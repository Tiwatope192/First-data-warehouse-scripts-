This contains scripts used in building a data warehouse in Snowflake SQL, focusing on the gold layer
here i joined the facts and dimension tables to create a star schema for reporting and analysis.
I used the transformed data from the silver layer to create a more refined and optimized structure for analytical queries.  

use database peju_database_workplace;
use schema peju_gold_schema;
create schema if not exists peju_gold_schema;

----we have to start by joining tables with the matching keys/columns together
---we join Customer Info using the customer key  and Cust_AZ12 on cid together, because they the same similarities
select
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
    from peju_silver_schema.customer_info ci
    left join peju_silver_schema.cust_az12 ca
    on ci.cst_key = ca.cid
    left join peju_silver_schema.loc_a101 la
    on ci.cst_key = la.cid

---check for duplicates that might arise as a result of multiple joinings
select cst_id, count(*) from 
(select 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
        from peju_silver_schema.customer_info ci
        left join peju_silver_schema.cust_az12 ca
        on ci.cst_key = ca.cid
        left join peju_silver_schema.loc_a101 la
        on ci.cst_key = la.cid)
        group by cst_id
        having count(*) > 1
        
----No duplicates present  
---Data integration
---we have to integrate cst_gndr and gndr together, first we check if the data is matching
select distinct
ci.cst_gndr,
ca.gen
 from peju_silver_schema.customer_info ci
        left join peju_silver_schema.cust_az12 ca
        on ci.cst_key = ca.cid
        left join peju_silver_schema.loc_a101 la
        on ci.cst_key = la.cid
        order by 1,2
        ---The datas are not matching, to standardise we have to confirm with experts which is the master or source table, which in this case is the customer info table, to standardise,if there are unmatching data, we prioritise the data from customer info (cst_gndr). we do this integration to get rich and complete data
        select distinct
            ci.cst_gndr,
            ca.gen,
            case when ci.cst_gndr !='n/a' then ci.cst_gndr
            else coalesce(ca.gen, 'n/a')
            end as new_gen
            from peju_silver_schema.customer_info ci
            left join peju_silver_schema.cust_az12 ca
            on ci.cst_key = ca.cid
            left join peju_silver_schema.loc_a101 la
            on ci.cst_key = la.cid
            ---we effect this integration in the main query reflecting the changes
            
            select
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    case when ci.cst_gndr !='n/a' then ci.cst_gndr
    else coalesce(ca.gen, 'n/a')
    end as new_gen,
    ci.cst_create_date,
    ca.bdate,
    la.cntry
    from peju_silver_schema.customer_info ci
    left join peju_silver_schema.cust_az12 ca
    on ci.cst_key = ca.cid
    left join peju_silver_schema.loc_a101 la
    on ci.cst_key = la.cid
    ----rename columns using the principles of naming conventions
    --use snake_case, lowercase and underscores to separate words,
    --use english words for names
    --do not use sql reserved words as object names
        select
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as last_name,
    ci.cst_marital_status as marital_status,
    case when ci.cst_gndr !='n/a' then ci.cst_gndr
    else coalesce(ca.gen, 'n/a')
    end as gender,
    ci.cst_create_date as create_date,
    ca.bdate as birthdate,
    la.cntry as country
    from peju_silver_schema.customer_info ci
    left join peju_silver_schema.cust_az12 ca
    on ci.cst_key = ca.cid
    left join peju_silver_schema.loc_a101 la
    on ci.cst_key = la.cid

---bring relevant columns together e.g country should be closer to personal informations such as name, to do this we reorder the columns
    select
        ci.cst_id as customer_id,
        ci.cst_key as customer_number,
        ci.cst_firstname as first_name,
        ci.cst_lastname as last_name,
        ci.cst_marital_status as marital_status,
        la.cntry as country,
        case when ci.cst_gndr !='n/a' then ci.cst_gndr
        else coalesce(ca.gen, 'n/a')
        end as gender,
         ca.bdate as birthdate,
        ci.cst_create_date as create_date,
        from peju_silver_schema.customer_info ci
        left join peju_silver_schema.cust_az12 ca
        on ci.cst_key = ca.cid
        left join peju_silver_schema.loc_a101 la
        on ci.cst_key = la.cid

---This table is a dimension table becausebit holds decriptive info about the customer such as gender, age , marital status etc
        
        ---insert surrogate keys which are unique identifiers assigned to each record in a table, to di this we use a query-based window function row number) it is not from the source system but rather used for data modelling
        select
            row_number () over (order by cst_id) as customer_key,
            ci.cst_id as customer_id,
            ci.cst_key as customer_number,
            ci.cst_firstname as first_name,
            ci.cst_lastname as last_name,
            ci.cst_marital_status as marital_status,
            la.cntry as country,
            case when ci.cst_gndr !='n/a' then ci.cst_gndr
            else coalesce(ca.gen, 'n/a')
            end as gender,
             ca.bdate as birthdate,
            ci.cst_create_date as create_date,
            from peju_silver_schema.customer_info ci
            left join peju_silver_schema.cust_az12 ca
            on ci.cst_key = ca.cid
            left join peju_silver_schema.loc_a101 la
            on ci.cst_key = la.cid
            
            ---create a view to query the joined table
            
            drop view peju_database_workplace.peju_gold_schema.customer_info;
            
            create view peju_database_workplace.peju_gold_schema.dim_customer as
            select
            row_number () over (order by cst_id) as customer_key,
            ci.cst_id as customer_id,
            ci.cst_key as customer_number,
            ci.cst_firstname as first_name,
            ci.cst_lastname as last_name,
            ci.cst_marital_status as marital_status,
            la.cntry as country,
            case when ci.cst_gndr !='n/a' then ci.cst_gndr
            else coalesce(ca.gen, 'n/a')
            end as gender,
             ca.bdate as birthdate,
            ci.cst_create_date as create_date,
            from peju_silver_schema.customer_info ci
            left join peju_silver_schema.cust_az12 ca
            on ci.cst_key = ca.cid
            left join peju_silver_schema.loc_a101 la
            on ci.cst_key = la.cid

            ---Query table to check data quality
       select * from peju_gold_schema.dim_customer;
            
 ----------------------------------------------------------------------------           --joining table 2
 ----we have to filter out historical data, thereby leaving current end dates open and represented with nulls, so we eliminate the end date column
 select
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,	
    pn.prd_line,
    pn.prd_start_dt,
    pn.prd_end_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance
    from peju_silver_schema.product_info pn
    left join peju_silver_schema.px_cat_g1v2 pc
    on pn.cat_id = pc.id
    where prd_end_dt is null

