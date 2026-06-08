# CICS GenApp Repository Structure Analysis

## Executive Summary

This repository contains the **General Insurance Application (GenApp)** for IBM CICS Transaction Server for z/OS - a demonstration application originally distributed as IBM SupportPac CB12. The project showcases application modernization techniques for mainframe CICS applications, providing a working COBOL-based insurance system that exercises various CICS TS components.

**Primary Purpose**: Demonstrate how legacy 3270 "green screen" applications can be transformed to leverage modern CICS features including web services, workload management, event processing, and cloud enablement.

**Target Audience**: Intermediate to advanced CICS developers and system administrators with knowledge of z/OS, CICS configuration, and mainframe application development.

---

## Repository Structure Overview

```
cics-genapp/
├── base/                          # Core GenApp application
│   ├── Architecture.md            # Application architecture documentation
│   ├── Building.md                # Build instructions
│   ├── Installation.md            # Installation guide
│   ├── Reference.md               # Complete reference guide
│   ├── Testing.md                 # Testing procedures
│   ├── bin/                       # Installation scripts
│   ├── cntl/                      # JCL jobs for setup and configuration
│   ├── data/                      # Sample data files
│   ├── event-bindings/            # CICS event binding definitions
│   ├── exec/                      # REXX customization scripts
│   ├── images/                    # Architecture diagrams
│   ├── src/                       # COBOL source code and copybooks
│   └── wsim/                      # Workload Simulator scripts
├── Changes.md                     # Change history and contributors
├── LICENSE                        # Eclipse Public License 2.0
├── MAINTAINERS.md                 # Current maintainers
└── README.md                      # Main repository documentation
```

---

## Detailed Component Analysis

### 1. Core Application (`base/`)

The base directory contains the complete working application with all necessary components for deployment.

#### 1.1 Documentation Files

| File | Purpose | Key Content |
|------|---------|-------------|
| **Architecture.md** | System design overview | Component interactions, data flow, topology diagrams, technology stack |
| **Installation.md** | Setup procedures | USS and workstation installation paths, customization steps, prerequisites |
| **Building.md** | Build process | JCL job execution order, VSAM setup, Db2 configuration, optional components |
| **Testing.md** | Validation procedures | Transaction testing, data verification, troubleshooting |
| **Reference.md** | Complete reference | All transactions, programs, resources, sample data catalog |

#### 1.2 Installation Scripts (`bin/`)

- **install.sh**: Automated installation script for USS environments
  - Allocates MVS data sets
  - Copies files from USS to traditional data sets
  - Requires Git client with zos-working-tree-encoding support

#### 1.3 JCL Jobs (`cntl/`)

Contains 29 JCL members for building and configuring the application:

**Core Setup Jobs:**
- `ADEF121`: Create and populate VSAM files (KSDSCUST, KSDSPOLY)
- `ASMMAP`: Assemble BMS maps for 3270 interface
- `CDEF121`: Define CICS resources for single region
- `COBOL`: Compile all COBOL programs
- `DB2CRE`: Create Db2 database, tables, and indexes
- `DB2BIND`: Bind application to Db2 objects
- `DB2DEL`: Delete Db2 database (for rebuilds)

**Optional Components:**
- `SAMPNCS`: Start named counter server
- `SAMPTSQ`: Start temporary storage queue server
- `SAMPCMA`: Start CMAS (CICSPlex SM)
- `SAMPWUI`: Start CICSPlex SM Web User Interface

**Advanced Configuration:**
- `CDEF122-125`: Additional resource definitions for topology, workload management, web services
- `CPSMDE2`: CICSPlex SM definitions
- `WSAAC01-WSAVP01`: Web services assistant jobs

**Workload Simulator:**
- `ITPENTR`: Create customer and policy records
- `ITPLL`: Format log files
- `ITPSTL`: Translate programs into scripts

#### 1.4 Sample Data (`data/`)

- **ksdscust.txt**: Customer records (RECFM=FB, LRECL=225)
  - 10 sample customers with details
- **ksdspoly.txt**: Policy records (RECFM=FB, LRECL=64)
  - 10 sample policies across 4 types (Motor, Endowment, House, Commercial)

#### 1.5 REXX Scripts (`exec/`)

- **cust1.rexx**: Main customization script
  - Personalizes JCL with environment-specific values
  - Configures data set names, CICS/Db2 parameters
  - Creates @ prefixed customized members
- **mac1.rexx**: Macro support script

#### 1.6 Source Code (`src/`)

**Program Organization** (46 files total):

**Presentation Layer (3270 Interface):**
- `LGTESTC1`: Customer menu presentation logic
- `LGTESTP1-4`: Policy menu presentation (Motor, Endowment, House, Commercial)
- `SSMAP`: BMS map for screen layout

**Business Logic Layer:**
- `LGACUS01`: Add customer business logic
- `LGAPOL01`: Add policy business logic
- `LGICUS01`: Inquire customer business logic
- `LGIPOL01`: Inquire policy business logic
- `LGUCUS01`: Update customer business logic
- `LGUPOL01`: Update policy business logic
- `LGDPOL01`: Delete policy business logic

