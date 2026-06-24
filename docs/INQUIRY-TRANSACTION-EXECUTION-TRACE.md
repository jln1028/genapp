# Inquiry Transaction Execution Trace

## Overview
This document provides a detailed step-by-step execution trace for inquiry transactions in the GenApp system, mapping each step to an airline seat availability checking scenario. The trace follows both customer and policy inquiry flows, highlighting PERFORM chains, DB2 reads, loops, and validation logic.

---

## Transaction Entry Points

### Customer Inquiry: `SSC1` → `LGTESTC1`
**Airline Scenario**: Passenger checking their frequent flyer profile and booking history

### Policy Inquiry: `SSP1` → `LGTESTP1`  
**Airline Scenario**: Checking seat availability and fare rules for a specific flight

---

## Execution Flow 1: Customer Inquiry (`LGICUS01` → `LGICDB01`)

### **Step 1: Transaction Initialization**
**Program**: [`LGICUS01`](../base/src/lgicus01.cbl:77)  
**PERFORM Chain**: MAINLINE SECTION

**Actions**:
1. Initialize working storage header ([`LGICUS01:79`](../base/src/lgicus01.cbl:79))
2. Capture CICS environment information:
   - Transaction ID → `WS-TRANSID` ([`LGICUS01:81`](../base/src/lgicus01.cbl:81))
   - Terminal ID → `WS-TERMID` ([`LGICUS01:82`](../base/src/lgicus01.cbl:82))
   - Task number → `WS-TASKNUM` ([`LGICUS01:83`](../base/src/lgicus01.cbl:83))

**Airline Mapping**: System logs passenger session (terminal ID = check-in kiosk, task number = session ID)

---

### **Step 2: COMMAREA Validation**
**Program**: [`LGICUS01`](../base/src/lgicus01.cbl:87)  
**Validation Logic**:

```cobol
IF EIBCALEN IS EQUAL TO ZERO
    MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
    PERFORM WRITE-ERROR-MESSAGE
    EXEC CICS ABEND ABCODE('LGCA') NODUMP END-EXEC
END-IF
```

**Checks**:
- Verify COMMAREA exists (lines 87-91)
- Initialize return code to '00' (line 93)
- Calculate required COMMAREA length (lines 102-107)
- Validate sufficient length provided (lines 104-107)

**Return Codes**:
- `00` = Success
- `98` = Insufficient COMMAREA length

**Airline Mapping**: Validate passenger inquiry request contains required data (frequent flyer number, request type)

---

### **Step 3: Link to Database Layer**
**Program**: [`LGICUS01`](../base/src/lgicus01.cbl:109)  
**PERFORM Chain**: `GET-CUSTOMER-INFO` → CICS LINK

**Action**:
```cobol
PERFORM GET-CUSTOMER-INFO.
    EXEC CICS LINK Program(LGICDB01)
        Commarea(DFHCOMMAREA)
        LENGTH(32500)
    END-EXEC
```

**Flow**:
1. Call paragraph `GET-CUSTOMER-INFO` (line 109)
2. Execute CICS LINK to [`LGICDB01`](../base/src/lgicdb01.cbl:122) (lines 122-125)
3. Pass entire COMMAREA (32,500 bytes)

**Airline Mapping**: Forward request to passenger database system to retrieve profile

---

### **Step 4: Database Program Initialization**
**Program**: [`LGICDB01`](../base/src/lgicdb01.cbl:102)  
**PERFORM Chain**: MAINLINE SECTION

**Actions**:
1. Initialize working storage ([`LGICDB01:108`](../base/src/lgicdb01.cbl:108))
2. Capture CICS environment (lines 110-112)
3. Validate COMMAREA received (lines 119-123)
4. Initialize DB2 host variables (line 131)
5. Validate COMMAREA length (lines 137-143)

**Airline Mapping**: Database layer validates request and prepares to query passenger records

---

### **Step 5: Customer Number Conversion**
**Program**: [`LGICDB01`](../base/src/lgicdb01.cbl:145)  
**Data Transformation**:

