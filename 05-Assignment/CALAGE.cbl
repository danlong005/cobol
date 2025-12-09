       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE-SQL-CB.
      *
       ENVIRONMENT DIVISION.
           INPUT-OUTPUT SECTION.
      *
       DATA DIVISION.
           WORKING-STORAGE SECTION.
      **********************************************************************
      *******                EMBEDDED SQL VARIABLES                  *******
       01 SQLV.
           05 SQL-ARRSZ  PIC S9(9) COMP-5 VALUE 2.
           05 SQL-COUNT  PIC S9(9) COMP-5 VALUE ZERO.
           05 SQL-ADDR   POINTER OCCURS 2 TIMES VALUE NULL.
           05 SQL-LEN    PIC S9(9) COMP-5 OCCURS 2 TIMES VALUE ZERO.
           05 SQL-TYPE   PIC X OCCURS 2 TIMES.
           05 SQL-PREC   PIC X OCCURS 2 TIMES.
      **********************************************************************
      *    EXEC SQL BEGIN DECLARE SECTION END-EXEC.
           01 DBNAME          PIC        X(30) VALUE SPACE.
           01 USERNAME        PIC        X(30) VALUE SPACE.
           01 PASSWD          PIC        X(10) VALUE SPACE.
           01 EMP-FNAME       PIC        X(20) VALUE SPACE.
           01 EMP-LNAME       PIC        X(20) VALUE SPACE.
           01 EMP-DOB         PIC        X(10) VALUE SPACE.
           01 DB-CON-STR      PIC        X(50).
      *    EXEC SQL END DECLARE SECTION END-EXEC.
      *
      *    EXEC SQL INCLUDE SQLCA END-EXEC.
       01 SQLCA.
           05 SQLSTATE PIC X(5).
              88  SQL-SUCCESS           VALUE '00000'.
              88  SQL-RIGHT-TRUNC       VALUE '01004'.
              88  SQL-NODATA            VALUE '02000'.
              88  SQL-DUPLICATE         VALUE '23000' THRU '23999'.
              88  SQL-MULTIPLE-ROWS     VALUE '21000'.
              88  SQL-NULL-NO-IND       VALUE '22002'.
              88  SQL-INVALID-CURSOR-STATE VALUE '24000'.
           05 FILLER   PIC X.
           05 SQLVERSN PIC 99 VALUE 03.
           05 SQLCODE  PIC S9(9) COMP-5 VALUE ZERO.
           05 SQLERRM.
               49 SQLERRML PIC S9(4) COMP-5 VALUE ZERO.
               49 SQLERRMC PIC X(486).
           05 SQLERRD OCCURS 6 TIMES PIC S9(9) COMP-5 VALUE ZERO.
           05 FILLER   PIC X(4).
           05 SQL-HCONN USAGE POINTER VALUE NULL.
      *
           01 WS-EMP-EOF      PIC        A(1).
           01 AGE             PIC        9(3).

       COPY "CALC_AGE_DEF.cob".

      *
       PROCEDURE DIVISION.
       MAIN.

           MOVE 'admin/password@COBODBC' TO DB-CON-STR.
      *    EXEC SQL
      *        CONNECT TO :DB-CON-STR
      *    END-EXEC.
           MOVE 50 TO SQL-LEN(1)
           CALL 'OCSQL'    USING DB-CON-STR
                               SQL-LEN(1)
                               SQLCA
           END-CALL
                   .
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.

           PERFORM INITIALIZE-PARA.
           PERFORM PROCESS-PARA.
           PERFORM TERMINATE-PARA.

      * ================================================================
      * ERROR-RTN PARA
      * ================================================================
       ERROR-RTN.
           DISPLAY "*** SQL ERROR ***".
           DISPLAY "SQLCODE: " SQLCODE " " NO ADVANCING.
           PERFORM TERMINATE-PARA.

      * ================================================================
      * INITIALIZE-PARA
      * ================================================================
       INITIALIZE-PARA.
           OPEN INPUT EMPLOYEE.
           MOVE ' ' TO WS-EMP-EOF.

      * ================================================================
      * PROCESS-PARA
      * ================================================================
       PROCESS-PARA.
           READ EMPLOYEE INTO EMPLOYEE-FILE
                AT END MOVE 'Y' TO WS-EMP-EOF
           END-READ.
           PERFORM UNTIL WS-EMP-EOF = 'Y'

             MOVE EMPDOBM TO CA-MONTH
             MOVE EMPDOBD TO CA-DAY
             MOVE EMPDOBY TO CA-YEAR
             PERFORM CALCULATE-AGE-PARA
             MOVE CA-AGE TO AGE

             DISPLAY EMPFNM EMPLNM AGE

             READ EMPLOYEE INTO EMPLOYEE-FILE
                  AT END MOVE 'Y' TO WS-EMP-EOF
             END-READ

           END-PERFORM.

      * ================================================================
      * COPY IN AGE CALC PARAGRAPH
      * ================================================================
       COPY "CALC_AGE_PARA.cob".
      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
      *    EXEC SQL
      *        CONNECT RESET
      *    END-EXEC.
           CALL 'OCSQLDIS' USING SQLCA END-CALL
                   .
           CLOSE EMPLOYEE.
           STOP RUN.
      **********************************************************************
      *  : ESQL for GnuCOBOL/OpenCOBOL Version 3 (2022.01.03) Build Jul 23 2025

      *******               EMBEDDED SQL VARIABLES USAGE             *******
      *  DB-CON-STR               IN USE CHAR(50)
      *  DBNAME               NOT IN USE
      *  EMP-DOB              NOT IN USE
      *  EMP-FNAME            NOT IN USE
      *  EMP-LNAME            NOT IN USE
      *  PASSWD               NOT IN USE
      *  USERNAME             NOT IN USE
      **********************************************************************
