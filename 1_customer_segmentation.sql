-- Customer Segmentation --


WITH customer_LTV AS(
	SELECT 
		customerkey,
		corrected_name,
		sum(total_net_revenue)AS total_LTV
	FROM
		cohort_analysis
	GROUP BY 
		customerkey,
		corrected_name),
	
segment_values AS(
	
	SELECT
		PERCENTILE_CONT(0.25)WITHIN GROUP(ORDER BY total_LTV) AS ltv_25th_percentile,
		PERCENTILE_CONT(0.75)WITHIN GROUP(ORDER BY total_LTV) AS ltv_75th_percentile	
	FROM
		customer_LTV
	),
	
customer_segment AS(		
	SELECT
		c.customerkey,
		c.corrected_name,
		c.total_ltv,
		CASE 
			WHEN c.total_ltv <= sv.ltv_25th_percentile THEN '1-LOW'
			WHEN c.total_ltv >= sv.ltv_75th_percentile THEN '3-HIGH'
			ELSE '2-MEDIUM'
		END	AS Customer_segment
	FROM customer_LTV c,
		 segment_values sv)

SELECT 
	customer_segment,
	sum(total_ltv) AS Total_ltv,
	count(customerkey)AS customer_count,
	sum(total_ltv)/count(customerkey) AS Avg_customer_LTV
FROM 
	customer_segment 
GROUP BY 
	customer_segment
ORDER BY 
	customer_segment;
		 
