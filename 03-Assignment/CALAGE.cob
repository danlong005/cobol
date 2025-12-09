       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALAGE.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 DB-CON-STR      PIC        X(50).
       01 EMP-COUNT       PIC        9(04).
       EXEC SQL END DECLARE SECTION END-EXEC.
      *
       EXEC SQL INCLUDE SQLCA END-EXEC.
      * ================================================================
       PROCEDURE DIVISION.
       MAIN.
           DISPLAY "*** STARTING ***".

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

      * ================================================================
      * PROCESS-PARA
      * ================================================================
       PROCESS-PARA.
           EXEC SQL 
               SELECT COUNT(*)
               INTO :EMP-COUNT
               FROM EMPLOYEES
           END-EXEC.

           DISPLAY "TOTAL EMPLOYEES: " EMP-COUNT.

           EXEC SQL
               CONNECT RESET
           END-EXEC. 
                   

      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
           STOP RUN.
