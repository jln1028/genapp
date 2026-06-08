# LGACUS01 Program Documentation

## 1. Program Purpose

LGACUS01 is a CICS business logic program responsible for adding new customer records to the system. It serves as an intermediary layer that validates incoming communication area (COMMAREA) data, ensures proper data structure and length requirements are met, and delegates the actual database insertion operation to a subordinate data access program (LGACDB01). The program implements error handling mechanisms including COMMAREA validation, error logging through temporary storage queues, and appropriate return code management to communicate processing status back to calling programs.

## 2. Program Inputs

The program receives the following inputs:

### 2.1. DFHCOMMAREA (Communication Area)

The primary input parameter passed from the calling program, containing customer data to be added. This structure is defined by the LGCMAREA copybook and includes:
- CA-RETURN-CODE: Return code field for status communication
- CA-NUM-POLICIES: Number of policies field
- Customer data fields as defined in the LGCMAREA copybook structure

### 2.2. CICS Execute Interface Block (EIB) Fields

System-provided runtime information automatically available to the program:
- EIBCALEN: Length of the communication area received
- EIBTRNID: Transaction identifier of the current transaction
- EIBTRMID: Terminal identifier where the transaction originated
- EIBTASKN: Task number assigned to this transaction instance

### 2.3. Copybook Definitions

External data structure definitions included at compile time:
- LGCMAREA: Defines the communication area structure for inter-program communication
- LGPOLICY: Defines customer details length (WS-CUSTOMER-LEN) used for validation

### 2.4. System Time

The program obtains current system time and date through CICS ASKTIME and FORMATTIME commands for error logging purposes.

## 3. Program Outputs

The program produces the following outputs:

### 3.1. Modified DFHCOMMAREA (Communication Area)

The program updates fields in the communication area that is returned to the calling program:
- CA-RETURN-CODE: Set to '00' for successful processing, '98' for insufficient COMMAREA length error, or other codes returned from the LGACDB01 program
- CA-NUM-POLICIES: Initialized to '00' at the start of processing

### 3.2. Database Updates

Through the LGACDB01 program, the program indirectly causes:
- New customer record insertion into the DB2 Customer table
- Any associated database changes performed by the data access layer

### 3.3. Error Log Messages

When errors occur, the program writes diagnostic information to temporary storage queues via the LGSTSQ program:
- ERROR-MSG: Contains formatted error message with date, time, program name (LGACUS01), and error description
- CA-ERROR-MSG: Contains up to 90 bytes of the COMMAREA content for debugging purposes

### 3.4. CICS ABEND

In critical error conditions (no COMMAREA received), the program issues:
- ABEND with code 'LGCA' (without dump) to terminate the transaction abnormally

### 3.5. Return to Caller

The program returns control to the calling program via EXEC CICS RETURN, passing back the modified COMMAREA with status information.
## 4. Program Processing Logic

The program follows a structured processing flow with validation, delegation, and error handling:

### 4.1. Initialization Phase

1. **Working Storage Initialization**: The program begins by initializing the WS-HEADER structure to clear any residual data
2. **Runtime Context Capture**: Captures CICS execution context by moving EIB fields (EIBTRNID, EIBTRMID, EIBTASKN) to working storage variables for debugging and audit purposes

### 4.2. COMMAREA Validation Phase

3. **COMMAREA Existence Check**: Validates that a COMMAREA was passed to the program by checking if EIBCALEN equals zero
   - If no COMMAREA: Logs error message via WRITE-ERROR-MESSAGE paragraph and issues ABEND with code 'LGCA'
   - If COMMAREA exists: Proceeds to length validation

4. **COMMAREA Initialization**: Sets initial values in the COMMAREA:
   - CA-RETURN-CODE set to '00' (success)
   - CA-NUM-POLICIES set to '00'
   - Stores COMMAREA length and address for reference

5. **COMMAREA Length Validation**: Calculates required COMMAREA length by adding:
   - WS-CA-HEADER-LEN (18 bytes for header)
   - WS-CUSTOMER-LEN (from LGPOLICY copybook for customer data)
   - If received length (EIBCALEN) is less than required: Sets CA-RETURN-CODE to '98' and returns to caller

### 4.3. Business Logic Execution Phase

