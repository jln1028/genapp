# Institutional Knowledge Recovery & Documentation Strategy

## Executive Summary

This strategy addresses the critical institutional knowledge gap caused by developer attrition in the CICS General Insurance Application (GenApp). The goal is to transform this undocumented, high-risk legacy system into a well-understood asset that enables confident maintenance, accelerated onboarding, and de-risked modernization.

**Document Version**: 1.0  
**Last Updated**: 2026-06-24  
**Status**: Active Implementation Plan

---

## 1. Current State Assessment

### 1.1 Existing Documentation Strengths

✅ **Strong Foundation Already Exists:**
- Comprehensive [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md) with role-based learning paths
- Detailed [`REPOSITORY_STRUCTURE.md`](REPOSITORY_STRUCTURE.md) with 409 lines of structural analysis
- Well-maintained [`AGENTS.md`](../AGENTS.md) with architectural rules and program mappings
- Complete [`BUSINESS_RULES.md`](BUSINESS_RULES.md) cataloging validation and processing rules
- Technical documentation suite: Architecture, Installation, Building, Testing, Reference
- Data dictionary ([`bobz/DD.json`](../bobz/DD.json)) with 386 lines of variable context
- Impact analysis examples in [`bobz/impact-analysis/`](../bobz/impact-analysis/)
- Implementation plan examples in [`bobz/implementation-plans/`](../bobz/implementation-plans/)

### 1.2 Critical Documentation Gaps

❌ **Missing Knowledge Areas:**

1. **Program-Level Documentation** (CRITICAL)
   - Only 1 of 33 COBOL programs documented ([`LGACUS01.md`](program-documents/LGACUS01.md))
   - 32 programs lack comprehensive documentation
   - Missing: purpose, inputs, outputs, processing logic, error handling

2. **Cross-Program Data Flows** (HIGH)
   - Limited documentation of COMMAREA contracts between layers
   - Incomplete tracing of data transformations across program boundaries
   - Missing sequence diagrams for multi-program transactions

3. **Business Context** (HIGH)
   - Technical documentation exists but business rationale is scattered
   - Limited explanation of "why" decisions were made
   - Insufficient connection between code and business requirements

4. **Operational Knowledge** (MEDIUM)
   - Troubleshooting procedures incomplete
   - Performance tuning guidance missing
   - Production support runbooks absent

5. **Modernization Roadmap** (MEDIUM)
   - [`MODERNIZATION-ARCHITECTURE.md`](MODERNIZATION-ARCHITECTURE.md) exists but needs expansion
   - API enablement strategy incomplete
   - Cloud migration patterns not documented

### 1.3 Risk Assessment

| Risk Area | Current Risk Level | Impact if Not Addressed |
|-----------|-------------------|------------------------|
| **Program Understanding** | 🔴 CRITICAL | Cannot maintain or modify 97% of codebase confidently |
| **Onboarding Time** | 🟡 HIGH | 6-12 months for new developers vs. 2-3 months target |
| **Modernization Delays** | 🟡 HIGH | Cannot assess modernization feasibility or effort |
| **Production Incidents** | 🟡 HIGH | Extended MTTR due to knowledge gaps |
| **Technical Debt** | 🟢 MEDIUM | Well-structured code but undocumented decisions |

---

## 2. Documentation Strategy & Roadmap

### 2.1 Strategic Objectives

**Primary Goal**: Reconstruct institutional knowledge to enable confident maintenance and modernization

**Success Metrics**:
- ✅ 100% of COBOL programs have comprehensive documentation (32 remaining)
- ✅ New developer onboarding reduced from 6-12 months to 2-3 months
- ✅ 90% of common maintenance tasks can be performed without SME consultation
- ✅ Modernization feasibility assessments can be completed in days, not weeks
- ✅ Production incident MTTR reduced by 40%

### 2.2 Phased Implementation Approach

#### **Phase 1: Critical Program Documentation** (Weeks 1-4)
**Priority**: CRITICAL  
**Effort**: 80 hours

**Scope**: Document the 15 most critical programs that form the application backbone

**Programs to Document**:
1. **Presentation Layer** (5 programs)
   - `LGTESTC1` - Customer menu presentation
   - `LGTESTP1` - Motor policy presentation
   - `LGTESTP2` - Endowment policy presentation
   - `LGTESTP3` - House policy presentation
   - `LGTESTP4` - Commercial property presentation

