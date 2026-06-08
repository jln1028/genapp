# Refactoring Opportunities Analysis

**Generated:** 2026-06-05  
**Analysis Type:** Local Database Analysis  
**Application:** CICS GenApp - General Insurance Application

---

## Executive Summary

Based on comprehensive analysis of your CICS GenApp application, I've identified **8 major refactoring opportunities** across code structure, architecture patterns, and maintainability. The application demonstrates good layered architecture but has significant code duplication and inconsistent error handling that could be improved.

### Key Findings
- **31 COBOL programs** analyzed
- **8 program families** with similar patterns (CRUD operations)
- **High code duplication** across similar operations (Add, Inquire, Update, Delete)
- **Inconsistent error handling** - 10 programs lack error logging
- **Dual persistence pattern** creates maintenance overhead
- **Tight coupling** through LGSTSQ utility (called by 20 programs)

---

## 1. Code Duplication in CRUD Program Families

### 🔴 Priority: HIGH | Impact: HIGH | Effort: MEDIUM

### Current State
The application has **8 program families** performing similar CRUD operations with duplicated code:

| Family | Programs | Operations | Avg Size | Pattern |
|--------|----------|------------|----------|---------|
| **LGAC** | LGACUS01, LGACDB01, LGACDB02, LGACVS01 | Add Customer | 40 stmts | Business → DB2 → VSAM |
| **LGIC** | LGICUS01, LGICDB01, LGICVS01 | Inquire Customer | 43 stmts | Business → DB2 → VSAM |
| **LGUC** | LGUCUS01, LGUCDB01, LGUCVS01 | Update Customer | 34 stmts | Business → DB2 → VSAM |
| **LGAP** | LGAPOL01, LGAPDB01, LGAPVS01 | Add Policy | 67 stmts | Business → DB2 → VSAM |
| **LGIP** | LGIPOL01, LGIPDB01, LGIPVS01 | Inquire Policy | 98 stmts | Business → DB2 → VSAM |
| **LGUP** | LGUPOL01, LGUPDB01, LGUPVS01 | Update Policy | 72 stmts | Business → DB2 → VSAM |
| **LGDP** | LGDPOL01, LGDPDB01, LGDPVS01 | Delete Policy | 36 stmts | Business → DB2 → VSAM |
| **LGTE** | LGTESTC1, LGTESTP1-P4 | Presentation | 141 stmts | UI Layer |

### Issues
- **Duplicated error handling logic** across all families
- **Repeated COMMAREA validation** in every program
- **Similar DB2/VSAM coordination** code in each data access program
- **Identical LGSTSQ error logging** patterns (3 calls per program)
- **Copy-paste programming** evident in working storage definitions

### Refactoring Opportunities

#### Option A: Extract Common Business Logic Module
Create a reusable business logic framework:
```
LGBUSLOG (New Common Module)
├── COMMAREA validation
├── Error handling framework
├── LGSTSQ logging wrapper
└── Return code standardization
```

**Benefits:**
- Reduce code by ~30% across business logic programs
- Centralize error handling
- Easier to maintain and test

**Risks:**
- Requires careful COMMAREA handling
- May impact performance (additional LINK)
- Needs thorough regression testing

#### Option B: Create Data Access Layer Framework
Consolidate DB2 and VSAM operations:
```
LGDATAFW (New Data Framework)
├── Generic DB2 operations (SELECT, INSERT, UPDATE, DELETE)
├── Generic VSAM operations (READ, WRITE, REWRITE, DELETE)
├── Two-phase commit coordination
└── Unified error handling
```

**Benefits:**
- Eliminate duplicate persistence code
- Simplify two-phase commit logic
- Easier to add new persistence mechanisms

**Risks:**
- Complex parameter passing
- May not fit all use cases
- Performance overhead

#### Option C: Copybook-Based Code Generation
Create copybooks with common code patterns:
```
LGCOMERR.CPY - Error handling patterns
LGCOMVAL.CPY - COMMAREA validation
LGCOMLOG.CPY - Logging patterns
LGCOMDB2.CPY - DB2 operation templates
LGCOMVSM.CPY - VSAM operation templates
```

**Benefits:**
- Maintains current architecture
- Lower risk than framework approach
- Easier to implement incrementally