6. **Customer Insertion**: Performs the INSERT-CUSTOMER paragraph which delegates the actual database operation to the LGACDB01 program via CICS LINK command, passing:
   - The entire DFHCOMMAREA structure
   - A fixed length of 32500 bytes
   - Any return codes from LGACDB01 are automatically reflected in the COMMAREA

### 4.4. Completion Phase

7. **Return to Caller**: Issues EXEC CICS RETURN to pass control back to the calling program with the updated COMMAREA containing processing results

### 4.5. Error Handling Logic

The WRITE-ERROR-MESSAGE paragraph provides diagnostic logging:
1. Obtains current system time using CICS ASKTIME
2. Formats time and date using CICS FORMATTIME (MMDDYYYY format for date, standard format for time)
3. Populates ERROR-MSG structure with timestamp and error details
4. Writes error message to temporary storage queue via LGSTSQ program
5. Conditionally writes COMMAREA content (up to 90 bytes) to the queue for debugging:
   - If EIBCALEN < 91: Writes actual COMMAREA length
   - If EIBCALEN >= 91: Writes first 90 bytes only

## 5. Program Paragraphs

The program is organized into the following sections and paragraphs:

### 5.1. MAINLINE Section

The primary control section that orchestrates the entire customer addition process. This section contains the main program logic flow and is executed when the program is invoked.

**Operations Performed:**
- Initializes working storage variables (WS-HEADER)
- Captures runtime context from CICS EIB fields (transaction ID, terminal ID, task number)
- Validates COMMAREA existence and length
- Initializes COMMAREA return codes
- Performs customer insertion via INSERT-CUSTOMER paragraph
- Returns control to the calling program

**Control Flow:**
- IF EIBCALEN = 0: Performs WRITE-ERROR-MESSAGE and issues ABEND 'LGCA'
- IF EIBCALEN < required length: Sets CA-RETURN-CODE to '98' and returns
- Otherwise: Proceeds with customer insertion

**Exit Point:** MAINLINE-EXIT paragraph provides a clean exit from the section

### 5.2. INSERT-CUSTOMER Paragraph

Delegates the database insertion operation to the data access layer program.

**Purpose:** Acts as a wrapper for the database operation, maintaining separation between business logic and data access layers

**Operations Performed:**
- Executes CICS LINK to program LGACDB01
- Passes the entire DFHCOMMAREA structure (32500 bytes)
- Allows LGACDB01 to update the COMMAREA with operation results

**External Interaction:** Links to LGACDB01 program for DB2 customer table insertion

### 5.3. WRITE-ERROR-MESSAGE Paragraph

Provides comprehensive error logging functionality for diagnostic and audit purposes.

**Purpose:** Captures and logs error conditions with timestamp and context information

**Operations Performed:**
1. Obtains current system time via CICS ASKTIME
2. Formats timestamp using CICS FORMATTIME (MMDDYYYY date format)
3. Populates ERROR-MSG structure with date, time, and error details
4. Writes formatted error message to temporary storage queue via LGSTSQ program
5. Conditionally writes COMMAREA content for debugging

**Control Flow:**
- IF EIBCALEN > 0: Writes COMMAREA data to queue
  - IF EIBCALEN < 91: Writes actual COMMAREA length
  - ELSE: Writes first 90 bytes only

**External Interactions:**
- CICS ASKTIME: Retrieves system time
- CICS FORMATTIME: Formats timestamp
- LGSTSQ program: Writes messages to temporary storage queue (called twice per error)

## 6. Program Dependencies

The program has the following dependencies:

### 6.1. Copybooks (Compile-Time Dependencies)

#### 6.1.1. LGCMAREA

**Purpose:** Defines the communication area structure used for inter-program communication
**Usage:** Included in LINKAGE SECTION to define DFHCOMMAREA structure
**Contains:** Fields such as CA-RETURN-CODE, CA-NUM-POLICIES, and customer data fields
**Role:** Provides the contract for data exchange between calling programs and LGACUS01

#### 6.1.2. LGPOLICY

**Purpose:** Defines customer details and policy-related data structures
**Usage:** Included in WORKING-STORAGE SECTION
**Contains:** WS-CUSTOMER-LEN field used for COMMAREA length validation
**Role:** Provides standard customer data structure definitions and length constants

### 6.2. External Programs (Runtime Dependencies)

#### 6.2.1. LGACDB01