```cobol
MOVE CA-CUSTOMER-NUM TO DB2-CUSTOMERNUMBER-INT
MOVE CA-CUSTOMER-NUM TO EM-CUSNUM
```

**Purpose**: Convert 10-digit customer number from COMMAREA to DB2 INTEGER format

**Airline Mapping**: Convert frequent flyer number to database key format

---

### **Step 6: DB2 SELECT - Customer Information**
**Program**: [`LGICDB01`](../base/src/lgicdb01.cbl:154)  
**PERFORM Chain**: `GET-CUSTOMER-INFO`

**DB2 Read Operation**:
```sql
SELECT FIRSTNAME,
       LASTNAME,
       DATEOFBIRTH,
       HOUSENAME,
       HOUSENUMBER,
       POSTCODE,
       PHONEMOBILE,
       PHONEHOME,
       EMAILADDRESS
INTO  :CA-FIRST-NAME,
      :CA-LAST-NAME,
      :CA-DOB,
      :CA-HOUSE-NAME,
      :CA-HOUSE-NUM,
      :CA-POSTCODE,
      :CA-PHONE-MOBILE,
      :CA-PHONE-HOME,
      :CA-EMAIL-ADDRESS
FROM CUSTOMER
WHERE CUSTOMERNUMBER = :DB2-CUSTOMERNUMBER-INT
```

**Key Points**:
- Single-row SELECT (lines 169-190)
- Direct read by primary key (CUSTOMERNUMBER)
- No loops - expects exactly 0 or 1 row
- Data returned directly into COMMAREA fields

**Airline Mapping**: Query passenger database for profile details (name, contact info, address)

---

### **Step 7: SQLCODE Evaluation**
**Program**: [`LGICDB01`](../base/src/lgicdb01.cbl:192)  
**Validation Logic**:

```cobol
Evaluate SQLCODE
  When 0
    MOVE '00' TO CA-RETURN-CODE
  When 100
    MOVE '01' TO CA-RETURN-CODE
  When -913
    MOVE '01' TO CA-RETURN-CODE
  When Other
    MOVE '90' TO CA-RETURN-CODE
    PERFORM WRITE-ERROR-MESSAGE
    EXEC CICS RETURN END-EXEC
END-Evaluate
```

**Return Codes**:
- `00` = Customer found successfully
- `01` = Customer not found (SQLCODE 100) or deadlock timeout (SQLCODE -913)
- `90` = SQL error occurred

**Airline Mapping**: 
- Code 00: Passenger profile found
- Code 01: Passenger not in system or database busy
- Code 90: Database error

---

### **Step 8: Error Handling (If Needed)**
**Program**: [`LGICDB01`](../base/src/lgicdb01.cbl:212)  
**PERFORM Chain**: `WRITE-ERROR-MESSAGE`

**Actions** (lines 212-245):
1. Save SQLCODE to error message (line 214)
2. Get current timestamp via CICS ASKTIME (lines 216-221)
3. Format timestamp (lines 222-223)
4. Write error to temporary storage queue via [`LGSTSQ`](../base/src/lgstsq.cbl) (lines 225-228)
5. Write COMMAREA contents to queue (lines 230-244)

**Airline Mapping**: Log database errors to system audit trail with timestamp

---

### **Step 9: Return to Business Logic Layer**
**Program**: [`LGICDB01`](../base/src/lgicdb01.cbl:161)  

**Action**:
```cobol
EXEC CICS RETURN END-EXEC
```

**Result**: Control returns to [`LGICUS01`](../base/src/lgicus01.cbl:125) with populated COMMAREA

**Airline Mapping**: Return passenger profile data to presentation layer

---

### **Step 10: Return to Presentation Layer**
**Program**: [`LGICUS01`](../base/src/lgicus01.cbl:115)  

**Action**:
```cobol
EXEC CICS RETURN END-EXEC
```

**Result**: Control returns to [`LGTESTC1`](../base/src/lgtestc1.cbl) with customer data in COMMAREA

**Airline Mapping**: Display passenger profile on check-in kiosk screen

---

## Execution Flow 2: Policy Inquiry (`LGIPOL01` → `LGIPDB01`)

