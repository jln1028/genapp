       PROCESS SQL
      ******************************************************************
      *                                                                *
      * (C) Copyright IBM Corp. 2026                                   *
      *                                                                *
      *              Customer Detail Report - Batch Program            *
      *                                                                *
      *   Generates a detailed report of all customers in the          *
      *   database including their contact information and address     *
      *                                                                *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LGCURPT1.
       AUTHOR. GENAPP DEVELOPMENT TEAM.
       DATE-WRITTEN. 2026-06-05.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-REPORT
               ASSIGN TO CUSTRPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.
      *
       DATA DIVISION.
      *
       FILE SECTION.
       FD  CUSTOMER-REPORT
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 133 CHARACTERS.
       01  REPORT-RECORD               PIC X(133).
      *
       WORKING-STORAGE SECTION.
      *
      *----------------------------------------------------------------*
      * Program identification and control fields                      *
      *----------------------------------------------------------------*
       01  WS-PROGRAM-INFO.
           05  WS-PROGRAM-NAME         PIC X(8)  VALUE 'LGCURPT1'.
           05  WS-PROGRAM-VERSION      PIC X(5)  VALUE '01.00'.
           05  WS-PROGRAM-DATE         PIC X(10) VALUE '2026-06-05'.
      *
      *----------------------------------------------------------------*
      * File status and control fields                                 *
      *----------------------------------------------------------------*
       01  WS-FILE-STATUS.
           05  WS-REPORT-STATUS        PIC XX    VALUE SPACES.
               88  REPORT-OK           VALUE '00'.
               88  REPORT-EOF          VALUE '10'.
               88  REPORT-ERROR        VALUE '30' THRU '99'.
      *
      *----------------------------------------------------------------*
      * Counters and accumulators                                      *
      *----------------------------------------------------------------*
       01  WS-COUNTERS.
           05  WS-CUSTOMER-COUNT       PIC 9(7)  VALUE ZERO COMP-3.
           05  WS-LINE-COUNT           PIC 9(3)  VALUE ZERO COMP-3.
           05  WS-PAGE-COUNT           PIC 9(5)  VALUE ZERO COMP-3.
           05  WS-ERROR-COUNT          PIC 9(5)  VALUE ZERO COMP-3.
      *
      *----------------------------------------------------------------*
      * Constants                                                      *
      *----------------------------------------------------------------*
       01  WS-CONSTANTS.
           05  WS-LINES-PER-PAGE       PIC 9(3)  VALUE 55  COMP-3.
           05  WS-MAX-ERRORS           PIC 9(3)  VALUE 10  COMP-3.
      *
      *----------------------------------------------------------------*
      * Date and time fields                                           *
      *----------------------------------------------------------------*
       01  WS-DATE-TIME-FIELDS.
           05  WS-CURRENT-DATE.
               10  WS-CURR-YEAR        PIC 9(4).
               10  WS-CURR-MONTH       PIC 9(2).
               10  WS-CURR-DAY         PIC 9(2).
           05  WS-CURRENT-TIME.
               10  WS-CURR-HOUR        PIC 9(2).
               10  WS-CURR-MINUTE      PIC 9(2).
               10  WS-CURR-SECOND      PIC 9(2).
           05  WS-FORMATTED-DATE       PIC X(10).
           05  WS-FORMATTED-TIME       PIC X(8).
      *
      *----------------------------------------------------------------*
      * Report header lines                                            *
      *----------------------------------------------------------------*
       01  WS-REPORT-HEADER-1.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(30) VALUE
               'CUSTOMER DETAIL REPORT'.
           05  FILLER                  PIC X(52) VALUE SPACES.
           05  FILLER                  PIC X(6)  VALUE 'PAGE: '.
           05  HDR1-PAGE-NUM           PIC ZZZ9.
           05  FILLER                  PIC X(40) VALUE SPACES.
      *
       01  WS-REPORT-HEADER-2.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(6)  VALUE 'DATE: '.
           05  HDR2-DATE               PIC X(10).
           05  FILLER                  PIC X(5)  VALUE SPACES.
           05  FILLER                  PIC X(6)  VALUE 'TIME: '.
           05  HDR2-TIME               PIC X(8).
           05  FILLER                  PIC X(97) VALUE SPACES.
      *
       01  WS-REPORT-HEADER-3.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(132) VALUE ALL '-'.
      *
       01  WS-COLUMN-HEADER-1.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(10) VALUE 'CUSTOMER'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(10) VALUE 'FIRST'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(20) VALUE 'LAST'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(10) VALUE 'DATE OF'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(20) VALUE 'MOBILE'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(20) VALUE 'HOME'.
           05  FILLER                  PIC X(33) VALUE SPACES.
      *
       01  WS-COLUMN-HEADER-2.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(10) VALUE 'NUMBER'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(10) VALUE 'NAME'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(20) VALUE 'NAME'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(10) VALUE 'BIRTH'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(20) VALUE 'PHONE'.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(20) VALUE 'PHONE'.
           05  FILLER                  PIC X(33) VALUE SPACES.
      *
       01  WS-COLUMN-HEADER-3.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(132) VALUE ALL '-'.
      *
      *----------------------------------------------------------------*
      * Detail line format                                             *
      *----------------------------------------------------------------*
       01  WS-DETAIL-LINE-1.
           05  FILLER                  PIC X     VALUE SPACE.
           05  DTL1-CUSTOMER-NUM       PIC Z(9)9.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  DTL1-FIRST-NAME         PIC X(10).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  DTL1-LAST-NAME          PIC X(20).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  DTL1-DOB                PIC X(10).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  DTL1-PHONE-MOBILE       PIC X(20).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  DTL1-PHONE-HOME         PIC X(20).
           05  FILLER                  PIC X(33) VALUE SPACES.
      *
       01  WS-DETAIL-LINE-2.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(12) VALUE 'ADDRESS:    '.
           05  DTL2-HOUSE-NUM          PIC X(4).
           05  FILLER                  PIC X     VALUE SPACE.
           05  DTL2-HOUSE-NAME         PIC X(20).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  FILLER                  PIC X(10) VALUE 'POSTCODE: '.
           05  DTL2-POSTCODE           PIC X(8).
           05  FILLER                  PIC X(75) VALUE SPACES.
      *
       01  WS-DETAIL-LINE-3.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(12) VALUE 'EMAIL:      '.
           05  DTL3-EMAIL              PIC X(100).
           05  FILLER                  PIC X(20) VALUE SPACES.
      *
       01  WS-BLANK-LINE.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(132) VALUE SPACES.
      *
      *----------------------------------------------------------------*
      * Summary line format                                            *
      *----------------------------------------------------------------*
       01  WS-SUMMARY-LINE.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(132) VALUE ALL '='.
      *
       01  WS-TOTAL-LINE.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(25) VALUE
               'TOTAL CUSTOMERS LISTED: '.
           05  TOT-CUSTOMER-COUNT      PIC ZZZ,ZZ9.
           05  FILLER                  PIC X(101) VALUE SPACES.
      *
      *----------------------------------------------------------------*
      * Error message line                                             *
      *----------------------------------------------------------------*
       01  WS-ERROR-LINE.
           05  FILLER                  PIC X     VALUE SPACE.
           05  FILLER                  PIC X(8)  VALUE '** ERROR'.
           05  FILLER                  PIC X(3)  VALUE ' - '.
           05  ERR-MESSAGE             PIC X(100).
           05  FILLER                  PIC X(21) VALUE SPACES.
      *
      *----------------------------------------------------------------*
      * DB2 host variables for customer data                           *
      *----------------------------------------------------------------*
       01  DB2-CUSTOMER-RECORD.
           05  DB2-CUSTOMER-NUM        PIC S9(9)  COMP.
           05  DB2-FIRST-NAME          PIC X(10).
           05  DB2-LAST-NAME           PIC X(20).
           05  DB2-DOB                 PIC X(10).
           05  DB2-HOUSE-NAME          PIC X(20).
           05  DB2-HOUSE-NUM           PIC X(4).
           05  DB2-POSTCODE            PIC X(8).
           05  DB2-PHONE-MOBILE        PIC X(20).
           05  DB2-PHONE-HOME          PIC X(20).
           05  DB2-EMAIL-ADDRESS       PIC X(100).
      *
      *----------------------------------------------------------------*
      * DB2 cursor control                                             *
      *----------------------------------------------------------------*
       01  WS-END-OF-CURSOR            PIC X     VALUE 'N'.
           88  END-OF-CURSOR           VALUE 'Y'.
           88  NOT-END-OF-CURSOR       VALUE 'N'.
      *
      *----------------------------------------------------------------*
      * DB2 SQLCA - SQL Communications Area                            *
      *----------------------------------------------------------------*
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.
      *
      ******************************************************************
      *    P R O C E D U R E   D I V I S I O N
      ******************************************************************
       PROCEDURE DIVISION.
      *
      *----------------------------------------------------------------*
       0000-MAIN-PROCESS.
      *----------------------------------------------------------------*
      *    Main processing routine                                     *
      *----------------------------------------------------------------*
           PERFORM 1000-INITIALIZE-PROGRAM
           PERFORM 2000-PROCESS-CUSTOMERS
           PERFORM 3000-TERMINATE-PROGRAM
           STOP RUN.
      *
      *----------------------------------------------------------------*
       1000-INITIALIZE-PROGRAM.
      *----------------------------------------------------------------*
      *    Initialize program variables and open files                 *
      *----------------------------------------------------------------*
           DISPLAY WS-PROGRAM-NAME ' STARTING'
           PERFORM 1100-GET-CURRENT-DATE-TIME
           PERFORM 1200-OPEN-REPORT-FILE
           PERFORM 1300-PRINT-REPORT-HEADERS
           PERFORM 1400-OPEN-CUSTOMER-CURSOR.
      *
      *----------------------------------------------------------------*
       1100-GET-CURRENT-DATE-TIME.
      *----------------------------------------------------------------*
      *    Obtain current date and time for report header             *
      *----------------------------------------------------------------*
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE
           STRING WS-CURR-MONTH '/' WS-CURR-DAY '/' WS-CURR-YEAR
               DELIMITED BY SIZE
               INTO WS-FORMATTED-DATE
           END-STRING
           STRING WS-CURR-HOUR ':' WS-CURR-MINUTE ':' WS-CURR-SECOND
               DELIMITED BY SIZE
               INTO WS-FORMATTED-TIME
           END-STRING.
      *
      *----------------------------------------------------------------*
       1200-OPEN-REPORT-FILE.
      *----------------------------------------------------------------*
      *    Open the output report file                                 *
      *----------------------------------------------------------------*
           OPEN OUTPUT CUSTOMER-REPORT
           IF NOT REPORT-OK
               DISPLAY 'ERROR OPENING REPORT FILE'
               DISPLAY 'FILE STATUS: ' WS-REPORT-STATUS
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF.
      *
      *----------------------------------------------------------------*
       1300-PRINT-REPORT-HEADERS.
      *----------------------------------------------------------------*
      *    Print report page headers                                   *
      *----------------------------------------------------------------*
           ADD 1 TO WS-PAGE-COUNT
           MOVE WS-PAGE-COUNT TO HDR1-PAGE-NUM
           MOVE WS-FORMATTED-DATE TO HDR2-DATE
           MOVE WS-FORMATTED-TIME TO HDR2-TIME
           WRITE REPORT-RECORD FROM WS-REPORT-HEADER-1
               AFTER ADVANCING PAGE
           WRITE REPORT-RECORD FROM WS-REPORT-HEADER-2
               AFTER ADVANCING 1 LINE
           WRITE REPORT-RECORD FROM WS-REPORT-HEADER-3
               AFTER ADVANCING 1 LINE
           WRITE REPORT-RECORD FROM WS-BLANK-LINE
               AFTER ADVANCING 1 LINE
           WRITE REPORT-RECORD FROM WS-COLUMN-HEADER-1
               AFTER ADVANCING 1 LINE
           WRITE REPORT-RECORD FROM WS-COLUMN-HEADER-2
               AFTER ADVANCING 1 LINE
           WRITE REPORT-RECORD FROM WS-COLUMN-HEADER-3
               AFTER ADVANCING 1 LINE
           MOVE 7 TO WS-LINE-COUNT.
      *
      *----------------------------------------------------------------*
       1400-OPEN-CUSTOMER-CURSOR.
      *----------------------------------------------------------------*
      *    Declare and open DB2 cursor for customer records           *
      *----------------------------------------------------------------*
           EXEC SQL
               DECLARE CUSTOMER-CURSOR CURSOR FOR
               SELECT CUSTOMERNUMBER,
                      FIRSTNAME,
                      LASTNAME,
                      DATEOFBIRTH,
                      HOUSENAME,
                      HOUSENUMBER,
                      POSTCODE,
                      PHONEMOBILE,
                      PHONEHOME,
                      EMAILADDRESS
               FROM CUSTOMER
               ORDER BY CUSTOMERNUMBER
           END-EXEC
      *
           EXEC SQL
               OPEN CUSTOMER-CURSOR
           END-EXEC
      *
           IF SQLCODE NOT = 0
               MOVE 'FAILED TO OPEN CUSTOMER CURSOR' TO ERR-MESSAGE
               PERFORM 9100-WRITE-ERROR-LINE
               PERFORM 9200-DISPLAY-SQL-ERROR
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF.
      *
      *----------------------------------------------------------------*
       2000-PROCESS-CUSTOMERS.
      *----------------------------------------------------------------*
      *    Main processing loop - fetch and print customer records    *
      *----------------------------------------------------------------*
           PERFORM 2100-FETCH-CUSTOMER-RECORD
           PERFORM UNTIL END-OF-CURSOR
               PERFORM 2200-PRINT-CUSTOMER-DETAIL
               PERFORM 2100-FETCH-CUSTOMER-RECORD
           END-PERFORM
           PERFORM 2300-PRINT-SUMMARY.
      *
      *----------------------------------------------------------------*
       2100-FETCH-CUSTOMER-RECORD.
      *----------------------------------------------------------------*
      *    Fetch next customer record from cursor                      *
      *----------------------------------------------------------------*
           EXEC SQL
               FETCH CUSTOMER-CURSOR
               INTO :DB2-CUSTOMER-NUM,
                    :DB2-FIRST-NAME,
                    :DB2-LAST-NAME,
                    :DB2-DOB,
                    :DB2-HOUSE-NAME,
                    :DB2-HOUSE-NUM,
                    :DB2-POSTCODE,
                    :DB2-PHONE-MOBILE,
                    :DB2-PHONE-HOME,
                    :DB2-EMAIL-ADDRESS
           END-EXEC
      *
           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN 100
                   SET END-OF-CURSOR TO TRUE
               WHEN OTHER
                   MOVE 'ERROR FETCHING CUSTOMER RECORD'
                       TO ERR-MESSAGE
                   PERFORM 9100-WRITE-ERROR-LINE
                   PERFORM 9200-DISPLAY-SQL-ERROR
                   ADD 1 TO WS-ERROR-COUNT
                   IF WS-ERROR-COUNT > WS-MAX-ERRORS
                       DISPLAY 'MAXIMUM ERRORS EXCEEDED - TERMINATING'
                       MOVE 16 TO RETURN-CODE
                       STOP RUN
                   END-IF
           END-EVALUATE.
      *
      *----------------------------------------------------------------*
       2200-PRINT-CUSTOMER-DETAIL.
      *----------------------------------------------------------------*
      *    Print customer detail lines                                 *
      *----------------------------------------------------------------*
           IF WS-LINE-COUNT > WS-LINES-PER-PAGE
               PERFORM 1300-PRINT-REPORT-HEADERS
           END-IF
      *
           ADD 1 TO WS-CUSTOMER-COUNT
      *
           MOVE DB2-CUSTOMER-NUM   TO DTL1-CUSTOMER-NUM
           MOVE DB2-FIRST-NAME     TO DTL1-FIRST-NAME
           MOVE DB2-LAST-NAME      TO DTL1-LAST-NAME
           MOVE DB2-DOB            TO DTL1-DOB
           MOVE DB2-PHONE-MOBILE   TO DTL1-PHONE-MOBILE
           MOVE DB2-PHONE-HOME     TO DTL1-PHONE-HOME
      *
           WRITE REPORT-RECORD FROM WS-DETAIL-LINE-1
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-LINE-COUNT
      *
           MOVE DB2-HOUSE-NUM      TO DTL2-HOUSE-NUM
           MOVE DB2-HOUSE-NAME     TO DTL2-HOUSE-NAME
           MOVE DB2-POSTCODE       TO DTL2-POSTCODE
      *
           WRITE REPORT-RECORD FROM WS-DETAIL-LINE-2
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-LINE-COUNT
      *
           MOVE DB2-EMAIL-ADDRESS  TO DTL3-EMAIL
      *
           WRITE REPORT-RECORD FROM WS-DETAIL-LINE-3
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-LINE-COUNT
      *
           WRITE REPORT-RECORD FROM WS-BLANK-LINE
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-LINE-COUNT.
      *
      *----------------------------------------------------------------*
       2300-PRINT-SUMMARY.
      *----------------------------------------------------------------*
      *    Print report summary totals                                 *
      *----------------------------------------------------------------*
           WRITE REPORT-RECORD FROM WS-SUMMARY-LINE
               AFTER ADVANCING 2 LINES
           ADD 2 TO WS-LINE-COUNT
      *
           MOVE WS-CUSTOMER-COUNT TO TOT-CUSTOMER-COUNT
           WRITE REPORT-RECORD FROM WS-TOTAL-LINE
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-LINE-COUNT
      *
           WRITE REPORT-RECORD FROM WS-SUMMARY-LINE
               AFTER ADVANCING 1 LINE.
      *
      *----------------------------------------------------------------*
       3000-TERMINATE-PROGRAM.
      *----------------------------------------------------------------*
      *    Close files and display completion message                  *
      *----------------------------------------------------------------*
           PERFORM 3100-CLOSE-CUSTOMER-CURSOR
           PERFORM 3200-CLOSE-REPORT-FILE
           DISPLAY WS-PROGRAM-NAME ' COMPLETED SUCCESSFULLY'
           DISPLAY 'TOTAL CUSTOMERS PROCESSED: ' WS-CUSTOMER-COUNT
           DISPLAY 'TOTAL PAGES PRINTED: ' WS-PAGE-COUNT
           IF WS-ERROR-COUNT > 0
               DISPLAY 'TOTAL ERRORS ENCOUNTERED: ' WS-ERROR-COUNT
           END-IF.
      *
      *----------------------------------------------------------------*
       3100-CLOSE-CUSTOMER-CURSOR.
      *----------------------------------------------------------------*
      *    Close DB2 cursor                                            *
      *----------------------------------------------------------------*
           EXEC SQL
               CLOSE CUSTOMER-CURSOR
           END-EXEC
      *
           IF SQLCODE NOT = 0
               DISPLAY 'WARNING: ERROR CLOSING CURSOR'
               PERFORM 9200-DISPLAY-SQL-ERROR
           END-IF.
      *
      *----------------------------------------------------------------*
       3200-CLOSE-REPORT-FILE.
      *----------------------------------------------------------------*
      *    Close output report file                                    *
      *----------------------------------------------------------------*
           CLOSE CUSTOMER-REPORT
           IF NOT REPORT-OK
               DISPLAY 'WARNING: ERROR CLOSING REPORT FILE'
               DISPLAY 'FILE STATUS: ' WS-REPORT-STATUS
           END-IF.
      *
      *----------------------------------------------------------------*
       9100-WRITE-ERROR-LINE.
      *----------------------------------------------------------------*
      *    Write error message to report                               *
      *----------------------------------------------------------------*
           WRITE REPORT-RECORD FROM WS-ERROR-LINE
               AFTER ADVANCING 2 LINES
           ADD 2 TO WS-LINE-COUNT.
      *
      *----------------------------------------------------------------*
       9200-DISPLAY-SQL-ERROR.
      *----------------------------------------------------------------*
      *    Display DB2 error information                               *
      *----------------------------------------------------------------*
           DISPLAY 'DB2 ERROR INFORMATION:'
           DISPLAY '  SQLCODE: ' SQLCODE
           DISPLAY '  SQLERRM: ' SQLERRM.
      *
      ******************************************************************
      *    E N D   O F   P R O G R A M
      ******************************************************************

      *> Made with Bob
