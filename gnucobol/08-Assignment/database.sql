\c cobol

drop table if exists public.employees;

CREATE TABLE public.employees (
	id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	first_name text NOT NULL DEFAULT '',
	last_name text NOT NULL DEFAULT '',
	date_of_birth DATE,
	age int4
);

-- Wade Wilson has no date of birth, so AGECALC rejects it
insert into employees (first_name, last_name, date_of_birth) values
	('Clark', 'Kent', '1980-01-01'),
	('Tony', 'Stark', '1999-05-04'),
	('Bruce', 'Wayne', '1965-07-04'),
	('Wade', 'Wilson', NULL);
