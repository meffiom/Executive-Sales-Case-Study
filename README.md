## Project Overview
This project analyzes two years (2023–2024) of transactional sales data across multiple regions, customer segments, and product categories. The deliverables include an executive Tableau dashboard and SQL queries answering five key business questions.

---

## Repository Contents

| File | Description |
|------|-------------|
| `Executive_Dashboard.twbx` | Tableau packaged workbook — executive summary dashboard |
| `Queries Case Study.sql` | SQL queries for all 5 business questions |
| `README.md` | This file — setup instructions and findings |

---

## Dashboard Preview
Open `Executive_Dashboard.twbx` in Tableau Public (free) to view the interactive dashboard.

**Dashboard includes:**
- 5 KPI Cards: Total Revenue, Quantity, Avg Selling Price, Revenue After Discount, YoY Growth
- Business Insight Callouts highlighting key findings
- Revenue Trend Over Time (2023 vs 2024)
- Revenue by Category with % contribution
- Revenue by Customer Segment
- Revenue by Region
- Interactive filters: Year, Segment, Region, Category

---

## Setup Instructions

### To View the Dashboard
1. Download [Tableau Public](https://public.tableau.com/en-us/s/download) — free
2. Open `Sales_Dashboard.twbx` directly in Tableau Public
3. No additional setup needed — data is packaged inside the .twbx file

### To Run the SQL Queries

#### Option A — SQLite via DB Browser (Easiest — Recommended)
**Required:** [DB Browser for SQLite](https://sqlitebrowser.org) — free, no account needed

**Steps:**
1. Open DB Browser for SQLite
2. Click **File → New Database** → save as `sales_assignment.db`
3. Import each CSV file:
   - **File → Import → Table from CSV file**
   - Import `Sales.csv` → table name: `Sales`
   - Import `Customers.csv` → table name: `Customers`
   - Import `Products.csv` → table name: `Products`
   - Import `Calendar.csv` → table name: `Calendar`
4. Click **Execute SQL** tab
5. Paste queries from `queries.sql` one at a time and press **F5**

**Verify import was successful:**
- Sales → 5,000 rows
- Customers → 100 rows
- Products → 45 rows
- Calendar → 731 rows

#### Option B — MySQL
**Required:** [MySQL Community Server](https://dev.mysql.com/downloads/) — free

**Steps:**
1. Install MySQL and open MySQL Workbench
2. Create a new database:
```sql
CREATE DATABASE sales_db;
USE sales_db;
```
3. Import CSV files using MySQL Workbench import wizard
4. Note: Replace `strftime('%Y', OrderDate)` with `YEAR(OrderDate)` in all queries

#### Option C — PostgreSQL
**Required:** [PostgreSQL](https://www.postgresql.org/download/) — free

**Steps:**
1. Create database: `CREATE DATABASE sales_db;`
2. Import CSVs using pgAdmin import tool
3. Note: Replace `strftime('%Y', OrderDate)` with `EXTRACT(YEAR FROM OrderDate)` in all queries

---

## Data Model — Star Schema

```
                   ┌──────────────┐
                   │  Customers   │
                   │  (100 rows)  │
                   └──────┬───────┘
                          │ CustomerID
             ┌────────────▼─────────────┐
┌──────────┐ │          Sales            │ ┌─────────────┐
│ Products │─│       (5,000 rows)        │─│  Calendar   │
│ (45 rows)│ │     Fact Table            │ │ (731 rows)  │
└──────────┘ └───────────────────────────┘ └─────────────┘
  ProductID        OrderDate = Date
```

- **Sales** — fact table: OrderID, OrderDate, CustomerID, ProductID, Region, Quantity, UnitPrice, Discount
- **Customers** — dimension: CustomerID, CustomerName, Segment, SignupDate
- **Products** — dimension: ProductID, ProductName, Category, Subcategory
- **Calendar** — date dimension: Date, Year, Month, MonthName, Quarter

---

## Key Findings

| Metric | Value |
|--------|-------|
| Total Revenue (2023–2024) | $24,970K |
| Total Units Sold | 24,843 |
| Average Selling Price | $1,005.13 |
| Revenue After Discounts | $23,843K |
| Discount Impact | -$1,127K lost to discounts |
| YoY Revenue Growth | +2.1% |

### Business Insights

1. **Stable but slow growth** — Revenue grew 2.1% from $12.35M (2023) to $12.62M (2024)
2. **Office Supplies leads** — 33.8% of total revenue, closely followed by Furniture (33.6%) and Technology (32.6%)
3. **Enterprise overtook SMB** — Enterprise led in 2024 ($4.62M) after SMB led in 2023 ($4.43M)
4. **Strong Q4 seasonality** — December 2024 peaked at $1.33M; Feb and Sep are the weakest months
5. **Discounting largely ineffective** — $1.13M lost to discounts; only Paper subcategory shows higher volume when discounted
6. **Well-diversified business** — All regions within $506K of each other; no single point of failure

### SQL Query Results Summary

| Query | Finding |
|-------|---------|
| Top segment per year | Enterprise led 2023; Enterprise led 2024 |
| Subcategory unit growth | Paper +200 units, Tables +185, Labels +167 |
| MoM by region (2024) | West surged in Dec (+$80K MoM) |
| Discount effectiveness | Only Paper benefits from discounting |
| Customer fix | Customer_1096 corrected from SMB → Enterprise |
