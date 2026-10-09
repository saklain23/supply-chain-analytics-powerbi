-- drop table
DROP TABLE IF EXISTS customers;

-- ==========================================
-- 1. CUSTOMERS TABLE
-- ==========================================
-- Create table
CREATE TABLE customers(
Customer_Id	INT PRIMARY KEY,
Customer_Fname	VARCHAR(50),
Customer_Lname	VARCHAR(50),
Customer_Email	VARCHAR(50),
Customer_Password	VARCHAR(50),
Customer_Segment	VARCHAR(50),
Customer_City	VARCHAR(50),
Customer_State	VARCHAR(50),
Customer_Country	VARCHAR(50),
Customer_Street	VARCHAR(100),
Customer_Zipcode	INT,
Latitude	NUMERIC(12,3),
Longitude	NUMERIC(12,3)

);

COPY customers (customer_id, customer_fname, customer_lname, customer_email, customer_password, customer_segment, customer_city, customer_state, customer_country, customer_street, customer_zipcode, latitude, longitude)
FROM 'Supply_Chain_Analysis\customers.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM customers;




-- drop table 
DROP TABLE IF EXISTS products;

-- ==========================================
-- 2. PRODUCTS TABLE
-- ==========================================
CREATE TABLE products (
    product_card_id    INTEGER PRIMARY KEY,
    product_name       VARCHAR(255),
    product_price      NUMERIC(10, 2),
    product_description TEXT,
    product_image      TEXT,
    product_status     SMALLINT,
    product_category_id INTEGER,
    category_id        INTEGER,
    category_name      VARCHAR(100),
    department_id      INTEGER,
    department_name    VARCHAR(100)
);

COPY products (product_card_id, product_name, product_price, product_description, product_image, product_status, product_category_id, category_id, category_name, department_id, department_name)
FROM 'C:\Supply_Chain_Analysis\products.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM products;

-- drop table
DROP TABLE IF EXISTS orders;
-- ==========================================
-- 3. ORDERS TABLE
-- ==========================================
CREATE TABLE orders (
    order_id              INTEGER,
    customer_id           INTEGER REFERENCES customers(customer_id),
    product_card_id       INTEGER REFERENCES products(product_card_id),
    type                  VARCHAR(50),
    days_shipping_real    INTEGER,
    days_shipping_sched   INTEGER,
    benefit_per_order     NUMERIC(10, 2),
    sales_per_customer    NUMERIC(10, 2),
    delivery_status       VARCHAR(50),
    late_delivery_risk    SMALLINT,
    market                VARCHAR(50),
    order_city            VARCHAR(100),
    order_country         VARCHAR(100),
    order_region          VARCHAR(100),
    order_state           VARCHAR(100),
    order_status          VARCHAR(50),
    order_zipcode         VARCHAR(20),
    order_date            TIMESTAMP,
    shipping_date         TIMESTAMP,
    shipping_mode         VARCHAR(50),
    order_item_id         INTEGER,
    order_item_discount   NUMERIC(10, 2),
    order_item_discount_rate NUMERIC(5, 4),
    order_item_product_price NUMERIC(10, 2),
    order_item_profit_ratio  NUMERIC(5, 4),
    order_item_quantity   INTEGER,
    sales                 NUMERIC(10, 2),
    order_item_total      NUMERIC(10, 2),
    order_profit_per_order NUMERIC(10, 2)
);

COPY orders (order_id, customer_id, product_card_id, type, days_shipping_real, days_shipping_sched, benefit_per_order, sales_per_customer, delivery_status, late_delivery_risk, market, order_city, order_country, order_region, order_state, order_status, order_zipcode, order_date, shipping_date, shipping_mode, order_item_id, order_item_discount, order_item_discount_rate, order_item_product_price, order_item_profit_ratio, order_item_quantity, sales, order_item_total, order_profit_per_order)
FROM 'C:\Supply_Chain_Analysis\orders.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS web_logs;
-- ==========================================
-- 4. WEB LOGS TABLE
-- ==========================================
CREATE TABLE web_logs (
    product_name  VARCHAR(255),
    category      VARCHAR(100),
    log_date      DATE,
    month         VARCHAR(20),
    hour          INTEGER,
    department    VARCHAR(100),
    ip            VARCHAR(50),
    url           TEXT
);



