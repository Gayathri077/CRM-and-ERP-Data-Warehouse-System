-- ============================================================ --
                  -- CRM_CUSTOMER INFO --
-- ============================================================ --
-- Check for nulls or duplicates in primary key 
-- Expectation: No result 
select 
cst_id, 
count(*)
from bronze_crm_cust_info
group by cst_id
having count(*)>1 or cst_id is null
; 

-- check for unwanted spaces in string values --
-- Expectation : No results -- 
select cst_firstname 
from bronze_crm_cust_info 
where cst_firstname != trim(cst_firstname);

select cst_lastname 
from bronze_crm_cust_info 
where cst_lastname != trim(cst_lastname);

select cst_gender 
from bronze_crm_cust_info
where cst_gender != trim(cst_gender);

-- Data standardization and consistency --
select distinct cst_gender 
from bronze_crm_cust_info
where cst_gender is not null ;

select distinct cst_material_status 
from bronze_crm_cust_info
where cst_gender is not null ;

-- ============================================================ --
                    -- CRM_PRODUCT INFO --
-- ============================================================ --
select 
	prd_id,
	count(*)
from bronze_crm_prd_info
group by prd_id
having count(*)>1 or prd_id is null;

-- check for unwanted spaces in string values --
-- Expectation : No results -- 
select 
	prd_nm
from bronze_crm_prd_info
where prd_nm != trim(prd_nm);

-- Check for nulls or duplicates in primary key 
-- Expectation: No result 

select prd_cost
from bronze_crm_prd_info
where prd_cost <0 or prd_cost is null ;

-- Data standardization and consistency --
select distinct prd_line 
from bronze_crm_prd_info;

-- Check for invalid date orders 
select * 
from bronze_crm_prd_info
where prd_end_dt < prd_start_dt ;

-- checking the negative number in date column --
SELECT 
	nullif(sls_order_dt, 0) as sls_order_dt
FROM bronze_crm_sales_info
where sls_order_dt <= 0 
or length(sls_order_dt) != 8 
or sls_order_dt > 20500101 
or sls_order_dt > 19000101 ;

-- checking the order date < shiping date -- 
select *
from bronze_crm_sales_info
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

-- check data consistency : Between sales, quantity, and price
-- >> Sales = Quantity * Price
-- >> Values must be postive and not null.

select distinct 
    sls_sales as old_sales,
    sls_quantity, 
    sls_price as old_price, 
    case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) 
         then CEILING(sls_quantity * abs(sls_price))  -- Sales rounded UP
         else CEILING(sls_sales)                      -- Sales rounded UP
    end as sls_sales, 
    case when sls_price is null or sls_price <= 0 
         then ROUND(sls_sales / nullif(sls_quantity, 0))  -- Price with 2 decimals
         else sls_price
    end as sls_price
from bronze_crm_sales_info
where sls_sales != sls_quantity * sls_price 
   or sls_sales is null or sls_quantity is null or sls_price is null
   or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0 
order by 1, 2;

-- ******************************************************************** --
                         -- ERP CHECKING --
-- ******************************************************************** --

SELECT 
    bdate
FROM silver_erp_cust_info
WHERE bdate < '1924-01-01' OR  bdate > NOW();

SELECT DISTINCT
    gen
FROM silver_erp_cust_info;

SELECT 
	replace(cid, '-', '')as cid, 
    cntry
FROM bronze_erp_custloc_info
where replace(cid, '-', '') not in 
(select cst_key from bronze_crm_cust_info);

-- CHECKING DATA CONSISTENCY AND STANDARDIZATION --
SELECT DISTINCT 
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
         ELSE TRIM(cntry)
   END AS cntry    
FROM bronze_erp_custloc_info 
ORDER BY cntry;

SELECT 
	id, 
    cat, 
    subcat, 
    maintenance
FROM bronze_erp_prdcat_info;
-- check unwanted spaces --
select * from bronze_erp_prdcat_info
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance);

-- CHECKING DATA CONSISTENCY AND STANDARDIZATION --
select 
	distinct cat 
from bronze_erp_prdcat_info;
select 
	distinct subcat 
from bronze_erp_prdcat_info;
select 
	distinct maintenance
from bronze_erp_prdcat_info;