**Type:** Data access layer program
**Invocation Method:** CICS LINK command
**Purpose:** Performs actual DB2 customer table insertion operations
**Data Exchange:** Receives and updates DFHCOMMAREA (32500 bytes)
**Role:** Separates database operations from business logic, handles DB2 interactions
**Return Values:** Updates CA-RETURN-CODE in COMMAREA with operation status

#### 6.2.2. LGSTSQ

**Type:** Logging utility program
**Invocation Method:** CICS LINK command (called multiple times per error)
**Purpose:** Writes diagnostic messages to temporary storage queues
**Data Exchange:** 
- First call: ERROR-MSG structure with timestamp and error details
- Second call: CA-ERROR-MSG structure with COMMAREA content (up to 90 bytes)
**Role:** Centralized error logging and audit trail management

### 6.3. CICS System Services

#### 6.3.1. CICS Execute Interface Block (EIB)

**Fields Used:**
- EIBCALEN: Communication area length
- EIBTRNID: Transaction identifier
- EIBTRMID: Terminal identifier
- EIBTASKN: Task number
**Role:** Provides runtime context and transaction information

#### 6.3.2. CICS Commands

- **EXEC CICS ASKTIME**: Retrieves current system time for error logging
- **EXEC CICS FORMATTIME**: Formats timestamp in MMDDYYYY format
- **EXEC CICS LINK**: Invokes external programs (LGACDB01, LGSTSQ)
- **EXEC CICS RETURN**: Returns control to calling program
- **EXEC CICS ABEND**: Terminates transaction abnormally with code 'LGCA'

### 6.4. Database Dependencies (Indirect)

#### 6.4.1. DB2 Customer Table

**Access Method:** Indirect via LGACDB01 program
**Operations:** INSERT operations for new customer records
**Role:** Persistent storage for customer data
**Note:** Direct database access is delegated to the data access layer (LGACDB01)

### 6.5. System Resources

#### 6.5.1. Temporary Storage Queues

**Access Method:** Via LGSTSQ program
**Purpose:** Error message logging and diagnostic information storage
**Content:** Timestamped error messages and COMMAREA snapshots for debugging
## 7. Program Constraints

The program enforces the following constraints and limitations:

### 7.1. Data Structure Constraints

#### 7.1.1. COMMAREA Existence Requirement

**Constraint:** The program MUST receive a COMMAREA from the calling program
**Enforcement:** Checks if EIBCALEN equals zero at program start
**Violation Handling:** Issues ABEND with code 'LGCA' if no COMMAREA is provided
**Rationale:** The program cannot function without customer data to process

#### 7.1.2. COMMAREA Minimum Length Requirement

**Constraint:** COMMAREA must be at least (WS-CA-HEADER-LEN + WS-CUSTOMER-LEN) bytes
**Enforcement:** Calculates required length and compares against EIBCALEN
**Required Length:** Minimum 18 bytes (header) + customer data length from LGPOLICY copybook
**Violation Handling:** Sets CA-RETURN-CODE to '98' and returns to caller
**Rationale:** Ensures sufficient data structure for customer information

#### 7.1.3. COMMAREA Structure Compliance

**Constraint:** COMMAREA must conform to LGCMAREA copybook structure
**Enforcement:** Implicit through copybook definition in LINKAGE SECTION
**Required Fields:** CA-RETURN-CODE, CA-NUM-POLICIES, and customer data fields
**Rationale:** Maintains data contract between calling and called programs

### 7.2. Processing Constraints

#### 7.2.1. Fixed LINK Length

**Constraint:** CICS LINK to LGACDB01 uses fixed length of 32500 bytes
**Implementation:** Hard-coded LENGTH parameter in EXEC CICS LINK command
**Implication:** COMMAREA passed to LGACDB01 is always treated as 32500 bytes regardless of actual length
**Note:** This may allow callers to pass larger COMMAREAs than minimum required

#### 7.2.2. Sequential Processing Order

**Constraint:** Operations must execute in specific sequence
**Enforced Order:**
1. Initialize working storage
2. Validate COMMAREA existence
3. Validate COMMAREA length
4. Perform customer insertion
5. Return to caller
**Rationale:** Ensures data integrity and proper error handling

### 7.3. Error Logging Constraints

#### 7.3.1. Error Message Size Limit

**Constraint:** Error messages are limited to ERROR-MSG structure size
**Size:** Fixed at 45 bytes (8 date + 1 space + 6 time + 9 program name + 21 variable)
**Enforcement:** Structure definition in WORKING-STORAGE
**Implication:** Error descriptions must fit within 21-character EM-VARIABLE field