### **Step 1: Transaction Initialization**
**Program**: [`LGIPOL01`](../base/src/lgipol01.cbl:70)  
**PERFORM Chain**: MAINLINE SECTION

**Actions**:
1. Initialize working storage header ([`LGIPOL01:72`](../base/src/lgipol01.cbl:72))
2. Capture CICS environment (lines 74-76)
3. Validate COMMAREA exists (lines 79-83)
4. Initialize return code to '00' (line 86)

**Airline Mapping**: Initialize flight seat availability inquiry

---

### **Step 2: Link to Database Layer**
**Program**: [`LGIPOL01`](../base/src/lgipol01.cbl:91)  

**Action**:
```cobol
EXEC CICS LINK Program(LGIPDB01)
    Commarea(DFHCOMMAREA)
    Length(32500)
END-EXEC
```

**Airline Mapping**: Forward request to flight inventory system

---

### **Step 3: Database Program Initialization**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:230)  
**PERFORM Chain**: MAINLINE SECTION

**Actions**:
1. Initialize working storage (line 236)
2. Capture CICS environment (lines 238-240)
3. Initialize DB2 host variables (lines 243-245)
4. Validate COMMAREA (lines 251-255)
5. Initialize return code (line 258)

**Airline Mapping**: Prepare to query flight seat inventory

---

### **Step 4: Policy Number Conversion**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:262)  

**Data Transformation**:
```cobol
MOVE CA-CUSTOMER-NUM TO DB2-CUSTOMERNUM-INT
MOVE CA-POLICY-NUM   TO DB2-POLICYNUM-INT
MOVE CA-CUSTOMER-NUM TO EM-CUSNUM
MOVE CA-POLICY-NUM   TO EM-POLNUM
```

**Airline Mapping**: Convert passenger ID and flight number to database keys

---

### **Step 5: Request Type Evaluation**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:275)  
**Validation Logic**:

```cobol
MOVE FUNCTION UPPER-CASE(CA-REQUEST-ID) TO WS-REQUEST-ID

EVALUATE WS-REQUEST-ID
  WHEN '01IEND'
    INITIALIZE DB2-ENDOWMENT
    PERFORM GET-ENDOW-DB2-INFO
  WHEN '01IHOU'
    INITIALIZE DB2-HOUSE
    PERFORM GET-HOUSE-DB2-INFO
  WHEN '01IMOT'
    INITIALIZE DB2-MOTOR
    PERFORM GET-MOTOR-DB2-INFO
  WHEN '01ICOM'
    INITIALIZE DB2-COMMERCIAL
    PERFORM GET-COMMERCIAL-DB2-INFO-1
  WHEN '02ICOM'
    INITIALIZE DB2-COMMERCIAL
    PERFORM GET-COMMERCIAL-DB2-INFO-2
  WHEN '03ICOM'
    INITIALIZE DB2-COMMERCIAL
    PERFORM GET-COMMERCIAL-DB2-INFO-3
  WHEN '05ICOM'
    INITIALIZE DB2-COMMERCIAL
    PERFORM GET-COMMERCIAL-DB2-INFO-5
  WHEN OTHER
    MOVE '99' TO CA-RETURN-CODE
END-EVALUATE
```

**Policy Types**:
- `01IEND` = Endowment policy inquiry
- `01IHOU` = House policy inquiry
- `01IMOT` = Motor policy inquiry
- `01ICOM` = Commercial policy inquiry (basic)
- `02ICOM` = Commercial policy inquiry (with claims)
- `03ICOM` = Commercial policy inquiry (with cursor loop)
- `05ICOM` = Commercial policy inquiry (alternative cursor)

**Airline Mapping**: Determine inquiry type:
- Economy class availability
- Business class availability
- First class availability
- Fare rules inquiry
- Seat map inquiry

---

### **Step 6: DB2 SELECT - Endowment Policy (Example)**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:327)  
**PERFORM Chain**: `GET-ENDOW-DB2-INFO`

