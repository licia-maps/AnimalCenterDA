select
	Breed,
    Color,
    count(Color) over (partition by Breed) as TotalNumber
from
	intakes;