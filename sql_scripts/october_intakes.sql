-- File: october_intakes.sql

-- the number of animals taken in each day of october per intake type
select
	IF(substr(date,4,2) LIKE "%/%", LEFT(substr(date,4,2),1) , substr(date,4,2)) AS DayOfOctober,
    sum(case when IntakeType = "Stray" then 1 else 0 end) as "Stray",
    sum(case when IntakeType = "Owner Surrender" then 1 else 0 end) as "Owner Surrender",
    sum(case when IntakeType = "Wildlife" then 1 else 0 end) as "Wildlife",
    sum(case when IntakeType = "Public Assist" then 1 else 0 end) as "Public Assist",
    sum(case when IntakeType = "Euthanasia Request" then 1 else 0 end) as "Euthanasia Request"
from
	intakes
group by
	DayOfOctober
order by
	DayOfOctober asc;
    