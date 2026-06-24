# MOTUPD01 - Motor Policy Update Service Extraction Report

## Extraction Overview

**Source Program**: LGUPDB01.cbl  
**Service Name**: MOTUPD01.cbl  
**Entry Point**: UPDATE-MOTOR-DB2-INFO (Line 460)  
**Extraction Type**: FOCUSED  
**Extraction Goal**: Motor policy update logic including premium handling  
**Date**: 2026-06-18

## Extraction Rationale

The UPDATE-MOTOR-DB2-INFO procedure was selected as the optimal extraction candidate because:

1. **Complete Business Logic**: Contains the full motor policy update workflow including premium handling
2. **Self-Contained**: Performs a single, well-defined responsibility (motor policy updates)
3. **Production-Ready Infrastructure**: Includes error handling, SQLCODE checking, and return code management
4. **Clear Data Flow**: Explicit input (COMMAREA motor fields) and output (return codes)
5. **Minimal Dependencies**: Only requires LGSTSQ for error logging

This extraction provides a reusable service for motor policy updates that can be called independently from the original multi-policy update orchestrator.

## Copybooks Analyzed

The following application copybooks were analyzed to ensure accurate data flow:

- **LGPOLICY** (base/src/lgpolicy.cpy) - DB2 host variable structures for policy data
  - DB2-MOTOR structure (lines 72-81) with premium field at line 80
- **LGCMAREA** (base/src/lgcmarea.cpy) - COMMAREA structure with motor policy fields
  - CA-MOTOR structure (lines 65-75) with premium field at line 73
- **SQLCA** - SQL Communication Area (standard system copybook)

## What Was Extracted

### Core Logic

1. **UPDATE-MOTOR-DB2-INFO** (Lines 157-192)
   - Data type conversions: CA-M-PREMIUM (PIC 9(6)) → DB2-M-PREMIUM-INT (PIC S9(9) COMP)
   - SQL UPDATE statement for MOTOR table with all 9 fields including PREMIUM
   - SQLCODE error handling (100=not found, other=SQL error)
   - Return code management ('00'=success, '01'=not found, '90'=error)

2. **WRITE-ERROR-MESSAGE** (Lines 199-232)
   - SQLCODE capture and formatting
   - CICS ASKTIME and FORMATTIME for timestamp generation
   - CICS LINK to LGSTSQ for TDQ error logging
   - COMMAREA diagnostic dump (first 90 bytes)

### Infrastructure Components

**WORKING-STORAGE SECTION**:
- WS-HEADER - Runtime debug information (eyecatcher, transaction ID, terminal ID, task number)
- WS-ABSTIME, WS-TIME, WS-DATE - Time/date processing variables
- ERROR-MSG - Structured error message with customer/policy numbers and SQLCODE
- CA-ERROR-MSG - COMMAREA diagnostic dump structure
- DB2-IN-INTEGERS - Motor-specific DB2 integer host variables (5 fields)

**SQL INCLUDES**:
- LGPOLICY - Provides DB2-MOTOR structure
- SQLCA - SQL Communication Area for SQLCODE
- LGCMAREA - COMMAREA structure with CA-MOTOR fields

**LINKAGE SECTION**:
- DFHCOMMAREA - Full COMMAREA structure via LGCMAREA include

**CICS EIB Fields Used**:
- EIBTRNID, EIBTRMID, EIBTASKN - Transaction context
- EIBCALEN - COMMAREA length validation

## Data Flow Analysis

### Input (from COMMAREA)

**Motor Policy Fields**:
- CA-M-MAKE (PIC X(15)) - Vehicle make
- CA-M-MODEL (PIC X(15)) - Vehicle model
- CA-M-VALUE (PIC 9(6)) - Vehicle value → converted to DB2-M-VALUE-INT
- CA-M-REGNUMBER (PIC X(7)) - Registration number
- CA-M-COLOUR (PIC X(8)) - Vehicle color
- CA-M-CC (PIC 9(4)) - Engine CC → converted to DB2-M-CC-SINT
- CA-M-MANUFACTURED (PIC X(10)) - Year of manufacture
- **CA-M-PREMIUM (PIC 9(6))** - Insurance premium → converted to DB2-M-PREMIUM-INT
- CA-M-ACCIDENTS (PIC 9(6)) - Accident count → converted to DB2-M-ACCIDENTS-INT

**Key Fields**:
- CA-POLICY-NUM (PIC 9(10)) - Policy number for WHERE clause
- CA-CUSTOMER-NUM (PIC 9(10)) - Customer number for error logging

### Output (to COMMAREA)

**CA-RETURN-CODE** (PIC 9(2)):
- '00' = Successful update
- '01' = Policy not found (SQLCODE 100)
- '90' = SQL error (any other non-zero SQLCODE)

### Backward Data Flow (Dependencies)

**From COMMAREA**:
- All CA-M-* motor fields flow into SQL UPDATE statement
- CA-POLICY-NUM used in WHERE clause
- CA-CUSTOMER-NUM and CA-POLICY-NUM used in error messages

