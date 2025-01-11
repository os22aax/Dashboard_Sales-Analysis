/*Create a Database*/
CREATE DATABASE IF NOT EXISTS pro_sales;

/*Use the database for codeings*/
USE pro_sales;

/*Create tables*/
CREATE TABLE orders(
OrderID VARCHAR(255),
ShipMode VARCHAR(255),
CustomerID VARCHAR(255),
ProductsID VARCHAR(255),
Sales DECIMAL(10,2),
Quantity INT,
Discount DECIMAL(5,2),
DiscountValue DECIMAL(10,2),
Profit DECIMAL(10,2),
COGS DECIMAL(10,2)

);
SELECT * FROM orders;
SELECT COUNT(*) FROM orders;

/*Check the duplicate entries from orderid*/
SELECT orderid, COUNT(*) AS duplicate_count
FROM orders
GROUP BY orderid
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

/*check the duplicate entries on all attributes*/
SELECT COUNT(*) AS duplicate_count_orders
FROM orders
GROUP BY orderid, shipmode, customerid, productsid, sales, quantity, discount, discountvalue, profit, cogs
HAVING COUNT(*) > 1
ORDER BY duplicate_count_orders DESC;

/*display the duplicate rows*/
SELECT *
FROM orders
WHERE (orderid, shipmode, customerid, productsid, sales, quantity, discount, discountvalue, profit, cogs) IN (
    SELECT orderid, shipmode, customerid, productsid, sales, quantity, discount, discountvalue, profit, cogs
    FROM orders
    GROUP BY orderid, shipmode, customerid, productsid, sales, quantity, discount, discountvalue, profit, cogs
    HAVING COUNT(*) > 1
)
ORDER BY orderid;
/*backup the orders table*/
/*CREATE TABLE orders_backup AS SELECT * FROM orders;
/*drop the duplicate entries - when all records are similar
CREATE TABLE temp_orders_x AS
SELECT DISTINCT *
FROM orders;

DROP TABLE orders;

RENAME TABLE temp_orders TO orders; */

DROP TABLE orders;
RENAME TABLE orders_backup TO orders;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) AS duplicate_count_orders
FROM orders
GROUP BY orderid, shipmode, customerid, productsid, sales, quantity, discount, discountvalue, profit, cogs
HAVING COUNT(*) > 1
ORDER BY duplicate_count_orders DESC;


/*Import Data from csv file*/
LOAD DATA INFILE 'DATA_ORDER_CRR.CSV' INTO TABLE orders
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT DISTINCT (orders.CustomerID) FROM orders;
SELECT COUNT(*) FROM orders WHERE orders.CustomerID = 'CG-12520';
SELECT * FROM orders WHERE orders.CustomerID = 'CG-12520';

CREATE TABLE products (
OrderID VARCHAR(255),
ProductID VARCHAR(255),
Category VARCHAR(255),
SubCategory VARCHAR(255),
ProductName TEXT
);

SELECT * FROM products;
SELECT COUNT(*) FROM products;

LOAD DATA INFILE 'DATA_PRODUCTS_CRR.CSV' INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) AS duplicate_count_products
FROM products
GROUP BY orderid, productid, category, subcategory, productname
HAVING COUNT(*) > 1
ORDER BY duplicate_count_products DESC;

SELECT @@secure_file_priv;

CREATE TABLE customers(
OrderID VARCHAR(255),
CustomerID VARCHAR(255),
CustomerName VARCHAR(255),
Segment VARCHAR(255),
Country VARCHAR(255),
City VARCHAR(255),
States VARCHAR(255),
Region VARCHAR(255),
PostalCode VARCHAR(255)
);

LOAD DATA INFILE 'DATA_CUSTOMERS_CRR.CSV' INTO TABLE customers
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

TRUNCATE TABLE customers;
SELECT COUNT(*) FROM customers;

CREATE TABLE dates(
OrderID VARCHAR(255),
OrderDate VARCHAR(255),
ShipDate DATE,
DeliveryDuration INT
);

LOAD DATA INFILE 'DATA_DATE_CRR.CSV' INTO TABLE dates
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

TRUNCATE TABLE dates;
SELECT * FROM dates;
SELECT COUNT(*) FROM dates;

