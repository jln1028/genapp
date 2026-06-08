[ ] Support team trained on 12-digit customer number format and troubleshooting
- [ ] Development team briefed on code changes and testing requirements
- [ ] Database administrators trained on DB2 migration procedures
- [ ] CICS systems programmers trained on FCT and Named Counter updates
- [ ] Documentation published to internal wiki and knowledge base

---

## Appendix A: Analysis Data

### Programs Analyzed

**Customer Management Programs** (9 programs):
- [`LGACDB01`](base/src/lgacdb01.cbl): Customer DB2 add - generates customer numbers, inserts to CUSTOMER table
- [`LGACUS01`](base/src/lgacus01.cbl): Customer business logic - orchestrates add operations
- [`LGACVS01`](base/src/lgacvs01.cbl): Customer VSAM add - writes to KSDSCUST with 10-byte key
- [`LGICDB01`](base/src/lgicdb01.cbl): Customer DB2 inquiry - reads from CUSTOMER table
- [`LGICUS01`](base/src/lgicus01.cbl): Customer inquiry business logic
- [`LGICVS01`](base/src/lgicvs01.cbl): Customer VSAM inquiry - reads from KSDSCUST
- [`LGUCDB01`](base/src/lgucdb01.cbl): Customer DB2 update - updates CUSTOMER table
- [`LGUCUS01`](base/src/lgucus01.cbl): Customer update business logic
- [`LGUCVS01`](base/src/lgucvs01.cbl): Customer VSAM update - updates KSDSCUST

**Policy Management Programs** (15 programs):
- [`LGAPDB01`](base/src/lgapdb01.cbl): Policy DB2 add - inserts to POLICY table with customer number foreign key
- [`LGAPOL01`](base/src/lgapol01.cbl): Policy add business logic
- [`LGAPVS01`](base/src/lgapvs01.cbl): Policy VSAM add - writes to KSDSPOLY
- [`LGIPDB01`](base/src/lgipdb01.cbl): Policy DB2 inquiry - reads from POLICY table
- [`LGIPOL01`](base/src/lgipol01.cbl): Policy inquiry business logic
- [`LGIPVS01`](base/src/lgipvs01.cbl): Policy VSAM inquiry - reads from KSDSPOLY
- [`LGUPDB01`](base/src/lgupdb01.cbl): Policy DB2 update - updates POLICY table
- [`LGUPOL01`](base/src/lgupol01.cbl): Policy update business logic
- [`LGUPVS01`](base/src/lgupvs01.cbl): Policy VSAM update - updates KSDSPOLY
- [`LGDPDB01`](base/src/lgdpdb01.cbl): Policy DB2 delete - deletes from POLICY table
- [`LGDPOL01`](base/src/lgdpol01.cbl): Policy delete business logic
- [`LGDPVS01`](base/src/lgdpvs01.cbl): Policy VSAM delete - deletes from KSDSPOLY

**Presentation Layer Programs** (5 programs):
- [`LGTESTC1`](base/src/lgtestc1.cbl): Customer menu and presentation logic
- [`LGTESTP1`](base/src/lgtestp1.cbl): Policy menu - Endowment policies
- [`LGTESTP2`](base/src/lgtestp2.cbl): Policy menu - House policies
- [`LGTESTP3`](base/src/lgtestp3.cbl): Policy menu - Motor policies
- [`LGTESTP4`](base/src/lgtestp4.cbl): Policy menu - Commercial policies

**Support Programs** (1 program):
- [`LGASTAT1`](base/src/lgastat1.cbl): Statistics tracking and reporting

### Key Variables/Data Structures

**From [`lgcmarea.cpy`](base/src/lgcmarea.cpy)**:
- [`CA-REQUEST-ID`](base/src/lgcmarea.cpy:10): PIC X(6) - Request routing identifier
- [`CA-RETURN-CODE`](base/src/lgcmarea.cpy:11): PIC 9(2) - Operation result code
- [`CA-CUSTOMER-NUM`](base/src/lgcmarea.cpy:12): PIC 9(10) → **PIC 9(12)** - Customer identifier (PRIMARY CHANGE)
- [`CA-REQUEST-SPECIFIC`](base/src/lgcmarea.cpy:13): PIC X(32482) - Variable data area

**From [`lgpolicy.cpy`](base/src/lgpolicy.cpy)**:
- [`WS-CUSTOMER-LEN`](base/src/lgpolicy.cpy:17): PIC S9(4) COMP VALUE +72 - Customer data length
- [`DB2-POLICYNUMBER`](base/src/lgpolicy.cpy:44): PIC 9(10) - Policy identifier (NO CHANGE)

