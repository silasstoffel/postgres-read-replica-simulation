# Postgres-Read-Replica-Simulation

## About
This project have the proposal to simulate a read replica infrastucture in postgres (physical replication).

![Diagram](/doc/diagram.svg)

## Commands

```shell
# Creating postgres instancies
docker-compose up

# Acessing prostgres shell for primary database (read and write operations)
make primary-db-shell

# Acessing prostgres shell for replica database (readonly)
make replica-db-shell
```

## Operations

```shell
# writing operation
make primary-db-shell

insert into categories(name) values ('electronics');
insert into categories(name) values ('fitness');

select * from categories order by 1 desc limit 2;

# Acessing replica database (readonly) and executing read operation
make replica-db-shell

select * from products where sku in('SKU-4', 'SKU-5');
```

## Analytics Operations

Accessing metabase using this host http://localhost:3000 and configure the source to read the replica database.

### Queries:

1. Bestselling Products

```sql
select
   p.name as product_name
   ,SUM (oi.total_price) as amount
from 
  orders as o
  join order_items oi on oi.order_id = o.id
  join products p on p.id = oi.product_id

where o.status IN('PAID', 'SHIPPED', 'DELIVERED') 

group by 1
```

2. Monthly sales
```sql
SELECT
	to_char(o.created_at, 'YYYY-MM') as period
	,sum(o.total_amount)
	,count(*)
FROM
  orders o

WHERE
	o.created_at >= date_trunc('month', now()) - interval '{{last_months}} months'
	and o.status IN ('PAID','SHIPPED','DELIVERED')

group by 1

ORDER BY 1 
```

3. Orders Total Amount by Status

```sql
SELECT
  "public"."orders"."status" AS "status",
  SUM("public"."orders"."total_amount") AS "sum"
FROM
  "public"."orders"
GROUP BY
  "public"."orders"."status"
ORDER BY
  "public"."orders"."status" ASC
``` 

4. Sales conversion

```sql
WITH all_orders AS (
    SELECT
        date_trunc('month', o.created_at) AS period,
        COUNT(*) AS total_orders
    FROM orders o
    WHERE
        o.created_at >= date_trunc('month', now()) - ({{last_months}} * interval '1 month')
    GROUP BY 1
),
converted AS (
    SELECT
        date_trunc('month', o.created_at) AS period,
        COUNT(*) AS total_converted
    FROM orders o
    WHERE
        o.created_at >= date_trunc('month', now()) - ({{last_months}} * interval '1 month')
        AND o.status IN ('PAID','SHIPPED','DELIVERED')
    GROUP BY 1
)
SELECT
    COALESCE(c.period, u.period) AS period,
    COALESCE(c.total_converted, 0) AS total_converted,
    COALESCE(u.total_orders, 0) AS total_orders,
    (COALESCE(c.total_converted, 0)::numeric / NULLIF(COALESCE(u.total_orders, 0), 0)) * 100 AS percent_converted
FROM converted c
FULL JOIN all_orders u ON u.period = c.period
ORDER BY 1;
``` 