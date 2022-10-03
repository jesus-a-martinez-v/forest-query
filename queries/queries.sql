CREATE OR REPLACE VIEW forestation AS
(
WITH all_area AS (SELECT fa.*,
                         la.total_area_sq_mi * 2.59 AS total_area_sqkm
                  FROM land_area la
                           JOIN
                       forest_area fa ON fa.country_code = la.country_code
                           AND fa.year = la.year
                           AND fa.forest_area_sqkm IS NOT NULL
                           AND la.total_area_sq_mi IS NOT NULL)
SELECT aa.*,
       r.region,
       r.income_group,
       100 * (aa.forest_area_sqkm / aa.total_area_sqkm) AS forest_percent
FROM all_area aa
         JOIN
     regions r ON aa.country_code = r.country_code);

------------------------------------------------------
--------------------- PART 1 -------------------------
------------------------------------------------------


-- (1.a)
--  What was the total forest area (in sq km) of the world in 1990?
--      Please keep in mind that you can use the country record denoted as “World" in
--      the region table
SELECT forest_area_sqkm AS total_forest_area
FROM forestation
WHERE country_code = 'WLD'
  AND year = 1990;

-- (1.b)
-- What was the total forest area (in sq km) of the world in 2016?
-- Please keep in mind that you can use the country record in the table is denoted as “World.”
SELECT forest_area_sqkm AS total_forest_area
FROM forestation
WHERE country_code = 'WLD'
  AND year = 2016;

-- (1.c)
--  What was the change (in sq km) in the forest area of the world from 1990 to 2016?
SELECT f1990.country_name,
       ROUND((f2016.forest_area_sqkm - f1990.forest_area_sqkm)::NUMERIC, 2) AS change
FROM forestation f1990
         JOIN forestation f2016 ON f1990.country_code = f2016.country_code
    AND f1990.country_code = 'WLD'
    AND f1990.year = 1990
    AND f2016.year = 2016;

-- (1.d)
-- What was the percent change in forest area of the world between 1990 and 2016?
SELECT f1990.country_name,
       ROUND(((f2016.forest_area_sqkm - f1990.forest_area_sqkm) / f1990.forest_area_sqkm * 100)::NUMERIC, 2) AS change
FROM forestation f1990
         JOIN forestation f2016 ON f1990.country_code = f2016.country_code
    AND f1990.country_code = 'WLD'
    AND f1990.year = 1990
    AND f2016.year = 2016;

-- (1.e)
-- If you compare the amount of forest area lost between 1990
-- and 2016, to which country's total area in 2016 is it closest to?
SELECT country_name,
       total_area_sqkm,
       ABS(total_area_sqkm
           -
           -- The subtraction below gives us the number of square kilometers of forest area
           -- that we've lost.
           (SELECT ROUND((f1990.forest_area_sqkm - f2016.forest_area_sqkm)::NUMERIC, 2) AS change
            FROM forestation f1990
                     JOIN forestation f2016 ON f1990.country_code = f2016.country_code
                AND f1990.country_code = 'WLD'
                AND f1990.year = 1990
                AND f2016.year = 2016)
           ) AS delta
FROM forestation
WHERE year = 2016
AND country_name != 'World'
ORDER BY delta
LIMIT 1;

------------------------------------------------------
--------------------- PART 2 -------------------------
------------------------------------------------------

CREATE OR REPLACE VIEW forestation_per_region AS
(
SELECT region,
       100 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) as forest_percent,
       year
FROM forestation
WHERE year IN (1990, 2016)
GROUP BY region, year);

--------------------

-- (2.a)
-- What was the percent forest of the entire world in 2016?
SELECT region, ROUND(forest_percent::NUMERIC, 2)
FROM forestation_per_region
WHERE year = 2016
  AND region = 'World';

-- Which region had the HIGHEST percent forest in 2016,
-- and which had the LOWEST, to 2 decimal places?
SELECT region, ROUND(forest_percent::NUMERIC, 2) as forest_percent
FROM forestation_per_region
WHERE year = 2016
ORDER BY forest_percent DESC;

