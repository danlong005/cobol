       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAGE.
      *
       ENVIRONMENT DIVISION.
           INPUT-OUTPUT SECTION.
              FILE-CONTROL.
              SELECT EMPLOYEE ASSIGN TO './input.dta'
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
      *
           01 WS-TODAY.
              05 WS-TODAY-Y   PIC        9(4).
              05 WS-TODAY-M   PIC        9(2).
              05 WS-TODAY-D   PIC        9(2).
      *
           01 WS-AGE          PIC        9(3).
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
           MOVE FUNCTION CURRENT-DATE TO WS-TODAY.

      * ================================================================
      * PROCESS-PARA
      * ================================================================
       PROCESS-PARA.
           READ EMPLOYEE INTO EMPLOYEE-FILE
                AT END MOVE 'Y' TO WS-EMP-EOF
           END-READ.
           PERFORM UNTIL WS-EMP-EOF = 'Y'

             COMPUTE WS-AGE = WS-TODAY-Y - EMPDOBY - 1
             IF WS-TODAY-M > EMPDOBM
               COMPUTE WS-AGE = WS-AGE + 1
             ELSE
               IF WS-TODAY-M = EMPDOBM
                 IF WS-TODAY-D >= EMPDOBD
                   COMPUTE WS-AGE = WS-AGE + 1
                 END-IF
               END-IF
             END-IF

             DISPLAY EMPLOYEE-FILE, " ", WS-AGE

             READ EMPLOYEE INTO EMPLOYEE-FILE
                  AT END MOVE 'Y' TO WS-EMP-EOF
             END-READ
           END-PERFORM.

      * ================================================================
      * TERMINATE-PARA
      * ================================================================
       TERMINATE-PARA.
           CLOSE EMPLOYEE.
           STOP RUN.
