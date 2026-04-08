-- =============================================
-- SALARY PREDICTION PROJECT
-- Stage 1: Data Loading
-- =============================================

-- Create the database
CREATE DATABASE salary_db;

-- Select the database to use
USE salary_db;

-- Create the table with correct column types
CREATE TABLE job_salaries (
    job_title VARCHAR(100),
    experience_years INT,
    education_level VARCHAR(50),
    skills_count INT,
    industry VARCHAR(100),
    company_size VARCHAR(50),
    location VARCHAR(100),
    remote_work VARCHAR(20),
    certifications INT,
    salary INT
);

-- Load the CSV data into the table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/job_salary_prediction_dataset.csv'
INTO TABLE job_salaries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify data loaded successfully
SELECT COUNT(*) FROM job_salaries;

-- =============================================
-- Stage 2: Data Cleaning
-- =============================================

-- Check for NULL values in all columns
SELECT 
    SUM(job_title IS NULL) AS null_job_title,
    SUM(experience_years IS NULL) AS null_experience,
    SUM(education_level IS NULL) AS null_education,
    SUM(skills_count IS NULL) AS null_skills,
    SUM(industry IS NULL) AS null_industry,
    SUM(company_size IS NULL) AS null_company_size,
    SUM(location IS NULL) AS null_location,
    SUM(remote_work IS NULL) AS null_remote_work,
    SUM(certifications IS NULL) AS null_certifications,
    SUM(salary IS NULL) AS null_salary
FROM job_salaries;

-- Result: No NULLs found in any column ✓


-- Check for duplicate rows


SELECT 
    job_title, experience_years, education_level,
    skills_count, industry, company_size,
    location, remote_work, certifications, salary,
    COUNT(*) AS duplicate_count
FROM job_salaries
GROUP BY 
    job_title, experience_years, education_level,
    skills_count, industry, company_size,
    location, remote_work, certifications, salary
HAVING COUNT(*) > 1;

-- Result: No duplicates found ✓


-- : Check consistency of categorical columns
SELECT DISTINCT remote_work FROM job_salaries;
-- Result: Yes, No, Hybrid ✓

SELECT DISTINCT education_level FROM job_salaries;
-- Result: Bachelor, PhD, High School, Diploma, Master ✓

SELECT DISTINCT industry FROM job_salaries;
-- Result: 10 clear industries ✓

SELECT DISTINCT company_size FROM job_salaries;
-- Result: Small, Medium, Large, Enterprise, Startup
--  Note: Enterprise and Startup sit alongside Small/Medium/Large

SELECT DISTINCT location FROM job_salaries;
-- Result: 10 values - India, Australia, Singapore, Canada, 
--         Sweden, USA, Netherlands, Remote, Germany, UK
-- ⚠️ Note: 'Remote' appears as a location but it's not a country
--          We already have remote_work column for this

SELECT DISTINCT job_title FROM job_salaries;
-- Result: 12 clear job titles - Frontend Developer, Business Analyst,
--         Product Manager, Backend Developer, Machine Learning Engineer,
--         DevOps Engineer, Software Engineer, Cybersecurity Analyst,
--         Data Scientist, Cloud Engineer, AI Engineer, Data Analyst
-- All consistently spelled and logically correct ✓

-- Question 4: Check for outliers in numerical columns
SELECT 
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    AVG(salary) AS avg_salary,
    MIN(experience_years) AS min_experience,
    MAX(experience_years) AS max_experience,
    MIN(skills_count) AS min_skills,
    MAX(skills_count) AS max_skills,
    MIN(certifications) AS min_certifications,
    MAX(certifications) AS max_certifications
FROM job_salaries;
-- Result: salary 31867 - 333046 avg 145718 ✓
--         experience 0 - 20 years ✓
--         skills 1 - 19 ✓
--         certifications 0 - 5 ✓
-- All values make real world sense, no outliers found ✓

-- =============================================
-- Stage 3: Exploratory Data Analysis (EDA)
-- =============================================

-- Question 1: Which job title pays the most?

SELECT 
    job_title, 
    ROUND(AVG(salary), 2) AS avg_salary
FROM job_salaries
GROUP BY job_title
ORDER BY avg_salary DESC;