COPY web_logs (product_name, category, log_date, month, hour, department, ip, url)
FROM 'C:\Supply_Chain_Analysis\web_logs.csv'
DELIMITER ','
CSV HEADER;

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_product ON orders(product_card_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_web_logs_product ON web_logs(product_name);
CREATE INDEX idx_web_logs_date ON web_logs(log_date);





SELECT COUNT(*) AS count_customer
FROM customers;

SELECT COUNT(*) AS count_product
FROM products;

SELECT COUNT(*) AS count_order
FROM orders;

SELECT COUNT(*) AS count_web_Logs
FROM web_logs;

-- Customers table
SELECT 'customers' AS table_name, 'customer_id' AS column_name,
       COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_count
FROM customers

UNION ALL

-- Products table
SELECT 'products', 'product_card_id',
       COUNT(*) FILTER (WHERE product_card_id IS NULL)
FROM products

UNION ALL

-- Orders table
SELECT 'orders', 'customer_id',
       COUNT(*) FILTER (WHERE order_id IS NULL)
FROM orders

UNION ALL

-- Orders table - product
SELECT 'orders', 'product_card_id',
       COUNT(*) FILTER (WHERE product_card_id IS NULL)
FROM orders

UNION ALL

-- Orders table - order
SELECT 'orders', 'order_id',
       COUNT(*) FILTER (WHERE order_id IS NULL)
FROM orders

UNION ALL

-- Web logs table
SELECT 'web_logs', 'product_name',
       COUNT(*) FILTER (WHERE product_name IS NULL)
FROM web_logs;



-- Q1. How many total customers are there?
SELECT COUNT(*) AS tatal_customer
FROM customers;

-- Q2. How many total orders are there?
SELECT COUNT(*) AS total_order
FROM orders;

-- Q3. List all unique product categories.
SELECT DISTINCT category_name
FROM products;

-- Q4. Show top 10 customers by total sales.
SELECT c.customer_id, 
       c.customer_fname,
	   c.customer_lname,
      SUM(o.sales) AS total_sales
	  FROM orders o
	  JOIN customers c ON o.customer_id = c.customer_id
	  GROUP BY c.customer_id, c.customer_fname, c.customer_lname
	  ORDER BY total_sales DESC
	  LIMIT 10;
	  
-- Q5. How many orders were delivered late?
    SELECT delivery_status,
	       late_delivery_risk,
		   COUNT(*) AS total
		   FROM orders
		   GROUP BY delivery_status, late_delivery_risk
		   ORDER BY delivery_status, late_delivery_risk;

-- Q6. How many orders per shipping mode?	   
     WITH shipping AS (
           SELECT
		   shipping_mode,
		   COUNT(*) AS total_order
		   FROM orders
		   GROUP BY shipping_mode
	 )
    SELECT*
    FROM shipping
    ORDER BY total_order;
	
-- Q7. Category-wise total revenue (top 10).
	  WITH c AS (
           SELECT p.category_name,
		   SUM(o.sales) AS total_revenue
		   FROM orders o
		   JOIN products p ON o.product_card_id = p.product_card_id
		   GROUP BY p.category_name
	  )
	  SELECT*
	  FROM c
	  ORDER BY total_revenue DESC
	  LIMIT 10;


-- Q8. What is the average shipping delay (real vs scheduled)?
      SELECT 
	        COUNT(*) total_order,
			COUNT(*) FILTER (WHERE days_shipping_real > days_shipping_sched) AS late_orders,
			COUNT(*) FILTER (WHERE days_shipping_real = days_shipping_sched) AS one_time_orders,
			COUNT(*) FILTER (WHERE days_shipping_real < days_shipping_sched) AS early_orders,
			ROUND(AVG(days_shipping_real),2) AS avg_real,
			ROUND(AVG(days_shipping_sched),2) AS avg_sched,
			ROUND(AVG(days_shipping_real  - days_shipping_sched),2) AS avg_delay_order,
			ROUND(AVG(days_shipping_real - days_shipping_sched) 
			FILTER ( WHERE days_shipping_real > days_shipping_sched),2)
			AS avg_delay_when_late
			FROM orders;
			
-- Q9. Top 5 states by number of orders.
   WITH S AS(
        SELECT
         order_state,
		 COUNT(*) AS order_count
		 FROM orders
    	 GROUP BY order_state	 
   )
   SELECT*
   FROM S
   ORDER BY order_count DESC
   LIMIT 5;
   
-- Q10. Show top 10 orders with highest profit.
    WITH op AS(
         SELECT order_id,
		        customer_id,
				product_card_id,
		        order_profit_per_order
				FROM orders		   	
	     )
      SELECT*
	  FROM op
	  ORDER BY order_profit_per_order DESC
	  LIMIT 10	
	  
 -- Q11. How many unique markets are there? 
        SELECT DISTINCT market
		FROM orders;
		
-- 12. Month-wise total sales (2018).
        WITH  monthly AS (
		     SELECT
                  EXTRACT(MONTH FROM order_date) AS month,
			      SUM(sales) AS monthly_sales
			FROM orders
			WHERE EXTRACT(YEAR FROM order_date) = 2018
			GROUP BY month	
		)
		SELECT*
		FROM monthly
		ORDER BY month;
       
   
-- Q13. Department-wise product count.
       WITH D AS(
            SELECT department_name,
			       COUNT(*) AS product_count
				   FROM products
				   GROUP BY department_name
				   
	      )
          SELECT*
	      FROM D
	      ORDER BY product_count DESC;

-- Q14. Late Delivery Analysis
-- You need to find out how many orders were late (real days > scheduled days) 
-- in each shipping mode. Show only those shipping modes where there are more than 1000 late orders.
      WITH T AS (
            SELECT 
			      shipping_mode,
				  COUNT(*) AS late_order
				  FROM orders
				  WHERE days_shipping_real > days_shipping_sched
				  GROUP BY shipping_mode
				  HAVING COUNT(*)>1000
		)  
		SELECT *
		FROM T
		ORDER BY late_order DESC;
	
-- Q15. Top Customers
-- The company needs the top 10 customers who generated the highest revenue. Also show 
-- their total orders and average order value. Include only those customers who placed more than 5 orders.
     WITH top_customers AS(
          SELECT
		        c.customer_id,
				c.customer_fname,
				c.customer_lname,
				COUNT(DISTINCT o.order_id) AS total_order,
				SUM(o.sales_per_customer) AS revenue,
		  ROUND(SUM(o.sales_per_customer)/ COUNT(DISTINCT o.order_id),2) AS avg_order_value
		  FROM orders o
		  JOIN customers c ON o.customer_id = c.customer_id
		  GROUP BY c.customer_id, customer_fname, customer_lname
		  HAVING COUNT(DISTINCT o.order_id)>5	        
	 )
	 SELECT
	       customer_id,
		   customer_fname,
		   customer_lname,
		   total_order,
		   revenue,
		   avg_order_value   
	 FROM top_customers
	 ORDER BY revenue DESC
	 LIMIT 10;
		      
				  
-- Q16. Category Performance
-- Show the performance of each product category — total sales, total profit, and average discount.
-- Show only those categories where total profit is positive.			   
          WITH category_performance AS (
              SELECT p.product_category_id,
			         p.category_name,
			         SUM(o.sales) AS total_sales,
					 SUM(o.order_profit_per_order) AS total_profit,
					 ROUND(AVG(o.order_item_discount),2) AS avg_discount
					 FROM orders o
					 JOIN products p ON o.product_card_id = p.product_card_id
					 GROUP BY p.product_category_id, p.category_name
					 HAVING SUM(o.order_profit_per_order)>0
		  )
          SELECT 
		        product_category_id,
				category_name,
				total_sales,
				total_profit,
				avg_discount
				FROM category_performance
				ORDER BY total_sales DESC;
				
-- Q17. Customer Segmentation
-- Divide customers into 3 groups based on total sales:	
        WITH segmentation AS(
                  SELECT
				  c.customer_id,
				  SUM(o.sales) AS total_sales
				  FROM orders o
				  JOIN customers c ON o.customer_id = c.customer_id
				  GROUP BY c.customer_id
				  
		)
		SELECT 
		      customer_id,
			  total_sales,
			  CASE 
			       WHEN total_sales > 7000 THEN 'High Value'
				   WHEN total_sales BETWEEN 4000 AND 7000 THEN 'Medium Value'
				   WHEN total_sales < 4000                  THEN 'Low Value'
				   ELSE 'Unknow'
				   END AS segment_status
				   FROM segmentation
				   ORDER BY total_sales DESC;

-- Q18. Monthly Trend
-- Show the month-wise sales trend for 2017. Also show the previous month's 
-- sales and the difference, so we can see which month had growth and which had decline.
     WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales) AS total_sales
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2017
    GROUP BY month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
    (total_sales - LAG(total_sales) OVER (ORDER BY month)) AS difference 
