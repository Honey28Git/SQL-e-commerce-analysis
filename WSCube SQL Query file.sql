create database ecommerce;
USE ecommerce;
SHOW VARIABLES LIKE 'secure_file_priv';


CREATE TABLE customers (
    customer_id VARCHAR(255) NOT NULL,
    customer_unique_id VARCHAR(255) NOT NULL,
    customer_zip_code_prefix INT NOT NULL,
    customer_city VARCHAR(255) NOT NULL,
    customer_state VARCHAR(255) NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE orders (
    order_id VARCHAR(255) NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    order_status VARCHAR(255) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(255) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    seller_id VARCHAR(255) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price FLOAT NOT NULL,
    freight_value FLOAT NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT NOT NULL,
    geolocation_lat FLOAT NOT NULL,
    geolocation_lng FLOAT NOT NULL,
    geolocation_city VARCHAR(255) NOT NULL,
    geolocation_state VARCHAR(255) NOT NULL
);


CREATE TABLE payments (
    order_id VARCHAR(255) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(255) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value FLOAT NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE products (
    product_id VARCHAR(255) NOT NULL,
    product_category VARCHAR(255),
    product_name_length FLOAT NOT NULL,
    product_description_length FLOAT NOT NULL,
    product_photos_qty FLOAT NOT NULL,
    product_weight_g FLOAT NOT NULL,
    product_length_cm FLOAT NOT NULL,
    product_height_cm FLOAT NOT NULL,
    product_width_cm FLOAT NOT NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE sellers (
    seller_id VARCHAR(255) NOT NULL,
    seller_zip_code_prefix INT NOT NULL,
    seller_city VARCHAR(255) NOT NULL,
    seller_state VARCHAR(255) NOT NULL,
    PRIMARY KEY (seller_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;  -- Skips header row, remove if no header


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_geolocation.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/corrected_sellers.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from customers;
select * from geolocation;
select * from order_items;
select * from orders;
select * from payments;
select * from products;
select * from sellers;



