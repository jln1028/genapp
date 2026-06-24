# GenApp Quick Start Guide - 30 Minutes to Understanding

## Purpose

Get up to speed on the CICS General Insurance Application in 30 minutes. This guide provides the essential knowledge needed to understand what GenApp does, how it works, and where to find more information.

**Target Audience**: New team members, stakeholders, anyone needing rapid orientation  
**Time Required**: 30 minutes  
**Prerequisites**: None

---

## 📋 What You'll Learn

- ✅ What GenApp does (business purpose)
- ✅ How it's structured (architecture)
- ✅ Key components and their roles
- ✅ How to navigate the codebase
- ✅ Where to find detailed information

---

## 1. What is GenApp? (5 minutes)

### The Elevator Pitch

GenApp is a **mainframe insurance policy management system** that demonstrates how traditional CICS applications can be modernized. It manages customers and four types of insurance policies through a 3270 terminal interface, with optional web services for modern integration.

### Business Functions

**Customer Management**:
- Add new customers with unique IDs
- Look up customer information
- Update customer details
- Track customer policies

**Policy Management** (4 types):
- 🚗 Motor Insurance
- 🏠 House Insurance  
- 💰 Endowment Insurance
- 🏢 Commercial Property Insurance

**Operations**: Add, Inquire, Update, Delete policies

### Key Business Value

- **Data Integrity**: Two-phase commit ensures Db2 and VSAM stay synchronized
- **Scalability**: Supports CICSPlex SM for workload management
- **Modernization**: Demonstrates API enablement and cloud integration patterns
- **Reliability**: 24/7 mainframe transaction processing

---

## 2. Architecture in 5 Minutes

### The Big Picture

```
User (3270 Terminal)
        ↓
┌───────────────────┐
│  PRESENTATION     │  ← Screens & Input Validation
│  LGTESTC1, etc.   │
└─────────┬─────────┘
          ↓ LINK (COMMAREA)
┌─────────────────────┐
│  BUSINESS LOGIC     │  ← Rules & Orchestration
│  LGACUS01, etc.     │
└─────────┬───────────┘
          ↓ LINK (COMMAREA)
┌─────────────────────┐
│  DATA ACCESS        │  ← Database & File I/O
│  LGACDB01, etc.     │
└─────────┬───────────┘
          ↓
    ┌─────┴─────┐
    ↓           ↓
  Db2         VSAM
```

### Three Layers Explained

**1. Presentation Layer** (5 programs)
- Handles 3270 screen display
- Validates user input
- Routes to business logic
- **Example**: `LGTESTC1` - Customer menu

**2. Business Logic Layer** (7 programs)
- Enforces business rules
- Orchestrates transactions
- Handles errors
- **Example**: `LGACUS01` - Add customer logic

**3. Data Access Layer** (17 programs)
- Db2 SQL operations (11 programs)
- VSAM file I/O (6 programs)
- **Example**: `LGACDB01` - Add customer to Db2

### Communication Pattern

Programs communicate via **COMMAREA** (Communication Area):
- Standard CICS inter-program data passing
- Contains customer/policy data + control fields
- Defined in copybook [`lgcmarea.cpy`](../base/src/lgcmarea.cpy)

---

## 3. Key Components (10 minutes)

### 3.1 Transactions (What Users Run)

| Transaction | Purpose | Menu Type |
|-------------|---------|-----------|
| **LGSE** | Initialize app (run first!) | Setup |
| **SSC1** | Customer operations | Customer menu |
| **SSP1** | Motor insurance | Policy menu |
| **SSP2** | Endowment insurance | Policy menu |
| **SSP3** | House insurance | Policy menu |
| **SSP4** | Commercial property | Policy menu |

**How to Use**:
1. Run `LGSE` to initialize
2. Run `SSC1` to manage customers
3. Run `SSP1-4` to manage policies

### 3.2 Program Naming Convention

Programs follow a consistent pattern:

```
LG [A|I|U|D] [CUS|POL] [01]
│   │         │         │
│   │         │         └─ Version number
│   │         └─────────── Entity (Customer/Policy)
│   └───────────────────── Operation (Add/Inquire/Update/Delete)
└───────────────────────── GenApp prefix
```

**Examples**:
- `LGACUS01` = **L**G **A**dd **CUS**tomer version **01**
- `LGIPOL01` = **L**G **I**nquire **POL**icy version **01**
- `LGUCUS01` = **L**G **U**pdate **CUS**tomer version **01**

