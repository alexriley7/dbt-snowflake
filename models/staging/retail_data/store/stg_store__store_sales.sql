WITH source_store_sales as (
    select * from {{ source('_store__sources', 'store_sales')}}

),

final as (

    select * from source_store_sales
)

select * from final