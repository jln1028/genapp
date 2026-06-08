# Dead Code Analysis Report
**Generated:** 2026-06-05  
**Analysis Method:** Local Database Analysis

## Executive Summary

This analysis identifies dead or unreachable code in the CICS GenApp application. The analysis reveals several categories of potentially removable code, though **caution is advised** as some "unused" code may be intentionally included for demonstration purposes or accessed through external mechanisms not captured in static analysis.

### Key Findings

- **5 programs** appear to have no internal callers (entry points or potentially unused utilities)
- **61 unreferenced paragraphs** across all programs (mostly COBOL structural paragraphs)
- **2,829 unused variables** across 31 programs (average 39.9% unused per program)
- **High-impact programs** with 70%+ unused variables: LGIPOL01 (85.7%), LGICUS01 (82.4%), LGACUS01 (82%), LGUCDB01 (78.8%)

---

## 1. Programs Without Internal Callers

### 1.1 Entry Point Programs (EXPECTED - Not Dead Code)

These programs are **CICS transaction entry points** and are invoked directly by CICS transactions, not by other programs:

| Program | Transaction | Purpose | Status |
|---------|-------------|---------|--------|
| **LGTESTC1** | SSC1 | Customer menu presentation | ✅ Active Entry Point |
| **LGTESTP1** | SSP1 | Motor policy menu | ✅ Active Entry Point |
| **LGTESTP2** | SSP2 | Endowment policy menu | ✅ Active Entry Point |
| **LGTESTP3** | SSP3 | House policy menu | ✅ Active Entry Point |
| **LGTESTP4** | SSP4 | Commercial policy menu | ✅ Active Entry Point |

**Recommendation:** ✅ **KEEP** - These are documented, tested transaction entry points per [`base/Testing.md`](../base/Testing.md) and [`base/Architecture.md`](../base/Architecture.md).

### 1.2 Utility Programs (REQUIRE INVESTIGATION)

These programs have no internal callers but may be invoked through external mechanisms:

| Program | Purpose | Investigation Needed |
|---------|---------|---------------------|
| **LGSETUP** | Initialization/setup utility | May be called by LGSE transaction or external JCL |
| **LGASTAT1** | Statistics/counter management | May be invoked by external monitoring or batch jobs |
| **LGWEBST5** | Web statistics (692 variables, only 9.7% unused) | May be REST/web service entry point |
| **LGICVS01** | Customer VSAM insert (never called) | ⚠️ **Potential dead code** - LGICUS01 calls LGICDB01 instead |
| **LGIPVS01** | Policy VSAM insert (never called) | ⚠️ **Potential dead code** - LGIPOL01 calls LGIPDB01 instead |

**Recommendations:**
- ✅ **LGSETUP**: Verify LGSE transaction definition and startup JCL
- ✅ **LGASTAT1**: Check for external monitoring scripts or batch jobs
- ✅ **LGWEBST5**: Verify web service configuration and REST API definitions
- ⚠️ **LGICVS01, LGIPVS01**: Strong candidates for removal - appear to be superseded by DB01 variants

---

## 2. Unreferenced Paragraphs

### 2.1 Structural Paragraphs (EXPECTED - Not Dead Code)

**61 unreferenced paragraphs** were found, but most are COBOL structural elements:

| Paragraph Pattern | Count | Explanation |
|-------------------|-------|-------------|
| `MAINLINE_FIRST_SENTENCES` | 31 | Entry point label - not explicitly called |
| `MAINLINE_MAINLINE-EXIT` | 21 | Exit point label - reached via GOBACK/STOP RUN |
| `MAINLINE_A-EXIT` | 8 | Alternative exit label |
| `MAINLINE_END-PROGRAM` | 3 | Program termination label |
| `MAINLINE_NO-UPD` | 1 | Conditional branch target in LGTESTP4 |

**Recommendation:** ✅ **KEEP** - These are standard COBOL structural paragraphs. Removing them would break program flow and is not recommended.

### 2.2 Investigation Required