**Data Management Layer:**

*Db2 Operations:*
- `LGACDB01-02`: Add customer to Db2
- `LGAPDB01`: Add policy to Db2
- `LGICDB01`: Retrieve customer from Db2
- `LGIPDB01`: Retrieve policy from Db2
- `LGUCDB01`: Update customer in Db2
- `LGUPDB01`: Update policy in Db2
- `LGDPDB01`: Delete policy from Db2

*VSAM Operations:*
- `LGACVS01`: Add customer to VSAM
- `LGAPVS01`: Add policy to VSAM
- `LGICVS01`: Retrieve customer from VSAM
- `LGIPVS01`: Retrieve policy from VSAM
- `LGUCVS01`: Update customer in VSAM
- `LGUPVS01`: Update policy in VSAM
- `LGDPVS01`: Delete policy from VSAM

**Utility Programs:**
- `LGSETUP`: Initialize counters and temporary storage queues
- `LGSTSQ`: Write messages to temporary storage queue
- `LGASTAT1`: Update transaction counts using named counters
- `LGWEBST5`: Copy transaction counts to temporary storage

**Copybooks (13 files):**
- `LGCMAREA`: Communication area structure
- `LGPOLICY`: Policy data structure
- `POLLOOK`, `POLLOO2`: Policy lookup structures
- `SOAIC01`, `SOAIPB1`, `SOAIPE1`, `SOAIPH1`, `SOAIPM1`: SOA interface definitions
- `SOAVCII`, `SOAVCIO`, `SOAVPII`, `SOAVPIO`: VSAM interface structures

**Other:**
- `LINKPARM.TXT`: Link editor parameters

#### 1.7 Workload Simulator Scripts (`wsim/`)

39 script files for IBM Workload Simulator for z/OS:

**Configuration Files:**
- `GENAPP`: Main workload definition
- `ONCICS`: CICS connection parameters
- `#SSVARS`: System variables

**Transaction Scripts:**
- `SSC1A1-A2`: Customer add transactions
- `SSC1I1`: Customer inquiry
- `SSP1A1-A2, SSP1D1, SSP1I1, SSP1U1`: Motor policy operations
- `SSP2A1-A2, SSP2D1, SSP2I1, SSP2U1`: Endowment policy operations
- `SSP3A1-A2, SSP3D1, SSP3I1, SSP3U1`: House policy operations
- `SSP4A1, SSP4D1, SSP4I1`: Commercial property operations
- `WSC1A1, WSC1I1`: Web service customer operations
- `WSLGCF`: Customer file operations

**Data Files:**
- `CCOLOR`, `CMAKE`, `CMODEL`, `CTYPE`: Customer data
- `FNAME`, `SNAME`: Name data
- `HTYPE`, `PCODE`, `PTYPE`, `RTYPE`: Policy data
- `STOP`, `WASERROR`: Control files

#### 1.8 Event Bindings (`event-bindings/`)

- **Transaction_Counters.evbind**: CICS event binding definition
  - Imported into CICS Explorer (not transferred to z/OS)
  - Enables transaction monitoring and event processing

#### 1.9 Images (`images/`)

- **initial_topology.jpg**: Architecture diagram showing initial CICS configuration

---

## Logical Groupings by Functionality

### Installation & Setup
- `base/Installation.md`
- `base/bin/install.sh`
- `base/exec/cust1.rexx`, `mac1.rexx`
- `base/cntl/README.md` and all JCL jobs

### Application Architecture & Design
- `base/Architecture.md`
- `base/images/initial_topology.jpg`
- `base/Reference.md`

### Build & Deployment
- `base/Building.md`
- `base/cntl/ADEF121`, `ASMMAP`, `CDEF121`, `COBOL`, `DB2CRE`, `DB2BIND`

### Testing & Validation
- `base/Testing.md`
- `base/data/` (sample data)
- `base/wsim/` (workload scripts)

### Source Code by Layer
- **Presentation**: `LGTESTC1`, `LGTESTP1-4`, `SSMAP`
- **Business Logic**: `LGACUS01`, `LGAPOL01`, `LGICUS01`, `LGIPOL01`, `LGUCUS01`, `LGUPOL01`, `LGDPOL01`
- **Data Access**: All `LGA*DB01`, `LGA*VS01`, `LGI*DB01`, `LGI*VS01`, `LGU*DB01`, `LGU*VS01`, `LGD*DB01`, `LGD*VS01` programs

### Advanced Features
- **Web Services**: `base/cntl/WSAAC01-WSAVP01`
- **CICSPlex SM**: `base/cntl/SAMPCMA`, `SAMPWUI`, `CPSMDE2`
- **Event Processing**: `base/event-bindings/`
- **Workload Management**: `base/cntl/CDEF123`

---

## Technology Stack

### Core Technologies
- **Language**: Enterprise COBOL (V6.x compatible)
- **Transaction Server**: IBM CICS TS V4.1 or later
- **Database**: IBM Db2 for z/OS
- **File System**: VSAM KSDS (Key-Sequenced Data Sets)
- **Interface**: 3270 terminal (BMS maps)