**Risks:**
- Still requires manual integration
- Less flexible than framework
- Copybook maintenance overhead

### Recommendation
**Start with Option C** (copybook-based) for quick wins, then evaluate Option A for business logic consolidation. Option B is too risky given the intentional dual-persistence demonstration architecture.

---

## 2. Inconsistent Error Handling

### 🟡 Priority: MEDIUM | Impact: HIGH | Effort: LOW

### Current State
Analysis shows **inconsistent error logging** across programs:

**Programs WITH Error Logging (20 programs):**
- All CRUD operations call LGSTSQ 3 times each
- Error handling percentage ranges from 1.26% to 12% of statements
- Consistent pattern: Call LGSTSQ on error conditions

**Programs WITHOUT Error Logging (10 programs):**
- LGWEBST5 (278 statements) - Web statistics
- LGTESTC1, LGTESTP1-P4 (130-154 statements) - Presentation layer
- LGSETUP (91 statements) - Initialization
- LGIPVS01, LGICVS01 (31-51 statements) - VSAM operations
- LGASTAT1 (30 statements) - Statistics

### Issues
- **Presentation layer programs** have no error logging
- **Some VSAM programs** (LGIPVS01, LGICVS01) lack error handling while others have it
- **Inconsistent error detection** - some programs may fail silently
- **Difficult troubleshooting** when errors occur in unlogged programs

### Refactoring Opportunities

#### Standardize Error Handling
1. **Add LGSTSQ calls to presentation layer** (LGTESTC1, LGTESTP1-P4)
   - Log CICS command failures
   - Log LINK failures to business logic
   - Log BMS map errors

2. **Complete VSAM error logging** (LGIPVS01, LGICVS01)
   - Add missing LGSTSQ calls
   - Match pattern used in LGACVS01, LGAPVS01, etc.

3. **Create error handling standards document**
   - Define when to call LGSTSQ
   - Standardize error message formats
   - Document error severity levels

### Benefits
- Improved troubleshooting and diagnostics
- Consistent error reporting across application
- Better production support

### Implementation Effort
- **Low effort** - Add 3-5 LGSTSQ calls per program
- **Low risk** - Non-breaking change
- **High value** - Immediate operational improvement

---

## 3. Dual Persistence Pattern Complexity

### 🟡 Priority: MEDIUM | Impact: MEDIUM | Effort: HIGH

### Current State
The application uses **intentional dual persistence** (DB2 + VSAM) with two-phase commit:

**Persistence Patterns:**
- **DB2-Only:** 8 programs (LGACDB01, LGICDB01, LGAPDB01, etc.)
- **VSAM-Only:** 7 programs (LGACVS01, LGICVS01, LGAPVS01, etc.)
- **No-Persistence:** 16 programs (business logic, presentation, utilities)

**Architecture Flow:**
```
Business Logic → DB2 Program → VSAM Program
                    ↓              ↓
                  DB2 Table    VSAM File
                    └──────┬──────┘
                    Two-Phase Commit
```

### Issues
- **Maintenance overhead** - Changes require updates to both DB2 and VSAM programs
- **Complex coordination** - Two-phase commit adds complexity
- **Data synchronization** - Risk of inconsistency if commit fails
- **Performance impact** - Two writes per operation

### Refactoring Opportunities

#### Option A: Maintain Current Architecture (Recommended)
**Rationale:** Per [`base/Architecture.md`](base/Architecture.md:48-50), the dual persistence is **intentional for demonstration purposes** to showcase two-phase commit processing in CICS.

**Improvements:**
- Document the demonstration purpose clearly
- Add monitoring for two-phase commit failures
- Create test scenarios for commit coordination
- Consider making VSAM optional via configuration

#### Option B: Migrate to DB2-Only
**If demonstration purpose is no longer needed:**
- Remove VSAM programs (7 programs)
- Simplify business logic (remove VSAM calls)
- Eliminate two-phase commit complexity
- Reduce maintenance by ~25%

**Risks:**
- Loses demonstration value
- Requires significant testing
- May impact training/demo scenarios

### Recommendation
**Maintain current architecture** but improve documentation and monitoring. Only migrate to DB2-only if demonstration purpose is no longer required.

