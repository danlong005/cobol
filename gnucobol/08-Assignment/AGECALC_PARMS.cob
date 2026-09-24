      * ================================================================
      * PARAMETERS FOR AGECALC
      * The caller copies this into WORKING-STORAGE and AGECALC copies
      * it into its LINKAGE SECTION, so both sides agree on the layout
      * ================================================================
           01 AGECALC-PARMS.
      *       Passed in
              05 AC-BIRTH-DATE.
                 10 AC-BIRTH-Y   PIC     9(4).
                 10 AC-BIRTH-M   PIC     9(2).
                 10 AC-BIRTH-D   PIC     9(2).
              05 AC-BIRTH-DATE-N REDEFINES AC-BIRTH-DATE
                                 PIC     9(8).
      *       Passed back
              05 AC-AGE          PIC     9(3).
              05 AC-STATUS       PIC     X(1).
                 88 AC-OK                VALUE '0'.
                 88 AC-BAD-DATE          VALUE '1'.
