use amazon;
-- ---------------------------------------------------------------------------------------------

-- Data Wrangling: 

SELECT 
    *
FROM
    sales_data
WHERE
    Invoice_ID IS NULL OR branch IS NULL
        OR city IS NULL
        OR customer_type IS NULL
        OR gender IS NULL
        OR product_line IS NULL
        OR unit_price IS NULL
        OR Quantity IS NULL
        OR tax_5 IS NULL
        OR date IS NULL
        OR time IS NULL
        OR payment IS NULL
        OR cogs IS NULL
        OR gross_margin_percentage IS NULL
        OR gross_income IS NULL
        OR rating IS NULL; 
SELECT * FROM amazon.sales_data;

-- -------------------------------------------------------------------
-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.

ALTER TABLE sales_data ADD timeofday VARCHAR(15);

UPDATE sales_data 
SET 
    timeofday = CASE
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END
WHERE
    invoice_id IS NOT NULL;
    
-- COMMENT : ADDING A NEW COLUMN TIMEOF DAY WHEN TIME BETWEEN 6 - 11 'MORNING' AND 12 - 17 'AFTERNOON' AND 18 - 23 'EVENING'
  
-- -----------------------------------------------------------------------
--  Add a new column named dayname that contains the extracted days of the week on which 
--  the given transaction took place (Mon, Tue, Wed, Thur, Fri).

ALTER TABLE sales_data ADD dayname VARCHAR(10);

UPDATE sales_data 
SET 
    dayname = DAYNAME(date);
    
-- COMMENT : ADDING A NEW COLUMN OF DAYNAME THAT CONTAINS THE EXTRACTED DAY OF THE WEEK 
    
-- -------------------------------------------------------------------------

-- Add a new column named monthname that contains the extracted months of the year on which
-- the given transaction took place (Jan, Feb, Mar).

ALTER TABLE sales_data ADD monthName varchar(10);

UPDATE sales_data 
SET 
    monthname = MONTHNAME(date);

-- COMMENT : ADDING A NEW COLUMN 'MONTHNAME' THAT CONTAINS THE EXTRACTED MONTHS OF THE YEAR

-- ------------------------------------------------------------------


-- 1) What is the count of distinct cities in the dataset?

SELECT 
    COUNT(DISTINCT (city)) AS distinct_citys
FROM
    sales_data;

-- COMMENT : '3' IS THE COUNT OF DISTINCT CITIES IN THE DATASET

-- ---------------------------------------------------------------------

-- 2) For each branch, what is the corresponding city?

SELECT 
    branch, city
FROM
    sales_data
GROUP BY branch , city;

-- COMMENT : A YANGON
-- 			 B MANDALAY
--           C NAYPYITAW
-- -- -----------------------------------------------------------------------

-- 3) What is the count of distinct product lines in the dataset?

SELECT 
    COUNT(DISTINCT (product_line)) AS distinct_product_line
FROM
    sales_data;
    
-- COMMENT : '6' IS THE COUNT OF DISTINCT PROUDCT LINES IN THE DATASET

-- -------------------------------------------------------------------------

-- 4) Which payment method occurs most frequently?


SELECT 
    payment, COUNT(*) AS frequence
FROM
    sales_data
GROUP BY payment
ORDER BY frequence DESC
LIMIT 1;

-- COMMENT : 'CASH' PAYMENT METHOD OCCURS MOST FREQUENTLY 
-- -------------------------------------------------------------------------

-- 5) Which product line has the highest sales?

SELECT 
    product_line, SUM(total) AS total_sales
FROM
    sales_data
GROUP BY product_line
ORDER BY total_sales DESC
LIMIT 1;

-- COMMENT : 'Home and lifestyle'	2458.2810000000004 HAS THE HIGHEST SALES IN DATASET

-- -------------------------------------------------------------------------

-- 6) How much revenue is generated each month


SELECT 
    YEAR(date) AS year,
    MONTHNAME(date) AS month,
    SUM(total) AS monthly_revenue
FROM
    sales_data
GROUP BY YEAR , MONTH
ORDER BY YEAR , MONTH;

-- COMMENT : 2019	Febr-- uary	3457.4295
--           2019	January	3938.1615
-- 			 2019	March	5601.204
-- --------------------------------------------------------------------------

