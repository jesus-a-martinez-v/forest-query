CREATE OR REPLACE VIEW forestation_per_region AS
(
SELECT region, 100 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) as forest_percent, year
FROM forestation
WHERE year IN (1990, 2016)
GROUP BY region, year
    );

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
WITH forestation_in_1990 AS (SELECT region, ROUND(forest_percent::NUMERIC, 2) as forest_percent
                           FROM forestation_per_region
                           WHERE year = 1990
                           ORDER BY forest_percent),
     forestation_in_2016 AS (SELECT region, ROUND(forest_percent::NUMERIC, 2) as forest_percent
                             FROM forestation_per_region
                             WHERE year = 2016
                             ORDER BY forest_percent)
SELECT forestation_in_2016.region,
       forestation_in_1990.forest_percent as fp1990,
       forestation_in_2016.forest_percent as fp2016,
       (forestation_in_1990.forest_percent - forestation_in_2016.forest_percent) as delta
FROM forestation_in_2016 JOIN forestation_in_1990
ON forestation_in_1990.region = forestation_in_2016.region
ORDER BY delta DESC