**DB2 Read Operation**:
```sql
SELECT  ISSUEDATE,
        EXPIRYDATE,
        LASTCHANGED,
        BROKERID,
        BROKERSREFERENCE,
        PAYMENT,
        WITHPROFITS,
        EQUITIES,
        MANAGEDFUND,
        FUNDNAME,
        TERM,
        SUMASSURED,
        LIFEASSURED,
        PADDINGDATA,
        LENGTH(PADDINGDATA)
INTO  :DB2-ISSUEDATE,
      :DB2-EXPIRYDATE,
      :DB2-LASTCHANGED,
      :DB2-BROKERID-INT INDICATOR :IND-BROKERID,
      :DB2-BROKERSREF INDICATOR :IND-BROKERSREF,
      :DB2-PAYMENT-INT INDICATOR :IND-PAYMENT,
      :DB2-E-WITHPROFITS,
      :DB2-E-EQUITIES,
      :DB2-E-MANAGEDFUND,
      :DB2-E-FUNDNAME,
      :DB2-E-TERM-SINT,
      :DB2-E-SUMASSURED-INT,
      :DB2-E-LIFEASSURED,
      :DB2-E-PADDINGDATA INDICATOR :IND-E-PADDINGDATA,
      :DB2-E-PADDING-LEN INDICATOR :IND-E-PADDINGDATAL
FROM  POLICY,ENDOWMENT
WHERE ( POLICY.POLICYNUMBER = ENDOWMENT.POLICYNUMBER AND
        POLICY.CUSTOMERNUMBER = :DB2-CUSTOMERNUM-INT AND
        POLICY.POLICYNUMBER = :DB2-POLICYNUM-INT )
```

**Key Points**:
- JOIN between POLICY and ENDOWMENT tables (line 361)
- Single-row SELECT by composite key
- Uses NULL indicators for optional fields (lines 349-351, 359-360)
- Retrieves VARCHAR length dynamically (line 345)

**Airline Mapping**: Query flight details:
- Departure/arrival times (ISSUEDATE, EXPIRYDATE)
- Last update timestamp (LASTCHANGED)
- Booking agent (BROKERID)
- Fare class details (WITHPROFITS, EQUITIES, etc.)
- Seat assignment (LIFEASSURED)

---

### **Step 7: SQLCODE Evaluation and Length Calculation**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:370)  
**Validation Logic**:

```cobol
IF SQLCODE = 0
  * Calculate size of commarea required
  ADD WS-CA-HEADERTRAILER-LEN TO WS-REQUIRED-CA-LEN
  ADD WS-FULL-ENDOW-LEN       TO WS-REQUIRED-CA-LEN
  
  * Handle VARCHAR field length
  IF IND-E-PADDINGDATAL NOT EQUAL MINUS-ONE
    ADD DB2-E-PADDING-LEN TO WS-REQUIRED-CA-LEN
    ADD DB2-E-PADDING-LEN TO END-POLICY-POS
  END-IF
  
  * Validate COMMAREA size
  IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN
    MOVE '98' TO CA-RETURN-CODE
    EXEC CICS RETURN END-EXEC
  ELSE
    * Move data to COMMAREA
    ...
  END-IF
ELSE
  * Handle SQL errors
  IF SQLCODE EQUAL 100
    MOVE '01' TO CA-RETURN-CODE
  ELSE
    MOVE '90' TO CA-RETURN-CODE
    PERFORM WRITE-ERROR-MESSAGE
  END-IF
END-IF
```

**Dynamic Length Handling**:
- Calculates required COMMAREA size based on VARCHAR data (lines 374-386)
- Validates caller provided sufficient space (lines 390-392)
- Only moves data if space is adequate (lines 393-414)

**Airline Mapping**: 
- Calculate response size based on seat map complexity
- Validate response buffer can hold all seat details
- Return error if buffer too small

---

### **Step 8: NULL Indicator Processing**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:397)  
**Validation Logic**:

```cobol
IF IND-BROKERID NOT EQUAL MINUS-ONE
  MOVE DB2-BROKERID-INT TO DB2-BROKERID
END-IF
IF IND-PAYMENT NOT EQUAL MINUS-ONE
  MOVE DB2-PAYMENT-INT TO DB2-PAYMENT
END-IF
```

