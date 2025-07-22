#Create Table Regions

CREATE TABLE Regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50)
);

#Create Table Sales

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    region_id INT,
    sale_date DATE,
    product VARCHAR(100),
    quantity INT,
    amount DECIMAL(10, 2),
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);

#Regions Table Input

INSERT INTO Regions VALUES
(1, 'North'),
(2, 'South'),
(3, 'East'),
(4, 'West');

#Sales Table Input

INSERT INTO Sales VALUES
(101, 1, '2025-01-15', 'Laptop', 2, 1200.00),
(102, 1, '2025-01-20', 'Monitor', 3, 600.00),
(103, 2, '2025-02-10', 'Laptop', 1, 600.00),
(104, 3, '2025-03-05', 'Keyboard', 5, 250.00),
(105, 4, '2025-03-12', 'Mouse', 10, 150.00),
(106, 1, '2025-04-01', 'Laptop', 1, 600.00),
(107, 2, '2025-04-20', 'Monitor', 2, 400.00),
(108, 3, '2025-05-15', 'Laptop', 1, 600.00),
(109, 4, '2025-06-01', 'Keyboard', 4, 200.00),
(110, 1, '2025-06-18', 'Monitor', 2, 400.00);

#Regions Table Output

select * from Regions;
+-----------+-------------+
| region_id | region_name |
+-----------+-------------+
|         1 | North       |
|         2 | South       |
|         3 | East        |
|         4 | West        |
+-----------+-------------+
#Sales Table Output

select * from Sales;
+---------+-----------+------------+----------+----------+---------+
| sale_id | region_id | sale_date  | product  | quantity | amount  |
+---------+-----------+------------+----------+----------+---------+
|     101 |         1 | 2025-01-15 | Laptop   |        2 | 1200.00 |
|     102 |         1 | 2025-01-20 | Monitor  |        3 |  600.00 |
|     103 |         2 | 2025-02-10 | Laptop   |        1 |  600.00 |
|     104 |         3 | 2025-03-05 | Keyboard |        5 |  250.00 |
|     105 |         4 | 2025-03-12 | Mouse    |       10 |  150.00 |
|     106 |         1 | 2025-04-01 | Laptop   |        1 |  600.00 |
|     107 |         2 | 2025-04-20 | Monitor  |        2 |  400.00 |
|     108 |         3 | 2025-05-15 | Laptop   |        1 |  600.00 |
|     109 |         4 | 2025-06-01 | Keyboard |        4 |  200.00 |
|     110 |         1 | 2025-06-18 | Monitor  |        2 |  400.00 |
+---------+-----------+------------+----------+----------+---------+

# CTE: Monthly Sales by Region

WITH MonthlySales AS (
    SELECT 
        r.region_name,
        DATE_FORMAT(s.sale_date, '%Y-%m-01') AS sale_month,
        SUM(s.amount) AS total_sales
    FROM Sales s
    JOIN Regions r ON s.region_id = r.region_id
    GROUP BY r.region_name, sale_month
)
SELECT * FROM MonthlySales;

# Output

+-------------+------------+-------------+
| region_name | sale_month | total_sales |
+-------------+------------+-------------+
| North       | 2025-01-01 |     1800.00 |
| North       | 2025-04-01 |      600.00 |
| North       | 2025-06-01 |      400.00 |
| South       | 2025-02-01 |      600.00 |
| South       | 2025-04-01 |      400.00 |
| East        | 2025-03-01 |      250.00 |
| East        | 2025-05-01 |      600.00 |
| West        | 2025-03-01 |      150.00 |
| West        | 2025-06-01 |      200.00 |
+-------------+------------+-------------+


#Window Function: Running Total by Region

WITH MonthlySales AS (
    SELECT 
        r.region_name,
        DATE_FORMAT(s.sale_date, '%Y-%m-01') AS sale_month,
        SUM(s.amount) AS total_sales
    FROM Sales s
    JOIN Regions r ON s.region_id = r.region_id
    GROUP BY r.region_name, DATE_FORMAT(s.sale_date, '%Y-%m-01')
),
SalesWithRunningTotal AS (
    SELECT 
        region_name,
        sale_month,
        total_sales,
        SUM(total_sales) OVER (PARTITION BY region_name ORDER BY sale_month) AS running_total
    FROM MonthlySales
)
SELECT * FROM SalesWithRunningTotal;

#Output

+-------------+------------+-------------+---------------+
| region_name | sale_month | total_sales | running_total |
+-------------+------------+-------------+---------------+
| East        | 2025-03-01 |      250.00 |        250.00 |
| East        | 2025-05-01 |      600.00 |        850.00 |
| North       | 2025-01-01 |     1800.00 |       1800.00 |
| North       | 2025-04-01 |      600.00 |       2400.00 |
| North       | 2025-06-01 |      400.00 |       2800.00 |
| South       | 2025-02-01 |      600.00 |        600.00 |
| South       | 2025-04-01 |      400.00 |       1000.00 |
| West        | 2025-03-01 |      150.00 |        150.00 |
| West        | 2025-06-01 |      200.00 |        350.00 |
+-------------+------------+-------------+---------------+


#Subquery: Compare with Average Sales per Region

WITH MonthlySales AS (
    SELECT 
        r.region_name,
         DATE_FORMAT(s.sale_date, '%Y-%m-01') AS sale_month,
        SUM(s.amount) AS total_sales
    FROM Sales s
    JOIN Regions r ON s.region_id = r.region_id
    GROUP BY r.region_name,  DATE_FORMAT(s.sale_date, '%Y-%m-01')
),
SalesWithRunningTotal AS (
    SELECT 
        region_name,
        sale_month,
        total_sales,
        SUM(total_sales) OVER (PARTITION BY region_name ORDER BY sale_month) AS running_total
    FROM MonthlySales
)
SELECT 
    swrt.region_name,
    swrt.sale_month,
    swrt.total_sales,
    swrt.running_total,
    (SELECT AVG(total_sales) 
     FROM MonthlySales ms 
     WHERE ms.region_name = swrt.region_name) AS avg_sales_per_region
FROM SalesWithRunningTotal swrt
ORDER BY swrt.region_name, swrt.sale_month;


#Output

+-------------+------------+-------------+---------------+----------------------+
| region_name | sale_month | total_sales | running_total | avg_sales_per_region |
+-------------+------------+-------------+---------------+----------------------+
| East        | 2025-03-01 |      250.00 |        250.00 |           425.000000 |
| East        | 2025-05-01 |      600.00 |        850.00 |           425.000000 |
| North       | 2025-01-01 |     1800.00 |       1800.00 |           933.333333 |
| North       | 2025-04-01 |      600.00 |       2400.00 |           933.333333 |
| North       | 2025-06-01 |      400.00 |       2800.00 |           933.333333 |
| South       | 2025-02-01 |      600.00 |        600.00 |           500.000000 |
| South       | 2025-04-01 |      400.00 |       1000.00 |           500.000000 |
| West        | 2025-03-01 |      150.00 |        150.00 |           175.000000 |
| West        | 2025-06-01 |      200.00 |        350.00 |           175.000000 |
+-------------+------------+-------------+---------------+----------------------+
