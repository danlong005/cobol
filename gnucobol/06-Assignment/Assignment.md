# Assignment 06

So far we have only read from the database. Now let's write back to it. The
employees table gets a new `age` column. We will read each employee with a
cursor like in Assignment 05, calculate the age with the CopyBook, and then
UPDATE that employee's row with the age.

# Transactions
```
esqlOC turns autocommit off, so the UPDATEs are one unit of work. The
program ends it with COMMIT. If anything fails, ERROR-RTN does a ROLLBACK
so none of the ages are saved.

The ROLLBACK matters: CONNECT RESET commits whatever is still pending, so
without it the rows updated before the error would be saved.
```

# Database
Load the table with `database.sql`. It drops and recreates the employees
table with an `age` column that starts out empty:
```
PGPASSWORD=password psql -h localhost -U admin -d cobol -f database.sql
```

The scripts in Assignments 03 and 05 recreate the table without the `age`
column, so run this one again if you have run one of those since.

Build and run
```
make
./CALAGE
```

# Output
The ages are as of 2026-09-23, so they depend on the date you run it.
```
001Clark          Kent                1980-01-01 046
002Tony           Stark               1999-05-04 027
003Bruce          Wayne               1965-07-04 061
ROWS UPDATED: 0003
```

Check the table
```
PGPASSWORD=password psql -h localhost -U admin -d cobol -c "select * from employees order by id"
```
```
 id | first_name | last_name | date_of_birth | age
----+------------+-----------+---------------+-----
  1 | Clark      | Kent      | 1980-01-01    |  46
  2 | Tony       | Stark     | 1999-05-04    |  27
  3 | Bruce      | Wayne     | 1965-07-04    |  61
```
