/* ============================================================================
   Coffee Chain — Analytical Query Library
   ----------------------------------------------------------------------------
   Business questions answered with SQL against the star schema defined in
   coffee-chain-star-schema.sql. These mirror the analyses I built visually in
   Tableau (see ../05-tableau/) — here they are as reproducible, reviewable SQL.

   Techniques demonstrated: INNER JOINs across a star schema, GROUP BY
   aggregation, HAVING, CASE expressions, subqueries/CTEs, and window functions
   (RANK, running totals, % of total).
   ============================================================================ */


/* Q1. Total sales and profit by product type and market size.
   (Recreates the Tableau "profit by product type / market size" view.) */
SELECT  p.Product_Type,
        s.Market_Size,
        SUM(f.Sales)  AS Total_Sales,
        SUM(f.Profit) AS Total_Profit
FROM        Fact_Sales f
JOIN        Product_Dimension p ON f.Product_ID = p.Product_ID
JOIN        Store_Dimension   s ON f.Area_Code  = s.Area_Code
GROUP BY    p.Product_Type, s.Market_Size
ORDER BY    Total_Profit DESC;


/* Q2. Top product type by sales in EACH market — using a window function
   to rank within each market and keep only the leader. */
WITH market_type_sales AS (
    SELECT  s.Market,
            p.Product_Type,
            SUM(f.Sales) AS Total_Sales,
            RANK() OVER (PARTITION BY s.Market ORDER BY SUM(f.Sales) DESC) AS sales_rank
    FROM        Fact_Sales f
    JOIN        Product_Dimension p ON f.Product_ID = p.Product_ID
    JOIN        Store_Dimension   s ON f.Area_Code  = s.Area_Code
    GROUP BY    s.Market, p.Product_Type
)
SELECT Market, Product_Type, Total_Sales
FROM   market_type_sales
WHERE  sales_rank = 1
ORDER BY Market;


/* Q3. Most profitable product in each state (product + product type + state). */
WITH product_state_profit AS (
    SELECT  s.State,
            p.Product_Description,
            p.Product_Type,
            SUM(f.Profit) AS Total_Profit,
            RANK() OVER (PARTITION BY s.State ORDER BY SUM(f.Profit) DESC) AS profit_rank
    FROM        Fact_Sales f
    JOIN        Product_Dimension p ON f.Product_ID = p.Product_ID
    JOIN        Store_Dimension   s ON f.Area_Code  = s.Area_Code
    GROUP BY    s.State, p.Product_Description, p.Product_Type
)
SELECT State, Product_Description, Product_Type, Total_Profit
FROM   product_state_profit
WHERE  profit_rank = 1
ORDER BY State;


/* Q4. Loss-making products — where total profit is negative.
   (Answers the assignment question "do any products generate a loss?") */
SELECT      p.Product_Description,
            p.Product_Type,
            SUM(f.Sales)  AS Total_Sales,
            SUM(f.Profit) AS Total_Profit
FROM        Fact_Sales f
JOIN        Product_Dimension p ON f.Product_ID = p.Product_ID
GROUP BY    p.Product_Description, p.Product_Type
HAVING      SUM(f.Profit) < 0
ORDER BY    Total_Profit ASC;


/* Q5. Profit margin % by product type, with a performance flag (CASE). */
SELECT      p.Product_Type,
            SUM(f.Sales)  AS Total_Sales,
            SUM(f.Profit) AS Total_Profit,
            ROUND(SUM(f.Profit) * 100.0 / NULLIF(SUM(f.Sales), 0), 1) AS Profit_Margin_Pct,
            CASE
                WHEN SUM(f.Profit) * 1.0 / NULLIF(SUM(f.Sales), 0) >= 0.30 THEN 'High margin'
                WHEN SUM(f.Profit) * 1.0 / NULLIF(SUM(f.Sales), 0) >= 0.15 THEN 'Healthy'
                ELSE 'Low / watch'
            END AS Margin_Band
FROM        Fact_Sales f
JOIN        Product_Dimension p ON f.Product_ID = p.Product_ID
GROUP BY    p.Product_Type
ORDER BY    Profit_Margin_Pct DESC;


/* Q6. Each market's contribution to total company sales (% of total). */
SELECT      s.Market,
            SUM(f.Sales) AS Market_Sales,
            ROUND(SUM(f.Sales) * 100.0
                  / (SELECT SUM(Sales) FROM Fact_Sales), 1) AS Pct_Of_Total_Sales
FROM        Fact_Sales f
JOIN        Store_Dimension s ON f.Area_Code = s.Area_Code
GROUP BY    s.Market
ORDER BY    Market_Sales DESC;


/* Q7. Actual vs. budget: compare realized profit to the budgeted figure.
   Demonstrates joining the fact table to the budget dimension and a variance. */
SELECT      SUM(f.Profit)                    AS Actual_Profit,
            SUM(b.Budget_Profit)             AS Budgeted_Profit,
            SUM(f.Profit) - SUM(b.Budget_Profit) AS Profit_Variance
FROM        Fact_Sales f
CROSS JOIN  Financial_Budget_Dimension b;


/* Q8. Running (cumulative) sales by market, ordered by sales — window frame. */
SELECT      s.Market,
            SUM(f.Sales) AS Market_Sales,
            SUM(SUM(f.Sales)) OVER (ORDER BY SUM(f.Sales) DESC
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                AS Running_Sales
FROM        Fact_Sales f
JOIN        Store_Dimension s ON f.Area_Code = s.Area_Code
GROUP BY    s.Market
ORDER BY    Market_Sales DESC;
