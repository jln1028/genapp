# Modernization Architecture for GenApp Insurance Application

## Executive Summary

This document proposes a modular, API-driven architecture for in-place modernization of the GenApp general insurance application on the mainframe. The strategy preserves existing COBOL business logic while exposing services through RESTful APIs, enabling gradual modernization without disrupting operations.

## Table of Contents

1. [Current Architecture Analysis](#current-architecture-analysis)
2. [Identified Business Services](#identified-business-services)
3. [Proposed API Endpoints](#proposed-api-endpoints)
4. [Modular Architecture Design](#modular-architecture-design)
5. [Implementation Strategy](#implementation-strategy)
6. [Technology Stack](#technology-stack)
7. [Migration Phases](#migration-phases)
8. [Risk Management](#risk-management)
9. [Success Metrics](#success-metrics)

---

## Current Architecture Analysis

### Application Overview

The GenApp application is a 3-tier CICS-based general insurance system with:

- **Presentation Layer**: 3270 BMS maps ([`ssmap.bms`](../base/src/ssmap.bms))
- **Business Logic Layer**: COBOL programs (LG*CUS01, LG*POL01 families)
- **Data Access Layer**: COBOL programs (LG*DB01, LG*VS01 families)
- **Persistence**: Db2 database + VSAM files (two-phase commit)

### Current Transaction Model

| Transaction | Purpose | Entry Program |
|-------------|---------|---------------|
| `SSC1` | Customer management menu | [`LGTESTC1`](../base/src/lgtestc1.cbl) |
| `SSP1` | Motor policy menu | [`LGTESTP1`](../base/src/lgtestp1.cbl) |
| `SSP2` | Endowment policy menu | [`LGTESTP2`](../base/src/lgtestp2.cbl) |
| `SSP3` | House policy menu | [`LGTESTP3`](../base/src/lgtestp3.cbl) |
| `SSP4` | Commercial property menu | [`LGTESTP4`](../base/src/lgtestp4.cbl) |
| `LGSE` | System initialization | [`LGSETUP`](../base/src/lgsetup.cbl) |

### Program Architecture Pattern

```
Presentation → Business Logic → Data Access → Persistence
LGTESTC1    → LGACUS01       → LGACDB01    → Db2/VSAM
            → LGICUS01       → LGICDB01
            → LGUCUS01       → LGUCDB01
```

### Communication Area (COMMAREA)

The application uses a standardized COMMAREA structure ([`lgcmarea.cpy`](../base/src/lgcmarea.cpy)) with:
- **Request ID** (6 bytes): Operation routing
- **Return Code** (2 bytes): Status indicator
- **Customer Number** (10 bytes): Primary key
- **Request-Specific Data** (32,482 bytes): Polymorphic payload

---

## Identified Business Services

Based on program analysis and business domain modeling, the following logical services have been identified:

### 1. Customer Management Service

**Business Capability**: Manage customer lifecycle and information

**Programs**:
- [`LGACUS01`](../base/src/lgacus01.cbl) - Add customer business logic
- [`LGICUS01`](../base/src/lgicus01.cbl) - Inquire customer business logic
- [`LGUCUS01`](../base/src/lgucus01.cbl) - Update customer business logic
- [`LGACDB01`](../base/src/lgacdb01.cbl) - Customer Db2 persistence
- [`LGACVS01`](../base/src/lgacvs01.cbl) - Customer VSAM persistence
- [`LGICDB01`](../base/src/lgicdb01.cbl) - Customer Db2 inquiry
- [`LGICVS01`](../base/src/lgicvs01.cbl) - Customer VSAM inquiry
- [`LGUCDB01`](../base/src/lgucdb01.cbl) - Customer Db2 update
- [`LGUCVS01`](../base/src/lgucvs01.cbl) - Customer VSAM update

**Data Entities**:
- Customer profile (name, DOB, address, contact info)
- Customer number (auto-generated via Named Counter or Db2 identity)
- Customer security credentials

**Business Rules**:
- Customer number uniqueness
- Two-phase commit (Db2 + VSAM)
- Address normalization (postcode uppercase, low-values to spaces)

### 2. Policy Management Service

**Business Capability**: Manage insurance policy lifecycle

**Programs**:
- [`LGAPOL01`](../base/src/lgapol01.cbl) - Add policy business logic
- [`LGIPOL01`](../base/src/lgipol01.cbl) - Inquire policy business logic
- [`LGUPOL01`](../base/src/lgupol01.cbl) - Update policy business logic
- [`LGDPOL01`](../base/src/lgdpol01.cbl) - Delete policy business logic
- [`LGAPDB01`](../base/src/lgapdb01.cbl) - Policy Db2 persistence
- [`LGAPVS01`](../base/src/lgapvs01.cbl) - Policy VSAM persistence
- [`LGIPDB01`](../base/src/lgipdb01.cbl) - Policy Db2 inquiry
- [`LGIPVS01`](../base/src/lgipvs01.cbl) - Policy VSAM inquiry
- [`LGUPDB01`](../base/src/lgupdb01.cbl) - Policy Db2 update
- [`LGUPVS01`](../base/src/lgupvs01.cbl) - Policy VSAM update
- [`LGDPDB01`](../base/src/lgdpdb01.cbl) - Policy Db2 deletion
- [`LGDPVS01`](../base/src/lgdpvs01.cbl) - Policy VSAM deletion

**Data Entities**:
- Policy header (number, type, dates, broker, payment)
- Policy type-specific details (motor, endowment, house, commercial)

**Business Rules**:
- Policy number auto-generation (Db2 identity)
- Customer must exist (referential integrity)
- Two-phase commit (Db2 + VSAM)
- Policy type validation (M/E/H/C)

### 3. Motor Policy Service

**Business Capability**: Specialized motor insurance policy management

**Data Entities** (from [`lgpolicy.cpy`](../base/src/lgpolicy.cpy)):
- Vehicle make, model, registration
- Vehicle value, color, engine CC
- Manufacturing date
- Premium calculation
- Accident history

**Business Rules**:
- Vehicle-specific validation
- Premium calculation based on vehicle attributes

### 4. Endowment Policy Service

**Business Capability**: Specialized endowment insurance policy management

**Data Entities**:
- Investment options (with-profits, equities, managed fund)
- Fund name
- Term duration
- Sum assured
- Life assured details

**Business Rules**:
- Investment allocation validation
- Term-based calculations

### 5. House Policy Service

**Business Capability**: Specialized house insurance policy management

**Data Entities**:
- Property type
- Number of bedrooms
- Property value
- Property address (house name, number, postcode)

**Business Rules**:
- Property valuation
- Location-based risk assessment

### 6. Commercial Property Policy Service

**Business Capability**: Specialized commercial property insurance management

**Data Entities**:
- Business address with geolocation (latitude, longitude)
- Customer business name
- Property type
- Peril coverage (fire, crime, flood, weather)
- Premium per peril
- Policy status and rejection reasons

**Business Rules**:
- Multi-peril risk assessment
- Geographic risk modeling
- Complex premium calculations

### 7. Statistics and Monitoring Service

**Business Capability**: Transaction monitoring and business analytics

**Programs**:
- [`LGASTAT1`](../base/src/lgastat1.cbl) - Update transaction counters
- [`LGWEBST5`](../base/src/lgwebst5.cbl) - Copy counters to temp storage
- [`LGSTSQ`](../base/src/lgstsq.cbl) - Write to temp storage queue

**Data Entities**:
- Transaction counts by type
- Error logs
- Performance metrics

---

## Proposed API Endpoints

### RESTful API Design Principles

- **Resource-oriented**: URLs represent business entities
- **HTTP verbs**: Standard CRUD operations (GET, POST, PUT, DELETE)
- **Stateless**: Each request contains all necessary information
- **JSON payloads**: Modern, language-agnostic data format
- **Versioning**: `/api/v1/` prefix for future compatibility
- **HATEOAS**: Hypermedia links for resource navigation

### API Endpoint Mapping

#### Customer Management API

```
Base Path: /api/v1/customers
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `POST` | `/api/v1/customers` | [`LGACUS01`](../base/src/lgacus01.cbl) | Create new customer |
| `GET` | `/api/v1/customers/{customerNumber}` | [`LGICUS01`](../base/src/lgicus01.cbl) | Retrieve customer details |
| `PUT` | `/api/v1/customers/{customerNumber}` | [`LGUCUS01`](../base/src/lgucus01.cbl) | Update customer information |
| `GET` | `/api/v1/customers/{customerNumber}/policies` | [`LGICUS01`](../base/src/lgicus01.cbl) | List customer's policies |

**Request/Response Examples**:

```json
POST /api/v1/customers
{
  "firstName": "John",
  "lastName": "Smith",
  "dateOfBirth": "1985-06-15",
  "address": {
    "houseName": "Rose Cottage",
    "houseNumber": "42",
    "postcode": "SW1A 1AA"
  },
  "contact": {
    "mobile": "+44 7700 900123",
    "home": "+44 20 7946 0958",
    "email": "john.smith@example.com"
  }
}

Response: 201 Created
{
  "customerNumber": "0000000123",
  "firstName": "John",
  "lastName": "Smith",
  "dateOfBirth": "1985-06-15",
  "address": {
    "houseName": "Rose Cottage",
    "houseNumber": "42",
    "postcode": "SW1A 1AA"
  },
  "contact": {
    "mobile": "+44 7700 900123",
    "home": "+44 20 7946 0958",
    "email": "john.smith@example.com"
  },
  "numberOfPolicies": 0,
  "_links": {
    "self": "/api/v1/customers/0000000123",
    "policies": "/api/v1/customers/0000000123/policies"
  }
}
```

#### Policy Management API

```
Base Path: /api/v1/policies
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `POST` | `/api/v1/policies` | [`LGAPOL01`](../base/src/lgapol01.cbl) | Create new policy |
| `GET` | `/api/v1/policies/{policyNumber}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | Retrieve policy details |
| `PUT` | `/api/v1/policies/{policyNumber}` | [`LGUPOL01`](../base/src/lgupol01.cbl) | Update policy |
| `DELETE` | `/api/v1/policies/{policyNumber}` | [`LGDPOL01`](../base/src/lgdpol01.cbl) | Delete policy |
| `GET` | `/api/v1/policies?customerId={id}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | List policies by customer |
| `GET` | `/api/v1/policies?type={type}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | List policies by type |

#### Motor Policy API

```
Base Path: /api/v1/policies/motor
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `POST` | `/api/v1/policies/motor` | [`LGAPOL01`](../base/src/lgapol01.cbl) | Create motor policy |
| `GET` | `/api/v1/policies/motor/{policyNumber}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | Get motor policy details |
| `PUT` | `/api/v1/policies/motor/{policyNumber}` | [`LGUPOL01`](../base/src/lgupol01.cbl) | Update motor policy |

**Request Example**:

```json
POST /api/v1/policies/motor
{
  "customerNumber": "0000000123",
  "vehicle": {
    "make": "Toyota",
    "model": "Camry",
    "registrationNumber": "AB12CDE",
    "color": "Silver",
    "engineCC": 2500,
    "manufacturedDate": "2020-03-15",
    "value": 25000
  },
  "coverage": {
    "issueDate": "2024-01-01",
    "expiryDate": "2025-01-01",
    "brokerId": "0000000001",
    "brokersRef": "BRK-2024-01",
    "payment": 1200
  },
  "premium": 1200,
  "accidentHistory": 0
}
```

#### Endowment Policy API

```
Base Path: /api/v1/policies/endowment
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `POST` | `/api/v1/policies/endowment` | [`LGAPOL01`](../base/src/lgapol01.cbl) | Create endowment policy |
| `GET` | `/api/v1/policies/endowment/{policyNumber}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | Get endowment details |
| `PUT` | `/api/v1/policies/endowment/{policyNumber}` | [`LGUPOL01`](../base/src/lgupol01.cbl) | Update endowment policy |

#### House Policy API

```
Base Path: /api/v1/policies/house
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `POST` | `/api/v1/policies/house` | [`LGAPOL01`](../base/src/lgapol01.cbl) | Create house policy |
| `GET` | `/api/v1/policies/house/{policyNumber}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | Get house policy details |
| `PUT` | `/api/v1/policies/house/{policyNumber}` | [`LGUPOL01`](../base/src/lgupol01.cbl) | Update house policy |

#### Commercial Property Policy API

```
Base Path: /api/v1/policies/commercial
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `POST` | `/api/v1/policies/commercial` | [`LGAPOL01`](../base/src/lgapol01.cbl) | Create commercial policy |
| `GET` | `/api/v1/policies/commercial/{policyNumber}` | [`LGIPOL01`](../base/src/lgipol01.cbl) | Get commercial details |
| `PUT` | `/api/v1/policies/commercial/{policyNumber}` | [`LGUPOL01`](../base/src/lgupol01.cbl) | Update commercial policy |

#### Statistics and Monitoring API

```
Base Path: /api/v1/statistics
```

| Method | Endpoint | COBOL Program | Description |
|--------|----------|---------------|-------------|
| `GET` | `/api/v1/statistics/transactions` | [`LGWEBST5`](../base/src/lgwebst5.cbl) | Get transaction counts |
| `GET` | `/api/v1/statistics/errors` | [`LGSTSQ`](../base/src/lgstsq.cbl) | Retrieve error logs |
| `GET` | `/api/v1/health` | [`LGSETUP`](../base/src/lgsetup.cbl) | System health check |

---

## Modular Architecture Design

### Architecture Principles

1. **Preserve Existing Logic**: Keep COBOL business logic intact
2. **API Gateway Pattern**: Single entry point for all API requests
3. **Service Facade**: Thin adapter layer between REST and COBOL
4. **Gradual Migration**: Modernize incrementally without disruption
5. **Backward Compatibility**: Maintain 3270 interface during transition

### Proposed Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Consumers                             │
│  (Web Apps, Mobile Apps, Partner Systems, Microservices)        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS/REST
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      API Gateway Layer                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  - Authentication/Authorization (OAuth 2.0, JWT)         │  │
│  │  - Rate Limiting & Throttling                            │  │
│  │  - Request Routing                                       │  │
│  │  - API Versioning                                        │  │
│  │  - Logging & Monitoring                                  │  │
│  │  - Circuit Breaker Pattern                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                    (z/OS Connect or API ML)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Internal Protocol
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                   Service Adapter Layer                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  REST-to-COMMAREA Transformation                         │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │  │
│  │  │ Customer   │  │  Policy    │  │ Statistics │         │  │
│  │  │  Adapter   │  │  Adapter   │  │  Adapter   │         │  │
│  │  └────────────┘  └────────────┘  └────────────┘         │  │
│  │  - JSON ↔ COMMAREA mapping                              │  │
│  │  - Data validation                                       │  │
│  │  - Error handling & translation                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                    (New COBOL/Java Programs)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ EXEC CICS LINK
                             │
┌────────────────────────────▼────────────────────────────────────┐
│              Existing Business Logic Layer                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Customer Services    │  Policy Services                  │  │
│  │  ┌──────────────┐    │  ┌──────────────┐                │  │
│  │  │  LGACUS01    │    │  │  LGAPOL01    │                │  │
│  │  │  LGICUS01    │    │  │  LGIPOL01    │                │  │
│  │  │  LGUCUS01    │    │  │  LGUPOL01    │                │  │
│  │  └──────────────┘    │  │  LGDPOL01    │                │  │
│  │                      │  └──────────────┘                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                    (Existing COBOL Programs)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ EXEC CICS LINK
                             │
┌────────────────────────────▼────────────────────────────────────┐
│              Existing Data Access Layer                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Db2 Access           │  VSAM Access                      │  │
│  │  ┌──────────────┐    │  ┌──────────────┐                │  │
│  │  │  LGACDB01    │    │  │  LGACVS01    │                │  │
│  │  │  LGICDB01    │    │  │  LGICVS01    │                │  │
│  │  │  LGUCDB01    │    │  │  LGUCVS01    │                │  │
│  │  │  LGAPDB01    │    │  │  LGAPVS01    │                │  │
│  │  │  LGIPDB01    │    │  │  LGIPVS01    │                │  │
│  │  │  LGUPDB01    │    │  │  LGUPVS01    │                │  │
│  │  │  LGDPDB01    │    │  │  LGDPVS01    │                │  │
│  │  └──────────────┘    │  └──────────────┘                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                    (Existing COBOL Programs)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Two-Phase Commit
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    Persistence Layer                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ┌──────────────┐              ┌──────────────┐          │  │
│  │  │  Db2 Tables  │              │  VSAM Files  │          │  │
│  │  │  - CUSTOMER  │              │  - KSDSCUST  │          │  │
│  │  │  - POLICY    │              │  - KSDSPOLY  │          │  │
│  │  │  - MOTOR     │              │              │          │  │
│  │  │  - ENDOWMENT │              │              │          │  │
│  │  │  - HOUSE     │              │              │          │  │
│  │  │  - COMMERCIAL│              │              │          │  │
│  │  └──────────────┘              └──────────────┘          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                  Supporting Infrastructure                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  - Named Counter Server (Customer Number Generation)     │  │
│  │  - Temporary Storage Queues (Error Logging, Control)     │  │
│  │  - Coupling Facility (Shared Resources)                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              Legacy 3270 Interface (Parallel)                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Presentation Programs: LGTESTC1, LGTESTP1-P4           │  │
│  │  Transactions: SSC1, SSP1, SSP2, SSP3, SSP4             │  │
│  │  BMS Maps: SSMAP                                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│  (Continues to use existing business logic via EXEC CICS LINK)  │
└─────────────────────────────────────────────────────────────────┘
```

### Component Descriptions

#### 1. API Gateway Layer

**Technology Options**:
- **z/OS Connect EE**: IBM's enterprise API gateway for z/OS
- **Zowe API Mediation Layer**: Open-source API gateway
- **IBM API Connect**: Full-featured API management platform

**Responsibilities**:
- External API exposure and management
- Security enforcement (OAuth 2.0, JWT tokens)
- Rate limiting and quota management
- Request/response transformation
- API versioning and routing
- Monitoring and analytics
- Circuit breaker for fault tolerance

#### 2. Service Adapter Layer

**Purpose**: Bridge between REST/JSON and COBOL COMMAREA

**Implementation Options**:
- **Option A**: COBOL JSON parsing (Enterprise COBOL 6.3+)
- **Option B**: Java adapters in Liberty/WebSphere
- **Option C**: Node.js adapters with CICS Node.js support

**Request ID Mapping** (from [`lgcmarea.cpy`](../base/src/lgcmarea.cpy)):

| Operation | Request ID | Target Program |
|-----------|------------|----------------|
| Add Customer | `01AAAA` | [`LGACUS01`](../base/src/lgacus01.cbl) |
| Inquire Customer | `01IIII` | [`LGICUS01`](../base/src/lgicus01.cbl) |
| Update Customer | `01UUUU` | [`LGUCUS01`](../base/src/lgucus01.cbl) |
| Add Policy | `01APPP` | [`LGAPOL01`](../base/src/lgapol01.cbl) |
| Inquire Policy | `01IPPP` | [`LGIPOL01`](../base/src/lgipol01.cbl) |
| Update Policy | `01UPPP` | [`LGUPOL01`](../base/src/lgupol01.cbl) |
| Delete Policy | `01DPPP` | [`LGDPOL01`](../base/src/lgdpol01.cbl) |

#### 3. Business Logic Layer (Unchanged)

**Preservation Strategy**:
- No changes to existing COBOL business logic programs
- Continue using COMMAREA-based interfaces
- Maintain existing EXEC CICS LINK patterns
- Preserve two-phase commit logic
- Keep error handling mechanisms

**Benefits**:
- Zero risk to proven business logic
- No regression testing of core functions
- Gradual migration path
- Parallel operation of 3270 and API interfaces

---

## Implementation Strategy

### Phase 1: Foundation (Months 1-3)

**Objectives**:
- Establish API infrastructure
- Create adapter framework
- Implement authentication/authorization

**Deliverables**:
1. API Gateway Setup (z/OS Connect or Zowe API ML)
2. Adapter Framework (JSON ↔ COMMAREA transformation)
3. Pilot Service: Customer Inquiry API
4. Security Infrastructure (OAuth 2.0, JWT)

**Success Criteria**:
- Customer inquiry API operational
- Response time < 200ms (95th percentile)
- Zero impact on existing 3270 transactions

### Phase 2: Core Services (Months 4-6)

**Objectives**:
- Implement full Customer Management API
- Implement basic Policy Management API

**Deliverables**:
1. Customer Management API (POST, PUT, GET)
2. Policy Management API (POST, GET, PUT, DELETE)
3. Integration Testing
4. Performance Tuning

**Success Criteria**:
- All CRUD operations functional
- API response times meet SLAs
- 99.9% availability

### Phase 3: Specialized Services (Months 7-9)

**Objectives**:
- Implement policy type-specific APIs
- Add advanced query capabilities

**Deliverables**:
1. Motor Policy API
2. Endowment Policy API
3. House Policy API
4. Commercial Property API
5. Query Enhancements (search, filter, pagination)

**Success Criteria**:
- All policy types accessible via API
- Complex queries performant
- Business rules correctly enforced

### Phase 4: Advanced Features (Months 10-12)

**Objectives**:
- Add analytics and reporting
- Implement event-driven capabilities
- Enable partner integrations

**Deliverables**:
1. Statistics and Monitoring API
2. Event Streaming (Kafka, MQ)
3. Partner API Portal
4. Performance Optimization

**Success Criteria**:
- Real-time analytics available
- Event-driven integrations operational
- Partner onboarding < 1 week

### Phase 5: Migration and Decommissioning (Months 13-18)

**Objectives**:
- Migrate consumers from 3270 to API
- Modernize presentation layer
- Decommission legacy interfaces (optional)

**Deliverables**:
1. Web Application (modern UI)
2. Mobile Applications (iOS, Android)
3. 3270 Coexistence Strategy
4. Legacy Decommissioning Plan

**Success Criteria**:
- 80% of users migrated to new interfaces
- Zero business disruption
- Positive user feedback

---

## Technology Stack

### Mainframe Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| **API Gateway** | z/OS Connect EE 3.0+ or Zowe API ML | External API exposure |
| **Application Server** | CICS TS 5.6+ | Transaction processing |
| **Business Logic** | Enterprise COBOL 6.3+ | Existing programs |
| **Adapter Layer** | COBOL 6.3+ or Java (Liberty) | REST-COMMAREA transformation |
| **Database** | Db2 12 for z/OS | Relational persistence |
| **File System** | VSAM KSDS | Legacy file storage |
| **Security** | RACF + OAuth 2.0 | Authentication/Authorization |
| **Monitoring** | IBM Z Monitoring (Instana) | Performance tracking |

### Integration Technologies

| Component | Technology | Purpose |
|-----------|------------|---------|
| **API Management** | IBM API Connect | API lifecycle management |
| **Message Queue** | IBM MQ | Async messaging |
| **Event Streaming** | IBM Event Streams (Kafka) | Event-driven architecture |
| **Service Mesh** | Istio on OpenShift | Microservices orchestration |

---

## Migration Phases

### Phased Approach Summary

| Phase | Duration | Risk | Business Value | Complexity |
|-------|----------|------|----------------|------------|
| Phase 1: Foundation | 3 months | Low | Medium | Medium |
| Phase 2: Core Services | 3 months | Medium | High | Medium |
| Phase 3: Specialized Services | 3 months | Medium | High | High |
| Phase 4: Advanced Features | 3 months | Medium | High | High |
| Phase 5: Migration | 6 months | High | Very High | Very High |

---

## Risk Management

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Performance degradation | High | Medium | Load testing, caching, connection pooling |
| Security vulnerabilities | Critical | Low | Security audits, penetration testing |
| Data inconsistency | High | Low | Maintain two-phase commit, thorough testing |
| Integration failures | Medium | Medium | Circuit breakers, retry logic, monitoring |
| Adapter bugs | Medium | Medium | Comprehensive unit testing, code reviews |

### Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| User resistance | Medium | High | Training, change management, gradual rollout |
| Business disruption | Critical | Low | Parallel operation, rollback procedures |
| Budget overruns | High | Medium | Phased approach, regular reviews |
| Timeline delays | Medium | Medium | Agile methodology, buffer time |
| Vendor dependencies | Medium | Low | Multi-vendor strategy, open standards |

---

## Success Metrics

### Technical KPIs

- **API Response Time**: < 200ms (95th percentile)
- **Availability**: 99.9% uptime
- **Throughput**: Support 1000 TPS (transactions per second)
- **Error Rate**: < 0.1% of requests
- **Security**: Zero critical vulnerabilities

### Business KPIs

- **User Adoption**: 80% migration within 18 months
- **Partner Onboarding**: < 1 week from request to production
- **Development Velocity**: 50% faster feature delivery
- **Cost Reduction**: 30% reduction in maintenance costs
- **Customer Satisfaction**: > 4.5/5 rating

### Operational KPIs

- **Deployment Frequency**: Weekly releases
- **Mean Time to Recovery (MTTR)**: < 1 hour
- **Change Failure Rate**: < 5%
- **Lead Time for Changes**: < 2 weeks

---

## Conclusion

This modernization architecture provides a pragmatic, low-risk path to expose GenApp's insurance services as modern RESTful APIs while preserving the proven COBOL business logic. The modular approach enables gradual migration, parallel operation of legacy and modern interfaces, and incremental value delivery.

**Key Benefits**:
- **Zero disruption** to existing operations
- **Rapid time-to-market** for new channels (web, mobile, partners)
- **Future-proof** architecture supporting microservices evolution
- **Cost-effective** by reusing existing investments
- **Risk-mitigated** through phased implementation

**Next Steps**:
1. Stakeholder review and approval
2. Proof of concept for Phase 1 pilot
3. Detailed technical design for adapter layer
4. Resource allocation and team formation
5. Kickoff Phase 1 implementation

---

**Document Version**: 1.0  
**Last Updated**: 2026-06-24  
**Author**: Z Architect Mode  
**Status**: Draft for Review