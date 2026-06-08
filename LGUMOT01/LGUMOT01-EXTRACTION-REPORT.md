# LGUMOT01 - Motor Policy Update Service Extraction Report

## Executive Summary

**Service Name:** LGUMOT01  
**Source Program:** LGUPDB01  
**Entry Point:** UPDATE-MOTOR-DB2-INFO (Line 460)  
**Extraction Type:** FOCUSED  
**Extraction Date:** 2026-06-05  

This service extracts the motor policy update logic from LGUPDB01, creating a focused, reusable component for updating motor policy details in the DB2 MOTOR table.

---

## Extraction Goal

Extract the motor policy update logic to create a standalone service that can be called independently to update motor policy details without requiring the full policy update orchestration logic.

---

## Entry Point Rationale

**UPDATE-MOTOR-DB2-INFO** was selected as the entry point because:

1. **Complete Functionality**: Encapsulates the entire motor-specific update logic including field conversions, SQL UPDATE execution, and error handling
2. **Clear Boundaries**: Well-defined input (COMMAREA motor fields) and output (return codes)
3. **Production-Ready**: Includes full error handling infrastructure with SQLCODE evaluation and error logging
4. **Self-Contained**: Minimal dependencies on parent program logic
5. **Reusability**: Can be called independently for motor policy updates

---

## Copybooks Analyzed

The following copybooks were analyzed to ensure accurate data flow:

1. **LGCMAREA** - COMMAREA structure containing:
   - CA-REQUEST-ID (request identifier)
   - CA-RETURN-CODE (return code)
   - CA-CUSTOMER-NUM (customer number)
   - CA-POLICY-NUM (policy number)
   - CA-MOTOR section with motor-specific fields:
     - CA-M-MAKE (vehicle make)
     - CA-M-MODEL (vehicle model)
     - CA-M-VALUE (vehicle value)
     - CA-M-REGNUMBER (registration number)
     - CA-M-COLOUR (vehicle colour)
     - CA-M-CC (engine cubic capacity)
     - CA-M-MANUFACTURED (year of manufacture)
     - CA-M-PREMIUM (insurance premium)
     - CA-M-ACCIDENTS (number of accidents)

2. **LGPOLICY** - DB2 host variables for policy table structures:
   - DB2-MOTOR section matching MOTOR table columns
   - DB2-POLICY section for common policy fields

3. **SQLCA** - SQL Communication Area for DB2 operations

---

## What Was Extracted

### Core Logic

1. **UPDATE-MOTOR-DB2-INFO** (Lines 162-197)
   - Converts COMMAREA numeric fields to DB2 integer formats
   - Executes SQL UPDATE statement on MOTOR table
   - Evaluates SQLCODE for success/failure
   - Sets appropriate return codes
   - Triggers error logging on failures

2. **WRITE-ERROR-MESSAGE** (Lines 204-237)
   - Formats error messages with timestamp, program name, customer/policy numbers, and SQLCODE
   - Links to LGSTSQ program for error logging to TDQ
   - Writes both structured error message and COMMAREA snapshot

### Infrastructure Components

1. **Working-Storage Variables**
   - WS-HEADER: Runtime information (transaction ID, terminal ID, task number)
   - WS-ABSTIME, WS-TIME, WS-DATE: Time/date processing
   - ERROR-MSG: Structured error message format
   - CA-ERROR-MSG: COMMAREA snapshot for error logging
   - DB2-IN-INTEGERS: Host variables for DB2 integer conversions

2. **DB2 Host Variables**
   - DB2-CUSTOMERNUM-INT: Customer number in DB2 INTEGER format
   - DB2-POLICYNUM-INT: Policy number in DB2 INTEGER format
   - DB2-M-VALUE-INT: Motor value in DB2 INTEGER format
   - DB2-M-CC-SINT: Engine CC in DB2 SMALLINT format
   - DB2-M-PREMIUM-INT: Premium in DB2 INTEGER format
   - DB2-M-ACCIDENTS-INT: Accidents count in DB2 INTEGER format

3. **COMMAREA Structure**
   - Full LGCMAREA copybook included in LINKAGE SECTION
   - Provides access to all motor policy fields

4. **SQL Infrastructure**
   - SQLCA for DB2 communication
   - LGPOLICY copybook for DB2 host variable definitions

5. **CICS Infrastructure**
   - COMMAREA validation (EIBCALEN check)
   - ABEND handling for missing COMMAREA
   - CICS RETURN for program termination
   - CICS LINK to LGSTSQ for error logging

---

## Data Flow Analysis

