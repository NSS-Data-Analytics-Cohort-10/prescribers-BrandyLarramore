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

-- Nurse Practitioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?



--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, 
	SUM(CAST(total_drug_cost AS money)
FROM drug
INNER JOIN prescription
Using (drug_name)
GROUP BY generic_name
ORDER BY total_drug_cost DESC
		  
SELECT generic_name, 
       SUM(CAST(total_drug_cost AS money)) AS total_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY generic_name
ORDER BY total_cost DESC;
		
		
		
		  NOT WORKING

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name
FROM drug
INNER JOIN prescription

SELECT sum total drug cost divided by total_30_day_fill_count 
FROM prescription

7141?

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

SELECT *
FROM cbsa
WHERE LOWER(cbsaname) LIKE '%tn%';
		  
--58


--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT SUM(CAST(cbsa AS INT)) total_cbsa, cbsaname
FROM cbsa
GROUP BY cbsaname
ORDER BY total_cbsa DESC;

SELECT SUM(CAST(cbsa AS INT)) total_cbsa, cbsaname
FROM cbsa
GROUP BY cbsaname
ORDER BY total_cbsa;

-- largest: San Juan-Carolina_caguas, PR
-- smallest: Albany, OR
		  


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.




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

SELECT p.drug_name, p.total_claim_count, nppes_provider_first_name AS firtst_name, nppes_provider_last_org_name AS last_name,
    CASE
        WHEN opioid_drug_flag = 'Y' THEN 'Yes'
        ELSE 'No'
    END AS is_opioid
FROM prescription AS p
INNER JOIN drug AS rx
USING (drug_name)
INNER JOIN prescriber as dr
USING (npi)
WHERE p.total_claim_count > 3000

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT rx.npi, drug_name
FROM prescriber as dr
INNER JOIN prescription AS rx
USING (npi)
WHERE specialty_description = 'Pain Management';


--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT rx.npi, drug_name, total_claim_count, nppes_provider_last_org_name AS last_name
FROM prescriber as dr
INNER JOIN prescription AS rx
USING (npi)
WHERE specialty_description = 'Pain Management';

    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
		
		