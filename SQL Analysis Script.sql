/* For the purpose of our analysis and as detailed in the paper, we will assume healthy products to fall under the following dietary preferences:
lowsodium, lowfat, wholefoods or sugarconscious. Further, considering the benchmark set by FDA of 400 calories as high intake, we will assume calorie 
intake per serving of <= 300 to be healthy. 
 In essence, all products falling under EITHER of the dietary preferences mentioned above AND within the calorie limits defined above will be 
 considered to be healthy.
 As defined in our paper, products costing over $3.85 or 385 cents on an average are considered to be costly. */
 
 /* Assumptions made for the analysis:
 1. Products with Price and serving size as 0 have not been considered since they will not impact our analysis.
 2. The data across categories is not uniform. E.g., the prices for all categories are in cents except for 'Null', 'Beer' and 'Wine' categories.
	The units of measurement for servings are different across categories. Hence, the calculations have been done category-wise to factor in
    calculations/ CASE statements to make data uniform so that they can be easily compared on an overall level. */
 
 -- Selecting the database
 USE fmban_sql_analysis;
 
 /* 
----------------------------------
ANSWERING BUSINESS QUESTION
----------------------------------
*/
 
/* QUERY 1: Finding healthy products based on defined criteria from the database */
SELECT 
    *
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0;
 
 /* QUERY 2: Calculating total number of servings for the products resulting from Query 1 */
 
SELECT 
    *,
    price AS final_price,
    ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize,
            1) AS totalservings
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0
    -- Data for servingsize unit measurement is uniform across following categories
		AND (category = 'Produce'
        OR category = 'Dairy and Eggs'
        OR category = 'Bread Rolls & Bakery'
        OR category = 'Meat'
        OR category = 'Desserts') 
UNION SELECT 
    *,
    price AS final_price,
    ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize,
            1) AS totalservings
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0
        -- Data for servingsize unit measurement is uniform across following categories
		AND (category = 'Prepared Foods'
        OR category = 'Frozen Foods') 
UNION SELECT 
    *,
    price AS final_price,
   -- Standardizing the units of measurement for calculating totalservings considering 1ml = 1g AND 1g = 1 unit
   ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize,
            1) AS totalservings
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0
        AND category = 'Supplements' 
UNION SELECT 
    *,
    price AS final_price,
   -- Since no appropriate units of measurement available for calculating totalservings, it is assumed that data in servingsizeunits is totalservings
   ROUND(servingsizeunits, 1) AS totalservings
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0
        AND category = 'Beverages' 
UNION SELECT 
    *,
    -- Price converted from $ to cents for uniformity
    ROUND(price * 100, 0) AS final_price,
    ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize,
            1) AS totalservings
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0
        AND (category = 'NULL' OR category = 'Beer') 
UNION SELECT 
    *,
	-- Price converted from $ to cents for uniformity
    ROUND(price * 100, 0) AS final_price,
    -- Since no data available for calculating totalservings, for this category, assumed that totalservings = 1
    '1' AS totalservings
FROM
    fmban_data
WHERE
    (lowfat = 1 OR lowsodium = 1
        OR wholefoodsdiet = 1
        OR sugarconscious = 1)
        AND caloriesperserving <= 300
        AND price > 0
        AND servingsize > 0
        AND category = 'Wine';


 /* QUERY 3: Calculating price per serving using total number of servings calculated above using a subquery */


SELECT 
    *,
    ROUND(final_price / totalservings, 0) AS price_per_serving
