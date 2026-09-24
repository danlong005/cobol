# Assignment 07

In Assignment 06 all the updates were committed at the end. That is fine for
three rows, but a batch job that updates millions of rows can't work that
way. It holds its locks for the whole run, and if it fails near the end all
of the work is rolled back and has to be done again.

Real batch programs use checkpoint/restart instead:
- Commit every N rows. Each commit is a checkpoint.
- In the same unit of work, save the key of the last row committed in a
  restart table.
- When the program starts, read the restart table and only process rows
  after that key. A job that failed picks up where it left off.
- When the run completes, reset the restart key so the next run starts from
  the top.

This program calculates the ages like Assignment 06, but commits every 3
rows (`WS-COMMIT-FREQ`) and keeps its checkpoint in the `restart` table.

# Why the checkpoint is in the same unit of work
```
The UPDATE of the restart row and the employee UPDATEs are committed by the
same COMMIT. Either both are saved or neither is. If the restart key were
committed separately, a failure between the two commits would make the
next run skip rows or do them twice.
```

# Database
`database.sql` recreates the employees table with 10 employees, and creates
the `restart` table with one row for this program:
```
PGPASSWORD=password psql -h localhost -U admin -d cobol -f database.sql
```

The scripts in Assignments 03 and 05 recreate the employees table without
the `age` column, so run this one again if you have run one of those since.

# Simulating a failure
Set `CALAGE_FAIL_ID` to an employee id and the program fails when it gets
to that row. It rolls back the updates since the last checkpoint and ends
with return code 16. Leave it unset for a normal run.

Build
```
make
```

Run 1, failing at employee 8
```
CALAGE_FAIL_ID=8 ./CALAGE
```
```
*** STARTING ***
001Clark          Kent                1980-01-01 046
002Tony           Stark               1999-05-04 027
003Bruce          Wayne               1965-07-04 061
*** CHECKPOINT AT ID 003 ***
004Diana          Prince              1985-03-22 041
005Peter          Parker              2001-08-10 025
006Natasha        Romanoff            1984-11-22 041
*** CHECKPOINT AT ID 006 ***
007Barry          Allen               1992-03-14 034
*** SIMULATED FAILURE AT ID 008 ***
ROWS UPDATED: 0007
*** ROLLED BACK, RERUN TO RESTART ***
```
Employees 1 to 6 have their ages saved and the restart key is 6. The update
to employee 7 was rolled back.

Run 2, the restart
```
./CALAGE
```
```
*** RESTARTING AFTER ID 006 ***
007Barry          Allen               1992-03-14 034
008Steve          Rogers              1918-07-04 108
009Hal            Jordan              1978-02-20 048
*** CHECKPOINT AT ID 009 ***
010Bruce          Banner              1969-12-18 056
ROWS UPDATED: 0004
*** COMPLETE ***
```
The run is complete, so the restart key is back to 0 and the next run
starts from the top.

The ages are as of 2026-09-23, so they depend on the date you run it.

Check the tables between runs
```
PGPASSWORD=password psql -h localhost -U admin -d cobol -c "select * from employees order by id" -c "select * from restart"
```

# Things to try
- Fail at an id right after a checkpoint (like 7), then at one right before
  (like 9). How much work is redone each time?
- Change `WS-COMMIT-FREQ`. What is the trade-off between committing often
  and committing rarely?
- Take the `ROLLBACK` out of `ABEND-PARA` and fail at 8. Employee 7 now
  has an age but the restart key is still 6. What does that do to the next
  run? (Look at what `CONNECT RESET` does.)