### Backward Data Flow (Inputs)

**From COMMAREA (LGCMAREA copybook):**
- CA-CUSTOMER-NUM → DB2-CUSTOMERNUM-INT (for WHERE clause)
- CA-POLICY-NUM → DB2-POLICYNUM-INT (for WHERE clause)
- CA-M-MAKE → Direct to SQL UPDATE
- CA-M-MODEL → Direct to SQL UPDATE
- CA-M-VALUE → DB2-M-VALUE-INT → SQL UPDATE
- CA-M-REGNUMBER → Direct to SQL UPDATE
- CA-M-COLOUR → Direct to SQL UPDATE
- CA-M-CC → DB2-M-CC-SINT → SQL UPDATE
- CA-M-MANUFACTURED → Direct to SQL UPDATE
- CA-M-PREMIUM → DB2-M-PREMIUM-INT → SQL UPDATE
- CA-M-ACCIDENTS → DB2-M-ACCIDENTS-INT → SQL UPDATE

**From CICS Environment:**
- EIBTRNID → WS-TRANSID (for error messages)
- EIBTRMID → WS-TERMID (for error messages)
- EIBTASKN → WS-TASKNUM (for error messages)
- EIBCALEN → WS-CALEN (for COMMAREA validation)

### Forward Data Flow (Outputs)

**To COMMAREA:**
- CA-RETURN-CODE:
  - '00' = Successful update
  - '01' = Record not found (SQLCODE 100)
  - '90' = SQL error (any other non-zero SQLCODE)

**To DB2 MOTOR Table:**
- All motor policy fields updated via SQL UPDATE statement
- WHERE clause: POLICYNUMBER = :DB2-POLICYNUM-INT

**To Error Logging (via LGSTSQ):**
- ERROR-MSG structure with timestamp, program name, customer/policy numbers, SQLCODE
- CA-ERROR-MSG with COMMAREA snapshot (first 90 bytes)

---

## Dependencies

### Copybooks
- **LGCMAREA** - COMMAREA structure (REQUIRED)
- **LGPOLICY** - DB2 host variables (REQUIRED)
- **SQLCA** - SQL Communication Area (REQUIRED)

### External Programs
- **LGSTSQ** - Error logging program (REQUIRED)
  - Called via CICS LINK
  - Receives ERROR-MSG and CA-ERROR-MSG structures
  - Writes to transient data queue (TDQ)

### DB2 Tables
- **MOTOR** - Motor policy details table (REQUIRED)
  - Columns: MAKE, MODEL, VALUE, REGNUMBER, COLOUR, CC, YEAROFMANUFACTURE, PREMIUM, ACCIDENTS, POLICYNUMBER
  - UPDATE operation with WHERE POLICYNUMBER = :DB2-POLICYNUM-INT

### CICS Resources
- Transient Data Queue (TDQ) - For error logging via LGSTSQ
- COMMAREA - For inter-program communication

---

## What Was NOT Extracted

The following components from LGUPDB01 were intentionally excluded:

1. **Policy Table Operations**
   - POLICY_CURSOR declaration and operations
   - FETCH-DB2-POLICY-ROW procedure
   - Policy table UPDATE logic
   - Timestamp validation logic

2. **Orchestration Logic**
   - UPDATE-POLICY-DB2-INFO procedure
   - Policy type routing (EVALUATE CA-REQUEST-ID)
   - Cursor open/close operations
   - SYNCPOINT ROLLBACK logic

3. **Other Policy Type Updates**
   - UPDATE-ENDOW-DB2-INFO procedure
   - UPDATE-HOUSE-DB2-INFO procedure

4. **VSAM Integration**
   - LGUPVS01 LINK call (Line 209-212 in original)

5. **Additional Host Variables**
   - Variables for Endowment and House policy types
   - BROKERID, PAYMENT, and other common policy fields
   - Indicator variables (IND-BROKERID, IND-BROKERSREF, IND-PAYMENT)

---

## Return Codes

| Code | Meaning | Trigger Condition |
|------|---------|-------------------|
| '00' | Success | SQL UPDATE completed successfully (SQLCODE = 0) |
| '01' | Not Found | No matching record in MOTOR table (SQLCODE = 100) |
| '90' | SQL Error | Any other non-zero SQLCODE from UPDATE statement |

**Note:** The service does NOT return codes '02' (timestamp mismatch) or '99' (invalid request) as these are handled by the parent orchestration logic in LGUPDB01.

---

## Testing Considerations

### Unit Testing

