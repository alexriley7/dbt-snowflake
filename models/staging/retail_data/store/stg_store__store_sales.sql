WITH source_store_sales as (
    select * from {{ source('store', 'store_sales')}}

),

final as (

    select * from source_store_sales
)

select * from final