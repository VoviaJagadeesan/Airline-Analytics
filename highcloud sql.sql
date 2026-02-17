create database airline;
use airline;

Alter Table maindata Add flight_date DATE;
SET SQL_SAFE_UPDATES = 0;

UPDATE maindata
SET flight_date = STR_TO_DATE(
    CONCAT(Year, '-', LPAD(Month_,2,'0'), '-', LPAD(Day,2,'0')),
    '%Y-%m-%d'
);

SELECT Year, Month_, Day, flight_date
FROM maindata
LIMIT 10;

SELECT DISTINCT YEAR(flight_date) AS Year FROM maindata;
describe maindata;

-- Month Number
Select Distinct month(flight_date) As MonthNo
From maindata;

-- Month Full Name
Select Distinct MonthName(flight_date) As MonthName
From maindata;

-- Quarter(Q1-Q4)
Select distinct 
Quarter(flight_date) as Quarter
from maindata;

--- Year Month(YYYY-MMM)
Select Date_Format(flight_date, '%Y-%b') as YearMonth
from maindata;

-- Weekday Number
Select dayofweek(Flight_date) as WeekdayNo
from maindata;

-- WeekdayName
select dayname(flight_date) as WeekdayName
from maindata;

--- Financial Month (India: Apr-Mar)
select 
case 
when month(flight_date)>= 4 then month(flight_date) - 3
else month(flight_date) + 9
End as FinancialMonth
from maindata;

--- Financial Quarter
select 
case
when month(flight_date) between 4 and 6 then 'Q1'
when Month(flight_date) between 7 and 9 then 'Q2'
when month(flight_date) between 10 and 12 then 'Q3'
Else 'Q4'
end as FinancialQuarter
from maindata;

----- Question 2 Load Factor (Yearly/ Quarterly/ Monthly)

SELECT CONCAT(ROUND(SUM(_Transported_Passengers) / SUM(_Available_seats) * 100, 2),'%') AS Load_Factor FROM maindata;

-- YEARLY
SELECT 
    YEAR(flight_date) AS Year,
    ROUND(
        SUM(_Transported_Passengers) / SUM(_Available_seats) * 100
    , 2) AS LoadFactor_Percent
FROM maindata
GROUP BY YEAR(flight_date)
ORDER BY Year;


-- Monthly
SELECT 
    Monthname(flight_date) as Month,
    ROUND(
        SUM(_Transported_Passengers) / SUM(_Available_seats) * 100
    , 2) AS LoadFactor_Percent
FROM maindata
GROUP BY Month
ORDER BY Month;

-- Quarterly
SELECT 
    QUARTER(flight_date) AS Quarter,
    ROUND(
        SUM(_Transported_Passengers) / SUM(_Available_seats) * 100
    , 2) AS LoadFactor_Percent
FROM maindata
GROUP BY QUARTER(flight_date)
ORDER BY Quarter;

---- Question 3: Load Factor by carrier
SELECT 
    Carrier_Name,
    ROUND(
        SUM(_Transported_Passengers) / SUM(_Available_seats) * 100
    , 2) AS LoadFactor_Percent
FROM maindata
GROUP BY Carrier_Name
ORDER BY LoadFactor_Percent DESC;

--- Question 4 Top 10 Carriers by passengers
 SELECT 
    Carrier_Name,
    CONCAT(
        ROUND(SUM(_Transported_Passengers) / 1000000, 2),
        ' Million'
    ) AS TotalPassengers
FROM maindata
GROUP BY Carrier_Name
ORDER BY SUM(_Transported_Passengers) DESC
LIMIT 10;


--- Question 5 Top Routes (From to City)
SELECT
    Origin_City,
    Destination_City,
    COUNT(*) AS NumberOfFlights,
    ROUND(SUM(_Transported_Passengers)/10000, 2) AS Passengers
FROM maindata
GROUP BY Origin_City, Destination_City
ORDER BY NumberOfFlights DESC
LIMIT 10;

--- Question 6 Weekend vs Weekday loadfactor
SELECT 
    DayType,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Flights_Percentage
FROM (
    SELECT 
        CASE
            WHEN DAYOFWEEK(flight_date) IN (1,7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS DayType
    FROM maindata
) t
GROUP BY DayType;


--- Question 7 Filter Flights (Search Capability)
select * from maindata
where 
'Origin Country' = 'India'
And 'Origin City Name' = 'Pune'
And 'Destinatin City Name' = 'Delhi';

--- Question 8 Flights By Distance Group 
SELECT
    Distance_Group_ID,
    COUNT(*) AS TotalFlights
FROM maindata
GROUP BY Distance_Group_ID
ORDER BY Distance_Group_ID;

SELECT 
    CONCAT(
        ROUND(SUM(_Available_seats) / 1000000, 2),
        ' Million'
    ) AS TotalAvailableSeats
FROM maindata;

SELECT 
    COUNT(_Transported_Passengers) AS TotalFlights
FROM maindata;

SELECT 
    ROUND(AVG(Distance), 2) AS Avg_Distance
FROM maindata
WHERE Distance IS NOT NULL;

SELECT 
    COUNT(City) AS TotalCities
FROM (
    SELECT Origin_City AS City FROM maindata
    UNION
    SELECT Destination_City FROM maindata
) t;