FROM monthly
ORDER BY month;
			
-- Q19 Month-wise sales, previous month sales, difference, growth %
     WITH monthly_sales AS(
           SELECT
	       DATE_TRUNC('MONTH', order_date)::DATE AS month,
		   SUM(sales) AS total_sales
		   FROM orders
		   GROUP BY month

		   ),	   
   sales_with_previous AS (
                SELECT month,
				total_sales,
				LAG(total_sales) OVER (ORDER BY month) AS prev_month,
				(total_sales - LAG(total_sales) OVER (ORDER BY month)) AS difference
				FROM monthly_sales
   )
	SELECT month,
	       total_sales,
		   prev_month,
		   difference,
	       ROUND(100.0 * (total_sales - prev_month) / NULLIF(prev_month, 0 ),2)
		   FROM sales_with_previous
		   ORDER BY month;
	
-- Q20. Delivery Performance
-- For each order region, show:

-- Total orders

-- Late orders

-- On-time orders

-- Early orders

-- Late delivery percentage

-- Show only those regions where late percentage is more than 50%.	

WITH delivery_performance AS (
    SELECT 
        order_region,
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (WHERE days_shipping_real > days_shipping_sched) AS late_orders,
        COUNT(*) FILTER (WHERE days_shipping_real = days_shipping_sched) AS on_time_orders,
        COUNT(*) FILTER (WHERE days_shipping_real < days_shipping_sched) AS early_orders
    FROM orders
    GROUP BY order_region
)
SELECT
    order_region,
    total_orders,
    late_orders,
    on_time_orders,
    early_orders,
    ROUND((100.0 * late_orders / total_orders), 2) AS late_pct