1. **Successful Update Test**
   - Provide valid COMMAREA with existing policy number
   - Verify SQLCODE = 0
   - Verify CA-RETURN-CODE = '00'
   - Verify MOTOR table updated correctly

2. **Record Not Found Test**
   - Provide COMMAREA with non-existent policy number
   - Verify SQLCODE = 100
   - Verify CA-RETURN-CODE = '01'
   - Verify no error logged to TDQ

3. **SQL Error Test**
   - Simulate SQL error (e.g., constraint violation)
   - Verify SQLCODE ≠ 0 and ≠ 100
   - Verify CA-RETURN-CODE = '90'
   - Verify error logged to TDQ via LGSTSQ

4. **Missing COMMAREA Test**
   - Call with EIBCALEN = 0
   - Verify ABEND with code 'LGCA'
   - Verify error logged before ABEND

5. **Field Conversion Test**
   - Verify numeric COMMAREA fields correctly converted to DB2 integer formats
   - Test boundary values (max/min for SMALLINT and INTEGER)

### Integration Testing

1. **LGSTSQ Integration**
   - Verify error messages written to TDQ
   - Verify message format includes timestamp, program name, SQLCODE
   - Verify COMMAREA snapshot captured correctly

2. **DB2 Integration**
   - Verify SQL UPDATE statement syntax
   - Verify WHERE clause uses correct policy number
   - Verify all motor fields updated correctly
   - Test with DB2 unavailable (SQLCODE -913)

3. **CICS Integration**
   - Verify CICS RETURN works correctly
   - Verify CICS LINK to LGSTSQ succeeds
   - Verify COMMAREA passed correctly

### Performance Testing

1. **Response Time**
   - Measure execution time for typical update
   - Compare with original LGUPDB01 performance

2. **Concurrency**
   - Test multiple concurrent updates to different policies
   - Verify no locking issues

---

## Integration Guidance

### Calling LGUMOT01 from Other Programs

**Prerequisites:**
1. Populate COMMAREA with motor policy data (LGCMAREA structure)
2. Set CA-CUSTOMER-NUM and CA-POLICY-NUM
3. Set all CA-M-* fields with motor policy details

**Example CICS LINK:**
```cobol
EXEC CICS LINK PROGRAM('LGUMOT01')
     COMMAREA(DFHCOMMAREA)
     LENGTH(LENGTH OF DFHCOMMAREA)
END-EXEC
```

**After LINK:**
1. Check CA-RETURN-CODE:
   - '00' = Success, proceed
   - '01' = Record not found, handle appropriately
   - '90' = SQL error, check error logs

### Modifying LGUPDB01 to Use LGUMOT01

**Option 1: Replace Inline Logic**

Replace the UPDATE-MOTOR-DB2-INFO procedure call (Line 298) with:

```cobol
      WHEN '01UMOT'
*        Call extracted motor update service
         EXEC CICS LINK PROGRAM('LGUMOT01')
              COMMAREA(DFHCOMMAREA)
              LENGTH(LENGTH OF DFHCOMMAREA)
         END-EXEC
```

**Option 2: Keep Both (Transition Period)**

Keep original logic but add conditional routing:

```cobol
      WHEN '01UMOT'
         IF USE-NEW-MOTOR-SERVICE
*          Call extracted motor update service
           EXEC CICS LINK PROGRAM('LGUMOT01')
                COMMAREA(DFHCOMMAREA)
                LENGTH(LENGTH OF DFHCOMMAREA)
           END-EXEC
         ELSE
*          Call original routine
           PERFORM UPDATE-MOTOR-DB2-INFO
         END-IF
```

### Considerations for Integration

1. **Transaction Scope**
   - LGUMOT01 does NOT issue SYNCPOINT or SYNCPOINT ROLLBACK
   - Transaction control remains with calling program
   - Ensure calling program handles commit/rollback appropriately

2. **Error Handling**
   - LGUMOT01 logs errors to TDQ via LGSTSQ
   - Calling program should check CA-RETURN-CODE after LINK
   - Consider additional error handling in calling program

3. **Performance**
   - CICS LINK adds overhead vs. PERFORM
   - Measure performance impact in production-like environment
   - Consider caching or connection pooling if needed

4. **Deployment**
   - Compile LGUMOT01 with DB2 precompiler
   - Define LGUMOT01 in CICS CSD
   - Ensure LGSTSQ is available
   - Test in development environment first

---

## Deployment Checklist

### Pre-Deployment

