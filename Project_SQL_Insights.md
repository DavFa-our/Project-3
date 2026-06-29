# Project Order Data — SQL Insights

**Dataset:** `orders` table, loaded from the *CLEANED DATA* sheet — 1,200 orders, Jan 1 2023 – Jun 30 2025
**Tool:** SQLite (standard ANSI SQL — portable to MySQL/PostgreSQL/SQL Server with minor syntax tweaks)

Schema:
```sql
CREATE TABLE orders (
    OrderID TEXT, Date TEXT, CustomerID TEXT, Product TEXT,
    Quantity INTEGER, UnitPrice REAL, TotalPrice REAL,
    ShippingAddress TEXT, PaymentMethod TEXT, OrderStatus TEXT,
    TrackingNumber TEXT, ItemsInCart INTEGER, CouponCode TEXT,
    ReferralSource TEXT
);
```

---

## 1. Top 10 highest-value orders
*Demonstrates: `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`*

```sql
SELECT OrderID, Date, Product, Quantity, UnitPrice, TotalPrice, OrderStatus
FROM orders
WHERE OrderStatus != 'Cancelled'
ORDER BY TotalPrice DESC
LIMIT 10;
```

| OrderID | Date | Product | Qty | Unit Price | Total Price | Status |
|---|---|---|---|---|---|---|
| ORD200789 | 2023-08-17 | Tablet | 5 | 691.28 | 3456.40 | Delivered |
| ORD201122 | 2023-06-07 | Monitor | 5 | 678.19 | 3390.95 | Returned |
| ORD200632 | 2023-05-02 | Laptop | 5 | 678.16 | 3390.80 | Delivered |
| ORD200107 | 2023-03-27 | Printer | 5 | 670.75 | 3353.75 | Shipped |
| ORD200326 | 2024-07-01 | Laptop | 5 | 670.48 | 3352.40 | Returned |
| ORD201065 | 2023-10-30 | Printer | 5 | 666.80 | 3334.00 | Delivered |
| ORD201031 | 2023-02-28 | Phone | 5 | 664.51 | 3322.55 | Pending |
| ORD200463 | 2023-05-26 | Laptop | 5 | 662.78 | 3313.90 | Shipped |
| ORD200361 | 2024-06-29 | Printer | 5 | 659.85 | 3299.25 | Delivered |
| ORD200367 | 2024-04-25 | Laptop | 5 | 658.77 | 3293.85 | Pending |

**Insight:** every top-10 order is a 5-unit purchase of a high-unit-price item — order value is driven almost entirely by quantity × price combinations, not by any single "premium" product.

---

## 2. High-value Laptop orders paid by Credit Card
*Demonstrates: `WHERE` with multiple `AND` conditions*

```sql
SELECT OrderID, Date, CustomerID, Quantity, UnitPrice, TotalPrice
FROM orders
WHERE Product = 'Laptop'
  AND PaymentMethod = 'Credit Card'
  AND TotalPrice > 1000
ORDER BY TotalPrice DESC;
```

11 rows returned, ranging from $1,040.85 to $3,137.15. Full result set available in the companion workbook.

---

## 3. Revenue, order count, and average order value by Product
*Demonstrates: `GROUP BY`, `COUNT`, `SUM`, `AVG`*

```sql
SELECT Product,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY Product
ORDER BY TotalRevenue DESC;
```

| Product | Order Count | Total Revenue | Avg Order Value |
|---|---|---|---|
| Chair | 178 | $195,620.11 | $1,098.99 |
| Printer | 181 | $195,612.61 | $1,080.73 |
| Laptop | 173 | $192,126.56 | $1,110.56 |
| Tablet | 179 | $186,568.95 | $1,042.28 |
| Monitor | 163 | $175,651.41 | $1,077.62 |
| Desk | 170 | $167,459.93 | $985.06 |
| Phone | 156 | $151,722.39 | $972.58 |

**Insight:** revenue is nearly evenly split across the 7 products (12-14% each) — no single product dominates. Laptop has the highest average order value despite a mid-range order count.

---

## 4. Order count and revenue by Order Status
*Demonstrates: `GROUP BY`, `COUNT`, `SUM`, `AVG`*

```sql
SELECT OrderStatus,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY OrderStatus
ORDER BY OrderCount DESC;
```

