-- JOIN TABLES --
DROP VIEW IF EXISTS gold_fact_sales ;
CREATE VIEW gold_fact_sales AS
SELECT 
	sd.sls_ord_num as order_number, 
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt as order_date, 
    sd.sls_due_dt as due_date, 
    sd.sls_ship_dt as ship_date, 
    sd.sls_sales as sales_amount, 
    sd.sls_quantity as quantity, 
    sd.sls_price as price
FROM silver_crm_sales_info sd
LEFT JOIN gold_dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN  gold_dim_customers cu 
ON sd.sls_cust_id = cu.customer_id;