**From [`LGACDB01`](base/src/lgacdb01.cbl)**:
- `DB2-CUSTOMERNUM-INT`: Host variable for DB2 INTEGER → **BIGINT**
- `LastCustNum`: PIC S9(8) COMP - Named Counter Service value
- `GENAcount`: PIC X(16) VALUE 'GENACUSTNUM' - Counter name

### Control Flow Insights

**Customer Add Flow**:
1. [`LGTESTC1`](base/src/lgtestc1.cbl) receives transaction SSC1, validates input, normalizes data
2. [`LGTESTC1`](base/src/lgtestc1.cbl) LINKs to [`LGACUS01`](base/src/lgacus01.cbl) with commarea
3. [`LGACUS01`](base/src/lgacus01.cbl) validates commarea length, LINKs to [`LGACDB01`](base/src/lgacdb01.cbl)
4. [`LGACDB01`](base/src/lgacdb01.cbl) generates customer number via Named Counter or DB2 identity
5. [`LGACDB01`](base/src/lgacdb01.cbl) inserts to DB2 CUSTOMER table
6. [`LGACDB01`](base/src/lgacdb01.cbl) LINKs to [`LGACDB02`](base/src/lgacdb02.cbl) for security setup
7. [`LGACDB01`](base/src/lgacdb01.cbl) LINKs to [`LGACVS01`](base/src/lgacvs01.cbl) for VSAM write
8. [`LGACVS01`](base/src/lgacvs01.cbl) writes to KSDSCUST with 10-byte key → **12-byte key**
9. Two-phase commit ensures DB2 and VSAM consistency

**Policy Add Flow**:
1. [`LGTESTP1-P4`](base/src/lgtestp1.cbl) receives transaction SSP1, validates input
2. LINKs to [`LGAPOL01`](base/src/lgapol01.cbl) with commarea containing customer number
3. [`LGAPOL01`](base/src/lgapol01.cbl) LINKs to [`LGAPDB01`](base/src/lgapdb01.cbl)
4. [`LGAPDB01`](base/src/lgapdb01.cbl) inserts to DB2 POLICY table with customer number foreign key
5. [`LGAPDB01`](base/src/lgapdb01.cbl) LINKs to [`LGAPVS01`](base/src/lgapvs01.cbl)
6. [`LGAPVS01`](base/src/lgapvs01.cbl) writes to KSDSPOLY with customer number in key
7. Two-phase commit ensures consistency

### Cross-Program Dependencies

**Copybook Dependencies**:
- All 25 programs include [`lgcmarea.cpy`](base/src/lgcmarea.cpy) - single point of change
- 9 programs include [`lgpolicy.cpy`](base/src/lgpolicy.cpy) - verify no customer number references

**Database Dependencies**:
- CUSTOMER table → CUSTOMER_SECURE table (foreign key)
- CUSTOMER table → POLICY table (foreign key)
- POLICY table → ENDOWMENT, HOUSE, MOTOR, COMMERCIAL tables (foreign key via policyNumber)

**VSAM Dependencies**:
- KSDSCUST file: Primary customer data store, 10-byte key → **12-byte key**
- KSDSPOLY file: Primary policy data store, includes customer number in composite key

**Program Call Dependencies**:
- [`LGACUS01`](base/src/lgacus01.cbl) → [`LGACDB01`](base/src/lgacdb01.cbl) → [`LGACDB02`](base/src/lgacdb02.cbl), [`LGACVS01`](base/src/lgacvs01.cbl)
- [`LGICUS01`](base/src/lgicus01.cbl) → [`LGICDB01`](base/src/lgicdb01.cbl), [`LGICVS01`](base/src/lgicvs01.cbl)
- [`LGUCUS01`](base/src/lgucus01.cbl) → [`LGUCDB01`](base/src/lgucdb01.cbl), [`LGUCVS01`](base/src/lgucvs01.cbl)
- [`LGAPOL01`](base/src/lgapol01.cbl) → [`LGAPDB01`](base/src/lgapdb01.cbl) → [`LGAPVS01`](base/src/lgapvs01.cbl)
- Similar patterns for inquiry, update, delete policy operations

---

## Appendix B: Traceability Matrix