- [ ] Review extracted code for completeness
- [ ] Verify all copybooks are available (LGCMAREA, LGPOLICY, SQLCA)
- [ ] Confirm LGSTSQ program is available and working
- [ ] Verify DB2 MOTOR table structure matches expectations
- [ ] Review and approve return code handling

### Compilation

- [ ] Run DB2 precompiler on LGUMOT01.cbl
- [ ] Compile COBOL source with CICS translator
- [ ] Link-edit with CICS and DB2 libraries
- [ ] Verify no compilation errors or warnings

### CICS Definition

- [ ] Define LGUMOT01 program in CICS CSD
- [ ] Set appropriate transaction class
- [ ] Configure program attributes (language=COBOL, reload=NO, etc.)
- [ ] Install program definition in CICS region

### Testing

- [ ] Execute unit tests (see Testing Considerations section)
- [ ] Execute integration tests with LGSTSQ
- [ ] Execute integration tests with DB2 MOTOR table
- [ ] Verify error logging to TDQ
- [ ] Test COMMAREA validation and ABEND handling
- [ ] Performance test under load

### Deployment

- [ ] Deploy to development environment
- [ ] Execute smoke tests
- [ ] Deploy to test environment
- [ ] Execute full regression tests
- [ ] Deploy to production environment
- [ ] Monitor initial production usage
- [ ] Verify error logs for any issues

### Post-Deployment

- [ ] Monitor performance metrics
- [ ] Review error logs for any unexpected issues
- [ ] Gather feedback from operations team
- [ ] Document any issues or lessons learned
- [ ] Update runbook with operational procedures

---

## Maintenance Notes

### Future Enhancements

1. **Enhanced Error Handling**
   - Add more granular SQLCODE handling
   - Implement retry logic for transient errors
   - Add detailed error messages for specific SQL errors

2. **Validation**
   - Add input validation for motor fields
   - Validate numeric ranges (e.g., CC, VALUE, PREMIUM)
   - Validate date formats (YEAROFMANUFACTURE)

3. **Logging**
   - Add audit trail for successful updates
   - Log before/after values for compliance
   - Add performance metrics logging

4. **Optimization**
   - Consider prepared statements for better performance
   - Optimize field conversions
   - Review and optimize error message formatting

### Known Limitations

1. **No Timestamp Validation**
   - Service does not validate policy timestamp
   - Calling program must handle optimistic locking

2. **No Transaction Control**
   - Service does not issue SYNCPOINT/ROLLBACK
   - Calling program responsible for transaction boundaries

3. **Limited Return Codes**
   - Only three return codes ('00', '01', '90')
   - May need more granular codes for specific errors

4. **No Input Validation**
   - Service assumes valid input from calling program
   - Consider adding validation in future versions

---

## Contact Information

For questions or issues related to this extracted service:

- **Source Program:** LGUPDB01
- **Extraction Date:** 2026-06-05
- **Service Name:** LGUMOT01
- **Documentation:** This file (LGUMOT01-EXTRACTION-REPORT.md)

---

## Appendix: SQL Statement

### MOTOR Table UPDATE Statement

```sql
UPDATE MOTOR
  SET
       MAKE              = :CA-M-MAKE,
       MODEL             = :CA-M-MODEL,
       VALUE             = :DB2-M-VALUE-INT,
       REGNUMBER         = :CA-M-REGNUMBER,
       COLOUR            = :CA-M-COLOUR,
       CC                = :DB2-M-CC-SINT,
       YEAROFMANUFACTURE = :CA-M-MANUFACTURED,
       PREMIUM           = :DB2-M-PREMIUM-INT,
       ACCIDENTS         = :DB2-M-ACCIDENTS-INT
  WHERE
       POLICYNUMBER      = :DB2-POLICYNUM-INT
```

**Host Variables:**
- `:CA-M-MAKE` - VARCHAR from COMMAREA
- `:CA-M-MODEL` - VARCHAR from COMMAREA
- `:DB2-M-VALUE-INT` - INTEGER converted from CA-M-VALUE
- `:CA-M-REGNUMBER` - VARCHAR from COMMAREA
- `:CA-M-COLOUR` - VARCHAR from COMMAREA
- `:DB2-M-CC-SINT` - SMALLINT converted from CA-M-CC
- `:CA-M-MANUFACTURED` - VARCHAR from COMMAREA
- `:DB2-M-PREMIUM-INT` - INTEGER converted from CA-M-PREMIUM
- `:DB2-M-ACCIDENTS-INT` - INTEGER converted from CA-M-ACCIDENTS
- `:DB2-POLICYNUM-INT` - INTEGER converted from CA-POLICY-NUM

---

*End of Extraction Report*