- **LGTESTP4 / MAINLINE_NO-UPD**: Verify if this paragraph is reachable through conditional logic not captured in static analysis.

---

## 3. Unused Variables Analysis

### 3.1 Critical Programs (70%+ Unused Variables)

These programs have the highest percentage of unused variables and should be prioritized for cleanup:

| Rank | Program | Total Vars | Unused | % Unused | Category |
|------|---------|------------|--------|----------|----------|
| 1 | **LGIPOL01** | 203 | 174 | 85.7% | Business Logic |
| 2 | **LGICUS01** | 210 | 173 | 82.4% | Business Logic |
| 3 | **LGACUS01** | 211 | 173 | 82.0% | Business Logic |
| 4 | **LGUCDB01** | 226 | 178 | 78.8% | Data Access |
| 5 | **LGICDB01** | 221 | 167 | 75.6% | Data Access |
| 6 | **LGACVS01** | 126 | 94 | 74.6% | Data Access |
| 7 | **LGUCUS01** | 125 | 93 | 74.4% | Business Logic |
| 8 | **LGAPOL01** | 124 | 90 | 72.6% | Business Logic |
| 9 | **LGDPVS01** | 133 | 95 | 71.4% | Data Access |
| 10 | **LGUCVS01** | 132 | 94 | 71.2% | Data Access |

### 3.2 Root Cause: COMMAREA Copybook Over-Inclusion

**Primary Issue:** Programs include the entire [`lgcmarea.cpy`](../base/src/lgcmarea.cpy) copybook, which defines a comprehensive COMMAREA structure containing fields for **all policy types** (Motor, Endowment, House, Commercial) and **all operations** (Add, Inquire, Update, Delete).

**Example from LGACDB01:**
- **Total Variables:** 254
- **Unused Variables:** 172 (67.7%)
- **Unused Categories:**
  - Commercial policy fields (CA-COMMERCIAL, CA-B-*)
  - Endowment policy fields (CA-ENDOWMENT, CA-E-*)
  - House policy fields (CA-H-*)
  - Motor policy fields (CA-M-*)
  - Claim fields (CA-CLAIM, CA-C-*)
  - Customer security fields (CA-CUSTSECR-*)
  - Broker fields (CA-BROKERID, CA-BROKERSREF)

**Why This Happens:**
- Each program handles **one specific policy type** but includes the **entire COMMAREA** structure
- COMMAREA is the stable contract across layers (per AGENTS.md)
- Over-sized COMMAREA lengths are commonly passed between programs

### 3.3 Variable Cleanup Strategy

#### Option A: Aggressive Cleanup (NOT RECOMMENDED)
Remove unused variables from individual programs.

**Risks:**
- ❌ Breaks COMMAREA contract stability
- ❌ Requires copybook fragmentation
- ❌ May break oversized length passing patterns
- ❌ High maintenance burden

#### Option B: Copybook Restructuring (RECOMMENDED)
Refactor [`lgcmarea.cpy`](../base/src/lgcmarea.cpy) into modular sections:

```cobol
COPY LGCMAREA-COMMON.     * Request ID, return codes, common fields
COPY LGCMAREA-CUSTOMER.   * Customer-specific fields
COPY LGCMAREA-MOTOR.      * Motor policy fields (only in motor programs)
COPY LGCMAREA-ENDOWMENT.  * Endowment fields (only in endowment programs)
COPY LGCMAREA-HOUSE.      * House fields (only in house programs)
COPY LGCMAREA-COMMERCIAL. * Commercial fields (only in commercial programs)
```

**Benefits:**
- ✅ Maintains COMMAREA contract for common fields
- ✅ Reduces unused variables by 60-80% per program
- ✅ Improves code readability and maintenance
- ✅ Preserves oversized length passing for common section

**Implementation Effort:** Medium (requires careful copybook splitting and regression testing)

#### Option C: Documentation Only (MINIMAL EFFORT)
Accept high unused variable counts as architectural trade-off.