| Order Status | Order Count | Total Revenue | Avg Order Value |
|---|---|---|---|
| Cancelled | 250 | $276,396.21 | $1,105.58 |
| Returned | 247 | $243,277.70 | $984.93 |
| Pending | 237 | $256,328.15 | $1,081.55 |
| Shipped | 235 | $246,159.58 | $1,047.49 |
| Delivered | 231 | $242,600.32 | $1,050.22 |

**Insight:** Cancelled + Returned orders account for 497 of 1,200 orders (41.4%) and **$519,673.91** in order value — worth a closer operational look, especially since Cancelled orders skew toward higher-than-average value ($1,105.58).

---

## 5. Payment methods with above-average order value
*Demonstrates: `GROUP BY`, `HAVING`, subquery*

```sql
SELECT PaymentMethod,
       COUNT(*) AS OrderCount,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY PaymentMethod
HAVING AVG(TotalPrice) > (SELECT AVG(TotalPrice) FROM orders)
ORDER BY AvgOrderValue DESC;
```

| Payment Method | Order Count | Avg Order Value |
|---|---|---|
| Credit Card | 234 | $1,127.55 |
| Gift Card | 230 | $1,070.97 |
| Cash | 246 | $1,056.04 |

Overall average is $1,053.97 — Online and Debit Card orders fall below this and are filtered out by the `HAVING` clause.

---

## 6. Orders and revenue by Referral Source
*Demonstrates: `GROUP BY`, `SUM`, `AVG`, `ORDER BY`*

```sql
SELECT ReferralSource,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY ReferralSource
ORDER BY TotalRevenue DESC;
```

| Referral Source | Order Count | Total Revenue | Avg Order Value |
|---|---|---|---|
| Instagram | 259 | $275,285.45 | $1,062.88 |
| Email | 250 | $261,808.55 | $1,047.23 |
| Google | 241 | $250,441.48 | $1,039.18 |
| Facebook | 228 | $250,410.90 | $1,098.29 |
| Referral | 222 | $226,815.58 | $1,021.69 |

**Insight:** Instagram drives the most orders and revenue; Facebook has fewer orders but the highest average order value among channels.

---

## 7. Orders placed in June 2024
*Demonstrates: `WHERE` with a date range, `ORDER BY`*

```sql
SELECT OrderID, Date, Product, TotalPrice, OrderStatus
FROM orders
WHERE Date >= '2024-06-01' AND Date < '2024-07-01'
ORDER BY Date ASC;
```

53 orders returned (the busiest single month in the dataset), totaling **$68,068.54** in revenue.

---

## 8. Monthly order volume and revenue trend
*Demonstrates: `GROUP BY` on a derived column, `SUM`, `AVG`*

```sql
SELECT substr(Date, 1, 7) AS Month,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY Month
ORDER BY Month ASC;
```

30 months returned (Jan 2023 – Jun 2024). Order counts range from **27** (Jan 2025) to **53** (Jun 2024), with no sustained upward or downward trend. Note 2025 only has 6 months of data, so its lower total order count is a partial-year artifact, not a real decline.

---

## 9. Coupon usage analysis
*Demonstrates: `GROUP BY`, `COALESCE` for NULL handling, aggregations*

```sql
SELECT COALESCE(CouponCode, 'No Coupon') AS Coupon,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY Coupon
ORDER BY OrderCount DESC;
```

| Coupon | Order Count | Total Revenue | Avg Order Value |
|---|---|---|---|
| FREESHIP | 313 | $335,036.99 | $1,070.41 |
| No Coupon | 309 | $322,401.41 | $1,043.37 |
| WINTER15 | 292 | $302,483.54 | $1,035.90 |
| SAVE10 | 286 | $304,840.02 | $1,065.87 |

**Insight:** coupon usage is roughly even across the three codes and "no coupon" — none of the codes appears to be cannibalizing or significantly inflating average order value.

---

## 10. Top 10 customers by total spend
*Demonstrates: `GROUP BY`, `SUM`, `ORDER BY`, `LIMIT`*

```sql
SELECT CustomerID,
       COUNT(*) AS OrderCount,
       SUM(TotalPrice) AS TotalSpent,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM orders
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;
```

