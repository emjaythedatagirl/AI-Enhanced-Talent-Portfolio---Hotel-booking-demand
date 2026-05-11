CREATE DATABASE hotel_bookings;
USE  hotel_bookings;

select * from hotel_bookings;

-- 1. Creating a duplicate table for cleaning
CREATE TABLE hotel_bookings_raw AS 
SELECT * FROM hotel_bookings;


-- 2. Replace NULL with 0 for agent column
UPDATE hotel_bookings
SET agent = 0
WHERE agent IS NULL OR agent = 'NULL' OR agent = '';

-- 3. Update 'company' column to 0 where it is missing or 'NULL'
UPDATE hotel_bookings
SET company = 0
WHERE company IS NULL OR company = 'NULL' OR company = '';

-- 4. Fill missing countries with 'Unknown'
UPDATE hotel_bookings
SET country = 'Unknown'
WHERE country IS NULL OR country = 'NULL' OR country = '';

-- 5. Fill missing children with 0
UPDATE hotel_bookings
SET children = 0
WHERE children  = 'NA';

-- 6. checking if  "ghost" bookings exist 
SELECT * FROM hotel_bookings
WHERE adults = 0 AND children = 0 AND babies = 0;

-- 7. Now, to delete  them in order to  clean the dataset
DELETE FROM hotel_bookings
WHERE adults = 0 AND children = 0 AND babies = 0;

-- 8. If the dates are stored as 'YYYY-MM-DD' text, convert them:
UPDATE hotel_bookings
SET reservation_status_date = STR_TO_DATE(reservation_status_date, '%Y-%m-%d');

-- 9. Modify the column type to officially be a DATE 
ALTER TABLE hotel_bookings
MODIFY COLUMN reservation_status_date DATE;

-- 10. calculate revenue
ALTER TABLE hotel_bookings
ADD COLUMN revenue DECIMAL(10,2);

UPDATE hotel_bookings
SET revenue = adr * (stays_in_week_nights + stays_in_weekend_nights)
WHERE is_canceled = 0;

-- 11. calculate length of stay
ALTER TABLE hotel_bookings
ADD COLUMN length_of_stay INT;

UPDATE hotel_bookings
SET length_of_stay = stays_in_week_nights + stays_in_weekend_nights;

-- 12. create new column
ALTER TABLE hotel_bookings
ADD COLUMN room_changed VARCHAR(3);

UPDATE hotel_bookings
SET room_changed = 
    CASE 
        WHEN reserved_room_type <> assigned_room_type THEN 'Yes'
        ELSE 'No'
    END;
    
-- 13. create guest_type column
   ALTER TABLE hotel_bookings
ADD COLUMN guest_type VARCHAR(15);

UPDATE hotel_bookings
SET guest_type = 
    CASE 
        WHEN country = 'PRT' THEN 'Domestic'
        ELSE 'International'
    END;
    
-- 13. check for duplicates
 SELECT 
    hotel,
    lead_time,
    arrival_date_year,
    arrival_date_month,
    arrival_date_day_of_month,
    adults,
    children,
    babies,
    country,
    reserved_room_type,
    adr,
    COUNT(*) AS duplicate_count
FROM hotel_bookings
GROUP BY 
    hotel,
    lead_time,
    arrival_date_year,
    arrival_date_month,
    arrival_date_day_of_month,
    adults,
    children,
    babies,
    country,
    reserved_room_type,
    adr
HAVING COUNT(*) > 1;

CREATE TABLE hotel_bookings_no_duplicates AS
SELECT DISTINCT *
FROM hotel_bookings;

UPDATE hotel_bookings_no_duplicates
SET arrival_month_no =
CASE arrival_date_month
    WHEN 'January' THEN 1
    WHEN 'February' THEN 2
    WHEN 'March' THEN 3
    WHEN 'April' THEN 4
    WHEN 'May' THEN 5
    WHEN 'June' THEN 6
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    WHEN 'December' THEN 12
END;

-- Create Booking Month Number (for sorting in Power BI)
ALTER TABLE hotel_bookings_no_duplicates
ADD COLUMN arrival_month_no INT;



