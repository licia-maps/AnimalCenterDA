-- File: create_columns.sql

-- creating a separate column for the date
alter table
	intakes
add column
	date text;

-- creating a separate column for the time 
alter table
	intakes
add column
	time text;