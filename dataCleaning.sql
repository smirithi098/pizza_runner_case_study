USE pizza_db;

-- #####################CUSTOMER_ORDERS TABLE#######################

-- Set 0 for rows where NULL or NA - exclusions
UPDATE customer_orders SET exclusions = 0 WHERE exclusions = '' or exclusions = 'null';

-- Set 0 for rows where NULL or NA - extras
UPDATE customer_orders SET extras = 0 WHERE extras = 'null' or extras = '' or extras IS NULL;

-- Split the multi value rows to individual rows and create a new table 
SELECT * 
INTO new_customer_orders 
FROM
	(SELECT *,
		TRIM(LEFT(exclusions, 1)) as exclusion,
		TRIM(LEFT(extras, 1)) as extra
	FROM customer_orders
	UNION
	SELECT *,
		TRIM(RIGHT(exclusions, 1)) as exclusion,
		TRIM(RIGHT(extras, 1)) as extra
	FROM customer_orders
	) AS temp_table;

-- Set the data type of extras and exclusions as INTEGER
ALTER TABLE new_customer_orders ALTER COLUMN exclusion INTEGER;
ALTER TABLE new_customer_orders ALTER COLUMN extra INTEGER;

-- Drop the originl `exclusions` and `extras` column from new table
ALTER TABLE new_customer_orders DROP COLUMN exclusions;
ALTER TABLE new_customer_orders DROP COLUMN extras;

-- #########################RUNNER_ORDERS TABLE########################

-- Delete order records which were cancelled (customer/restaurant)
DELETE FROM runner_orders WHERE cancellation LIKE '%Cancellation';

-- Query to check the data types of table columns
SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'pizza_recipes';

-- Remove string part from `distance` column
UPDATE runner_orders 
	SET distance = IIF(CHARINDEX('k', distance) = 0, distance, TRIM(SUBSTRING(distance, 1, CHARINDEX('k', distance)-1)));
    
-- Remove string part from `duration` column
UPDATE runner_orders
	SET duration = IIF(CHARINDEX('m', duration) = 0, duration, TRIM(SUBSTRING(duration, 1, CHARINDEX('m', duration)-1)));

-- Update the `cancellation` column with meaningful string for orders not cancelled
UPDATE runner_orders
	SET cancellation = 'Not cancelled' WHERE cancellation = '' or cancellation IS NULL or cancellation = 'null';
    
-- Set data type of `distance` column as FLOAT
ALTER TABLE runner_orders ALTER COLUMN distance FLOAT;

-- Set data type of `duration` column as INTEGER
ALTER TABLE runner_orders ALTER COLUMN duration INTEGER;

-- #####################PIZZA_RECIPES TABLE#######################

-- Split the toppings column into separate rows for each pizza_id
SELECT *
INTO new_pizza_recipes
FROM
	(SELECT pizza_id, TRIM(value) AS topping
	FROM pizza_recipes
	CROSS APPLY STRING_SPLIT(CONVERT(VARCHAR(MAX), toppings), ',')
	) AS new_table;