**Rationale:**
- COMMAREA stability is intentional design (per AGENTS.md)
- Unused variables have minimal runtime impact
- Focus cleanup efforts on truly dead code (programs, paragraphs)

---

## 4. Detailed Unused Variable Examples

### 4.1 LGACDB01 (Customer DB Access - 67.7% Unused)

**Unused Policy-Specific Fields:**
```
CA-B-Address, CA-B-CrimePeril, CA-B-CrimePremium, CA-B-Customer,
CA-B-FirePeril, CA-B-FirePremium, CA-B-FloodPeril, CA-B-FloodPremium,
CA-B-Latitude, CA-B-Longitude, CA-B-Postcode, CA-B-PropType,
CA-B-RejectReason, CA-B-Status, CA-B-WeatherPeril, CA-B-WeatherPremium
```

**Unused Operational Fields:**
```
CA-BROKERID, CA-BROKERSREF, CA-CLAIM (and all CA-C-* claim fields),
CA-COMMERCIAL (and all CA-B-* commercial fields),
CA-ENDOWMENT (and all CA-E-* endowment fields),
CA-H-* (all house policy fields)
```

**Recommendation:** These are unused because LGACDB01 handles **customer data only**, not policy data. This is expected behavior given the layered architecture.

### 4.2 LGIPOL01 (Policy Business Logic - 85.7% Unused)

**Why So High?**
- Includes entire COMMAREA with all policy types
- Only uses fields relevant to **policy insert operations**
- Does not use customer-specific fields (handled by LGICUS01)
- Does not use claim fields (separate claim processing flow)

---

## 5. Programs Not in Database

The following programs exist in the source directory but were **not found in the scan database**:

| Program | Location | Status |
|---------|----------|--------|
| **LGCURPT1** | [`base/src/lgcurpt1.cbl`](../base/src/lgcurpt1.cbl) | Batch report program (JCL: [`base/cntl/lgcurpt1.jcl`](../base/cntl/lgcurpt1.jcl)) |
| **LGUMOT01** | [`LGUMOT01/LGUMOT01.cbl`](../LGUMOT01/LGUMOT01.cbl) | Custom extraction program (documented in [`LGUMOT01/LGUMOT01-EXTRACTION-REPORT.md`](../LGUMOT01/LGUMOT01-EXTRACTION-REPORT.md)) |

**Recommendation:** ✅ **KEEP** - These are batch programs invoked via JCL, not CICS LINK calls. They are not dead code.

---

## 6. Architecture Context

### 6.1 Intentional Non-Best-Practice Code

Per [`base/Architecture.md`](../base/Architecture.md):
> "The architecture intentionally includes some non-best-practice constructs for demonstration purposes, including VSAM + Db2 two-phase commit and temporary-storage/named-counter usage; do not 'simplify' these away in plans without checking Architecture.md."

**Implications:**
- Some "unused" code may be **intentionally included for demonstration**
- VSAM programs (LGICVS01, LGIPVS01) may be demonstration alternatives to DB2 programs
- Temporary storage queue handling may appear unused but serves testing purposes

### 6.2 COMMAREA Contract Stability

Per [`AGENTS.md`](../AGENTS.md):
> "COMMAREA is the stable contract across layers; request routing is driven by CA-REQUEST-ID in lgcmarea.cpy, and callers commonly pass oversized lengths, so interface changes must be copybook-first and cross-program."

**Implications:**
- High unused variable counts are **architectural trade-off** for stability
- Removing unused COMMAREA fields requires **cross-program impact analysis**
- Oversized length passing means programs may receive more data than they use

---

## 7. Recommendations Summary

### 7.1 High-Confidence Removals

| Item | Type | Confidence | Estimated Effort |
|------|------|------------|------------------|
| **LGICVS01** | Program | 🟡 Medium | Low (verify no external JCL calls) |
| **LGIPVS01** | Program | 🟡 Medium | Low (verify no external JCL calls) |

### 7.2 Requires Investigation

