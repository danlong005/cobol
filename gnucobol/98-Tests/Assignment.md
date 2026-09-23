# Tests

A scratch program for checking the SQL setup. It builds the connect string
from the DSN, user name and password with STRING, connects, counts the
employees and disconnects, showing the SQLCODE after each step.

# Setup
This uses the same esqlOC, PostgreSQL and ODBC setup as Assignment 03. Follow
the steps in [03-Assignment/Assignment.md](../03-Assignment/Assignment.md),
then load the table
```
PGPASSWORD=password psql -h localhost -U admin -d cobol -f database.sql
```

Build and run
```
make
./CALAGE
```

# Output
```
*** STARTING ***
*** SQL CODE ***
SQLCODE: +0000000000 
NUMBER OF EMPLOYEES: 000000003
*** SQL CODE ***
SQLCODE: +0000000000 
*** SQL CODE ***
SQLCODE: +0000000000 
```
