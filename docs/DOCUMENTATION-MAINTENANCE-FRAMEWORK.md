# Documentation Maintenance Framework

## Purpose

This framework establishes sustainable practices for maintaining accurate, up-to-date documentation for the CICS General Insurance Application (GenApp). It defines roles, responsibilities, processes, and quality standards to ensure documentation remains a valuable asset rather than becoming outdated technical debt.

**Version**: 1.0  
**Last Updated**: 2026-06-24  
**Owner**: Technical Lead  
**Status**: Active

---

## 1. Governance Model

### 1.1 Roles & Responsibilities

#### Documentation Owner (Technical Lead)
**Responsibilities**:
- Overall documentation strategy and quality
- Quarterly documentation reviews
- Resource allocation for documentation work
- Escalation point for documentation issues
- Approval of major documentation changes

**Time Commitment**: 20% allocation

#### Program Documentation Owners (Development Team)
**Responsibilities**:
- Maintain documentation for assigned programs
- Update docs when code changes
- Respond to documentation issues
- Participate in peer reviews
- Ensure examples are tested

**Assignment**: Each developer owns 3-5 programs

**Time Commitment**: 10% allocation

#### Architecture Documentation Owner (Lead Architect)
**Responsibilities**:
- Maintain architecture documentation
- Update design decisions
- Review impact analyses
- Approve architectural changes
- Ensure consistency across docs

**Time Commitment**: 15% allocation

#### Operations Documentation Owner (Operations Lead)
**Responsibilities**:
- Maintain operational runbooks
- Update troubleshooting guides
- Document production incidents
- Review monitoring procedures
- Ensure operational accuracy

**Time Commitment**: 10% allocation

#### Documentation Reviewers (All Team Members)
**Responsibilities**:
- Peer review documentation changes
- Validate technical accuracy
- Test examples and procedures
- Provide feedback on clarity
- Suggest improvements

**Time Commitment**: 5% allocation

### 1.2 Documentation Champions

**Purpose**: Promote documentation culture and best practices

**Selection**: Volunteer or rotate quarterly

**Responsibilities**:
- Advocate for documentation quality
- Share best practices
- Mentor team members
- Organize documentation sessions
- Track metrics and improvements

**Recognition**: Acknowledged in team meetings, performance reviews

---

## 2. Update Triggers & Workflows

### 2.1 Mandatory Update Triggers

#### Code Changes
**Trigger**: Any modification to COBOL programs, copybooks, or JCL

**Workflow**:
1. Developer makes code change
2. Developer updates affected documentation
3. Documentation included in pull request
4. Reviewer validates both code and docs
5. Merge only if both approved

**Affected Documents**:
- Program documentation
- Data flow diagrams
- Business rules catalog
- Data dictionary
- Architecture docs (if applicable)

**Timeline**: Same commit/PR as code change

#### New Programs
**Trigger**: Addition of new COBOL program, copybook, or JCL

**Workflow**:
1. Developer creates new program
2. Developer generates documentation using `generate-doc` skill
3. Developer adds cross-references
4. Documentation reviewed before production
5. Added to documentation index

**Affected Documents**:
- New program document
- Call graphs
- Data flows
- Transaction routing
- Documentation index

**Timeline**: Before production deployment

#### Business Rule Changes
**Trigger**: Modification to validation, calculation, or processing logic

**Workflow**:
1. Developer identifies business rule change
2. Developer updates BUSINESS_RULES.md
3. Developer updates affected program docs
4. Business analyst validates accuracy
5. Merge with code change

**Affected Documents**:
- BUSINESS_RULES.md
- Program documentation
- Data flow documentation

**Timeline**: Same commit/PR as code change

#### Architecture Changes
**Trigger**: Changes to system design, integration patterns, or technology stack

**Workflow**:
1. Architect proposes change
2. Architect updates architecture docs
3. Architect creates/updates diagrams
4. Team reviews and approves
5. Implementation updates program docs

**Affected Documents**:
- Architecture.md
- SYSTEM-ARCHITECTURE-DIAGRAM.md
- MODERNIZATION-ARCHITECTURE.md
- Affected program docs

**Timeline**: Before implementation begins

#### Production Incidents
**Trigger**: Any production issue requiring investigation

