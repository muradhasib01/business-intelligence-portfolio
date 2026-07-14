# SQL & Dimensional Modeling — Coffee Chain

**Business question:** *How do you model retail sales data so it can be queried quickly across products, stores, and budgets — and answer real profit questions with SQL?*

## What's here

| File | What it shows |
|------|---------------|
| [`coffee-chain-star-schema.sql`](coffee-chain-star-schema.sql) | **DDL** recreating the star schema — one `Fact_Sales` table + `Product`, `Store`, and `Financial_Budget` dimensions, with primary/foreign keys. |
| [`coffee-chain-analytics-queries.sql`](coffee-chain-analytics-queries.sql) | **8 analytical queries** answering business questions: profit by product/market, top product per market (`RANK`), loss-making products (`HAVING`), margin bands (`CASE`), market contribution (% of total), actual-vs-budget variance, and running totals. |
| `coffee-store-database.accdb` / `A3-relational-database.accdb` | The original MS Access models (data-modeling assignments — schema designed in Access). |

## The model

```
        Product_Dimension                 Financial_Budget_Dimension
                \                                    /
                 \                                  /
   Store_Dimension  ────────  Fact_Sales  ────────
```

- **Fact grain:** one row per product sale per store area.
- **Measures:** Sales, COGS, Margin, Profit.
- **Dimensions:** Product (type, description), Store (market, market size, state), Budget.

## Techniques demonstrated

`INNER JOIN` across a star schema · `GROUP BY` / `HAVING` aggregation · `CASE` expressions · CTEs (`WITH`) · window functions — `RANK() OVER (PARTITION BY …)`, running totals with `SUM() OVER (… ROWS BETWEEN …)`, and percent-of-total subqueries.

> These are the same questions visualized in the [Tableau dashboards](../05-tableau/) — here as reproducible SQL.
