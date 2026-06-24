# GenApp Documentation Index

## Overview

This index provides a comprehensive guide to all documentation in the CICS General Insurance Application (GenApp) repository. Use this as your starting point to find the information you need quickly.

**Last Updated**: 2026-06-24  
**Total Documents**: 40+ files across multiple categories

---

## 🚀 Quick Access by Role

### New Team Member
Start here for rapid onboarding:
1. [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md) - 30 minutes to understanding
2. [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) - Comprehensive onboarding (2-3 hours)
3. [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - Executive summary

### Developer
Essential reading for code work:
1. [`AGENTS.md`](../AGENTS.md) - Development rules and guidelines
2. [`program-documents/`](program-documents/) - Program-level documentation
3. [`BUSINESS_RULES.md`](BUSINESS_RULES.md) - Business logic catalog
4. [`data-flows/`](data-flows/) - Transaction flow documentation
5. [`bobz/DD.json`](../bobz/DD.json) - Data dictionary

### Architect
Strategic and design documentation:
1. [`base/Architecture.md`](../base/Architecture.md) - Technical architecture
2. [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - System overview
3. [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) - Modernization patterns
4. [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) - Documentation strategy
5. [`bobz/impact-analysis/`](../bobz/impact-analysis/) - Impact analysis examples

### Operations/Support
Operational documentation:
1. [`base/Installation.md`](../base/Installation.md) - Installation procedures
2. [`base/Building.md`](../base/Building.md) - Build process
3. [`base/Testing.md`](../base/Testing.md) - Testing procedures
4. [`base/Reference.md`](../base/Reference.md) - Complete reference
5. Production runbooks (planned - see [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md))

### Business Analyst
Business-focused documentation:
1. [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - Business context
2. [`BUSINESS_RULES.md`](BUSINESS_RULES.md) - Business rules catalog
3. [`base/Architecture.md`](../base/Architecture.md) - System capabilities
4. [`GENAPP-BUSINESS-GLOSSARY.md`](GENAPP-BUSINESS-GLOSSARY.md) - Business terminology

### Project Manager
Project and planning documentation:
1. [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) - Documentation roadmap
2. [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - ROI and metrics
3. [`bobz/implementation-plans/`](../bobz/implementation-plans/) - Implementation examples
4. [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) - Modernization strategy

---

## 📚 Documentation by Category

### 1. Getting Started (Essential Reading)

| Document | Purpose | Time | Audience |
|----------|---------|------|----------|
| [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md) | 30-minute orientation | 30 min | Everyone |
| [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) | Comprehensive onboarding | 2-3 hrs | New team members |
| [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) | Executive summary | 15 min | Leadership, stakeholders |
| [`REPOSITORY_STRUCTURE.md`](REPOSITORY_STRUCTURE.md) | Repository analysis | 30 min | Developers, architects |

### 2. Architecture & Design

| Document | Purpose | Audience |
|----------|---------|----------|
| [`base/Architecture.md`](../base/Architecture.md) | Technical architecture | Architects, developers |
| [`SYSTEM-ARCHITECTURE-DIAGRAM.md`](SYSTEM-ARCHITECTURE-DIAGRAM.md) | Visual architecture | All technical roles |
| [`ArchDiag.md`](ArchDiag.md) | Architecture diagrams | Architects |
| [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) | Modernization patterns | Architects, leadership |
| [`EXTERNAL-DEPENDENCIES.md`](EXTERNAL-DEPENDENCIES.md) | External system dependencies | Architects, operations |

### 3. Installation & Setup

| Document | Purpose | Audience |
|----------|---------|----------|
| [`base/Installation.md`](../base/Installation.md) | Installation procedures | Operations, developers |
| [`base/Building.md`](../base/Building.md) | Build process | Developers, operations |
| [`base/Testing.md`](../base/Testing.md) | Testing procedures | QA, developers |
| [`base/Reference.md`](../base/Reference.md) | Complete reference | All roles |

### 4. Program Documentation

| Document | Purpose | Status |
|----------|---------|--------|
| [`program-documents/LGACUS01.md`](program-documents/LGACUS01.md) | Add customer business logic | ✅ Complete |
| [`program-documents/`](program-documents/) | All program docs | 🟡 3% complete (1/33) |

**Note**: See [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) for program documentation roadmap.

### 5. Data Flow Documentation

| Document | Purpose | Status |
|----------|---------|--------|
| [`data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md`](data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md) | Customer add transaction flow | ✅ Complete |
| [`INSERT-CUSTOMER-DATA-FLOW.md`](INSERT-CUSTOMER-DATA-FLOW.md) | Customer insert flow | ✅ Complete |
| [`INQUIRY-TRANSACTION-EXECUTION-TRACE.md`](INQUIRY-TRANSACTION-EXECUTION-TRACE.md) | Inquiry transaction trace | ✅ Complete |
| [`TRANSACTION-ENTRY-POINTS.md`](TRANSACTION-ENTRY-POINTS.md) | Transaction entry points | ✅ Complete |
| [`TRANSACTION-ROUTING-LOGIC.md`](TRANSACTION-ROUTING-LOGIC.md) | Request routing logic | ✅ Complete |

**Planned**: Policy add, update, delete flows (see [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md))

### 6. Business Rules & Logic

| Document | Purpose | Audience |
|----------|---------|----------|
| [`BUSINESS_RULES.md`](BUSINESS_RULES.md) | Complete business rules catalog | Developers, analysts |
| [`GENAPP-BUSINESS-GLOSSARY.md`](GENAPP-BUSINESS-GLOSSARY.md) | Business terminology | All roles |
| [`AIRLINE-BUSINESS-GLOSSARY.md`](AIRLINE-BUSINESS-GLOSSARY.md) | Domain glossary (legacy) | Reference |

### 7. Code Analysis & Quality

| Document | Purpose | Audience |
|----------|---------|----------|
| [`CONTROL-FLOW-ANALYSIS.md`](CONTROL-FLOW-ANALYSIS.md) | Control flow analysis | Developers, architects |
| [`DEAD_CODE_ANALYSIS.md`](DEAD_CODE_ANALYSIS.md) | Dead code identification | Developers |
| [`REFACTORING_OPPORTUNITIES.md`](REFACTORING_OPPORTUNITIES.md) | Refactoring recommendations | Developers, architects |
| [`PERFORMANCE-OPTIMIZATION-ANALYSIS.md`](PERFORMANCE-OPTIMIZATION-ANALYSIS.md) | Performance analysis | Architects, operations |

### 8. Strategic Planning

| Document | Purpose | Audience |
|----------|---------|----------|
| [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) | Documentation strategy & roadmap | Leadership, architects |
| [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) | Modernization approach | Leadership, architects |
| [`DOCUMENTATION_RECOMMENDATIONS.md`](DOCUMENTATION_RECOMMENDATIONS.md) | Documentation best practices | Technical writers |

### 9. Development Guidelines

| Document | Purpose | Audience |
|----------|---------|----------|
| [`AGENTS.md`](../AGENTS.md) | AI agent guidance & dev rules | Developers, AI tools |
| [`base/src/README.md`](../base/src/README.md) | Source code guidelines | Developers |
| [`base/cntl/README.md`](../base/cntl/README.md) | JCL guidelines | Operations |
| [`base/wsim/README.md`](../base/wsim/README.md) | Workload simulator guide | QA, performance |

### 10. Data Dictionary & Schemas

| Document | Purpose | Audience |
|----------|---------|----------|
| [`bobz/DD.json`](../bobz/DD.json) | Variable descriptions & context | Developers, analysts |
| [`base/src/lgcmarea.cpy`](../base/src/lgcmarea.cpy) | COMMAREA structure | Developers |
| [`base/src/lgpolicy.cpy`](../base/src/lgpolicy.cpy) | Policy data structure | Developers |

### 11. Impact Analysis & Planning

| Document | Purpose | Status |
|----------|---------|--------|
| [`bobz/impact-analysis/ca-customer-num-12-digit-20260605T025040Z/`](../bobz/impact-analysis/ca-customer-num-12-digit-20260605T025040Z/) | Customer number expansion | ✅ Example |
| [`bobz/impact-analysis/electric-vehicle-category-20260605T025636Z/`](../bobz/impact-analysis/electric-vehicle-category-20260605T025636Z/) | EV policy type addition | ✅ Example |
| [`bobz/impact-analysis/performance-optimization-20260618T211427Z/`](../bobz/impact-analysis/performance-optimization-20260618T211427Z/) | Performance optimization | ✅ Example |

### 12. Implementation Plans

| Document | Purpose | Status |
|----------|---------|--------|
| [`bobz/implementation-plans/ca-customer-num-12-digit-expansion-20260605T030354Z/`](../bobz/implementation-plans/ca-customer-num-12-digit-expansion-20260605T030354Z/) | Customer number expansion plan | ✅ Example |
| [`bobz/implementation-plans/electric-vehicle-policy-type-20260605T031056Z/`](../bobz/implementation-plans/electric-vehicle-policy-type-20260605T031056Z/) | EV policy implementation plan | ✅ Example |

### 13. Call Graphs & Dependencies

| Document | Purpose | Audience |
|----------|---------|----------|
| [`callgraphs/LGACUS01-CALLGRAPH.md`](callgraphs/LGACUS01-CALLGRAPH.md) | LGACUS01 call graph | Developers, architects |

**Planned**: Call graphs for all programs (see [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md))

---

## 🔍 Finding Information Quickly

### By Topic

**Understanding the Application**:
- Start: [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md)
- Deep dive: [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md)
- Architecture: [`base/Architecture.md`](../base/Architecture.md)

**Working with Code**:
- Rules: [`AGENTS.md`](../AGENTS.md)
- Programs: [`program-documents/`](program-documents/)
- Business logic: [`BUSINESS_RULES.md`](BUSINESS_RULES.md)
- Variables: [`bobz/DD.json`](../bobz/DD.json)

**Understanding Data Flow**:
- Customer add: [`data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md`](data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md)
- Transaction routing: [`TRANSACTION-ROUTING-LOGIC.md`](TRANSACTION-ROUTING-LOGIC.md)
- Entry points: [`TRANSACTION-ENTRY-POINTS.md`](TRANSACTION-ENTRY-POINTS.md)

**Planning Changes**:
- Impact analysis: [`bobz/impact-analysis/`](../bobz/impact-analysis/)
- Implementation plans: [`bobz/implementation-plans/`](../bobz/implementation-plans/)
- Refactoring: [`REFACTORING_OPPORTUNITIES.md`](REFACTORING_OPPORTUNITIES.md)

**Installation & Operations**:
- Install: [`base/Installation.md`](../base/Installation.md)
- Build: [`base/Building.md`](../base/Building.md)
- Test: [`base/Testing.md`](../base/Testing.md)
- Reference: [`base/Reference.md`](../base/Reference.md)

**Modernization**:
- Strategy: [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md)
- Architecture: [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md)
- ROI: [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md)

### By Question

**"What does this application do?"**
→ [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md)

**"How do I get started?"**
→ [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md)

**"How do I install it?"**
→ [`base/Installation.md`](../base/Installation.md)

**"What does this program do?"**
→ [`program-documents/`](program-documents/) (if documented)  
→ [`AGENTS.md`](../AGENTS.md) (for program mapping)

**"What does this variable mean?"**
→ [`bobz/DD.json`](../bobz/DD.json)

**"How does this transaction work?"**
→ [`data-flows/`](data-flows/)  
→ [`TRANSACTION-ROUTING-LOGIC.md`](TRANSACTION-ROUTING-LOGIC.md)

**"What are the business rules?"**
→ [`BUSINESS_RULES.md`](BUSINESS_RULES.md)

**"How do I make a change?"**
→ [`AGENTS.md`](../AGENTS.md)  
→ [`bobz/implementation-plans/`](../bobz/implementation-plans/) (examples)

**"What will this change affect?"**
→ [`bobz/impact-analysis/`](../bobz/impact-analysis/) (examples)  
→ Use Bob Z Architect Mode impact-analysis skill

**"How do we modernize this?"**
→ [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md)  
→ [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md)

**"Where's the documentation strategy?"**
→ [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md)

---

## 📊 Documentation Status Dashboard

### Coverage Metrics

| Category | Documents | Status | Target |
|----------|-----------|--------|--------|
| **Getting Started** | 4/4 | ✅ 100% | 100% |
| **Architecture** | 5/5 | ✅ 100% | 100% |
| **Installation** | 4/4 | ✅ 100% | 100% |
| **Program Docs** | 1/33 | 🔴 3% | 100% |
| **Data Flows** | 5/5 | ✅ 100% | 100% (core) |
| **Business Rules** | 1/1 | ✅ 100% | 100% |
| **Code Analysis** | 4/4 | ✅ 100% | 100% |
| **Strategic** | 3/3 | ✅ 100% | 100% |
| **Development** | 4/4 | ✅ 100% | 100% |
| **Data Dictionary** | 1/1 | ✅ 100% | 100% |
| **Impact Analysis** | 3 examples | ✅ Examples | Ongoing |
| **Implementation Plans** | 2 examples | ✅ Examples | Ongoing |
| **Operational** | 0/3 | 🔴 0% | 100% |

### Priority Gaps

**CRITICAL** 🔴:
1. Program documentation (32 programs remaining)
2. Operational runbooks (0/3 planned)

**HIGH** 🟡:
1. Additional data flow documentation (policy operations)
2. COMMAREA contracts documentation
3. Two-phase commit patterns documentation

**MEDIUM** 🟢:
1. Performance tuning guide
2. Monitoring & alerting guide
3. API enablement strategy
4. Cloud migration patterns

See [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) for complete roadmap.

---

## 🛠️ Documentation Tools & Standards

### Generation Tools

**Bob Z Architect Mode**:
- Program documentation: `generate-doc` skill
- Impact analysis: `impact-analysis` skill
- Implementation plans: `implementation-planning` skill

**Manual Documentation**:
- Markdown for all documents
- Mermaid for diagrams
- PlantUML for complex UML
- Git for version control

### Documentation Standards

**File Naming**:
- Uppercase with hyphens: `SYSTEM-OVERVIEW-EXECUTIVE.md`
- Descriptive names: `CUSTOMER-ADD-COMPLETE-FLOW.md`
- Timestamps for versioned artifacts: `implementation-plan-20260605T030354Z.md`

**Structure**:
- Clear headings and sections
- Table of contents for long documents
- Cross-references with relative links
- Code examples with syntax highlighting
- Mermaid diagrams for flows

**Maintenance**:
- Update date in document header
- Version control via Git
- Review cycle: Quarterly
- Update triggers: Code changes, incidents, new features

---

## 📝 Contributing to Documentation

### When to Update Documentation

**MANDATORY Updates**:
- ✅ Code changes to any program
- ✅ New programs added
- ✅ Business rule changes
- ✅ Architecture changes
- ✅ After production incidents

**RECOMMENDED Updates**:
- New insights from troubleshooting
- Performance optimization discoveries
- Modernization experiments
- User feedback

### How to Update Documentation

1. **Identify Affected Documents**:
   - Use this index to find relevant docs
   - Check cross-references

2. **Make Updates**:
   - Follow existing format and style
   - Update "Last Updated" date
   - Add cross-references as needed

3. **Review**:
   - Peer review for technical accuracy
   - SME validation if available
   - Test examples and links

4. **Commit**:
   - Descriptive commit message
   - Link to related code changes
   - Update this index if needed

### Documentation Templates

**Program Documentation**:
- Use `generate-doc` skill for automation
- Template in [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md)

**Data Flow Documentation**:
- See [`data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md`](data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md) as example
- Include Mermaid sequence diagram
- Document error scenarios

**Impact Analysis**:
- Use Bob Z Architect Mode `impact-analysis` skill
- See examples in [`bobz/impact-analysis/`](../bobz/impact-analysis/)

**Implementation Plans**:
- Use Bob Z Architect Mode `implementation-planning` skill
- See examples in [`bobz/implementation-plans/`](../bobz/implementation-plans/)

---

## 🔗 External Resources

### IBM Documentation
- [CICS TS Documentation](https://www.ibm.com/docs/en/cics-ts/)
- [CICS Developer Center](https://developer.ibm.com/components/cics/)
- [Db2 for z/OS Documentation](https://www.ibm.com/docs/en/db2-for-zos/)

### GitHub Resources
- [CICS Samples Repository](https://github.com/cicsdev)
- [GenApp Repository](https://github.com/cicsdev/cics-genapp)

### Training Materials
- CICS Fundamentals
- COBOL Programming
- Db2 SQL
- z/OS System Programming

---

## 📞 Getting Help

### Documentation Questions

**Can't find what you need?**
1. Search this index by topic or question
2. Check the role-based quick access section
3. Review related documents via cross-references
4. Consult the team

**Documentation is incorrect?**
1. Create an issue or pull request
2. Contact the documentation team
3. Update directly if you have access

**Need new documentation?**
1. Check [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) roadmap
2. Request via team channels
3. Contribute if you have expertise

### Technical Support

**Development Questions**:
- Review [`AGENTS.md`](../AGENTS.md)
- Check program documentation
- Consult senior developers

**Operational Issues**:
- Check [`base/Reference.md`](../base/Reference.md)
- Review installation/build docs
- Contact operations team

**Architecture Decisions**:
- Review architecture documentation
- Check impact analysis examples
- Consult architects

---

## 📅 Documentation Roadmap

See [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) for the complete 14-week documentation roadmap including:

- **Phase 1** (Weeks 1-4): Critical program documentation
- **Phase 2** (Weeks 5-6): Data flows and integration
- **Phase 3** (Weeks 7-10): Remaining programs
- **Phase 4** (Weeks 11-12): Operational knowledge
- **Phase 5** (Weeks 13-14): Modernization enablement

---

## 🎯 Quick Links

### Most Frequently Accessed
1. [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md)
2. [`AGENTS.md`](../AGENTS.md)
3. [`BUSINESS_RULES.md`](BUSINESS_RULES.md)
4. [`bobz/DD.json`](../bobz/DD.json)
5. [`base/Architecture.md`](../base/Architecture.md)

### Recently Updated
1. [`KNOWLEDGE-RECOVERY-STRATEGY.md`](KNOWLEDGE-RECOVERY-STRATEGY.md) - 2026-06-24
2. [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - 2026-06-24
3. [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md) - 2026-06-24
4. [`data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md`](data-flows/CUSTOMER-ADD-COMPLETE-FLOW.md) - 2026-06-24
5. This index - 2026-06-24

### Essential for New Team Members
1. [`QUICK-START-GUIDE.md`](QUICK-START-GUIDE.md) - Start here!
2. [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) - Complete onboarding
3. [`SYSTEM-OVERVIEW-EXECUTIVE.md`](SYSTEM-OVERVIEW-EXECUTIVE.md) - Big picture
4. [`AGENTS.md`](../AGENTS.md) - Development rules
5. [`base/Architecture.md`](../base/Architecture.md) - Technical details

---

**Document Control**
- **Version**: 1.0
- **Created**: 2026-06-24
- **Last Updated**: 2026-06-24
- **Next Review**: 2026-07-24
- **Owner**: Documentation Team
- **Maintained By**: All contributors