**Workflow**:
1. Incident resolved
2. Root cause analysis completed
3. Operations updates runbooks within 48 hours
4. Troubleshooting guides updated
5. Monitoring/alerting adjusted if needed

**Affected Documents**:
- Production runbooks
- Troubleshooting guides
- Monitoring guides
- Program docs (if code issue)

**Timeline**: Within 48 hours of resolution

### 2.2 Recommended Update Triggers

#### New Insights
**Trigger**: Discovery of undocumented behavior or patterns

**Workflow**:
1. Team member identifies insight
2. Team member documents finding
3. Adds to appropriate document
4. Shares in team meeting
5. Peer review validates

**Timeline**: Within 1 week of discovery

#### User Feedback
**Trigger**: Documentation confusion or errors reported

**Workflow**:
1. Feedback received
2. Documentation owner investigates
3. Updates documentation
4. Notifies feedback provider
5. Tracks in metrics

**Timeline**: Within 2 weeks of feedback

#### Technology Updates
**Trigger**: CICS, Db2, or COBOL version changes

**Workflow**:
1. Technology upgrade planned
2. Documentation owner reviews impact
3. Updates affected documentation
4. Validates examples still work
5. Publishes updated docs

**Timeline**: Before or during upgrade

---

## 3. Review Cycles

### 3.1 Quarterly Documentation Review

**Frequency**: Every 3 months

**Scope**: All documentation

**Process**:
1. **Week 1**: Documentation owner assigns review sections
2. **Week 2-3**: Team members review assigned sections
3. **Week 4**: Consolidate findings and prioritize updates
4. **Week 5-6**: Execute high-priority updates

**Review Checklist**:
- [ ] Technical accuracy verified
- [ ] Examples tested and working
- [ ] Cross-references valid
- [ ] Screenshots/diagrams current
- [ ] No broken links
- [ ] Consistent formatting
- [ ] Clear and concise language
- [ ] Appropriate detail level

**Output**: Review report with action items

### 3.2 Annual Documentation Audit

**Frequency**: Annually

**Scope**: Complete documentation suite

**Process**:
1. **Month 1**: External review (if possible) or comprehensive internal review
2. **Month 2**: Gap analysis and improvement plan
3. **Month 3**: Execute improvements
4. **Month 4**: Validate and publish

**Audit Criteria**:
- Coverage completeness (all programs documented)
- Accuracy (matches current code)
- Usability (new team members can understand)
- Consistency (follows standards)
- Maintainability (easy to update)

**Output**: Audit report and improvement roadmap

### 3.3 Post-Release Documentation Review

**Frequency**: After each major release

**Scope**: All documentation affected by release

**Process**:
1. Identify documentation changes in release
2. Validate all updates were made
3. Test all examples
4. Update version numbers
5. Publish release notes

**Timeline**: Within 1 week of release

---

## 4. Quality Standards

### 4.1 Documentation Quality Criteria

#### Accuracy
- ✅ Matches current code implementation
- ✅ Examples are tested and working
- ✅ Technical details are correct
- ✅ No outdated information

#### Completeness
- ✅ All required sections present
- ✅ Sufficient detail for target audience
- ✅ Edge cases documented
- ✅ Error scenarios covered

#### Clarity
- ✅ Clear, concise language
- ✅ Appropriate technical level
- ✅ Well-organized structure
- ✅ Good use of examples

#### Consistency
- ✅ Follows documentation standards
- ✅ Consistent terminology
- ✅ Uniform formatting
- ✅ Standard structure

#### Maintainability
- ✅ Easy to update
- ✅ Clear ownership
- ✅ Version controlled
- ✅ Cross-referenced appropriately

### 4.2 Documentation Standards

#### File Naming
```
UPPERCASE-WITH-HYPHENS.md
program-name.md (lowercase for programs)
feature-name-YYYYMMDDTHHMMSSZ.md (timestamped artifacts)
```

#### Document Structure
```markdown
# Title

## Overview
Brief description, purpose, audience

## Table of Contents (for long docs)

## Main Sections
Clear headings, logical flow

## Examples
Tested, working examples

## Related Documentation
Cross-references

## Document Control
Version, dates, owner
```

