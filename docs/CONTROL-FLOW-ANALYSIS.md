# Control Flow and PERFORM Structure Analysis

## Overview

This document provides detailed analysis of control flow patterns, PERFORM paragraph structures, and execution paths within the GenApp CICS application. It covers all three architectural tiers: Presentation, Business Logic, and Database Access layers.

## Table of Contents

1. [Presentation Layer Control Flow](#presentation-layer-control-flow)
2. [Business Logic Layer Control Flow](#business-logic-layer-control-flow)
3. [Database Access Layer Control Flow](#database-access-layer-control-flow)
4. [PERFORM Paragraph Patterns](#perform-paragraph-patterns)
5. [Error Handling Flow](#error-handling-flow)

## Presentation Layer Control Flow

### LGTESTC1 - Customer Menu Program

#### Main Control Flow Structure

```cobol
MAINLINE SECTION (Line 53)
│
├─ IF EIBCALEN > 0 → GO TO A-GAIN (Lines 55-56)
│  └─ Pseudo-conversational restart
│
├─ Initialize SSMAPC1I (Line 58)
├─ Initialize SSMAPC1O (Line 59)
├─ Initialize COMM-AREA (Line 60)
├─ MOVE '0000000000' To ENT1CNOO (Line 61)
│
├─ EXEC CICS SEND MAP ('SSMAPC1') (Lines 64-68)
│  └─ Display initial screen
│
└─ A-GAIN Section (Line 70)
   │
   ├─ EXEC CICS HANDLE AID (Lines 72-74)
   │  ├─ CLEAR(CLEARIT)
   │  └─ PF3(ENDIT)
   │
   ├─ EXEC CICS HANDLE CONDITION MAPFAIL(ENDIT) (Lines 75-77)
   │
   ├─ EXEC CICS RECEIVE MAP('SSMAPC1') (Lines 79-81)
   │
   └─ EVALUATE ENP1OPTO (Lines 84-222)
      │
      ├─ WHEN '1' - Inquire Customer (Lines 86-111)
      │  ├─ Move '01ICUS' To CA-REQUEST-ID (Line 87)
      │  ├─ Move ENT1CNOO To CA-CUSTOMER-NUM (Line 88)
      │  ├─ EXEC CICS LINK PROGRAM('LGICUS01') (Lines 89-92)
      │  ├─ IF CA-RETURN-CODE > 0 → GO TO NO-DATA (Lines 94-96)
      │  ├─ Move CA-* fields to ENT1* map fields (Lines 98-106)
      │  ├─ EXEC CICS SEND MAP (Lines 107-110)
      │  └─ GO TO ENDIT-STARTIT (Line 111)
      │
      ├─ WHEN '2' - Add Customer (Lines 113-146)
      │  ├─ Move '01ACUS' To CA-REQUEST-ID (Line 114)
      │  ├─ Move 0 To CA-CUSTOMER-NUM (Line 115)
      │  ├─ Move ENT1* map fields to CA-* fields (Lines 116-124)
      │  ├─ Inspect COMM-AREA Replacing x'00' by x'40' (Line 125)
      │  ├─ Move Function UPPER-CASE(CA-POSTCODE) (Lines 126-127)
      │  ├─ EXEC CICS LINK PROGRAM('LGACUS01') (Lines 128-131)
      │  ├─ IF CA-RETURN-CODE > 0 (Lines 132-135)
      │  │  ├─ Exec CICS Syncpoint Rollback (Line 133)
      │  │  └─ GO TO NO-ADD
      │  ├─ Perform WRITE-GENACNTL (Line 137)
      │  ├─ Move CA-CUSTOMER-NUM To ENT1CNOI (Line 138)
      │  ├─ Move 'New Customer Inserted' To ERRFLDO (Lines 140-141)
      │  ├─ EXEC CICS SEND MAP (Lines 142-145)
      │  └─ GO TO ENDIT-STARTIT (Line 146)
      │
      ├─ WHEN '4' - Update Customer (Lines 148-207)
      │  ├─ Move '01ICUS' To CA-REQUEST-ID (Line 149)
      │  ├─ Move ENT1CNOO To CA-CUSTOMER-NUM (Line 150)
      │  ├─ EXEC CICS LINK PROGRAM('LGICUS01') (Lines 151-154)
      │  ├─ IF CA-RETURN-CODE > 0 → GO TO NO-DATA (Lines 155-157)
      │  ├─ Move CA-* fields to ENT1* map fields (Lines 159-167)
      │  ├─ EXEC CICS SEND MAP (Lines 168-171)
      │  ├─ EXEC CICS RECEIVE MAP (Lines 172-174)
      │  ├─ Move '01UCUS' To CA-REQUEST-ID (Line 176)
      │  ├─ Move ENT1* map fields to CA-* fields (Lines 177-186)
      │  ├─ Inspect COMM-AREA Replacing x'00' by x'40' (Line 187)
      │  ├─ Move Function UPPER-CASE(CA-POSTCODE) (Lines 188-189)
      │  ├─ EXEC CICS LINK PROGRAM('LGUCUS01') (Lines 190-193)
      │  ├─ IF CA-RETURN-CODE > 0 → GO TO NO-UPD (Lines 195-197)
      │  ├─ Move 'Customer details updated' To ERRFLDO (Lines 201-202)
      │  ├─ EXEC CICS SEND MAP (Lines 203-206)
      │  └─ GO TO ENDIT-STARTIT (Line 207)
      │
      └─ WHEN OTHER - Invalid Option (Lines 209-220)
         ├─ Move 'Please enter a valid option' To ERRFLDO (Lines 211-212)
         ├─ Move -1 To ENT1OPTL (Line 213)
         ├─ EXEC CICS SEND MAP CURSOR (Lines 215-219)
         └─ GO TO ENDIT-STARTIT (Line 220)
```

#### Exit Points

```cobol
ENDIT-STARTIT (Lines 230-234)
├─ EXEC CICS RETURN
│       TRANSID('SSC1')
│       COMMAREA(COMM-AREA)
└─ END-EXEC
   └─ Restarts transaction with preserved state

ENDIT (Lines 236-244)
├─ EXEC CICS SEND TEXT FROM(MSGEND) ERASE FREEKB
└─ EXEC CICS RETURN
   └─ Terminates conversation

CLEARIT (Lines 246-257)
├─ Initialize SSMAPC1I
├─ EXEC CICS SEND MAP MAPONLY
└─ EXEC CICS RETURN TRANSID('SSC1') COMMAREA
   └─ Clears screen and restarts
```

#### Error Handling Paragraphs

```cobol
NO-UPD (Lines 259-261)
├─ Move 'Error Updating Customer' To ERRFLDO
└─ Go To ERROR-OUT

NO-ADD (Lines 263-265)
├─ Move 'Error Adding Customer' To ERRFLDO
└─ Go To ERROR-OUT

NO-DATA (Lines 267-269)
├─ Move 'No data was returned.' To ERRFLDO
└─ Go To ERROR-OUT

ERROR-OUT (Lines 271-281)
├─ EXEC CICS SEND MAP
├─ Initialize SSMAPC1I
├─ Initialize SSMAPC1O
├─ Initialize COMM-AREA
└─ GO TO ENDIT-STARTIT
```

### PERFORM Paragraph: WRITE-GENACNTL

**Purpose**: Update temporary storage queue with new customer number range

**Location**: Lines 283-347 in LGTESTC1

**Control Flow**:

```cobol
WRITE-GENACNTL
│
├─ EXEC CICS ENQ Resource(STSQ-NAME) (Lines 285-287)
│  └─ Lock the GENACNTL queue for exclusive access
│
├─ Move 'Y' To WS-FLAG-TSQH (Line 288)
├─ Move 1 To WS-Item-Count (Line 289)
│
├─ Exec CICS ReadQ TS Queue(STSQ-NAME) Item(1) (Lines 290-294)
│  └─ Read first item from queue
│
├─ If WS-RESP = DFHRESP(NORMAL) (Line 295)
│  └─ Perform With Test after Until WS-RESP > 0 (Lines 296-316)
│     │
│     ├─ Exec CICS ReadQ TS Next (Lines 297-301)
│     ├─ Add 1 To WS-Item-Count (Line 302)
│     │
│     └─ If WS-RESP = DFHRESP(NORMAL) And
│        Read-Msg-Msg(1:13) = 'HIGH CUSTOMER' (Lines 303-304)
│        │
│        ├─ Move CA-Customer-Num To Write-Msg-High (Line 305)
│        ├─ Move Space to WS-FLAG-TSQH (Line 306)
│        ├─ Exec CICS WriteQ TS ReWrite (Lines 307-313)
│        └─ MOVE 99 To WS-RESP (Line 314)
│           └─ Force loop exit
│
├─ If WS-FLAG-TSQH = 'Y' (Line 320)
│  └─ Queue doesn't exist or HIGH CUSTOMER not found
│     │
│     ├─ EXEC CICS WRITEQ TS (WRITE-MSG-E) (Lines 321-326)
│     │  └─ Write header record
│     │
│     ├─ Move CA-Customer-Num To Write-Msg-Low (Line 327)
│     ├─ Move CA-Customer-Num To Write-Msg-High (Line 328)
│     │
│     ├─ EXEC CICS WRITEQ TS (WRITE-MSG-L) (Lines 329-334)
│     │  └─ Write LOW CUSTOMER record
│     │
│     └─ EXEC CICS WRITEQ TS (WRITE-MSG-H) (Lines 335-340)
│        └─ Write HIGH CUSTOMER record
│
├─ EXEC CICS DEQ Resource(STSQ-NAME) (Lines 343-345)
│  └─ Release the queue lock
│
└─ EXIT (Line 347)
```

**Key Characteristics**:
- Uses ENQ/DEQ for serialization
- Implements read-modify-write pattern
- Creates queue if it doesn't exist
- Updates high customer number atomically

## Business Logic Layer Control Flow

### LGACUS01 - Add Customer Business Logic

**Location**: Lines 78-179

```cobol
MAINLINE SECTION (Line 78)
│
├─ INITIALIZE WS-HEADER (Line 84)
│
├─ MOVE EIBTRNID TO WS-TRANSID (Line 86)
├─ MOVE EIBTRMID TO WS-TERMID (Line 87)
├─ MOVE EIBTASKN TO WS-TASKNUM (Line 88)
│
├─ IF EIBCALEN IS EQUAL TO ZERO (Lines 95-99)
│  ├─ MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
│  ├─ PERFORM WRITE-ERROR-MESSAGE
│  └─ EXEC CICS ABEND ABCODE('LGCA') NODUMP
│
├─ MOVE '00' TO CA-RETURN-CODE (Line 102)
├─ MOVE '00' TO CA-NUM-POLICIES (Line 103)
├─ MOVE EIBCALEN TO WS-CALEN (Line 104)
├─ SET WS-ADDR-DFHCOMMAREA TO ADDRESS OF DFHCOMMAREA (Line 105)
│
├─ Validate commarea length (Lines 108-115)
│  ├─ ADD WS-CA-HEADER-LEN TO WS-REQUIRED-CA-LEN (Line 108)
│  ├─ ADD WS-CUSTOMER-LEN TO WS-REQUIRED-CA-LEN (Line 109)
│  │
│  └─ IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN (Line 112)
│     ├─ MOVE '98' TO CA-RETURN-CODE (Line 113)
│     └─ EXEC CICS RETURN (Line 114)
│
├─ PERFORM INSERT-CUSTOMER (Line 119)
│  └─ INSERT-CUSTOMER paragraph (Lines 132-140)
│     ├─ EXEC CICS LINK Program(LGACDB01) (Lines 134-137)
│     └─ EXIT (Line 140)
│
└─ EXEC CICS RETURN (Line 123)
```

### LGIPOL01 - Inquire Policy Business Logic

**Location**: Lines 70-139

```cobol
MAINLINE SECTION (Line 70)
│
├─ INITIALIZE WS-HEADER (Line 72)
├─ MOVE EIBTRNID TO WS-TRANSID (Line 74)
├─ MOVE EIBTRMID TO WS-TERMID (Line 75)
├─ MOVE EIBTASKN TO WS-TASKNUM (Line 76)
│
├─ IF EIBCALEN IS EQUAL TO ZERO (Lines 79-83)
│  ├─ MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
│  ├─ PERFORM WRITE-ERROR-MESSAGE
│  └─ EXEC CICS ABEND ABCODE('LGCA') NODUMP
│
├─ MOVE '00' TO CA-RETURN-CODE (Line 86)
├─ MOVE EIBCALEN TO WS-CALEN (Line 87)
├─ SET WS-ADDR-DFHCOMMAREA TO ADDRESS OF DFHCOMMAREA (Line 88)
│
├─ EXEC CICS LINK Program(LGIPDB01) (Lines 91-94)
│  └─ Direct delegation to database layer
│
└─ EXEC CICS RETURN (Line 96)
```

### LGAPOL01 - Add Policy Business Logic

**Location**: Lines 80-169

```cobol
MAINLINE SECTION (Line 80)
│
├─ INITIALIZE WS-HEADER (Line 86)
├─ MOVE EIBTRNID TO WS-TRANSID (Line 88)
├─ MOVE EIBTRMID TO WS-TERMID (Line 89)
├─ MOVE EIBTASKN TO WS-TASKNUM (Line 90)
├─ MOVE EIBCALEN TO WS-CALEN (Line 91)
│
├─ IF EIBCALEN IS EQUAL TO ZERO (Lines 98-102)
│  ├─ MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
│  ├─ PERFORM WRITE-ERROR-MESSAGE
│  └─ EXEC CICS ABEND ABCODE('LGCA') NODUMP
│
├─ MOVE '00' TO CA-RETURN-CODE (Line 105)
├─ SET WS-ADDR-DFHCOMMAREA TO ADDRESS OF DFHCOMMAREA (Line 106)
│
├─ Validate commarea length (Lines 109-116)
│  ├─ ADD WS-CA-HEADER-LEN TO WS-REQUIRED-CA-LEN (Line 109)
│  │
│  └─ IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN (Line 113)
│     ├─ MOVE '98' TO CA-RETURN-CODE (Line 114)
│     └─ EXEC CICS RETURN (Line 115)
│
├─ EXEC CICS Link Program(LGAPDB01) (Lines 121-124)
│  └─ Delegate to database layer
│
└─ EXEC CICS RETURN (Line 126)
```

## Database Access Layer Control Flow

### LGACDB01 - Add Customer Database Access

**Location**: Lines 128-328

```cobol
MAINLINE SECTION (Line 128)
│
├─ INITIALIZE WS-HEADER (Line 134)
├─ MOVE EIBTRNID TO WS-TRANSID (Line 136)
├─ MOVE EIBTRMID TO WS-TERMID (Line 137)
├─ MOVE EIBTASKN TO WS-TASKNUM (Line 138)
│
├─ INITIALIZE DB2-OUT-INTEGERS (Line 143)
│
├─ IF EIBCALEN IS EQUAL TO ZERO (Lines 149-153)
│  ├─ MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
│  ├─ PERFORM WRITE-ERROR-MESSAGE
│  └─ EXEC CICS ABEND ABCODE('LGCA') NODUMP
│
├─ MOVE '00' TO CA-RETURN-CODE (Line 156)
├─ MOVE EIBCALEN TO WS-CALEN (Line 157)
├─ SET WS-ADDR-DFHCOMMAREA TO ADDRESS OF DFHCOMMAREA (Line 158)
│
├─ Validate commarea length (Lines 161-168)
│  ├─ ADD WS-CA-HEADER-LEN TO WS-REQUIRED-CA-LEN (Line 161)
│  ├─ ADD WS-CUSTOMER-LEN TO WS-REQUIRED-CA-LEN (Line 162)
│  │
│  └─ IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN (Line 165)
│     ├─ MOVE '98' TO CA-RETURN-CODE (Line 166)
│     └─ EXEC CICS RETURN (Line 167)
│
├─ PERFORM Obtain-CUSTOMER-Number (Line 171)
│  └─ See detailed flow below
│
├─ PERFORM INSERT-CUSTOMER (Line 172)
│  └─ See detailed flow below
│
├─ EXEC CICS LINK Program(LGACVS01) (Lines 174-177)
│  └─ Write to VSAM file
│
├─ Prepare security data (Lines 179-184)
│  ├─ MOVE DB2-CUSTOMERNUM-INT TO D2-CUSTOMER-NUM
│  ├─ Move '02ACUS' To D2-REQUEST-ID
│  ├─ move password hash To D2-CUSTSECR-PASS
│  ├─ Move '0000' To D2-CUSTSECR-COUNT
│  └─ Move 'N' To D2-CUSTSECR-STATE
│
├─ EXEC CICS LINK Program(LGACDB02) (Lines 186-189)
│  └─ Create customer security record
│
└─ EXEC CICS RETURN (Line 192)
```

### PERFORM Paragraph: Obtain-CUSTOMER-Number

**Location**: Lines 199-212 in LGACDB01

```cobol
Obtain-CUSTOMER-Number
│
├─ Exec CICS Get Counter(GENAcount) (Lines 201-205)
│  ├─ Pool(GENApool)
│  ├─ Value(LastCustNum)
│  └─ Resp(WS-RESP)
│
├─ If WS-RESP Not = DFHRESP(NORMAL) (Line 206)
│  ├─ MOVE 'NO' TO LGAC-NCS (Line 207)
│  │  └─ Named Counter Service unavailable
│  └─ Initialize DB2-CUSTOMERNUM-INT (Line 208)
│     └─ Will use DB2 IDENTITY column
│
└─ ELSE (Line 209)
   └─ Move LastCustNum To DB2-CUSTOMERNUM-INT (Line 210)
      └─ Use counter value for customer number
```

### PERFORM Paragraph: INSERT-CUSTOMER

**Location**: Lines 215-288 in LGACDB01

```cobol
INSERT-CUSTOMER
│
├─ MOVE ' INSERT CUSTOMER' TO EM-SQLREQ (Line 219)
│
├─ IF LGAC-NCS = 'ON' (Line 221)
│  │
│  ├─ EXEC SQL INSERT INTO CUSTOMER (Lines 222-244)
│  │  ├─ Use :DB2-CUSTOMERNUM-INT from Named Counter
│  │  └─ VALUES (:DB2-CUSTOMERNUM-INT, :CA-FIRST-NAME, ...)
│  │
│  └─ IF SQLCODE NOT EQUAL 0 (Line 245)
│     ├─ MOVE '90' TO CA-RETURN-CODE (Line 246)
│     ├─ PERFORM WRITE-ERROR-MESSAGE (Line 247)
│     └─ EXEC CICS RETURN (Line 248)
│
├─ ELSE (Line 250)
│  │  └─ Named Counter Service not available
│  │
│  ├─ EXEC SQL INSERT INTO CUSTOMER (Lines 251-273)
│  │  ├─ Use DEFAULT for CUSTOMERNUMBER
│  │  └─ VALUES (DEFAULT, :CA-FIRST-NAME, ...)
│  │
│  ├─ IF SQLCODE NOT EQUAL 0 (Line 274)
│  │  ├─ MOVE '90' TO CA-RETURN-CODE (Line 275)
│  │  ├─ PERFORM WRITE-ERROR-MESSAGE (Line 276)
│  │  └─ EXEC CICS RETURN (Line 277)
│  │
│  └─ EXEC SQL SET :DB2-CUSTOMERNUM-INT = IDENTITY_VAL_LOCAL() (Lines 280-282)
│     └─ Retrieve auto-generated customer number
│
├─ MOVE DB2-CUSTOMERNUM-INT TO CA-CUSTOMER-NUM (Line 285)
│
└─ EXIT (Line 287)
```

## PERFORM Paragraph Patterns

### Pattern 1: Simple Delegation

**Example**: INSERT-CUSTOMER in LGACUS01 (Lines 132-140)

```cobol
INSERT-CUSTOMER.
    EXEC CICS LINK Program(LGACDB01)
         Commarea(DFHCOMMAREA)
         LENGTH(32500)
    END-EXEC.
    EXIT.
```

**Characteristics**:
- Single responsibility
- No conditional logic
- Direct CICS LINK call
- Always ends with EXIT

### Pattern 2: Conditional Processing

**Example**: Obtain-CUSTOMER-Number in LGACDB01 (Lines 199-212)

```cobol
Obtain-CUSTOMER-Number.
    Exec CICS Get Counter(GENAcount)
              Pool(GENApool)
              Value(LastCustNum)
              Resp(WS-RESP)
    End-Exec.
    
    If WS-RESP Not = DFHRESP(NORMAL)
      MOVE 'NO' TO LGAC-NCS
      Initialize DB2-CUSTOMERNUM-INT
    ELSE
      Move LastCustNum To DB2-CUSTOMERNUM-INT
    End-If.
```

**Characteristics**:
- Conditional branching based on RESP code
- Fallback logic for resource unavailability
- Sets flags for downstream processing
- No explicit EXIT (implicit)

### Pattern 3: Loop Processing

**Example**: WRITE-GENACNTL in LGTESTC1 (Lines 296-316)

```cobol
Perform With Test after Until WS-RESP > 0
  Exec CICS ReadQ TS Queue(STSQ-NAME)
      Into(READ-MSG)
      Resp(WS-RESP)
      Next
  End-Exec
  Add 1 To WS-Item-Count
  If WS-RESP = DFHRESP(NORMAL) And
       Read-Msg-Msg(1:13) = 'HIGH CUSTOMER'
       Move CA-Customer-Num To Write-Msg-High
       Move Space to WS-FLAG-TSQH
       Exec CICS WriteQ TS Queue(STSQ-NAME)
           From(Write-Msg-H)
           Length(F24)
           Resp(WS-RESP)
           ReWrite
           Item(WS-Item-Count)
       End-Exec
       MOVE 99 To WS-RESP
  End-If
End-Perform
```

**Characteristics**:
- PERFORM WITH TEST AFTER loop
- Processes queue items sequentially
- Conditional update within loop
- Forced exit via RESP code manipulation

### Pattern 4: Error Handling

**Example**: WRITE-ERROR-MESSAGE in LGACDB01 (Lines 295-328)

```cobol
WRITE-ERROR-MESSAGE.
    MOVE SQLCODE TO EM-SQLRC
    EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC
    EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)
              MMDDYYYY(WS-DATE)
              TIME(WS-TIME)
    END-EXEC
    MOVE WS-DATE TO EM-DATE
    MOVE WS-TIME TO EM-TIME
    
    EXEC CICS LINK PROGRAM('LGSTSQ')
              COMMAREA(ERROR-MSG)
              LENGTH(LENGTH OF ERROR-MSG)
    END-EXEC.
    
    IF EIBCALEN > 0 THEN
      IF EIBCALEN < 91 THEN
        MOVE DFHCOMMAREA(1:EIBCALEN) TO CA-DATA
        EXEC CICS LINK PROGRAM('LGSTSQ')
                  COMMAREA(CA-ERROR-MSG)
                  LENGTH(LENGTH OF CA-ERROR-MSG)
        END-EXEC
      ELSE
        MOVE DFHCOMMAREA(1:90) TO CA-DATA
        EXEC CICS LINK PROGRAM('LGSTSQ')
                  COMMAREA(CA-ERROR-MSG)
                  LENGTH(LENGTH OF CA-ERROR-MSG)
        END-EXEC
      END-IF
    END-IF.
    EXIT.
```

**Characteristics**:
- Captures diagnostic information (SQLCODE, timestamp)
- Formats error message
- Writes to error log via LGSTSQ
- Includes commarea dump for debugging
- Nested IF for length checking

## Error Handling Flow

### Presentation Layer Error Flow

```
User Input
    │
    ▼
RECEIVE MAP
    │
    ├─ MAPFAIL → ENDIT (terminate)
    │
    ▼
EVALUATE Option
    │
    ├─ Valid Option
    │  │
    │  ├─ LINK to Business Logic
    │  │  │
    │  │  ├─ CA-RETURN-CODE = '00' → Success
    │  │  │  └─ SEND MAP with results
    │  │  │     └─ ENDIT-STARTIT (continue)
    │  │  │
    │  │  └─ CA-RETURN-CODE > '00' → Error
    │  │     ├─ SYNCPOINT ROLLBACK (if add/update/delete)
    │  │     └─ GO TO NO-ADD/NO-UPD/NO-DATA
    │  │        └─ ERROR-OUT
    │  │           ├─ SEND MAP with error message
    │  │           ├─ Initialize structures
    │  │           └─ ENDIT-STARTIT (continue)
    │  │
    │  └─ WHEN OTHER → Invalid option
    │     └─ SEND MAP with error
    │        └─ ENDIT-STARTIT (continue)
    │
    └─ AID Keys
       ├─ CLEAR → CLEARIT (clear screen, continue)
       └─ PF3 → ENDIT (terminate)
```

### Business Logic Layer Error Flow

```
Validate EIBCALEN
    │
    ├─ EIBCALEN = 0
    │  ├─ PERFORM WRITE-ERROR-MESSAGE
    │  └─ EXEC CICS ABEND ABCODE('LGCA')
    │
    └─ EIBCALEN > 0
       │
       ├─ Validate commarea length
       │  │
       │  ├─ Too short
       │  │  ├─ MOVE '98' TO CA-RETURN-CODE
       │  │  └─ EXEC CICS RETURN
       │  │
       │  └─ Valid length
       │     │
       │     └─ PERFORM operation
       │        │
       │        ├─ Success
       │        │  ├─ CA-RETURN-CODE = '00'
       │        │  └─ EXEC CICS RETURN
       │        │
       │        └─ Failure
       │           ├─ MOVE error code TO CA-RETURN-CODE
       │           ├─ PERFORM WRITE-ERROR-MESSAGE
       │           └─ EXEC CICS RETURN
```

### Database Layer Error Flow

```
Execute SQL Statement
    │
    ├─ SQLCODE = 0 (Success)
    │  ├─ Process results
    │  └─ MOVE '00' TO CA-RETURN-CODE
    │
    └─ SQLCODE ≠ 0 (Error)
       ├─ MOVE '90' TO CA-RETURN-CODE
       ├─ PERFORM WRITE-ERROR-MESSAGE
       │  ├─ MOVE SQLCODE TO EM-SQLRC
       │  ├─ Format timestamp
       │  ├─ EXEC CICS LINK PROGRAM('LGSTSQ')
       │  └─ Write commarea dump
       └─ EXEC CICS RETURN
```

## Control Flow Best Practices

### 1. Consistent Structure
All programs follow the same pattern:
- Initialize working storage
- Validate input (EIBCALEN, commarea length)
- Perform business operation
- Return to caller

### 2. Single Entry/Exit Points
- MAINLINE SECTION is the only entry point
- EXIT or EXEC CICS RETURN are the only exit points
- GO TO used sparingly for error handling

### 3. PERFORM Paragraph Naming
- Verb-noun format (e.g., INSERT-CUSTOMER, WRITE-ERROR-MESSAGE)
- Descriptive of the operation performed
- Consistent across programs

### 4. Error Handling
- Check RESP codes immediately after CICS commands
- Set CA-RETURN-CODE for caller
- Log errors via WRITE-ERROR-MESSAGE
- Return control to caller (no ABENDs except for critical errors)

### 5. Resource Management
- ENQ before critical section
- DEQ after critical section
- SYNCPOINT ROLLBACK on errors
- Clean up temporary storage

## Related Documentation

- [Transaction Entry Points](TRANSACTION-ENTRY-POINTS.md)
- [Transaction Routing Logic](TRANSACTION-ROUTING-LOGIC.md)
- [External Dependencies](EXTERNAL-DEPENDENCIES.md)
- [System Architecture Diagram](SYSTEM-ARCHITECTURE-DIAGRAM.md)