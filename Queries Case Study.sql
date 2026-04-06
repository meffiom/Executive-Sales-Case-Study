-- Query 1: Customer segments with most sales per year
SELECT 
    strftime('%Y', OrderDate) AS Year,
    c.Segment,
    ROUND(SUM(s.UnitPrice * s.Quantity), 2) AS TotalSales
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY strftime('%Y', OrderDate), c.Segment
ORDER BY Year, TotalSales DESC;

-- Query 2: Product subcategory with most unit growth (2023 vs 2024)
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

-- Query 3: Month-over-month sales by region for 2024
SELECT 
    Region,
    strftime('%m', OrderDate) AS Month,
    ROUND(SUM(UnitPrice * Quantity), 2) AS TotalSales,
    ROUND(SUM(UnitPrice * Quantity) - LAG(SUM(UnitPrice * Quantity)) 
        OVER (PARTITION BY Region ORDER BY strftime('%m', OrderDate)), 2) AS MoM_Change
FROM Sales
WHERE strftime('%Y', OrderDate) = '2024'
GROUP BY Region, strftime('%m', OrderDate)
ORDER BY Region, Month;

-- Query 4: Subcategories that sell better when discounted
SELECT 
    p.Subcategory,
    ROUND(AVG(CASE WHEN s.Discount > 0 THEN s.Quantity END), 2) AS Avg_Qty_Discounted,
    ROUND(AVG(CASE WHEN s.Discount = 0 THEN s.Quantity END), 2) AS Avg_Qty_Full_Price,
    ROUND(AVG(CASE WHEN s.Discount > 0 THEN s.Quantity END) - 
    AVG(CASE WHEN s.Discount = 0 THEN s.Quantity END), 2) AS Difference
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Subcategory
HAVING Avg_Qty_Discounted > Avg_Qty_Full_Price
ORDER BY Difference DESC;

-- Query 5: Fix Customer_1096 segment from SMB to Enterprise
UPDATE Customers
SET Segment = 'Enterprise'
WHERE CustomerID = 1096 AND Segment = 'SMB';
