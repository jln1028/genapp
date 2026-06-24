# Airline Business Glossary
## Mapping Insurance System Data Structures to Airline Concepts

**Document Purpose**: This glossary interprets the cryptic field names from the GenApp insurance application and maps them to equivalent airline industry concepts, providing a business-oriented reference for understanding how this system could be adapted for airline operations.

---

## Core Entity Mappings

### Customer → Passenger/Frequent Flyer

The insurance system's customer entity maps directly to airline passengers and frequent flyer members.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-CUSTOMER-NUM` | Frequent Flyer Number / Passenger ID | Unique identifier for passenger (10 digits) |
| `CA-FIRST-NAME` | Passenger First Name | Given name (10 chars) |
| `CA-LAST-NAME` | Passenger Last Name | Family name (20 chars) |
| `CA-DOB` | Date of Birth | Passenger DOB for age verification, child/senior fares |
| `CA-HOUSE-NAME` | Address Line 1 | Primary residence name/building |
| `CA-HOUSE-NUM` | Address Line 2 | Street number |
| `CA-POSTCODE` | Postal/ZIP Code | Geographic location for marketing, route planning |
| `CA-PHONE-MOBILE` | Mobile Contact | Primary contact for flight alerts, gate changes |
| `CA-PHONE-HOME` | Alternate Contact | Secondary contact number |
| `CA-EMAIL-ADDRESS` | Email Address | Digital boarding passes, booking confirmations |
| `CA-NUM-POLICIES` | Number of Active Bookings | Count of current flight reservations |

**Airline Business Context**: 
- Customer number becomes frequent flyer membership ID
- Address data supports loyalty program communications and regional marketing
- Contact information critical for real-time flight notifications
- DOB enables age-based fare rules (infant, child, adult, senior)

---

### Policy → Flight Booking/Reservation

Insurance policies map to flight bookings, with policy types representing different booking classes or product types.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-POLICY-NUM` | Booking Reference / PNR | Unique 10-digit reservation identifier |
| `DB2-POLICYTYPE` | Booking Class / Product Type | E=Economy, H=Premium Economy, M=Business, C=First Class, B=Cargo |
| `CA-ISSUE-DATE` | Booking Date | When reservation was created |
| `CA-EXPIRY-DATE` | Travel Date / Departure Date | When flight departs |
| `CA-LASTCHANGED` | Last Modified Timestamp | Most recent booking change (26 chars) |
| `CA-BROKERID` | Travel Agent ID / Channel | Booking source (10 digits) |
| `CA-BROKERSREF` | Agent Reference Number | Travel agent's internal booking ID |
| `CA-PAYMENT` | Fare Amount | Ticket price in cents (6 digits = up to $9,999.99) |

**Airline Business Context**:
- Policy number becomes PNR (Passenger Name Record)
- Issue date tracks booking lead time for revenue management
- Expiry date is flight departure date/time
- Broker ID identifies distribution channel (GDS, OTA, direct, corporate)
- Payment field stores base fare (additional fees tracked separately)

---

## Policy Type Mappings (Product Variants)

### Endowment Policy → Premium Cabin Booking

Endowment policies with investment features map to premium cabin bookings with loyalty benefits.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-E-WITH-PROFITS` | Upgrade Eligible | Can use miles for upgrade (Y/N) |
| `CA-E-EQUITIES` | Lounge Access | Premium lounge access included (Y/N) |
| `CA-E-MANAGED-FUND` | Priority Boarding | Early boarding group (Y/N) |
| `CA-E-FUND-NAME` | Fare Class Code | Specific booking class (10 chars) |
| `CA-E-TERM` | Advance Purchase Days | Days before departure booked (2 digits) |
| `CA-E-SUM-ASSURED` | Miles Earned | Loyalty miles credited (6 digits) |
| `CA-E-LIFE-ASSURED` | Primary Passenger Name | Lead passenger on booking (31 chars) |

**Airline Business Context**:
- Investment flags become premium service entitlements
- Term becomes advance purchase requirement for fare rules
- Sum assured becomes miles/points earned
- Life assured is the primary ticket holder

---

### House Policy → Route/Flight Segment

