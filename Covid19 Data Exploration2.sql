
CREATE DATABASE IF NOT EXISTS c19virus_db;
USE c19virus_db;

-- If NULL values are present, update them with zeros for all columns
SELECT  *
FROM covid_data
WHERE Province IS NULL
        OR `Country/Region` IS NULL
        OR Latitude IS NULL
        OR Longitude IS NULL
        OR `Date` IS NULL
        OR Confirmed IS NULL
        OR Deaths IS NULL
        OR Recovered IS NULL;      -- unfortunately there's no null values present

/*to update where there is a null values
UPDATE covid_data
SET confirmed = 0
WHERE confirmed = ' '; */

-- Check the total number of rows
SELECT COUNT(*) 
FROM covid_data;
SELECT COUNT(DISTINCT Province)     -- Counting the distinct provinces
FROM covid_data;

-- Check what is the start date and end date. 
UPDATE covid_data
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

ALTER TABLE covid_data
MODIFY COLUMN `Date` DATE;

SELECT MIN(`Date`) AS Start_date, MAX(`Date`) AS End_date
FROM covid_data;

-- Number of months present in the dataset
SELECT COUNT( DISTINCT SUBSTR(`Date`,1,7)) AS `months`
FROM covid_data;

-- Monthly average for the confirmed, deaths, and recovered cases
SELECT 
    SUBSTR(`Date`, 1, 7) AS `months`,
    ROUND(AVG(confirmed), 2) avg_confirmed,
    ROUND(AVG(deaths), 2) avg_deaths,
    ROUND(AVG(Recovered), 2) avg_recovered
FROM covid_data
GROUP BY `months`
ORDER BY 1 DESC;

-- Getting the minimum values for confirmed, deaths, recovered per year
SELECT 
    YEAR(`Date`) AS `Year`,
    MIN(confirmed) min_confirmed,
    MIN(deaths) min_deaths,
    MIN(Recovered) min_recovered
FROM
    covid_data
WHERE
    Confirmed != 0 AND deaths != 0
        AND Recovered != 0
GROUP BY `Year`
ORDER BY 1 DESC;

-- Getting the maximum values for confirmed, deaths, recovered cases per year
SELECT 
    YEAR(`Date`) AS `Year`,
    MAX(confirmed) max_confirmed,
    MAX(deaths) max_deaths,
    MAX(Recovered) max_recovered
FROM
    covid_data
WHERE
    Confirmed != 0 AND deaths != 0
        AND Recovered != 0
GROUP BY `Year`
ORDER BY 1 DESC;

-- The total number of cases of confirmed, deaths, Recovered each month
SELECT 
    SUBSTR(`Date`, 1, 7) AS `months`,
    SUM(confirmed) total_confirmed,
    SUM(deaths) total_deaths,
    SUM(Recovered) total_recovered
FROM covid_data
GROUP BY `months`
ORDER BY 1 DESC;

-- Total number of spreads with respect to the confirmed case
SELECT 
    SUM(confirmed) AS Total_Confirmed_Cases,
    ROUND(AVG(confirmed), 3) AS Average_Confirmed_Cases,
    ROUND(VARIANCE(confirmed), 3) AS Variance_Confirmed_Cases,
    ROUND(STDDEV(confirmed), 3) AS Std_Dev_Confirmed_Cases
FROM
    covid_data;

-- Total spread out with respect to death rate per month
SELECT 
    SUBSTR(`Date`, 1, 7) `months`,
    SUM(Deaths) AS Total_Death_Rates,
    ROUND(AVG(Deaths), 3) AS Average_Death_Rates,
    ROUND(VARIANCE(Deaths), 3) AS Variance_Death_Rates,
    ROUND(STDDEV(Deaths), 3) AS Std_Dev_Death_Rates
FROM
    covid_data
GROUP BY `months`;

-- Total spread out with respect to the recovered case
SELECT 
    SUM(Recovered) AS Total_Recovered_Cases,
    ROUND(AVG(Recovered), 3) AS Average_Recovered_Cases,
    ROUND(VARIANCE(Recovered), 3) AS Variance_Recovered_Cases,
    ROUND(STDDEV(Recovered), 3) AS Std_Dev_Recovered_Cases