| Customer ID | Order Count | Total Spent | Avg Order Value |
|---|---|---|---|
| C38840 | 2 | $5,723.23 | $2,861.61 |
| C57276 | 1 | $3,456.40 | $3,456.40 |
| C67260 | 1 | $3,390.80 | $3,390.80 |
| C13877 | 1 | $3,384.90 | $3,384.90 |
| C18404 | 1 | $3,370.20 | $3,370.20 |
| C16775 | 1 | $3,353.75 | $3,353.75 |
| C65986 | 1 | $3,352.40 | $3,352.40 |
| C47778 | 1 | $3,334.00 | $3,334.00 |
| C59183 | 1 | $3,322.55 | $3,322.55 |
| C25276 | 1 | $3,313.90 | $3,313.90 |

**Insight:** of 1,189 unique customers, only 11 placed more than one order — this is overwhelmingly a one-time-purchase customer base. The single repeat customer (C38840) is the only one in the top 10 with 2 orders.

---

## 11. Bulk orders (Quantity ≥ 4) by Product
*Demonstrates: `WHERE`, `GROUP BY`, aggregations together*

```sql
SELECT Product,
       COUNT(*) AS BulkOrderCount,
       SUM(TotalPrice) AS BulkRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgBulkOrderValue
FROM orders
WHERE Quantity >= 4
GROUP BY Product
ORDER BY BulkRevenue DESC;
```

| Product | Bulk Order Count | Bulk Revenue | Avg Bulk Order Value |
|---|---|---|---|
| Laptop | 81 | $129,283.29 | $1,596.09 |
| Printer | 72 | $117,559.40 | $1,632.77 |
| Chair | 76 | $117,199.38 | $1,542.10 |
| Desk | 69 | $101,198.97 | $1,466.65 |
| Monitor | 62 | $101,142.41 | $1,631.33 |
| Tablet | 58 | $100,970.44 | $1,740.87 |
| Phone | 50 | $80,673.92 | $1,613.48 |

**Insight:** bulk orders (4-5 units) make up 468 of 1,200 orders (39%) but generate **$748,027.81** — 59% of total revenue. Tablet has the highest average bulk order value.

---

## 12. Cancelled or Returned orders by Product
*Demonstrates: `WHERE ... IN`, `GROUP BY` on two columns*

```sql
SELECT Product, OrderStatus,
       COUNT(*) AS Count,
       SUM(TotalPrice) AS LostRevenue
FROM orders
WHERE OrderStatus IN ('Cancelled', 'Returned')
GROUP BY Product, OrderStatus
ORDER BY LostRevenue DESC;
```

Top rows:

| Product | Status | Count | Lost Revenue |
|---|---|---|---|
| Chair | Cancelled | 45 | $48,660.98 |
| Laptop | Cancelled | 35 | $43,761.72 |
| Tablet | Returned | 43 | $42,525.86 |
| Tablet | Cancelled | 34 | $40,629.96 |
| Monitor | Returned | 36 | $40,524.60 |

**Insight:** Chair has the single largest cancellation loss; Tablet has the highest combined cancel+return exposure across both statuses ($83,155.82).

---

## 13. Overall dataset summary
*Demonstrates: multiple aggregations in one query*

```sql
SELECT COUNT(*) AS TotalOrders,
       SUM(TotalPrice) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue,
       MIN(TotalPrice) AS MinOrderValue,
       MAX(TotalPrice) AS MaxOrderValue
FROM orders;
```

| Total Orders | Total Revenue | Avg Order Value | Min | Max |
|---|---|---|---|---|
| 1,200 | $1,264,761.96 | $1,053.97 | $11.39 | $3,456.40 |

---

## Summary of Key Findings

- **Revenue is evenly distributed across products** — Chair and Printer lead (~$195.6K each), Phone trails (~$151.7K), but the spread is narrow (12-14% share each).
- **Bulk orders (qty ≥ 4) drive a disproportionate share of revenue**: 39% of orders generate 59% of total revenue.
- **Cancelled + Returned orders are a significant share (41.4%)** of all orders and over $519K in order value — the single biggest area worth investigating operationally.
- **Credit Card customers spend the most on average** ($1,127.55), the only payment method meaningfully above the overall average.
- **Instagram and Email are the top referral channels by volume and revenue**, though Facebook converts to a higher average order value.
- **This is almost entirely a one-time-purchase customer base** — only 11 of 1,189 customers ordered more than once.
- **No meaningful seasonal or growth trend** in monthly order volume across the 2.5-year window (excluding the partial 2025 year).