FROM delivery_performance
WHERE ROUND((100.0 * late_orders / total_orders), 2) > 50
ORDER BY late_pct DESC;

	
-- Q21. Product Ranking
-- Rank products by sales within each category. Show the top 3 products from each category.
WITH ranked AS (
    SELECT
        p.product_name,
        p.category_name,
        SUM(o.sales) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY p.category_name 
            ORDER BY SUM(o.sales) DESC
        ) AS rnk
    FROM orders o
    JOIN products p ON o.product_card_id = p.product_card_id
    GROUP BY p.category_name, p.product_name
)
SELECT 
    product_name,
    category_name,
    total_sales,
    rnk
FROM ranked
WHERE rnk <= 3
ORDER BY category_name, total_sales DESC;
		 
	
-- Q22. Customer Retention
-- Find customers whose first order and last order have a gap of more than 1 year.
-- These are loyal customers who have been buying for a long time.   
   WITH retention AS(
        SELECT customer_id,
		       MAX(order_date)::DATE AS last_date,
			   MIN(order_date)::DATE AS first_date,
			   EXTRACT (YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS years_gap
			   FROM orders
			   GROUP BY customer_id
			   HAVING AGE(MAX(order_date), MIN(order_date)) > INTERVAL '1 year'
   )
   SELECT*
   FROM retention;


-- Q23. Profit Margin Analysis
-- Show the profit margin for each department. Show only those departments
-- where the average profit ratio is more than 0.2. Also include total sales and total profit
WITH department_margin AS(
      SELECT 
	  p.department_name,
	  SUM(o.benefit_per_order) AS total_profit,
	  SUM(o.sales) AS total_sales,
	  ROUND(100.0 * SUM(o.benefit_per_order) / NULLIF (SUM(o.sales),0),2) AS profit_margin,
	  ROUND(AVG(o.order_item_profit_ratio),2) AS avg_profit_ratio
	  FROM orders o
	  JOIN products p ON o.product_card_id = p.product_card_id
	  GROUP BY p.department_name
	  HAVING AVG(o.order_item_profit_ratio)>0.1
	  
	  )
	  SELECT*
	  FROM department_margin
	  ORDER BY avg_profit_ratio;
	  
	  


-- Q24. Order Size Distribution
-- Categorize orders based on quantity: Small → 1-2 items, Medium → 3-5 items, Large → 6+ items
-- Show how many orders are in each category, the average sales, and the total revenue.
WITH order_distribution AS (
      SELECT 
	CASE
	WHEN order_item_quantity >= 5 THEN 'large(5+)'
	WHEN order_item_quantity BETWEEN 1 AND 2 THEN 'small (1-2)'
	WHEN order_item_quantity BETWEEN 3 AND 4 THEN 'medium (3-5)'
	ELSE 'unknow'
	END AS order_size,
			COUNT(*) AS total_order,
			ROUND(AVG(sales),2) AS avg_sales,
			SUM(sales) AS revenue
			FROM orders 
			GROUP BY order_size 	
		)
  SELECT*
 FROM order_distribution
 ORDER BY order_size DESC;


-- Q25. Running Total
-- Show the running total of orders for 2017 — meaning after each day, what is the cumulative sales.
 WITH daily_sales AS (
       SELECT 
	         order_date,
			 SUM(sales) AS daily_sales
			 FROM orders
			 WHERE EXTRACT(YEAR FROM order_date) = 2017
			 GROUP BY order_date

		)
		SELECT
		     order_date,
			 daily_sales,
			 SUM(daily_sales) OVER (ORDER BY order_date) AS running_total
			 FROM daily_sales
			 ORDER BY order_date;

-- Q26. Year-over-Year Comparison
-- Compare the total sales of 2016 vs 2017 vs 2018. Also show the growth percentage.
WITH yearly_sales AS (
        SELECT 
		DATE_TRUNC('year', order_date)::DATE AS sales_year,
		SUM(sales) AS total_sales
		FROM orders
		GROUP BY sales_year		
),
 yearly_growth AS(
         SELECT sales_year,
		        total_sales,
				LAG(total_sales) OVER (ORDER BY sales_year) AS prev_year_sales,
				ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY sales_year))
				/ NULLIF(LAG(total_sales) OVER(ORDER BY sales_year),0),2) AS growth_pct
				FROM yearly_sales		       
 )
 SELECT sales_year,
        total_sales,
		prev_year_sales,
		growth_pct
 FROM yearly_growth
 ORDER BY sales_year;

