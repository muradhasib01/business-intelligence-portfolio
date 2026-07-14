/* ============================================================================
   Coffee Chain Data Warehouse — Star Schema (DDL)
   ----------------------------------------------------------------------------
   Recreates the dimensional model I designed in Microsoft Access for the
   Coffee Chain sales dataset. One central fact table records each sale;
   three dimension tables (Product, Store, Financial Budget) give it context.

   This is the classic star schema that underpins OLAP / BI reporting:
   measures live in the fact table, descriptive attributes live in dimensions,
   and analysts slice the measures by any dimension attribute.

   Written in portable ANSI-style SQL. Table/column names mirror the original
   Access model (spaces removed for portability).
   ============================================================================ */

-- ---------- Dimension: Product -------------------------------------------------
CREATE TABLE Product_Dimension (
    Product_ID          INTEGER      NOT NULL,
    Product_Type        VARCHAR(50),          -- Coffee, Espresso, Herbal Tea, Tea
    Type                VARCHAR(50),           -- Regular / Decaf
    Product_Description VARCHAR(100),          -- e.g. Amaretto, Columbian, Caffe Latte
    CONSTRAINT PK_Product PRIMARY KEY (Product_ID)
);

-- ---------- Dimension: Store ---------------------------------------------------
CREATE TABLE Store_Dimension (
    Area_Code   INTEGER      NOT NULL,
    Market      VARCHAR(50),                   -- East, West, South, Central
    Market_Size VARCHAR(50),                   -- Major Market / Small Market
    State       VARCHAR(50),
    CONSTRAINT PK_Store PRIMARY KEY (Area_Code)
);

-- ---------- Dimension: Financial Budget ---------------------------------------
CREATE TABLE Financial_Budget_Dimension (
    Budget_ID     INTEGER      NOT NULL,
    Budget_Sales  DECIMAL(12,2),
    Budget_Margin DECIMAL(12,2),
    Budget_Profit DECIMAL(12,2),
    CONSTRAINT PK_Budget PRIMARY KEY (Budget_ID)
);

-- ---------- Fact: Sales --------------------------------------------------------
CREATE TABLE Fact_Sales (
    Fact_ID    INTEGER      NOT NULL,
    Product_ID INTEGER      NOT NULL,
    Area_Code  INTEGER      NOT NULL,
    Sales      DECIMAL(12,2),
    COGS       DECIMAL(12,2),                  -- Cost of Goods Sold
    Margin     DECIMAL(12,2),
    Profit     DECIMAL(12,2),
    CONSTRAINT PK_Fact PRIMARY KEY (Fact_ID),
    CONSTRAINT FK_Fact_Product FOREIGN KEY (Product_ID) REFERENCES Product_Dimension (Product_ID),
    CONSTRAINT FK_Fact_Store   FOREIGN KEY (Area_Code)  REFERENCES Store_Dimension  (Area_Code)
);

/* Star schema overview:

                    +--------------------------+
                    |    Product_Dimension     |
                    +--------------------------+
                                 |
   +------------------+     +------------+     +-----------------------------+
   | Store_Dimension  |-----| Fact_Sales |-----| Financial_Budget_Dimension  |
   +------------------+     +------------+     +-----------------------------+

   Fact grain: one row per product sale per store area.
   Measures  : Sales, COGS, Margin, Profit.
*/