2. **Business Logic Layer** (7 programs)
   - `LGACUS01` - ✅ Already documented
   - `LGICUS01` - Inquire customer business logic
   - `LGUCUS01` - Update customer business logic
   - `LGAPOL01` - Add policy business logic
   - `LGIPOL01` - Inquire policy business logic
   - `LGUPOL01` - Update policy business logic
   - `LGDPOL01` - Delete policy business logic

3. **Data Access Layer** (3 programs)
   - `LGACDB01` - Add customer to Db2
   - `LGAPDB01` - Add policy to Db2
   - `LGICDB01` - Retrieve customer from Db2

**Deliverables**:
- 14 comprehensive program documents in [`docs/program-documents/`](program-documents/)
- Each document includes: Purpose, Inputs, Outputs, Processing Logic, Dependencies, Error Handling, Examples

**Method**: Use `generate-doc` skill for programs <1000 lines

#### **Phase 2: Data Flow & Integration Documentation** (Weeks 5-6)
**Priority**: HIGH  
**Effort**: 40 hours

**Scope**: Document how data flows through the system and between programs

**Deliverables**:
1. **Transaction Flow Diagrams** (5 documents)
   - Customer Add Flow (SSC1 → LGTESTC1 → LGACUS01 → LGACDB01/LGACVS01)
   - Customer Inquiry Flow
   - Policy Add Flow (SSP1-4 → LGTESTP1-4 → LGAPOL01 → LGAPDB01/LGAPVS01)
   - Policy Update Flow
   - Policy Delete Flow

2. **COMMAREA Contract Documentation**
   - [`docs/COMMAREA-CONTRACTS.md`](COMMAREA-CONTRACTS.md) - Complete specification
   - Request routing logic (CA-REQUEST-ID patterns)
   - Length validation rules
   - Error code catalog

3. **Two-Phase Commit Documentation**
   - [`docs/TWO-PHASE-COMMIT-PATTERNS.md`](TWO-PHASE-COMMIT-PATTERNS.md)
   - Db2 + VSAM coordination
   - Rollback scenarios
   - Error recovery procedures

**Method**: Manual analysis with Mermaid sequence diagrams

#### **Phase 3: Remaining Program Documentation** (Weeks 7-10)
**Priority**: MEDIUM  
**Effort**: 80 hours

**Scope**: Document remaining 18 programs for complete coverage

**Programs**:
- Data Access Layer (12 programs): All remaining *DB01 and *VS01 programs
- Utility Programs (4 programs): LGSETUP, LGSTSQ, LGASTAT1, LGWEBST5
- Report Programs (1 program): LGCURPT1
- BMS Map (1 file): SSMAP

**Deliverables**:
- 18 additional program documents
- Complete program inventory with cross-references

#### **Phase 4: Operational & Troubleshooting Knowledge** (Weeks 11-12)
**Priority**: MEDIUM  
**Effort**: 40 hours

**Scope**: Capture operational knowledge for production support

**Deliverables**:
1. **Production Support Runbook** ([`docs/PRODUCTION-SUPPORT-RUNBOOK.md`](PRODUCTION-SUPPORT-RUNBOOK.md))
   - Common incident scenarios and resolutions
   - Error code reference guide
   - Temporary storage queue monitoring
   - Named counter troubleshooting
   - Db2 connection issues
   - VSAM file problems

2. **Performance Tuning Guide** ([`docs/PERFORMANCE-TUNING-GUIDE.md`](PERFORMANCE-TUNING-GUIDE.md))
   - Transaction response time baselines
   - Db2 query optimization
   - VSAM buffer tuning
   - CICS region sizing
   - Workload management configuration

3. **Monitoring & Alerting Guide** ([`docs/MONITORING-ALERTING-GUIDE.md`](MONITORING-ALERTING-GUIDE.md))
   - Key performance indicators
   - Alert thresholds
   - Dashboard configurations
   - Event processing setup

#### **Phase 5: Modernization Enablement** (Weeks 13-14)
**Priority**: MEDIUM  
**Effort**: 40 hours

**Scope**: Expand modernization documentation to support strategic initiatives

