-- ============================================================================= --
-- Intializing the tables --
-- ============================================================================= --
drop table if exists silver_crm_cust_info;
CREATE TABLE silver_crm_cust_info AS 
SELECT * FROM bronze_crm_cust_info;
-- adding the new column to the silver_crm_cust_info --
alter table silver_crm_cust_info 
add column dwh_create_date date default (current_date()) ;

drop table if exists silver_crm_prd_info;
create table silver_crm_prd_info as
select * from bronze_crm_prd_info ;
-- adding the new column to the silver_crm_prd_info --
alter table silver_crm_prd_info 
add column dwh_create_date date default (current_date()), 
add column cat_id varchar(50) ;

DROP TABLE IF EXISTS silver_crm_sales_info;
CREATE TABLE silver_crm_sales_info (
    sls_ord_num   VARCHAR(50),
    sls_prd_key   VARCHAR(50),
    sls_cust_id   INT,
    sls_order_dt  DATE,
    sls_due_dt    DATE,
    sls_ship_dt   DATE,
    sls_sales     INT,
    sls_quantity  INT,
    sls_price     INT,
    dwh_create_date DATE DEFAULT (CURRENT_DATE())
);


-- Executing the table -- 
select * from silver_crm_cust_info;
select * from silver_crm_prd_info ;
select * from silver_crm_sales_info ;