#### 7.3.2. COMMAREA Debug Data Limit

**Constraint:** Maximum 90 bytes of COMMAREA logged for debugging
**Enforcement:** Conditional logic in WRITE-ERROR-MESSAGE paragraph
**Implementation:**
- If EIBCALEN < 91: Logs actual COMMAREA length
- If EIBCALEN >= 91: Logs only first 90 bytes
**Rationale:** Prevents excessive queue usage while providing sufficient debug information

### 7.4. System Resource Constraints

#### 7.4.1. CICS Transaction Context Dependency

**Constraint:** Program must execute within CICS transaction environment
**Required EIB Fields:** EIBCALEN, EIBTRNID, EIBTRMID, EIBTASKN
**Enforcement:** Implicit through CICS API usage
**Implication:** Cannot be executed as standalone batch program

#### 7.4.2. Temporary Storage Queue Availability

**Constraint:** Temporary storage queues must be available for error logging
**Dependency:** LGSTSQ program must be accessible
**Failure Impact:** Error logging will fail but main processing may continue
**Note:** No explicit error handling for LGSTSQ failures

### 7.5. Data Access Constraints

#### 7.5.1. LGACDB01 Program Availability

**Constraint:** LGACDB01 data access program must be available and linked
**Enforcement:** CICS LINK command execution
**Failure Impact:** Customer insertion fails, return code set in COMMAREA
**Note:** Program relies on LGACDB01 for all database operations

#### 7.5.2. DB2 Availability (Indirect)

**Constraint:** DB2 subsystem must be available for customer insertion
**Enforcement:** Indirect through LGACDB01 program
**Failure Impact:** Handled by LGACDB01, reflected in CA-RETURN-CODE
**Note:** This program has no direct DB2 constraint checking

### 7.6. Return Code Constraints

#### 7.6.1. Return Code Format

**Constraint:** Return codes must be 2-character numeric strings
**Defined Codes:**
- '00': Successful processing
- '98': Insufficient COMMAREA length
- Other codes: Returned from LGACDB01
**Enforcement:** Character field definition (not numeric)
**Implication:** Calling programs must handle character-based return codes

## 8. Program Error Handling

The program implements a multi-layered error handling strategy:

### 8.1. Input Validation Error Handling

#### 8.1.1. Missing COMMAREA Detection

**Error Type:** Critical input validation failure
**Detection Method:** Checks if EIBCALEN equals zero at program entry
**Error Response:**
1. Populates EM-VARIABLE with ' NO COMMAREA RECEIVED' message
2. Invokes WRITE-ERROR-MESSAGE paragraph to log the error
3. Issues CICS ABEND with code 'LGCA' (no dump generated)
**Severity:** Critical - terminates transaction immediately
**Rationale:** Program cannot proceed without customer data

#### 8.1.2. Insufficient COMMAREA Length

**Error Type:** Data structure validation failure
**Detection Method:** Compares EIBCALEN against calculated minimum required length (header + customer data)
**Error Response:**
1. Sets CA-RETURN-CODE to '98' in the COMMAREA
2. Returns control to calling program via EXEC CICS RETURN
**Severity:** High - prevents processing but allows graceful return
**Recovery:** Calling program must provide correctly sized COMMAREA and retry
**Rationale:** Prevents data corruption from undersized communication area

### 8.2. Return Code Management

#### 8.2.1. Success Indication

**Implementation:** Sets CA-RETURN-CODE to '00' after successful validation
**Timing:** Initialized immediately after COMMAREA existence validation
**Purpose:** Provides default success status that may be overridden by downstream operations

#### 8.2.2. Error Code Propagation

**Mechanism:** LGACDB01 program can update CA-RETURN-CODE in the shared COMMAREA
**Implementation:** COMMAREA passed by reference to LGACDB01 via CICS LINK
**Error Codes:**
- '00': Successful processing
- '98': Insufficient COMMAREA length (set by LGACUS01)
- Other codes: Database operation errors (set by LGACDB01)
**Advantage:** Allows data access layer to communicate specific error conditions

### 8.3. Diagnostic Logging

#### 8.3.1. WRITE-ERROR-MESSAGE Paragraph

