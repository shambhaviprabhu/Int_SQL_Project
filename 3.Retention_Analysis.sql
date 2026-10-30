-- Retention Analysi--

WITH last_Purchase_date AS(
SELECT 
		customerkey,
		corrected_name,
		orderdate,
		cohort_year,
		ROW_NUMBER() OVER (PARTITION BY customerkey ORDER BY orderdate DESC)AS rn,
		first_purchase_date 	
	FROM 
		cohort_analysis		
	ORDER BY Customerkey),

Customers_churn AS(	
	SELECT 
		customerkey,
		corrected_name,
		first_purchase_date,
		orderdate AS last_Purchase_date,
		cohort_year
	FROM last_Purchase_date
	WHERE rn = 1),	
	
Customer_Status AS(	
	SELECT 
		customerkey,
		corrected_name,
		last_purchase_date,
		CASE WHEN last_purchase_date < (SELECT Max(orderdate) FROM SALES)::date - INTERVAL'6 months' THEN 'Churned'
		ELSE 'Active'
		END AS Customer_status,
		cohort_year 
	FROM  	Customers_churn
	WHERE first_purchase_date <(SELECT Max(orderdate) FROM SALES)::date - INTERVAL'6 months')
	
SELECT
	cohort_year, 
	customer_status,
	Count(customerkey)AS Customer_count,
	Sum(Count(customerkey)) OVER(PARTITION BY cohort_year) AS Total_Customers,
	round(Count(customerkey)*100/Sum(Count(customerkey))OVER(PARTITION BY cohort_year),2) AS status_percentage
FROM Customer_Status 
GROUP BY 
	Cohort_year,
	customer_status
ORDER BY Cohort_year;
			
	