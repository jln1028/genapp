# Transaction Entry Points Analysis

## Overview

This document identifies all transaction entry points in the GenApp CICS application, mapping transaction IDs to their corresponding programs and describing their purpose within the system architecture.

## Primary Transaction Entry Points

### Customer Management

#### SSC1 - Customer Menu Transaction
- **Program**: [`LGTESTC1`](../base/src/lgtestc1.cbl)
- **Purpose**: Customer management menu providing inquire, add, and update operations
- **Return Statement**: Line 232 - `EXEC CICS RETURN TRANSID('SSC1') COMMAREA(COMM-AREA)`
- **Operations Supported**:
  - Option 1: Inquire customer details
  - Option 2: Add new customer
  - Option 4: Update existing customer
- **BMS Map**: SSMAPC1 from SSMAP mapset
- **Pseudo-conversational**: Yes - maintains state via COMMAREA

### Policy Management

#### SSP1 - Motor Policy Transaction
- **Program**: [`LGTESTP1`](../base/src/lgtestp1.cbl)
- **Purpose**: Motor vehicle insurance policy management
- **Return Statement**: Line 259 - `EXEC CICS RETURN TRANSID('SSP1') COMMAREA(COMM-AREA)`
- **Operations Supported**:
  - Option 1: Inquire motor policy
  - Option 2: Add motor policy
  - Option 3: Delete motor policy
  - Option 4: Update motor policy
- **BMS Map**: SSMAPP1 from SSMAP mapset
- **Pseudo-conversational**: Yes

#### SSP2 - Endowment/Life Policy Transaction
- **Program**: [`LGTESTP2`](../base/src/lgtestp2.cbl)
- **Purpose**: Life insurance and endowment policy management
- **Return Statement**: Line 241 - `EXEC CICS RETURN TRANSID('SSP2') COMMAREA(COMM-AREA)`
- **Operations Supported**:
  - Option 1: Inquire endowment policy
  - Option 2: Add endowment policy
  - Option 3: Delete endowment policy
  - Option 4: Update endowment policy
- **BMS Map**: SSMAPP2 from SSMAP mapset
- **Pseudo-conversational**: Yes

#### SSP3 - House Policy Transaction
- **Program**: LGTESTP3
- **Purpose**: Property/home insurance policy management
- **Operations Supported**:
  - Option 1: Inquire house policy
  - Option 2: Add house policy
  - Option 3: Delete house policy
  - Option 4: Update house policy
- **BMS Map**: SSMAPP3 from SSMAP mapset
- **Pseudo-conversational**: Yes

#### SSP4 - Commercial Policy Transaction
- **Program**: LGTESTP4
- **Purpose**: Commercial/business insurance policy management
- **Operations Supported**:
  - Option 1: Inquire commercial policy
  - Option 2: Add commercial policy
  - Option 3: Delete commercial policy
  - Option 4: Update commercial policy
- **BMS Map**: SSMAPP4 from SSMAP mapset
- **Pseudo-conversational**: Yes

### System Utilities

#### LGSE - System Setup Transaction
- **Program**: [`LGSETUP`](../base/src/lgsetup.cbl)
- **Purpose**: Initialize system resources including:
  - Delete and recreate temporary storage queues
  - Initialize named counters for customer number generation
  - Initialize transaction counters for statistics
- **Execution**: One-time or periodic initialization
- **Return Statement**: Line 527 - `EXEC CICS RETURN`
- **Pseudo-conversational**: No - single execution

## Transaction Initialization Pattern

All presentation programs follow a consistent pseudo-conversational pattern:

```cobol
MAINLINE SECTION.
    IF EIBCALEN > 0
       GO TO A-GAIN.          /* Resume existing conversation */
    
    Initialize SSMAPC1I.      /* First invocation - cold start */
    Initialize SSMAPC1O.
    Initialize COMM-AREA.
    
    EXEC CICS SEND MAP ('SSMAPC1')
              FROM(SSMAPC1O)
              MAPSET ('SSMAP')
              ERASE
    END-EXEC.

A-GAIN.
    /* Process user input and perform operations */
```

### Key Characteristics

1. **EIBCALEN Check**: Determines if this is a new conversation (EIBCALEN = 0) or continuation (EIBCALEN > 0)
2. **Cold Start**: First invocation initializes data structures and displays initial screen
3. **Warm Start**: Subsequent invocations jump to A-GAIN to process user input
4. **State Preservation**: COMMAREA passed on RETURN maintains conversation state

## Transaction Flow Diagram

```
User Terminal
     │
     ├─ Enter SSC1 ──────────────────────────────────────┐
     │                                                    │
     ▼                                                    ▼
┌─────────────────┐                              ┌──────────────┐
│   LGTESTC1      │◄─────────────────────────────│  CICS Region │
│  (SSC1 Trans)   │                              └──────────────┘
└────────┬────────┘                                      ▲
         │                                               │
         │ EIBCALEN = 0?                                │
         ├─ Yes: Initialize & SEND MAP                  │
         │        RETURN (end transaction)              │
         │                                               │
         └─ No:  GO TO A-GAIN                           │
                 RECEIVE MAP                             │
                 EVALUATE option                         │
                 LINK to business logic                  │
                 SEND MAP with results                   │
                 RETURN TRANSID('SSC1') COMMAREA ────────┘
                 (restart transaction)
```

## Transaction Routing Summary

| Transaction | Program | Menu Options | Business Logic Programs |
|------------|---------|--------------|------------------------|
| SSC1 | LGTESTC1 | 1=Inquire, 2=Add, 4=Update | LGICUS01, LGACUS01, LGUCUS01 |
| SSP1 | LGTESTP1 | 1=Inquire, 2=Add, 3=Delete, 4=Update | LGIPOL01, LGAPOL01, LGDPOL01, LGUPOL01 |
| SSP2 | LGTESTP2 | 1=Inquire, 2=Add, 3=Delete, 4=Update | LGIPOL01, LGAPOL01, LGDPOL01, LGUPOL01 |
| SSP3 | LGTESTP3 | 1=Inquire, 2=Add, 3=Delete, 4=Update | LGIPOL01, LGAPOL01, LGDPOL01, LGUPOL01 |
| SSP4 | LGTESTP4 | 1=Inquire, 2=Add, 3=Delete, 4=Update | LGIPOL01, LGAPOL01, LGDPOL01, LGUPOL01 |
| LGSE | LGSETUP | N/A (Utility) | None |

## Pseudo-Conversational Benefits

1. **Resource Efficiency**: No resources held during user think-time
2. **Scalability**: Supports thousands of concurrent users
3. **Reliability**: Transaction boundaries clearly defined
4. **Recovery**: Each interaction is atomic and recoverable
5. **Performance**: CICS can efficiently manage task switching

## Related Documentation

- [Control Flow Analysis](CONTROL-FLOW-ANALYSIS.md)
- [Transaction Routing Logic](TRANSACTION-ROUTING-LOGIC.md)
- [System Architecture Diagram](SYSTEM-ARCHITECTURE-DIAGRAM.md)
- [Testing Guide](../base/Testing.md)