FROM
    (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Wine') AS totalservingsubquery;


/* QUERY 4: Calculating average price per serving using above calculated fields through a subquery */

SELECT 
    ROUND(AVG(price_per_serving), 0) AS avg_price_per_serving
FROM
    (SELECT 
        *,
            ROUND(final_price / totalservings, 0) AS price_per_serving
    FROM
        (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Wine') AS totalservingsubquery) AS priceperservingsubquery;
/*Based on the result of 331 for the above query, since it is less than our defined "costly" average of 385, it can be concluded that
healthier foods in general across all categories are not costly. */

/* QUERY 5: Calculating average price per serving healthy foods category wise */

SELECT 
    (CASE
        WHEN category = 'NULL' THEN 'Miscellaneous'
        ELSE category
    END) AS category_name,
    ROUND(AVG(price_per_serving), 0) AS avg_price_per_serving,
    (CASE
        WHEN ROUND(AVG(price_per_serving), 0) <= 385 THEN 'Inexpensive'
        ELSE 'Expensive'
    END) AS costly_or_not
FROM
    (SELECT 
        *,
            ROUND(final_price / totalservings, 0) AS price_per_serving
    FROM
        (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Wine') AS totalservingsubquery) AS priceperservingsubquery
GROUP BY category_name;



/* QUERY 6: Finding correlation between caloriesperserving and priceperserving to establish statistical significance.
The formula for Pearson's correlation coefficient is covariance of two variables divided by the product of their standard deviations */

-- First let us define some variables for inputting into our formula
SELECT 
    @avgcalories:=AVG(caloriesperserving),
    @avgprice:=AVG(price_per_serving),
    @divisor:=STDDEV_SAMP(caloriesperserving) * STDDEV_SAMP(price_per_serving)
FROM
    (SELECT 
        *,
            ROUND(final_price / totalservings, 0) AS price_per_serving
    FROM
        (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        category = 'Wine') AS totalservingsubquery) AS priceperservingsubquery
;


-- Now let us replace the defined variables in our formula for correlation
SELECT 
    ROUND((SUM((caloriesperserving - @avgcalories) * (price_per_serving - @avgprice)) / ((COUNT(caloriesperserving) - 1) * @divisor)),
            2) AS corr_coeff
FROM
    (SELECT 
        *,
            ROUND(final_price / totalservings, 0) AS price_per_serving
    FROM
        (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        category = 'Wine') AS totalservingsubquery) AS priceperservingsubquery
;


/* 
----------------------------------
ACTIONABLE INSIGHTS
----------------------------------
*/

 -- Selecting the database
 USE fmban_sql_analysis;

/* INSIGHT-1 : INCREASE PRODUCTION AND SALE OF FROZEN FRUITS AND VEGGIES- SAME NUTRITIONAL CONTENT */
 
/* QUERY 1: Finding average price per serving of fresh fruits and veggies */

SELECT 
    ROUND(AVG(price_per_serving), 0) AS fresh_avg_price_per_serving
FROM
    (SELECT 
        *,
            ROUND(final_price / totalservings, 0) AS price_per_serving
    FROM
        (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Wine') AS totalservingsubquery) AS priceperservingsubquery
WHERE
    subcategory = 'Fresh Vegetables' OR 'Fresh Fruits';
    
 
/* QUERY 2: Finding average price per serving of frozen fruits and veggies */

SELECT 
    ROUND(AVG(price_per_serving), 0) AS frozen_avg_price_per_serving
FROM
    (SELECT 
        *,
            ROUND(final_price / totalservings, 0) AS price_per_serving
    FROM
        (SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Produce'
            OR category = 'Dairy and Eggs'
            OR category = 'Bread Rolls & Bakery'
            OR category = 'Meat'
            OR category = 'Desserts') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
                ELSE totalsecondarysize * 0.035274
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'Prepared Foods'
            OR category = 'Frozen Foods') UNION SELECT 
        *,
            price AS final_price,
            ROUND((CASE
                WHEN
                    (servingsizeunits = totalsizeunits)
                        OR (servingsizeunits = 'ml'
                        AND totalsizeunits = 'g'
                        OR totalsizeunits = 'unit')
                THEN
                    totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Supplements' UNION SELECT 
        *,
            price AS final_price,
            ROUND(servingsizeunits, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Beverages' UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            ROUND((CASE
                WHEN servingsizeunits = totalsizeunits THEN totalsize
                WHEN servingsizeunits = secondarysizeunits THEN totalsecondarysize
            END) / servingsize, 1) AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND (category = 'NULL' OR category = 'Beer') UNION SELECT 
        *,
            ROUND(price * 100, 0) AS final_price,
            '1' AS totalservings
    FROM
        fmban_data
    WHERE
        (lowfat = 1 OR lowsodium = 1
            OR wholefoodsdiet = 1
            OR sugarconscious = 1)
            AND caloriesperserving <= 300
            AND price > 0
            AND servingsize > 0
            AND category = 'Wine') AS totalservingsubquery) AS priceperservingsubquery
WHERE
    subcategory = 'Frozen Fruits & Vegetables';
    
    
/* INSIGHT-2 : COMPARING VEGAN VS MEAT PRODUCTS BASED ON MAJOR DIET PREFERENCE OF AMERICANS */
 
/* QUERY 3: Finding the proportion of vegan products to total products on offer */

SELECT 
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    fmban_data) * 100,
            2) AS vegan_products_proportion
FROM
    fmban_data
WHERE
    vegan = 1
        AND category NOT IN ('Beer' , 'Wine', 'Beverages')
        AND subcategory != 'Meat alternatives';

/* QUERY 4: Finding the proportion of meat products to total products on offer */

SELECT 
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    fmban_data) * 100,
            2) AS meat_products_proportion
FROM
    fmban_data
WHERE
    category = 'Meat'
        AND subcategory != 'Meat alternatives';
        

/* INSIGHT-3 : INCREASE PRODUCTION AND SALE OF BOTTLED WATER SINCE IT WAS THE MOST CONSUMED BEVERAGE IN USA */
 
/* QUERY 5: Finding the proportion of  vegan products to total products on offer */

SELECT 
    subcategory, ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    fmban_data
                    WHERE category = 'Beverages') * 100,
            2) AS proportion
FROM
    fmban_data
WHERE
     category = 'Beverages'
     GROUP BY subcategory;
        
    
    
/* ------------------------------------------------------------------- */