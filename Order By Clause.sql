#Group By clause

SELECT * 
FROM parks_and_recreation.employee_demographics;

SELECT gender, AVG(age), MIN(age), COUNT(AGE)
FROM employee_demographics
GROUP BY gender
;

SELECT occupation, salary
FROM employee_salary
GROUP BY occupation, salary
;

#Order by
SELECT *
FROM employee_demographics
ORDER BY gender, age
;