| Requirement ID | Requirement | Implementation Workstream | Test Case |
|----------------|-------------|---------------------------|-----------|
| FR1 | Expand CA-CUSTOMER-NUM to PIC 9(12) | Workstream A: Copybook Updates | Unit Test 1: Copybook Field Size |
| FR2 | Update DB2 CUSTOMER table to BIGINT | Workstream B: DB2 Schema Migration | Unit Test 2: DB2 BIGINT Storage |
| FR3 | Update DB2 POLICY table foreign key to BIGINT | Workstream B: DB2 Schema Migration | Integration Test 4: Policy Add with 12-digit Customer |
| FR4 | Update DB2 CUSTOMER_SECURE table to BIGINT | Workstream B: DB2 Schema Migration | Regression Test: Security Integration |
| FR5 | Modify VSAM KSDSCUST key to 12 bytes | Workstream C: VSAM Reorganization | Unit Test 3: VSAM 12-Byte Key |
| FR6 | Modify VSAM KSDSPOLY customer field to 12 bytes | Workstream C: VSAM Reorganization | Integration Test 4: Policy Add |
| FR7 | Update all 25 COBOL programs | Workstream D: COBOL Program Updates | Integration Tests 1-5 |
| FR8 | Update CICS Named Counter Service | Workstream E: CICS Configuration | Unit Test 4: Customer Number Generation |
| FR9 | Migrate existing data to 12-digit format | Workstream H: Data Migration | Unit Test 5: Data Migration, Migration Tests 1-2 |
| NFR1 | Zero data loss during migration | Workstream H: Data Migration | Migration Tests 1-3 |
| NFR2 | Maintain backward compatibility | Workstream A: Feature Flag | Integration Test 2: Migrated Customer Inquiry |
| NFR3 | No service interruption | Workstream H: Phased Rollout | End-to-End Test 1-3 |
| NFR4 | Performance impact < 5% | Workstream G: Testing | Integration Test 3: High-Volume Creation |
| NFR5 | Maintain two-phase commit integrity | Workstream D: COBOL Programs | Integration Test 5: Two-Phase Commit Rollback |
| NFR6 | Rollback capability for 48 hours | Workstream H: Rollout Plan | Migration Test 3: Rollback Test |
| BR1 | Support growth beyond 10 billion customers | All Workstreams | End-to-End Test 3: High-Volume Creation |
| BR2 | Align with industry standards | Workstream A: Copybook Updates | Documentation Review |
| BR3 | Prevent emergency changes | All Workstreams | Operational Readiness Checklist |
| BR4 | Maintain audit trail | Workstream D: COBOL Programs | Regression Test: Error Handling |

---

**Last Updated**: 2026-06-05T03:03:54Z
**Next Review Date**: 2026-06-12

---

## Implementation Notes

### Critical Success Factors

1. **Single Copybook Change**: All programs use [`lgcmarea.cpy`](base/src/lgcmarea.cpy), making this a single point of change that propagates to all 25 programs
2. **Two-Phase Commit Preservation**: The architecture's two-phase commit between DB2 and VSAM must be maintained throughout the change
3. **Data Migration Accuracy**: Left-padding existing 10-digit customer numbers with '00' ensures backward compatibility and data integrity
4. **Feature Flag Control**: Gradual rollout via feature flag minimizes risk and enables quick rollback if issues arise
5. **Comprehensive Testing**: Testing must cover all layers (presentation, business logic, persistence) and both DB2 and VSAM paths

### Recommended Execution Timeline

- **Week 1-2**: Workstream A (Copybook Updates) + Workstream F (BMS Maps)
- **Week 3-4**: Workstream D (COBOL Program Updates) - parallel development by program family
- **Week 5**: Workstream B (DB2 Schema) + Workstream C (VSAM Reorganization) - parallel development
- **Week 6**: Workstream E (CICS Configuration)
- **Week 7-8**: Workstream G (Testing) - comprehensive testing across all layers
- **Week 9**: Workstream H (Migration & Rollout) - phased deployment with monitoring

**Total Duration**: 9 weeks from start to full production rollout

### Key Decision Points

1. **Week 2**: Review copybook changes and BMS map updates with stakeholders
2. **Week 4**: Code review checkpoint for all COBOL program updates
3. **Week 6**: Review DB2 and VSAM migration scripts with DBAs
4. **Week 8**: Go/No-Go decision based on test results
5. **Week 9**: Daily go/no-go decisions during phased rollout

### Success Metrics

- **Zero data loss**: 100% of existing customer records migrated successfully
- **Zero service interruption**: No unplanned outages during deployment
- **Performance maintained**: < 5% increase in transaction response time
- **High availability**: > 99.9% transaction success rate post-deployment
- **Clean rollout**: < 0.1% two-phase commit failures during rollout