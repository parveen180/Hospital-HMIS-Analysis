-- =========================================================
-- PATIENT & ADMISSION ANALYSIS
-- =========================================================


-- 1. Find the total number of patients.
SELECT 
    COUNT(patient_id) AS total_patients
FROM patient;


-- 2. Find the number of male and female patients.
SELECT 
    gender,
    COUNT(patient_id) AS no_of_patients
FROM patient
GROUP BY gender
ORDER BY no_of_patients DESC;


-- 3. List patients who are above 60 years old.
SELECT *
FROM patient
WHERE age > 60;


-- 4. Find all patients admitted through Emergency admission.
SELECT 
    patient_id,
    admission_type
FROM admission_db
WHERE admission_type = 'Emergency';


-- 5. Find patients whose treatment cost is greater than ₹50,000.
SELECT 
    p.patient_id,
    b.total_amount AS treatment_cost
FROM billing AS b
JOIN admission_db AS a
    ON b.admission_id = a.admission_id
JOIN patient AS p
    ON a.patient_id = p.patient_id
WHERE b.total_amount > 50000;


-- 6. List patients ordered by treatment cost
--    and disease from highest to lowest.
SELECT 
    p.patient_id,
    b.total_amount AS treatment_cost,
    d.disease_name
FROM billing AS b
JOIN admission_db AS a
    ON b.admission_id = a.admission_id
JOIN patient AS p
    ON a.patient_id = p.patient_id
JOIN disease AS d
    ON a.disease_id = d.disease_id
ORDER BY b.total_amount DESC;


-- 7. Find the average treatment cost before and after insurance.
SELECT 
    AVG(total_amount) AS avg_total_bill,
    AVG(patient_payable_amount) AS avg_amount_after_insurance
FROM billing;


-- 8. Find the maximum and minimum treatment cost.
SELECT 
    MAX(total_amount) AS max_total_bill,
    MAX(patient_payable_amount) AS max_amount_after_insurance,
    MIN(total_amount) AS min_total_bill,
    MIN(patient_payable_amount) AS min_amount_after_insurance
FROM billing;


-- 9. Calculate the total treatment cost by department.
SELECT 
    d.department_name,
    SUM(b.total_amount) AS total_cost
FROM department AS d
JOIN admission_db AS a
    ON d.department_id = a.department_id
JOIN billing AS b
    ON a.admission_id = b.admission_id
GROUP BY d.department_name
ORDER BY total_cost DESC;


-- 10. Find the average treatment cost by medical condition.
SELECT 
    d.disease_name,
    ROUND(AVG(b.total_amount), 2) AS average_treatment_cost
FROM disease AS d
JOIN admission_db AS a
    ON d.disease_id = a.disease_id
JOIN billing AS b
    ON a.admission_id = b.admission_id
GROUP BY d.disease_name
ORDER BY average_treatment_cost DESC;


-- 11. Find the number of patients in each department.
SELECT 
    d.department_name,
    COUNT(p.patient_id) AS number_of_patients
FROM department AS d
JOIN admission_db AS a
    ON d.department_id = a.department_id
JOIN patient AS p
    ON a.patient_id = p.patient_id
GROUP BY d.department_name
ORDER BY number_of_patients DESC;


-- 12. Find the number of patients for each admission type.
SELECT 
    admission_type,
    COUNT(patient_id) AS number_of_patients
FROM admission_db
GROUP BY admission_type
ORDER BY number_of_patients DESC;


-- 13. Find departments having more than 1,000 patients.
SELECT 
    d.department_name,
    COUNT(p.patient_id) AS number_of_patients
FROM department AS d
JOIN admission_db AS a
    ON d.department_id = a.department_id
JOIN patient AS p
    ON a.patient_id = p.patient_id
GROUP BY d.department_name
HAVING COUNT(p.patient_id) > 1000;


-- 14. Find diseases where the average treatment cost
--     is greater than the overall average treatment cost.
SELECT 
    d.disease_name,
    AVG(b.total_amount) AS avg_treatment_cost
FROM disease AS d
JOIN admission_db AS a
    ON d.disease_id = a.disease_id
JOIN billing AS b
    ON a.admission_id = b.admission_id
GROUP BY d.disease_name
HAVING AVG(b.total_amount) > (
    SELECT AVG(total_amount)
    FROM billing
);


-- 15. Find patients whose treatment cost is higher
--     than the average treatment cost.
SELECT 
    p.patient_id,
    b.total_amount AS treatment_cost
FROM billing AS b
JOIN admission_db AS a
    ON b.admission_id = a.admission_id
JOIN patient AS p
    ON a.patient_id = p.patient_id
WHERE b.total_amount > (
    SELECT AVG(total_amount)
    FROM billing
);


-- 16. Categorize patients into age groups:
--     Under 18  → Child
--     18–40     → Young Adult
--     41–60     → Middle Age
--     Above 60  → Senior

SELECT 
    patient_id,
    age,
    CASE
        WHEN age < 18 THEN 'Child'
        WHEN age BETWEEN 18 AND 40 THEN 'Young Adult'
        WHEN age BETWEEN 41 AND 60 THEN 'Middle Age'
        ELSE 'Senior'
    END AS age_group
FROM patient;


-- 17. Find the most common medical condition.
SELECT 
    d.disease_name,
    COUNT(p.patient_id) AS no_of_patients
FROM disease AS d
JOIN admission_db AS a
    ON d.disease_id = a.disease_id
JOIN patient AS p
    ON a.patient_id = p.patient_id
GROUP BY d.disease_name
ORDER BY no_of_patients DESC
LIMIT 1;


-- 18. Find the department with the highest number
--     of emergency admissions.
SELECT 
    d.department_name,
    COUNT(a.admission_id) AS no_of_admissions
FROM department AS d
JOIN admission_db AS a
    ON d.department_id = a.department_id
WHERE a.admission_type = 'Emergency'
GROUP BY d.department_name
ORDER BY no_of_admissions DESC
LIMIT 1;


-- 19. Find patients who stayed in the hospital longer
--     than the average length of stay.
SELECT 
    p.patient_id,
    a.admitted_days
FROM patient AS p
JOIN admission_db AS a
    ON p.patient_id = a.patient_id
WHERE a.admitted_days > (
    SELECT AVG(admitted_days)
    FROM admission_db
);

-- 20. Rank departments based on total treatment cost

SELECT 
    d.department_name,
    SUM(b.total_amount) AS total_treatment_cost,
    DENSE_RANK() OVER (
        ORDER BY SUM(b.total_amount) DESC
    ) AS cost_rank
FROM department AS d
JOIN admission_db AS a
    ON d.department_id = a.department_id
JOIN billing AS b
    ON a.admission_id = b.admission_id
GROUP BY d.department_name
ORDER BY cost_rank;