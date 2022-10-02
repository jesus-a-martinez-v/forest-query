
-- (1.a)
--  What was the total forest area (in sq km) of the world in 1990?
--      Please keep in mind that you can use the country record denoted as “World" in
--      the region table
SELECT forest_area_sqkm
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
SELECT (
               (SELECT forest_area_sqkm
                FROM forestation
                WHERE country_code = 'WLD'
                  AND year = 1990)
               -
               (SELECT forest_area_sqkm
                FROM forestation
                WHERE country_code = 'WLD'
                  AND year = 2016)
           ) AS forest_area_lost;

-- (1.d)
-- What was the percent change in forest area of the world between 1990 and 2016?
SELECT (
               (SELECT forest_percent
                FROM forestation
                WHERE country_code = 'WLD'
                  AND year = 1990)
               -
               (SELECT forest_percent
                FROM forestation
                WHERE country_code = 'WLD'
                  AND year = 2016)
           ) AS percent_lost;

-- (1.e)
-- If you compare the amount of forest area lost between 1990
-- and 2016, to which country's total area in 2016 is it closest to?
SELECT country_name,
       total_area_sqkm,
       ABS(total_area_sqkm
           -
           -- The subtraction below gives us the number of square kilometers of forest area
           -- that we've lost.
           (
                   (SELECT forest_area_sqkm
                    FROM forestation
                    WHERE country_code = 'WLD'
                      AND year = 1990)
                   -
                   (SELECT forest_area_sqkm
                    FROM forestation
                    WHERE country_code = 'WLD'
                      AND year = 2016)
               )
           ) AS delta
FROM forestation
WHERE year = 2016
ORDER BY delta
LIMIT 1;