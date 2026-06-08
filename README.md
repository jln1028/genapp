# General Insurance Application (GenApp) for IBM CICS TS

[![License](https://img.shields.io/badge/License-EPL%202.0-blue.svg)](LICENSE)
[![CICS TS](https://img.shields.io/badge/CICS%20TS-V4.1%2B-green.svg)](https://www.ibm.com/products/cics-transaction-server)

A comprehensive demonstration application showcasing CICS Transaction Server modernization techniques through a working general insurance system.

---

## 🎯 What is GenApp?

GenApp is a production-quality COBOL application originally distributed as IBM SupportPac CB12, designed to demonstrate how traditional 3270 "green screen" mainframe applications can be modernized using the latest CICS Transaction Server capabilities.

**Key Features:**
- 🏢 Complete insurance business application (customers and policies)
- 🔄 Three-tier architecture (presentation, business logic, data access)
- 💾 Dual storage (Db2 database + VSAM files with two-phase commit)
- 🖥️ 3270 terminal interface with BMS maps
- 🌐 Web services enablement (SOAP/JSON)
- 📊 Workload management and event processing
- 🔧 Extensible design for learning and experimentation

---

## 📚 Quick Navigation

### 🚀 Getting Started
- **New to GenApp?** → Start with the [Onboarding Guide](docs/ONBOARDING_GUIDE.md)
- **Ready to install?** → Follow [Installation Instructions](base/Installation.md)
- **Want to understand the architecture?** → Read [Architecture Overview](base/Architecture.md)

### 📖 Documentation
| Document | Purpose |
|----------|---------|
| [**Onboarding Guide**](docs/ONBOARDING_GUIDE.md) | Step-by-step guide for new users and contributors |
| [**Repository Structure**](docs/REPOSITORY_STRUCTURE.md) | Detailed analysis of all files and components |
| [**Architecture**](base/Architecture.md) | System design and component interactions |
| [**Installation**](base/Installation.md) | Setup procedures for USS and workstation |
| [**Building**](base/Building.md) | Build process and JCL job execution |
| [**Testing**](base/Testing.md) | Validation procedures and test scenarios |
| [**Reference**](base/Reference.md) | Complete catalog of transactions, programs, and resources |

### 🎓 Learning Paths

Choose your path based on your goals:

| Path | Time | Best For |
|------|------|----------|
| [**Understanding GenApp**](docs/ONBOARDING_GUIDE.md#-path-1-i-want-to-understand-what-genapp-does) | 15 min | Learning about the application |
| [**Installing GenApp**](docs/ONBOARDING_GUIDE.md#%EF%B8%8F-path-2-i-want-to-install-and-run-genapp) | 2-4 hrs | Setting up the environment |
| [**Developing with GenApp**](docs/ONBOARDING_GUIDE.md#-path-3-i-want-to-modify-or-extend-genapp) | 1-2 hrs | Modifying or extending code |
| [**Testing with GenApp**](docs/ONBOARDING_GUIDE.md#-path-4-i-want-to-use-genapp-for-testingdemonstration) | 3-5 hrs | Workload testing and demos |

---

## 🏗️ Application Overview

### Business Functionality

GenApp simulates a general insurance company managing:

**Customer Management:**
- Add, inquire, update customer records
- Unique customer number generation
- Customer data validation

**Policy Management (4 Types):**
- 🚗 Motor insurance policies
- 💰 Endowment insurance policies
- 🏠 House insurance policies
- 🏢 Commercial property insurance policies

**Operations:** Full CRUD (Create, Read, Update, Delete) for all entity types

### Technical Architecture

```
┌─────────────────────────────────────────────────────────┐
│              3270 Terminal Interface (BMS)               │
│                  Presentation Layer                      │
└────────────────────┬────────────────────────────────────┘
                     │ EXEC CICS LINK
┌────────────────────▼────────────────────────────────────┐
│                 Business Logic Layer                     │
│         Validation, Processing, Coordination             │
└────────────────────┬────────────────────────────────────┘
                     │ EXEC CICS LINK
┌────────────────────▼────────────────────────────────────┐
│               Data Management Layer                      │
│    ┌──────────────────┐      ┌──────────────────┐      │
│    │   Db2 Access     │      │   VSAM Access    │      │
│    └────────┬─────────┘      └────────┬─────────┘      │
└─────────────┼──────────────────────────┼────────────────┘
              │                          │
    ┌─────────▼─────────┐    ┌──────────▼──────────┐
    │  Db2 Database     │    │   VSAM Files        │
    │  (Primary Store)  │    │   (Secondary Store) │
    └───────────────────┘    └─────────────────────┘
```

**Key Design Principles:**
- Separation of concerns across layers
- Two-phase commit for data integrity
- Modular, reusable components
- Extensible for modernization scenarios

---

## 🎯 Use Cases

GenApp is ideal for:

1. **Learning CICS Development**
   - Study a complete, working application
   - Understand three-tier architecture
   - Learn CICS programming patterns

2. **Testing CICS Features**
   - Web services (SOAP/JSON)
   - CICSPlex SM and workload management
   - Event processing and monitoring
   - Named counters and shared resources

3. **Demonstrating Modernization**
   - Transform 3270 apps to web services
   - Integrate with modern applications
   - Showcase cloud enablement

4. **Performance Testing**
   - Use included Workload Simulator scripts
   - Test scalability scenarios
   - Benchmark CICS configurations

5. **Training and Education**
   - Hands-on CICS training
   - Application architecture examples
   - Best practices demonstration

---

## 📋 Prerequisites

### Required Software
- **IBM CICS Transaction Server for z/OS** V4.1 or later
- **IBM Db2 for z/OS** (any supported version)
- **Enterprise COBOL** V6.x (recommended)
- **z/OS** (compatible with CICS version)

### Required Knowledge
- Basic CICS concepts (transactions, programs, resources)
- z/OS navigation and JCL
- Understanding of MVS data sets
- COBOL programming (for development)

### Optional Components
- **Coupling Facility** (for named counters and shared queues)
- **CICSPlex SM** (for workload management)
- **IBM Workload Simulator** (for automated testing)
- **CICS Explorer** (for event binding management)

See the [Onboarding Guide](docs/ONBOARDING_GUIDE.md#prerequisites) for detailed requirements.

---

## 🚀 Quick Start

### Installation Methods

**Option 1: Direct USS Clone** (Recommended)
```bash
# Clone to USS
git clone https://github.com/cicsdev/cics-genapp.git
cd cics-genapp/base/bin

# Edit and run installation script
vi install.sh
./install.sh
```

**Option 2: Workstation + FTP**
1. Download repository to workstation
2. Transfer files via FTP to MVS data sets
3. Follow detailed instructions in each directory's README

### Basic Setup Steps

1. **Install** → Follow [Installation.md](base/Installation.md)
2. **Customize** → Edit and run CUST1 REXX script
3. **Build** → Submit JCL jobs in sequence
4. **Configure** → Update CICS region parameters
5. **Test** → Run LGSE and SSC1 transactions

See [Building.md](base/Building.md) for complete build instructions.

---

## 📦 Repository Contents

### Core Application (`base/`)

```
base/
├── 📄 Documentation (Architecture, Installation, Building, Testing, Reference)
├── 🔧 bin/          - Installation scripts
├── 📋 cntl/         - JCL jobs (29 members)
├── 📊 data/         - Sample data files
├── 🎯 event-bindings/ - CICS event definitions
├── 📝 exec/         - REXX customization scripts
├── 🖼️  images/       - Architecture diagrams
├── 💻 src/          - COBOL source (33 programs, 13 copybooks)
└── 🔄 wsim/         - Workload Simulator scripts (39 files)
```

### Key Components

| Component | Count | Purpose |
|-----------|-------|---------|
| **COBOL Programs** | 33 | Application logic |
| **Copybooks** | 13 | Data structures |
| **JCL Jobs** | 29 | Build and setup |
| **Transactions** | 8 | User interface |
| **Workload Scripts** | 39 | Automated testing |
| **Sample Customers** | 10 | Test data |
| **Sample Policies** | 10 | Test data |

See [Repository Structure](docs/REPOSITORY_STRUCTURE.md) for detailed analysis.

---

## 🎮 Using GenApp

### Main Transactions

| Transaction | Purpose | Description |
|-------------|---------|-------------|
| **LGSE** | Setup | Initialize counters and queues |
| **SSC1** | Customers | Add, inquire, update customer records |
| **SSP1** | Motor Policies | Manage motor insurance policies |
| **SSP2** | Endowment | Manage endowment policies |
| **SSP3** | House | Manage house insurance policies |
| **SSP4** | Commercial | Manage commercial property policies |

### Basic Operations

Each transaction supports:
1. **Inquire** (Option 1) - View existing records
2. **Add** (Option 2) - Create new records
3. **Update** (Option 3) - Modify existing records
4. **Delete** (Option 4) - Remove records

### Sample Data

Pre-loaded with:
- 10 customer records (IDs 1-10)
- 10 insurance policies across 4 types
- Ready for immediate testing

See [Testing.md](base/Testing.md) for detailed test procedures.

---

## 🔧 Development

### Code Organization

Programs follow a consistent naming pattern:

```
LG [A|I|U|D] [CUS|POL] [DB|VS] [01]
│   │         │         │       │
│   │         │         │       └─ Version
│   │         │         └───────── Storage (DB2/VSAM)
│   │         └─────────────────── Entity
│   └───────────────────────────── Operation
└───────────────────────────────── Prefix
```

**Examples:**
- `LGACDB01` - Add Customer to Db2
- `LGIPOL01` - Inquire Policy (business logic)
- `LGUCVS01` - Update Customer in VSAM

### Making Changes

1. Modify source in `base/src/`
2. Compile with `@COBOL` JCL job
3. Test in CICS region
4. Validate data integrity

See [Onboarding Guide](docs/ONBOARDING_GUIDE.md#development-guidelines) for detailed guidelines.

---

## 🌟 Advanced Features

### Web Services
- SOAP and JSON support (CICS TS V5.2+)
- Provider mode pipelines
- Sample web service definitions included
- See `@WSAxx01` JCL jobs

### CICSPlex SM
- Workload management
- Topology management
- Resource monitoring
- See `@CPSMDE2`, `@SAMPCMA` jobs

### Event Processing
- Transaction counters
- Event bindings
- Dashboard integration
- See `event-bindings/` directory

### Workload Simulation
- 39 pre-built scripts
- Customer and policy operations
- Performance testing
- See `wsim/` directory

---

## 📊 Project Statistics

- **Total Files**: 150+ files
- **Lines of COBOL**: Thousands across 33 programs
- **JCL Jobs**: 29 build and configuration jobs
- **Documentation**: 10+ markdown files
- **First Released**: February 2012 (as SupportPac CB12)
- **GitHub Release**: May 2021
- **Last Updated**: November 2023

---

## 🤝 Contributing

We welcome contributions! Here's how to get involved:

1. **Report Issues**: Use GitHub Issues for bugs or feature requests
2. **Submit Pull Requests**: Follow existing code patterns
3. **Improve Documentation**: Help make docs clearer
4. **Share Use Cases**: Tell us how you're using GenApp

### Maintainers
- James O'Grady ([@JAMOGRAD](https://github.com/JAMOGRAD))
- Ledina Hido-Evans ([@ledina](https://github.com/ledina))

See [MAINTAINERS.md](MAINTAINERS.md) for contact information.

---

## 📜 License

This project is licensed under the [Eclipse Public License 2.0](LICENSE).

Originally distributed as IBM SupportPac CB12, now freely available for learning, development, and demonstration purposes.

---

## 📚 Additional Resources

### IBM Documentation
- [CICS TS Documentation](https://www.ibm.com/docs/en/cics-ts/)
- [CICS Scenarios](https://www.ibm.com/docs/en/cics-ts/5.4?topic=scenarios)
- [CICS Developer Center](https://developer.ibm.com/components/cics/)

### Related Projects
- [CICS Developer GitHub](https://github.com/cicsdev)
- [CICS Samples](https://github.com/cicsdev?q=sample)

### Learning Resources
- [IBM CICS Learning](https://www.ibm.com/training/cics)
- [CICS Application Programming](https://www.ibm.com/docs/en/cics-ts/5.6?topic=programming)

---

## 🗺️ Roadmap

GenApp continues to evolve with CICS TS releases. Potential future enhancements:

- [ ] Container support
- [ ] REST API examples
- [ ] Cloud-native integration patterns
- [ ] Additional modernization scenarios
- [ ] Enhanced monitoring and observability

---

## 📞 Getting Help

### Documentation
Start with our comprehensive guides:
- [Onboarding Guide](docs/ONBOARDING_GUIDE.md) - For new users
- [Repository Structure](docs/REPOSITORY_STRUCTURE.md) - Detailed component analysis
- [Architecture](base/Architecture.md) - System design
- [Reference](base/Reference.md) - Complete resource catalog

### Support Channels
- **GitHub Issues**: For bugs and feature requests
- **IBM Documentation**: For CICS TS questions
- **Community**: CICS developer forums and communities

### Common Issues
See the [Onboarding Guide - Common Issues](docs/ONBOARDING_GUIDE.md#common-issues-and-solutions) section for troubleshooting help.

---

## 🎉 Acknowledgments

### Original Contributors
- **Stewart Smith** - Base application development
- **BlueGen Project Team** - Policy and Customer Search extensions
- **Russell Bonner** - Business Rules extension
- **Ian Burnett** - GitHub publication

### History
- **2012**: Initial release as SupportPac CB12
- **2021**: Open source release on GitHub
- **2023**: Latest updates and improvements

See [Changes.md](Changes.md) for complete change history.

---

## ⭐ Star This Repository

If you find GenApp useful for learning, development, or demonstration, please star this repository to show your support!

---

<div align="center">

**[Get Started](docs/ONBOARDING_GUIDE.md)** • **[Documentation](base/)** • **[Issues](https://github.com/cicsdev/cics-genapp/issues)** • **[License](LICENSE)**

Made with ❤️ by the CICS Development Team

</div>