#### Markdown Standards
- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language identifiers
- Use tables for structured data
- Use Mermaid for diagrams
- Use relative links for cross-references
- Use bullet points for lists
- Use bold for emphasis, not italics

#### Code Examples
```cobol
* Always include context
* Use actual program names
* Test before documenting
* Include expected output
* Explain non-obvious parts
```

#### Diagrams
- Use Mermaid for sequence, flow, and architecture diagrams
- Include alt text for accessibility
- Keep diagrams simple and focused
- Update diagrams when code changes

### 4.3 Quality Gates

#### Pre-Commit
- [ ] Documentation updated for code changes
- [ ] Examples tested
- [ ] Cross-references added
- [ ] Formatting validated

#### Pull Request
- [ ] Documentation reviewed by peer
- [ ] Technical accuracy validated
- [ ] Clarity assessed
- [ ] Standards compliance checked

#### Pre-Production
- [ ] All documentation complete
- [ ] Examples work in test environment
- [ ] Operational docs updated
- [ ] Release notes prepared

#### Post-Production
- [ ] Documentation matches production
- [ ] Runbooks validated
- [ ] Monitoring docs current
- [ ] Incident procedures tested

---

## 5. Tools & Automation

### 5.1 Documentation Generation

#### Bob Z Architect Mode
**Use Cases**:
- Generate program documentation (`generate-doc` skill)
- Create impact analyses (`impact-analysis` skill)
- Develop implementation plans (`implementation-planning` skill)

**Process**:
1. Identify program/change to document
2. Use appropriate skill
3. Review and enhance generated content
4. Add to repository

**Benefits**:
- Consistent format
- Comprehensive coverage
- Integrated with data dictionary
- Faster than manual documentation

#### Manual Documentation
**Use Cases**:
- Complex programs (>1000 lines)
- Architecture documentation
- Operational runbooks
- Strategic documents

**Process**:
1. Use template from KNOWLEDGE-RECOVERY-STRATEGY.md
2. Follow documentation standards
3. Include diagrams and examples
4. Peer review before publishing

### 5.2 Validation Automation

#### Pre-Commit Hooks
```bash
# Check for documentation updates
if [[ $(git diff --name-only | grep '\.cbl$') ]]; then
    echo "COBOL files changed - documentation update required"
    # Check for corresponding .md updates
fi

# Validate markdown syntax
markdownlint docs/**/*.md

# Check for broken links
markdown-link-check docs/**/*.md
```

#### CI/CD Pipeline
```yaml
documentation-check:
  stage: validate
  script:
    - Check documentation completeness
    - Validate markdown syntax
    - Test code examples
    - Check cross-references
    - Generate coverage report
  artifacts:
    reports:
      documentation-coverage
```

#### Automated Metrics
- Documentation coverage percentage
- Documentation age (days since last update)
- Broken link count
- Example test pass rate
- Review completion rate

### 5.3 Version Control

#### Git Workflow
```bash
# Documentation changes in same commit as code
git add src/lgacus01.cbl docs/program-documents/LGACUS01.md
git commit -m "feat: Add customer validation logic

- Enhanced input validation in LGACUS01
- Updated program documentation
- Added validation examples"

# Documentation-only changes
git add docs/BUSINESS_RULES.md
git commit -m "docs: Update customer validation rules

- Clarified postcode format requirements
- Added validation error codes
- Updated examples"
```

#### Branch Strategy
- Documentation updates in same branch as code changes
- Documentation-only changes in `docs/*` branches
- Major documentation initiatives in feature branches

#### Commit Message Standards
```
<type>: <subject>

<body>

<footer>

Types:
- docs: Documentation only changes
- feat: New feature (includes docs)
- fix: Bug fix (includes docs)
- refactor: Code refactoring (includes docs)
```

---

## 6. Metrics & Tracking

### 6.1 Documentation Health Metrics

#### Coverage Metrics
| Metric | Target | Current | Trend |
|--------|--------|---------|-------|
| Programs Documented | 100% | 3% | 📈 |
| Data Flows Documented | 100% | 100% | ✅ |
| Business Rules Cataloged | 100% | 60% | 📈 |
| Operational Runbooks | 100% | 0% | 🔴 |
| Architecture Docs | 100% | 100% | ✅ |

