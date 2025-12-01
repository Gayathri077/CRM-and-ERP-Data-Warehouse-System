-- JOINING THE TABLES --
DROP VIEW IF EXISTS gold_dim_products ;
CREATE VIEW gold_dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id as product_id,
    pn.prd_key as product_number, 
    pn.prd_nm as product_name, 
	pn.cat_id as category_id,
    pc.cat as category,
    pc.subcat as sub_category,
    pc.maintenance,
    pn.prd_cost as cost, 
    pn.prd_line as product_line, 
    pn.prd_start_dt as start_date
FROM silver_crm_prd_info pn
LEFT JOIN silver_erp_prdcat_info pc
ON pn.cat_id = pc.id 
WHERE pn.prd_end_dt is null; -- filter out all historical data --

SELECT * FROM gold_dim_products ;
