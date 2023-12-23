-- File: age.sql

-- Convert the age of each animal into years to make it easier to make comparisons 
-- about how age influences addmition into the centre.
SELECT
	AnimalID,
    ROUND(CASE
    WHEN
		AgeUponIntake LIKE "%year%" THEN left(AgeUponIntake,2)
    WHEN 
		AgeUponIntake like "%week%" THEN left(AgeUponIntake,2)/52 -- there are 52 weeks in a year
    ELSE
		left(AgeUponIntake,2)/12 -- there are 12 months in a year
	END,2) AS AgeInYears
from
	intakes;