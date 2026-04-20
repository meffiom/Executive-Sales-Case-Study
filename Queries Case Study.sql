-- ============================================================
-- QUERY 1: Which customer segment had the MOST sales per year?
-- ============================================================

WITH segment_sales AS (
    SELECT
        strftime('%Y', s.OrderDate)             AS Year,
        c.Segment,
        ROUND(SUM(s.UnitPrice * s.Quantity), 2) AS TotalSales
    FROM Sales s
    JOIN Customers c ON s.CustomerID = c.CustomerID
    GROUP BY strftime('%Y', s.OrderDate), c.Segment
),
ranked AS (
    SELECT
        Year,
        Segment,
        TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY Year
            ORDER BY TotalSales DESC
        ) AS rnk
    FROM segment_sales
)
SELECT
    Year,
    Segment AS TopSegment,
    TotalSales
FROM ranked
WHERE rnk = 1
ORDER BY Year;

-- ============================================================
-- QUERY 2: Which product subcategory had the most unit growth?
-- ============================================================

SELECT
    p.Subcategory,
    SUM(CASE WHEN strftime('%Y', s.OrderDate) = '2023' THEN s.Quantity ELSE 0 END) AS Units_2023,
    SUM(CASE WHEN strftime('%Y', s.OrderDate) = '2024' THEN s.Quantity ELSE 0 END) AS Units_2024,
    SUM(CASE WHEN strftime('%Y', s.OrderDate) = '2024' THEN s.Quantity ELSE 0 END) -
    SUM(CASE WHEN strftime('%Y', s.OrderDate) = '2023' THEN s.Quantity ELSE 0 END) AS UnitGrowth
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Subcategory
ORDER BY UnitGrowth DESC;


-- ============================================================
-- QUERY 3: Month-over-month change in sales by region (2024)
-- ============================================================

WITH monthly_sales AS (
    SELECT
        Region,
        CAST(strftime('%m', OrderDate) AS INTEGER) AS Month,
        ROUND(SUM(UnitPrice * Quantity), 2)        AS TotalSales
    FROM Sales
    WHERE strftime('%Y', OrderDate) = '2024'
    GROUP BY Region, strftime('%m', OrderDate)
)
SELECT
    Region,
    Month,
    TotalSales,
    LAG(TotalSales) OVER (
        PARTITION BY Region
        ORDER BY Month
    )                                              AS PrevMonthSales,
    ROUND(
        TotalSales - LAG(TotalSales) OVER (
            PARTITION BY Region
            ORDER BY Month
        ), 2
    )                                              AS MoM_Change
FROM monthly_sales
ORDER BY Region, Month;


-- ============================================================
-- QUERY 4: Which subcategories sell better when discounted?
-- ============================================================

SELECT
    p.Subcategory,
    ROUND(AVG(CASE WHEN s.Discount > 0 THEN CAST(s.Quantity AS FLOAT) END), 2) AS Avg_Qty_With_Discount,
    ROUND(AVG(CASE WHEN s.Discount = 0 THEN CAST(s.Quantity AS FLOAT) END), 2) AS Avg_Qty_Full_Price,
    ROUND(
        AVG(CASE WHEN s.Discount > 0 THEN CAST(s.Quantity AS FLOAT) END) -
        AVG(CASE WHEN s.Discount = 0 THEN CAST(s.Quantity AS FLOAT) END),
    2)                                                                           AS Difference,
    CASE
        WHEN AVG(CASE WHEN s.Discount > 0 THEN CAST(s.Quantity AS FLOAT) END) >
             AVG(CASE WHEN s.Discount = 0 THEN CAST(s.Quantity AS FLOAT) END)
        THEN 'YES - Discounting helps'
        ELSE 'NO - Discounting does not help'
    END                                                                          AS Discount_Effective
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Subcategory
ORDER BY Difference DESC;


-- ============================================================
-- QUERY 5: Fix Customer_1096 segment from SMB to Enterprise
-- ============================================================

-- Verify BEFORE update:
SELECT CustomerID, CustomerName, Segment
FROM Customers
WHERE CustomerID = 1096;

-- Run the fix:
UPDATE Customers
SET Segment = 'Enterprise'
WHERE CustomerID = 1096
  AND Segment = 'SMB';

-- Verify AFTER update:
SELECT CustomerID, CustomerName, Segment
FROM Customers
WHERE CustomerID = 1096;
