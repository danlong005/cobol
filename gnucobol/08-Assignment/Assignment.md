# Assignment 08

In Assignment 04 we shared the age calculation with a CopyBook. That shares
source code: every program that copies it compiles its own copy, and when
the calculation changes every one of those programs has to be recompiled.

This time the age calculation is its own program, `AGECALC`, compiled once
into `AGECALC.so`. `CALAGE` CALLs it for each employee. Change `AGECALC`,
rebuild just it, and every program that calls it picks up the change. This
is how most production COBOL shares code.

The program otherwise does what Assignment 06 did: read the employees,
calculate the ages and UPDATE them.

# The pieces
```
AGECALC_PARMS.cob  CopyBook with the parameter block. Both programs copy
                   it, so the caller and the subprogram always agree on
                   the layout.
AGECALC.cob        The subprogram. Validates the date and calculates the
                   age.
CALAGE.cob         The main program. CALLs AGECALC once per employee.
```

# Subprogram concepts
```
LINKAGE SECTION         The subprogram declares its parameters here. It
                        doesn't own this storage, it is given the address
                        of the caller's data.

PROCEDURE DIVISION      Names the parameters, in the order the caller
USING                   passes them.

CALL ... USING          BY REFERENCE (the default) passes the address of
                        the caller's data, so the subprogram can change it.
                        That is how AC-AGE and AC-STATUS get back.
                        BY CONTENT passes a copy, so changes are lost.

GOBACK                  Returns to the caller. STOP RUN in a subprogram
                        ends the whole program, the caller included.

Return status           AGECALC sets AC-STATUS so the caller can tell a
                        good result from a bad one. The 88 levels
                        (AC-OK, AC-BAD-DATE) give the values names.

ON EXCEPTION            Runs if the subprogram can't be loaded. Without it
                        a missing module would end the program.
```

`AGECALC` keeps its WORKING-STORAGE between calls. It is loaded on the
first CALL and stays in memory. `CANCEL 'AGECALC'` unloads it, and
`PROGRAM-ID. AGECALC IS INITIAL.` resets it on every call.

# 88 levels
The main program's switches are now 88 levels too. Instead of
`MOVE 'Y' TO WS-EMP-EOF` and `PERFORM UNTIL WS-EMP-EOF = 'Y'`:
```
       01 WS-EMP-EOF-SW   PIC X(1) VALUE 'N'.
          88 EMP-EOF               VALUE 'Y'.

       SET EMP-EOF TO TRUE
       PERFORM UNTIL EMP-EOF
```

# Dynamic and static calls
```
CALL 'AGECALC' with a literal is a dynamic call in GnuCOBOL. The Makefile
builds AGECALC as a module with cobc -m, and the runtime finds and loads
it the first time it is called.

The runtime looks for AGECALC.so in the directories in COB_LIBRARY_PATH,
and in the current directory. Run CALAGE from this directory, or it
stops with *** AGECALC NOT FOUND ***.

A static call links the subprogram into the program instead:
    cobc -x -locsql -L /usr/local/lib CALAGE.cbl AGECALC.cob
There is no .so to lose, but changing AGECALC means relinking CALAGE.
```

# Database
`database.sql` recreates the employees table with an `age` column. Wade
Wilson has no date of birth, so `AGECALC` rejects him:
```
PGPASSWORD=password psql -h localhost -U admin -d cobol -f database.sql
```

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
004Wade           Wilson                         *** BAD DATE, SKIPPED ***
ROWS UPDATED: 0003
ROWS SKIPPED: 0001
```

# Things to try
- Change the age calculation in `AGECALC.cob` and rebuild only it with
  `cobc -m -q AGECALC.cob`. Run `./CALAGE` again without rebuilding it.
- Change the CALL to `USING BY CONTENT AGECALC-PARMS`. Why is every
  employee skipped?
- Change `GOBACK` in `AGECALC` to `STOP RUN`. What happens after the first
  employee, and are any ages saved?
- From the `gnucobol` directory, run `./08-Assignment/CALAGE`, then
  `COB_LIBRARY_PATH=08-Assignment ./08-Assignment/CALAGE`.