#### Quality Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| Documentation Accuracy | 95%+ | Quarterly review score |
| Example Test Pass Rate | 100% | Automated testing |
| Broken Link Count | 0 | Automated checking |
| Average Doc Age | <90 days | Git commit dates |
| Review Completion | 100% | Quarterly review tracking |

#### Usage Metrics
| Metric | Measurement |
|--------|-------------|
| Documentation Views | Git analytics |
| Search Queries | Internal wiki analytics |
| Feedback Submissions | Issue tracker |
| Onboarding Time | New hire surveys |
| SME Dependency | Support ticket analysis |

### 6.2 Tracking Dashboard

**Weekly Metrics**:
- Documentation updates this week
- Pull requests with documentation
- Documentation issues opened/closed
- Broken links detected/fixed

**Monthly Metrics**:
- Documentation coverage change
- Average documentation age
- Review completion rate
- User feedback summary

**Quarterly Metrics**:
- Comprehensive coverage report
- Quality assessment scores
- Onboarding time trends
- SME dependency trends

### 6.3 Reporting

#### Weekly Status Report
```markdown
# Documentation Status - Week of YYYY-MM-DD

## Updates This Week
- 3 programs documented
- 2 data flows updated
- 1 business rule added

## Issues
- 2 broken links fixed
- 1 accuracy issue resolved

## Next Week
- Continue Phase 1 program documentation
- Quarterly review preparation
```

#### Quarterly Review Report
```markdown
# Documentation Quarterly Review - Q# YYYY

## Coverage Summary
- Programs: X% complete
- Data Flows: Y% complete
- Business Rules: Z% complete

## Quality Assessment
- Accuracy: A%
- Completeness: B%
- Clarity: C%

## Action Items
1. High priority updates
2. Medium priority updates
3. Low priority updates

## Next Quarter Goals
- Target coverage improvements
- Quality initiatives
- Process improvements
```

---

## 7. Training & Onboarding

### 7.1 Documentation Training

#### New Team Member Training
**Duration**: 2 hours

**Curriculum**:
1. Documentation philosophy and importance (15 min)
2. Documentation structure and index (15 min)
3. Finding information quickly (15 min)
4. Documentation standards (30 min)
5. Update workflows (30 min)
6. Tools and automation (15 min)

**Materials**:
- DOCUMENTATION-INDEX.md
- DOCUMENTATION-MAINTENANCE-FRAMEWORK.md
- KNOWLEDGE-RECOVERY-STRATEGY.md
- Hands-on exercises

#### Documentation Champion Training
**Duration**: 4 hours

**Curriculum**:
1. Advanced documentation techniques (1 hr)
2. Quality assessment (1 hr)
3. Review processes (1 hr)
4. Mentoring and coaching (1 hr)

**Materials**:
- All documentation standards
- Review checklists
- Mentoring guidelines
- Best practices

### 7.2 Continuous Learning

#### Monthly Documentation Sessions
**Duration**: 1 hour

**Topics** (rotating):
- Documentation best practices
- Tool demonstrations
- Quality improvement techniques
- Lessons learned sharing
- New documentation features

**Format**:
- 20 min presentation
- 20 min discussion
- 20 min hands-on practice

#### Documentation Showcase
**Frequency**: Quarterly

**Purpose**: Celebrate documentation achievements

**Activities**:
- Highlight excellent documentation examples
- Share before/after improvements
- Recognize documentation champions
- Discuss metrics and progress

---

## 8. Continuous Improvement

### 8.1 Feedback Mechanisms

#### Documentation Feedback Form
**Location**: Each document footer

**Questions**:
- Was this document helpful? (Yes/No)
- What could be improved?
- What's missing?
- Rate accuracy (1-5)
- Rate clarity (1-5)

**Process**:
1. User submits feedback
2. Documentation owner reviews
3. Updates prioritized
4. User notified of changes

#### New Developer Surveys
**Timing**: After 30, 60, 90 days

**Questions**:
- Which documents were most helpful?
- Which documents were confusing?
- What documentation is missing?
- How can we improve onboarding?
- Rate overall documentation quality (1-10)

**Process**:
1. Survey responses collected
2. Patterns identified
3. Improvements prioritized
4. Changes implemented

