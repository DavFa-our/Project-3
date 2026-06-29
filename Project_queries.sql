-- ============================================================
-- Project Order Data — SQL Insights
-- Table: orders (1,200 rows, loaded from CLEANED DATA sheet)
-- ============================================================

-- 1. Top 10 highest-value orders (excluding cancelled)
SELECT OrderID, Date, Product, Quantity, UnitPrice, TotalPrice, OrderStatus
FROM orders
WHERE OrderStatus != 'Cancelled'
ORDER BY TotalPrice DESC
LIMIT 10;

-- 2. High-value Laptop orders paid by Credit Card
SELECT OrderID, Date, CustomerID, Quantity, UnitPrice, TotalPrice
FROM orders
WHERE Product = 'Laptop'
  AND PaymentMethod = 'Credit Card'
  AND TotalPrice > 1000
ORDER BY TotalPrice DESC;

-- 3. Revenue, order count, and average order value by Product
SELECT Product,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY Product
ORDER BY TotalRevenue DESC;

-- 4. Order count and revenue by Order Status
SELECT OrderStatus,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY OrderStatus
ORDER BY OrderCount DESC;

-- 5. Payment methods with above-average order value
SELECT PaymentMethod,
       COUNT(*) AS OrderCount,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY PaymentMethod
HAVING AVG(TotalPrice) > (SELECT AVG(TotalPrice) FROM orders)
ORDER BY AvgOrderValue DESC;

-- 6. Orders and revenue by Referral Source
SELECT ReferralSource,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY ReferralSource
ORDER BY TotalRevenue DESC;

-- 7. Orders placed in June 2024
SELECT OrderID, Date, Product, TotalPrice, OrderStatus
FROM orders
WHERE Date >= '2024-06-01' AND Date < '2024-07-01'
ORDER BY Date ASC;

-- 8. Monthly order volume and revenue trend
SELECT substr(Date, 1, 7) AS Month,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY Month
ORDER BY Month ASC;

-- 9. Coupon usage analysis
SELECT COALESCE(CouponCode, 'No Coupon') AS Coupon,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY Coupon
ORDER BY OrderCount DESC;

-- 10. Top 10 customers by total spend
SELECT CustomerID,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalSpent,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;

-- 11. Bulk orders (Quantity >= 4) by Product
SELECT Product,
       COUNT(*) AS BulkOrderCount,
       SUM(TotalPrice) AS BulkRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgBulkOrderValue
FROM orders
WHERE Quantity >= 4
GROUP BY Product
ORDER BY BulkRevenue DESC;

-- 12. Cancelled or Returned orders by Product
SELECT Product, OrderStatus,
       COUNT(*) AS Count,
       SUM(TotalPrice) AS LostRevenue
FROM orders
WHERE OrderStatus IN ('Cancelled', 'Returned')
GROUP BY Product, OrderStatus
ORDER BY LostRevenue DESC;

-- 13. Overall dataset summary
SELECT COUNT(*) AS TotalOrders,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue,
       MIN(TotalPrice) AS MinOrderValue,
       MAX(TotalPrice) AS MaxOrderValue
FROM orders;