| Item | Type | Action Required |
|------|------|-----------------|
| **LGSETUP** | Program | Verify LGSE transaction and startup JCL |
| **LGASTAT1** | Program | Check external monitoring/batch jobs |
| **LGWEBST5** | Program | Verify web service configuration |
| **LGTESTP4 / NO-UPD** | Paragraph | Trace conditional logic paths |

### 7.3 Architectural Improvements

| Improvement | Priority | Effort | Impact |
|-------------|----------|--------|--------|
| **Copybook Restructuring** | 🟢 High | Medium | Reduces unused variables by 60-80% |
| **Document COMMAREA Strategy** | 🟢 High | Low | Clarifies intentional design decisions |
| **Remove LGICVS01/LGIPVS01** | 🟡 Medium | Low | Eliminates 2 unused programs |

### 7.4 Not Recommended

| Item | Reason |
|------|--------|
| **Remove structural paragraphs** | Breaks COBOL program flow |
| **Aggressive variable cleanup** | Breaks COMMAREA contract stability |
| **Remove entry point programs** | Active CICS transactions |

---

## 8. Next Steps

### Phase 1: Verification (Low Risk)
1. ✅ Verify LGICVS01 and LGIPVS01 have no external callers (JCL, scripts)
2. ✅ Confirm LGSETUP is called by LGSE transaction
3. ✅ Validate LGASTAT1 usage in monitoring systems
4. ✅ Check LGWEBST5 web service configuration

### Phase 2: Documentation (No Risk)
1. 📝 Document COMMAREA design strategy in Architecture.md
2. 📝 Add comments to high-unused-variable programs explaining intentional design
3. 📝 Create copybook restructuring design document

### Phase 3: Cleanup (Medium Risk)
1. 🔧 Remove LGICVS01 and LGIPVS01 if verification confirms no usage
2. 🔧 Implement copybook restructuring (requires regression testing)
3. 🔧 Update build scripts and documentation

---

## 9. Testing Requirements

Before removing any code, ensure:

1. ✅ **Functional Testing**: Run all transactions (SSC1, SSP1-SSP4, LGSE) per [`base/Testing.md`](../base/Testing.md)
2. ✅ **Regression Testing**: Verify customer add/update/inquire flows
3. ✅ **Policy Testing**: Test all policy types (Motor, Endowment, House, Commercial)
4. ✅ **Two-Phase Commit**: Validate VSAM + Db2 synchronization
5. ✅ **Error Handling**: Test GENAERRS temporary storage queue logging
6. ✅ **Counter Server**: Verify named counter allocation (if configured)

---

## 10. Conclusion

The CICS GenApp application has **limited true dead code**. Most "unused" elements fall into three categories:

1. **Entry Points** (LGTESTC1, LGTESTP1-4): Active transaction entry points - **KEEP**
2. **Structural Paragraphs** (61 items): COBOL flow control - **KEEP**
3. **COMMAREA Variables** (2,829 items): Intentional architectural trade-off - **DOCUMENT, OPTIONALLY REFACTOR**

**True Dead Code Candidates:**
- LGICVS01 (Customer VSAM insert - superseded by LGICDB01)
- LGIPVS01 (Policy VSAM insert - superseded by LGIPDB01)

**Recommended Focus:**
- Verify and remove LGICVS01/LGIPVS01 if unused
- Document COMMAREA design strategy
- Consider copybook restructuring for long-term maintainability

**Estimated Cleanup Impact:**
- **Programs Removed:** 2 (LGICVS01, LGIPVS01)
- **Lines of Code Reduced:** ~400-600 lines
- **Maintenance Burden Reduced:** Minimal (these programs are already inactive)
- **Risk Level:** Low (if verification confirms no external usage)

---

**Report Generated By:** Bob Z Architect Mode  
**Analysis Date:** 2026-06-05  
**Database Location:** `.bobz/local-settings.json`  
**Programs Analyzed:** 31 COBOL programs  
**Total Variables Analyzed:** 7,091 variables