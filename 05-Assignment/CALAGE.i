#line 1 "/home/dlong/source/repos/cobol/05-Assignment/CALAGE.cob"
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CALCAGE-SQL-CB.
 * 
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 *
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 EXEC SQL BEGIN DECLARE SECTION END-EXEC.
 01 DBNAME PIC X(30) VALUE SPACE.
 01 USERNAME PIC X(30) VALUE SPACE.
 01 PASSWD PIC X(10) VALUE SPACE.
 01 EMP-FNAME PIC X(20) VALUE SPACE.
 01 EMP-LNAME PIC X(20) VALUE SPACE.
 01 EMP-DOB PIC X(10) VALUE SPACE.
 EXEC SQL END DECLARE SECTION END-EXEC.
 *
 EXEC SQL 
 *
 01 WS-EMP-EOF PIC A(1).
 01 AGE PIC 9(3).

 
#line 1 "CALC_AGE_DEF.cob"
 * ================================================================
 * DEFINITIONS NEEDED FOR PARAGRAPH
 * ================================================================
 01 CA-AGE PIC 9(3).
 01 CA-YEAR PIC 9(4).
 01 CA-MONTH PIC 9(2).
 01 CA-DAY PIC 9(2).
 01 CA-TODAY.
 05 CA-TODAY-Y PIC 9(4).
 05 CA-TODAY-M PIC 9(2).
 05 CA-TODAY-D PIC 9(2).
#line 23 "/home/dlong/source/repos/cobol/05-Assignment/CALAGE.cob"


 *
 PROCEDURE DIVISION.
 MAIN.

 * CONNECT
 MOVE "cobol@localhost" TO DBNAME.
 MOVE "admin" TO USERNAME.
 MOVE "password" TO PASSWD.

 EXEC SQL 
 CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME
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
 * 


 * ================================================================
 * TERMINATE-PARA
 * ================================================================
 TERMINATE-PARA.
 CLOSE EMPLOYEE.
 STOP RUN.