### Optional Components
- **Coupling Facility**: Named counter server, shared temporary storage queues
- **CICSPlex SM**: Workload management, topology management
- **Web Services**: SOAP and JSON support (CICS TS V5.2+)
- **Workload Simulator**: IBM Workload Simulator for z/OS
- **Event Processing**: CICS event bindings and adapters

### Development Tools
- **REXX**: Customization and automation
- **JCL**: Job control for batch operations
- **CICS Explorer**: Event binding management

---

## Key Application Features

### Business Functionality
1. **Customer Management**
   - Add new customers with unique customer numbers
   - Inquire on existing customer records
   - Update customer information
   - Store in both Db2 and VSAM (two-phase commit)

2. **Policy Management** (4 types)
   - Motor insurance policies
   - Endowment insurance policies
   - House insurance policies
   - Commercial property insurance policies
   - Full CRUD operations for all policy types

3. **Data Integrity**
   - Two-phase commit across Db2 and VSAM
   - Referential integrity (policies require existing customers)
   - Unique key generation via named counters or Db2

### Technical Capabilities
- 3270 terminal interface with BMS maps
- Multi-layer architecture (presentation, business, data)
- Db2 integration via CICS attachment facility
- VSAM file management
- Named counter server for unique ID generation
- Temporary storage queue management
- Transaction monitoring and event processing
- Web services enablement (SOAP/JSON)
- Workload simulation support

---

## Data Model

### Customer Table (Db2 & VSAM)
- Customer Number (10 digits, unique key)
- Customer details (name, address, etc.)
- VSAM key: First 10 characters

### Policy Tables (Db2 & VSAM)
- Main policy table with customer reference
- Type-specific tables: Motor, Endowment, House, Commercial
- Policy Number (10 digits)
- Customer Number (10 digits, foreign key)
- Policy Type (1 character: M, E, H, C)
- VSAM key: Type (1) + Customer Number (10) + Policy Number (10) = 21 characters

### Sample Data
- 10 pre-loaded customers (IDs 1-10)
- 10 pre-loaded policies distributed across 4 types

---

## Deployment Scenarios

### 1. Single Region (Basic)
- Standalone CICS region
- Db2 database
- VSAM files
- 3270 interface
- **Use Case**: Learning, development, basic testing

### 2. Single Region with Coupling Facility
- Adds named counter server
- Adds shared temporary storage queues
- **Use Case**: Testing sysplex features, scalability preparation

### 3. CICSPlex SM Topology
- Multiple CICS regions
- Workload management
- CICSPlex SM management
- **Use Case**: Production-like environment, high availability

### 4. Web Services Enabled
- SOAP/JSON web services
- Pipeline definitions
- TCP/IP service
- **Use Case**: Application integration, modernization demonstration

### 5. Full Featured
- All of the above
- Event processing
- Workload simulation
- **Use Case**: Complete modernization showcase

---

## File Transfer Methods

The repository supports two installation approaches:

### Method 1: Direct USS Clone
- Clone Git repository to USS
- Run `install.sh` script
- Automatic data set allocation and file transfer
- **Requires**: Git client with zos-working-tree-encoding support (e.g., Rocket Git 2.26.2+)

### Method 2: Workstation Download + FTP
- Download/clone to workstation
- Manual FTP transfer to MVS data sets
- Detailed instructions in each subdirectory README
- **Requires**: FTP client, manual data set allocation

---

## Maintenance & Support

### Current Maintainers
- James O'Grady (@JAMOGRAD)
- Ledina Hido-Evans (@ledina)
- Last reviewed: January 2024

### Original Contributors
- Stewart Smith (base application)
- BlueGen project team (extensions)
- Russell Bonner (Business Rules extension)
- Ian Burnett (GitHub publication)

### License
Eclipse Public License 2.0

### Change History
- **2023-11**: Bug fixes for COMMAREA handling
- **2021-05**: Initial GitHub release, COBOL V6 support
- **2019-03**: License update
- **2012-02**: Original SupportPac CB12 release

---

## Related Resources

### IBM Documentation
- [CICS TS Documentation](https://www.ibm.com/docs/en/cics-ts/)
- [CICS Scenarios](https://www.ibm.com/docs/en/cics-ts/5.4?topic=scenarios)
- [Named Counter Server Setup](https://www.ibm.com/docs/en/cics-ts/5.6?topic=servers-setting-up-running-named-counter-server)
- [Temporary Storage Server Setup](https://www.ibm.com/docs/en/cics-ts/5.6?topic=servers-setting-up-running-temporary-storage-server)

### GitHub Organization
- [CICS Transaction Server for z/OS](https://github.com/cicsdev)

---

## Summary Statistics

- **Total Files**: ~150+ files
- **COBOL Programs**: 33 programs
- **Copybooks**: 13 copybooks
- **JCL Jobs**: 29 jobs
- **Workload Scripts**: 39 scripts
- **Documentation Files**: 10+ markdown files
- **Transactions**: 8 user transactions + 4 internal
- **Sample Policies**: 10 across 4 types
- **Sample Customers**: 10