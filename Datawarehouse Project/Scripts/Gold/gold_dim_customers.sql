-- JOINING THE TABLES --
DROP VIEW IF EXISTS gold_dim_customers ;
CREATE VIEW gold_dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id)  as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number, 
	ci.cst_firstname as first_name, 
	ci.cst_lastname as last_name, 
    la.cntry as country,
	ci.cst_material_status as martial_status, 
	CASE WHEN ci.cst_gender != 'n/a' then ci.cst_gender -- CRM is the master of the table --
	     ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,  
	ca.bdate as birthdate,
    ci.cst_create_date as create_date
FROM silver_crm_cust_info ci   
LEFT JOIN silver_erp_cust_info ca
ON  ci.cst_key = ca.cid
LEFT JOIN silver_erp_custloc_info la
ON ci.cst_key = la.cid ;