-- Q27. Market-wise Sales
-- Show total sales for each market.
 WITH market_wise AS(
      SELECT market,
	         SUM(sales) AS total_sales
			 FROM orders
			 GROUP BY market
 )
 SELECT*
 FROM market_wise
 ORDER BY total_sales DESC;

-- Q28. Shipping Mode Performance
-- Show late, on-time, and early orders for each shipping mode.	
WITH shipping_performance AS (
      SELECT shipping_mode,
	  COUNT(*) FILTER (WHERE delivery_status = 'Late delivery') AS late_order,
	  COUNT(*) FILTER (WHERE delivery_status = 'Shipping on time') AS on_time_order,
	  COUNT(*) FILTER (WHERE delivery_status = 'Advance shipping') AS early_order
	  FROM orders
	  GROUP BY shipping_mode
	  
)
SELECT *
FROM shipping_performance
ORDER BY late_order DESC;

-- Q29. Department-wise Revenue
-- Show total revenue and total profit for each department.
WITH department_performance AS(
      SELECT p.department_name,
	         SUM(o.sales) AS revenue,
			 SUM(o.benefit_per_order) AS total_profit
			 FROM orders o
			 JOIN products p ON o.product_card_id = p.product_card_id
			 GROUP BY p.department_name
	)
	SELECT*
	FROM department_performance
	ORDER BY total_profit DESC;