---check data quality by checking for duplicates
select 
    prd_id, count (*) from (
    select
    pn.prd_id,
         pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,	
        pn.prd_line,
        pn.prd_start_dt,
        pn.prd_end_dt
        pc.cat,
        pc.subcat,
        pc.maintenance
        from peju_silver_schema.product_info pn
        left join peju_silver_schema.px_cat_g1v2 pc
        on pn.cat_id = pc.id
        where prd_end_dt is null)
        group by prd_id
        having count (*) > 1

    ---no duplicates 
    ---improve readability by putting like columns together  and rename columns
    
    select
        pn.prd_id as product_id,
        pn.prd_key as product_number,
        pn.prd_nm as product_name,
        pn.prd_cost as product_cost,
        pc.subcat as subcategory
        pc.cat as category,
        pn.cat_id as category_id,
        pn.prd_line as product_line,
        pc.maintenance,
         pn.prd_start_dt as start_date
         pn.prd_end_dt as end_date
        from peju_silver_schema.product_info pn
        left join peju_silver_schema.px_cat_g1v2 pc
        on pn.cat_id = pc.id
        where prd_end_dt is null
        ---this is also a dimension table because it is just describing one object which is the product rather than events

    ---create a surrogate key
    select
        row_number() over (order by pn.prd_key) as product_key,
        pn.prd_id as product_id,
        pn.prd_key as product_number,
        pn.prd_nm as product_name,
        pn.prd_cost as product_cost,	
        pc.cat as category,
        pn.cat_id as category_id,
        pn.prd_line as product_line,
        pc.maintenance,
         pn.prd_start_dt as start_date
         pn.prd_end_dt as end_date
        from peju_silver_schema.product_info pn
        left join peju_silver_schema.px_cat_g1v2 pc
        on pn.cat_id = pc.id
        where prd_end_dt is null
        
        drop view  peju_database_workplace.peju_gold_schema.dim_product;
        create view peju_database_workplace.peju_gold_schema.dim_product as
        select
            row_number() over (order by pn.prd_key) as product_key,
            pn.prd_id as product_id,
            pn.prd_key as product_number,
            pn.prd_nm as product_name,
            pn.prd_cost as product_cost,
            pn.prd_line as product_line,
            pc.cat as category,
            pc.subcat as subcategory,
            pn.cat_id as category_id,
            pc.maintenance as maintenance,
            pn.prd_start_dt as start_date
            from peju_silver_schema.product_info pn
            left join peju_silver_schema.px_cat_g1v2 pc
            on pn.cat_id = pc.id
            where prd_end_dt is null
            
            select * from peju_gold_schema.dim_product;
  
-------------------------------------------------------------------- Table 3
--This is a fact table because its talking about metrics.dates and measures rather than providing or describing the sales details
---Data lookup, we join two columns together using a surrogate key to connect the dimensions table customer info and product info with the fact table sales details 

select
    sls_ord_num as order_number,
    pr.product_key,
    cu.customer_key,
    sls_order_dt as order_date,	
    sls_ship_dt as shipping_date,
    sls_due_dt as due_date,
    sls_sales as sales_amount,
    sls_quantity as quantity,	
    sls_price as price
    from peju_silver_schema.sales_details sd
    Left join peju_gold_schema.product_info pr
    on sd.sls_prd_key = pr.product_number
    left join peju_gold_schema.customer_info cu
   on sd.sls_cust_id = cu.customer_id 
   
   drop view peju_database_workplace.peju_gold_schema.sales_info; 
   create view peju_database_workplace.peju_gold_schema.fact_sales as
   select
    sls_ord_num as order_number,
    pr.product_key,
    cu.customer_key,
    sls_order_dt as order_date,	
    sls_ship_dt as shipping_date,
    sls_due_dt as due_date,
    sls_sales as sales_amount,
    sls_quantity as quantity,	
    sls_price as price
    from peju_silver_schema.sales_details sd
    Left join peju_gold_schema.dim_product pr
    on sd.sls_prd_key = pr.product_number
    left join peju_gold_schema.dim_customer cu
   on sd.sls_cust_id = cu.customer_id 
   
   select * from peju_gold_schema.fact_sales;

   ----Quality check---foreign integrity key (Dimensions)
   select * 
   from peju_gold_schema.sales_info s
   left join peju_gold_schema.customer_info c
   on c.customer_key = s.customer_key
   where c.customer_key is null
   ---No results