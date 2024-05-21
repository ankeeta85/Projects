CREATE DATABASE Ankeeta_Internship ---CREATING DATABASE

Use Ankeeta_Internship

----Import conona_virus Dataset file by right click on Ankeeta-intership--Import Flat file

SELECT * From corona_virus 

-- Q1. Write a code to check NULL values
SELECT * FROM corona_virus ISNULL;



--Q2. If NULL values are present, update them with zeros for all columns. 
--UPDATE corona_virus = 0 IF [dbo].[corona_virus] ISNULL;

UPDATE corona_virus
SET Province = COALESCE (Province, '0'),
    Country_Region = COALESCE(Country_Region, '0'),
    Latitude = COALESCE(Latitude, '0'),	 
    Longitude = COALESCE(Longitude, '0'),
	Dates = COALESCE (Dates, '0'),
	Confirmed = COALESCE(Confirmed,'0'),
	Deaths = COALESCE(Deaths,'0'),
	Recovered = COALESCE (Recovered, '0');


-- Q3. check total number of rows

SELECT COUNT(*) AS TotalRows
FROM corona_virus;


-- Q4. Check what is start_date and end_date

SELECT
    MIN(Dates) AS start_date,
    MAX(Dates) AS end_date
FROM
    corona_virus;

--converting datatype

SELECT DISTINCT
    CASE
        WHEN TRY_CONVERT(DATE, Dates, 101) IS NOT NULL THEN 'MM/DD/YYYY'
        WHEN TRY_CONVERT(DATE, Dates, 120) IS NOT NULL THEN 'YYYY-MM-DD'
        -- Add more WHEN conditions for other date formats as needed
        ELSE 'Invalid Format'
    END AS Date_Format
FROM Corona_virus;

UPDATE corona_virus
SET Dates = CONCAT(SUBSTRING(Dates, 7, 4), '-', SUBSTRING(Dates, 4, 2), '-', SUBSTRING(Dates, 1, 2))
WHERE TRY_CONVERT(DATE, Dates, 101) IS NULL
  AND TRY_CONVERT(DATE, Dates, 120) IS NULL;

ALTER TABLE corona_virus
ALTER COLUMN Dates Date;

UPDATE corona_virus
SET Dates = TRY_CAST(Dates AS DATE);


-- Q5. Number of month present in dataset

SELECT COUNT(DISTINCT CONCAT(YEAR(Dates), '-', MONTH(Dates))) AS NumberOfMonths
FROM corona_virus;

-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT
    YEAR(Dates) AS Year,
    MONTH(Dates) AS Month,
    AVG(Confirmed) AS AverageConfirmed,
    AVG(Deaths) AS AverageDeaths,
    AVG(Recovered) AS AverageRecovered
FROM
    corona_virus
GROUP BY
    YEAR(Dates),
    MONTH(Dates)
ORDER BY
    Year,
    Month;


-- Q7. Find most frequent value for confirmed, deaths, recovered each month 

WITH CTE AS (
    SELECT
        YEAR(Dates) AS Year,
        MONTH(Dates) AS Month,
        Confirmed,
        Deaths,
        Recovered,
        ROW_NUMBER() OVER (PARTITION BY YEAR(Dates), MONTH(Dates), Confirmed ORDER BY COUNT(*) DESC) AS ConfirmedRank,
        ROW_NUMBER() OVER (PARTITION BY YEAR(Dates), MONTH(Dates), Deaths ORDER BY COUNT(*) DESC) AS DeathRank,
        ROW_NUMBER() OVER (PARTITION BY YEAR(Dates), MONTH(Dates), Recovered ORDER BY COUNT(*) DESC) AS RecoveredRank
    FROM
        corona_virus
    GROUP BY
        YEAR(Dates),
        MONTH(Dates),
        Confirmed,
        Deaths,
        Recovered
)
SELECT
    Year,
    Month,
    MAX(CASE WHEN ConfirmedRank = 1 THEN Confirmed END) AS MostFrequentConfirmed,
    MAX(CASE WHEN DeathRank = 1 THEN Deaths END) AS MostFrequentDeaths,
    MAX(CASE WHEN RecoveredRank = 1 THEN Recovered END) AS MostFrequentRecovered
