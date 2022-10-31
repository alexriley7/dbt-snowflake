{{ config(materialized='table') }}

WITH source_store_returns as (
    select * from {{ source('_store__sources', 'store_returns')}}

),

final as (

    select * from source_store_returns
)

select * from final