**Deliverables**:
1. **API Enablement Strategy** ([`docs/API-ENABLEMENT-STRATEGY.md`](API-ENABLEMENT-STRATEGY.md))
   - RESTful API design patterns
   - Web services expansion roadmap
   - Authentication/authorization approach
   - API versioning strategy

2. **Cloud Migration Patterns** ([`docs/CLOUD-MIGRATION-PATTERNS.md`](CLOUD-MIGRATION-PATTERNS.md))
   - Hybrid cloud architecture options
   - Data synchronization strategies
   - Containerization approach for CICS
   - DevOps pipeline design

3. **Refactoring Opportunities** (Expand existing [`REFACTORING_OPPORTUNITIES.md`](REFACTORING_OPPORTUNITIES.md))
   - Prioritized refactoring backlog
   - Technical debt quantification
   - Modernization ROI analysis

---

## 3. Documentation Standards & Templates

### 3.1 Program Documentation Template

**Location**: Use `generate-doc` skill for automated generation

**Required Sections**:
1. **Program Overview**
   - Purpose and business function
   - Layer (Presentation/Business/Data)
   - Transaction context

2. **Inputs**
   - COMMAREA structure
   - External data sources
   - Configuration parameters

3. **Outputs**
   - COMMAREA modifications
   - Database updates
   - File operations
   - Return codes

4. **Processing Logic**
   - Main processing flow
   - Decision points
   - Calculations
   - Business rules applied

5. **Paragraph/Section Descriptions**
   - Purpose of each paragraph
   - Key operations
   - Called programs

6. **Dependencies**
   - Called programs (LINK)
   - Copybooks (COPY)
   - Database tables
   - VSAM files
   - CICS resources

7. **Error Handling**
   - Error conditions
   - Return codes
   - Logging mechanisms
   - Recovery procedures

8. **Constraints & Limitations**
   - Performance considerations
   - Data volume limits
   - Known issues

9. **Examples**
   - Sample COMMAREA inputs
   - Expected outputs
   - Common scenarios

### 3.2 Data Flow Documentation Template

**Format**: Mermaid sequence diagrams + narrative

**Required Elements**:
- Transaction entry point
- Program call sequence
- Data transformations
- Database operations
- Error paths
- Return flow

### 3.3 Documentation Maintenance Rules

**Update Triggers**:
- ✅ Any code change to a program requires documentation update
- ✅ New programs require documentation before production deployment
- ✅ Business rule changes require BUSINESS_RULES.md update
- ✅ Architecture changes require Architecture.md update

**Review Cycle**:
- Quarterly documentation review for accuracy
- Annual comprehensive documentation audit
- Post-incident documentation updates within 48 hours

---

## 4. Knowledge Transfer Mechanisms

### 4.1 Onboarding Acceleration

**Enhanced Onboarding Path** (Target: 2-3 months):

**Week 1-2: Foundation**
- Read [`ONBOARDING_GUIDE.md`](ONBOARDING_GUIDE.md)
- Review [`REPOSITORY_STRUCTURE.md`](REPOSITORY_STRUCTURE.md)
- Study [`base/Architecture.md`](../base/Architecture.md)
- Complete installation and testing exercises

**Week 3-4: Core Programs**
- Study 5 presentation layer programs
- Study 7 business logic programs
- Trace 2 complete transaction flows
- Make supervised code change

**Week 5-6: Data Layer**
- Study data access programs
- Understand two-phase commit
- Review Db2 schema and VSAM structures
- Debug production-like scenario

**Week 7-8: Advanced Topics**
- Web services integration
- Event processing
- CICSPlex SM configuration
- Performance tuning basics

**Week 9-12: Supervised Development**
- Implement small feature with mentor
- Participate in code reviews
- Handle simulated production incident
- Document new knowledge

### 4.2 Knowledge Sharing Practices

**Weekly Knowledge Sessions** (1 hour):
- Rotate presenter among team members
- Deep dive into one program or subsystem
- Document insights in shared wiki
- Record sessions for future reference

**Code Review Standards**:
- Every change requires documentation review
- Reviewers verify business context is clear
- New patterns must be documented
- Technical decisions require rationale

**Incident Post-Mortems**:
- Document root cause analysis
- Update troubleshooting guides
- Enhance monitoring if needed
- Share lessons learned