**Data Access Suffix**:
- `*DB01` = Db2 operations (e.g., `LGACDB01`)
- `*VS01` = VSAM operations (e.g., `LGACVS01`)

### 3.3 Data Storage

**Db2 Database**:
- `CUSTOMER` table - Customer records
- `POLICY` table - Policy master records
- `MOTOR`, `ENDOWMENT`, `HOUSE`, `COMMERCIAL` - Type-specific tables

**VSAM Files**:
- `KSDSCUST` - Customer file (key: 10-digit customer number)
- `KSDSPOLY` - Policy file (key: 21 chars = type + customer# + policy#)

**Why Both?**
- Demonstrates two-phase commit
- Shows legacy integration patterns
- Not typical for production (usually one or the other)

### 3.4 Sample Data

**10 Customers** (IDs 1-10):
- Pre-loaded for testing
- Located in [`base/data/ksdscust.txt`](../base/data/ksdscust.txt)

**10 Policies**:
- 3 Motor, 2 Endowment, 3 House, 2 Commercial
- Located in [`base/data/ksdspoly.txt`](../base/data/ksdspoly.txt)

---

## 4. Navigating the Codebase (5 minutes)

### Directory Structure

```
cics-genapp/
├── base/                    ← Core application
│   ├── src/                 ← COBOL programs & copybooks (46 files)
│   ├── cntl/                ← JCL jobs for build/deploy (29 files)
│   ├── data/                ← Sample data files
│   ├── wsim/                ← Workload simulator scripts
│   ├── Architecture.md      ← Technical architecture
│   ├── Installation.md      ← Setup guide
│   ├── Building.md          ← Build instructions
│   ├── Testing.md           ← Test procedures
│   └── Reference.md         ← Complete reference
├── docs/                    ← Documentation
│   ├── ONBOARDING_GUIDE.md  ← Detailed onboarding
│   ├── KNOWLEDGE-RECOVERY-STRATEGY.md ← Doc strategy
│   ├── BUSINESS_RULES.md    ← Business logic catalog
│   └── program-documents/   ← Program-level docs
├── bobz/                    ← Bob Z artifacts
│   ├── DD.json              ← Data dictionary
│   ├── impact-analysis/     ← Impact analysis reports
│   └── implementation-plans/ ← Implementation plans
└── AGENTS.md                ← AI agent guidance
```

### Where to Find Things

**Need to understand a program?**
→ Check [`docs/program-documents/`](program-documents/) first
→ Then read source in [`base/src/`](../base/src/)

**Need to understand business rules?**
→ Read [`docs/BUSINESS_RULES.md`](BUSINESS_RULES.md)

**Need to build/deploy?**
→ Follow [`base/Building.md`](../base/Building.md)
→ JCL jobs in [`base/cntl/`](../base/cntl/)

**Need to understand architecture?**
→ Read [`base/Architecture.md`](../base/Architecture.md)
→ See diagram: [`base/images/initial_topology.jpg`](../base/images/initial_topology.jpg)

**Need variable meanings?**
→ Check [`bobz/DD.json`](../bobz/DD.json) (data dictionary)

---

## 5. Common Workflows (5 minutes)

### Workflow 1: Add a Customer

**User Actions**:
1. Run transaction `SSC1`
2. Enter customer details
3. Select option 2 (Add)
4. System assigns customer number

**System Flow**:
```
LGTESTC1 (Presentation)
    ↓ validates input, normalizes data
LGACUS01 (Business Logic)
    ↓ enforces rules, orchestrates
LGACDB01 (Data Access)
    ↓ inserts to Db2
LGACVS01 (Data Access)
    ↓ writes to VSAM
Two-Phase Commit
    ↓ both succeed or both rollback
Return customer number to user
```

### Workflow 2: Add a Policy

**User Actions**:
1. Run transaction `SSP1` (motor), `SSP2` (endowment), `SSP3` (house), or `SSP4` (commercial)
2. Enter policy details + customer number
3. Select option 2 (Add)
4. System assigns policy number

**System Flow**:
```
LGTESTP1-4 (Presentation)
    ↓ validates input
LGAPOL01 (Business Logic)
    ↓ verifies customer exists
LGAPDB01 (Data Access)
    ↓ inserts to Db2 (checks foreign key)
LGAPVS01 (Data Access)
    ↓ writes to VSAM
Two-Phase Commit
    ↓ both succeed or both rollback
Return policy number to user
```

### Workflow 3: Inquire on Customer

**User Actions**:
1. Run transaction `SSC1`
2. Enter customer number
3. Select option 1 (Inquire)
4. View customer details

**System Flow**:
```
LGTESTC1 (Presentation)
    ↓ validates customer number
LGICUS01 (Business Logic)
    ↓ orchestrates retrieval
LGICDB01 (Data Access)
    ↓ queries Db2
Return data to screen
```

---

## 6. Key Concepts (5 minutes)

### COMMAREA (Communication Area)

**What**: Standard CICS mechanism for passing data between programs

**Structure**:
- Header (18 bytes): Control information
- Body: Customer or policy data
- Defined in [`lgcmarea.cpy`](../base/src/lgcmarea.cpy)

**Key Fields**:
- `CA-REQUEST-ID`: Routes request to correct handler
- `CA-RETURN-CODE`: Success/error indicator (00=success)
- `CA-CUSTOMER-NUM`: Customer identifier
- `CA-POLICY-NUM`: Policy identifier

### Two-Phase Commit

**What**: Ensures atomic updates across Db2 and VSAM

**How it Works**:
1. Begin transaction
2. Update Db2 (prepare phase)
3. Update VSAM (prepare phase)
4. If both succeed → commit both
5. If either fails → rollback both

**Why**: Maintains data consistency across heterogeneous systems

### Named Counter Service

**What**: Generates unique customer numbers across sysplex

**How it Works**:
- CICS Named Counter `GENACUSTNUM` in pool `GENA`
- Provides high-performance sequence generation
- Falls back to Db2 identity columns if unavailable

**Why**: Ensures unique IDs in multi-region environments

### Error Handling

**Pattern**: CICS-style, not exception-style

**Mechanism**:
- Programs set `CA-RETURN-CODE`
- Common codes: 00=success, 90=SQL error, 98=invalid length
- Errors logged to temporary storage queue `GENAERRS`
- Hard failures may `ABEND`

---

## 7. Next Steps

### Immediate Actions (Choose Your Path)

**Path 1: I Want to Understand the Code**
1. ✅ Read [`docs/ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) (comprehensive)
2. ✅ Study program docs in [`docs/program-documents/`](program-documents/)
3. ✅ Review [`docs/BUSINESS_RULES.md`](BUSINESS_RULES.md)
4. ✅ Trace a transaction flow in the source code

**Path 2: I Want to Install and Run It**
1. ✅ Review [`base/Installation.md`](../base/Installation.md)
2. ✅ Follow [`base/Building.md`](../base/Building.md)
3. ✅ Test with [`base/Testing.md`](../base/Testing.md)
4. ✅ Explore transactions hands-on

**Path 3: I Want to Modify It**
1. ✅ Complete Path 1 (understand the code)
2. ✅ Complete Path 2 (install and run)
3. ✅ Read [`AGENTS.md`](../AGENTS.md) for development rules
4. ✅ Review impact analysis examples in [`bobz/impact-analysis/`](../bobz/impact-analysis/)

**Path 4: I Want to Modernize It**
1. ✅ Read [`docs/SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md)
2. ✅ Review [`docs/MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md)
3. ✅ Study [`docs/KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md)
4. ✅ Assess API enablement opportunities

### Key Documentation by Role

**Developer**:
- [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) - Complete onboarding
- [`AGENTS.md`](../AGENTS.md) - Development rules
- [`BUSINESS_RULES.md`](BUSINESS_RULES.md) - Business logic
- [`program-documents/`](program-documents/) - Program details

**Architect**:
- [`base/Architecture.md`](../base/Architecture.md) - Technical architecture
- [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - Executive summary
- [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) - Modernization patterns
- [`REPOSITORY_STRUCTURE.md`](REPOSITORY_STRUCTURE.md) - Complete structure

**Operations**:
- [`base/Installation.md`](../base/Installation.md) - Setup procedures
- [`base/Building.md`](../base/Building.md) - Build process
- [`base/Testing.md`](../base/Testing.md) - Test procedures
- [`base/Reference.md`](../base/Reference.md) - Complete reference

**Business Analyst**:
- [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - Business context
- [`BUSINESS_RULES.md`](BUSINESS_RULES.md) - Business rules catalog
- [`base/Architecture.md`](../base/Architecture.md) - System capabilities

---

## 8. Quick Reference

### Essential Files

| File | Purpose | When to Use |
|------|---------|-------------|
| [`AGENTS.md`](../AGENTS.md) | Development rules | Before making changes |
| [`bobz/DD.json`](../bobz/DD.json) | Variable meanings | Understanding data |
| [`base/src/lgcmarea.cpy`](../base/src/lgcmarea.cpy) | COMMAREA structure | Understanding interfaces |
| [`base/src/lgpolicy.cpy`](../base/src/lgpolicy.cpy) | Policy structure | Understanding policies |
| [`base/Reference.md`](../base/Reference.md) | Complete reference | Finding resources |

### Essential Commands

**Initialize Application**:
```
LGSE
```

**Test Customer Operations**:
```
SSC1
```

**Test Policy Operations**:
```
SSP1  (Motor)
SSP2  (Endowment)
SSP3  (House)
SSP4  (Commercial)
```

### Essential Concepts

- **Three-Tier Architecture**: Presentation → Business → Data
- **COMMAREA**: Inter-program communication mechanism
- **Two-Phase Commit**: Db2 + VSAM atomic updates
- **Named Counter**: Unique ID generation
- **Program Naming**: LG[A|I|U|D][CUS|POL]01

---

## 9. Common Questions

**Q: Why both Db2 and VSAM?**  
A: Demonstrates two-phase commit and legacy integration patterns. Not typical for production.

**Q: What's the difference between *DB01 and *VS01 programs?**  
A: *DB01 programs handle Db2 SQL operations. *VS01 programs handle VSAM file I/O.

**Q: How do I know which program to look at?**  
A: Follow the naming convention: LG[Operation][Entity]01 for business logic, add DB or VS for data access.

**Q: Where are business rules documented?**  
A: [`docs/BUSINESS_RULES.md`](BUSINESS_RULES.md) catalogs all business rules with source code references.

**Q: How do I trace a transaction?**  
A: Start with the transaction (SSC1, SSP1, etc.) → find presentation program → follow LINK commands to business logic → follow LINK commands to data access.

**Q: What's COMMAREA?**  
A: Standard CICS mechanism for passing data between programs. Defined in [`lgcmarea.cpy`](../base/src/lgcmarea.cpy).

**Q: How do I add a new feature?**  
A: Read [`AGENTS.md`](../AGENTS.md) for development rules, review similar programs, follow the three-tier pattern.

**Q: Where's the data dictionary?**  
A: [`bobz/DD.json`](../bobz/DD.json) contains variable descriptions and business context.

**Q: How do I modernize this?**  
A: Read [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) and [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md).

**Q: What if I get stuck?**  
A: Check the documentation index below, review program documents, or consult the team.

---

## 10. Documentation Index

### Getting Started
- ✅ **This Guide** - 30-minute quick start
- [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) - Comprehensive onboarding (2-3 hours)
- [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - Executive summary (15 min)

### Technical Documentation
- [`base/Architecture.md`](../base/Architecture.md) - System architecture
- [`base/Installation.md`](../base/Installation.md) - Installation guide
- [`base/Building.md`](../base/Building.md) - Build procedures
- [`base/Testing.md`](../base/Testing.md) - Testing guide
- [`base/Reference.md`](../base/Reference.md) - Complete reference

### Code Documentation
- [`program-documents/`](program-documents/) - Program-level docs
- [`BUSINESS_RULES.md`](BUSINESS_RULES.md) - Business rules catalog
- [`bobz/DD.json`](../bobz/DD.json) - Data dictionary
- [`AGENTS.md`](../AGENTS.md) - Development rules

### Strategic Documentation
- [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) - Documentation strategy
- [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) - Modernization patterns
- [`REPOSITORY_STRUCTURE.md`](REPOSITORY_STRUCTURE.md) - Repository analysis

### Analysis Documentation
- [`bobz/impact-analysis/`](../bobz/impact-analysis/) - Impact analysis examples
- [`bobz/implementation-plans/`](../bobz/implementation-plans/) - Implementation plans
- [`REFACTORING_OPPORTUNITIES.md`](REFACTORING_OPPORTUNITIES.md) - Refactoring guide

---

## Congratulations! 🎉

You now have a solid foundation for understanding GenApp. You know:
- ✅ What it does (insurance policy management)
- ✅ How it's structured (three-tier architecture)
- ✅ Key components (programs, transactions, data)
- ✅ How to navigate the codebase
- ✅ Where to find detailed information

**Next**: Choose your path from Section 7 and dive deeper!

---

**Document Control**
- **Version**: 1.0
- **Created**: 2026-06-24
- **Last Updated**: 2026-06-24
- **Estimated Reading Time**: 30 minutes
- **Target Audience**: All roles