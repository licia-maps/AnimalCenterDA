SELECT
	AnimalID,
    ROUND(CASE
    WHEN
		AgeUponIntake LIKE "%year%" THEN left(AgeUponIntake,2)
    WHEN 
		AgeUponIntake like "%week%" THEN left(AgeUponIntake,2)/52
    ELSE
		left(AgeUponIntake,2)/12
	END,2) AS AgeInYears
from
	intakes;