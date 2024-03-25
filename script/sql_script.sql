-- ===================================================================================================
-- Title: Data Analysis Queries for Animal Shelter intakes
-- Author: Alicia Maposa
-- ===================================================================================================

-- ==================================================================================================
-- i. Data Loading
-- ==================================================================================================

-- prepare to load the data
Show variables like "local_infile";
set global local_infile = 1;

-- create a table for animal intakes and insert animal shelter data into it
CREATE TABLE animal_intakes(
AnimalID TEXT,
Name TEXT,
DateTimeFound TEXT,	
MonthYear TEXT,
LocationFound TEXT,
IntakeType	TEXT,
IntakeCondition TEXT,
AnimalType TEXT,
SexuponIntake TEXT,
AgeUponIntake TEXT,
Breed TEXT,
Color TEXT
);
 
load data local infile 'C:/Users/User/Downloads/animal_intakes.csv'
into table animal_intakes
fields terminated by ','
ignore 1 rows;

-- ===================================================================================================
-- ii. Data Cleaning
-- ===================================================================================================

-- move misplaced data into the correct columns
SET SQL_SAFE_UPDATES = 0;

UPDATE animal_intakes
SET LocationFound = concat(LocationFound, " ", IntakeType)
WHERE IntakeCondition in ('Stray', 'Wildlife', 'Owner Surrender', 'Public Assist');

UPDATE animal_intakes
SET 
    IntakeType = IntakeCondition,
    IntakeCondition = AnimalType,
    AnimalType = SexUponIntake,
    SexUponIntake = AgeUponIntake,
    AgeUponIntake = Breed,
    Breed = Color,
    Color = 'Unknown'
WHERE IntakeCondition in ('Stray', 'Wildlife', 'Owner Surrender', 'Public Assist');

-- remove corrupted columns
DELETE FROM
	animal_intakes
WHERE 
	IntakeType NOT IN ('Stray', 'Owner Surrender', 'Wildlife', 'Public Assist', 'Euthanasia Request', 'Abandoned');
  
-- ==================================================================================================
-- iii. Data Analysis
-- ==================================================================================================
-- 1. Basic Statistics
-- =================================================================================================

-- total number of animal intakes
SELECT
	COUNT(*) AS TotalAnimalIntakes
FROM 
	animal_intakes;
    
-- number of intakes per intake type
SELECT
	IntakeType,
    count(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	IntakeType;
    
-- distribution of animal conditions
SELECT
	IntakeCondition,
    COUNT(*) AS NumberOfIntakes,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM animal_intakes) * 100, 2) AS PercentageOfIntakes
FROM
	animal_intakes
GROUP BY
	IntakeCondition
ORDER BY
	NumberOfIntakes DESC;
    
-- distribution of animal types
SELECT
	AnimalType,
    COUNT(*) AS NumberOfIntakes,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM animal_intakes) * 100, 2) AS PercentageOfIntakes
FROM 
	animal_intakes
GROUP BY
	AnimalType
ORDER BY
	NumberOfIntakes DESC;

-- distribution of animal sexes
SELECT
	IF(LEFT(SexUponIntake, 1) = 'I', IF(LEFT(SexUponIntake, 8) = 'F', "Female", 'Male'), IF(LEFT(SexUponIntake, 1) = 'S', 'Female', IF(LEFT(SexUponIntake, 1) = 'N', 'Male', 'Undetermined'))) AS Gender,
    COUNT(*) AS NumberOfIntakes,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM animal_intakes) * 100, 2) AS PercentageOfIntakes
FROM
	animal_intakes
GROUP BY
	Gender;

-- distribution of spayed/neutered animals vs. intact animals
SELECT
	IF(LEFT(SexUponIntake, 1) = 'I', "Intact", IF(LEFT(SexUponIntake, 1) in ('S', 'N'), 'Spayed/Neutered', 'Undetermined')) AS ReproductiveStatus,
    COUNT(*) AS NumberOfIntakes,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM animal_intakes) * 100, 2) AS PercentageOfIntakes