House insurance with property details maps to flight route and aircraft information.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-H-PROPERTY-TYPE` | Aircraft Type | Equipment code (e.g., "Boeing 737-800", 15 chars) |
| `CA-H-BEDROOMS` | Seat Count / Capacity | Total seats on aircraft (3 digits) |
| `CA-H-VALUE` | Aircraft Value | Asset value for insurance (8 digits) |
| `CA-H-HOUSE-NAME` | Origin Airport | Departure airport name (20 chars) |
| `CA-H-HOUSE-NUMBER` | Flight Number | Numeric flight identifier (4 chars) |
| `CA-H-POSTCODE` | Destination Airport Code | IATA/ICAO arrival airport (8 chars) |

**Airline Business Context**:
- Property type becomes aircraft equipment type
- Bedrooms becomes seat configuration
- House name/number becomes origin airport and flight number
- Postcode becomes destination airport code
- Value tracks aircraft asset value for fleet management

---

### Motor Policy → Passenger Itinerary Details

Motor insurance with vehicle details maps to individual passenger journey information.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-M-MAKE` | Airline Code | Operating carrier (15 chars, e.g., "United Airlines") |
| `CA-M-MODEL` | Service Class | Cabin class (15 chars, e.g., "Business Class") |
| `CA-M-VALUE` | Ticket Value | Total fare paid (6 digits) |
| `CA-M-REGNUMBER` | Ticket Number | 13-digit ticket identifier (7 chars truncated) |
| `CA-M-COLOUR` | Seat Preference | Window/Aisle/Middle preference (8 chars) |
| `CA-M-CC` | Baggage Allowance | Checked bag weight limit in kg (4 digits) |
| `CA-M-MANUFACTURED` | Booking Channel | How ticket was purchased (10 chars) |
| `CA-M-PREMIUM` | Ancillary Fees | Extra charges (bags, seats, meals) (6 digits) |
| `CA-M-ACCIDENTS` | Disruption Count | Number of flight changes/cancellations (6 digits) |

**Airline Business Context**:
- Make/Model become carrier and service class
- Registration becomes ticket number
- Color becomes seat preference
- CC (engine size) becomes baggage allowance
- Premium becomes ancillary revenue
- Accidents track service disruptions

---

### Commercial Policy → Cargo/Freight Booking

Commercial property insurance maps to cargo and freight operations.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-B-Address` | Shipper Address | Origin shipping address (255 chars) |
| `CA-B-Postcode` | Origin Airport Code | Departure airport for cargo (8 chars) |
| `CA-B-Latitude` | Origin Coordinates | GPS latitude of pickup (11 chars) |
| `CA-B-Longitude` | Origin Coordinates | GPS longitude of pickup (11 chars) |
| `CA-B-Customer` | Consignee Name | Receiving party details (255 chars) |
| `CA-B-PropType` | Cargo Type | Freight classification (255 chars) |
| `CA-B-FirePeril` | Hazmat Level | Dangerous goods classification (4 digits) |
| `CA-B-FirePremium` | Hazmat Surcharge | Additional fee for dangerous goods (8 digits) |
| `CA-B-CrimePeril` | Security Level | Cargo security screening level (4 digits) |
| `CA-B-CrimePremium` | Security Fee | Additional security charges (8 digits) |
| `CA-B-FloodPeril` | Temperature Control | Refrigeration requirement level (4 digits) |
| `CA-B-FloodPremium` | Cold Chain Fee | Temperature-controlled transport fee (8 digits) |
| `CA-B-WeatherPeril` | Priority Level | Expedited handling level (4 digits) |
| `CA-B-WeatherPremium` | Priority Fee | Express delivery surcharge (8 digits) |
| `CA-B-Status` | Shipment Status | Current cargo state (4 digits) |
| `CA-B-RejectReason` | Rejection Reason | Why cargo was refused (255 chars) |

**Airline Business Context**:
- Address fields track shipper and consignee
- Coordinates enable precise pickup/delivery
- Peril fields become cargo handling requirements
- Premium fields become specialized service fees
- Status tracks cargo through supply chain

---

### Claim Policy → Service Recovery/Compensation

Insurance claims map to passenger compensation and service recovery.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-C-Num` | Claim Number | Unique compensation case ID (10 digits) |
| `CA-C-Date` | Incident Date | When disruption occurred (10 chars) |
| `CA-C-Paid` | Amount Paid | Compensation issued (8 digits) |
| `CA-C-Value` | Amount Claimed | Compensation requested (8 digits) |
| `CA-C-Cause` | Disruption Reason | Why flight was delayed/cancelled (255 chars) |
| `CA-C-Observations` | Resolution Notes | Customer service actions taken (255 chars) |

**Airline Business Context**:
- Claim number tracks compensation cases
- Date records when service failure occurred
- Paid vs. Value shows approved vs. requested compensation
- Cause documents delay/cancellation reason (weather, mechanical, crew)
- Observations track customer service resolution

---

## Communication Area (COMMAREA) Structure

The COMMAREA is the inter-program communication mechanism, equivalent to airline message formats.

| Insurance Field | Airline Equivalent | Business Meaning |
|----------------|-------------------|------------------|
| `CA-REQUEST-ID` | Transaction Type | 6-char operation code (e.g., "BKGCRE", "CHKCIN") |
| `CA-RETURN-CODE` | Response Code | 2-digit status (00=success, 90=error, 98=invalid) |
| `CA-REQUEST-SPECIFIC` | Message Payload | Variable data area (32,482 bytes) |

**Request ID Values** (Transaction Types):
- `01AAAA` → Create new passenger profile
- `01IIII` → Retrieve passenger details
- `01UUUU` → Update passenger information
- `01DDDD` → Delete passenger record
- `01NNNN` → Inquire all passengers
- `02AAAA` → Create new booking
- `02IIII` → Retrieve booking details
- `02UUUU` → Modify booking
- `02DDDD` → Cancel booking

