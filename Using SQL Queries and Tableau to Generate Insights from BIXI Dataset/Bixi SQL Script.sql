#QUESTION 1

# REFERENCE: Found the YEAR(), MONTH() and DAY() format in the link below
# https://www.w3schools.com/sql/sql_dates.asp

#1-1: The total number of trips for the year of 2016.
SELECT 
	YEAR(start_date) AS Year, 
	COUNT(*) AS TotTrips2016
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY Year;

#1-2: The total number of trips for the year of 2017.
SELECT 
	YEAR(start_date) AS Year, 
    COUNT(*) AS TotTrips_2017
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY Year;

#1-3: The total number of trips for the year of 2016 broken down by month.
SELECT 
	MONTHNAME(start_date) AS Month, 
    COUNT(*) AS TotMonthlyTrips_2016
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY Month;

#1-4: The total number of trips for the year of 2017 broken down by month.
SELECT 
	MONTHNAME(start_date) AS Month, 
    COUNT(*) AS TotMonthlyTrips_2016
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY Month;

#1-5: The average number of trips a day for each year-month combination in the dataset.
SELECT 
	YEAR(start_date) AS Year, 
    MONTHNAME(start_date) AS Month, 
    COUNT(*)/COUNT(DISTINCT DAY(start_date)) AS AvgTripsDay
FROM trips
GROUP BY Year, Month;

#1-6: Save your query results from the previous question (Q1.5) by creating a table called working_table1
# REFERENCE: Found a function to create table in the link below
# https://www.w3schools.com/sql/sql_create_table.asp

CREATE TABLE working_table1
	(SELECT 
	YEAR(start_date) AS Year, 
    MONTH(start_date) AS Month, 
    COUNT(*)/COUNT(DISTINCT DAY(start_date)) AS AvgTripsDay
FROM trips
GROUP BY Year, Month);

#To check that information in new table is accurate
SELECT *
FROM working_table1;

# QUESTION 2
# The total number of trips in the year 2017 broken down by membership status (member/non-member).
SELECT 
	is_member AS membership_status, 
	COUNT(*) AS tot_trips
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY is_member;

# The percentage of total trips by members for the year 2017 broken down by month.
# Link below was used to see if a condition can be included within the COUNT statement
# https://stackoverflow.com/questions/1400078/is-it-possible-to-specify-condition-in-count
SELECT 
	MONTHNAME(start_date) AS Month, 
	COUNT(is_member = 1 OR NULL)/COUNT(*) *100 AS Percentage
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY Month;

# QUESTION 3
# At which time(s) of the year is the demand for Bixi bikes at its peak?
# RESOURCE FOR FUNCTION: https://www.w3schools.com/sql/func_mysql_time_format.asp
SELECT 
	TIME_FORMAT(start_date, "%h %p") AS Time, 
    COUNT(*) AS numTrips
FROM trips
GROUP BY Time
ORDER BY numTrips DESC;

# If you were to offer non-members a special promotion in an attempt to convert them to members, when would you do it? Describe the promotion and explain the motivation and your reasoning behind it.
SELECT 
    MONTHNAME(start_date) AS Month,
    COUNT(*) AS TotTrips
FROM trips
WHERE is_member = 0
GROUP BY Month
ORDER BY TotTrips DESC;
# Non-members promotion: provide a discount for the next 3 months when non-members sign up to be members
# X% off as DISCOUNT during months with the most trips - June, July, and August
    
#QUESTION 4
# It is clear now that average temperature and membership status are intertwined and influence greatly how people use Bixi bikes. 
# Let’s try to bring this knowledge with us and learn something about station popularity.

# What are the names of the 5 most popular starting stations? Determine the answer without using a subquery.
SELECT
	start_station_code,
    stations.name,
    COUNT(start_station_code) AS Trips_at_Station
FROM trips
INNER JOIN stations
ON trips.start_station_code = stations.code
GROUP BY start_station_code, stations.name
ORDER BY Trips_at_Station DESC
LIMIT 5;

# Solve the same question as Q4.1, but now use a subquery. 
# Is there a difference in query run time between 4.1 and 4.2? Why or why not?

SELECT Station.*
FROM 
	(
    SELECT 
		start_station_code,
        stations.name,
        COUNT(start_station_code) AS Trips_at_Station
	FROM trips
    INNER JOIN stations
	ON trips.start_station_code = stations.code
	GROUP BY start_station_code, stations.name
    ORDER BY Trips_at_Station DESC
    ) 
    AS Station
LIMIT 5;
# There is a difference in query run time. Due to the sequence by which SQL runs. 
# The aggregation was in the SELECT statement, which runs AFTER GROUP BY


