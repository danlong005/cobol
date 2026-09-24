       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE-SUBPGM.
      *
       DATA DIVISION.
           WORKING-STORAGE SECTION.
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
           01 DB-CON-STR      PIC        X(50).
           01 EMP-ID          PIC        9(3).
           01 EMP-FNAME       PIC        X(15).
           01 EMP-LNAME       PIC        X(20).
           01 EMP-AGE         PIC        9(3).
           01 EMP-DOB         PIC        X(10).
           EXEC SQL END DECLARE SECTION END-EXEC.
      *    esqlOC can't bind a group item, so split the date here
           01 EMP-DOB-PARTS REDEFINES EMP-DOB.
              05 EMP-DOBY     PIC        X(4).
              05 EMP-DOBS     PIC        X(1).
              05 EMP-DOBM     PIC        X(2).
              05 EMP-DOBS1    PIC        X(1).
              05 EMP-DOBD     PIC        X(2).
      *
           EXEC SQL INCLUDE SQLCA END-EXEC.
      *
           01 WS-EMP-EOF-SW   PIC        X(1)  VALUE 'N'.
              88 EMP-EOF                       VALUE 'Y'.
           01 WS-CUR-OPEN-SW  PIC        X(1)  VALUE 'N'.
              88 CUR-OPEN                      VALUE 'Y'.
           01 WS-UPD-COUNT    PIC        9(4)  VALUE ZERO.
           01 WS-SKIP-COUNT   PIC        9(4)  VALUE ZERO.
           01 WS-RC           PIC        9(2)  VALUE ZERO.

       COPY "AGECALC_PARMS.cob".

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
           PERFORM COMMIT-PARA.
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
      *    Undo any updates made before the error. Without this the
      *    CONNECT RESET in TERMINATE-PARA would commit them.
           EXEC SQL
               ROLLBACK
           END-EXEC.
           MOVE 16 TO WS-RC.
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
           SET CUR-OPEN TO TRUE.

      * ================================================================
      * PROCESS-PARA
      * ================================================================
       PROCESS-PARA.
           PERFORM FETCH-PARA.
           PERFORM UNTIL EMP-EOF

             MOVE EMP-DOBY TO AC-BIRTH-Y
             MOVE EMP-DOBM TO AC-BIRTH-M
             MOVE EMP-DOBD TO AC-BIRTH-D
      *      BY REFERENCE is the default: AGECALC works on our copy
      *      of AGECALC-PARMS, which is how AC-AGE gets back to us
             CALL 'AGECALC' USING AGECALC-PARMS
      *        The module couldn't be loaded, see Assignment.md
               ON EXCEPTION
                 DISPLAY "*** AGECALC NOT FOUND ***"
                 PERFORM ABEND-PARA
             END-CALL

             IF AC-OK
               MOVE AC-AGE TO EMP-AGE
               PERFORM UPDATE-PARA
               DISPLAY EMP-ID EMP-FNAME EMP-LNAME EMP-DOB " " EMP-AGE
             ELSE
               ADD 1 TO WS-SKIP-COUNT
               DISPLAY EMP-ID EMP-FNAME EMP-LNAME EMP-DOB
                       " *** BAD DATE, SKIPPED ***"
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
             SET EMP-EOF TO TRUE
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

      * ================================================================
      * COMMIT-PARA
      * ================================================================
       COMMIT-PARA.
           EXEC SQL
               COMMIT
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           DISPLAY "ROWS UPDATED: " WS-UPD-COUNT.
           DISPLAY "ROWS SKIPPED: " WS-SKIP-COUNT.

      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
      *    ERROR-RTN can get here before the cursor was opened
           IF CUR-OPEN
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