**From CICS EIB**:
- EIBTRNID, EIBTRMID, EIBTASKN → WS-HEADER for diagnostics
- EIBCALEN → validation and COMMAREA dump sizing

### Forward Data Flow (Impacts)

**To DB2 MOTOR Table**:
- All 9 motor fields updated via SQL UPDATE WHERE POLICYNUMBER = :DB2-POLICYNUM-INT
- Premium value flows: CA-M-PREMIUM → DB2-M-PREMIUM-INT → MOTOR.PREMIUM column

**To TDQ (via LGSTSQ)**:
- ERROR-MSG structure with timestamp, program name, customer/policy numbers, SQLCODE
- CA-ERROR-MSG with first 90 bytes of COMMAREA for diagnostics

**To Caller**:
- CA-RETURN-CODE indicates success/failure
- Original COMMAREA preserved (no modifications except return code)

## Dependencies

### Copybooks
- **LGPOLICY** - Required for DB2-MOTOR structure
- **LGCMAREA** - Required for CA-MOTOR fields and CA-RETURN-CODE
- **SQLCA** - Required for SQLCODE

### External Programs
- **LGSTSQ** - Error logging service (CICS LINK)
  - Called with ERROR-MSG (length of ERROR-MSG)
  - Called with CA-ERROR-MSG (length of CA-ERROR-MSG)

### DB2 Tables
- **MOTOR** - UPDATE operation
  - Columns: MAKE, MODEL, VALUE, REGNUMBER, COLOUR, CC, YEAROFMANUFACTURE, PREMIUM, ACCIDENTS
  - WHERE clause: POLICYNUMBER = :DB2-POLICYNUM-INT

### File I/O
- None (all I/O is via DB2 and CICS services)

## What Was NOT Extracted

The following components from LGUPDB01 were intentionally excluded:

1. **Policy Table Operations**:
   - POLICY_CURSOR declaration and operations (OPEN, FETCH, CLOSE)
   - Timestamp validation logic (CA-LASTCHANGED vs DB2-LASTCHANGED)
   - Policy table UPDATE with broker and payment fields
   - CLOSE-PCURSOR procedure

2. **Other Policy Type Updates**:
   - UPDATE-ENDOW-DB2-INFO (endowment policies)
   - UPDATE-HOUSE-DB2-INFO (house policies)
   - FETCH-DB2-POLICY-ROW procedure

3. **Policy Type Routing**:
   - EVALUATE CA-REQUEST-ID logic
   - Multi-policy orchestration in UPDATE-POLICY-DB2-INFO

4. **VSAM Integration**:
   - CICS LINK to LGUPVS01 for VSAM updates
   - Two-phase commit coordination

5. **Unused Host Variables**:
   - DB2-CUSTOMERNUM-INT (not needed for motor-only service)
   - DB2-BROKERID-INT, DB2-PAYMENT-INT (policy table fields)
   - DB2-E-* (endowment fields)
   - DB2-H-* (house fields)

6. **Unused Working Storage**:
   - WS-COMMAREA-LENGTHS
   - WS-VARY-FIELD (VARCHAR handling)
   - Indicator variables (IND-BROKERID, IND-BROKERSREF, IND-PAYMENT)

## Return Codes

| Code | Meaning | Trigger Condition |
|------|---------|-------------------|
| '00' | Success | SQLCODE = 0 after UPDATE |
| '01' | Not Found | SQLCODE = 100 (no rows updated) |
| '90' | SQL Error | Any other non-zero SQLCODE |

**Note**: The original LGUPDB01 also uses '02' (timestamp mismatch) and '99' (invalid request), but these are not applicable to this focused motor update service.

## Testing Considerations

### Unit Testing

1. **Successful Update**:
   - Provide valid motor policy data with existing POLICYNUMBER
   - Verify SQLCODE = 0 and CA-RETURN-CODE = '00'
   - Confirm MOTOR table updated with new premium value

2. **Policy Not Found**:
   - Provide non-existent POLICYNUMBER
   - Verify SQLCODE = 100 and CA-RETURN-CODE = '01'
   - Confirm no error messages logged

3. **SQL Error Handling**:
   - Simulate DB2 error (e.g., connection failure)
   - Verify CA-RETURN-CODE = '90'
   - Confirm error logged to TDQ via LGSTSQ

4. **Data Type Conversions**:
   - Test premium values: 0, 999999 (max PIC 9(6))
   - Verify correct conversion to DB2 INTEGER format
   - Test CC values: 0, 9999 (max PIC 9(4))

5. **COMMAREA Validation**:
   - Test with EIBCALEN = 0 (should ABEND with 'LGCA')
   - Test with valid COMMAREA length
   - Verify WS-ADDR-DFHCOMMAREA set correctly

### Integration Testing

1. **With LGSTSQ**:
   - Verify error messages written to TDQ
   - Confirm timestamp formatting (MMDDYYYY and TIME)
   - Check COMMAREA dump (first 90 bytes)

2. **With DB2**:
   - Test within CICS transaction
   - Verify SQL precompiler processes EXEC SQL statements
   - Confirm SQLCA populated correctly

