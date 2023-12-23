-- File: breeds

-- Figure out the total makeup of each breed in the centre
select
	Breed,
    Color,
    count(Color) over (partition by Breed) as TotalNumber
from
	intakes;