#### Incident Post-Mortems
**Trigger**: After each production incident

**Documentation Review**:
- Was documentation accurate?
- Was documentation complete?
- Could better docs have prevented incident?
- What documentation updates are needed?

**Process**:
1. Incident resolved
2. Post-mortem conducted
3. Documentation gaps identified
4. Updates made within 48 hours

### 8.2 Process Improvements

#### Retrospectives
**Frequency**: Quarterly

**Focus**: Documentation processes

**Questions**:
- What's working well?
- What's not working?
- What should we try?
- What should we stop doing?

**Output**: Process improvement action items

#### Benchmarking
**Frequency**: Annually

**Activities**:
- Review industry best practices
- Compare with other projects
- Identify improvement opportunities
- Adopt proven techniques

#### Experimentation
**Approach**: Try new techniques on small scale

**Examples**:
- New documentation formats
- Different diagram tools
- Alternative review processes
- Enhanced automation

**Evaluation**: Measure impact before full adoption

---

## 9. Success Criteria

### 9.1 Short-Term Success (3 months)

✅ **Documentation Coverage**:
- 50% of programs documented
- All critical programs documented
- Core data flows documented

✅ **Process Adoption**:
- 90% of code changes include documentation updates
- All team members trained
- Review process established

✅ **Quality Improvement**:
- Documentation accuracy >90%
- Zero broken links
- All examples tested

### 9.2 Medium-Term Success (6 months)

✅ **Documentation Coverage**:
- 80% of programs documented
- All data flows documented
- Operational runbooks complete

✅ **Process Maturity**:
- Automated validation in CI/CD
- Quarterly reviews completed
- Metrics dashboard operational

✅ **Business Impact**:
- Onboarding time reduced by 40%
- SME dependency reduced by 50%
- Incident MTTR reduced by 30%

### 9.3 Long-Term Success (12 months)

✅ **Documentation Coverage**:
- 100% of programs documented
- Complete documentation suite
- All gaps addressed

✅ **Process Excellence**:
- Documentation culture established
- Continuous improvement active
- Industry best practices adopted

✅ **Business Value**:
- Onboarding time reduced by 60-75%
- SME dependency reduced by 80%
- Incident MTTR reduced by 40%
- Confident modernization planning

---

## 10. Appendices

### Appendix A: Documentation Checklist

**Program Documentation**:
- [ ] Program overview and purpose
- [ ] Business function description
- [ ] Input specifications
- [ ] Output specifications
- [ ] Processing logic flow
- [ ] Paragraph descriptions
- [ ] Dependencies documented
- [ ] Error handling documented
- [ ] Constraints listed
- [ ] Examples provided
- [ ] Cross-references added
- [ ] Data dictionary integrated
- [ ] Peer reviewed
- [ ] SME validated (if available)

**Data Flow Documentation**:
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

**Operational Documentation**:
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

### Appendix B: Review Checklist

**Technical Accuracy**:
- [ ] Code matches documentation
- [ ] Examples work as described
- [ ] Technical details correct
- [ ] No outdated information

**Completeness**:
- [ ] All required sections present
- [ ] Sufficient detail provided
- [ ] Edge cases covered
- [ ] Error scenarios documented

**Clarity**:
- [ ] Clear, concise language
- [ ] Appropriate technical level
- [ ] Well-organized structure
- [ ] Good use of examples

**Consistency**:
- [ ] Follows documentation standards
- [ ] Consistent terminology
- [ ] Uniform formatting
- [ ] Standard structure

**Maintainability**:
- [ ] Easy to update
- [ ] Clear ownership
- [ ] Version controlled
- [ ] Cross-referenced appropriately

### Appendix C: Contact Information

**Documentation Owner**: [Name/Email]  
**Architecture Owner**: [Name/Email]  
**Operations Owner**: [Name/Email]  
**Documentation Champions**: [Names/Emails]

**Support Channels**:
- Documentation Issues: [Issue Tracker URL]
- Questions: [Team Channel]
- Feedback: [Feedback Form URL]

---

**Document Control**
- **Version**: 1.0
- **Created**: 2026-06-24
- **Last Updated**: 2026-06-24
- **Next Review**: 2026-09-24
- **Owner**: Technical Lead
- **Status**: Active