**Purpose:** Comprehensive error logging for troubleshooting and audit
**Trigger:** Called explicitly when critical errors occur (e.g., missing COMMAREA)
**Logging Components:**

1. **Timestamp Capture:**
   - Obtains system time via CICS ASKTIME
   - Formats as MMDDYYYY date and standard time format
   - Ensures all error messages have accurate temporal context

2. **Error Message Logging:**
   - Constructs ERROR-MSG with date, time, program name (LGACUS01), and error description
   - Writes to temporary storage queue via LGSTSQ program
   - Fixed 45-byte message format for consistent parsing

3. **Context Data Logging:**
   - Conditionally logs COMMAREA content for debugging
   - Logs up to 90 bytes of COMMAREA data
   - Adapts to actual COMMAREA size (full content if < 91 bytes, first 90 bytes otherwise)
   - Provides snapshot of input data state at error occurrence

**Error Handling for Logging:**
- No explicit error handling for LGSTSQ failures
- Logging errors do not prevent main program flow
- Assumes temporary storage queues are available

### 8.4. Implicit Error Handling

#### 8.4.1. CICS Command Error Handling

**Approach:** No explicit RESP or RESP2 checking on CICS commands
**Implication:** CICS default error handling applies
**Behavior:**
- CICS LINK failures: May cause transaction ABEND
- CICS ASKTIME/FORMATTIME failures: May cause transaction ABEND
- CICS RETURN failures: Unlikely but would cause ABEND

**Design Decision:** Relies on CICS system-level error handling rather than program-level recovery

#### 8.4.2. Database Operation Error Handling

**Delegation:** All database error handling delegated to LGACDB01 program
**Communication:** Errors communicated via CA-RETURN-CODE in COMMAREA
**Advantage:** Separation of concerns - business logic layer doesn't handle DB-specific errors
**Limitation:** LGACUS01 has no visibility into specific database error details

### 8.5. Error Prevention Mechanisms

#### 8.5.1. Working Storage Initialization

**Purpose:** Prevents unpredictable behavior from residual data
**Implementation:** INITIALIZE WS-HEADER at program start
**Benefit:** Ensures clean state for each program invocation

#### 8.5.2. COMMAREA Field Initialization

**Purpose:** Establishes known initial state for output fields
**Implementation:** Sets CA-RETURN-CODE and CA-NUM-POLICIES to '00'
**Timing:** Performed after COMMAREA existence validation
**Benefit:** Provides predictable default values for calling program

### 8.6. Error Recovery Limitations

#### 8.6.1. No Retry Logic

**Observation:** Program does not implement automatic retry for failed operations
**Implication:** Calling program responsible for retry decisions
**Rationale:** Business logic layer should not make retry policy decisions

#### 8.6.2. No Compensating Transactions

**Observation:** No rollback or compensation logic for partial failures
**Implication:** Relies on CICS and DB2 transaction management
**Rationale:** Transaction integrity managed at system level

#### 8.6.3. Limited Error Context

**Observation:** Error messages contain limited contextual information
**Available Context:** Date, time, program name, error description (21 characters max)
**Missing Context:** Customer number, specific field values, transaction details
**Implication:** May require correlation with other logs for complete troubleshooting

## 9. Usage Examples

The following examples demonstrate typical usage scenarios for LGACUS01:

### 9.1. Example 1: Successful Customer Addition

**Scenario:** A presentation layer program calls LGACUS01 to add a new customer with valid data

**Input COMMAREA:**
- EIBCALEN: 500 bytes (sufficient length)
- CA-REQUEST-ID: 'ACUS' (add customer request)
- Customer data fields populated with:
  - Customer number: '0001234567'
  - Customer name: 'JOHN DOE'
  - Customer address: '123 MAIN ST'
  - Customer city: 'NEW YORK'
  - Customer state: 'NY'
  - Customer postcode: '10001'
  - Additional customer fields as defined in LGCMAREA copybook

**Processing Flow:**
1. Program validates COMMAREA exists (EIBCALEN > 0) ✓
2. Program validates COMMAREA length (500 >= minimum required) ✓
3. Program initializes CA-RETURN-CODE to '00'
4. Program calls LGACDB01 via CICS LINK with COMMAREA
5. LGACDB01 inserts customer record into DB2 table
6. LGACDB01 returns with CA-RETURN-CODE = '00' (success)
7. LGACUS01 returns to caller

