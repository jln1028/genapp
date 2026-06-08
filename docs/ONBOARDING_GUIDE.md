# GenApp Onboarding Guide

Welcome to the CICS General Insurance Application (GenApp) project! This guide will help you get started quickly, whether you're a new contributor, tester, or someone learning about CICS application modernization.

---

## Quick Start Paths

Choose your path based on your role and goals:

### 🎯 Path 1: I want to understand what GenApp does
**Time**: 15 minutes  
**Prerequisites**: None

1. Read the [main README](../README.md) for project overview
2. Review [`base/Architecture.md`](../base/Architecture.md) to understand the system design
3. Look at the [architecture diagram](../base/images/initial_topology.jpg)
4. Browse [`base/Reference.md`](../base/Reference.md) to see available transactions and programs

### 🛠️ Path 2: I want to install and run GenApp
**Time**: 2-4 hours  
**Prerequisites**: CICS TS V4.1+, Db2, COBOL compiler, z/OS access

1. Review [Prerequisites](#prerequisites) section below
2. Follow [`base/Installation.md`](../base/Installation.md) for your environment
3. Complete [`base/Building.md`](../base/Building.md) to build the application
4. Validate with [`base/Testing.md`](../base/Testing.md)

### 💻 Path 3: I want to modify or extend GenApp
**Time**: 1-2 hours setup + development time  
**Prerequisites**: Path 2 completed, COBOL knowledge, CICS development experience

1. Complete Path 2 (installation)
2. Review [Code Organization](#code-organization) section
3. Study the [three-tier architecture](#application-architecture)
4. Read [Development Guidelines](#development-guidelines)
5. Set up your development environment

### 📊 Path 4: I want to use GenApp for testing/demonstration
**Time**: 3-5 hours  
**Prerequisites**: Path 2 completed, Workload Simulator (optional)

1. Complete Path 2 (installation)
2. Review [`base/wsim/README.md`](../base/wsim/README.md) for workload scripts
3. Explore web services setup in [`base/Reference.md`](../base/Reference.md)
4. Configure optional features (CICSPlex SM, event processing)

---

## Prerequisites

### Required Software

| Component | Minimum Version | Purpose |
|-----------|----------------|---------|
| **CICS TS** | V4.1 | Transaction server platform |
| **IBM Db2** | Any supported version | Database storage |
| **Enterprise COBOL** | V6.x recommended | Program compilation |
| **z/OS** | Compatible with CICS version | Operating system |

### Required Knowledge

**Essential:**
- Basic CICS concepts (transactions, programs, resources)
- z/OS navigation and JCL submission
- TSO/ISPF or USS command line
- Understanding of MVS data sets

**Helpful:**
- COBOL programming
- Db2 SQL
- VSAM file structures
- 3270 terminal operations
- REXX scripting

### Required Access

- z/OS user ID with appropriate permissions
- Authority to:
  - Create and manage MVS data sets
  - Submit batch jobs
  - Access CICS regions
  - Create Db2 databases and tables
  - Allocate VSAM files
- Optional: Access to coupling facility (for advanced features)

---

## Installation Overview

GenApp supports two installation methods:

### Method 1: USS Direct Clone (Recommended)
**Best for**: Modern z/OS environments with Git support

```bash
# Clone repository to USS
git clone https://github.com/cicsdev/cics-genapp.git
cd cics-genapp/base/bin

# Edit install.sh to set your high-level qualifier
vi install.sh

# Run installation
./install.sh
```

**Requirements**: Git client with `zos-working-tree-encoding` support (Rocket Git 2.26.2+)

### Method 2: Workstation + FTP
**Best for**: Traditional mainframe environments

1. Download repository to your workstation
2. Create MVS data sets manually or via FTP
3. Transfer files using FTP (ASCII mode)
4. Follow detailed instructions in each directory's README

See [`base/Installation.md`](../base/Installation.md) for complete details.

---

## Configuration Steps

After installation, customize GenApp for your environment:

### 1. Edit Customization Script

Edit `userid.GENAPP.EXEC(CUST1)` and update these values:

```rexx
PDSMEMin  = 'userid.GENAPP.CNTL'      # Your CNTL library
CICSHLQ   = 'CTS540.CICS710'          # CICS high-level qualifier
USRHLQ    = 'userid'                   # Your user HLQ
COBOLHLQ  = 'PP.COBOL390.V610'        # COBOL compiler HLQ
DB2HLQ    = 'SYS2.DB2.V12'            # Db2 libraries HLQ
DB2SSID   = 'DKM1'                     # Db2 subsystem ID
DB2DBID   = 'GENASA1'                  # Database name
SQLID     = 'userid'                   # Db2 authorization ID
```

### 2. Run Customization

```
EXEC 'userid.GENAPP.EXEC(CUST1)'
```

This creates @ prefixed customized JCL members.

### 3. Build Application

Submit jobs in this order:

1. `@ADEF121` - Create VSAM files
2. `@ASMMAP` - Assemble BMS maps
3. `@CDEF121` - Define CICS resources
4. `@COBOL` - Compile programs
5. `@DB2CRE` - Create Db2 database
6. `@DB2BIND` - Bind to Db2

### 4. Configure CICS Region

Update CICS startup JCL:
```
GRPLIST=(DFHLIST,GENALIST)
DB2CONN=YES
NCPLDFT=GENA
```

Add to DFHRPL: `userid.GENAPP.LOAD`

### 5. Start and Test

1. Start CICS region
2. Run `LGSE` transaction to initialize
3. Run `SSC1` transaction to test customer inquiry
4. Verify Db2 connectivity

---

## Application Architecture

GenApp uses a three-tier architecture:

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (3270 Interface - BMS Maps)                            │
│  LGTESTC1, LGTESTP1-4, SSMAP                           │
└────────────────────┬────────────────────────────────────┘
                     │ EXEC CICS LINK
┌────────────────────▼────────────────────────────────────┐
│                   Business Logic Layer                   │
│  LGACUS01, LGAPOL01, LGICUS01, LGIPOL01                │
│  LGUCUS01, LGUPOL01, LGDPOL01                          │
└────────────────────┬────────────────────────────────────┘
                     │ EXEC CICS LINK
┌────────────────────▼────────────────────────────────────┐
│                 Data Management Layer                    │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │   Db2 Programs   │      │  VSAM Programs   │        │
│  │  LGA*DB01        │      │  LGA*VS01        │        │
│  │  LGI*DB01        │      │  LGI*VS01        │        │
│  │  LGU*DB01        │      │  LGU*VS01        │        │
│  │  LGD*DB01        │      │  LGD*VS01        │        │
│  └────────┬─────────┘      └────────┬─────────┘        │
└───────────┼──────────────────────────┼──────────────────┘
            │                          │
┌───────────▼─────────┐    ┌──────────▼──────────┐
│   Db2 Database      │    │   VSAM Files        │
│   - Customer Table  │    │   - KSDSCUST        │
│   - Policy Tables   │    │   - KSDSPOLY        │
└─────────────────────┘    └─────────────────────┘
```

**Key Design Principles:**
- Separation of concerns (presentation, business, data)
- Two-phase commit for data integrity
- Reusable business logic components
- Modular design for easy extension

---

## Code Organization

### Program Naming Convention

Programs follow a consistent naming pattern:

```
LG [A|I|U|D] [CUS|POL] [01]
│   │         │         │
│   │         │         └─ Sequence number
│   │         └─────────── Entity (Customer/Policy)
│   └───────────────────── Operation (Add/Inquire/Update/Delete)
└───────────────────────── GenApp prefix
```

**Examples:**
- `LGACUS01` = Add Customer, version 01
- `LGIPOL01` = Inquire Policy, version 01
- `LGUCUS01` = Update Customer, version 01

### Data Access Suffix

```
[Program][DB|VS][01]
          │      │
          │      └─ Sequence number
          └──────── Storage type (DB2/VSAM)
```

**Examples:**
- `LGACDB01` = Add Customer to Db2
- `LGACVS01` = Add Customer to VSAM

### Directory Structure

```
base/src/
├── Presentation Programs (LGTESTxx)
├── Business Logic (LGxxxx01)
├── Data Access - Db2 (LGxxDB01)
├── Data Access - VSAM (LGxxVS01)
├── Utilities (LGSETUP, LGSTSQ, etc.)
├── Copybooks (*.cpy)
└── BMS Maps (*.bms)
```

---

## Key Transactions

### User Transactions

| Transaction | Purpose | Menu Type |
|-------------|---------|-----------|
| **LGSE** | Initialize application | Setup |
| **SSC1** | Customer management | Customer menu |
| **SSP1** | Motor insurance policies | Policy menu |
| **SSP2** | Endowment policies | Policy menu |
| **SSP3** | House insurance policies | Policy menu |
| **SSP4** | Commercial property policies | Policy menu |

### Internal Transactions

| Transaction | Purpose |
|-------------|---------|
| **LGCF** | Retrieve random customer from VSAM |
| **LGPF** | Retrieve policy and customer from VSAM |
| **LGST** | Event adapter trigger for counters |
| **SSST** | Initialize dynamic scripting |

### Transaction Operations

Each menu transaction supports these operations:

1. **Inquire** (Option 1): Retrieve existing record
2. **Add** (Option 2): Create new record
3. **Update** (Option 3): Modify existing record
4. **Delete** (Option 4): Remove record

---

## Sample Data

GenApp includes pre-loaded sample data:

### Customers (10 records)
- Customer IDs: 1-10
- Located in: `base/data/ksdscust.txt`

### Policies (10 records)

| Type | Policy # | Customer # | Description |
|------|----------|------------|-------------|
| Motor | 1 | 2 | Motor insurance |
| Motor | 2 | 10 | Motor insurance |
| Motor | 3 | 5 | Motor insurance |
| Endowment | 4 | 8 | Endowment policy |
| Endowment | 5 | 3 | Endowment policy |
| House | 6 | 4 | House insurance |
| House | 7 | 6 | House insurance |
| House | 8 | 9 | House insurance |
| Commercial | 9 | 5 | Commercial property |
| Commercial | 10 | 1 | Commercial property |

Located in: `base/data/ksdspoly.txt`

---

## Development Guidelines

### Making Code Changes

1. **Understand the Layer**: Identify which layer needs modification
   - Presentation: User interface changes
   - Business: Logic and validation changes
   - Data: Storage and retrieval changes

2. **Follow the Pattern**: Use existing programs as templates
   - Copy similar program structure
   - Maintain naming conventions
   - Keep layer separation

3. **Test Thoroughly**:
   - Unit test individual programs
   - Integration test across layers
   - Validate two-phase commit behavior

### Adding New Functionality

**Example: Adding a new policy type**

1. Create data structures (copybook)
2. Create Db2 table
3. Create VSAM file definition
4. Implement data access programs (DB01, VS01)
5. Implement business logic program
6. Create presentation program
7. Define BMS map
8. Create transaction definition
9. Update reference documentation

### Compilation Process

Programs are compiled via the `@COBOL` JCL job:
- Source: `userid.GENAPP.SRC`
- Output: `userid.GENAPP.LOAD`
- Includes: Db2 precompilation, COBOL compilation, link-edit

---

## Testing Your Changes

### Basic Testing

1. **Compile**: Submit `@COBOL` job
2. **Install**: Ensure CICS can access new load module
3. **Test Transaction**: Run transaction from 3270 terminal
4. **Verify Data**: Check Db2 and VSAM for correct updates
5. **Check Logs**: Review CICS logs for errors

### Using Workload Simulator

1. Review scripts in `base/wsim/`
2. Customize for your test scenario
3. Submit `@ITPENTR` job to run workload
4. Analyze results with `@ITPLL`

### Debugging Tips

- Use CEDF (CICS Execution Diagnostic Facility)
- Check temporary storage queue GENAERRS for errors
- Review Db2 logs for SQL issues
- Verify VSAM file status
- Check CICS resource definitions

---

## Common Issues and Solutions

### Issue: COBOL Compilation Fails
**Solution**: 
- Verify COBOL compiler HLQ in CUST1
- Check SYSLIB concatenation includes copybooks
- Ensure Db2 precompiler is accessible

### Issue: Db2 Connection Fails
**Solution**:
- Verify DB2CONN=YES in CICS SIT
- Check DB2CONN resource definition
- Confirm Db2 subsystem is active
- Validate SQLID authorization

### Issue: VSAM File Not Found
**Solution**:
- Verify `@ADEF121` job completed successfully
- Check FILE resource definitions in CICS
- Confirm data set names match CUST1 settings

### Issue: Transaction ABEND
**Solution**:
- Check CICS CSMT log for abend code
- Use CEDF to step through transaction
- Verify all required programs are in DFHRPL
- Check COMMAREA sizes match between programs

### Issue: Named Counter Not Working
**Solution**:
- Verify coupling facility structure exists
- Check named counter server is active (SAMPNCS job)
- Confirm NCPLDFT=GENA in CICS SIT
- Review TSMODEL definition

---

## Advanced Features

### Enabling Web Services

1. Submit web services assistant jobs (`@WSAxx01`)
2. Define PIPELINE resource (GENAPIP1)
3. Define TCPIPSERVICE resource (GENATCP1)
4. Test with SOAP/JSON clients

### Setting Up CICSPlex SM

1. Submit `@CPSMDE2` for definitions
2. Start CMAS with `@SAMPCMA`
3. Start WUI with `@SAMPWUI`
4. Configure workload management

### Enabling Event Processing

1. Import `Transaction_Counters.evbind` in CICS Explorer
2. Define BUNDLE resource (GENAEV01)
3. Enable event processing in CICS
4. Monitor events via dashboard

---

## Getting Help

### Documentation Resources

- **Architecture**: [`base/Architecture.md`](../base/Architecture.md)
- **Installation**: [`base/Installation.md`](../base/Installation.md)
- **Building**: [`base/Building.md`](../base/Building.md)
- **Testing**: [`base/Testing.md`](../base/Testing.md)
- **Reference**: [`base/Reference.md`](../base/Reference.md)
- **Repository Structure**: [`docs/REPOSITORY_STRUCTURE.md`](REPOSITORY_STRUCTURE.md)

### IBM Resources

- [CICS TS Documentation](https://www.ibm.com/docs/en/cics-ts/)
- [CICS Scenarios](https://www.ibm.com/docs/en/cics-ts/5.4?topic=scenarios)
- [CICS Developer Center](https://developer.ibm.com/components/cics/)

### Community

- **GitHub Issues**: Report bugs or request features
- **Maintainers**: See [MAINTAINERS.md](../MAINTAINERS.md)
- **Contributors**: See [Changes.md](../Changes.md)

---

## Next Steps

After completing onboarding:

1. ✅ **Explore the Application**: Run all transactions, test different scenarios
2. ✅ **Review the Code**: Study program structure and patterns
3. ✅ **Try Modifications**: Make small changes to understand the flow
4. ✅ **Enable Advanced Features**: Web services, CICSPlex SM, events
5. ✅ **Contribute**: Share improvements, report issues, help others

---

## Checklist for New Users

- [ ] Read main README and understand project purpose
- [ ] Review architecture documentation
- [ ] Verify all prerequisites are met
- [ ] Choose installation method (USS or FTP)
- [ ] Complete installation steps
- [ ] Customize CUST1 script with environment values
- [ ] Run customization script
- [ ] Submit build jobs in correct order
- [ ] Configure CICS region
- [ ] Start CICS and run LGSE transaction
- [ ] Test with SSC1 transaction
- [ ] Verify Db2 connectivity
- [ ] Explore sample data
- [ ] Review code organization
- [ ] Understand three-tier architecture
- [ ] Try making a simple change
- [ ] Set up development environment

Welcome to GenApp! 🎉