-- Q30. Customer Segment Analysis
-- Show the count of customers in each segment.	
WITH segment_counts AS (
    SELECT 
        customer_segment,
        COUNT(*) AS total_customers
    FROM customers
    GROUP BY customer_segment
)
SELECT *
FROM segment_counts
ORDER BY total_customers DESC;
  
-- Q31. Top 10 Products by Sales
-- Show the top 10 products by total sale
WITH top_products AS(
     SELECT
          p.product_name,
		  SUM(o.sales) AS total_sales
		  FROM orders o
		  JOIN products p ON o.product_card_id = p.product_card_id
		  GROUP BY p.product_name
)
SELECT *
FROM top_products
ORDER BY total_sales DESC
LIMIT 10;
			
-- Q32. Late Delivery Trend by Month
-- Show the month-wise late delivery count for 2017.
WITH monthly AS(
       SELECT 
	       DATE_TRUNC('month', order_date)::DATE AS month,
		   COUNT(*) FILTER (WHERE delivery_status = 'late delivery') AS late_delivery
	  FROM orders
	  WHERE EXTRACT(YEAR FROM order_date)=2017
	  GROUP BY month
		   
)
SELECT *
FROM monthly;

-- Q33. Order Status Distribution
-- Show the count of orders in each status.
WITH order_count AS(
      SELECT
             order_status,
	         COUNT(*) AS count_of_order
	  FROM orders
	  GROUP BY order_status
)
SELECT *
FROM order_count
ORDER BY count_of_order DESC;

-- Q34. Discount Impact on Profit
-- Show average profit for different discount ranges.
WITH discounted_ranges AS(
         SELECT 
		       order_item_discount_rate,
			   benefit_per_order,
			   sales,
			         CASE
					     WHEN order_item_discount_rate = 0 THEN 'no discount (0%)'
						 WHEN order_item_discount_rate BETWEEN 0.01 AND 0.10 THEN 'low (1-10%)'
						 WHEN order_item_discount_rate BETWEEN 0.11 AND 0.20 THEN 'medium (11-20%)'
						 WHEN order_item_discount_rate > 0.20 THEN 'high (21%+)'
						 ELSE 'other'
						 END discount_range
                         FROM orders
)
SELECT
     discount_range,
	 ROUND(AVG(benefit_per_order),2) AS avg_profit,
	 ROUND(AVG(sales),2) AS avg_sales,
	 SUM(benefit_per_order) AS total_profit
	 FROM discounted_ranges
	 GROUP BY discount_range
	 ORDER BY avg_profit DESC;
      


SELECT 
    SUM(benefit_per_order) AS total_profit,
    
    ROUND(
        100.0 * SUM(benefit_per_order) / NULLIF(SUM(order_item_total), 0), 
    2) AS profit_margin_pct,
    
    COUNT(DISTINCT order_id) AS total_orders,
    
    COUNT(DISTINCT order_id) FILTER (WHERE days_shipping_real = days_shipping_sched) AS on_time_orders,
    
    ROUND(
        100.0 * COUNT(DISTINCT order_id) FILTER (WHERE days_shipping_real = days_shipping_sched) 
        / COUNT(DISTINCT order_id), 
    2) AS on_time_pct,
    
    COUNT(DISTINCT order_id) FILTER (WHERE days_shipping_real > days_shipping_sched) AS late_orders,
    
    ROUND(
        100.0 * COUNT(DISTINCT order_id) FILTER (WHERE days_shipping_real > days_shipping_sched) 
        / COUNT(DISTINCT order_id), 
    2) AS late_delivery_pct,
    
    ROUND(AVG(days_shipping_real) - AVG(days_shipping_sched), 2) AS avg_delay_days

FROM orders;

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM web_logs;

	