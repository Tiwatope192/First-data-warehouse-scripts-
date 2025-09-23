
-- silver_layer.sql
-- This SQL file is part of the silver layer in a data processing pipeline.
-- It includes transformations and checks for duplicates in the data.
---create a database, Warehouse,set admin role,set schema as public

----create a database, Warehouse,set admin role,set schema as public

-----precise database
USE DATABASE peju_database_workplace;
     
-----create new schema, name, and precise
        USE SCHEMA peju_bronze_schema;
        
-----create a table
create or replace table customer_info (
    cst_id integer primary key,
    cst_key varchar (100),
    cst_firstname varchar(100),
    cst_lastname varchar(100),	
    cst_marital_status varchar(20),
    cst_gndr varchar(10),
    cst_create_date date );
    
    select*
    from peju_bronze_schema.customer_info;

    select cst_firstname
     from peju_bronze_schema.customer_info
     where cst_firstname != TRIM (cst_firstname)

        select cst_lastname
     from peju_bronze_schema.customer_info;PHOENIX_ANALYTICS_DB.DBT_LOLA
     
    SHOW TABLES IN SCHEMA peju_bronze_schema;

    
    ----load data manually (no code)
    
   ----check for duplicates
    select cst_id,
    count(cst_id) as cnt from customer_info,
    group by cst_id
    having cnt > 1
    
    ----confirm duplicates
     select * from customer_info
    where cst_id in (29483,29449,29466,29433)
    
    ----Data Cleaning
        Delete from customer_info
        where cst_create_date = date('2026-01-26') 
        and cst_id in (29466)

    ----check for unwanted spaces
    select cst_firstname
    from customer_info;
        
        ---creating other tables
        
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
            
            -----delete table
             drop table product_info
             
             -----check for duplicates
               select prd_id,
    count(prd_id) as cnt from product_info,
    group by prd_id
    having cnt > 1
    
---creating other tables
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


USE SCHEMA peju_bronze_schema;

drop table sales_details
Think of data modelling and transformation

-----move to silver facts and dimension tables (star schema or snowflake)
and gold

----check for duplicates
    select sls_ord_num,
    count(sls_ord_num) as cnt from sales_details,
    group by sls_ord_num
    having cnt > 1 or sls_ord_num is NULL;
    
drop table customer_info2
   create or replace table CUST_AZ12 (
   CID varchar(100) primary key,
   BDATE date, 
   GEN varchar(100)
   );
   ---duplicates
   
   select CID,
   count (CID)as cnt from CUST_AZ12,
   group by CID
   having cnt > 1 or CID is NULL;
   
----Clean data, since we are joining customer info primary key and cust-az12 customer id together we have to make sure the primary key matches i.e NASAW00 = AW000
----To do this we eliminate NAS from cust_azi2 because it carry no relevance to the data
----First check, only one data in customer_info carries NAS, so we can clean and standardise data
select 
cid,
bdate, 
gen 
from
   peju_bronze_schema.CUST_AZ12
   where cid like '%AW00011000%'
   ----data transformation
       select
       case when cid like 'NAS%'then substring (cid,4,length(cid))
       else cid
       end cid,
       case when bdate > getdate ()then null
       else bdate
       end as bdate,
       case when upper(trim(gen)) in ('F','FEMALE') THEN 'Female'
       when upper(trim(gen)) in ('M','MALE') THEN 'Male'
       Else 'n/a'
      End as gen
       from
    peju_bronze_schema.CUST_AZ12
    insert into peju_silver_schema.CUST_AZ12 (cid, bdate, gen) 
    FROM peju_bronze_schema;

   
create or replace table LOC_A101 (
   CID varchar(100) primary key,
   CNTRY varchar(100)
 );
----duplicates
select CID,
count (CID)as cnt from  LOC_A101,
group by CID
having cnt >1 or CID is NULL;



create or replace table PX_CAT_G1V2 (
ID	varchar (100) primary key,
CAT varchar (100),
SUBCAT varchar (100),
MAINTENANCE varchar (100)
);
---Duplicates
 select ID,
   count (ID)as cnt from PX_CAT_G1V2 ,
   group by ID
   having cnt > 1 or ID is NULL;

---drop a table that is already loaded
DROP TABLE IF EXISTS peju_bronze_schema.CUSTOMER_CUST_AZ12;

----Clean data
select 
cid,
gen 
from 

---- To check the number of columns in a table
select count (*) from peju_bronze_schema

----Bulk insert
----Truncate Table bronze. schema name. table name (for a full load truncate means to empty the table first before loading data in order to be sure)
----'File Path\file name.csv'
---With (
----Firstrow =2, (telling sql to skip the first row which is the header)
----Fieldterminator = ',', (telling sql that we have a field delimiter which is a comma separating data so it can recognise it)
----Tablock (locking the whole table)

---Create silver layer
---precise database
use database peju_database_workplace;

CREATE SCHEMA IF NOT EXISTS peju_silver_schema;

USE SCHEMA peju_silver_schema;

Create or replace table customer_info (
cst_id integer primary key,
    cst_key varchar (100),
    cst_firstname varchar(100),
    cst_lastname varchar(100),	
    cst_marital_status varchar(20),
    cst_gndr varchar(10),
    cst_create_date date);
    select * from peju_silver_schema.customer_info;
    
    INSERT INTO peju_silver_schema.customer_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM peju_bronze_schema.customer_info;
select * from peju_silver_schema.customer_info;
----check for unwanted spaces
select cst_create_date
from peju_silver_schema.customer_info
where  cst_create_date  != TRIM ( cst_create_date)
----Results: No results, no unwanted spaces

-----Data standardization and consistency
---change abbreviations to full and null to not availaible n/a
---To check
select distinct cst_gndr from peju_silver_schema.customer_info
---To change
    SELECT
    cst_gndr,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr
FROM peju_silver_schema.customer_info;
----change marital status from appreviations
 SELECT
    cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status
FROM peju_silver_schema.customer_info;

---To insert clean data

INSERT into peju_silver_schema.customer_info (


INSERT INTO peju_silver_schema.customer_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,

    cst_create_date
FROM peju_bronze_schema.customer_info;

UPDATE peju_silver_schema.customer_info
SET cst_marital_status = CASE
    WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE cst_marital_status
END;

UPDATE peju_silver_schema.customer_info
SET cst_gndr = CASE
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE cst_gndr
END;

select * from peju_silver_schema.customer_info;s