-- Result: AI Engineer pays the most, Data Analyst pays the least

-- Question 2: How many people have PhD and earn more than 100k?

SELECT COUNT(*) AS phd_above_100k
FROM job_salaries
WHERE education_level = 'PhD' AND salary >= 100000;

-- Extended: Compare all education levels above 100k

SELECT 
    education_level,
    COUNT(*) AS count_above_100k
FROM job_salaries
WHERE salary >= 100000
GROUP BY education_level
ORDER BY count_above_100k DESC;

-- Conclusion: PhD earns most above 100k (47,894) vs High School (41,294)
-- Gap is only 6,600 — education alone may not be the biggest salary driver
-- This leads us to Question 3 — what factor matters most?


-- =============================================
-- Stage 3: Exploratory Data Analysis (EDA)
-- =============================================

-- Question 1: Which job title pays the most?
SELECT 
    job_title, 
    ROUND(AVG(salary), 2) AS avg_salary
FROM job_salaries
GROUP BY job_title
ORDER BY avg_salary DESC;
-- Result: AI Engineer pays the most, Data Analyst pays the least ✓

-- Question 2: How many people have PhD and earn more than 100k?
SELECT COUNT(*) AS phd_above_100k
FROM job_salaries
WHERE education_level = 'PhD' AND salary >= 100000;
-- Result: 47,894 people ✓

-- Extended Q2: Compare all education levels above 100k

SELECT 
    education_level,
    COUNT(*) AS count_above_100k
FROM job_salaries
WHERE salary >= 100000
GROUP BY education_level
ORDER BY count_above_100k DESC;

-- Result: PhD(47894) Master(47069) Bachelor(44466) Diploma(42941) High School(41294)
-- Conclusion: Small gap of only 6,600 between PhD and High School ✓


Question 3: What drives salary more - education, skills or industry?
-- 3a: Industry vs salary

SELECT 
    industry,
    ROUND(AVG(salary), 2) AS avg_salary
FROM job_salaries
GROUP BY industry
ORDER BY avg_salary DESC;
-- Result: Education(145993) to Retail(145399) 
-- Conclusion: Only 594 difference - industry has minimal impact ✓

-- 3b: Skills vs salary

SELECT 
    skills_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM job_salaries
GROUP BY skills_count
ORDER BY skills_count ASC;
-- Result: 15k difference between 1 skill and 19 skills
-- Conclusion: Skills have moderate impact ✓

-- 3c: Education level vs salary

SELECT 
    education_level,
    ROUND(AVG(salary), 2) AS avg_salary
FROM job_salaries
GROUP BY education_level
ORDER BY avg_salary DESC;
-- Result: PhD(163976) Master(153305) Bachelor(142410) Diploma(137158) High School(131715)
-- Conclusion: 32,261 gap - EDUCATION IS THE BIGGEST SALARY DRIVER ✓

-- Overall Q3 Conclusion:
-- Education impact: 32,261 gap ← BIGGEST FACTOR
-- Skills impact: 15,000 gap ← moderate
-- Industry impact: 594 gap ← minimal
-- Education is the strongest single driver of salary in this dataset

-- Question 4: How does location affect salary?
SELECT 
    location,
    ROUND(AVG(salary), 2) AS avg_salary
FROM job_salaries
GROUP BY location
ORDER BY avg_salary DESC;

-- Result: USA(181716) Canada(167391) UK(160075) Germany(153376)
--         Remote(139442) Sweden(139440) Australia(139362)
--         Singapore(139340) Netherlands(139294) India(97690)
-- Gap of 84,026 between USA and India
-- Conclusion: LOCATION IS THE BIGGEST SALARY DRIVER ✓
-- Overturns Q3 conclusion - location beats education!


-- Question 5: How does company size affect salary?

SELECT 
    company_size,
    ROUND(AVG(salary), 2) AS average_salary
FROM job_salaries
GROUP BY company_size
ORDER BY average_salary DESC;
-- Result: Enterprise(169616) Large(155711) Medium(141537) 
--         Small(134356) Startup(127289)
-- Gap of 42,327 between Enterprise and Startup
-- Conclusion: Bigger company = higher salary ✓
