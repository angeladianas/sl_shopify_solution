{{
    config(
        materialized='table'
    )
}}

SELECT 
    va.product_id,
    va.id AS variant_id,
    pr.product_type,
    pr.title AS product_name,
    va.title AS variant_name,
    va.price,
    pr.created_at AS product_create_time,
    va.created_at AS variant_create_time,
    va.updated_at AS variant_update_time,
    va.ingested_at AS variant_ingested_time
FROM 
    shopify_dim.product_variant AS va 
LEFT JOIN 
    shopify_dim.product AS pr 
ON 
    va.product_id = pr.id