SELECT orderid, 
       COUNT(*) AS duplicate_count
FROM dates
GROUP BY orderid
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT d.orderid, d.orderdata, o.productsid
FROM dates d
JOIN orders o ON d.orderid = o.orderid
WHERE d.orderid IN (
    SELECT orderid
    FROM dates
    GROUP BY orderid
    HAVING COUNT(*) > 1
)
ORDER BY d.orderid;


/*check distinct states and count*/
SELECT DISTINCT States FROM Customers;
SELECT COUNT(DISTINCT States) FROM Customers;

/*check distinct Customer names and count*/
SELECT DISTINCT CustomerName FROM Customers;

/*best selling products (by earning)*/
select products.productID, sum(orders.Sales) from orders
inner join products on orders.OrderID = products.OrderID
group by products.ProductID
order by sum(orders.Sales) desc;

/*Top Customers (by sales)*/
select customers.CustomerID, Customers.CustomerName, sum(orders.sales)
from orders inner join customers on 
orders.OrderID = customers.OrderID
group by customers.CustomerID, customers.CustomerName
order by sum(orders.Sales) desc;

/*Total Revenu by year*/
select extract(year from dates.OrderData) as SalesYear,
sum(orders.sales) from orders inner join dates on 
orders.OrderID = dates.OrderID
group by SalesYear
order by sum(orders.Sales) desc;

/*Total Revenue */
select sum(orders.Sales) as totalRevenue
from orders;

/*Top States (by sales)*/
select customers.States, sum(orders.sales)
from orders inner join customers on 
orders.OrderID = customers.OrderID
group by customers.States
order by sum(orders.Sales) desc;

/*Top States (by sales) year 2014*/
SELECT customers.States, SUM(orders.Sales) AS Revenue
FROM orders
INNER JOIN customers ON orders.OrderID = customers.OrderID
INNER JOIN dates ON dates.OrderID = orders.OrderID
WHERE dates.ShipDate BETWEEN '2014-01-01' AND '2014-12-31'
GROUP BY customers.States
ORDER BY Revenue DESC;

/*Top States (by sales) year 2015*/
SELECT customers.States, SUM(orders.Sales) AS Revenue
FROM orders
INNER JOIN customers ON orders.OrderID = customers.OrderID
INNER JOIN dates ON dates.OrderID = orders.OrderID
WHERE dates.ShipDate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY customers.States
ORDER BY Revenue DESC;


SELECT YEAR(dates.OrderData) AS Year, SUM(orders.Sales) AS Revenue
FROM orders
INNER JOIN dates ON orders.OrderID = dates.OrderID
GROUP BY YEAR(dates.OrderData)
ORDER BY Year;
/*2297201.07*/
SELECT SUM(orders.Sales) AS total_revenue
FROM orders;

/*7114085.47*/
SELECT SUM(o.Sales) AS total_revenue
FROM orders o inner join (select distinct * from dates) d  on 
 o.orderid = d.orderid;

select count(orderid) as c, orderid from dates group by orderid order by count(orderid) desc;

select * from dates where orderid = 'CA-2017-100111';

SELECT YEAR(d.orderdata) AS Year, 
       o.orderid, 
       SUM(o.Sales) AS Revenue
FROM orders o
INNER JOIN dates d ON o.orderid = d.orderid
GROUP BY YEAR(d.orderdata), o.orderid
ORDER BY Year;


/*if exists (select orderid from dates where orderid =)
select count(*) c from products where orderid = 'CA-2017-100111'*/

select * from orders;

SELECT SUM(orders.Sales) AS total_revenue_2014
FROM orders
INNER JOIN dates ON orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

ALTER TABLE dates
ADD FirstDayOfMonth DATE;
/*disable safe update mode*/
SET SQL_SAFE_UPDATES = 0;

UPDATE dates
SET FirstDayOfMonth = DATE_FORMAT(OrderData, '%Y-%m-01');

SELECT OrderData, FirstDayOfMonth
FROM dates
LIMIT 10;

/*re-enable the safe update mode*/
/*SET SQL_SAFE_UPDATES = 1;*/

