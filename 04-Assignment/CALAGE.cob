       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE-SEP-COMP.
      * 
       ENVIRONMENT DIVISION.
           INPUT-OUTPUT SECTION.
              FILE-CONTROL.
              SELECT EMPLOYEE ASSIGN TO 'input.dta'
              ORGANIZATION IS LINE SEQUENTIAL.
      *
       DATA DIVISION.
           FILE SECTION.
           FD EMPLOYEE.
           01 EMPLOYEE-FILE.
              05 EMPID        PIC        9(3).
              05 EMPFNM       PIC       A(15).
              05 EMPLNM       PIC       A(20).
              05 EMPDOB.
                 07 EMPDOBY   PIC        9(4).
                 07 EMPDOBS   PIC        A(1).
                 07 EMPDOBM   PIC        9(2).
                 07 EMPDOBS1  PIC        A(1).
                 07 EMPDOBD   PIC        9(2).
      *
           WORKING-STORAGE SECTION.
           01 WS-EMP-EOF      PIC        A(1).
           01 AGE             PIC        9(3).

       COPY "CALC_AGE_DEF.cob".

      *
       PROCEDURE DIVISION.
       MAIN.
           PERFORM INITIALIZE-PARA.
           PERFORM PROCESS-PARA.
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
           CLOSE EMPLOYEE.
           STOP RUN.