---

## 4. Presentation Layer Code Duplication

### 🟡 Priority: MEDIUM | Impact: MEDIUM | Effort: MEDIUM

### Current State
The **LGTE family** (5 programs) shows significant duplication:

| Program | Purpose | Statements | Calls |
|---------|---------|------------|-------|
| LGTESTC1 | Customer menu | 132 | LGICUS01, LGUCUS01, LGACUS01 |
| LGTESTP1 | Policy menu (Motor) | 154 | LGIPOL01, LGUPOL01, LGDPOL01, LGAPOL01 |
| LGTESTP2 | Policy menu (Endowment) | 142 | LGIPOL01, LGUPOL01, LGDPOL01, LGAPOL01 |
| LGTESTP3 | Policy menu (House) | 139 | LGIPOL01, LGUPOL01, LGDPOL01, LGAPOL01 |
| LGTESTP4 | Policy menu (Commercial) | 146 | LGIPOL01, LGDPOL01, LGAPOL01 |

### Issues
- **LGTESTP1-P4 are nearly identical** (only differ in policy type)
- **Duplicated BMS map handling** across all 5 programs
- **Repeated input validation** logic
- **Similar COMMAREA preparation** code
- **Identical error handling patterns** (currently missing)

### Refactoring Opportunities

#### Option A: Consolidate Policy Presentation Programs
Merge LGTESTP1-P4 into a single program with policy type parameter:
```
LGTESTPX (New Consolidated Program)
├── Accept policy type from COMMAREA
├── Common BMS map handling
├── Shared validation logic
└── Route to appropriate business logic based on type
```

**Benefits:**
- Reduce from 4 programs to 1 (~75% reduction)
- Single point of maintenance
- Consistent behavior across policy types

**Risks:**
- Larger program (may exceed complexity thresholds)
- Requires transaction definition changes
- More complex testing

#### Option B: Extract Common Presentation Framework
Create shared copybooks for presentation logic:
```
LGPRESFW.CPY - Presentation framework
├── BMS map handling templates
├── Input validation patterns
├── COMMAREA preparation
└── Error display logic
```

**Benefits:**
- Maintains separate programs
- Lower risk than consolidation
- Incremental implementation

### Recommendation
**Option B** - Extract common patterns into copybooks first. Evaluate Option A only if maintenance burden remains high.

---

## 5. Tight Coupling Through LGSTSQ Utility

### 🟢 Priority: LOW | Impact: MEDIUM | Effort: LOW

### Current State
**LGSTSQ is called by 20 programs** (3 calls each = 60 total calls):

**High Coupling:**
- Every data access program depends on LGSTSQ
- Changes to LGSTSQ impact 20 programs
- LGSTSQ becomes a single point of failure
- No alternative logging mechanism

### Issues
- **Tight coupling** reduces flexibility
- **Testing complexity** - Must mock LGSTSQ for unit tests
- **No logging alternatives** - Can't switch to different logging
- **Performance bottleneck** - All errors funnel through one program

### Refactoring Opportunities

#### Create Logging Abstraction Layer
```
LGLOGAPI.CPY (New Logging API)
├── CALL-LOGGER paragraph
├── LOG-ERROR paragraph
├── LOG-WARNING paragraph
└── LOG-INFO paragraph

Implementation options:
- LGSTSQ (current)
- CICS TD queues
- SMF records
- External logging service
```

**Benefits:**
- Decouple programs from specific logging implementation
- Enable multiple logging targets
- Easier testing (mock the API)
- Future-proof for logging changes

**Implementation:**
- Create copybook with logging API
- Update programs to use API instead of direct LGSTSQ calls
- Maintain LGSTSQ as default implementation

### Recommendation
**Implement logging abstraction** - Low effort, high value for maintainability and testing.

---

## 6. Missing Cyclomatic Complexity Metrics

### 🟢 Priority: LOW | Impact: LOW | Effort: LOW

### Current State
**No cyclomatic complexity scores** available in the database:
- All programs show `CYCLOMATICSCORE: null`
- Cannot identify overly complex programs
- No objective measure of code complexity

