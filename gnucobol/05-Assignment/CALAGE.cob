       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE-SQL-CB.
      * 
       ENVIRONMENT DIVISION.
           INPUT-OUTPUT SECTION.
      *
       DATA DIVISION.
           WORKING-STORAGE SECTION.
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
           01 DBNAME          PIC        X(30) VALUE SPACE.
           01 USERNAME        PIC        X(30) VALUE SPACE.
           01 PASSWD          PIC        X(10) VALUE SPACE.
           01 EMP-FNAME       PIC        X(20) VALUE SPACE.
           01 EMP-LNAME       PIC        X(20) VALUE SPACE.
           01 EMP-DOB         PIC        X(10) VALUE SPACE.
           01 DB-CON-STR      PIC        X(50).
           EXEC SQL END DECLARE SECTION END-EXEC.
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
           EXEC SQL 
               CONNECT RESET
           END-EXEC.
           CLOSE EMPLOYEE.
           STOP RUN.