-- b. What was the percent forest of the entire world in 1990?
SELECT region, ROUND(forest_percent::NUMERIC, 2)
FROM forestation_per_region
WHERE year = 1990
  AND region = 'World';

-- Which region had the HIGHEST percent forest in 1990,
-- and which had the LOWEST, to 2 decimal places?
SELECT region, ROUND(forest_percent::NUMERIC, 2) as forest_percent
FROM forestation_per_region
WHERE year = 1990
ORDER BY forest_percent DESC;

-- c. Based on the table you created,
-- which regions of the world DECREASED in forest area from 1990 to 2016?
SELECT fr1990.region,
       ROUND(fr1990.forest_percent::NUMERIC, 2)                           AS forest_percent_1990,
       ROUND(fr2016.forest_percent::NUMERIC, 2)                           AS forest_percent_2016,
       ROUND((fr1990.forest_percent - fr2016.forest_percent)::NUMERIC, 2) AS decrease
FROM forestation_per_region AS fr1990,
     forestation_per_region AS fr2016
WHERE fr2016.year = 2016
  AND fr1990.year = 1990
  AND fr1990.region = fr2016.region
ORDER BY decrease DESC;


------------------------------------------------------
--------------------- PART 3 -------------------------
------------------------------------------------------

-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
SELECT fr1990.region,
       fr1990.country_name,
       ROUND(fr1990.forest_area_sqkm::NUMERIC, 2)                             AS forest_area_1990,
       ROUND(fr2016.forest_area_sqkm::NUMERIC, 2)                             AS forest_area_2016,
       ROUND((fr1990.forest_area_sqkm - fr2016.forest_area_sqkm)::NUMERIC, 2) AS decrease
FROM forestation AS fr1990,
     forestation AS fr2016
WHERE fr2016.year = 2016
  AND fr1990.year = 1990
  AND fr1990.country_name = fr2016.country_name
  AND fr1990.country_name != 'World'
ORDER BY decrease DESC;

-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
SELECT fr1990.region,
       fr1990.country_name,
       ROUND(fr1990.forest_area_sqkm::NUMERIC, 2)         AS forest_area_1990,
       ROUND(fr2016.forest_area_sqkm::NUMERIC, 2)         AS forest_area_2016,
       ROUND(((fr1990.forest_area_sqkm - fr2016.forest_area_sqkm) /
              fr1990.forest_area_sqkm * 100)::NUMERIC, 2) AS decrease
FROM forestation AS fr1990,
     forestation AS fr2016
WHERE fr2016.year = 2016
  AND fr1990.year = 1990
  AND fr1990.country_name = fr2016.country_name
  AND fr1990.country_name != 'World'
ORDER BY decrease DESC;

-- c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
SELECT DISTINCT quartile,
                COUNT(country_name) OVER (PARTITION BY quartile) AS count
FROM (SELECT (CASE
                  WHEN forest_percent <= 25 THEN '0%-25%'
                  WHEN 25 < forest_percent AND forest_percent <= 50 THEN '25%-50%'
                  WHEN 50 < forest_percent AND forest_percent <= 75 THEN '50%-75%'
                  WHEN forest_percent > 75 THEN '75%-100%' END) AS quartile,
             country_name
      FROM forestation
      WHERE forest_percent IS NOT NULL
        AND year = 2016
        AND country_name != 'World') AS quantiles
ORDER BY count DESC;

-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT region,
       country_name,
       ROUND(forest_percent::NUMERIC, 2) as forest_percent
FROM forestation
WHERE forest_percent IS NOT NULL
  AND forest_percent > 75
  AND year = 2016
  AND country_name != 'World'
ORDER BY forest_percent DESC;

-- e. How many countries had a percent forestation higher than the United States in 2016?
SELECT COUNT(country_code)
FROM forestation
WHERE forest_percent > (SELECT forest_percent
                        FROM forestation
                        WHERE country_code = 'USA'
                          AND year = 2016)
  AND year = 2016
  AND country_name != 'World';