### Issues
- **Cannot prioritize refactoring** based on complexity
- **No complexity trends** over time
- **Difficult to enforce** complexity standards
- **May miss** high-complexity programs needing refactoring

### Refactoring Opportunities

#### Enable Complexity Analysis
1. **Configure scanner** to calculate cyclomatic complexity
2. **Establish complexity thresholds:**
   - Low: < 10
   - Medium: 10-20
   - High: 20-50
   - Very High: > 50

3. **Create complexity report** showing:
   - Programs exceeding thresholds
   - Complexity trends
   - Refactoring priorities

### Benefits
- Objective refactoring prioritization
- Identify high-risk programs
- Track complexity over time
- Enforce coding standards

### Recommendation
**Enable complexity metrics** in next scan - Provides valuable data for future refactoring decisions.

---

## 7. Copybook Dependency Management

### 🟢 Priority: LOW | Impact: MEDIUM | Effort: MEDIUM

### Current State
**Copybook usage analysis:**

| Copybook | Used By | Purpose |
|----------|---------|---------|
| **LGCMAREA** | 25 programs | COMMAREA structure (universal) |
| **LGPOLICY** | 10 programs | Policy data structure |
| **SQLCA** | 8 programs | DB2 SQL communication area |
| **SSMAP** | 5 programs | BMS map definitions |

### Issues
- **LGCMAREA is universal** - Changes impact 25 programs
- **No versioning** of copybook structures
- **Tight coupling** through shared data structures
- **Difficult to extend** without breaking changes

### Refactoring Opportunities

#### Implement Copybook Versioning Strategy
```
LGCMAREA.CPY (Current - V1)
LGCMAR02.CPY (V2 - Extended)
LGCMAR03.CPY (V3 - Future)

Strategy:
- New fields added to new versions
- Programs migrate incrementally
- Old versions maintained for compatibility
```

#### Create Copybook Abstraction
```
LGCMAPI.CPY (API Layer)
├── GET-CUSTOMER-NUM
├── SET-REQUEST-ID
├── GET-RETURN-CODE
└── Hides internal COMMAREA structure
```

**Benefits:**
- Reduce coupling to COMMAREA structure
- Enable structure evolution
- Easier to add new fields
- Better encapsulation

### Recommendation
**Implement versioning strategy** for future COMMAREA changes (like the 12-digit customer number expansion already planned).

---

## 8. Program Size and Modularity

### 🟢 Priority: LOW | Impact: LOW | Effort: MEDIUM

### Current State
**Program size distribution:**

| Size Category | Count | Programs |
|---------------|-------|----------|
| **Large (>200)** | 3 | LGWEBST5 (278), LGIPDB01 (245), LGTESTP1 (154) |
| **Medium (100-200)** | 7 | LGTESTP2-P4, LGAPDB01, LGUPDB01, LGSETUP |
| **Small (<100)** | 21 | Most CRUD operations |

### Issues
- **LGWEBST5** (278 statements) - Web statistics program is large
- **LGIPDB01** (245 statements) - Policy inquiry has 5 SQL operations
- **Limited paragraph reuse** - Most programs have 2-11 paragraphs

### Refactoring Opportunities

#### Break Down Large Programs
**LGWEBST5:**
- Extract statistics calculation logic
- Separate data collection from formatting
- Create reusable statistics modules

**LGIPDB01:**
- Extract SQL operations into separate paragraphs
- Consider splitting into multiple programs by policy type
- Reduce from 5 SQL operations to more focused queries

### Recommendation
**Monitor program growth** - Current sizes are acceptable, but establish thresholds (e.g., 300 statements) to trigger refactoring.

---

## Implementation Roadmap

### Phase 1: Quick Wins (1-2 weeks)
**Priority: HIGH | Risk: LOW**

