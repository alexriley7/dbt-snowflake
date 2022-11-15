{{ config(materialized='table') }}

WITH source_store as (
    select * from {{ source('_store__sources', 'store')}}

),

final as (

    select * from source_store
)

select * from final