SET SEARCH_PATH TO Project;

-- Answering Question 1: Is there a relationship between the rating of a company and the salary they offered?
DROP TABLE IF EXISTS Q1 cascade;
CREATE TABLE Q1 (
	-- total number of jobs
	total_num float, 
	-- number of jobs which have the same category for rating and salary
	same_category float,
	-- calculate the percentage of jobs which have the same category for rating and salary
    percentage float
);

-- Get the corresponding and rating information for each job
DROP VIEW IF EXISTS ratinginfo CASCADE;
CREATE VIEW ratinginfo AS
SELECT 0.5 * (salaryLB + salaryUB) as avg_salary, companyID, rating
FROM Job JOIN Company USING(companyID);

-- Categorize salary as 'high' or 'low' and its corresponding rating as 'high' or 'low'.
-- Salary is considered as high if it is greater than the mean salary, and low otherwise. 
-- Rating is considered as high if it is greater than the mean rating, and low otherwise. 
DROP VIEW IF EXISTS Category CASCADE;
CREATE VIEW Category AS
SELECT avg_salary, companyID, rating,
CASE
    WHEN avg_salary > (SELECT avg(avg_salary) FROM ratinginfo) THEN 'High'
    ELSE 'Low'
END AS salaryCategory,
CASE
    WHEN rating > (SELECT avg(rating) FROM ratinginfo) THEN 'High'
    ELSE 'Low'
END AS ratingCategory
FROM ratinginfo;

-- Count the number of jobs which have the same category for its salary and rating.
DROP VIEW IF EXISTS Counting CASCADE;
CREATE VIEW Counting AS
SELECT COUNT(*) as total_num, 
(SELECT COUNT(*)
FROM Category
WHERE salaryCategory = ratingCategory) as same_category
FROM Category;

insert into Q1
SELECT total_num, same_category, (1.0 * same_category)/total_num as percentage
FROM Counting;

-- Answering Question 2: Is there a city with a salary much higher than other cities?
-- Table to store the result
DROP TABLE IF EXISTS Q2 cascade;
CREATE TABLE Q2 (
	-- average salary for jobs in the corresponding city
    avg_salary float,
    -- city
    city TEXT,
	-- average salary for jobs across all cities
	average_across_city float
);

-- Join each job with its corresponding location.
DROP VIEW IF EXISTS salaryCity CASCADE;
CREATE VIEW salaryCity AS
SELECT salaryLB, salaryUB, city
FROM Job JOIN Company USING(companyID)
JOIN Location USING (LocationID);

-- Calculate the average salary of all jobs in a certain city.
DROP VIEW IF EXISTS avgSalary CASCADE;
CREATE VIEW avgSalary AS
SELECT avg((salaryLB+salaryUB)/2) AS avg_salary,city
FROM salaryCity
GROUP BY city
ORDER BY avg_salary DESC;

-- Insert the result to our table
insert into Q2
SELECT avg_salary, city, (SELECT avg(avg_salary) AS avg_across_city
FROM avgSalary) as average_across_city
FROM avgSalary
WHERE avg_salary in (SELECT max(avg_salary) FROM avgSalary);

-- Answering Question 3: Is that true that companies with higher revenues will give employees more salaries?
DROP TABLE IF EXISTS Q3 cascade;

-- Table to store the result
CREATE TABLE Q3 (
	-- category of the company, in 'highSalaryHighRevenue' or 'lowSalaryHighRevenue' or 'lowSalaryLowRevenue'
	-- or 'highSalaryLowRevenue'
    category TEXT,
    -- number of counts of this category
    totalNum INT
);

-- Join each job with its corresponding company.
DROP VIEW IF EXISTS salaryCompany CASCADE;
CREATE VIEW salaryCompany AS
SELECT salaryLB, salaryUB, companyID, headID
FROM Job JOIN Company USING(companyID);

-- Since each company may have several jobs, calculate the average salary of all jobs in a company.
DROP VIEW IF EXISTS companyAvgSalary CASCADE;
CREATE VIEW companyAvgSalary AS
SELECT avg((salaryLB+salaryUB)/2) AS salaryMean, companyID, headID
FROM salaryCompany
GROUP BY companyID, headID;

-- Calculate average salary and average revenue for each headquarter.
DROP VIEW IF EXISTS salaryRevenue CASCADE;
CREATE VIEW salaryRevenue AS
SELECT salaryMean, headID, (revenueLB+revenueUB)/2 AS revenueMean
FROM companyAvgSalary JOIN Headquarters USING(headID);

-- Categorize salary as 'high' or 'low' and revenue as 'high' or 'low'.
-- Salary is considered as high if it is greater than the mean salary, and low otherwise. 
-- Revenue is considered as high if it is greater than the mean revenue, and low otherwise. 
DROP VIEW IF EXISTS salaryRevenueCat CASCADE;
CREATE VIEW salaryRevenueCat AS
SELECT headID,
CASE
    WHEN salaryMean > (SELECT avg(salaryMean) FROM salaryRevenue) THEN 'High'
    ELSE 'Low'
END AS salaryCategory,
CASE
    WHEN revenueMean > (SELECT avg(revenueMean) FROM salaryRevenue) THEN 'High'
    ELSE 'Low'
END AS revenueCategory
FROM salaryRevenue;

-- Categorize each headquarter based on their salary category and revenue category.
DROP VIEW IF EXISTS headquarterCat CASCADE;
CREATE VIEW headquarterCat AS
SELECT headID,
CASE
    WHEN salaryCategory = 'High' and revenueCategory = 'High' THEN 'highSalaryHighRevenue'
    WHEN salaryCategory = 'Low' and revenueCategory = 'High' THEN 'lowSalaryHighRevenue'
    WHEN salaryCategory = 'Low' and revenueCategory = 'Low' THEN 'lowSalaryLowRevenue'
    ELSE 'highSalaryLowRevenue'
END AS headCat
FROM salaryRevenueCat;

-- Summary of each category of headquaters, including the name of the category and its total count.
DROP VIEW IF EXISTS summary CASCADE;
CREATE VIEW summary AS
SELECT headCat AS category, count(headCat) AS totalNum
FROM headquarterCat
GROUP BY headCat;

insert into Q3
SELECT *
FROM summary;