create database cobol;

CREATE TABLE public.employees (
	id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	first_name text NULL,
	last_name text NULL
);

insert into employees (first_name, last_name) values ('Tony', 'Stark');
insert into employees (first_name, last_name) values ('Clark', 'Kent');