FROM
    covid_data;

-- Country having highest number of the confirmed cases
SELECT 
    `Country/Region` Country,
    SUM(Confirmed) highest_confirmed_cases
FROM
    covid_data
GROUP BY Country
ORDER BY highest_confirmed_cases DESC
LIMIT 1;

-- Using CTEs to find the country having highest number of the confirmed cases
WITH highest_confirmed_cases AS (
   SELECT 
    `Country/Region` Country,
    SUM(Confirmed) total_confirmed
FROM
    covid_data
GROUP BY Country
),Top_rank AS (
SELECT *, RANK() OVER(ORDER BY total_confirmed DESC) AS Ranks
FROM highest_confirmed_cases
)
SELECT Country, total_confirmed
FROM Top_rank 
WHERE Ranks = 1;

-- Country with lowest number of death rate
SELECT `Country/Region` country, SUM(Deaths) death_rate
FROM covid_data
WHERE Deaths != 0
GROUP BY country
ORDER BY death_rate
LIMIT 1;

-- Using CTEs to Find the list of countries  with lowest number of death rate
WITH lowest_death AS (
   SELECT `Country/Region` country, SUM(Deaths) death_rate
   FROM covid_data
   WHERE Deaths != 0
   GROUP BY country   
)
SELECT *, RANK() OVER( ORDER BY death_rate ) AS Ranks
FROM lowest_death;

-- Top 5 countries having highest recovered case
SELECT `Country/Region` country, SUM(Recovered) highest_recovered
FROM covid_data
WHERE Recovered !=0
GROUP BY country
ORDER BY highest_recovered DESC
LIMIT 5;

-- Most frequent value for confirmed, deaths, recovered each month 
WITH ConfirmedCounts AS (
    SELECT SUBSTR(`Date`,1,7) AS `months`, Confirmed, COUNT(*) AS freq
    FROM covid_data
    WHERE Confirmed !=0
    GROUP BY `months`, Confirmed
),
MostFrequentConfirmed AS (
    SELECT `months`, Confirmed
    FROM (
        SELECT `months`, Confirmed, freq,
               ROW_NUMBER() OVER (PARTITION BY `months` ORDER BY freq DESC) AS rn
        FROM ConfirmedCounts
    ) AS sub
    WHERE rn = 1
),

DeathsCounts AS (
    SELECT SUBSTR(`Date`,1,7) AS `months`, Deaths, COUNT(*) AS freq
    FROM covid_data
	WHERE Deaths !=0
    GROUP BY `months`, Deaths
),
MostFrequentDeaths AS (
    SELECT `months`, Deaths
    FROM (
        SELECT `months`, Deaths, freq,
               ROW_NUMBER() OVER (PARTITION BY `months` ORDER BY freq DESC) AS rn
        FROM DeathsCounts
    ) AS sub
    WHERE rn = 1
),

RecoveredCounts AS (
    SELECT SUBSTR(`Date`,1,7) AS `months`, Recovered, COUNT(*) AS freq
    FROM covid_data
	WHERE Recovered !=0
    GROUP BY `months`, Recovered
),
MostFrequentRecovered AS (
    SELECT `months`, Recovered
    FROM (
        SELECT `months`, Recovered, freq,
               ROW_NUMBER() OVER (PARTITION BY `months` ORDER BY freq DESC) AS rn
        FROM RecoveredCounts
    ) AS sub
    WHERE rn = 1
)

SELECT c.`months`,
	   c.Confirmed AS Most_Frequent_Confirmed, 
       d.Deaths AS Most_Frequent_Deaths, 
       r.Recovered AS Most_Frequent_Recovered
FROM MostFrequentConfirmed c
JOIN MostFrequentDeaths d ON c.`months` = d.`months`
JOIN MostFrequentRecovered r ON c.`months` = r.`months`
ORDER BY c.`months`;