### 4.3 SME Knowledge Capture

**Immediate Actions** (If SMEs still available):
- Schedule knowledge transfer sessions
- Record video walkthroughs of complex areas
- Document tribal knowledge in appropriate guides
- Create decision logs for architectural choices

**Ongoing Practices**:
- Pair programming with junior developers
- Code annotation sessions
- Architecture decision records (ADRs)
- Business context workshops

---

## 5. Tool & Automation Strategy

### 5.1 Documentation Generation Tools

**Primary Tool**: Bob Z Architect Mode with `generate-doc` skill
- Automated program documentation for programs <1000 lines
- Consistent format and structure
- Integrated with data dictionary
- Markdown output for version control

**Supplementary Tools**:
- Mermaid for diagrams (sequence, flow, architecture)
- PlantUML for complex UML diagrams
- Markdown for all documentation
- Git for version control

### 5.2 Documentation Repository Structure

```
docs/
├── KNOWLEDGE-RECOVERY-STRATEGY.md (this document)
├── ONBOARDING_GUIDE.md (existing, enhanced)
├── REPOSITORY_STRUCTURE.md (existing)
├── BUSINESS_RULES.md (existing, maintained)
├── program-documents/
│   ├── LGACUS01.md (existing)
│   ├── LGTESTC1.md (new - Phase 1)
│   ├── LGICUS01.md (new - Phase 1)
│   └── [32 more programs...]
├── data-flows/
│   ├── CUSTOMER-ADD-FLOW.md (new - Phase 2)
│   ├── CUSTOMER-INQUIRY-FLOW.md (new - Phase 2)
│   ├── POLICY-ADD-FLOW.md (new - Phase 2)
│   └── [more flows...]
├── operational/
│   ├── PRODUCTION-SUPPORT-RUNBOOK.md (new - Phase 4)
│   ├── PERFORMANCE-TUNING-GUIDE.md (new - Phase 4)
│   └── MONITORING-ALERTING-GUIDE.md (new - Phase 4)
├── modernization/
│   ├── MODERNIZATION-ARCHITECTURE.md (existing, expand)
│   ├── API-ENABLEMENT-STRATEGY.md (new - Phase 5)
│   └── CLOUD-MIGRATION-PATTERNS.md (new - Phase 5)
└── technical/
    ├── COMMAREA-CONTRACTS.md (new - Phase 2)
    ├── TWO-PHASE-COMMIT-PATTERNS.md (new - Phase 2)
    └── ERROR-CODE-REFERENCE.md (new - Phase 4)
```

### 5.3 Continuous Documentation

**Integration Points**:
- Pre-commit hooks validate documentation updates
- CI/CD pipeline checks for documentation completeness
- Pull request templates require documentation section
- Automated link checking for cross-references

---

## 6. Success Metrics & Tracking

### 6.1 Documentation Coverage Metrics

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Programs Documented | 3% (1/33) | 100% (33/33) | Week 10 |
| Transaction Flows Documented | 20% (1/5) | 100% (5/5) | Week 6 |
| Business Rules Cataloged | 60% | 100% | Week 6 |
| Operational Runbooks | 0% | 100% | Week 12 |
| Modernization Guides | 40% | 100% | Week 14 |

### 6.2 Knowledge Transfer Metrics

| Metric | Baseline | Target | Timeline |
|--------|----------|--------|----------|
| Onboarding Time | 6-12 months | 2-3 months | Week 8 |
| SME Dependency | 80% | 20% | Week 12 |
| Code Change Confidence | Low | High | Week 10 |
| Incident MTTR | Baseline | -40% | Week 14 |
| Documentation Accuracy | N/A | 95%+ | Ongoing |

### 6.3 Business Impact Metrics

| Metric | Expected Impact | Measurement |
|--------|----------------|-------------|
| **Maintenance Velocity** | +50% faster changes | Story points per sprint |
| **Defect Rate** | -30% production defects | Defects per release |
| **Modernization Readiness** | Feasibility assessments in days | Assessment cycle time |
| **Team Productivity** | +40% developer productivity | Velocity trends |
| **Risk Reduction** | 80% reduction in knowledge risk | Risk assessment score |

---

## 7. Implementation Plan

### 7.1 Resource Requirements

