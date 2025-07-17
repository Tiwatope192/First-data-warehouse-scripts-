---create a database, Warehouse,set admin role,set schema as public

-----precise database
USE DATABASE peju_database_workplace;
     
-----create new schema, name, and precise
        USE SCHEMA peju_bronze_schema;

1   ---CREATE TABLE 1.... CUSTOMER INFO
    
create or replace table customer_info (
    cst_id integer primary key,
    cst_key varchar (100),
    cst_firstname varchar(100),
    cst_lastname varchar(100),	
    cst_marital_status varchar(20),
    cst_gndr varchar(10),
    cst_create_date date );

    ----load data manually (no code)
    
    ----View table
    select*
    from peju_bronze_schema.customer_info;


   ----check for duplicates
    select cst_id,
    count(cst_id) as cnt from  peju_bronze_schema.customer_info,
    group by cst_id
    having cnt > 1
    ----Duplicates present
    
   

    ----check for unwanted spaces
    select cst_firstname
    from peju_bronze_schema.customer_info
    where cst_firstname != Trim (cst_firstname)
    ---checked for all columns no empty spaces

    
2---CREATING TABLE 2.. Product_info
    

         USE SCHEMA peju_bronze_schema;
        create or replace table product_info (
            prd_id integer primary key,
            prd_key varchar (100),
            prd_nm varchar (100),
            prd_cost integer,	
            prd_line varchar,
            prd_start_dt date,
            prd_end_dt date
            );
            ----Load data manually
            ---view table
            select * from peju_bronze_schema.product_info;
            
             select 
                 prd_id,
                count(prd_id) as cnt from product_info,
                group by prd_id
                having cnt > 1
                ----no duplicates

    3 -----CREATE TABLE 3...Sales_details
                
                USE SCHEMA peju_bronze_schema;        
create or replace table sales_details (
    sls_ord_num	varchar primary key,
    sls_prd_key	varchar (100),
    sls_cust_id	integer,
    sls_order_dt varchar (100),	
    sls_ship_dt	varchar (100),
    sls_due_dt	varchar (100),
    sls_sales	integer,
    sls_quantity integer,	
    sls_price integer
    );
    ---load data manually
    ----view TABLE
    select * from peju_bronze_schema.sales_details;
    ----check for duplicates
    select 
        sls_ord_num,
        count (sls_ord_num) as cnt from sales_details,
        group by sls_ord_num
        having  cnt > 1
        ---no duplicates

4----CREATE TABLE 4.... Cust_AZ12
        USE SCHEMA peju_bronze_schema;  
        create or replace table CUST_AZ12 (
           CID varchar(100) primary key,
           BDATE date, 
           GEN varchar(100)
           );
           ---Load data manually
           ---check for duplicates
           select
               cid,
               count (cid)as cnt from CUST_AZ12,
               group by cid
               having cnt > 1
               ----No duplicates
               
5----CREATE TABLE---LOC_A101
USE SCHEMA peju_bronze_schema; 
create or replace table LOC_A101 (
           cid varchar(100) primary key,
           Cntry varchar(100)
            );
            select * from peju_bronze_schema.LOC_A101;
            ---load data manually
            ----check for duplicates
              
     select
            cid,
            count (cid)as cnt from LOC_A101,
            group by cid
            having cnt > 1
            ----no duplicates
            
 6----CREATE TABLE 6....
 use schema peju_bronze_schema
 create or replace table PX_CAT_G1V2 (
    id	varchar (100) primary key,
    cat varchar (100),
    subcat varchar (100),
    maintenance varchar (100)
    );
    ---load data manually
    ---check for duplicates
    select
        id,
        count (id) as cnt from PX_CAT_G1V2,
        group by id
        having cnt > 1
    ---no duplicates
  
              