FROM
	animal_intakes
GROUP BY
	ReproductiveStatus;
    
-- distribution of animal ages
SELECT
	CASE 
    WHEN AnimalType = 'Cat' THEN IF(
    ((RIGHT(AgeUponIntake, 6) = 'months' OR RIGHT(AgeUponIntake, 5) = 'month') AND LEFT(AgeUponIntake,2) < 7) OR ((RIGHT(AgeUponIntake, 5) = 'weeks' OR RIGHT(AgeUponIntake, 4) = 'week') AND LEFT(AgeUponIntake,2) < 12),
    "Pediatric",
    IF(((RIGHT(AgeUponIntake, 6) = 'months' AND LEFT(AgeUponIntake,2) > 6) OR ((RIGHT(AgeUponIntake, 4) = 'year' OR RIGHT(AgeUponIntake, 5) = 'years') AND LEFT(AgeUponIntake,1) > 0 AND LEFT(AgeUponIntake,1) < 8)),
    "Young Adult",
    IF(AnimalType = 'Cat' AND RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 7 AND LEFT(AgeUponIntake, 2) < 12,
    "Mature Adult",
    IF(AnimalType = 'Cat' AND RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 11 AND LEFT(AgeUponIntake, 2) < 16,
    "Senior",
    "Geriatric"))))
    WHEN AnimalType = 'Dog' THEN IF(
    (((RIGHT(AgeUponIntake, 6) = 'months' OR RIGHT(AgeUponIntake, 5) = 'month') AND LEFT(AgeUponIntake,2) < 7 ) OR ((RIGHT(AgeUponIntake, 5) = 'weeks' OR RIGHT(AgeUponIntake, 4) = 'week') AND LEFT(AgeUponIntake,2) < 12)),
    "Pediatric",
    IF(((RIGHT(AgeUponIntake, 6) = 'months' AND LEFT(AgeUponIntake,2) > 6) OR ((RIGHT(AgeUponIntake, 4) = 'year' OR RIGHT(AgeUponIntake, 5) = 'years') AND LEFT(AgeUponIntake,2) < 7 AND LEFT(AgeUponIntake,2) > 0)),
    "Young Adult",
    IF(RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 6 AND LEFT(AgeUponIntake, 2) < 11,
    "Mature Adult",
    IF(RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 10 AND LEFT(AgeUponIntake, 2) < 13,
    "Senior",
    "Geriatric"))))
    WHEN AnimalType = 'Bird' THEN IF(
    (RIGHT(AgeUponIntake, 6) = 'months' OR RIGHT(AgeUponIntake, 5) = 'month' OR RIGHT(AgeUponIntake, 5) = 'weeks' OR RIGHT(AgeUponIntake, 4) = 'week') AND LEFT(AgeUponIntake,2) < 12,
    "Pediatric",
    IF((RIGHT(AgeUponIntake, 4) = 'year' OR RIGHT(AgeUponIntake, 5) = 'years') AND LEFT(AgeUponIntake,2) >=1 AND LEFT(AgeUponIntake,2) < 4,
    "Young Adult",
    IF(RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 3 AND LEFT(AgeUponIntake, 2) < 15,
    "Mature Adult",
    IF(RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 14 AND LEFT(AgeUponIntake, 2) < 20,
    "Senior",
    "Geriatric"))))
    WHEN AnimalType = 'Livestock' THEN IF(
    (((RIGHT(AgeUponIntake, 6) = 'months' OR RIGHT(AgeUponIntake, 5) = 'month') AND LEFT(AgeUponIntake,2) < 7) OR ((RIGHT(AgeUponIntake, 5) = 'weeks' OR RIGHT(AgeUponIntake, 4) = 'week') AND LEFT(AgeUponIntake,2) < 12)),
    "Pediatric",
    IF(((RIGHT(AgeUponIntake, 6) = 'months' AND LEFT(AgeUponIntake,2) > 6) OR ((RIGHT(AgeUponIntake, 4) = 'year' OR RIGHT(AgeUponIntake, 5) = 'years') AND LEFT(AgeUponIntake,1) > 0 AND LEFT(AgeUponIntake,1) < 3)),
    "Young Adult",
    IF(RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 2 AND LEFT(AgeUponIntake, 2) < 7,
    "Mature Adult",
    IF(RIGHT(AgeUponIntake, 5) = 'years' AND LEFT(AgeUponIntake, 2) > 6 AND LEFT(AgeUponIntake, 2) < 9,
    "Senior",
    "Geriatric"))))
    WHEN AnimalType = 'Other' THEN 'Undetermined'
    END AS
		AgeCategory,
	AnimalType,
	COUNT(*) AS NumberOfIntakes,
    ROUND(COUNT(*)/ (SELECT COUNT(*) FROM animal_intakes) * 100,2) As PercentageOfIntakes