SELECT SUM(orders.Sales) AS total_revenue_2014
FROM orders
INNER JOIN dates ON orders.OrderID = dates.OrderID
WHERE YEAR(dates.FirstDayOfMonth) = 2014;


SELECT orders.OrderID
FROM orders
LEFT JOIN dates ON orders.OrderID = dates.OrderID
WHERE dates.OrderID IS NULL;

SELECT dates.OrderID
FROM dates
LEFT JOIN orders ON dates.OrderID = orders.OrderID
WHERE orders.OrderID IS NULL;


SELECT COUNT(*) AS NumberOfRows
FROM orders
INNER JOIN dates ON orders.OrderID = dates.OrderID
WHERE YEAR(dates.FirstDayOfMonth) = 2015;

SELECT COUNT(*) AS NumberOfRows
FROM orders
INNER JOIN dates ON orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

SELECT COUNT(*) AS NumberOfRows_orders
FROM orders;


SELECT DISTINCT dates.OrderData
FROM orders
INNER JOIN dates ON orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;


SELECT COUNT(*) AS NumberOfRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;


SELECT SUM(aggregated_orders.TotalSales) AS total_revenue_2014
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

SELECT 
    SUM(aggregated_orders.TotalSales) AS total_revenue_2014,
    COUNT(*) AS NumberOfRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

SELECT 
    SUM(aggregated_orders.TotalSales) AS total_revenue_2015,
    COUNT(*) AS NumberOfRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2015;


SELECT 
    SUM(aggregated_orders.TotalSales) AS total_revenue_2014,
    COUNT(*) AS NumberOfRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

SELECT 
    aggregated_orders.OrderID,
    aggregated_orders.TotalSales,
    COUNT(*) AS TotalRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014
GROUP BY aggregated_orders.OrderID
ORDER BY aggregated_orders.TotalSales DESC;


SELECT 
    SUM(aggregated_orders.TotalSales) AS total_revenue_2014,
    COUNT(DISTINCT aggregated_orders.OrderID) AS NumberOfRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

SELECT 
    SUM(DISTINCT aggregated_orders.TotalSales) AS total_revenue_2014,
    COUNT(DISTINCT aggregated_orders.OrderID) AS NumberOfRows
FROM (
    SELECT DISTINCT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;


SELECT 
    SUM(aggregated_orders.TotalSales) AS total_revenue_2014,
    COUNT(*) AS NumberOfRows
FROM (
    SELECT OrderID, SUM(Sales) AS TotalSales
    FROM orders
    GROUP BY OrderID
) AS aggregated_orders
INNER JOIN dates ON aggregated_orders.OrderID = dates.OrderID
WHERE YEAR(dates.OrderData) = 2014;

SELECT * FROM orders WHERE OrderID NOT IN (SELECT OrderID FROM dates);

SELECT o.orderid, 
       p.productid, 
       d.orderdata, 
       o.Sales AS line_revenue 
FROM orders o
JOIN products p ON o.orderid = p.orderid
JOIN dates d ON o.orderid = d.orderid;

SELECT o.orderid, 
       p.productid, 
       COUNT(*) AS duplicate_count
FROM orders o
JOIN products p ON o.orderid = p.orderid
JOIN dates d ON o.orderid = d.orderid
GROUP BY o.orderid, p.productid
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT o.orderid, 
       p.productid, 
       d.orderdata, 
       o.Sales AS line_revenue, 
       COUNT(*) AS duplicate_count
FROM orders o
JOIN products p ON o.orderid = p.orderid
JOIN dates d ON o.orderid = d.orderid
GROUP BY o.orderid, p.productid, d.orderdata, o.Sales
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT o.orderid, 
       p.productid, 
       d.orderdata, 
       o.Sales AS line_revenue, 
       COUNT(*) AS duplicate_count
FROM orders o
JOIN products p ON o.orderid = p.orderid
JOIN dates d ON o.orderid = d.orderid
GROUP BY o.orderid, p.productid, d.orderdata, o.Sales
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


SELECT YEAR(d.orderdata) AS year, 
       SUM(o.Sales) AS total_revenue
FROM orders o
JOIN products p ON o.orderid = p.orderid
JOIN dates d ON o.orderid = d.orderid
GROUP BY YEAR(d.orderdata)
ORDER BY year;

































