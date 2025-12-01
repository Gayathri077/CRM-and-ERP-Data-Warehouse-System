-- creating a customer info table --  
drop table if exists bronze_crm_cust_info ;
create table bronze_crm_cust_info (
	cst_id int, 
	cst_key varchar (50), 
	cst_firstname varchar(50), 
	cst_lastname varchar(50), 
	cst_material_status varchar(50), 
	cst_gender varchar(50), 
	cst_create_date date
) ;

-- creating a product info table --
drop table if exists bronze_crm_prd_info ;
create table bronze_crm_prd_info (
	prd_id int, 
	prd_key	varchar(50), 
	prd_nm varchar(50), 
	prd_cost int, 	
	prd_line varchar(50), 
	prd_start_dt date, 
	prd_end_dt date
) ;

-- creating a sales info table --
drop table if exists bronze_crm_sales_info ;
create table bronze_crm_sales_info (
	sls_ord_num	varchar(50),
	sls_prd_key	varchar(50),
	sls_cust_id	int,
	sls_order_dt int,
	sls_due_dt int,
    sls_ship_dt int,
	sls_sales int,
	sls_quantity int,	
	sls_price int
);
select * from bronze_crm_cust_info;
select * from bronze_crm_prd_info ;
select * from bronze_crm_sales_info;