1. ✅ **Standardize error handling** (Opportunity #2)
   - Add LGSTSQ calls to presentation layer
   - Complete VSAM error logging
   - Document error handling standards

2. ✅ **Create logging abstraction** (Opportunity #5)
   - Implement LGLOGAPI.CPY
   - Update 5 programs as pilot
   - Validate approach

3. ✅ **Enable complexity metrics** (Opportunity #6)
   - Configure scanner
   - Generate baseline report
   - Establish thresholds

### Phase 2: Code Consolidation (4-6 weeks)
**Priority: MEDIUM | Risk: MEDIUM**

4. ✅ **Extract common copybooks** (Opportunity #1, Option C)
   - Create LGCOMERR.CPY, LGCOMVAL.CPY, LGCOMLOG.CPY
   - Pilot with 3 programs
   - Roll out to remaining programs

5. ✅ **Consolidate presentation layer** (Opportunity #4, Option B)
   - Create LGPRESFW.CPY
   - Update LGTESTC1 first
   - Apply to LGTESTP1-P4

### Phase 3: Architecture Improvements (8-12 weeks)
**Priority: MEDIUM | Risk: HIGH**

6. ✅ **Implement copybook versioning** (Opportunity #7)
   - Design versioning strategy
   - Create LGCMAR02.CPY for 12-digit customer number
   - Migrate programs incrementally

7. ✅ **Evaluate business logic framework** (Opportunity #1, Option A)
   - Design LGBUSLOG module
   - Pilot with customer operations
   - Assess benefits vs. complexity

### Phase 4: Long-term Optimization (Future)
**Priority: LOW | Risk: HIGH**

8. ⚠️ **Consider DB2-only migration** (Opportunity #3, Option B)
   - Only if demonstration purpose no longer needed
   - Requires business approval
   - Significant testing effort

9. ⚠️ **Refactor large programs** (Opportunity #8)
   - Break down LGWEBST5 if it grows beyond 300 statements
   - Monitor LGIPDB01 complexity

---

## Risk Assessment

### Low Risk Refactorings
- ✅ Add error logging (non-breaking)
- ✅ Create logging abstraction (wrapper pattern)
- ✅ Enable complexity metrics (analysis only)
- ✅ Extract common copybooks (incremental)

### Medium Risk Refactorings
- ⚠️ Consolidate presentation programs (changes program structure)
- ⚠️ Implement copybook versioning (requires migration strategy)
- ⚠️ Create business logic framework (new architecture layer)

### High Risk Refactorings
- 🔴 Migrate to DB2-only (removes demonstration feature)
- 🔴 Consolidate policy programs (major restructuring)
- 🔴 Break down large programs (significant rework)

---

## Success Metrics

### Code Quality Metrics
- **Code duplication:** Reduce by 30% (target: 8 program families → 3-4 modules)
- **Error handling coverage:** Increase from 65% to 100% of programs
- **Cyclomatic complexity:** Maintain all programs < 50
- **Program coupling:** Reduce LGSTSQ direct calls by 50%

### Maintainability Metrics
- **Time to add new CRUD operation:** Reduce by 40%
- **Defect rate:** Reduce by 25% through standardization
- **Code review time:** Reduce by 30% with consistent patterns
- **Onboarding time:** Reduce by 50% with better structure

### Operational Metrics
- **Error detection rate:** Increase by 100% (add logging to 10 programs)
- **Mean time to diagnose:** Reduce by 40% with better logging
- **Production incidents:** Reduce by 20% through improved error handling

---

## Conclusion

Your CICS GenApp application demonstrates **good architectural layering** but has significant opportunities for improvement through:

1. **Reducing code duplication** across CRUD operation families
2. **Standardizing error handling** across all programs
3. **Improving maintainability** through common frameworks
4. **Reducing coupling** through abstraction layers

The recommended approach is **incremental refactoring** starting with low-risk, high-value improvements (error handling, logging abstraction) before tackling more complex architectural changes.

**Key Principle:** Maintain the intentional demonstration architecture (dual persistence, two-phase commit) while improving code quality and maintainability within that framework.

---

## Next Steps

1. **Review this analysis** with your team
2. **Prioritize opportunities** based on your business needs
3. **Select Phase 1 items** to begin implementation
4. **Create detailed implementation plans** for selected opportunities
5. **Establish success metrics** and tracking mechanisms

For detailed implementation planning of any opportunity, I can create comprehensive implementation plans using the implementation-planning skill.

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-05  
**Analysis Method:** Local Database SQL Analysis  
**Programs Analyzed:** 31 COBOL programs  
**Dependencies Mapped:** 52 program-to-program calls  
**Copybooks Analyzed:** 4 shared copybooks