#QUESTION 5 

# How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day?
# Reference for UNION function: https://www.w3schools.com/sql/sql_union.asp


#STATION CODE FOR STATION
SELECT *
FROM stations
WHERE name = 'Mackay / de Maisonneuve';

#FOR MORNING - STARTS
SELECT 
	'Morning-Starts' AS 'TimeOfDay',
    COUNT(*) AS TotTrips
FROM trips
WHERE start_station_code = 6100 AND HOUR(start_date) BETWEEN 7 AND 11
GROUP BY 'TimeOfDay'

UNION


#FOR MORNING - ENDS
SELECT 
	'Morning-Ends' AS 'TimeOfDay',
    COUNT(*) AS TotTrips
FROM trips
WHERE end_station_code = 6100 AND HOUR(end_date) BETWEEN 7 AND 11
GROUP BY 'TimeOfDay'

UNION


#FOR AFTERNOON
#starts
SELECT 
	'Afternoon-Starts' AS 'TimeOfDay',
    COUNT(*) AS TotTrips
FROM trips
WHERE start_station_code = 6100 AND HOUR(start_date) BETWEEN 12 AND 16
GROUP BY 'TimeOfDay'

UNION

#ends
SELECT 
	'Afternoon-Ends' AS 'TimeOfDay',
    COUNT(*) AS TotTrips
FROM trips
WHERE end_station_code = 6100 AND HOUR(end_date) BETWEEN 12 AND 16
GROUP BY 'TimeOfDay'

UNION

#FOR EVENING
#starts
SELECT 
	'Evening-Starts' AS 'TimeOfDay',
    COUNT(*) AS TotTrips
FROM trips
WHERE start_station_code = 6100 AND HOUR(start_date) BETWEEN 17 AND 21
GROUP BY 'TimeOfDay'

UNION

#ends
SELECT 
	'Evening-Ends' AS 'TimeOfDay',
    COUNT(*) AS TotTrips
FROM trips
WHERE end_station_code = 6100 AND HOUR(end_date) BETWEEN 17 AND 21
GROUP BY 'TimeOfDay';

# Explain and interpret your results from above. 
# Why do you think these patterns in Bixi usage occur for this station? Put forth a hypothesis and justify your rationale.


#QUESTION 6
# First, write a query that counts the number of starting trips per station.

SELECT
	start_station_code, 
    COUNT(start_station_code) AS num_starting_trips
FROM trips
GROUP BY start_station_code;

# Second, write a query that counts, for each station, the number of round trips.

SELECT
	start_station_code,
    COUNT(*) AS num_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code;

# Combine the above queries and calculate the fraction of round trips to the total number of starting trips for each station.

SELECT 
	stations.start_station_code, 
    total_trips.numStartingTrips, 
    round_trips.numRoundTrips,
    (round_trips.numRoundTrips/total_trips.numStartingTrips)*100 AS fraction_round_start_trips
FROM (
	SELECT DISTINCT start_station_code AS 'start_station_code' 
	FROM trips 
	ORDER BY start_station_code
	) AS stations
INNER JOIN
	(SELECT
	start_station_code, 
    COUNT(start_station_code) AS numStartingTrips
	FROM trips
	GROUP BY start_station_code
	) AS total_trips 
ON total_trips.start_station_code = stations.start_station_code
INNER JOIN
	(SELECT
	start_station_code,
    COUNT(start_station_code) AS numRoundTrips
	FROM trips
	WHERE start_station_code = end_station_code
	GROUP BY start_station_code 
	) AS round_trips 
ON round_trips.start_station_code = stations.start_station_code
;


# Filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips.

SELECT 
	stations.start_station_code, 
    (round_trips.numRoundTrips/total_trips.numStartingTrips)*100 AS fraction_round_start_trips
FROM (
SELECT DISTINCT start_station_code AS 'start_station_code' 
FROM trips 
ORDER BY start_station_code
) AS stations
INNER JOIN
(SELECT
	start_station_code, 
    COUNT(start_station_code) AS numStartingTrips
FROM trips
GROUP BY start_station_code
) AS total_trips ON total_trips.start_station_code = stations.start_station_code
INNER JOIN
(SELECT
	start_station_code,
    COUNT(start_station_code) AS numRoundTrips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code 
) AS round_trips ON round_trips.start_station_code = stations.start_station_code

WHERE (total_trips.numStartingTrips >= 500) AND (((round_trips.numRoundTrips/total_trips.numStartingTrips)*100) >= 10)
ORDER BY fraction_round_start_trips DESC
;