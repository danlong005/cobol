\c cobol

drop table if exists public.employees;
drop table if exists public.restart;

CREATE TABLE public.employees (
	id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	first_name text NOT NULL DEFAULT '',
	last_name text NOT NULL DEFAULT '',
	date_of_birth DATE,
	age int4
);

insert into employees (first_name, last_name, date_of_birth) values
	('Clark', 'Kent', '1980-01-01'),
	('Tony', 'Stark', '1999-05-04'),
	('Bruce', 'Wayne', '1965-07-04'),
	('Diana', 'Prince', '1985-03-22'),
	('Peter', 'Parker', '2001-08-10'),
	('Natasha', 'Romanoff', '1984-11-22'),
	('Barry', 'Allen', '1992-03-14'),
	('Steve', 'Rogers', '1918-07-04'),
	('Hal', 'Jordan', '1978-02-20'),
	('Bruce', 'Banner', '1969-12-18');

-- One row per program: the last employee id it committed
CREATE TABLE public.restart (
	program text NOT NULL PRIMARY KEY,
	last_id int4 NOT NULL DEFAULT 0
);

insert into restart (program) values ('CALAGE');