**Purpose**: Only move fields that are NOT NULL in database

**Airline Mapping**: Only include optional data if available (e.g., meal preference, special assistance)

---

### **Step 9: Data Type Conversion**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:404)  

**Conversions**:
```cobol
MOVE DB2-E-TERM-SINT      TO DB2-E-TERM
MOVE DB2-E-SUMASSURED-INT TO DB2-E-SUMASSURED
```

**Purpose**: Convert DB2 SMALLINT/INTEGER to COBOL display numerics

**Airline Mapping**: Convert database integers to display format (e.g., seat count, fare amount)

---

### **Step 10: COMMAREA Population**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:407)  

**Data Movement**:
```cobol
MOVE DB2-POLICY-COMMON TO CA-POLICY-COMMON
MOVE DB2-ENDOW-FIXED TO CA-ENDOWMENT(1:WS-ENDOW-LEN)
IF IND-E-PADDINGDATA NOT EQUAL MINUS-ONE
  MOVE DB2-E-PADDINGDATA TO CA-E-PADDING-DATA(1:DB2-E-PADDING-LEN)
END-IF
```

**Key Points**:
- Fixed-length fields moved first (line 407)
- Variable-length fields moved with dynamic length (lines 410-413)
- End marker placed after data (line 417)

**Airline Mapping**: Populate response with:
- Flight common details (times, status)
- Seat availability by class
- Additional notes/restrictions

---

### **Step 11: Return to Business Logic Layer**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:313)  

**Action**:
```cobol
EXEC CICS RETURN END-EXEC
```

**Result**: Control returns to [`LGIPOL01`](../base/src/lgipol01.cbl:94) with policy data

**Airline Mapping**: Return flight availability data to business layer

---

### **Step 12: Return to Presentation Layer**
**Program**: [`LGIPOL01`](../base/src/lgipol01.cbl:96)  

**Action**:
```cobol
EXEC CICS RETURN END-EXEC
```

**Result**: Control returns to [`LGTESTP1`](../base/src/lgtestp1.cbl) with policy data in COMMAREA

**Airline Mapping**: Display seat availability on booking screen

---

## Loop and Cursor Processing (Commercial Policy Example)

### **Commercial Policy with Cursor Loop**
**Program**: [`LGIPDB01`](../base/src/lgipdb01.cbl:863)  
**PERFORM Chain**: `GET-COMMERCIAL-DB2-INFO-3-Cur`

**Cursor Declaration** (lines 863-913):
```sql
DECLARE C3 CURSOR FOR
  SELECT CLAIMNUMBER,
         CLAIMDATE,
         PAID,
         VALUE,
         CAUSE,
         OBSERVATIONS
  FROM CLAIM
  WHERE CUSTOMERNUMBER = :DB2-CUSTOMERNUM-INT
    AND POLICYNUMBER = :DB2-POLICYNUM-INT
```

**Loop Processing**:
1. **OPEN Cursor** - Initialize result set
2. **FETCH Loop** - Retrieve rows one at a time
3. **Process Each Row** - Move data to COMMAREA array
4. **CLOSE Cursor** - Release resources

**Airline Mapping**: 
- Query all previous bookings for passenger
- Loop through booking history
- Return list of past flights

**Loop Control**:
- Continues until SQLCODE = 100 (no more rows)
- Counts rows retrieved
- Handles multiple claims per policy

---

## Performance Characteristics

### **Customer Inquiry**
- **DB2 Reads**: 1 (single SELECT by primary key)
- **Loops**: None
- **Expected Response**: < 100ms
- **Airline Equivalent**: Instant passenger lookup

### **Policy Inquiry (Single)**
- **DB2 Reads**: 1 (JOIN between 2 tables)
- **Loops**: None
- **Expected Response**: < 150ms
- **Airline Equivalent**: Single flight availability check

### **Policy Inquiry (With Claims)**
- **DB2 Reads**: 2+ (policy SELECT + cursor FETCH loop)
- **Loops**: 1 (FETCH until SQLCODE 100)
- **Expected Response**: 200ms - 2s (depends on claim count)
- **Airline Equivalent**: Flight history with all past bookings

