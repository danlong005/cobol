       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE-SQL-CB.
      *
       DATA DIVISION.
           WORKING-STORAGE SECTION.
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
           01 DB-CON-STR      PIC        X(50).
           01 EMP-ID          PIC        9(3).
           01 EMP-FNAME       PIC        X(15).
           01 EMP-LNAME       PIC        X(20).
           01 EMP-DOB         PIC        X(10).
           EXEC SQL END DECLARE SECTION END-EXEC.
      *    esqlOC can't bind a group item, so split the date here
           01 EMP-DOB-PARTS REDEFINES EMP-DOB.
              05 EMP-DOBY     PIC        9(4).
              05 EMP-DOBS     PIC        X(1).
              05 EMP-DOBM     PIC        9(2).
              05 EMP-DOBS1    PIC        X(1).
              05 EMP-DOBD     PIC        9(2).
      *
           EXEC SQL INCLUDE SQLCA END-EXEC.
      *
           01 WS-EMP-EOF      PIC        A(1).
           01 AGE             PIC        9(3).

       COPY "CALC_AGE_DEF.cob".

      *
       PROCEDURE DIVISION.
       MAIN.

           MOVE 'admin/password@COBODBC' TO DB-CON-STR.
           EXEC SQL
               CONNECT TO :DB-CON-STR
           END-EXEC.
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
           EXEC SQL
               DECLARE EMPCUR CURSOR FOR
               SELECT ID, FIRST_NAME, LAST_NAME,
                      TO_CHAR(DATE_OF_BIRTH, 'YYYY-MM-DD')
               FROM EMPLOYEES
               ORDER BY ID
           END-EXEC.
           EXEC SQL
               OPEN EMPCUR
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           MOVE ' ' TO WS-EMP-EOF.

      * ================================================================
      * PROCESS-PARA
      * ================================================================
       PROCESS-PARA.
           PERFORM FETCH-PARA.
           PERFORM UNTIL WS-EMP-EOF = 'Y'

             MOVE EMP-DOBM TO CA-MONTH
             MOVE EMP-DOBD TO CA-DAY
             MOVE EMP-DOBY TO CA-YEAR
             PERFORM CALCULATE-AGE-PARA
             MOVE CA-AGE TO AGE

             DISPLAY EMP-ID EMP-FNAME EMP-LNAME EMP-DOB " " AGE

             PERFORM FETCH-PARA

           END-PERFORM.

      * ================================================================
      * FETCH-PARA
      * ================================================================
       FETCH-PARA.
           EXEC SQL
               FETCH EMPCUR
               INTO :EMP-ID, :EMP-FNAME, :EMP-LNAME, :EMP-DOB
           END-EXEC.
           IF SQLCODE = 100
             MOVE 'Y' TO WS-EMP-EOF
           ELSE
             IF SQLCODE NOT = ZERO PERFORM ERROR-RTN
           END-IF.

      * ================================================================
      * COPY IN AGE CALC PARAGRAPH
      * ================================================================
       COPY "CALC_AGE_PARA.cob".
      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
           EXEC SQL
               CLOSE EMPCUR
           END-EXEC.
           EXEC SQL
               CONNECT RESET
           END-EXEC.
           STOP RUN.
