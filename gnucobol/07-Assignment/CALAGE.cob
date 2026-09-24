       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE-RESTART.
      *
       DATA DIVISION.
           WORKING-STORAGE SECTION.
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
           01 DB-CON-STR      PIC        X(50).
           01 PGM-NAME        PIC        X(8)  VALUE 'CALAGE'.
           01 LAST-ID         PIC        9(3).
           01 EMP-ID          PIC        9(3).
           01 EMP-FNAME       PIC        X(15).
           01 EMP-LNAME       PIC        X(20).
           01 EMP-AGE         PIC        9(3).
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
           01 WS-CUR-OPEN     PIC        A(1)  VALUE 'N'.
      *    Commit after this many updates
           01 WS-COMMIT-FREQ  PIC        9(3)  VALUE 3.
           01 WS-UNCOMMITTED  PIC        9(3)  VALUE ZERO.
           01 WS-UPD-COUNT    PIC        9(4)  VALUE ZERO.
      *    Set CALAGE_FAIL_ID to an employee id to fail on that row
           01 WS-FAIL-ID      PIC        9(3)  VALUE ZERO.
           01 WS-RC           PIC        9(2)  VALUE ZERO.

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
           PERFORM FINISH-PARA.
           PERFORM TERMINATE-PARA.

      * ================================================================
      * ERROR-RTN PARA
      * ================================================================
       ERROR-RTN.
           DISPLAY "*** SQL ERROR ***".
           DISPLAY "SQLCODE: " SQLCODE.
           IF SQLERRML > 0
             DISPLAY "SQLERRMC: " SQLERRMC(1:SQLERRML)
           END-IF.
           PERFORM ABEND-PARA.

      * ================================================================
      * ABEND-PARA
      * ================================================================
       ABEND-PARA.
      *    Undo the updates since the last checkpoint. Without this the
      *    CONNECT RESET in TERMINATE-PARA would commit them.
           EXEC SQL
               ROLLBACK
           END-EXEC.
           DISPLAY "ROWS UPDATED: " WS-UPD-COUNT.
           DISPLAY "*** ROLLED BACK, RERUN TO RESTART ***".
           MOVE 16 TO WS-RC.
           PERFORM TERMINATE-PARA.

      * ================================================================
      * INITIALIZE-PARA
      * ================================================================
       INITIALIZE-PARA.
           ACCEPT WS-FAIL-ID FROM ENVIRONMENT "CALAGE_FAIL_ID".

      *    PGM-NAME is padded with spaces, and PostgreSQL text
      *    doesn't ignore them, so trim it in every WHERE
           EXEC SQL
               SELECT LAST_ID
               INTO :LAST-ID
               FROM RESTART
               WHERE PROGRAM = RTRIM(:PGM-NAME)
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.

           IF LAST-ID > ZERO
             DISPLAY "*** RESTARTING AFTER ID " LAST-ID " ***"
           ELSE
             DISPLAY "*** STARTING ***"
           END-IF.

           EXEC SQL
               DECLARE EMPCUR CURSOR FOR
               SELECT ID, FIRST_NAME, LAST_NAME,
                      TO_CHAR(DATE_OF_BIRTH, 'YYYY-MM-DD')
               FROM EMPLOYEES
               WHERE ID > :LAST-ID
               ORDER BY ID
           END-EXEC.
           EXEC SQL
               OPEN EMPCUR
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           MOVE 'Y' TO WS-CUR-OPEN.
           MOVE ' ' TO WS-EMP-EOF.

      * ================================================================
      * PROCESS-PARA
      * ================================================================
       PROCESS-PARA.
           PERFORM FETCH-PARA.
           PERFORM UNTIL WS-EMP-EOF = 'Y'

             IF EMP-ID = WS-FAIL-ID
               DISPLAY "*** SIMULATED FAILURE AT ID " EMP-ID " ***"
               PERFORM ABEND-PARA
             END-IF

             MOVE EMP-DOBM TO CA-MONTH
             MOVE EMP-DOBD TO CA-DAY
             MOVE EMP-DOBY TO CA-YEAR
             PERFORM CALCULATE-AGE-PARA
             MOVE CA-AGE TO EMP-AGE

             PERFORM UPDATE-PARA

             DISPLAY EMP-ID EMP-FNAME EMP-LNAME EMP-DOB " " EMP-AGE

             IF WS-UNCOMMITTED >= WS-COMMIT-FREQ
               PERFORM CHECKPOINT-PARA
             END-IF

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
      * UPDATE-PARA
      * ================================================================
       UPDATE-PARA.
           EXEC SQL
               UPDATE EMPLOYEES
               SET AGE = :EMP-AGE
               WHERE ID = :EMP-ID
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           ADD 1 TO WS-UPD-COUNT.
           ADD 1 TO WS-UNCOMMITTED.

      * ================================================================
      * CHECKPOINT-PARA
      * ================================================================
       CHECKPOINT-PARA.
      *    Save the restart point in the same unit of work as the
      *    updates, so they are committed together or not at all
           MOVE EMP-ID TO LAST-ID.
           EXEC SQL
               UPDATE RESTART
               SET LAST_ID = :LAST-ID
               WHERE PROGRAM = RTRIM(:PGM-NAME)
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           EXEC SQL
               COMMIT
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           MOVE ZERO TO WS-UNCOMMITTED.
           DISPLAY "*** CHECKPOINT AT ID " LAST-ID " ***".

      * ================================================================
      * FINISH-PARA
      * ================================================================
       FINISH-PARA.
      *    The run is complete, so the next run starts from the top
           MOVE ZERO TO LAST-ID.
           EXEC SQL
               UPDATE RESTART
               SET LAST_ID = :LAST-ID
               WHERE PROGRAM = RTRIM(:PGM-NAME)
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           EXEC SQL
               COMMIT
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           DISPLAY "ROWS UPDATED: " WS-UPD-COUNT.
           DISPLAY "*** COMPLETE ***".

      * ================================================================
      * COPY IN AGE CALC PARAGRAPH
      * ================================================================
       COPY "CALC_AGE_PARA.cob".
      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
      *    ERROR-RTN can get here before the cursor was opened
           IF WS-CUR-OPEN = 'Y'
             EXEC SQL
                 CLOSE EMPCUR
             END-EXEC
           END-IF.
           EXEC SQL
               CONNECT RESET
           END-EXEC.
      *    Set this last, the esqlOC calls overwrite RETURN-CODE
           MOVE WS-RC TO RETURN-CODE.
           STOP RUN.
