      * ================================================================
      * CALCULATE AGE
      * ================================================================
       CALCULATE-AGE-PARA.
           MOVE FUNCTION CURRENT-DATE TO CA-TODAY.

           COMPUTE CA-AGE = CA-TODAY-Y - CA-YEAR - 1
           IF CA-TODAY-M > CA-MONTH
             COMPUTE CA-AGE = CA-AGE + 1
           ELSE 
             IF CA-TODAY-M = CA-MONTH
               IF CA-TODAY-D >= CA-DAY
                 COMPUTE CA-AGE = CA-AGE + 1
               END-IF
             END-IF
           END-IF.