---

## Database Table Mappings

### DB2 Tables → Airline Database Schema

| Insurance Table | Airline Table | Purpose |
|----------------|---------------|---------|
| `CUSTOMER` | `PASSENGER` / `FREQUENT_FLYER` | Passenger master data |
| `POLICY` | `BOOKING` / `PNR` | Reservation records |
| `ENDOWMENT` | `PREMIUM_CABIN` | Premium service bookings |
| `HOUSE` | `FLIGHT_SEGMENT` | Route and aircraft data |
| `MOTOR` | `ITINERARY` | Passenger journey details |
| `COMMERCIAL` | `CARGO_SHIPMENT` | Freight bookings |
| `CLAIM` | `COMPENSATION` | Service recovery cases |

---

## Key Business Rules Translation

### Insurance → Airline

1. **Customer Number Generation**
   - Insurance: Sequential customer ID from Named Counter Service
   - Airline: Frequent flyer number generation with check digit

2. **Policy Lifecycle**
   - Insurance: Issue → Active → Expired → Renewed
   - Airline: Booked → Ticketed → Checked-in → Flown → Completed

3. **Multi-Policy Customer**
   - Insurance: One customer, multiple policies
   - Airline: One passenger, multiple bookings/segments

4. **Broker Commission**
   - Insurance: Broker ID and reference for agent tracking
   - Airline: GDS/OTA commission tracking and agent identification

5. **Payment Processing**
   - Insurance: Premium payment in cents
   - Airline: Fare + taxes + fees in cents

---

## Technical Field Interpretations

### Cryptic Abbreviations Decoded

| Abbreviation | Full Meaning | Airline Context |
|-------------|--------------|-----------------|
| `CA-` | Communication Area | Message field prefix |
| `DB2-` | Database 2 field | Persistent storage field |
| `WS-` | Working Storage | Temporary processing variable |
| `EM-` | Error Message | Error handling field |
| `LGAC` | Life & General Add Customer | Create passenger profile |
| `LGAP` | Life & General Add Policy | Create booking |
| `LGIC` | Life & General Inquire Customer | Retrieve passenger |
| `LGIP` | Life & General Inquire Policy | Retrieve booking |
| `LGUC` | Life & General Update Customer | Modify passenger |
| `LGUP` | Life & General Update Policy | Modify booking |
| `LGDC` | Life & General Delete Customer | Remove passenger |
| `LGDP` | Life & General Delete Policy | Cancel booking |

---

## Data Volume Considerations

### Field Size Implications for Airline Operations

| Field | Size | Airline Adequacy |
|-------|------|------------------|
| Customer Number | 10 digits | ✅ Supports 10 billion passengers |
| Policy Number | 10 digits | ✅ Supports 10 billion bookings |
| Payment Amount | 6 digits | ⚠️ Max $9,999.99 - may need expansion for premium fares |
| Email Address | 100 chars | ✅ Adequate for modern email addresses |
| Phone Numbers | 20 chars | ✅ Supports international formats |
| Postcode | 8 chars | ✅ Handles most postal codes globally |
| Name Fields | 10+20 chars | ⚠️ May be tight for some international names |

---

## Integration Points

### External System Mappings

| Insurance System | Airline System | Purpose |
|-----------------|----------------|---------|
| Named Counter Service | Reservation System | Generate unique IDs |
| Temporary Storage Queue | Message Queue | Async processing |
| DB2 Database | Passenger Service System | Master data storage |
| CICS Transactions | Departure Control System | Real-time operations |
| BMS Maps | Check-in Kiosks | User interface |

---

## Summary: Key Conceptual Mappings

1. **Customer = Passenger/Frequent Flyer**
   - Personal details, contact info, loyalty status

2. **Policy = Booking/Reservation**
   - Flight details, fare, travel dates

3. **Policy Types = Product Variants**
   - Endowment → Premium cabin
   - House → Flight segment
   - Motor → Itinerary
   - Commercial → Cargo
   - Claim → Compensation

4. **Broker = Distribution Channel**
   - Travel agent, GDS, OTA, direct

5. **Premium/Payment = Fare**
   - Base fare, taxes, fees, ancillaries

6. **Issue/Expiry Dates = Booking/Travel Dates**
   - When reserved vs. when traveling

---

## Usage Notes

This glossary enables:
- **Business analysts** to understand insurance data in airline terms
- **Architects** to design airline system adaptations
- **Developers** to map fields during system conversion
- **Testers** to create airline-relevant test scenarios
- **Stakeholders** to evaluate system fit for airline operations

The existing insurance system structure provides a solid foundation for airline operations, with most fields directly mappable to airline concepts. Key areas requiring extension include:
- Multi-segment itineraries (connecting flights)
- Seat assignments and preferences
- Meal preferences and special service requests
- Frequent flyer tier status and benefits
- Codeshare and alliance partner handling

---

**Document Version**: 1.0  
**Last Updated**: 2026-06-23  
**Maintained By**: Architecture Team