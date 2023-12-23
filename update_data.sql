-- File: update_data.sql

-- inserting date data into the date column
update 
	intakes
set
	date = left(DateTime,10);

-- inserting time data into the time table    
update 
	intakes
set 
	time = right(DateTime,5);