**Team Composition**:
- 1 Technical Lead (20% allocation) - Strategy oversight
- 2 Senior Developers (50% allocation) - Documentation creation
- 1 Technical Writer (optional, 25% allocation) - Quality review
- SMEs (as available) - Knowledge validation

**Tools & Infrastructure**:
- Bob Z Architect Mode with generate-doc skill
- Git repository for version control
- Markdown editors
- Diagram tools (Mermaid, PlantUML)
- Documentation review process

### 7.2 Weekly Execution Plan

**Weeks 1-4: Critical Programs**
- Week 1: Presentation layer (5 programs)
- Week 2: Business logic layer part 1 (4 programs)
- Week 3: Business logic layer part 2 (3 programs)
- Week 4: Data access layer (3 programs)

**Weeks 5-6: Data Flows**
- Week 5: Transaction flows and COMMAREA contracts
- Week 6: Two-phase commit and integration patterns

**Weeks 7-10: Remaining Programs**
- Week 7-8: Data access programs (12 programs)
- Week 9: Utility programs (4 programs)
- Week 10: Reports and BMS maps (2 items)

**Weeks 11-12: Operations**
- Week 11: Production support and troubleshooting
- Week 12: Performance tuning and monitoring

**Weeks 13-14: Modernization**
- Week 13: API enablement strategy
- Week 14: Cloud migration patterns and final review

### 7.3 Quality Gates

**Phase Completion Criteria**:
- ✅ All planned documents created
- ✅ Peer review completed
- ✅ SME validation (if available)
- ✅ Cross-reference links verified
- ✅ Examples tested and validated
- ✅ Integrated into onboarding materials

**Documentation Quality Standards**:
- Clear, concise language
- Accurate technical details
- Complete cross-references
- Tested examples
- Proper formatting
- Version controlled

---

## 8. Risk Mitigation

### 8.1 Identified Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **SME Unavailability** | High | High | Prioritize critical programs first; use code analysis tools |
| **Documentation Drift** | Medium | High | Implement automated checks; enforce update policies |
| **Resource Constraints** | Medium | Medium | Phase approach allows flexibility; automate where possible |
| **Incomplete Knowledge** | Medium | High | Document unknowns; create investigation backlog |
| **Tool Limitations** | Low | Medium | Manual documentation for complex cases; multiple tools |

### 8.2 Contingency Plans

**If SMEs Leave Before Completion**:
- Accelerate Phase 1 (critical programs)
- Increase use of automated documentation tools
- Leverage code analysis and reverse engineering
- Document assumptions and unknowns explicitly

**If Timeline Slips**:
- Prioritize critical path items
- Reduce scope of nice-to-have documentation
- Increase team allocation temporarily
- Extend timeline with stakeholder approval

**If Quality Issues Arise**:
- Implement additional review cycles
- Engage external technical writers
- Conduct documentation testing with new developers
- Iterate based on feedback

---

## 9. Long-Term Sustainability

### 9.1 Documentation Governance

**Ownership Model**:
- **Technical Lead**: Overall documentation strategy and quality
- **Development Team**: Program-level documentation maintenance
- **Architects**: Architecture and design documentation
- **Operations**: Operational runbooks and troubleshooting guides

**Review Cadence**:
- **Quarterly**: Documentation accuracy review
- **Annual**: Comprehensive documentation audit
- **Post-Incident**: Immediate updates to relevant guides
- **Post-Release**: Documentation updates for new features

### 9.2 Continuous Improvement

**Feedback Mechanisms**:
- New developer onboarding surveys
- Documentation usefulness ratings
- Incident analysis for documentation gaps
- Regular team retrospectives

**Evolution Strategy**:
- Incorporate new patterns and practices
- Retire obsolete documentation
- Enhance based on user feedback
- Adapt to technology changes

### 9.3 Knowledge Preservation

**Backup & Redundancy**:
- Git repository with multiple remotes
- Regular documentation exports
- Knowledge distribution across team
- Cross-training programs

**Succession Planning**:
- Rotate documentation ownership
- Pair programming for knowledge transfer
- Mentorship programs
- Documentation champions in each area

---

## 10. Next Steps & Quick Wins

### 10.1 Immediate Actions (Week 1)

1. **Approve Strategy** ✅
   - Review this document with stakeholders
   - Secure resource commitments
   - Set success metrics baseline

