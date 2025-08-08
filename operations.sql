-- Creat Database
CREATE DATABASE omniretail_sales_data;

-- CREATE TABLE 
CREATE TABLE sales_data (
				Sale_ID	VARCHAR (20),
				Sale_Date DATE,
				Customer_ID	VARCHAR (20),
				Product_ID VARCHAR (20),
				Product_Category VARCHAR (20),	
				Store_ID VARCHAR (20),	
				Region VARCHAR (20),	
				Quantity_Sold INT,	
				Unit_Price FLOAT,
				Payment_Method VARCHAR (20),	
				Returned VARCHAR (20),
				Total_Sale_Amount FLOAT
				);
ALTER TABLE sales_data 
ADD PRIMARY KEY (Sale_ID);

DESCRIBE sales_data;

SELECT * FROM sales_data;

-- INSERT data done

-- ## Business Case Problem Questions ##

-- 1.	Which region has the highest total revenue?

SELECT 
	   Region,
	   ROUND(SUM(Total_Sale_Amount),2) 
       AS total_revenue
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 2.	Which product category generates the highest revenue on average per sale?

SELECT 
		Product_Category,
        ROUND(AVG(Total_Sale_Amount),2) 
        AS Revenue
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 3.	What is the return rate per product category?

SELECT
		Product_Category,
        CONCAT(ROUND(COUNT(Returned) * 100 / (SELECT COUNT(*) 
        FROM sales_data),2),'%') 
        AS Return_rate_per_product
FROM sales_data
WHERE Returned = 'YES'
GROUP BY 1
ORDER BY 2 DESC;



-- 4.	Identify the top 5 products with the highest total sales by quantity.

SELECT DISTINCT
			Product_Category,
            SUM(Quantity_Sold)
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5.	Which store has the lowest revenue but highest number of sales?

SELECT 
		DISTINCT Store_ID,
        COUNT(*) AS sales,
        ROUND(SUM(Total_Sale_Amount),2) AS total_revenue
FROM sales_data
GROUP BY 1
ORDER BY 3 ASC, 2 DESC
LIMIT 1;

-- 6.	How do different payment methods impact total revenue?

SELECT 
	Payment_Method,
    ROUND(SUM(Total_Sale_Amount),2) AS total_revenue,
    COUNT(*) total_sales,
    SUM(Quantity_Sold) AS units_sold,
    COUNT(CASE WHEN Returned = 'Yes' THEN 1 END) AS total_returns
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;


-- 7.	Which customers have made the most purchases in terms of total amount spent?

SELECT 
	DISTINCT Customer_ID ,
    ROUND(SUM(Total_Sale_Amount),2)
    AS total_spend
FROM sales_data
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

-- 8.	Which quarter sees the highest sales?

SELECT 
	CONCAT('Q', QUARTER(sale_date)) AS QUARTER,
    COUNT(*) AS total_sale,
    ROUND(SUM(Total_Sale_Amount),2) AS total_revenue
FROM sales_data
GROUP BY 1
ORDER BY 3 DESC;

-- 9.	What is the average unit price per product category?

SELECT 
    Product_Category,
    ROUND(AVG(Unit_Price), 2) AS Avg_Unit_Price
FROM 
    sales_data
GROUP BY 
    Product_Category
ORDER BY 
    Avg_Unit_Price DESC;


-- 10.	Which product categories have the highest return percentage?
SELECT * FROM sales_data;

SELECT 
    Product_Category,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sales_data 
    WHERE Returned = 'Yes'), 2),'%') 
    AS Return_Rate
FROM 
    sales_data
WHERE 
    Returned = 'Yes'
GROUP BY 
    Product_Category
ORDER BY 
   2 DESC;

-- 11.	Total Revenue by Region

SELECT 
		DISTINCT Region,
        ROUND(SUM(Total_Sale_Amount),2)
        AS Revenue
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;


-- 12.	How did sales perform over each month?

SELECT 
    DATE_FORMAT(sale_Date, '%Y-%m') AS sale_month, -- I just accidentally learned something: using a capital 'M' in %m will display the month name. 😄' 
    COUNT(*) AS Total_Sales
FROM sales_data
GROUP BY Sale_Month
ORDER BY Sale_Month;

-- 13.	What is the average revenue per sale?

SELECT 
    ROUND(SUM(Total_Sale_Amount) / COUNT(*), 2) 
    AS Average_Order_Value
FROM sales_data;

-- 14.	How is the sales growth trending month by month?

WITH monthly_sales AS (
  SELECT 
    DATE_FORMAT(Sale_Date, '%Y-%m') AS Sale_Month,
    SUM(Total_Sale_Amount) AS Total_Revenue
  FROM sales_data
  GROUP BY 1
)
SELECT 
  Sale_Month,
  Total_Revenue,
  LAG(Total_Revenue) OVER (ORDER BY Sale_Month) AS Previous_Month_Revenue,
  ROUND(((Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY Sale_Month)) 
  / LAG(Total_Revenue) OVER (ORDER BY Sale_Month)) * 100, 2) 
  AS Growth_Percent
FROM monthly_sales;

-- 15.	How much revenue was lost due to returned items?

SELECT 
    Product_Category,
    ROUND(SUM(CASE WHEN Returned = 'yes' THEN Total_Sale_Amount ELSE 0 END),2) 
    AS Lost_Revenue
FROM sales_data
GROUP BY Product_Category
ORDER BY Lost_Revenue DESC; 

