--Data from http://insideairbnb.com/mexico-city

-- Looking to the top 100 rows of the data
SELECT top 100 *
FROM [Portfolio Airbnb]..airbnbData;

-- Host id is unique acording to the name, id is set for each place
-- Each place is really unique
SELECT count(distinct id) as total_unique_ids, count(distinct host_id) as total_unique_hosts, count(id) as total_ids, count(host_id) as total_hosts
FROM [Portfolio Airbnb]..airbnbData;

-- Looking into the total of neighbourhoods
SELECT count(distinct neighbourhood) as total_neighbourhoods
FROM [Portfolio Airbnb]..airbnbData;

-- Neighbourhood_group and license are totally empty, can be removed
--SELECT neighbourhood_group, count(neighbourhood_group), license ,count(license)
--FROM [Portfolio Airbnb]..airbnbData
--GROUP BY neighbourhood_group, license;

-- Looking into the room type numbers and the percentage they represent
DECLARE @TOTALROOMS FLOAT
SET @TOTALROOMS = 20093
SELECT room_type, count(room_type) as room_types, (count(room_type)/@TOTALROOMS)*100 as per_of_total
FROM [Portfolio Airbnb]..airbnbData
GROUP BY room_type;

SELECT room_type, count(room_type) as room_types, MIN(price) as minimun_price, MAX(price) as maximun_price
FROM [Portfolio Airbnb]..airbnbData
WHERE price <> 0
GROUP BY room_type;

-- We have 7 places where price is 0, we might consider this as outliers
-- Also, we can consider posible outliers as some places are so cheap
SELECT *
FROM [Portfolio Airbnb]..airbnbData
WHERE price = 0;

-- First look into prices without 0's
SELECT *
FROM [Portfolio Airbnb]..airbnbData
WHERE price <> 0
ORDER BY price ASC;

-- Average reviews
SELECT neighbourhood, room_type, AVG(reviews_per_month) as avg_reviews_per_month
FROM [Portfolio Airbnb]..airbnbData
WHERE price <> 0
GROUP BY neighbourhood, room_type
ORDER BY neighbourhood, avg_reviews_per_month DESC;

-- Looking into general stats
SELECT neighbourhood, room_type, count(room_type) as total_opt_room_types, MIN(price) as minimun_price, MAX(price) as maximun_price, AVG(price) as average_price
FROM [Portfolio Airbnb]..airbnbData
WHERE price <> 0
GROUP BY neighbourhood, room_type
ORDER BY neighbourhood;

SELECT distinct host_id, host_name, count(*) as tot_rooms
FROM [Portfolio Airbnb]..airbnbData
WHERE last_review BETWEEN '2021-03-27' AND '2022-03-27'
GROUP BY host_name, host_id
ORDER BY tot_rooms DESC;

--Things to do
--Look into time and shared room, private room, apt with min time of 6 months and good pricing, for students
--Look into last_reviews, check how many of them where unoccupied in previous 2022
--Look into the host_name groups
--Check availability, minimun_nights, etc
--Check tend by year