FROM
    CTE
GROUP BY
    Year,
	Month;


-- Q8. Find minimum values for confirmed, deaths, recovered per year

SELECT
    YEAR(Dates) AS Year,
    MIN(Confirmed) AS MinConfirmed,
    MIN(Deaths) AS MinDeaths,
    MIN(Recovered) AS MinRecovered
FROM
    corona_virus
GROUP BY
    YEAR(Dates);


-- Q9. Find maximum values of confirmed, deaths, recovered per year

SELECT
    YEAR(Dates) AS Year,
    MAX(Confirmed) AS MaxConfirmed,
    MAX(Deaths) AS MaxDeaths,
    MAX(Recovered) AS MaxRecovered
FROM
    corona_virus
GROUP BY
    YEAR(Dates);
	

-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT
    YEAR(Dates) AS Year,
    MONTH(Dates) AS Month,
    SUM(Confirmed) AS TotalConfirmed,
    SUM(Deaths) AS TotalDeaths,
    SUM(Recovered) AS TotalRecovered
FROM
    corona_virus
GROUP BY
    YEAR(Dates),
    MONTH(Dates)
ORDER BY
    Year,
    Month;
	

-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT
	DATEPART(YEAR, Dates) AS Year,
    DATEPART(MONTH, Dates) AS Month,
    SUM(Confirmed) AS TotalConfirmed,
    AVG(Confirmed) AS AverageConfirmed,
    VAR(Confirmed) AS VarianceConfirmed,
    STDEV(Confirmed) AS StdevConfirmed
FROM
    corona_virus
	GROUP BY
    DATEPART(YEAR, Dates),
    DATEPART(MONTH, Dates)
ORDER BY
    Year,
    Month;
	

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT
    DATEPART(YEAR, Dates) AS Year,
    DATEPART(MONTH, Dates) AS Month,
    SUM(Confirmed) AS TotalConfirmed,
    AVG(Deaths) AS AverageDeaths,
    VAR(Deaths) AS VarianceDeaths,
    STDEV(Deaths) AS StdevDeaths
FROM
    corona_virus
GROUP BY
    DATEPART(YEAR, Dates),
    DATEPART(MONTH, Dates)
ORDER BY
    Year,
    Month;


-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT
	DATEPART(YEAR, Dates) AS Year,
    DATEPART(MONTH, Dates) AS Month,
    SUM(Confirmed) AS TotalConfirmed,
    AVG(Recovered) AS AverageRecovered,
    VAR (Recovered) AS VarianceRecovered,
    STDEV(Recovered) AS StdevRecovered
FROM
    corona_virus
GROUP BY
    DATEPART(YEAR, Dates),
    DATEPART(MONTH, Dates)
ORDER BY
    Year,
    Month;

	

-- Q14. Find Country having highest number of the Confirmed case

SELECT TOP 1
    Country_Region,
    Confirmed
FROM
    corona_virus
WHERE
    Confirmed IS NOT NULL
ORDER BY
    Confirmed DESC;




-- Q15. Find Country having lowest number of the death case
SELECT TOP 1
    Country_Region,
    Deaths
FROM
    corona_virus
WHERE
    Deaths <> 0 
ORDER BY
    Deaths ASC;



-- Q16. Find top 5 countries having highest recovered case
SELECT TOP 5
    Country_Region AS Country,
	SUM(CAST(Recovered AS INT)) AS TotalRecoveredcases
	FROM
	corona_virus
WHERE
    ISNUMERIC(RECOVERED) = 1
GROUP BY
	Country_Region
ORDER BY
    TotalRecoveredcases DESC;


