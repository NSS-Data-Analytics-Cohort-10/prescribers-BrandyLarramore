-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS claim_count_sum, nppes_provider_last_org_name AS last_name 
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY npi, last_name
ORDER BY SUM(total_claim_count) DESC;

--PENDLEY
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name AS last_name, specialty_description, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY npi, nppes_provider_last_org_name, nppes_provider_first_name, specialty_description
ORDER BY claim_count_sum DESC;


--Bruce Pendly, Family practice, 99707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
LEFT JOIN prescription
USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

-- Family Practice

--     b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count) AS sum_of_claim_count
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

Right, leave it
-- Nurse Practitioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?



--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost)
FROM prescription AS x
LEFT JOIN drug AS d
USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC;

--Insulin has the highest total

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, CAST(SUM(total_drug_cost)/SUM(total_day_supply) AS MONEY) AS cost_per_day
FROM prescription AS x
LEFT JOIN drug AS d
USING(drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;

-- C1 ESTERASE INHIBITOR

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name, SUM(total_drug_cost) AS total_cost,
CASE
    WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither'
END AS drug_category
FROM drug
LEFT JOIN prescription
USING (drug_name)
GROUP BY drug_name, drug_category


--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.


WITH categorized AS
(SELECT drug_name, CAST(SUM(total_drug_cost) AS MONEY) AS total_cost,
CASE
    WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither'
END AS drug_category
FROM drug
LEFT JOIN prescription
USING (drug_name)
GROUP BY drug_name, drug_category)
SELECT drug_category, CAST(SUM(total_cost) AS MONEY) AS total_cost
FROM categorized
GROUP BY drug_category
ORDER BY total_cost DESC;


-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT(cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%TN%';
		  
-- 10 in TN


--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.


SELECT cbsaname AS cbsa_name,
SUM(p.population) AS total_population
FROM cbsa AS c
INNER JOIN population AS p
USING (fipscounty)
GROUP BY c.cbsa, cbsaname
ORDER BY total_population DESC;

-- largest: Nashville-Davidson_Murfreesboro-Franklin, TN

SELECT cbsaname AS cbsa_name,
SUM(p.population) AS total_population
FROM cbsa AS c
INNER JOIN population AS p
USING (fipscounty)
GROUP BY c.cbsa, cbsaname
ORDER BY total_population;

-- smallest: Morristown, TN
		  


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT *
FROM population AS p
INNER JOIN fips_county AS fc USING(fipscounty)
LEFT JOIN cbsa USING (fipscounty)
WHERE cbsa IS null
ORDER BY population DESC
LIMIT 1;

--"SEVIER" 95,523
-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 3000;


--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT p.drug_name, p.total_claim_count,
    CASE
        WHEN opioid_drug_flag = 'Y' THEN 'Yes'
        ELSE 'No'
    END AS is_opioid
FROM prescription AS p
INNER JOIN drug AS d
USING (drug_name)
WHERE p.total_claim_count > 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT p.drug_name, p.total_claim_count,
CASE WHEN d.opioid_drug_flag = 'Y'
THEN 'Y' ELSE '' END AS opioid_flag,
p2.nppes_provider_first_name ||' '|| p2.nppes_provider_last_org_name AS prescriber_name
FROM drug AS d
INNER JOIN prescription AS p
USING (drug_name)
INNER JOIN prescriber AS p2
USING (npi)
WHERE p.total_claim_count >= 3000;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT p.npi, d.drug_name
FROM prescriber AS p
CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p.npi, d.drug_name, SUM(p2.total_claim_count)
FROM prescriber AS p
CROSS JOIN drug AS d
FULL JOIN prescription AS p2
USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY d.drug_name, p.npi
ORDER BY SUM(p2.total_claim_count) DESC;
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
		
SELECT p.npi, d.drug_name, COALESCE(SUM(p2.total_claim_count), '0')
FROM prescriber AS p
CROSS JOIN drug AS d
FULL JOIN prescription AS p2
USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY d.drug_name, p.npi
ORDER BY SUM(p2.total_claim_count) DESC;