      * ================================================================
      * AGECALC
      * Calculates an age from a date of birth. This is a subprogram,
      * compiled on its own into AGECALC.so and loaded when CALAGE
      * first calls it.
      * ================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. AGECALC.
      *
       DATA DIVISION.
           WORKING-STORAGE SECTION.
           01 WS-TODAY.
              05 WS-TODAY-Y   PIC        9(4).
              05 WS-TODAY-M   PIC        9(2).
              05 WS-TODAY-D   PIC        9(2).
      *
      *    The caller owns this storage, AGECALC only gets its address
           LINKAGE SECTION.
       COPY "AGECALC_PARMS.cob".
      *
       PROCEDURE DIVISION USING AGECALC-PARMS.
       MAIN.
           MOVE ZERO TO AC-AGE.

      *    TEST-DATE-YYYYMMDD returns 0 for a real date
           IF AC-BIRTH-DATE IS NOT NUMERIC
             SET AC-BAD-DATE TO TRUE
           ELSE
             IF FUNCTION TEST-DATE-YYYYMMDD(AC-BIRTH-DATE-N) NOT = 0
               SET AC-BAD-DATE TO TRUE
             ELSE
               SET AC-OK TO TRUE
               PERFORM CALCULATE-AGE-PARA
             END-IF
           END-IF.

      *    GOBACK returns to the caller. STOP RUN here would end the
      *    whole run unit, CALAGE included.
           GOBACK.

      * ================================================================
      * CALCULATE-AGE-PARA
      * ================================================================
       CALCULATE-AGE-PARA.
           MOVE FUNCTION CURRENT-DATE TO WS-TODAY.

           COMPUTE AC-AGE = WS-TODAY-Y - AC-BIRTH-Y - 1
           IF WS-TODAY-M > AC-BIRTH-M
             COMPUTE AC-AGE = AC-AGE + 1
           ELSE
             IF WS-TODAY-M = AC-BIRTH-M
               IF WS-TODAY-D >= AC-BIRTH-D
                 COMPUTE AC-AGE = AC-AGE + 1
               END-IF
             END-IF
           END-IF.
