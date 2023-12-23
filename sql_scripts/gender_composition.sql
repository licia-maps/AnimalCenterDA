-- File: gender_composition.sql 

-- Delete the null rows that were interfering with querying
delete from
	intakes
where
	AnimalID is null;

--  The gender makeup per animal type
select
	AnimalType,
    sum(case when SexUponIntake like "%female%" then 1 else 0 end) as "Female",
    sum(case when SexUponIntake like "%male%" and SexUponIntake not like "%female%" then 1 else 0 end) as "Male",
    sum(case when SexUponIntake not like "%male%" and SexUponIntake not like "%female%" then 1 else 0 end) as "Undetermined"
from
	intakes
group by
	AnimalType;

-- the sexuality per animal type per intake condition
SELECT
	AnimalType,
    IntakeCondition,
    sum(case when SexUponIntake like "%Intact Female%" then 1 else 0 end) as "Intactfemale",
    sum(case when SexUponIntake like "%Intact Male%" then 1 else 0 end) as "IntactMale",
    sum(case when SexUponIntake like "%Spayed Female%" then 1 else 0 end) as "SpayedFemale",
    sum(case when SexUponIntake like "%Neutered Male%" then 1 else 0 end) as "NeuteredMale",
    sum(case when SexUponIntake like "%Unknown%" then 1 else 0 end) as "Unknown"
from
	intakes
group by
	AnimalType,
    IntakeCondition
order by
	AnimalType;