FROM 
	animal_intakes
GROUP BY
	AnimalType,
	AgeCategory
ORDER BY
	NumberOfIntakes DESC;
    
-- =================================================================================================
-- 2. Temporal Analysis
-- =================================================================================================

-- busiest hours for animal intakes
SELECT
	RIGHT(DateTimeFound, 2) AS TimeOfDay,
	SUBSTRING(DateTimeFound, 12, 2) AS HourOfDay,
    COUNT(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	TimeOfDay,
    HourOfDay
ORDER BY
	TimeOfDay;
    
-- Add timefound column to store the time
ALTER TABLE
	animal_intakes
ADD COLUMN 
	TimeFound TIME;
    
-- insert time data from the datetimefound column
SET SQL_SAFE_UPDATES = 0;	
UPDATE 
	animal_intakes
SET
	TimeFound = SUBSTRING(DateTimeFound, 12, 8);
   
-- Trends in animal intakes based on parts of the day
SELECT
	IF(RIGHT(DateTimeFound,2) = "AM" AND TimeFound >= '05:00:00' AND  TimeFound < '08:59:59', "Morning",
    IF(RIGHT(DateTimeFound,2) = "PM" AND (TimeFound >= '12:00:00' OR  (TimeFound >= '01:00:00' AND TimeFound < '05:00:00')), "Afternoon",
    IF(RIGHT(DateTimeFound,2) = "PM" AND TimeFound >= '05:00:00' AND TimeFound < '08:59:59', "Evening",
    "Night"))) AS TimeOfDay,
    COUNT(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	TimeOfDay;
   
-- monthly trends in animal intakes
WITH monthly_intakes AS(
SELECT
	IF(substring(MonthYear, 1, 9) = 'September', LEFT(MonthYear, 4), LEFT(MonthYear,3)) AS Month,
	COUNT(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	Month
ORDER BY
	NumberOfIntakes DESC)
    
-- seasonal variations in animal intakes
SELECT
	IF(Month in ('Mar', 'Apr', 'May'), "Spring", IF(Month in ('Jun', 'Jul', 'Aug'), "Summer", IF(Month in ('Sept', 'Oct', 'Nov'), "Fall", "Winter"))) AS Season,
    SUM(NumberOfIntakes) AS NumberOfIntakes
FROM
	monthly_intakes
GROUP BY
	Season
ORDER BY
	NumberOfIntakes DESC;

-- yearly trends in animal intake
SELECT
	RIGHT(MonthYear, 4) AS Year,
	COUNT(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	RIGHT(MonthYear, 4)
ORDER BY
	NumberOfIntakes DESC;
    
-- ==================================================================================================
-- 3. Demographic Analysis
-- ==================================================================================================
-- gennder distribution per animal type
SELECT
	AnimalType,
    sum(case when SexUponIntake like "%female%" then 1 else 0 end) as "Female",
    sum(case when SexUponIntake like "%male%" and SexUponIntake not like "%female%" then 1 else 0 end) as "Male",
    sum(case when SexUponIntake not like "%male%" and SexUponIntake not like "%female%" then 1 else 0 end) as "Undetermined"
FROM
	animal_intakes
GROUP BY
	AnimalType;
    
-- most commom breeds
SELECT
	*
FROM
	(
SELECT
	DENSE_RANK() OVER (PARTITION BY AnimalType ORDER BY COUNT(*) DESC) AS BreedRank,
	AnimalType,
	Breed,
    COUNT(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	AnimalType,
	Breed
ORDER BY
	AnimalType) AS AnimalBreedRank
WHERE BreedRank <= 3;

-- most common colors
SELECT
	*
FROM
	(
SELECT
	DENSE_RANK() OVER (PARTITION BY AnimalType ORDER BY COUNT(*) DESC) AS ColorRank,
	AnimalType,
	Color,
    COUNT(*) AS NumberOfIntakes
FROM
	animal_intakes
GROUP BY
	AnimalType,
	Color
ORDER BY
	AnimalType) AS AnimalColorRank
WHERE ColorRank <= 3;

-- average age of animals at intake
SELECT
	AnimalType,
    ROUND((AVG(AgeInWeeks)/52.143), 2) AS AverageAgeInWeeks
FROM
(SELECT
	AnimalType,
    AgeUponIntake,
	IF(RIGHT(AgeUponIntake, 1) = 'h' OR RIGHT(AgeUponIntake, 2) = 'hs', ROUND(LEFT(AgeUponIntake, 2) * 4.43, 2), 
	IF(RIGHT(AgeUponIntake, 1) = 'r' OR RIGHT(AgeUponIntake, 2) = 'rs', ROUND(LEFT(AgeUponIntake, 2) * 52.143, 2),
	LEFT(AgeUponIntake, 2))) AS AgeInWeeks
FROM
	animal_intakes) AS AnimalAgeInWeeks
GROUP BY
	AnimalType;
 
-- ==================================================================================================
-- 4. 	Health Analysis
-- ==================================================================================================

--  distribution of health conditions per animal type
SELECT
	IntakeCondition,
    sum(case when AnimalType = "Cat" then 1 else 0 end) as "Cats",
    sum(case when AnimalType = "Dog" then 1 else 0 end) as "Dogs",
    sum(case when AnimalType =  "Bird" then 1 else 0 end) as "Birds",
    sum(case when AnimalType =  "Livestock" then 1 else 0 end) as "Livestock",
    sum(case when AnimalType =  "Other" then 1 else 0 end) as "Others"
FROM
	animal_intakes
GROUP BY
	IntakeCondition;
    
-- health conditions per animal breed
SELECT 
	IntakeCondition,
    Breed,
    NumberOfIntakes
FROM	
(SELECT
	IntakeCondition,
    Breed,
    COUNT(*) AS NumberOfIntakes,
    DENSE_RANK() OVER(PARTITION BY IntakeCondition ORDER BY COUNT(*) DESC) AS BreedConditionRank
FROM
	animal_intakes
GROUP BY
	IntakeCondition,
    Breed
ORDER BY
	IntakeCondition) AS AnimalBreedConditionRank
WHERE BreedConditionRank = 1;

-- distribution of health condition by gender
SELECT
    IntakeCondition,
    sum(case when SexUponIntake = "Intact Female" then 1 else 0 end) as "IntactFemale",
    sum(case when SexUponIntake = "Intact Male" then 1 else 0 end) as "IntactMale",
    sum(case when SexUponIntake = "Spayed Female" then 1 else 0 end) as "SpayedFemale",
    sum(case when SexUponIntake = "Neutered Male" then 1 else 0 end) as "NeuteredMale",
    sum(case when SexUponIntake not in ("Intact Female", "Intact Male", "Spayed Female", "Neutered Male") then 1 else 0 end) as "Unknown"
FROM
	animal_intakes
GROUP BY
    IntakeCondition
order by
	IntakeCondition;
    
-- =================================================================================================
-- END OF SQL QUERIES
-- =================================================================================================