---

## Return Code Summary

| Code | Meaning | Airline Scenario |
|------|---------|------------------|
| `00` | Success | Data found and returned |
| `01` | Not found or timeout | Passenger/flight not in system or database busy |
| `90` | SQL error | Database error occurred |
| `98` | Insufficient COMMAREA | Response buffer too small |
| `99` | Invalid request type | Unknown inquiry type |

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer (LGTESTC1 / LGTESTP1)                   │
│ - Capture user input                                        │
│ - Format COMMAREA                                           │
│ - Display results                                           │
└────────────────────────┬────────────────────────────────────┘
                         │ LINK (COMMAREA)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Business Logic Layer (LGICUS01 / LGIPOL01)                 │
│ - Validate COMMAREA length                                  │
│ - Initialize return codes                                   │
│ - Route to database layer                                   │
└────────────────────────┬────────────────────────────────────┘
                         │ LINK (COMMAREA)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Database Layer (LGICDB01 / LGIPDB01)                       │
│ - Convert data types                                        │
│ - Execute DB2 SELECT                                        │
│ - Evaluate SQLCODE                                          │
│ - Populate COMMAREA                                         │
│ - Handle NULL indicators                                    │
└────────────────────────┬────────────────────────────────────┘
                         │ SQL
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ DB2 Database                                                │
│ - CUSTOMER table                                            │
│ - POLICY table                                              │
│ - ENDOWMENT / HOUSE / MOTOR / COMMERCIAL tables             │
│ - CLAIM table                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Observations

### **1. Layered Architecture**
- Clear separation: Presentation → Business Logic → Database
- Each layer validates and transforms data
- COMMAREA is the contract between layers

### **2. No Business Logic in Database Layer**
- Database programs only perform I/O
- All business rules in middle tier
- Promotes reusability

### **3. Defensive Programming**
- Multiple validation checkpoints
- NULL indicator handling
- Dynamic length calculation
- Comprehensive error logging

### **4. Performance Optimization**
- Single-row SELECTs by primary key
- No unnecessary JOINs
- Cursor loops only when needed
- Direct COMMAREA population (no intermediate buffers)

### **5. Error Handling Strategy**
- Standardized return codes
- Detailed error logging via [`LGSTSQ`](../base/src/lgstsq.cbl)
- Graceful degradation (timeout = not found)

---

## Airline System Correspondence

| GenApp Component | Airline Equivalent |
|------------------|-------------------|
| Customer Inquiry | Passenger Profile Lookup |
| Policy Inquiry | Flight Availability Check |
| CUSTOMER table | Passenger Database |
| POLICY table | Flight Inventory |
| ENDOWMENT policy | Economy Class Seats |
| HOUSE policy | Business Class Seats |
| MOTOR policy | First Class Seats |
| COMMERCIAL policy | Charter/Group Bookings |
| CLAIM records | Booking History |
| COMMAREA | API Request/Response |
| Return Code 00 | Seats Available |
| Return Code 01 | No Availability |
| Return Code 90 | System Error |
| DB2 SELECT | Inventory Query |
| Cursor Loop | History Retrieval |

---

## Conclusion

The inquiry transaction flow demonstrates a well-structured, three-tier architecture with clear separation of concerns. The execution path is deterministic for single-row queries and includes proper loop handling for multi-row results. The airline mapping shows how insurance policy inquiries parallel flight availability checks, with similar patterns for data retrieval, validation, and error handling.

**Key Takeaways**:
1. **PERFORM chains** are shallow (1-2 levels) for maintainability
2. **DB2 reads** are optimized (primary key access, minimal JOINs)
3. **Loops** are used only for multi-row cursors (claims history)
4. **Validations** occur at every layer (presentation, business, database)
5. **Airline mapping** demonstrates universal applicability of the pattern

---

*Document generated: 2026-06-24*  
*Source programs analyzed: LGICUS01, LGICDB01, LGIPOL01, LGIPDB01*  
*Copybooks referenced: LGCMAREA, LGPOLICY*