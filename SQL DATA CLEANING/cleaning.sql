-- 1. Create a duplicate table structure 
CREATE TABLE sales_data_staging LIKE raw_sales;

-- 2. Populate the staging table with all raw records
INSERT INTO sales_data_staging
SELECT * FROM raw_sales;

-- 3. Verify that the copy was successful
SELECT COUNT(*) FROM sales_data_staging;

-- 4 Removing duplicates 
CREATE TABLE sales_data_staging_clean AS
SELECT 
    transaction_id,
    order_date,
    customer_id,
    customer_name,
    product,
    category,
    quantity,
    unit_price,
    sales_amount,
    city,
    sales_channel,
    order_status
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS row_num
    FROM sales_data_staging
) AS ranked
WHERE row_num = 1;

-- Replace the old table with the clean one
DROP TABLE sales_data_staging;
RENAME TABLE sales_data_staging_clean TO data_staging;

-- 5. Standardizing
-- 5.1 column city
-- cofirming
SELECT DISTINCT city, COUNT(*) AS cnt
FROM data_staging
GROUP BY city
ORDER BY city;

-- Fix the dirty city values
UPDATE data_staging
SET city = 'Nairobi'
WHERE TRIM(city) IN ('nairobi', 'Nairobii');

UPDATE data_staging
SET city = 'Mombasa'
WHERE UPPER(TRIM(city)) = 'MOMBASA';

UPDATE data_staging
SET city = 'Nakuru'
WHERE UPPER(TRIM(city)) = 'NAKURU';

UPDATE data_staging
SET city = 'Kisumu'
WHERE city = 'Kisumu ';

-- Trimming any remaining spaces
UPDATE data_staging
SET city = TRIM(city);

-- 5.2 Column sales_channel
-- cofirming
SELECT DISTINCT sales_channel, COUNT(*) AS cnt
FROM data_staging
GROUP BY sales_channel
ORDER BY sales_channel;

-- fixing dirty sales channel
UPDATE data_staging
SET sales_channel  = 'Store'
WHERE UPPER(TRIM(sales_channel)) = 'STORE';

-- 5.3 Column order_status
-- cofirming
SELECT DISTINCT order_status, COUNT(*) AS cnt
FROM data_staging
GROUP BY order_status
ORDER BY order_status;

-- fixing dirty sales channel column
UPDATE data_staging
SET order_status = 'Completed'
WHERE order_status = 'Complete';

UPDATE data_staging
SET order_status = 'Pending'
WHERE UPPER(TRIM(order_status)) = 'PENDING';

-- Column product
-- confirming
SELECT DISTINCT product, COUNT(*) AS cnt
FROM data_staging
GROUP BY product
ORDER BY product;

-- fixing 
UPDATE data_staging
SET product = 'Keyboard'
WHERE product = 'Keybord';

-- 6. fixing and converting the date column
-- confirming

SELECT DISTINCT order_date
FROM data_staging
ORDER BY order_date;

-- fix 
-- 6.1 Fix MM/DD/YYYY format
UPDATE data_staging
SET order_date = STR_TO_DATE(order_date, '%m/%d/%Y')
WHERE order_date = '03/14/2025';

-- 6.2 Fix DD/MM/YYYY format
UPDATE data_staging
SET order_date = STR_TO_DATE(order_date, '%d/%m/%Y')
WHERE order_date = '15/04/2025';

-- 6.3 Fix YYYY.MM.DD format
UPDATE data_staging
SET order_date = STR_TO_DATE(order_date, '%Y.%m.%d')
WHERE order_date = '2025.05.09';

-- 6.4 Fix YYYY/MM/DD format
UPDATE data_staging
SET order_date = STR_TO_DATE(order_date, '%Y/%m/%d')
WHERE order_date = '2025/09/21';

-- 6.5 Fix "D Mon YYYY" format
UPDATE data_staging
SET order_date = STR_TO_DATE(order_date, '%e %b %Y')
WHERE order_date = '7 Aug 2025';

-- 6.6 Change the column type to DATE
ALTER TABLE data_staging
MODIFY COLUMN order_date DATE;

-- 7. Handling missing values 
SELECT
    SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer_name IS NULL OR TRIM(customer_name) = '' THEN 1 ELSE 0 END) AS missing_customer_name
FROM data_staging;

-- fixing missing_customer_id
UPDATE data_staging
SET customer_id = 'UNKNOWN'
WHERE customer_id IS NULL OR TRIM(customer_id) = '';

-- fixing customer_name 
UPDATE data_staging
SET customer_name = 'Unknown Customer'
WHERE customer_name IS NULL OR TRIM(customer_name) = '';

-- 7. Hnadling logical errors
-- adding correction errors
ALTER TABLE data_staging ADD COLUMN qty_corrected            INT DEFAULT 0;
ALTER TABLE data_staging ADD COLUMN unit_price_corrected     INT DEFAULT 0;
ALTER TABLE data_staging ADD COLUMN sales_amount_corrected   INT DEFAULT 0;
ALTER TABLE data_staging ADD COLUMN is_outlier               INT DEFAULT 0;

-- corrections
-- quantity fixing
UPDATE data_staging SET quantity = 10,    qty_corrected = 1 WHERE transaction_id = 'T0017';
UPDATE  data_staging SET quantity = 2,     qty_corrected = 1 WHERE transaction_id = 'T0040';
UPDATE data_staging SET quantity = 4,     qty_corrected = 1 WHERE transaction_id = 'T0058';

-- unit price fixing
UPDATE data_staging SET unit_price = 179.00, unit_price_corrected = 1 WHERE transaction_id = 'T0067';
UPDATE data_staging SET unit_price = 51.45,  unit_price_corrected = 1 WHERE transaction_id = 'T0099';

-- sales amount fixing
UPDATE data_staging SET sales_amount = 82.50,   sales_amount_corrected = 1 WHERE transaction_id = 'T0110';
UPDATE data_staging SET sales_amount = 563.85,  sales_amount_corrected = 1 WHERE transaction_id = 'T0145';

-- flagging outliers
UPDATE data_staging
SET is_outlier = 1
WHERE quantity >= 100;

-- 8. category correction 
UPDATE data_staging
SET category = 'Electronics'
WHERE transaction_id = 'T0032';

   




