# GenApp Insurance System - Business Glossary
## Data Structure Reference and Field Interpretation

**Document Purpose**: This glossary extracts and interprets the key data structures from the GenApp CICS insurance application, providing business meaning for cryptic field names found in COBOL programs and copybooks.

---

## Table of Contents
1. [Core Data Structures](#core-data-structures)
2. [Customer Data](#customer-data)
3. [Policy Data](#policy-data)
4. [Policy Type Variants](#policy-type-variants)
5. [System Control Fields](#system-control-fields)
6. [Counter and Queue Names](#counter-and-queue-names)
7. [Field Naming Conventions](#field-naming-conventions)

---

## Core Data Structures

### COMMAREA (Communication Area)
The primary inter-program communication structure defined in [`lgcmarea.cpy`](../base/src/lgcmarea.cpy).

**Structure**: 32,500 bytes total
- Header: 18 bytes (control fields)
- Customer/Policy data: 32,482 bytes (variable content)

**Purpose**: Passes data between CICS programs in a layered architecture (presentation → business logic → data access).

---

## Customer Data

### Customer Identification

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-CUSTOMER-NUM` | Numeric | 10 digits | **Customer Number** - Unique identifier for each customer. Generated sequentially using CICS Named Counter Service or DB2 identity column. Range: 0000000001 to 9999999999 |
| `DB2-CUSTOMERNUM-INT` | Integer | 4 bytes | **Database Customer ID** - Internal DB2 representation of customer number as integer for identity column operations |

### Customer Personal Information

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-FIRST-NAME` | Alphanumeric | 10 chars | **First Name** - Customer's given name |
| `CA-LAST-NAME` | Alphanumeric | 20 chars | **Last Name** - Customer's family/surname |
| `CA-DOB` | Date | 10 chars | **Date of Birth** - Format: YYYY-MM-DD or MM/DD/YYYY. Used for age verification and demographic analysis |

### Customer Address

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-HOUSE-NAME` | Alphanumeric | 20 chars | **House/Building Name** - Named property (e.g., "Rose Cottage", "Oak Manor") |
| `CA-HOUSE-NUM` | Alphanumeric | 4 chars | **House/Street Number** - Numeric street address |
| `CA-POSTCODE` | Alphanumeric | 8 chars | **Postal Code** - UK postcode or international equivalent for geographic location |

### Customer Contact Information

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-PHONE-MOBILE` | Alphanumeric | 20 chars | **Mobile Phone** - Primary contact number, supports international format (+44...) |
| `CA-PHONE-HOME` | Alphanumeric | 20 chars | **Home Phone** - Secondary/landline contact number |
| `CA-EMAIL-ADDRESS` | Alphanumeric | 100 chars | **Email Address** - Electronic correspondence address |

### Customer Policy Summary

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-NUM-POLICIES` | Numeric | 3 digits | **Number of Policies** - Count of active insurance policies held by customer (000-999) |
| `CA-POLICY-DATA` | Alphanumeric | 32,267 bytes | **Policy Details Area** - Variable-length area containing multiple policy records |

---

## Policy Data

### Policy Identification

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-POLICY-NUM` | Numeric | 10 digits | **Policy Number** - Unique identifier for each insurance policy (0000000001-9999999999) |
| `DB2-POLICYTYPE` | Alpha | 1 char | **Policy Type Code** - Single character indicating policy category:<br>• `E` = Endowment (investment/life insurance)<br>• `H` = House (property insurance)<br>• `M` = Motor (vehicle insurance)<br>• `C` = Commercial (business property)<br>• `L` = Claim (insurance claim record) |

### Policy Common Fields
These fields appear in all policy types, defined in [`lgpolicy.cpy`](../base/src/lgpolicy.cpy).

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-ISSUE-DATE` | Date | 10 chars | **Issue Date** - When policy was created/issued (YYYY-MM-DD) |
| `CA-EXPIRY-DATE` | Date | 10 chars | **Expiry Date** - When policy coverage ends (YYYY-MM-DD) |
| `CA-LASTCHANGED` | Timestamp | 26 chars | **Last Modified** - Full timestamp of most recent policy update (YYYY-MM-DD-HH.MM.SS.mmmmmm) |
| `CA-BROKERID` | Numeric | 10 digits | **Broker ID** - Identifier for insurance broker/agent who sold the policy |
| `CA-BROKERSREF` | Alphanumeric | 10 chars | **Broker Reference** - Broker's internal reference number for this policy |
| `CA-PAYMENT` | Numeric | 6 digits | **Payment Amount** - Premium amount in pence/cents (£0.00 to £9,999.99 or $0.00 to $99.99) |

---

## Policy Type Variants

### Endowment Policy (Type E)
Investment-based life insurance product. Fields defined in [`soaipe1.cpy`](../base/src/soaipe1.cpy).

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-E-WITH-PROFITS` | Alpha | 1 char | **With-Profits Flag** - Indicates if policy includes profit-sharing (Y/N) |
| `CA-E-EQUITIES` | Alpha | 1 char | **Equities Investment** - Policy includes equity investments (Y/N) |
| `CA-E-MANAGED-FUND` | Alpha | 1 char | **Managed Fund** - Invested in managed fund (Y/N) |
| `CA-E-FUND-NAME` | Alphanumeric | 10 chars | **Fund Name** - Name of investment fund |
| `CA-E-TERM` | Numeric | 2 digits | **Policy Term** - Duration in years (01-99) |
| `CA-E-SUM-ASSURED` | Numeric | 6 digits | **Sum Assured** - Guaranteed payout amount in pounds/dollars (£0-£999,999) |
| `CA-E-LIFE-ASSURED` | Alphanumeric | 31 chars | **Life Assured** - Name of person whose life is insured |

**Business Context**: Endowment policies combine life insurance with investment, paying out on death or policy maturity.

### House Policy (Type H)
Property/home insurance. Fields defined in [`soaiph1.cpy`](../base/src/soaiph1.cpy).

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-H-PROPERTY-TYPE` | Alphanumeric | 15 chars | **Property Type** - Classification (e.g., "Detached", "Semi-Detached", "Flat", "Bungalow") |
| `CA-H-BEDROOMS` | Numeric | 3 digits | **Number of Bedrooms** - Property size indicator (000-999) |
| `CA-H-VALUE` | Numeric | 8 digits | **Property Value** - Insured value in pounds/dollars (£0-£99,999,999) |
| `CA-H-HOUSE-NAME` | Alphanumeric | 20 chars | **Property Name** - Named building (may duplicate customer address) |
| `CA-H-HOUSE-NUMBER` | Alphanumeric | 4 chars | **Property Number** - Street number (may duplicate customer address) |
| `CA-H-POSTCODE` | Alphanumeric | 8 chars | **Property Postcode** - Location code (may duplicate customer address) |

**Business Context**: Covers buildings and contents against fire, theft, flood, and other perils.

### Motor Policy (Type M)
Vehicle insurance. Fields defined in [`soaipm1.cpy`](../base/src/soaipm1.cpy).

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-M-MAKE` | Alphanumeric | 15 chars | **Vehicle Make** - Manufacturer (e.g., "Ford", "Toyota", "BMW") |
| `CA-M-MODEL` | Alphanumeric | 15 chars | **Vehicle Model** - Specific model name (e.g., "Focus", "Corolla", "3 Series") |
| `CA-M-VALUE` | Numeric | 6 digits | **Vehicle Value** - Insured value in pounds/dollars (£0-£999,999) |
| `CA-M-REGNUMBER` | Alphanumeric | 7 chars | **Registration Number** - License plate/registration (UK format: AB12CDE) |
| `CA-M-COLOUR` | Alphanumeric | 8 chars | **Vehicle Colour** - Paint color (e.g., "Red", "Blue", "Silver") |
| `CA-M-CC` | Numeric | 4 digits | **Engine Capacity** - Cubic centimeters (cc) - engine size (0000-9999) |
| `CA-M-MANUFACTURED` | Date | 10 chars | **Manufacture Date** - Year/date vehicle was made |
| `CA-M-PREMIUM` | Numeric | 6 digits | **Premium Amount** - Annual insurance cost in pence/cents (£0.00-£9,999.99) |
| `CA-M-ACCIDENTS` | Numeric | 6 digits | **Accident Count** - Number of claims/accidents on record (affects premium) |

**Business Context**: Covers vehicle damage, theft, and third-party liability. Premium calculated based on vehicle value, driver history, and accident record.

### Commercial Policy (Type C)
Business property insurance. Fields defined in [`soaipb1.cpy`](../base/src/soaipb1.cpy).

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-B-Address` | Alphanumeric | 255 chars | **Business Address** - Full commercial property address |
| `CA-B-Postcode` | Alphanumeric | 8 chars | **Business Postcode** - Location code for risk assessment |
| `CA-B-Latitude` | Alphanumeric | 11 chars | **GPS Latitude** - Geographic coordinate (e.g., "51.5074° N") |
| `CA-B-Longitude` | Alphanumeric | 11 chars | **GPS Longitude** - Geographic coordinate (e.g., "0.1278° W") |
| `CA-B-Customer` | Alphanumeric | 255 chars | **Business Customer** - Company/business name |
| `CA-B-PropType` | Alphanumeric | 255 chars | **Property Type** - Business classification (e.g., "Retail", "Office", "Warehouse", "Factory") |

#### Commercial Peril Coverage
Commercial policies cover multiple risk types (perils), each with risk level and premium:

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-B-FirePeril` | Numeric | 4 digits | **Fire Risk Level** - Risk assessment score (0000-9999, higher = greater risk) |
| `CA-B-FirePremium` | Numeric | 8 digits | **Fire Premium** - Cost to insure against fire (£0.00-£999,999.99) |
| `CA-B-CrimePeril` | Numeric | 4 digits | **Crime Risk Level** - Theft/burglary risk score |
| `CA-B-CrimePremium` | Numeric | 8 digits | **Crime Premium** - Cost to insure against theft/crime |
| `CA-B-FloodPeril` | Numeric | 4 digits | **Flood Risk Level** - Water damage risk score |
| `CA-B-FloodPremium` | Numeric | 8 digits | **Flood Premium** - Cost to insure against flooding |
| `CA-B-WeatherPeril` | Numeric | 4 digits | **Weather Risk Level** - Storm/weather damage risk score |
| `CA-B-WeatherPremium` | Numeric | 8 digits | **Weather Premium** - Cost to insure against weather damage |

#### Commercial Policy Status

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-B-Status` | Numeric | 4 digits | **Policy Status** - Current state code (e.g., 0001=Active, 0002=Pending, 0003=Rejected) |
| `CA-B-RejectReason` | Alphanumeric | 255 chars | **Rejection Reason** - Explanation if policy application was declined |

**Business Context**: Commercial policies are complex, multi-peril products with location-based risk assessment using GPS coordinates.

### Claim Record (Type L)
Insurance claim details. Fields defined in [`lgcmarea.cpy`](../base/src/lgcmarea.cpy) lines 95-103.

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-C-Num` | Numeric | 10 digits | **Claim Number** - Unique identifier for insurance claim |
| `CA-C-Date` | Date | 10 chars | **Claim Date** - When claim was filed (YYYY-MM-DD) |
| `CA-C-Paid` | Numeric | 8 digits | **Amount Paid** - Settlement amount paid to claimant (£0.00-£999,999.99) |
| `CA-C-Value` | Numeric | 8 digits | **Claim Value** - Amount claimed/requested (£0.00-£999,999.99) |
| `CA-C-Cause` | Alphanumeric | 255 chars | **Cause of Loss** - Description of incident (e.g., "Fire damage", "Vehicle collision", "Theft") |
| `CA-C-Observations` | Alphanumeric | 255 chars | **Claim Notes** - Adjuster observations, investigation notes, settlement details |

**Business Context**: Tracks claims against policies. `CA-C-Value` vs `CA-C-Paid` shows requested vs. approved amounts.

---

## System Control Fields

### Request Control

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-REQUEST-ID` | Alphanumeric | 6 chars | **Transaction Type** - Operation code indicating what action to perform:<br>• `01AAAA` = Add Customer<br>• `01IIII` = Inquire Customer<br>• `01UUUU` = Update Customer<br>• `01DDDD` = Delete Customer<br>• `01NNNN` = Inquire All Customers<br>• `02AAAA` = Add Policy<br>• `02IIII` = Inquire Policy<br>• `02UUUU` = Update Policy<br>• `02DDDD` = Delete Policy |
| `CA-RETURN-CODE` | Numeric | 2 digits | **Return Code** - Operation result status:<br>• `00` = Success<br>• `01` = Record not found<br>• `90` = SQL/Database error<br>• `98` = Invalid COMMAREA length<br>• Other codes indicate specific errors |

### Security Fields

| Field Name | Type | Size | Business Meaning |
|-----------|------|------|------------------|
| `CA-CUSTSECR-PASS` | Alphanumeric | 32 chars | **Customer Password** - Hashed password for customer authentication |
| `CA-CUSTSECR-COUNT` | Alphanumeric | 4 chars | **Login Attempt Count** - Number of failed login attempts |
| `CA-CUSTSECR-STATE` | Alpha | 1 char | **Security State** - Account status:<br>• `N` = New account<br>• `A` = Active<br>• `L` = Locked (too many failed attempts)<br>• `S` = Suspended |

---

## Counter and Queue Names

### CICS Named Counters
Used for generating sequential IDs. Defined in [`lgsetup.cbl`](../base/src/lgsetup.cbl).

| Counter Name | Purpose | Range |
|-------------|---------|-------|
| `GENACUSTNUM` | Customer number generation | Sequential customer IDs |
| `GENA01ICUS00`-`GENA01ICUS99` | Inquire Customer transaction counters | Statistics tracking (00-99) |
| `GENA01ACUS00`-`GENA01ACUS99` | Add Customer transaction counters | Statistics tracking (00-99) |
| `GENA01UCUS00`-`GENA01UCUS99` | Update Customer transaction counters | Statistics tracking (00-99) |
| `GENA01IMOT00`-`GENA01IMOT99` | Inquire Motor policy counters | Statistics tracking (00-99) |
| `GENA01AMOT00`-`GENA01AMOT99` | Add Motor policy counters | Statistics tracking (00-99) |
| `GENA01DMOT00`-`GENA01DMOT99` | Delete Motor policy counters | Statistics tracking (00-99) |
| `GENA01UMOT00`-`GENA01UMOT99` | Update Motor policy counters | Statistics tracking (00-99) |
| `GENA01IEND00`-`GENA01IEND99` | Inquire Endowment policy counters | Statistics tracking (00-99) |
| `GENA01AEND00`-`GENA01AEND99` | Add Endowment policy counters | Statistics tracking (00-99) |
| `GENA01DEND00`-`GENA01DEND99` | Delete Endowment policy counters | Statistics tracking (00-99) |
| `GENA01UEND00`-`GENA01UEND99` | Update Endowment policy counters | Statistics tracking (00-99) |
| `GENA01IHOU00`-`GENA01IHOU99` | Inquire House policy counters | Statistics tracking (00-99) |
| `GENA01AHOU00`-`GENA01AHOU99` | Add House policy counters | Statistics tracking (00-99) |
| `GENA01DHOU00`-`GENA01DHOU99` | Delete House policy counters | Statistics tracking (00-99) |
| `GENA01UHOU00`-`GENA01UHOU99` | Update House policy counters | Statistics tracking (00-99) |
| `GENA01ICOM00`-`GENA01ICOM99` | Inquire Commercial policy counters | Statistics tracking (00-99) |
| `GENA01ACOM00`-`GENA01ACOM99` | Add Commercial policy counters | Statistics tracking (00-99) |
| `GENA01DCOM00`-`GENA01DCOM99` | Delete Commercial policy counters | Statistics tracking (00-99) |

**Business Context**: Counters track transaction volumes for performance monitoring and capacity planning.

### Temporary Storage Queues (TSQ)
Used for logging and control. Defined in [`lgsetup.cbl`](../base/src/lgsetup.cbl) and [`lgstsq.cbl`](../base/src/lgstsq.cbl).

| Queue Name | Purpose |
|-----------|---------|
| `GENACNTL` | Control queue - stores low/high customer number ranges |
| `GENAERRS` | Error queue - logs error messages and diagnostic information |
| `GENASTRT` | Start queue - initialization and startup messages |
| `GENASTAT` | Statistics queue - transaction statistics and counters |

---

## Field Naming Conventions

### Prefix Meanings

| Prefix | Meaning | Example | Usage |
|--------|---------|---------|-------|
| `CA-` | Communication Area | `CA-CUSTOMER-NUM` | Fields in COMMAREA structure |
| `DB2-` | Database 2 | `DB2-FIRSTNAME` | Fields mapped to DB2 table columns |
| `WS-` | Working Storage | `WS-HEADER` | Temporary program variables |
| `EM-` | Error Message | `EM-DATE` | Error message components |
| `LGAC` | Life & General Add Customer | `LGACUS01` | Customer add programs |
| `LGIC` | Life & General Inquire Customer | `LGICUS01` | Customer inquiry programs |
| `LGUC` | Life & General Update Customer | `LGUCUS01` | Customer update programs |
| `LGDC` | Life & General Delete Customer | (not implemented) | Customer delete programs |
| `LGAP` | Life & General Add Policy | `LGAPOL01` | Policy add programs |
| `LGIP` | Life & General Inquire Policy | `LGIPOL01` | Policy inquiry programs |
| `LGUP` | Life & General Update Policy | `LGUPOL01` | Policy update programs |
| `LGDP` | Life & General Delete Policy | `LGDPOL01` | Policy delete programs |

### Suffix Meanings

| Suffix | Meaning | Example | Usage |
|--------|---------|---------|-------|
| `-NUM` | Number | `CA-CUSTOMER-NUM` | Numeric identifier |
| `-NAME` | Name | `CA-FIRST-NAME` | Text name field |
| `-DATE` | Date | `CA-ISSUE-DATE` | Date value |
| `-LEN` | Length | `WS-CUSTOMER-LEN` | Size/length value |
| `-ID` | Identifier | `CA-REQUEST-ID` | ID code |
| `-CODE` | Code | `CA-RETURN-CODE` | Status/result code |
| `DB01` | Database 01 | `LGACDB01` | First database access program |
| `VS01` | VSAM 01 | `LGACVS01` | First VSAM access program |
| `01` | Business Logic 01 | `LGACUS01` | First business logic program |

### Type Indicators

| Indicator | Meaning | Example |
|-----------|---------|---------|
| `-E-` | Endowment | `CA-E-TERM` |
| `-H-` | House | `CA-H-VALUE` |
| `-M-` | Motor | `CA-M-MAKE` |
| `-B-` | Business/Commercial | `CA-B-Address` |
| `-C-` | Claim | `CA-C-Num` |

---

## Data Structure Sizes

### COMMAREA Variants

| Copybook | Total Size | Purpose |
|----------|-----------|---------|
| `lgcmarea.cpy` | 32,500 bytes | Full COMMAREA with all policy types |
| `soaic01.cpy` | ~30,215 bytes | Customer inquiry (reduced for WSIM) |
| `soaipe1.cpy` | ~30,100 bytes | Endowment policy (reduced for WSIM) |
| `soaiph1.cpy` | ~30,100 bytes | House policy (reduced for WSIM) |
| `soaipm1.cpy` | ~30,100 bytes | Motor policy (reduced for WSIM) |
| `soaipb1.cpy` | ~30,400 bytes | Commercial policy (reduced for WSIM) |

**Note**: SOA (Service-Oriented Architecture) copybooks are reduced below 32K for WSIM (Web Services Interface Manager) compatibility.

### DB2 Record Lengths
Defined in [`lgpolicy.cpy`](../base/src/lgpolicy.cpy) lines 16-28.

| Structure | Length | Purpose |
|-----------|--------|---------|
| `WS-CUSTOMER-LEN` | 72 bytes | Customer table record |
| `WS-POLICY-LEN` | 72 bytes | Policy table record |
| `WS-ENDOW-LEN` | 52 bytes | Endowment policy details |
| `WS-HOUSE-LEN` | 58 bytes | House policy details |
| `WS-MOTOR-LEN` | 65 bytes | Motor policy details |
| `WS-COMM-LEN` | 1,102 bytes | Commercial policy details |
| `WS-CLAIM-LEN` | 546 bytes | Claim record details |
| `WS-FULL-ENDOW-LEN` | 124 bytes | Complete endowment record |
| `WS-FULL-HOUSE-LEN` | 130 bytes | Complete house record |
| `WS-FULL-MOTOR-LEN` | 137 bytes | Complete motor record |
| `WS-FULL-COMM-LEN` | 1,174 bytes | Complete commercial record |
| `WS-FULL-CLAIM-LEN` | 618 bytes | Complete claim record |

---

## Program Naming Convention

### Program Name Structure: `LGxxyyzz`

- `LG` = Life & General (company prefix)
- `xx` = Operation type:
  - `AC` = Add Customer
  - `IC` = Inquire Customer
  - `UC` = Update Customer
  - `DC` = Delete Customer
  - `AP` = Add Policy
  - `IP` = Inquire Policy
  - `UP` = Update Policy
  - `DP` = Delete Policy
  - `SE` = Setup
  - `ST` = Statistics
  - `WE` = Web
- `yy` = Layer:
  - `US` = Business logic (customer)
  - `OL` = Business logic (policy)
  - `DB` = Database access (DB2)
  - `VS` = VSAM file access
  - `SQ` = Queue operations
  - `TU` = Setup/utility
  - `AT` = Statistics
  - `BS` = Web services
- `zz` = Sequence number: `01`, `02`, etc.

**Examples**:
- `LGACUS01` = Life & General, Add Customer, Business Logic, Program 01
- `LGACDB01` = Life & General, Add Customer, Database Access, Program 01
- `LGIPOL01` = Life & General, Inquire Policy, Business Logic, Program 01
- `LGAPDB01` = Life & General, Add Policy, Database Access, Program 01

---

## Business Rules Encoded in Data

### Customer Number Generation
- Uses CICS Named Counter Service (`GENACUSTNUM`) when available
- Falls back to DB2 identity column if counter service unavailable
- Sequential allocation ensures unique customer IDs
- Tracked in TSQ `GENACNTL` with low/high ranges

### Policy Number Allocation
- Generated per policy type
- Linked to customer via `CA-CUSTOMER-NUM`
- One customer can have multiple policies of different types

### Premium Calculation
- Motor: Based on vehicle value, engine size (CC), and accident history
- House: Based on property value, type, and location (postcode)
- Commercial: Sum of individual peril premiums (fire + crime + flood + weather)
- Endowment: Fixed payment amount for investment term

### Data Validation Rules
- COMMAREA length must match expected size for operation
- Customer number must exist before adding policies
- Dates must be in valid format (YYYY-MM-DD)
- Numeric fields must contain valid digits
- Return code `00` indicates success; any other value is an error

---

## Summary

This glossary documents the **actual data structures** used in the GenApp insurance system:

1. **Customer Data**: Personal details, address, contact information
2. **Policy Data**: Common fields plus type-specific details (Endowment, House, Motor, Commercial, Claim)
3. **Control Fields**: Request IDs, return codes, security credentials
4. **System Resources**: Named counters, temporary storage queues
5. **Naming Conventions**: Prefixes, suffixes, and program naming patterns

**Key Insights**:
- System uses 10-digit numeric IDs for customers and policies
- COMMAREA is the primary inter-program communication mechanism
- Policy types are distinguished by single-character codes (E/H/M/C/L)
- Commercial policies are most complex with multi-peril coverage
- System includes comprehensive transaction statistics tracking
- Architecture follows three-tier pattern: presentation → business logic → data access

---

**Document Version**: 1.0  
**Last Updated**: 2026-06-23  
**Source Files**: [`lgcmarea.cpy`](../base/src/lgcmarea.cpy), [`lgpolicy.cpy`](../base/src/lgpolicy.cpy), [`soaic01.cpy`](../base/src/soaic01.cpy), [`soaipb1.cpy`](../base/src/soaipb1.cpy), [`soaipe1.cpy`](../base/src/soaipe1.cpy), [`soaiph1.cpy`](../base/src/soaiph1.cpy), [`soaipm1.cpy`](../base/src/soaipm1.cpy), [`lgsetup.cbl`](../base/src/lgsetup.cbl), [`lgstsq.cbl`](../base/src/lgstsq.cbl), [`lgastat1.cbl`](../base/src/lgastat1.cbl)