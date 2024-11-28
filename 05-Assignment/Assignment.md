# Assignment 04

We have now done a little SQL and also used CopyBooks. In this Assignment
we will combine both of those things. We will use SQL to read the data from 
the database table. Then we will use the CopyBook to calculate the age.

# OceSQL shortcoming
```
Do NOT place the copybook for the paragraph on the last line of the 
code. For some reason OceSQL will triple the copy in it's translation.

We aren't using SQL in this example so we could rip out the usage of 
OceSQL. 
```


# Database
```
CREATE TABLE public.employees (
	id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	first_name text NOT NULL DEFAULT '',
	last_name text NOT NULL DEFAULT '',
    date_of_birth DATE
);

insert into employees (first_name, last_name, date_of_birth) values 
	('Clark', 'Kent', '1980-01-01'),
	('Tony', 'Stark', '1999-05-04'),
	('Bruce', 'Wayne', '1965-07-04')
```

# Output
```
001Clark          Kent               1980-01-01 042
002Tony           Stark              1999-05-04 022
003Bruce          Wayne              1965-07-04 056
```