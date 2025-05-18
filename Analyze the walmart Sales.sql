CREATE DATABASE walmart;
USE walmart;

SELECT *
FROM walmart_cleaned;

-- 1. Analyze Payment Methods and Sales
-- What is the different payment methods 

SELECT DISTINCT(payment_method)
FROM walmart_cleaned;

-- How many  transactions and items were sold with each method

SELECT payment_method,COUNT(*)AS number_transaction, SUM(quantity) As number_items
FROM walmart_cleaned
GROUP BY payment_method
ORDER BY number_transaction DESC;

-- 2. Identify the highest-Rated category in each Branch
WITH highest_rated AS (
SELECT branch,category, ROUND(avg(rating),2) AS avg_rating,
       RANK() OVER(PARTITION BY branch ORDER BY category, avg(rating)) AS rang
FROM walmart_cleaned
GROUP BY branch,category)
SELECT branch, category, avg_rating AS highest_avg_rated
FROM highest_rated
WHERE rang=1
ORDER BY highest_avg_rated DESC;

-- 3. DETERMINE THE busiest day for each branch
WITH highest_day AS(
SELECT branch, DAYNAME(str_to_date(`date`,'%d/%m/%Y')) AS day_week, Count(*)AS number_transaction ,
       RANK() OVER(PARTITION BY branch ORDER BY Count(*) DESC) AS rank_day
FROM walmart_cleaned
GROUP BY branch, day_week)
SELECT branch, day_week, number_transaction
FROM highest_day
WHERE rank_day =1;

-- 4. Analyze Category Ratings by city
SELECT city, category, ROUND(AVG(rating),2) AS avg_rating, MIN(rating)AS min_rating, MAX(rating)AS max_rating
FROM walmart_cleaned
GROUP BY city, category
ORDER BY City, avg_rating DESC;

-- 5. Calculate Total Profit by Category
SELECT category,ROUND(SUM(total_price),2) AS Total_Profit,
      RANK() OVER(ORDER BY SUM(total_price) DESC) AS rank_profit
FROM walmart_cleaned
GROUP BY category;

-- 6. Determine the most Common Payment Method per Branch
SELECT branch, payment_method, COUNT(*)AS frequence_use
FROM walmart_cleaned
GROUP BY branch, payment_method
ORDER BY branch,frequence_use DESC;

-- 7. Analyze Sales shifts throughout the Day
SELECT branch, 
    CASE 
        WHEN TIME(`time`) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(`time`) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN TIME(`time`) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Night' -- Covers 00:00:00 to 05:59:59
    END AS shift, 
    COUNT(*)AS total_transactions
FROM walmart_cleaned
GROUP BY branch, shift
ORDER BY branch, total_transactions DESC;


-- 8. Identify Branches with highest Revenue Decline Year-Over-Year
WITH profit AS(
    SELECT YEAR(str_to_date(`date`,'%d/%m/%Y'))AS year_date, SUM(total_price) AS total_profit
    FROM walmart_cleaned
    GROUP BY year_date)
SELECT year_date, ROUND(total_profit,2)AS actual_profit,
       ROUND(LAG(total_profit) OVER(ORDER BY year_date),2) AS previous_profit,
       ROUND(((total_profit-LAG(total_profit) OVER(ORDER BY year_date))/LAG(total_profit) OVER(ORDER BY year_date))*100,2)AS yoy_percentage_change
FROM profit;






 


 

