-- ============================================================================= --
-- Intializing the tables --
-- ============================================================================= --
drop table if exists silver_erp_cust_info ;
create table silver_erp_cust_info as 
select * from bronze_erp_cust_info ;
-- adding a new column to the existing table -- 
alter table silver_erp_cust_info
add column dwh_create_date date default (current_date()) ;

drop table if exists silver_erp_custloc_info ;
create table silver_erp_custloc_info as
select * from bronze_erp_custloc_info;
-- adding a new column to the existing table -- 
alter table silver_erp_custloc_info
add column dwh_create_date date default (current_date()) ;

drop table if exists silver_erp_prdcat_info;
create table silver_erp_prdcat_info as
select * from bronze_erp_prdcat_info ;
-- adding a new column to the existing table -- 
alter table silver_erp_prdcat_info
add column dwh_create_date date default (current_date()) ;

-- Executing the table -- 
select * from silver_erp_cust_info;
select * from silver_erp_custloc_info ;
select * from silver_erp_prdcat_info ;