3. **COMMAREA Contract**:
   - Test with various motor policy data combinations
   - Verify CA-RETURN-CODE set correctly
   - Confirm original COMMAREA preserved (except return code)

### Performance Testing

1. **Response Time**:
   - Measure single UPDATE execution time
   - Compare with original LGUPDB01 (should be faster without cursor overhead)

2. **Concurrency**:
   - Test multiple simultaneous updates to different policies
   - Verify no locking issues (no cursor = no row locks held)

## Integration Guidance

### Calling MOTUPD01 from Original Program

To integrate MOTUPD01 into LGUPDB01, replace the PERFORM UPDATE-MOTOR-DB2-INFO at line 298 with:

```cobol
      *** Motor ***
               WHEN '01UMOT'
      *          Call motor update service
                 EXEC CICS LINK PROGRAM('MOTUPD01')
                      COMMAREA(DFHCOMMAREA)
                      LENGTH(EIBCALEN)
                 END-EXEC
```

**Important**: Remove the original UPDATE-MOTOR-DB2-INFO procedure (lines 460-495) to avoid duplication.

### Calling MOTUPD01 from New Programs

```cobol
      * Set up COMMAREA with motor policy data
           MOVE '01UMOT'        TO CA-REQUEST-ID
           MOVE customer-number TO CA-CUSTOMER-NUM
           MOVE policy-number   TO CA-POLICY-NUM
           MOVE motor-data      TO CA-MOTOR
      
      * Call motor update service
           EXEC CICS LINK PROGRAM('MOTUPD01')
                COMMAREA(DFHCOMMAREA)
                LENGTH(LENGTH OF DFHCOMMAREA)
           END-EXEC
      
      * Check result
           EVALUATE CA-RETURN-CODE
             WHEN '00'
               DISPLAY 'Motor policy updated successfully'
             WHEN '01'
               DISPLAY 'Motor policy not found'
             WHEN '90'
               DISPLAY 'SQL error during update'
           END-EVALUATE
```

### COMMAREA Requirements

**Minimum COMMAREA Length**: 82 bytes (header + policy common + motor fields through accidents)

**Required Fields**:
- CA-POLICY-NUM (offset 10, length 10)
- CA-M-MAKE through CA-M-ACCIDENTS (offset 72, length 77)

**Optional Fields**:
- CA-CUSTOMER-NUM (for error logging only)

## Deployment Checklist

- [ ] Compile MOTUPD01.cbl with SQL precompiler (PROCESS SQL)
- [ ] Bind DB2 package for MOTUPD01
- [ ] Define CICS program resource (MOTUPD01)
- [ ] Verify LGSTSQ program available in CICS region
- [ ] Verify LGPOLICY, LGCMAREA, SQLCA copybooks in SYSLIB
- [ ] Test with sample motor policy data
- [ ] Verify TDQ error logging works
- [ ] Update LGUPDB01 to call MOTUPD01 (if replacing inline logic)
- [ ] Update program documentation and call graphs
- [ ] Add MOTUPD01 to build/deployment scripts

## Premium Handling Details

The premium field is central to this service extraction. Here's the complete flow:

1. **Input**: CA-M-PREMIUM (PIC 9(6)) - Numeric field in COMMAREA
   - Example: 123456 represents $1,234.56 or 123456 units depending on business rules

2. **Conversion**: MOVE CA-M-PREMIUM TO DB2-M-PREMIUM-INT (Line 162)
   - Source: PIC 9(6) - 6-digit unsigned numeric
   - Target: PIC S9(9) COMP - 4-byte signed binary integer
   - Conversion is automatic and safe (no precision loss)

3. **SQL UPDATE**: PREMIUM = :DB2-M-PREMIUM-INT (Line 176)
   - DB2 column type: INTEGER (4-byte signed integer)
   - Host variable: DB2-M-PREMIUM-INT matches DB2 type exactly

4. **Validation**: None performed in this service
   - Assumes caller has validated premium value
   - DB2 will reject if value exceeds INTEGER range (±2,147,483,647)

**Business Rule Considerations**:
- Premium calculation logic is NOT in this service
- This service only persists the premium value provided by caller
- Premium validation (min/max, business rules) should be in calling program

## Architecture Notes

This extraction follows the **Single Responsibility Principle**:
- Original LGUPDB01: Multi-policy orchestrator with cursor management
- New MOTUPD01: Focused motor policy update service

**Benefits**:
1. **Reusability**: Can be called from any program needing motor updates
2. **Simplicity**: No cursor overhead, direct UPDATE statement
3. **Testability**: Isolated logic easier to unit test
4. **Maintainability**: Changes to motor update logic centralized

**Trade-offs**:
1. **No Timestamp Validation**: Caller must handle optimistic locking if needed
2. **No Policy Table Update**: Caller must update POLICY table separately
3. **No VSAM Coordination**: Caller must handle two-phase commit if needed

This is appropriate for scenarios where:
- Motor policy updates are independent of policy table updates
- Timestamp validation is handled at a higher level
- VSAM synchronization is not required or handled separately