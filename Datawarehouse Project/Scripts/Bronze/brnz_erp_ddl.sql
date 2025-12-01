-- creating a customer info table -- 
drop table if exists bronze_erp_cust_info ;
create table bronze_erp_cust_info (
cid	varchar(50),
bdate date,
gen varchar(50)
) ;

-- creating a product info table --
drop table if exists bronze_erp_custloc_info;
create table bronze_erp_custloc_info (
cid	varchar(50),
cntry varchar(50)
) ;

-- creating a sales info table --
drop table if exists bronze_erp_prdcat_info ;
create table bronze_erp_prdcat_info (
id varchar(50), 
cat varchar(50),
subcat varchar(50),
maintenance varchar(50)
);

select * from bronze_erp_cust_info ;
select * from bronze_erp_custloc_info ;
select * from bronze_erp_prdcat_info ;