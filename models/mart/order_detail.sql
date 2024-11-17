
{{
    config(
        materialized='table'
    )
}}

WITH latest_tr AS (
    SELECT 
        *,
        CASE WHEN status != 'success' THEN 'not success' ELSE status END AS latest_status
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY created_at DESC) AS row_num
        FROM 
            {{ ref('transaction') }}
    )
    WHERE 
        row_num = 1
)

SELECT 
    main.id AS order_id,
    ol.id AS order_line_id,
    tr.id AS transaction_id,
    pr.product_id,
    ol.variant_id,
    main.customer_id,
    ol.price,
    ol.quantity,
    ol.price * ol.quantity AS revenue,
    tr.status AS transaction_status,
    main.processed_timestamp AS order_create_time,
    tr.created_at AS transaction_time,
    pr.product_type,
    pr.product_name,
    pr.variant_name
FROM 
    {{ ref('orders') }} AS main
LEFT JOIN 
    {{ ref('order_lines') }} AS ol
ON 
    main.id = ol.order_id 
LEFT JOIN 
    latest_tr AS tr 
ON 
    main.id = tr.order_id 
LEFT JOIN 
    {{ ref('dim_product') }} AS pr 
ON 
    ol.variant_id = pr.variant_id 
