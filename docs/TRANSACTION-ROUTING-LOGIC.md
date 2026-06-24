# Transaction Routing Logic Analysis

## Overview

This document details the multi-level routing mechanisms used in the GenApp CICS application to direct transaction requests through the three-tier architecture. It covers EIBTRNID-based routing, EVALUATE statement logic, CA-REQUEST-ID routing codes, and conditional IF statement routing.

## Table of Contents

1. [Routing Hierarchy](#routing-hierarchy)
2. [Level 1: EIBTRNID Routing](#level-1-eibtrnid-routing)
3. [Level 2: EVALUATE Statement Routing](#level-2-evaluate-statement-routing)
4. [Level 3: CA-REQUEST-ID Routing](#level-3-ca-request-id-routing)
5. [Conditional IF Statement Routing](#conditional-if-statement-routing)
6. [Complete Routing Examples](#complete-routing-examples)

## Routing Hierarchy

The GenApp application uses a **three-level routing hierarchy** to direct requests from user input to the appropriate database operations:

```
Level 1: EIBTRNID (Transaction ID)
    │
    ├─ Determines which presentation program executes
    │
    ▼
Level 2: EVALUATE Statement (Menu Option)
    │
    ├─ Routes to specific operation type (Inquire/Add/Update/Delete)
    │
    ▼
Level 3: CA-REQUEST-ID (6-byte routing code)
    │
    ├─ Identifies entity type and operation
    │
    ▼
Database Layer Program Selection
```

## Level 1: EIBTRNID Routing

### Transaction ID to Program Mapping

The CICS transaction ID (EIBTRNID) determines which presentation program executes:

| EIBTRNID | Program | Purpose | Return Statement |
|----------|---------|---------|------------------|
| **SSC1** | LGTESTC1 | Customer Management | Line 232: `EXEC CICS RETURN TRANSID('SSC1')` |
| **SSP1** | LGTESTP1 | Motor Policy Management | Line 259: `EXEC CICS RETURN TRANSID('SSP1')` |
| **SSP2** | LGTESTP2 | Endowment Policy Management | Line 241: `EXEC CICS RETURN TRANSID('SSP2')` |
| **SSP3** | LGTESTP3 | House Policy Management | Similar pattern |
| **SSP4** | LGTESTP4 | Commercial Policy Management | Similar pattern |
| **LGSE** | LGSETUP | System Initialization | Line 527: `EXEC CICS RETURN` |

### Pseudo-Conversational Pattern

Each transaction uses pseudo-conversational design to maintain state:

```cobol
MAINLINE SECTION.
    IF EIBCALEN > 0
       GO TO A-GAIN.    /* Resume conversation - EIBTRNID already set */
    
    /* First invocation - cold start */
    Initialize structures
    EXEC CICS SEND MAP
    
A-GAIN.
    /* Process user input */
    EXEC CICS RECEIVE MAP
    /* Perform operations */
    EXEC CICS RETURN
         TRANSID('SSC1')    /* Restart same transaction */
         COMMAREA(COMM-AREA)
    END-EXEC.
```

**Key Points**:
- EIBTRNID is set by CICS based on the TRANSID in the RETURN command
- Each user interaction is a separate transaction instance
- COMMAREA preserves state between transaction instances
- No resources held during user think-time

## Level 2: EVALUATE Statement Routing

### Menu Option Processing

All presentation programs use EVALUATE statements to route based on user menu selection:

#### LGTESTC1 - Customer Menu (Lines 84-222)

```cobol
EVALUATE ENP1OPTO    /* User's menu option */

  WHEN '1'           /* Inquire Customer */
      Move '01ICUS' To CA-REQUEST-ID
      Move ENT1CNOO To CA-CUSTOMER-NUM
      EXEC CICS LINK PROGRAM('LGICUS01')
                COMMAREA(COMM-AREA)
                LENGTH(32500)
      END-EXEC
      /* Display results */

  WHEN '2'           /* Add Customer */
      Move '01ACUS' To CA-REQUEST-ID
      Move 0 To CA-CUSTOMER-NUM
      /* Populate COMM-AREA from map fields */
      EXEC CICS LINK PROGRAM('LGACUS01')
                COMMAREA(COMM-AREA)
                LENGTH(32500)
      END-EXEC
      /* Handle results */

  WHEN '4'           /* Update Customer */
      /* First inquire to populate screen */
      Move '01ICUS' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGICUS01')
      /* Display for editing */
      EXEC CICS RECEIVE MAP
      /* Then update */
      Move '01UCUS' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGUCUS01')
      /* Handle results */

  WHEN OTHER         /* Invalid Option */
      Move 'Please enter a valid option' To ERRFLDO
      EXEC CICS SEND MAP CURSOR
      GO TO ENDIT-STARTIT

END-EVALUATE.
```

#### LGTESTP1 - Motor Policy Menu (Lines 66-249)

```cobol
EVALUATE ENP1OPTO    /* User's menu option */

  WHEN '1'           /* Inquire Motor Policy */
      Move '01IMOT' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGIPOL01')

  WHEN '2'           /* Add Motor Policy */
      Move '01AMOT' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGAPOL01')

  WHEN '3'           /* Delete Motor Policy */
      Move '01DMOT' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGDPOL01')

  WHEN '4'           /* Update Motor Policy */
      /* Inquire first, then update */
      Move '01IMOT' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGIPOL01')
      EXEC CICS RECEIVE MAP
      Move '01UMOT' To CA-REQUEST-ID
      EXEC CICS LINK PROGRAM('LGUPOL01')

  WHEN OTHER
      Move 'Please enter a valid option' To ERP1FLDO

END-EVALUATE.
```

### EVALUATE Characteristics

1. **Single Point of Decision**: All routing logic centralized in one EVALUATE
2. **Consistent Pattern**: Same structure across all presentation programs
3. **CA-REQUEST-ID Assignment**: Each WHEN clause sets the routing code
4. **Program Selection**: LINK to appropriate business logic program
5. **Error Handling**: WHEN OTHER catches invalid input

## Level 3: CA-REQUEST-ID Routing

### Request ID Structure

The CA-REQUEST-ID is a **6-byte routing code** defined in the LGCMAREA copybook (Line 10):

```cobol
03 CA-REQUEST-ID            PIC X(6).
```

**Format**: `PPOEEE`
- **PP**: Position (01 = first position in hierarchy)
- **O**: Operation (I=Inquire, A=Add, U=Update, D=Delete)
- **EEE**: Entity (CUS=Customer, MOT=Motor, END=Endowment, HOU=House, COM=Commercial)

### Complete Request ID Catalog

#### Customer Operations

| Request ID | Operation | Target Program Chain | Description |
|-----------|-----------|---------------------|-------------|
| `'01ICUS'` | Inquire Customer | LGICUS01 → LGICDB01 → LGICVS01 | Retrieve customer details by customer number |
| `'01ACUS'` | Add Customer | LGACUS01 → LGACDB01 → LGACVS01 → LGACDB02 | Create new customer record |
| `'01UCUS'` | Update Customer | LGUCUS01 → LGUCDB01 → LGUCVS01 | Modify existing customer details |

#### Motor Policy Operations

| Request ID | Operation | Target Program Chain | Description |
|-----------|-----------|---------------------|-------------|
| `'01IMOT'` | Inquire Motor | LGIPOL01 → LGIPDB01 → LGIPVS01 | Retrieve motor policy details |
| `'01AMOT'` | Add Motor | LGAPOL01 → LGAPDB01 → LGAPVS01 | Create new motor policy |
| `'01UMOT'` | Update Motor | LGUPOL01 → LGUPDB01 → LGUPVS01 | Modify motor policy |
| `'01DMOT'` | Delete Motor | LGDPOL01 → LGDPDB01 → LGDPVS01 | Remove motor policy |

#### Endowment Policy Operations

| Request ID | Operation | Target Program Chain | Description |
|-----------|-----------|---------------------|-------------|
| `'01IEND'` | Inquire Endowment | LGIPOL01 → LGIPDB01 → LGIPVS01 | Retrieve endowment policy details |
| `'01AEND'` | Add Endowment | LGAPOL01 → LGAPDB01 → LGAPVS01 | Create new endowment policy |
| `'01UEND'` | Update Endowment | LGUPOL01 → LGUPDB01 → LGUPVS01 | Modify endowment policy |
| `'01DEND'` | Delete Endowment | LGDPOL01 → LGDPDB01 → LGDPVS01 | Remove endowment policy |

#### House Policy Operations

| Request ID | Operation | Target Program Chain | Description |
|-----------|-----------|---------------------|-------------|
| `'01IHOU'` | Inquire House | LGIPOL01 → LGIPDB01 → LGIPVS01 | Retrieve house policy details |
| `'01AHOU'` | Add House | LGAPOL01 → LGAPDB01 → LGAPVS01 | Create new house policy |
| `'01UHOU'` | Update House | LGUPOL01 → LGUPDB01 → LGUPVS01 | Modify house policy |
| `'01DHOU'` | Delete House | LGDPOL01 → LGDPDB01 → LGDPVS01 | Remove house policy |

#### Commercial Policy Operations

| Request ID | Operation | Target Program Chain | Description |
|-----------|-----------|---------------------|-------------|
| `'01ICOM'` | Inquire Commercial | LGIPOL01 → LGIPDB01 → LGIPVS01 | Retrieve commercial policy details |
| `'01ACOM'` | Add Commercial | LGAPOL01 → LGAPDB01 → LGAPVS01 | Create new commercial policy |
| `'01UCOM'` | Update Commercial | LGUPOL01 → LGUPDB01 → LGUPVS01 | Modify commercial policy |
| `'01DCOM'` | Delete Commercial | LGDPOL01 → LGDPDB01 → LGDPVS01 | Remove commercial policy |

#### Security Operations

| Request ID | Operation | Target Program Chain | Description |
|-----------|-----------|---------------------|-------------|
| `'02ACUS'` | Add Customer Security | LGACDB02 | Create customer security credentials |

### Request ID Usage Pattern

Business logic programs receive CA-REQUEST-ID but typically don't inspect it - they delegate directly to database layer:

```cobol
/* LGACUS01 - Add Customer Business Logic */
MAINLINE SECTION.
    /* Validate commarea */
    PERFORM INSERT-CUSTOMER.
    EXEC CICS RETURN END-EXEC.

INSERT-CUSTOMER.
    /* CA-REQUEST-ID already set by presentation layer */
    EXEC CICS LINK Program(LGACDB01)
         Commarea(DFHCOMMAREA)
         LENGTH(32500)
    END-EXEC.
    EXIT.
```

Database layer programs may inspect CA-REQUEST-ID for operation-specific logic, but in GenApp they primarily rely on program name for routing.

## Conditional IF Statement Routing

### Error Code Routing

Programs use IF statements to route based on return codes:

#### Presentation Layer Error Routing (LGTESTC1, Lines 94-96)

```cobol
EXEC CICS LINK PROGRAM('LGICUS01')
          COMMAREA(COMM-AREA)
          LENGTH(32500)
END-EXEC

IF CA-RETURN-CODE > 0
  GO TO NO-DATA
END-IF
```

**Return Code Values**:
- `'00'` = Success - continue normal processing
- `'70'` = Entity not found - display "No data was returned"
- `'90'` = Database error - display "Error Adding/Updating"
- `'98'` = Invalid commarea length - return immediately

#### Business Logic Validation Routing (LGACUS01, Lines 112-115)

```cobol
IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN
  MOVE '98' TO CA-RETURN-CODE
  EXEC CICS RETURN END-EXEC
END-IF
```

#### Database Layer SQL Error Routing (LGACDB01, Lines 245-248)

```cobol
EXEC SQL
  INSERT INTO CUSTOMER (...)
  VALUES (...)
END-EXEC

IF SQLCODE NOT EQUAL 0
  MOVE '90' TO CA-RETURN-CODE
  PERFORM WRITE-ERROR-MESSAGE
  EXEC CICS RETURN END-EXEC
END-IF
```

### Resource Availability Routing

Programs route based on resource availability:

#### Named Counter Service Routing (LGACDB01, Lines 206-211)

```cobol
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

Then later (Lines 221-283):

```cobol
IF LGAC-NCS = 'ON'
  /* Use Named Counter value */
  EXEC SQL
    INSERT INTO CUSTOMER
    VALUES (:DB2-CUSTOMERNUM-INT, ...)
  END-EXEC
ELSE
  /* Use DB2 IDENTITY column */
  EXEC SQL
    INSERT INTO CUSTOMER
    VALUES (DEFAULT, ...)
  END-EXEC
  EXEC SQL
    SET :DB2-CUSTOMERNUM-INT = IDENTITY_VAL_LOCAL()
  END-EXEC
END-IF.
```

### Commarea Length Routing

All programs validate commarea length before processing:

```cobol
IF EIBCALEN IS EQUAL TO ZERO
    MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
    PERFORM WRITE-ERROR-MESSAGE
    EXEC CICS ABEND ABCODE('LGCA') NODUMP END-EXEC
END-IF

/* Calculate required length */
ADD WS-CA-HEADER-LEN TO WS-REQUIRED-CA-LEN
ADD WS-CUSTOMER-LEN  TO WS-REQUIRED-CA-LEN

IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN
  MOVE '98' TO CA-RETURN-CODE
  EXEC CICS RETURN END-EXEC
END-IF
```

## Complete Routing Examples

### Example 1: Add Customer Flow

```
User Action: Enter SSC1, select option 2 (Add Customer)
│
├─ Level 1: EIBTRNID = 'SSC1'
│  └─ CICS invokes LGTESTC1
│
├─ Level 2: EVALUATE ENP1OPTO
│  └─ WHEN '2'
│     ├─ Move '01ACUS' To CA-REQUEST-ID
│     ├─ Populate COMM-AREA from map fields
│     ├─ Inspect COMM-AREA (normalize data)
│     └─ EXEC CICS LINK PROGRAM('LGACUS01')
│
├─ Business Logic: LGACUS01
│  ├─ Validate EIBCALEN
│  │  └─ IF EIBCALEN = 0 → ABEND
│  ├─ Validate commarea length
│  │  └─ IF too short → CA-RETURN-CODE='98', RETURN
│  ├─ PERFORM INSERT-CUSTOMER
│  │  └─ EXEC CICS LINK Program(LGACDB01)
│  └─ EXEC CICS RETURN
│
├─ Database Layer: LGACDB01
│  ├─ Level 3: CA-REQUEST-ID = '01ACUS' (implicit)
│  ├─ PERFORM Obtain-CUSTOMER-Number
│  │  ├─ Exec CICS Get Counter
│  │  └─ IF WS-RESP ≠ NORMAL
│  │     ├─ LGAC-NCS = 'NO'
│  │     └─ Use DB2 IDENTITY
│  ├─ PERFORM INSERT-CUSTOMER
│  │  ├─ IF LGAC-NCS = 'ON'
│  │  │  └─ INSERT with counter value
│  │  └─ ELSE
│  │     ├─ INSERT with DEFAULT
│  │     └─ Get IDENTITY_VAL_LOCAL()
│  ├─ IF SQLCODE ≠ 0
│  │  ├─ CA-RETURN-CODE = '90'
│  │  ├─ PERFORM WRITE-ERROR-MESSAGE
│  │  └─ RETURN
│  ├─ EXEC CICS LINK Program(LGACVS01)
│  ├─ EXEC CICS LINK Program(LGACDB02)
│  └─ EXEC CICS RETURN
│
└─ Back to Presentation: LGTESTC1
   ├─ IF CA-RETURN-CODE > 0
   │  ├─ Exec CICS Syncpoint Rollback
   │  └─ GO TO NO-ADD → ERROR-OUT
   ├─ Perform WRITE-GENACNTL
   ├─ Display success message
   └─ EXEC CICS RETURN TRANSID('SSC1')
```

### Example 2: Inquire Motor Policy Flow

```
User Action: Enter SSP1, select option 1 (Inquire Motor)
│
├─ Level 1: EIBTRNID = 'SSP1'
│  └─ CICS invokes LGTESTP1
│
├─ Level 2: EVALUATE ENP1OPTO
│  └─ WHEN '1'
│     ├─ Move '01IMOT' To CA-REQUEST-ID
│     ├─ Move ENP1CNOO To CA-CUSTOMER-NUM
│     ├─ Move ENP1PNOO To CA-POLICY-NUM
│     └─ EXEC CICS LINK PROGRAM('LGIPOL01')
│
├─ Business Logic: LGIPOL01
│  ├─ Level 3: CA-REQUEST-ID = '01IMOT' (implicit)
│  ├─ Validate EIBCALEN
│  ├─ EXEC CICS LINK Program(LGIPDB01)
│  └─ EXEC CICS RETURN
│
├─ Database Layer: LGIPDB01
│  ├─ EXEC SQL SELECT ... WHERE CUSTOMERNUMBER = :CA-CUSTOMER-NUM
│  │                        AND POLICYNUMBER = :CA-POLICY-NUM
│  │                        AND POLICYTYPE = 'M'
│  ├─ IF SQLCODE = 0
│  │  ├─ Move DB2 fields to CA-M-* fields
│  │  └─ CA-RETURN-CODE = '00'
│  └─ ELSE
│     ├─ CA-RETURN-CODE = '70' (not found)
│     └─ PERFORM WRITE-ERROR-MESSAGE
│
└─ Back to Presentation: LGTESTP1
   ├─ IF CA-RETURN-CODE > 0
   │  └─ GO TO NO-DATA
   ├─ Move CA-M-* fields to ENP1* map fields
   ├─ EXEC CICS SEND MAP
   └─ GO TO ENDIT-STARTIT
```

### Example 3: Update Customer with Error Flow

```
User Action: Enter SSC1, select option 4 (Update Customer)
│
├─ Level 1: EIBTRNID = 'SSC1'
│  └─ CICS invokes LGTESTC1
│
├─ Level 2: EVALUATE ENP1OPTO
│  └─ WHEN '4'
│     ├─ Phase 1: Inquire to populate screen
│     │  ├─ Move '01ICUS' To CA-REQUEST-ID
│     │  ├─ EXEC CICS LINK PROGRAM('LGICUS01')
│     │  ├─ IF CA-RETURN-CODE > 0 → GO TO NO-DATA
│     │  ├─ Move CA-* to ENT1* (populate map)
│     │  └─ EXEC CICS SEND MAP
│     │
│     ├─ EXEC CICS RECEIVE MAP (get user changes)
│     │
│     └─ Phase 2: Update with changes
│        ├─ Move '01UCUS' To CA-REQUEST-ID
│        ├─ Move ENT1* to CA-* (user changes)
│        ├─ Inspect COMM-AREA
│        └─ EXEC CICS LINK PROGRAM('LGUCUS01')
│
├─ Business Logic: LGUCUS01
│  ├─ Validate EIBCALEN and length
│  ├─ EXEC CICS LINK Program(LGUCDB01)
│  └─ EXEC CICS RETURN
│
├─ Database Layer: LGUCDB01
│  ├─ EXEC SQL UPDATE CUSTOMER SET ... WHERE CUSTOMERNUMBER = :CA-CUSTOMER-NUM
│  ├─ IF SQLCODE ≠ 0
│  │  ├─ CA-RETURN-CODE = '90'
│  │  ├─ PERFORM WRITE-ERROR-MESSAGE
│  │  └─ RETURN
│  ├─ EXEC CICS LINK Program(LGUCVS01)
│  └─ EXEC CICS RETURN
│
└─ Back to Presentation: LGTESTC1
   ├─ IF CA-RETURN-CODE > 0
   │  └─ GO TO NO-UPD
   │     └─ ERROR-OUT
   │        ├─ Move 'Error Updating Customer' To ERRFLDO
   │        ├─ EXEC CICS SEND MAP
   │        ├─ Initialize structures
   │        └─ GO TO ENDIT-STARTIT
   │
   ├─ Move 'Customer details updated' To ERRFLDO
   ├─ EXEC CICS SEND MAP
   └─ GO TO ENDIT-STARTIT
```

## Routing Decision Matrix

| Level | Decision Point | Input | Output | Location |
|-------|---------------|-------|--------|----------|
| 1 | Transaction Start | User enters transaction ID | CICS invokes program | CICS Transaction Definition |
| 1 | Pseudo-conversational | RETURN TRANSID | CICS restarts transaction | Presentation RETURN statements |
| 2 | Menu Selection | User option (1-4) | CA-REQUEST-ID + Program name | Presentation EVALUATE |
| 3 | Operation Type | CA-REQUEST-ID | Database program selection | Business Logic LINK |
| 4 | Error Handling | CA-RETURN-CODE | Error paragraph or continue | All layers IF statements |
| 5 | Resource Availability | RESP codes | Fallback logic | Database layer IF statements |

## Routing Best Practices

### 1. Separation of Concerns
- **Presentation**: User interaction and display
- **Business Logic**: Validation and orchestration
- **Database**: Data persistence

### 2. Consistent Naming
- Transaction IDs follow pattern: SS + entity code (C=Customer, P=Policy)
- Request IDs follow pattern: PPOEEE
- Programs follow pattern: LG + operation + entity + layer

### 3. Error Propagation
- Database layer sets CA-RETURN-CODE
- Business logic passes through unchanged
- Presentation layer interprets and displays

### 4. Loose Coupling
- Programs communicate via COMMAREA only
- No direct dependencies between layers
- CA-REQUEST-ID provides routing context

### 5. Stateless Design
- Each program is stateless
- State preserved in COMMAREA
- Pseudo-conversational for scalability

## Related Documentation

- [Transaction Entry Points](TRANSACTION-ENTRY-POINTS.md)
- [Control Flow Analysis](CONTROL-FLOW-ANALYSIS.md)
- [External Dependencies](EXTERNAL-DEPENDENCIES.md)
- [System Architecture Diagram](SYSTEM-ARCHITECTURE-DIAGRAM.md)