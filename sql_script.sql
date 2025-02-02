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

/*clear table data before load data again*/
TRUNCATE TABLE dates;

LOAD DATA INFILE 'DATA_DATE_CRR.CSV' INTO TABLE dates
FIELDS TERMINATED BY ','
IGNORE 1 LINES;


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

/*Total Revenue */
select sum(orders.Sales) as totalRevenue
from orders;

/*Top States (by sales)*/
select customers.States, sum(orders.sales)
from orders inner join customers on 
orders.OrderID = customers.OrderID
group by customers.States
order by sum(orders.Sales) desc;











































