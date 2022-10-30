/* 1. Find all the current employees with the same hire date as employee 101010 using a sub-query. */
USE employees;
SHOW TABLES;
DESCRIBE dept_emp; -- emp_no, dept_no, from_date, to_date
describe employees; -- emp_no, first_name, last_name, hire_date, gender
DESCRIBE titles; -- emp_no, title, from_date, to_date
DESCRIBE dept_manager; -- emp_no, dept_no, from_date, to_date

SELECT hire_date FROM employees
JOIN titles USING(emp_no)
WHERE emp_no = '101010' 
	AND titles.to_date > CURDATE();

SELECT * FROM employees
JOIN titles USING(emp_no)
WHERE hire_date IN(
		SELECT hire_date FROM employees
		JOIN titles USING(emp_no)
		WHERE emp_no = '101010'
		AND titles.to_date > curdate()
			)
AND titles.to_date > CURDATE();

/* 2. Find all the titles ever held by all current employees with the first name Aamod.
*/
SELECT * FROM employees
JOIN titles USING(emp_no)
WHERE first_name = 'Aamod';

SELECT to_date FROM titles
JOIN employees USING(emp_no)
WHERE to_date > CURDATE();

SELECT title FROM titles
JOIN employees USING(emp_no)
WHERE to_date IN(
		SELECT to_date FROM titles
		JOIN employees USING(emp_no)
		WHERE to_date > CURDATE()
		)
AND first_name = 'Aamod';


/* 3.  How many people in the employees table are no longer working for the company? Give the answer in a comment in your code.
203 184 people are no longer working for the company (if using titles) ; 91 479 (if using dept_emp).
*/

SELECT * FROM employees
JOIN dept_emp USING(emp_no)
WHERE dept_emp.to_date < CURDATE();

SELECT * FROM employees
JOIN titles USING(emp_no);

SELECT to_date, emp_no FROM dept_emp
JOIN employees USING(emp_no)
WHERE to_date IN(
		SELECT to_date FROM dept_emp
		JOIN employees USING(emp_no)
		)
AND to_date < CURDATE();

/* 4. Find all the current department managers that are female. List their names in a comment in your code.
Isamu Legleitner, Karsten Sigstam, Leon DasSarma, Hilary Kambil.
*/
SELECT * FROM dept_manager
WHERE to_date > CURDATE();

SELECT * FROM employees
JOIN dept_manager USING(emp_no)
WHERE to_date IN(
			SELECT to_date FROM dept_manager
			WHERE to_date > CURDATE()
			)
AND employees.gender = 'F';


/* 5.   Find all the employees who currently have a higher salary than the company's overall, historical average salary. */

SELECT AVG(salary) FROM salaries; -- emp_no, salary, from_date, to_date

SELECT * FROM salaries
WHERE salary > (
			SELECT AVG(salary)
			FROM salaries
				)
AND to_date > CURDATE()
ORDER BY salary ASC;

--
/* 6m   How many current salaries are within 1 standard deviation of the current highest salary? (Hint: you can use a built in function to calculate the standard deviation.) What percentage of all salaries is this?
        Hint You will likely use multiple subqueries in a variety of ways
        Hint It's a good practice to write out all of the small queries that you can. Add a comment above 		the query showing the number of rows returned. You will use this number (or the query that 				produced it) in other, larger queries.
*/

SELECT MAX(salary) FROM salaries
WHERE to_date > CURDATE();
-- this returns 1 row. 

SELECT STDDEV_POP(MAX(salary)) FROM salaries;
-- SQL does not like this query.

SELECT STDDEV_POP(salary) FROM salaries;
-- SQL will run this query, but idk of what it's a stddev. It returns 1 row. 

SELECT STDDEV_POP(salary) FROM salaries
WHERE salary IN(
		SELECT MAX(salary) FROM salaries
		WHERE to_date > CURDATE()
		)
AND to_date > CURDATE(); 
-- this returned 1 row, with the integer "0", and that's it.

SELECT MAX(salary) FROM salaries
WHERE salary IN(SELECT STDDEV_POP(salary) FROM salaries)
AND to_date > CURDATE(); 
-- this returned 1 row, with the word "NULL", and that's it.

SELECT to_date, salary
FROM salaries
WHERE STDDEV_POP(salary) < MAX(salary); 
-- SQL does not like this query.

SELECT STDDEV_POP(salary)
FROM (SELECT 
		MAX(salary) AS Max_Sal
		FROM salaries
		WHERE to_date > CURDATE()
		) AS Std_Dev_Max
GROUP BY salary;
-- "Unknown column 'salary' in 'field list'."

SELECT STDDEV_POP(MAX(Max_Sal))
FROM (SELECT 
		MAX(salary) AS Max_Sal
		FROM salaries
		WHERE to_date > CURDATE()
		GROUP BY to_date
		) AS Std_Dev_Max;
-- "Invalid use of group function."
-- at this point, i'm rather lost.