**Expected Output COMMAREA:**
- CA-RETURN-CODE: '00' (successful processing)
- CA-NUM-POLICIES: '00' (initialized value)
- Customer data: Unchanged from input
- Database: New customer record created in DB2 Customer table

**Result:** Customer successfully added to the system

### 9.2. Example 2: Insufficient COMMAREA Length Error

**Scenario:** Calling program provides undersized COMMAREA

**Input COMMAREA:**
- EIBCALEN: 10 bytes (insufficient - less than minimum required)
- Partial header data only

**Processing Flow:**
1. Program validates COMMAREA exists (EIBCALEN > 0) ✓
2. Program calculates required length: 18 (header) + customer length
3. Program compares: 10 < required length ✗
4. Program sets CA-RETURN-CODE to '98'
5. Program returns immediately to caller without calling LGACDB01

**Expected Output COMMAREA:**
- CA-RETURN-CODE: '98' (insufficient length error)
- CA-NUM-POLICIES: '00' (initialized before error detected)
- Database: No changes made

**Result:** Error returned to caller, no database operation attempted

### 9.3. Example 3: Missing COMMAREA - Critical Error

**Scenario:** Program invoked without COMMAREA

**Input:**
- EIBCALEN: 0 (no COMMAREA passed)
- No COMMAREA structure available

**Processing Flow:**
1. Program checks EIBCALEN = 0 ✗
2. Program populates EM-VARIABLE with ' NO COMMAREA RECEIVED'
3. Program performs WRITE-ERROR-MESSAGE paragraph:
   - Obtains current timestamp (e.g., '06052024' and '143022')
   - Constructs ERROR-MSG: '06052024 143022 LGACUS01 NO COMMAREA RECEIVED'
   - Writes error message to temporary storage queue via LGSTSQ
4. Program issues CICS ABEND with code 'LGCA'

**Expected Output:**
- Transaction terminates with ABEND code 'LGCA'
- Error message logged to temporary storage queue
- No COMMAREA returned (transaction abended)
- Database: No changes made

**Result:** Transaction abnormally terminated, error logged for investigation

### 9.4. Example 4: Database Error During Insert

**Scenario:** Customer addition fails due to database constraint violation (e.g., duplicate customer number)

**Input COMMAREA:**
- EIBCALEN: 500 bytes (sufficient length)
- Customer data with duplicate customer number: '0001234567' (already exists in database)
- All other fields valid

**Processing Flow:**
1. Program validates COMMAREA exists ✓
2. Program validates COMMAREA length ✓
3. Program initializes CA-RETURN-CODE to '00'
4. Program calls LGACDB01 via CICS LINK
5. LGACDB01 attempts DB2 INSERT
6. DB2 returns SQLCODE -803 (duplicate key violation)
7. LGACDB01 sets CA-RETURN-CODE to appropriate error code (e.g., '23')
8. LGACDB01 returns to LGACUS01
9. LGACUS01 returns to caller with updated COMMAREA

**Expected Output COMMAREA:**
- CA-RETURN-CODE: '23' (or other database error code set by LGACDB01)
- CA-NUM-POLICIES: '00'
- Customer data: Unchanged from input
- Database: No changes made (INSERT failed)

**Result:** Error code returned to caller indicating database constraint violation

### 9.5. Example 5: Integration with Presentation Layer

**Scenario:** Complete transaction flow from user interface through LGACUS01

**Transaction Flow:**
1. User enters customer data in CICS screen (via LGTESTC1 or similar presentation program)
2. Presentation program validates and normalizes input data
3. Presentation program constructs COMMAREA with:
   - CA-REQUEST-ID: 'ACUS'
   - Customer data from screen fields
4. Presentation program issues EXEC CICS LINK to LGACUS01 with COMMAREA
5. LGACUS01 validates and processes request (as in Example 1)
6. LGACUS01 returns with CA-RETURN-CODE
7. Presentation program checks CA-RETURN-CODE:
   - '00': Displays success message to user
   - '98': Displays "Invalid data length" error
   - Other codes: Displays appropriate database error message
8. User sees confirmation or error message on screen

**Key Integration Points:**
- COMMAREA structure must match LGCMAREA copybook definition
- Presentation layer responsible for data normalization (uppercase, space-filling)
- Business logic layer (LGACUS01) responsible for validation and orchestration
- Data access layer (LGACDB01) responsible for database operations
- Error codes propagate back through all layers to user interface