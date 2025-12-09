       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALAGE.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 DSN             PIC        X(30) VALUE 'COBODBC'.
       01 USERNAME        PIC        X(30) VALUE 'admin'.
       01 PASSWD          PIC        X(10) VALUE 'password'.
       01 DB-CON-STR      PIC        X(100).
       01 WS-NUMBER       PIC        9(9).
       EXEC SQL END DECLARE SECTION END-EXEC.
      *
       EXEC SQL INCLUDE SQLCA END-EXEC.
      * ================================================================
       PROCEDURE DIVISION.
       MAIN.
           DISPLAY "*** STARTING ***".

           STRING FUNCTION TRIM(USERNAME) DELIMITED BY SPACE 
                  "/" DELIMITED BY SIZE
                  FUNCTION TRIM(PASSWD)   DELIMITED BY SPACE
                  "@" DELIMITED BY SIZE
                  FUNCTION TRIM(DSN)      DELIMITED BY SPACE
                  INTO DB-CON-STR
           END-STRING.
      
           EXEC SQL 
               CONNECT TO :DB-CON-STR
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN.

           DISPLAY "*** SQL CODE ***".
           DISPLAY "SQLCODE: " SQLCODE " ".

           EXEC SQL 
                SELECT COUNT(*)
                INTO :WS-NUMBER
                FROM EMPLOYEES
           END-EXEC.

           IF SQLCODE NOT = ZERO  PERFORM ERROR-RTN.
           DISPLAY "NUMBER OF EMPLOYEES: " WS-NUMBER.
           DISPLAY "*** SQL CODE ***".
           DISPLAY "SQLCODE: " SQLCODE " ".
           
           EXEC SQL 
                CONNECT RESET
           END-EXEC.
           DISPLAY "*** SQL CODE ***".
           DISPLAY "SQLCODE: " SQLCODE " ".
           
           PERFORM TERMINATE-PARA.
           
      * ================================================================
      * ERROR-RTN PARA
      * ================================================================
       ERROR-RTN.
           DISPLAY "*** SQL CODE ***".
           DISPLAY "SQLCODE: " SQLCODE " ".
           PERFORM TERMINATE-PARA.

      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
           STOP RUN.