2. **Start Phase 1** 🚀
   - Document `LGTESTC1` (customer menu presentation)
   - Document `LGICUS01` (inquire customer business logic)
   - Document `LGACDB01` (add customer to Db2)

3. **Setup Infrastructure**
   - Create documentation directory structure
   - Configure Bob Z Architect Mode
   - Establish review process

### 10.2 Quick Wins (Weeks 1-2)

**High-Impact, Low-Effort Deliverables**:
1. **Error Code Reference** - Catalog all CA-RETURN-CODE values
2. **Transaction Quick Reference** - One-page guide to all transactions
3. **COMMAREA Field Guide** - Quick reference for common fields
4. **Troubleshooting Checklist** - Top 10 common issues and fixes

### 10.3 Communication Plan

**Stakeholder Updates**:
- Weekly progress reports to management
- Bi-weekly demos of new documentation
- Monthly metrics dashboard
- Quarterly strategy review

**Team Communication**:
- Daily standup documentation status
- Weekly knowledge sharing sessions
- Documentation showcase meetings
- Celebration of milestones

---

## 11. Conclusion

This strategy transforms the CICS General Insurance Application from a high-risk, undocumented legacy system into a well-understood, maintainable asset. By systematically documenting all 33 programs, capturing data flows, preserving operational knowledge, and enabling modernization, we will:

✅ **Reduce Risk**: Eliminate single points of failure in knowledge  
✅ **Accelerate Onboarding**: Cut new developer ramp-up time by 60-75%  
✅ **Enable Modernization**: Provide foundation for confident refactoring and API enablement  
✅ **Improve Operations**: Reduce incident resolution time by 40%  
✅ **Preserve Knowledge**: Create sustainable documentation practices

**The time to act is now.** With each passing day, institutional knowledge continues to erode. This 14-week program provides a clear path to knowledge recovery and long-term sustainability.

---

## Appendix A: Documentation Checklist

### Program Documentation Checklist
- [ ] Program overview and purpose
- [ ] Business function description
- [ ] Input specifications (COMMAREA, files, DB)
- [ ] Output specifications (COMMAREA, files, DB)
- [ ] Processing logic flow
- [ ] Paragraph/section descriptions
- [ ] Dependencies (programs, copybooks, resources)
- [ ] Error handling and return codes
- [ ] Constraints and limitations
- [ ] Usage examples
- [ ] Cross-references to related docs
- [ ] Data dictionary integration
- [ ] Peer review completed
- [ ] SME validation (if available)

### Data Flow Documentation Checklist
- [ ] Transaction entry point identified
- [ ] Program call sequence documented
- [ ] Data transformations mapped
- [ ] Database operations listed
- [ ] Error paths documented
- [ ] Sequence diagram created
- [ ] COMMAREA contracts specified
- [ ] Return flow documented
- [ ] Examples provided
- [ ] Cross-references complete

### Operational Documentation Checklist
- [ ] Common scenarios documented
- [ ] Error codes cataloged
- [ ] Troubleshooting steps provided
- [ ] Monitoring procedures defined
- [ ] Alert thresholds specified
- [ ] Recovery procedures documented
- [ ] Performance baselines established
- [ ] Escalation paths defined
- [ ] Contact information current
- [ ] Tested with operations team

---

## Appendix B: Key Contacts & Resources

### Documentation Team
- **Technical Lead**: [Name] - Strategy and oversight
- **Senior Developer 1**: [Name] - Program documentation
- **Senior Developer 2**: [Name] - Data flow documentation
- **Technical Writer**: [Name] - Quality review (optional)

### Subject Matter Experts
- **CICS Architecture**: [Name/Contact]
- **Db2 Integration**: [Name/Contact]
- **Business Logic**: [Name/Contact]
- **Operations**: [Name/Contact]

### Tools & Resources
- **Bob Z Architect Mode**: Documentation generation
- **Git Repository**: [URL]
- **Documentation Wiki**: [URL]
- **Training Materials**: [Location]

---

**Document Control**
- **Version**: 1.0
- **Created**: 2026-06-24
- **Last Updated**: 2026-06-24
- **Next Review**: 2026-07-24
- **Owner**: Technical Lead
- **Status**: Active Implementation Plan