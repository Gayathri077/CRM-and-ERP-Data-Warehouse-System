-- ============================================================ --
                  -- CRM_CUSTOMER INFO --
-- ============================================================ --
DELIMITER $$
CREATE PROCEDURE sp_load_silver_crm_cust_info()
BEGIN
    -- Remove duplicates and clean data
    TRUNCATE TABLE silver_crm_cust_info;

    INSERT INTO silver_crm_cust_info (
        cst_id, 
        cst_key,
        cst_firstname, 
        cst_lastname, 
        cst_material_status, 
        cst_gender, 
        cst_create_date
    )
    SELECT 
        cst_id,
        cst_key, 
        TRIM(cst_firstname) AS cst_firstname, 
        TRIM(cst_lastname) AS cst_lastname, 
        CASE 
            WHEN TRIM(cst_material_status) = 'M' THEN 'Married'
            WHEN TRIM(cst_material_status) = 'S' THEN 'Single'
            ELSE 'N/A'
        END AS cst_material_status,      
        CASE 
            WHEN TRIM(cst_gender) = 'F' THEN 'Female'
            WHEN TRIM(cst_gender) = 'M' THEN 'Male'
            ELSE 'N/A'
        END AS cst_gender,   
        cst_create_date
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze_crm_cust_info
    ) AS t 
    WHERE flag_last = 1;
END $$

DELIMITER ;

select * from silver_crm_cust_info;

-- ============================================================ --
                    -- CRM_PRODUCT INFO --
-- ============================================================ --
DROP PROCEDURE IF EXISTS sp_load_silver_crm_prd_info;
DELIMITER $$
CREATE PROCEDURE sp_load_silver_crm_prd_info()
BEGIN 
	TRUNCATE TABLE SILVER_CRM_PRD_INFO;
	INSERT INTO SILVER_CRM_PRD_INFO (
		PRD_ID, 
		CAT_ID, 
		PRD_KEY,
		PRD_NM, 
		PRD_COST, 
		PRD_LINE, 
		PRD_START_DT, 
		PRD_END_DT )
	SELECT 
		PRD_ID, 
		REPLACE(SUBSTRING(PRD_KEY, 1, 5), '-', '_') AS CAT_ID,
		SUBSTRING(PRD_KEY, 7, LENGTH(PRD_KEY)) AS PRD_KEY,
		PRD_NM, 
		COALESCE(PRD_COST, 0) AS PRD_COST,
		CASE UPPER(TRIM(PRD_LINE))
			 WHEN 'S' THEN 'OTHER SALES'
			 WHEN 'R' THEN 'ROAD'
			 WHEN 'M' THEN 'MOUNTAIN'
			 WHEN 'T' THEN 'TOURING'
			 ELSE 'N/A'
		END AS PRD_LINE, 
		PRD_START_DT,
		DATE_SUB(
				LEAD(PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY PRD_START_DT),
				INTERVAL 1 DAY) AS PRD_END_DT
	FROM BRONZE_CRM_PRD_INFO ;
END $$
DELIMITER ;
-- CHECKING THE LOAD --
CALL sp_load_silver_crm_prd_info() ;
SELECT * FROM silver_crm_prd_info;

-- ============================================================ --
                  -- CRM_SALES INFO --
-- ============================================================ --
DROP PROCEDURE IF EXISTS sp_load_silver_crm_sales_info;
DELIMITER $$

CREATE PROCEDURE sp_load_silver_crm_sales_info()
BEGIN
    -- Optional: clear silver data before load
    TRUNCATE TABLE silver_crm_sales_info;

    INSERT INTO silver_crm_sales_info (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales, 
        sls_price,
        sls_quantity
    )
    SELECT  
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE 
            WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d') 
        END AS sls_order_dt,

        CASE 
            WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d') 
        END AS sls_ship_dt,

        CASE 
            WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d') 
        END AS sls_due_dt,

        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 
                 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN CEILING(sls_quantity * ABS(sls_price))
            ELSE CEILING(sls_sales)
        END AS sls_sales, 

        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 
            THEN ROUND(sls_sales / NULLIF(sls_quantity, 0), 2)
            ELSE sls_price
        END AS sls_price,

        sls_quantity
    FROM bronze_crm_sales_info;
END $$
DELIMITER ;

CALL sp_load_silver_crm_sales_info();
select * from silver_crm_sales_info;
-- ============================================================ --
                  -- ERP_CUSTOMER INFO --
-- ============================================================ --
DROP PROCEDURE IF EXISTS sp_load_erp_cust_info;
DELIMITER $$ 
CREATE PROCEDURE sp_load_erp_cust_info()
BEGIN 
TRUNCATE TABLE silver_erp_cust_info;
INSERT INTO silver_erp_cust_info(
	cid, 
    bdate, 
    gen
)
SELECT 
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
         ELSE cid
    END cid,     
    CASE WHEN bdate > NOW() THEN NULL
		 ELSE bdate
    END AS bdate,      
    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE'  ) THEN 'Male'
         ELSE 'N/A'
    END AS gen     
FROM bronze_erp_cust_info;
END $$
DELIMITER ;

CALL sp_load_erp_cust_info ;
select * from silver_erp_cust_info;

-- ============================================================ --
                  -- ERP_CUSTOMERLOC INFO --
-- ============================================================ --
DROP PROCEDURE IF EXISTS sp_load_erp_custloc_info;
DELIMITER $$
CREATE PROCEDURE sp_load_erp_custloc_info()
BEGIN 
	TRUNCATE TABLE silver_erp_custloc_info;
	INSERT INTO silver_erp_custloc_info(
		cid, 
		cntry
	)
	SELECT 
		REPLACE(cid, '-', '') AS cid, 
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
			 ELSE TRIM(cntry)
	   END AS cntry  
	FROM bronze_erp_custloc_info;  
END $$
DELIMITER ;  

CALL sp_load_erp_custloc_info ;
SELECT * FROM silver_erp_custloc_info;

-- ============================================================ --
                  -- ERP_PRDCAT INFO --
-- ============================================================ --
DROP PROCEDURE IF EXISTS sp_load_erp_prdcat_info;
DELIMITER $$
CREATE PROCEDURE sp_load_erp_prdcat_info()
BEGIN 
	TRUNCATE TABLE silver_erp_prdcat_info;
	INSERT INTO silver_erp_prdcat_info (
		id, 
		cat, 
		subcat, 
		maintenance
	)
	SELECT 
		id, 
		cat, 
		subcat, 
		maintenance
	FROM bronze_erp_prdcat_info;
END $$
DELIMITER ;

CALL sp_load_erp_prdcat_info() ;
SELECT * FROM silver_erp_prdcat_info ;