# External Dependencies Analysis

## Overview

This document catalogs all external dependencies in the GenApp CICS application, including DB2 database tables, VSAM files, CICS resources, copybooks, and inter-program dependencies. It provides a comprehensive reference for understanding the system's external integration points.

## Table of Contents

1. [DB2 Database Dependencies](#db2-database-dependencies)
2. [VSAM File Dependencies](#vsam-file-dependencies)
3. [CICS Resource Dependencies](#cics-resource-dependencies)
4. [Copybook Dependencies](#copybook-dependencies)
5. [Program Dependencies](#program-dependencies)
6. [Utility Program Dependencies](#utility-program-dependencies)

## DB2 Database Dependencies

### Customer Table

**Table Name**: `CUSTOMER`

**Accessed By**: LGACDB01, LGICDB01, LGUCDB01

**Columns**:
| Column Name | Data Type | Description | Constraints |
|------------|-----------|-------------|-------------|
| CUSTOMERNUMBER | INTEGER | Unique customer identifier | PRIMARY KEY, IDENTITY |
| FIRSTNAME | VARCHAR(10) | Customer first name | NOT NULL |
| LASTNAME | VARCHAR(20) | Customer last name | NOT NULL |
| DATEOFBIRTH | DATE | Customer date of birth | NOT NULL |
| HOUSENAME | VARCHAR(20) | Residence name | |
| HOUSENUMBER | VARCHAR(4) | Street number | |
| POSTCODE | VARCHAR(8) | Postal code | |
| PHONEMOBILE | VARCHAR(20) | Mobile phone number | |
| PHONEHOME | VARCHAR(20) | Home phone number | |
| EMAILADDRESS | VARCHAR(100) | Email address | |

**Operations**:
- **INSERT**: LGACDB01 (Lines 222-244, 251-273)
  - Uses Named Counter value or DB2 IDENTITY column
  - Returns generated customer number via IDENTITY_VAL_LOCAL()
- **SELECT**: LGICDB01
  - Retrieves customer by CUSTOMERNUMBER
- **UPDATE**: LGUCDB01
  - Updates customer details by CUSTOMERNUMBER

**SQL Examples**:

```sql
-- Insert with Named Counter (LGACDB01, Lines 222-244)
INSERT INTO CUSTOMER
  (CUSTOMERNUMBER, FIRSTNAME, LASTNAME, DATEOFBIRTH,
   HOUSENAME, HOUSENUMBER, POSTCODE,
   PHONEMOBILE, PHONEHOME, EMAILADDRESS)
VALUES
  (:DB2-CUSTOMERNUM-INT, :CA-FIRST-NAME, :CA-LAST-NAME, :CA-DOB,
   :CA-HOUSE-NAME, :CA-HOUSE-NUM, :CA-POSTCODE,
   :CA-PHONE-MOBILE, :CA-PHONE-HOME, :CA-EMAIL-ADDRESS)

-- Insert with IDENTITY (LGACDB01, Lines 251-273)
INSERT INTO CUSTOMER
  (CUSTOMERNUMBER, FIRSTNAME, LASTNAME, ...)
VALUES
  (DEFAULT, :CA-FIRST-NAME, :CA-LAST-NAME, ...)

-- Get generated identity value (LGACDB01, Lines 280-282)
SET :DB2-CUSTOMERNUM-INT = IDENTITY_VAL_LOCAL()
```

### Policy Tables

**Table Name**: `ENDOWMENT`, `MOTOR`, `HOUSE`, `COMMERCIAL`

**Accessed By**: LGAPDB01, LGIPDB01, LGUPDB01, LGDPDB01

**Common Policy Columns**:
| Column Name | Data Type | Description |
|------------|-----------|-------------|
| POLICYNUMBER | INTEGER | Unique policy identifier (PRIMARY KEY) |
| CUSTOMERNUMBER | INTEGER | Foreign key to CUSTOMER |
| ISSUEDATE | DATE | Policy issue date |
| EXPIRYDATE | DATE | Policy expiry date |
| LASTCHANGED | TIMESTAMP | Last modification timestamp |
| BROKERID | INTEGER | Broker identifier |
| BROKERSREF | VARCHAR(10) | Broker reference |
| PAYMENT | INTEGER | Payment amount |
| POLICYTYPE | CHAR(1) | 'E'=Endowment, 'M'=Motor, 'H'=House, 'C'=Commercial |

**Motor-Specific Columns**:
| Column Name | Data Type | Description |
|------------|-----------|-------------|
| MAKE | VARCHAR(15) | Vehicle manufacturer |
| MODEL | VARCHAR(15) | Vehicle model |
| VALUE | INTEGER | Vehicle value |
| REGNUMBER | VARCHAR(7) | Registration number |
| COLOUR | VARCHAR(8) | Vehicle color |
| CC | INTEGER | Engine capacity |
| MANUFACTURED | VARCHAR(10) | Manufacturing date |
| PREMIUM | INTEGER | Insurance premium |
| ACCIDENTS | INTEGER | Number of accidents |

**Endowment-Specific Columns**:
| Column Name | Data Type | Description |
|------------|-----------|-------------|
| WITHPROFITS | CHAR(1) | With profits flag |
| EQUITIES | CHAR(1) | Equities flag |
| MANAGEDFUND | CHAR(1) | Managed fund flag |
| FUNDNAME | VARCHAR(10) | Fund name |
| TERM | SMALLINT | Policy term in years |
| SUMASSURED | INTEGER | Sum assured amount |
| LIFEASSURED | VARCHAR(31) | Life assured name |

**House-Specific Columns**:
| Column Name | Data Type | Description |
|------------|-----------|-------------|
| PROPERTYTYPE | VARCHAR(15) | Property type |
| BEDROOMS | INTEGER | Number of bedrooms |
| VALUE | INTEGER | Property value |
| HOUSENAME | VARCHAR(20) | House name |
| HOUSENUMBER | VARCHAR(4) | House number |
| POSTCODE | VARCHAR(8) | Postal code |

**Commercial-Specific Columns**:
| Column Name | Data Type | Description |
|------------|-----------|-------------|
| ADDRESS | VARCHAR(255) | Business address |
| POSTCODE | VARCHAR(8) | Postal code |
| LATITUDE | VARCHAR(11) | Geographic latitude |
| LONGITUDE | VARCHAR(11) | Geographic longitude |
| CUSTOMER | VARCHAR(255) | Customer name |
| PROPTYPE | VARCHAR(255) | Property type |
| FIREPERIL | INTEGER | Fire peril rating |
| FIREPREMIUM | INTEGER | Fire premium |
| CRIMEPERIL | INTEGER | Crime peril rating |
| CRIMEPREMIUM | INTEGER | Crime premium |
| FLOODPERIL | INTEGER | Flood peril rating |
| FLOODPREMIUM | INTEGER | Flood premium |
| WEATHERPERIL | INTEGER | Weather peril rating |
| WEATHERPREMIUM | INTEGER | Weather premium |
| STATUS | INTEGER | Policy status |
| REJECTREASON | VARCHAR(255) | Rejection reason |

### Customer Security Table

**Table Name**: `CUSTSECR`

**Accessed By**: LGACDB02

**Columns**:
| Column Name | Data Type | Description |
|------------|-----------|-------------|
| CUSTOMERNUMBER | INTEGER | Foreign key to CUSTOMER (PRIMARY KEY) |
| PASSWORD | VARCHAR(32) | Password hash |
| FAILCOUNT | VARCHAR(4) | Failed login attempts |
| STATE | CHAR(1) | Account state ('N'=New, 'A'=Active, 'L'=Locked) |

**Operations**:
- **INSERT**: LGACDB02
  - Creates security record for new customer
  - Initial password: '5732fec825535eeafb8fac50fee3a8aa'
  - Initial state: 'N' (New)

### Two-Phase Commit

All database operations participate in CICS two-phase commit:

```cobol
/* On error in presentation layer (LGTESTC1, Line 133) */
IF CA-RETURN-CODE > 0
  Exec CICS Syncpoint Rollback End-Exec
  GO TO NO-ADD
END-IF
```

**Characteristics**:
- Ensures atomicity across DB2 and VSAM updates
- Automatic rollback on error
- Coordinated by CICS Transaction Manager

## VSAM File Dependencies

### Customer VSAM File

**File Name**: Referenced via LGACVS01, LGICVS01, LGUCVS01

**Purpose**: Parallel persistence to VSAM for demonstration of two-phase commit

**Key Structure**: Customer Number (10 digits)

**Record Layout**: Matches CUSTOMER table structure

**Operations**:
- **WRITE**: LGACVS01 (after DB2 INSERT)
- **READ**: LGICVS01 (parallel to DB2 SELECT)
- **REWRITE**: LGUCVS01 (after DB2 UPDATE)

### Policy VSAM Files

**File Names**: Referenced via LGAPVS01, LGIPVS01, LGUPVS01, LGDPVS01

**Purpose**: Parallel persistence for policy data

**Key Structure**: Customer Number + Policy Number

**Record Layout**: Matches policy table structures

**Operations**:
- **WRITE**: LGAPVS01
- **READ**: LGIPVS01
- **REWRITE**: LGUPVS01
- **DELETE**: LGDPVS01

### VSAM Access Pattern

```cobol
/* Example from LGACDB01 (Lines 174-177) */
EXEC CICS LINK Program(LGACVS01)
     Commarea(DFHCOMMAREA)
     LENGTH(225)
END-EXEC.
```

**Note**: VSAM operations are coordinated with DB2 via two-phase commit. If either fails, both are rolled back.

## CICS Resource Dependencies

### Temporary Storage Queues

#### GENACNTL Queue

**Purpose**: Track customer number range (low/high)

**Accessed By**: LGTESTC1 (WRITE-GENACNTL paragraph), LGSETUP

**Structure**:
```
Item 1: '**** GENAPP CNTL'
Item 2: 'LOW CUSTOMER=nnnnnnnnnn'
Item 3: 'HIGH CUSTOMER=nnnnnnnnnn'
```

**Operations**:
- **ENQ/DEQ**: Serialization for concurrent access (LGTESTC1, Lines 285, 343)
- **READQ TS**: Read existing range (LGTESTC1, Lines 290-301)
- **WRITEQ TS REWRITE**: Update high customer number (LGTESTC1, Line 307)
- **WRITEQ TS**: Create new queue (LGTESTC1, Lines 321-340)
- **DELETEQ TS**: Delete queue (LGSETUP, Line 150)

**Example Usage** (LGTESTC1, Lines 285-345):
```cobol
EXEC CICS ENQ Resource(STSQ-NAME)
              Length(Length Of STSQ-NAME)
END-EXEC.

/* Read and update queue */

EXEC CICS DEQ Resource(STSQ-NAME)
              Length(Length Of STSQ-NAME)
END-EXEC.
```

#### GENASTRT, GENASTAT, GENAERRS Queues

**Purpose**: System statistics and error logging

**Accessed By**: LGSETUP, LGASTAT1

**Operations**:
- **DELETEQ TS**: Cleanup during initialization (LGSETUP, Lines 138-148)

### Named Counters

#### GENACUSTNUM Counter

**Purpose**: Generate sequential customer numbers

**Pool**: GENA

**Accessed By**: LGACDB01

**Operations**:
- **GET COUNTER**: Retrieve next customer number (LGACDB01, Lines 201-205)
- **DEFINE COUNTER**: Initialize counter (LGSETUP, Lines 183-187)
- **DELETE COUNTER**: Remove counter (LGSETUP, Lines 179-182)

**Example** (LGACDB01, Lines 201-205):
```cobol
Exec CICS Get Counter(GENAcount)
          Pool(GENApool)
          Value(LastCustNum)
          Resp(WS-RESP)
End-Exec.
```

**Fallback**: If counter unavailable, use DB2 IDENTITY column (LGACDB01, Lines 206-211)

#### Transaction Counters

**Purpose**: Track transaction statistics per operation type

**Pool**: GENA

**Counter Names**: 
- GENA01ICUS00 through GENA01ICUS99 (Inquire Customer)
- GENA01ACUS00 through GENA01ACUS99 (Add Customer)
- GENA01IMOT00 through GENA01IMOT99 (Inquire Motor)
- GENA01AMOT00 through GENA01AMOT99 (Add Motor)
- ... (18 counter pairs total)

**Accessed By**: LGSETUP (initialization), LGASTAT1 (statistics collection)

**Operations**:
- **DEFINE COUNTER**: Initialize all counters to 0 (LGSETUP, Lines 189-516)
- **DELETE COUNTER**: Remove counters (LGSETUP)

**Example** (LGSETUP, Lines 189-197):
```cobol
Exec CICS Delete Counter(GENACNT100)
                 Pool(GENApool)
                 Resp(WS-RESP)
End-Exec.
Exec CICS Define Counter(GENACNT100)
                 Pool(GENApool)
                 Value(0)
                 Resp(WS-RESP)
End-Exec.
```

### BMS Maps

#### SSMAP Mapset

**Maps Defined**:
- **SSMAPC1**: Customer menu (LGTESTC1)
- **SSMAPP1**: Motor policy menu (LGTESTP1)
- **SSMAPP2**: Endowment policy menu (LGTESTP2)
- **SSMAPP3**: House policy menu (LGTESTP3)
- **SSMAPP4**: Commercial policy menu (LGTESTP4)

**Source**: base/src/ssmap.bms

**Operations**:
- **SEND MAP**: Display screen (all presentation programs)
- **RECEIVE MAP**: Get user input (all presentation programs)
- **SEND MAP MAPONLY**: Clear screen (CLEARIT paragraphs)

**Example** (LGTESTC1, Lines 64-68):
```cobol
EXEC CICS SEND MAP ('SSMAPC1')
          FROM(SSMAPC1O)
          MAPSET ('SSMAP')
          ERASE
END-EXEC.
```

### AID Key Handling

**Keys Handled**:
- **CLEAR**: Clear screen and restart (CLEARIT paragraph)
- **PF3**: End transaction (ENDIT paragraph)
- **MAPFAIL**: Handle no input (ENDIT paragraph)

**Example** (LGTESTC1, Lines 72-77):
```cobol
EXEC CICS HANDLE AID
          CLEAR(CLEARIT)
          PF3(ENDIT) END-EXEC.
EXEC CICS HANDLE CONDITION
          MAPFAIL(ENDIT)
END-EXEC.
```

## Copybook Dependencies

### LGCMAREA - Communication Area

**File**: base/src/lgcmarea.cpy

**Size**: 32,500 bytes

**Structure**:
```cobol
03 CA-REQUEST-ID            PIC X(6).      /* Routing code */
03 CA-RETURN-CODE           PIC 9(2).      /* Return status */
03 CA-CUSTOMER-NUM          PIC 9(10).     /* Customer ID */
03 CA-REQUEST-SPECIFIC      PIC X(32482).  /* Variable payload */
```

**Redefines**:
- **CA-CUSTOMER-REQUEST**: Customer data (FIRST-NAME, LAST-NAME, DOB, etc.)
- **CA-CUSTSECR-REQUEST**: Security data (PASSWORD, COUNT, STATE)
- **CA-POLICY-REQUEST**: Policy data with sub-redefines:
  - CA-ENDOWMENT: Endowment policy fields
  - CA-MOTOR: Motor policy fields
  - CA-HOUSE: House policy fields
  - CA-COMMERCIAL: Commercial policy fields
  - CA-CLAIM: Claim fields

**Used By**: All programs in the system

**Purpose**: 
- Inter-program communication
- State preservation in pseudo-conversational design
- Polymorphic data structure for different entity types

### LGPOLICY - Policy Data Structures

**File**: base/src/lgpolicy.cpy

**Purpose**: Define policy-related data structures and lengths

**Contains**:
- WS-CUSTOMER-LEN: Customer data length
- Policy type definitions
- Common policy fields

**Used By**: Business logic and database layer programs

### SSMAP - BMS Map Definitions

**File**: base/src/ssmap.bms

**Purpose**: Screen layout definitions

**Contains**:
- Map field definitions
- Attribute bytes
- Screen positioning

**Generated Files**:
- SSMAP (symbolic map for COBOL)
- Physical map loaded into CICS

**Used By**: All presentation programs (COPY SSMAP)

### SQLCA - DB2 Communications Area

**Purpose**: DB2 error handling and diagnostics

**Contains**:
- SQLCODE: SQL return code
- SQLSTATE: SQL state
- SQLERRM: Error message
- SQLWARN: Warning flags

**Used By**: All database layer programs

**Example** (LGACDB01, Lines 108-110):
```cobol
EXEC SQL
    INCLUDE SQLCA
END-EXEC.
```

## Program Dependencies

### Three-Tier Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                           │
├─────────────────────────────────────────────────────────────┤
│ LGTESTC1 │ LGTESTP1 │ LGTESTP2 │ LGTESTP3 │ LGTESTP4       │
└────┬──────┴────┬─────┴────┬─────┴────┬─────┴────┬───────────┘
     │           │          │          │          │
     ▼           ▼          ▼          ▼          ▼
┌─────────────────────────────────────────────────────────────┐
│ BUSINESS LOGIC LAYER                                         │
├─────────────────────────────────────────────────────────────┤
│ Customer Programs:                                           │
│   LGACUS01 (Add)    LGICUS01 (Inquire)    LGUCUS01 (Update)│
│                                                              │
│ Policy Programs:                                             │
│   LGAPOL01 (Add)    LGIPOL01 (Inquire)                     │
│   LGUPOL01 (Update) LGDPOL01 (Delete)                      │
└────┬──────┬────┬─────┬────┬─────┬────┬─────┬───────────────┘
     │      │    │     │    │     │    │     │
     ▼      ▼    ▼     ▼    ▼     ▼    ▼     ▼
┌─────────────────────────────────────────────────────────────┐
│ DATABASE ACCESS LAYER                                        │
├─────────────────────────────────────────────────────────────┤
│ DB2 Programs:                                                │
│   LGACDB01 → LGACDB02 (Customer Add + Security)            │
│   LGICDB01 (Customer Inquire)                               │
│   LGUCDB01 (Customer Update)                                │
│   LGAPDB01 (Policy Add)                                     │
│   LGIPDB01 (Policy Inquire)                                 │
│   LGUPDB01 (Policy Update)                                  │
│   LGDPDB01 (Policy Delete)                                  │
│                                                              │
│ VSAM Programs:                                               │
│   LGACVS01 (Customer Add)                                   │
│   LGICVS01 (Customer Inquire)                               │
│   LGUCVS01 (Customer Update)                                │
│   LGAPVS01 (Policy Add)                                     │
│   LGIPVS01 (Policy Inquire)                                 │
│   LGUPVS01 (Policy Update)                                  │
│   LGDPVS01 (Policy Delete)                                  │
└─────────────────────────────────────────────────────────────┘
```

### Program Call Chains

#### Add Customer Chain

```
LGTESTC1 (SSC1, Option 2)
    │
    ├─ EXEC CICS LINK PROGRAM('LGACUS01')
    │      │
    │      ├─ EXEC CICS LINK Program(LGACDB01)
    │      │      │
    │      │      ├─ EXEC SQL INSERT INTO CUSTOMER
    │      │      ├─ EXEC CICS LINK Program(LGACVS01)
    │      │      │      └─ VSAM WRITE
    │      │      └─ EXEC CICS LINK Program(LGACDB02)
    │      │             └─ EXEC SQL INSERT INTO CUSTSECR
    │      └─ RETURN
    │
    └─ Perform WRITE-GENACNTL
           └─ Update GENACNTL queue
```

#### Add Motor Policy Chain

```
LGTESTP1 (SSP1, Option 2)
    │
    ├─ EXEC CICS LINK PROGRAM('LGAPOL01')
    │      │
    │      └─ EXEC CICS Link Program(LGAPDB01)
    │             │
    │             ├─ EXEC SQL INSERT INTO MOTOR
    │             └─ EXEC CICS LINK Program(LGAPVS01)
    │                    └─ VSAM WRITE
    │
    └─ Display results
```

#### Inquire Customer Chain

```
LGTESTC1 (SSC1, Option 1)
    │
    └─ EXEC CICS LINK PROGRAM('LGICUS01')
           │
           └─ EXEC CICS LINK Program(LGICDB01)
                  │
                  ├─ EXEC SQL SELECT FROM CUSTOMER
                  └─ EXEC CICS LINK Program(LGICVS01)
                         └─ VSAM READ
```

## Utility Program Dependencies

### LGSTSQ - Error Logging

**Purpose**: Write error messages to temporary storage queue

**Called By**: All programs (WRITE-ERROR-MESSAGE paragraphs)

**Parameters**: ERROR-MSG or CA-ERROR-MSG via COMMAREA

**Operations**:
- Writes diagnostic messages to TSQ
- Includes timestamp, program name, error details

**Example** (LGACDB01, Lines 308-311):
```cobol
EXEC CICS LINK PROGRAM('LGSTSQ')
          COMMAREA(ERROR-MSG)
          LENGTH(LENGTH OF ERROR-MSG)
END-EXEC.
```

### LGSETUP - System Initialization

**Purpose**: Initialize CICS resources

**Transaction**: LGSE

**Operations**:
1. Delete existing temporary storage queues
2. Create GENACNTL queue with initial values
3. Delete and recreate GENACUSTNUM counter
4. Delete and recreate all transaction counters (18 pairs)

**Execution**: One-time or periodic (after system restart)

### LGASTAT1 - Statistics Collection

**Purpose**: Collect and report transaction statistics

**Accessed Resources**:
- Transaction counters (GENA01xxxx00-99)
- Statistics queues (GENASTAT)

**Operations**:
- Read counter values
- Generate statistics reports
- Write to output queues

## Dependency Matrix

| Program | DB2 | VSAM | TSQ | Counters | Maps | Copybooks |
|---------|-----|------|-----|----------|------|-----------|
| LGTESTC1 | - | - | GENACNTL | - | SSMAPC1 | LGCMAREA, SSMAP |
| LGTESTP1-4 | - | - | - | - | SSMAPP1-4 | LGCMAREA, SSMAP |
| LGACUS01 | - | - | - | - | - | LGCMAREA, LGPOLICY |
| LGICUS01 | - | - | - | - | - | LGCMAREA |
| LGUCUS01 | - | - | - | - | - | LGCMAREA, LGPOLICY |
| LGAPOL01 | - | - | - | - | - | LGCMAREA |
| LGIPOL01 | - | - | - | - | - | LGCMAREA, LGPOLICY |
| LGUPOL01 | - | - | - | - | - | LGCMAREA |
| LGDPOL01 | - | - | - | - | - | LGCMAREA |
| LGACDB01 | CUSTOMER | - | - | GENACUSTNUM | - | LGCMAREA, LGPOLICY, SQLCA |
| LGICDB01 | CUSTOMER | - | - | - | - | LGCMAREA, SQLCA |
| LGUCDB01 | CUSTOMER | - | - | - | - | LGCMAREA, LGPOLICY, SQLCA |
| LGACDB02 | CUSTSECR | - | - | - | - | LGCMAREA, SQLCA |
| LGAPDB01 | MOTOR/ENDOWMENT/HOUSE/COMMERCIAL | - | - | - | - | LGCMAREA, SQLCA |
| LGIPDB01 | MOTOR/ENDOWMENT/HOUSE/COMMERCIAL | - | - | - | - | LGCMAREA, SQLCA |
| LGUPDB01 | MOTOR/ENDOWMENT/HOUSE/COMMERCIAL | - | - | - | - | LGCMAREA, SQLCA |
| LGDPDB01 | MOTOR/ENDOWMENT/HOUSE/COMMERCIAL | - | - | - | - | LGCMAREA, SQLCA |
| LGACVS01 | - | Customer | - | - | - | LGCMAREA |
| LGICVS01 | - | Customer | - | - | - | LGCMAREA |
| LGUCVS01 | - | Customer | - | - | - | LGCMAREA |
| LGAPVS01 | - | Policy | - | - | - | LGCMAREA |
| LGIPVS01 | - | Policy | - | - | - | LGCMAREA |
| LGUPVS01 | - | Policy | - | - | - | LGCMAREA |
| LGDPVS01 | - | Policy | - | - | - | LGCMAREA |
| LGSTSQ | - | - | Error logs | - | - | - |
| LGSETUP | - | - | GENACNTL, GENASTRT, GENASTAT, GENAERRS | All counters | - | - |
| LGASTAT1 | - | - | GENASTAT | All counters | - | - |

## Resource Initialization Sequence

1. **System Startup**:
   - Execute LGSE transaction
   - LGSETUP program runs

2. **Queue Cleanup**:
   - Delete GENAERRS queue
   - Delete GENASTRT queue
   - Delete GENASTAT queue
   - Delete GENACNTL queue

3. **Queue Creation**:
   - Create GENACNTL with initial customer range
   - Write header, low, and high customer records

4. **Counter Initialization**:
   - Delete GENACUSTNUM counter
   - Define GENACUSTNUM with initial value
   - Delete all transaction counters (18 pairs)
   - Define all transaction counters with value 0

5. **Ready for Operations**:
   - System ready to process transactions
   - Counters available for customer number generation
   - Statistics collection enabled

## Related Documentation

- [Transaction Entry Points](TRANSACTION-ENTRY-POINTS.md)
- [Control Flow Analysis](CONTROL-FLOW-ANALYSIS.md)
- [Transaction Routing Logic](TRANSACTION-ROUTING-LOGIC.md)
- [System Architecture Diagram](SYSTEM-ARCHITECTURE-DIAGRAM.md)
- [Building Guide](../base/Building.md)
- [Installation Guide](../base/Installation.md)