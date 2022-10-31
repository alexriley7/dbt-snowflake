SQL style guide
DO NOT OPTIMIZE FOR FEWER LINES OF CODE.

New lines are cheap, brain time is expensive; new lines should be used within reason to produce code that is easily read.

Use trailing commas

Indents should use four spaces.

When dealing with long when or where clauses, predicates should be on a new line and indented.
Example:

where 
    user_id is not null
    and status = 'pending'
    and location = 'hq'
Lines of SQL should be no longer than 80 characters and new lines should be used to ensure this.
Example:

sum(
    case
        when order_status = 'complete'
            then order_total 
    end
) as monthly_total,



{{ get_windowed_values(
      strategy='sum',
      partition='order_id',
      order_by='created_at',
      column_list=[
          'final_cost'
      ]
) }} as total_final_cost
Use all lowercase unless a specific scenario needs you to do otherwise. This means that keywords, field names, function names, and file names should all be lowercased.

The as keyword should be used when aliasing a field or table

Fields should be stated before aggregates / window functions

Aggregations should be executed as early as possible before joining to another table.

Ordering and grouping by a number (eg. group by 1, 2) is preferred over listing the column names (see this rant for why). Note that if you are grouping by more than a few columns, it may be worth revisiting your model design. If you really need to, the dbt_utils.group_by function may come in handy.

Prefer union all to union *

Avoid table aliases in join conditions (especially initialisms) – it's harder to understand what the table called "c" is compared to "customers".

If joining two or more tables, always prefix your column names with the table alias. If only selecting from one table, prefixes are not needed.

Be explicit about your join (i.e. write inner join instead of join). left joins are the most common, right joins often indicate that you should change which table you select from and which one you join to.

Joins should list the left table first (i.e., the table you're joining data to)
Example:

select
    trips.*,
    drivers.rating as driver_rating,
    riders.rating as rider_rating
from trips
left join users as drivers
   on trips.driver_id = drivers.user_id
left join users as riders
    on trips.rider_id = riders.user_id
Example SQL
with

my_data as (
    select * from {{ ref('my_data') }}
    where not is_deleted
),

some_cte as (
    select * from {{ ref('some_cte') }}
),

some_cte_agg as (
    select
        id,
        sum(field_4) as total_field_4,
        max(field_5) as max_field_5
    from some_cte
    group by 1
),

final as (
    select [distinct]
        my_data.field_1,
        my_data.field_2,
        my_data.field_3,

        -- use line breaks to visually separate calculations into blocks
        case
            when my_data.cancellation_date is null
                and my_data.expiration_date is not null
                then expiration_data
            when my_data.cancellation_date is null
                then my_data.start_date + 7
            else my_data.cancellation_date
        end as cancellation_date,

        some_cte_agg.total_field_4,
        some_cte_agg.max_field_5
    from my_data
    left join some_cte_agg  
        on my_data.id = some_cte_agg.id
    where 
        my_data.field_1 = 'abc'
        and (
            my_data.field_2 = 'def'
            or my_data.field_2 = 'ghi'
        )
    qualify row_number() over(
        partition by my_data.field_1
        order by my_data.start_date desc
    ) = 1
)

select * from final
YAML and Markdown style guide
Every subdirectory contains their own .yml file(s) which contain configurations for the models within the subdirectory.

YAML and markdown files should be prefixed with an underscore ( _ ) to keep it at the top of the subdirectory.

YAML and markdown files should be named with the convention _<description>__<config>.

Examples: _jaffle_shop__sources.yml, _jaffle_shop__docs.md

description is typically the folder of models you're setting configurations for.
Examples: core, staging, intermediate
config is the top-level resource you are configuring.
Examples: docs, models, sources
Indents should use two spaces.

List items should be indented.

Use a new line to separate list items that are dictionaries, where appropriate.

Lines of YAML should be no longer than 80 characters.

Items listed in a single .yml or .md file should be sorted alphabetically for ease of finding in larger files.

Each top-level configuration should use a separate .yml file (i.e, sources, models) Example:

models
├── marts
└── staging
    └── jaffle_shop
        ├── _jaffle_shop__docs.md

        ├── _jaffle_shop__models.yml
        ├── _jaffle_shop__sources.yml
        ├── stg_jaffle_shop__customers.sql
        ├── stg_jaffle_shop__orders.sql
        └── stg_jaffle_shop__payments.sql
Example YAML
_jaffle_shop__models.yml:

version: 2

models:

  - name: base_jaffle_shop__nations

    description: This model cleans the raw nations data
    columns:
      - name: nation_id
        tests:
          - unique
          - not_null   

  - name: base_jaffle_shop__regions
    description: >
      This model cleans the raw regions data before being joined with nations
      data to create one cleaned locations table for use in marts.
    columns:
      - name: region_id
        tests:
          - unique
          - not_null

  - name: stg_jaffle_shop__locations

    description: "{{ doc('jaffle_shop_location_details') }}"

    columns:
      - name: location_sk
        tests:
          - unique
          - not_null
Example Markdown
_jaffle_shop__docs.md:

  {% docs enumerated_statuses %}
    
    Although most of our data sets have statuses attached, you may find some
    that are enumerated. The following table can help you identify these statuses.
    | Status | Description                                                                 |
    |--------|---------------|
    | 1      | ordered       |
    | 2      | shipped       |
    | 3      | pending       |
    | 4      | order_pending | 

    
{% enddocs %}

{% docs statuses %} 

    Statuses can be found in many of our raw data sets. The following lists
    statuses and their descriptions:
    | Status        | Description                                                                 |
    |---------------|-----------------------------------------------------------------------------|
    | ordered       | A customer has paid at checkout.                                            |
    | shipped       | An order has a tracking number attached.                                    |
    | pending       | An order has been paid, but doesn't have a tracking number.                 |
    | order_pending | A customer has not yet paid at checkout, but has items in their cart. | 

{% enddocs %}
