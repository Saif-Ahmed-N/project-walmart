SELECT * FROM walmart;
--
SELECT
	DISTINCT payment_method,
    COUNT(*) AS NoOfPayments
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT Branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

-- BUSINESS PROBLEMS:

-- 1) Find different payment method and number of transactions, number of quantity sold

SELECT 
	payment_method,
	COUNT(*) AS no_of_transactions,
	SUM(quantity) AS no_of_qnty_sold
FROM walmart
GROUP BY payment_method;

-- 2) Identify the highest-rated category in each branch, displaying the branch, category, AVG RATING

SELECT 
	Branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS "rank"     # shows the rank of the category over each branch
FROM walmart
GROUP BY Branch,category;              # grouping both bcs we want to show the avr rating of each category from each branch 


-- 3) Identify the busiest day for each branch based on the number of transactions

SELECT
	Branch,
	# STR_TO_DATE(date, '%d/%m/%y') AS real_date,
	DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_of_week,
	COUNT(*) AS no_of_transactions,
	RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS 'rank'
FROM walmart
GROUP BY Branch,day_of_week;

-- 4) Calculate the total quantity of item sold per payment method. List payment_method and total quantity
SELECT
	payment_method,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;
 

-- 5) Determine the average,minimum and maximum rating of products for each city.
-- List the city, avg_rating, min_rating and max_rating.

SELECT 
	city,
    category,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city,category
ORDER BY city;

-- 6) Calculate the total profit for each category by considering the total_profit as 
-- (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
    SUM(total * profit_margin) AS total_profit            # bcs we have calculated total as unit_price * quatinty in python 
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
    
-- 7) Determine the most common payment method for each branch. Display branch and preffered_payment_method

WITH cte                         # creates a temporary table
AS
(SELECT 
	 Branch,
     payment_method,
     COUNT(*) AS total_transactions,
     RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS ranks
FROM walmart
GROUP BY Branch,payment_method
)
SELECT *
FROM cte
WHERE ranks = 1;

-- 8) Categorize sales into 3 groups MORNING, AFTERNOON and EVENING. Find out for each of the shifts their number of invoices

SELECT 
	Branch,
	CASE
		WHEN EXTRACT(HOUR FROM STR_TO_DATE(time,'%H:%i:%s'))< 12 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM STR_TO_DATE(time,'%H:%i:%s')) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
	END AS shift,
    COUNT(*) AS no_of_invoices
	# STR_TO_DATE(time,'%H:%i:%s') AS actual_time                    # converting text time into actual time
FROM walmart
GROUP BY Branch,shift
ORDER BY Branch,no_of_invoices DESC; 

 
 -- 9) Identify 5 branch with highest decrease ratio in revenue compare to last year(current year 2023 and last year 2022)
 -- finding year
 SELECT *,
	EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) AS real_date        # returns only year from that date 	
 FROM walmart;
 
 -- Actual program
 -- 2022 sales
 WITH revenue_2022
 AS
 (
	 SELECT 
		Branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
	GROUP BY Branch
 ),
-- 2023 sales
revenue_2023
AS
 (
	SELECT 
		Branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2023
	GROUP BY Branch
)
SELECT 
	Branch,
    ls.revenue AS last_yr_revenue,
    cs.revenue AS current_yr_revenue,
    ROUND((ls.revenue - cs.revenue)/ls.revenue*100,2) AS revenue_decrease_ratio             #revenue ratio formula = (lst_yr_revenue - crnt_yr_revenue)/lst_yr_revenue*100
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs USING (Branch)
WHERE ls.revenue> cs.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;                             # shows first 5 rows