-- 7) In which month did the cost of goods sold reach its peak?

SELECT 
    MONTHNAME(date) month, SUM(cogs) AS total_cogs
FROM
    sales_data
GROUP BY month
ORDER BY total_cogs DESC
LIMIT 1;

-- COMMENT : March	5334.48

-- ---------------------------------------------------------------------------

-- 8) Which product line generated the highest revenue?

SELECT 
    product_line, SUM(total) AS total_revenue
FROM
    sales_data
GROUP BY Product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- COMMENT : Home and lifestyle	2458.2810000000004

-- ------------------------------------------------------------------------

-- 9) In which city was the highest revenue recorded?

SELECT 
    city, SUM(total) AS total_revenue
FROM
    sales_data
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- COMMENT : Mandalay	4746.252
-- -----------------------------------------------------------------------

-- 10) Which product line incurred the highest Value Added Tax?

select product_line, sum(total) as highest_value_tax from sales_data
group by Product_line
order by highest_value_tax desc
limit 1;

-- COMMENT : Home and lifestyle	2458.2810000000004

-- --------------------------------------------------------------------

-- 11)For each product line, add a column indicating "Good" if its sales are 
-- above average, otherwise "Bad."

SELECT 
    product_line,
    SUM(total) AS total_sales,
    CASE
        WHEN
            SUM(total) > (SELECT 
                    AVG(total)
                FROM
                    sales_data)
        THEN
            'Good'
        ELSE 'Bad'
    END AS performance
FROM
    sales_data
GROUP BY product_line;

-- COMMENT :  Health and beauty	2105.8905	Good
-- 			  Electronic accessories	2117.871	Good
-- 			  Home and lifestyle	2458.2810000000004	Good
-- 			  Fashion accessories	2240.679	Good
-- 			  Food and beverages	1816.8465	Good
--            Sports and travel	2257.2270000000003	Good

-- -----------------------------------------------------------------------

-- 12) Identify the branch that exceeded the average number of products sold.

SELECT 
    branch, SUM(quantity) AS total_products_sold
FROM
    sales_data
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales_data);
      --   
-- -- COMMENT :	A	66
-- 				B	70
-- 				C	73
        
-- -------------------------------------------------------------------------

-- 13) Which product line is most frequently associated with each gender?        

WITH GenderProductRank AS (
    SELECT 
        gender, 
        product_line, 
        COUNT(*) AS frequency,
        RANK() OVER (PARTITION BY gender ORDER BY count(*) DESC) AS rak
    FROM sales_data
    GROUP BY gender, product_line
)
SELECT gender, product_line, frequency
FROM GenderProductRank
WHERE rak = 1;

-- COMMENT : Female	Electroni-- c accessories	5
-- 			 Male	Health and beauty	        5
-- ------------------------------------------------------------------------

-- 14) Calculate the average rating for each product line.

SELECT 
    product_line, AVG(rating) AS average_rating
FROM
    sales_data
GROUP BY product_line;

-- COMMENT : Health and--  beauty	7.6000000000000005
-- 						   Electronic accessories	7.333333333333333
-- 						   Home and lifestyle	6.166666666666668
-- 						   Fashion accessories	7.6000000000000005
-- 						   Food and beverages	7.816666666666666
-- 						   Sports and travel	6.5

-- --------------------------------------------------------------------------

-- 15) Count the sales occurrences for each time of day on every weekday.

SELECT 
    DAYNAME(date) AS weekday, timeofday, COUNT(*) AS sales_count
FROM
    sales_data
GROUP BY weekday , timeofday
ORDER BY FIELD(weekday,
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday') , timeofday;
        
-- COMMENT : Monday	Afternoon	1
-- Monday	Evening	1
-- Tuesday	Afternoon	3
-- Tuesday	Evening	3
-- Tuesday	Morning	1
-- Wednesday	Afternoon	2
-- Wednesday	Evening	2
-- Wednesday	Morning	1
-- Thursday	Afternoon	3
-- Thursday	Morning	1
-- Friday	Afternoon	5
-- Saturday	Afternoon	6
-- Saturday	Evening	2
-- Saturday	Morning	2
-- Sunday	Afternoon	1
-- Sunday	Evening	2
-- -----------------------------------------------------------------------

-- 16) Identify the customer type contributing the highest revenue.

SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    sales_data
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- COMMENT : Normal	6629.868
-- ------------------------------------------------------------------------

-- 17) Determine the city with the highest VAT percentage.

SELECT 
    city, AVG(tax_5) AS average_vat_percentage
FROM
    sales_data
GROUP BY city
ORDER BY average_vat_percentage DESC
LIMIT 1;

-- COMMENT : Mandalay	18.83433333333333
-- ------------------------------------------------------------------------

-- 18) Identify the customer type with the highest VAT payments.

SELECT 
    customer_type, SUM(Tax_5) AS total_vat_paid
FROM
    sales_data
GROUP BY customer_type
ORDER BY total_vat_paid DESC
LIMIT 1;

-- COMMENT : Normal	315.70799999999997
-- -------------------------------------------------------------------------

-- 19) What is the count of distinct customer types in the dataset?

SELECT 
    COUNT(DISTINCT customer_type) AS distinct_customer_types
FROM
    sales_data;

-- COMMENT : 2
-- --------------------------------------------------------------------------

-- 20) What is the count of distinct payment methods in the dataset?

SELECT 
    COUNT(DISTINCT (payment)) AS distinct_payment_methods
FROM
    sales_data;
    
-- COMMENT : 3
-- -------------------------------------------------------------------------

-- 21) Which customer type occurs most frequently?

SELECT 
    customer_type, COUNT(*) AS frequency
FROM
    sales_data
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;

-- COMMENT : Member	18
-- --------------------------------------------------------------------------

-- 22) Identify the customer type with the highest purchase frequency.

SELECT 
    customer_type, COUNT(*) AS purchase_frequency
FROM
    sales_data
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

-- COMMENT : Member	18
-- ------------------------------------------------------------------------

--  23) Determine the predominant gender among customers.

SELECT 
    gender, COUNT(*) AS frequency
FROM
    sales_data
GROUP BY gender
ORDER BY frequency DESC
LIMIT 1;

-- COMMENT : Male	18
-- --------------------------------------------------------------------------

-- 24) Examine the distribution of genders within each branch.

SELECT 
    branch, gender, COUNT(*) AS gender_count
FROM
    sales_data
GROUP BY branch , gender
ORDER BY branch , gender;

-- COMMENT : A	Female	4
-- A	Male	8
-- B	Female	7
-- B	Male	5
-- C	Female	7
-- C	Male	5
-- -------------------------------------------------------------------------

-- 25) Identify the time of day when customers provide the most ratings.

SELECT 
    timeofday, COUNT(rating) AS rating_count
FROM
    sales_data
WHERE
    rating
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;

-- COMMENT : Afternoon	21
-- -------------------------------------------------------------------------

-- 26) Determine the time of day with the highest customer ratings for each branch.

SELECT 
    branch, timeofday, COUNT(rating) AS rating_count
FROM
    sales_data
WHERE
    rating IS NOT NULL
GROUP BY branch , timeofday
ORDER BY branch , rating_count DESC;

-- COMMENT : A	Afternoon	9
-- A	Evening	2
-- A	Morning	1
-- B	Afternoon	6
-- B	Evening	4
-- B	Morning	2
-- C	Afternoon	6
-- C	Evening	4
-- C	Morning	2

-- --------------------------------------------------------------------------

-- 27) Identify the day of the week with the highest average ratings.

SELECT 
    DAYNAME(date) AS day_of_week, AVG(rating) AS average_rating
FROM
    sales_data
WHERE
    rating IS NOT NULL
GROUP BY DAYNAME(date)
ORDER BY average_rating DESC
LIMIT 1;

-- COMMENT : Monday	9.65
-- ------------------------------------------------------------------------

-- 28) Determine the day of the week with the highest average ratings for each branch.

WITH BranchDayRank AS (
    SELECT 
        branch, 
        DAYNAME(date) AS day_of_week, 
        AVG(rating) AS average_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rak
    FROM sales_data
    WHERE rating IS NOT NULL
    GROUP BY branch, DAYNAME(date)
)
SELECT branch, day_of_week, average_rating
FROM BranchDayRank
WHERE rak = 1;

-- COMMENT :
-- A	Sunday	8.4
-- B	Monday	9.9
-- C	Monday	9.4
-------------------- PROJECT END ----- THANK YOU -------------------------













