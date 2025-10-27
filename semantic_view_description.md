-- =====================================================================
-- Snowflake Intelligence Demo: Credit Union
-- File: semantic_view_description.md
-- Purpose: Detailed documentation of all semantic views
-- =====================================================================

# Semantic View Documentation
## Credit Union AI Demo

This document provides comprehensive documentation for all six semantic views created for the Credit Union Snowflake Intelligence demo. Each view is optimized for specific business questions and use cases.

---

## Table of Contents
1. [MEMBER_ACQUISITION_VIEW](#member_acquisition_view)
2. [CERTIFICATE_RENEWAL_VIEW](#certificate_renewal_view)
3. [LOAN_PORTFOLIO_VIEW](#loan_portfolio_view)
4. [CREDIT_CARD_HEALTH_VIEW](#credit_card_health_view)
5. [BRANCH_PERFORMANCE_VIEW](#branch_performance_view)
6. [TIME_SERIES_METRICS_VIEW](#time_series_metrics_view)

---

## MEMBER_ACQUISITION_VIEW

### Purpose
Track new member acquisition trends, analyze marketing channel effectiveness, and understand member demographics and relationship depth.

### Source Tables
- `MEMBERS` (primary)
- `BRANCHES` (joined on PRIMARY_BRANCH_ID)
- `ACCOUNTS` (subquery for relationship metrics)
- `LOANS` (subquery for relationship metrics)

### Key Business Questions
- How many new members have we acquired in a given period?
- Which marketing channels are most effective?
- Which branches are growing fastest?
- What is the demographic profile of new members?
- How deep are member relationships (products per member)?

### Column Reference

#### Identifiers
| Column | Type | Description |
|--------|------|-------------|
| MEMBER_ID | VARCHAR(50) | Unique member identifier |
| MEMBER_NUMBER | VARCHAR(20) | Member account number |
| MEMBER_NAME | VARCHAR(200) | Full name (First + Last) |

#### Acquisition Metrics
| Column | Type | Description |
|--------|------|-------------|
| JOIN_DATE | DATE | Date member joined credit union |
| JOIN_YEAR | NUMBER | Year of join date |
| JOIN_QUARTER | NUMBER | Quarter of join date (1-4) |
| JOIN_MONTH | NUMBER | Month of join date (1-12) |
| JOIN_MONTH_NAME | VARCHAR | Month name (January, February, etc.) |
| JOIN_DAY_OF_WEEK | NUMBER | Day of week (0-6) |
| JOIN_DAY_NAME | VARCHAR | Day name (Monday, Tuesday, etc.) |
| JOIN_MONTH_START | DATE | First day of join month |
| JOIN_QUARTER_START | DATE | First day of join quarter |
| JOIN_YEAR_START | DATE | First day of join year |

#### Tenure Metrics
| Column | Type | Description |
|--------|------|-------------|
| DAYS_AS_MEMBER | NUMBER | Total days since joining |
| MONTHS_AS_MEMBER | NUMBER | Total months since joining |
| YEARS_AS_MEMBER | NUMBER | Total years since joining |

#### Member Attributes
| Column | Type | Description |
|--------|------|-------------|
| MEMBER_STATUS | VARCHAR(20) | Active, Inactive, Dormant, Closed |
| MEMBER_SEGMENT | VARCHAR(50) | New, Established, Loyal, Premium |
| RISK_RATING | VARCHAR(20) | Low, Medium, High |
| MARKETING_CHANNEL | VARCHAR(100) | Acquisition source (Referral, Online, Branch Walk-in, Social Media, Email Campaign, Direct Mail) |
| EMPLOYMENT_STATUS | VARCHAR(50) | Employed Full-time, Self-employed, Retired, Part-time |
| ANNUAL_INCOME | NUMBER(15,2) | Member's annual income |

#### Branch Information
| Column | Type | Description |
|--------|------|-------------|
| PRIMARY_BRANCH_ID | VARCHAR(50) | Branch ID |
| BRANCH_NAME | VARCHAR(200) | Branch name |
| BRANCH_CODE | VARCHAR(10) | Branch code (ENC, CAR, SDD, etc.) |
| BRANCH_CITY | VARCHAR(100) | Branch city |
| BRANCH_STATE | VARCHAR(2) | Branch state |
| BRANCH_REGION | VARCHAR(50) | Geographic region |
| BRANCH_TYPE | VARCHAR(50) | Full Service, Limited Service, Online Only |

#### Demographics
| Column | Type | Description |
|--------|------|-------------|
| DATE_OF_BIRTH | DATE | Member's birth date |
| AGE_AT_JOIN | NUMBER | Age when joined |
| CURRENT_AGE | NUMBER | Current age |
| MEMBER_CITY | VARCHAR(100) | Member's city |
| MEMBER_STATE | VARCHAR(2) | Member's state |
| MEMBER_ZIP | VARCHAR(10) | Member's ZIP code |

#### Relationship Depth
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_ACCOUNTS | NUMBER | Count of deposit accounts |
| TOTAL_LOANS | NUMBER | Count of loans |
| TOTAL_DEPOSIT_BALANCE | NUMBER(15,2) | Sum of all deposit balances |
| TOTAL_LOAN_BALANCE | NUMBER(15,2) | Sum of active loan balances |

#### Analysis Flags
| Column | Type | Description |
|--------|------|-------------|
| IS_NEW_MEMBER_90_DAYS | NUMBER(1,0) | 1 if joined in last 90 days |
| IS_NEW_MEMBER_6_MONTHS | NUMBER(1,0) | 1 if joined in last 6 months |
| IS_NEW_MEMBER_12_MONTHS | NUMBER(1,0) | 1 if joined in last 12 months |
| IS_REFERRAL | NUMBER(1,0) | 1 if acquired via referral |
| IS_DIGITAL_CHANNEL | NUMBER(1,0) | 1 if acquired via online/social/email |

### Sample Queries

**Count new members in last 90 days:**
```sql
SELECT COUNT(*) as new_members
FROM MEMBER_ACQUISITION_VIEW
WHERE IS_NEW_MEMBER_90_DAYS = 1;
```

**New members by marketing channel (last 6 months):**
```sql
SELECT 
    MARKETING_CHANNEL,
    COUNT(*) as member_count,
    AVG(TOTAL_ACCOUNTS) as avg_accounts_per_member
FROM MEMBER_ACQUISITION_VIEW
WHERE IS_NEW_MEMBER_6_MONTHS = 1
GROUP BY MARKETING_CHANNEL
ORDER BY member_count DESC;
```

**Member acquisition trend by month:**
```sql
SELECT 
    JOIN_MONTH_START,
    COUNT(*) as new_members
FROM MEMBER_ACQUISITION_VIEW
WHERE JOIN_DATE >= DATEADD(month, -12, CURRENT_DATE())
GROUP BY JOIN_MONTH_START
ORDER BY JOIN_MONTH_START;
```

---

## CERTIFICATE_RENEWAL_VIEW

### Purpose
Track certificate of deposit (CD) maturities, identify renewal opportunities, and support proactive member outreach for certificate renewals.

### Source Tables
- `ACCOUNTS` (primary, filtered to ACCOUNT_TYPE = 'Certificate')
- `MEMBERS` (joined on MEMBER_ID)
- `BRANCHES` (joined on BRANCH_ID)

### Key Business Questions
- How many certificates are renewing in the next 30/60/90 days?
- Which branches have the most certificates maturing?
- What is the total value of certificates renewing in a given period?
- **Branch-specific: How many certificates are renewing at Encinitas branch?**
- Which members should be contacted about upcoming maturities?

### Column Reference

#### Account Identifiers
| Column | Type | Description |
|--------|------|-------------|
| ACCOUNT_ID | VARCHAR(50) | Unique account identifier |
| ACCOUNT_NUMBER | VARCHAR(30) | Certificate account number |

#### Member Information
| Column | Type | Description |
|--------|------|-------------|
| MEMBER_ID | VARCHAR(50) | Member identifier |
| MEMBER_NUMBER | VARCHAR(20) | Member account number |
| MEMBER_NAME | VARCHAR(200) | Member full name |
| MEMBER_EMAIL | VARCHAR(200) | Member email for outreach |
| MEMBER_PHONE | VARCHAR(20) | Member phone for outreach |
| MEMBER_SEGMENT | VARCHAR(50) | Member segment |
| MEMBER_STATUS | VARCHAR(20) | Member status |

#### Branch Information
| Column | Type | Description |
|--------|------|-------------|
| BRANCH_ID | VARCHAR(50) | Branch identifier |
| BRANCH_NAME | VARCHAR(200) | Branch name (e.g., "Encinitas Main Branch") |
| BRANCH_CODE | VARCHAR(10) | Branch code (e.g., "ENC") |
| BRANCH_CITY | VARCHAR(100) | Branch city |
| BRANCH_STATE | VARCHAR(2) | Branch state |
| BRANCH_REGION | VARCHAR(50) | Branch region |
| BRANCH_MANAGER | VARCHAR(200) | Branch manager name |

#### Certificate Details
| Column | Type | Description |
|--------|------|-------------|
| CERTIFICATE_OPEN_DATE | DATE | When certificate was opened |
| MATURITY_DATE | DATE | When certificate matures |
| CERTIFICATE_TERM_MONTHS | NUMBER | Term length (6, 12, 18, 24, 36, 60) |
| ORIGINAL_DEPOSIT_AMOUNT | NUMBER(15,2) | Initial deposit |
| CURRENT_BALANCE | NUMBER(15,2) | Current value |
| INTEREST_RATE | NUMBER(5,4) | Annual interest rate |
| RENEWAL_STATUS | VARCHAR(20) | Auto-Renew, Manual-Renew, Pending, Closed |
| ACCOUNT_STATUS | VARCHAR(20) | Active, Dormant, Closed |

#### Time Calculations
| Column | Type | Description |
|--------|------|-------------|
| DAYS_UNTIL_MATURITY | NUMBER | Days from today to maturity |
| MONTHS_UNTIL_MATURITY | NUMBER | Months from today to maturity |
| TOTAL_TERM_DAYS | NUMBER | Total days in certificate term |
| DAYS_SINCE_OPEN | NUMBER | Days since certificate opened |

#### Maturity Date Dimensions
| Column | Type | Description |
|--------|------|-------------|
| MATURITY_YEAR | NUMBER | Year of maturity |
| MATURITY_QUARTER | NUMBER | Quarter of maturity (1-4) |
| MATURITY_MONTH | NUMBER | Month of maturity (1-12) |
| MATURITY_MONTH_NAME | VARCHAR | Month name |
| MATURITY_MONTH_START | DATE | First day of maturity month |
| MATURITY_QUARTER_START | DATE | First day of maturity quarter |

#### Calculated Metrics
| Column | Type | Description |
|--------|------|-------------|
| INTEREST_EARNED_TO_DATE | NUMBER(15,2) | Current balance - original deposit |

#### Renewal Urgency
| Column | Type | Description |
|--------|------|-------------|
| RENEWAL_URGENCY | VARCHAR(50) | Immediate (30d), Soon (60d), Upcoming (90d), Future (6mo), Distant (6+mo), Matured |
| IS_MATURING_30_DAYS | NUMBER(1,0) | 1 if maturing in 0-30 days |
| IS_MATURING_60_DAYS | NUMBER(1,0) | 1 if maturing in 0-60 days |
| IS_MATURING_90_DAYS | NUMBER(1,0) | 1 if maturing in 0-90 days |
| IS_MATURING_6_MONTHS | NUMBER(1,0) | 1 if maturing in 0-180 days |
| IS_MATURED | NUMBER(1,0) | 1 if already matured |
| IS_AUTO_RENEW | NUMBER(1,0) | 1 if set to auto-renew |

#### Value Tiers
| Column | Type | Description |
|--------|------|-------------|
| CERTIFICATE_VALUE_TIER | VARCHAR(50) | Premium ($100K+), High Value ($50K-$100K), Mid Value ($25K-$50K), Standard ($10K-$25K), Entry Level (<$10K) |

### Sample Queries

**Certificates maturing in next 90 days:**
```sql
SELECT COUNT(*) as certificates,
       SUM(CURRENT_BALANCE) as total_value
FROM CERTIFICATE_RENEWAL_VIEW
WHERE IS_MATURING_90_DAYS = 1;
```

**Certificates maturing at Encinitas branch (next 90 days):**
```sql
SELECT 
    MEMBER_NAME,
    MEMBER_EMAIL,
    MEMBER_PHONE,
    CURRENT_BALANCE,
    MATURITY_DATE,
    RENEWAL_STATUS
FROM CERTIFICATE_RENEWAL_VIEW
WHERE BRANCH_NAME = 'Encinitas Main Branch'
  AND IS_MATURING_90_DAYS = 1
ORDER BY MATURITY_DATE;
```

**Certificate renewal pipeline by branch:**
```sql
SELECT 
    BRANCH_NAME,
    SUM(IS_MATURING_30_DAYS) as maturing_30d,
    SUM(IS_MATURING_90_DAYS) as maturing_90d,
    SUM(CASE WHEN IS_MATURING_90_DAYS = 1 THEN CURRENT_BALANCE ELSE 0 END) as value_90d
FROM CERTIFICATE_RENEWAL_VIEW
GROUP BY BRANCH_NAME
ORDER BY value_90d DESC;
```

---

## LOAN_PORTFOLIO_VIEW

### Purpose
Comprehensive loan portfolio analysis across all loan types, enabling portfolio composition analysis, credit quality monitoring, and performance trending.

### Source Tables
- `LOANS` (primary)
- `MEMBERS` (joined on MEMBER_ID)
- `BRANCHES` (joined on BRANCH_ID)

### Key Business Questions
- What is the current balance of our auto loan portfolio?
- How are loan balances trending over time?
- What percentage of total portfolio is each loan type?
- What is our portfolio credit quality?
- How many loans are delinquent?

### Column Reference

#### Loan Identifiers
| Column | Type | Description |
|--------|------|-------------|
| LOAN_ID | VARCHAR(50) | Unique loan identifier |
| LOAN_NUMBER | VARCHAR(30) | Loan account number |
| LOAN_TYPE | VARCHAR(50) | Auto, Credit Card, Mortgage, Personal |
| LOAN_STATUS | VARCHAR(20) | Active, Paid Off, Charged Off, Delinquent, Suspended, Inactive |

#### Member & Branch
| Column | Type | Description |
|--------|------|-------------|
| MEMBER_ID | VARCHAR(50) | Member identifier |
| MEMBER_NUMBER | VARCHAR(20) | Member account number |
| MEMBER_NAME | VARCHAR(200) | Member full name |
| MEMBER_SEGMENT | VARCHAR(50) | Member segment |
| MEMBER_INCOME | NUMBER(15,2) | Member annual income |
| BRANCH_ID | VARCHAR(50) | Branch identifier |
| BRANCH_NAME | VARCHAR(200) | Branch name |
| BRANCH_CODE | VARCHAR(10) | Branch code |
| BRANCH_REGION | VARCHAR(50) | Branch region |

#### Loan Dates & Time Dimensions
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_DATE | DATE | Loan origination date |
| ORIGINATION_YEAR | NUMBER | Year of origination |
| ORIGINATION_QUARTER | NUMBER | Quarter of origination |
| ORIGINATION_MONTH | NUMBER | Month of origination |
| ORIGINATION_MONTH_NAME | VARCHAR | Month name |
| ORIGINATION_MONTH_START | DATE | First day of origination month |
| ORIGINATION_QUARTER_START | DATE | First day of origination quarter |
| ORIGINATION_YEAR_START | DATE | First day of origination year |
| MONTHS_SINCE_ORIGINATION | NUMBER | Months since loan originated |
| YEARS_SINCE_ORIGINATION | NUMBER | Years since loan originated |

#### Loan Financials
| Column | Type | Description |
|--------|------|-------------|
| ORIGINAL_LOAN_AMOUNT | NUMBER(15,2) | Original loan amount |
| CURRENT_BALANCE | NUMBER(15,2) | Current outstanding balance |
| PRINCIPAL_PAID | NUMBER(15,2) | Amount paid down |
| PAYDOWN_PERCENTAGE | NUMBER | (Paid / Original) ratio |
| INTEREST_RATE | NUMBER(6,4) | Annual interest rate |
| TERM_MONTHS | NUMBER | Loan term in months |
| MONTHLY_PAYMENT | NUMBER(10,2) | Monthly payment amount |

#### Credit Card Specific
| Column | Type | Description |
|--------|------|-------------|
| CREDIT_LIMIT | NUMBER(15,2) | Credit card limit (NULL for other loans) |
| AVAILABLE_CREDIT | NUMBER(15,2) | Available credit (NULL for other loans) |
| CREDIT_UTILIZATION | NUMBER | Balance / Limit ratio |

#### Credit Quality
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_CREDIT_SCORE | NUMBER | Credit score at origination |
| CURRENT_CREDIT_SCORE | NUMBER | Current credit score |
| CREDIT_SCORE_CHANGE | NUMBER | Current - Origination |
| DAYS_DELINQUENT | NUMBER | Days past due |
| LOAN_TO_VALUE_RATIO | NUMBER(5,4) | LTV for secured loans |
| COLLATERAL_TYPE | VARCHAR(100) | Collateral description |

#### Payment Information
| Column | Type | Description |
|--------|------|-------------|
| LAST_PAYMENT_DATE | DATE | Date of last payment |
| LAST_PAYMENT_AMOUNT | NUMBER(10,2) | Amount of last payment |
| NEXT_PAYMENT_DATE | DATE | Next payment due date |
| CLOSE_DATE | DATE | Loan close/payoff date |

#### Status Flags
| Column | Type | Description |
|--------|------|-------------|
| IS_ACTIVE | NUMBER(1,0) | 1 if status = Active |
| IS_PAID_OFF | NUMBER(1,0) | 1 if status = Paid Off |
| IS_CHARGED_OFF | NUMBER(1,0) | 1 if status = Charged Off |
| IS_DELINQUENT | NUMBER(1,0) | 1 if status = Delinquent |
| HAS_DELINQUENCY | NUMBER(1,0) | 1 if days delinquent > 0 |
| IS_30_DAYS_LATE | NUMBER(1,0) | 1 if 30+ days delinquent |
| IS_60_DAYS_LATE | NUMBER(1,0) | 1 if 60+ days delinquent |
| IS_90_DAYS_LATE | NUMBER(1,0) | 1 if 90+ days delinquent |

#### Loan Type Flags
| Column | Type | Description |
|--------|------|-------------|
| IS_AUTO_LOAN | NUMBER(1,0) | 1 if loan type = Auto |
| IS_CREDIT_CARD | NUMBER(1,0) | 1 if loan type = Credit Card |
| IS_MORTGAGE | NUMBER(1,0) | 1 if loan type = Mortgage |
| IS_PERSONAL_LOAN | NUMBER(1,0) | 1 if loan type = Personal |

#### Origination Cohort Flags
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATED_LAST_3_MONTHS | NUMBER(1,0) | 1 if originated in last 3 months |
| ORIGINATED_LAST_6_MONTHS | NUMBER(1,0) | 1 if originated in last 6 months |
| ORIGINATED_LAST_12_MONTHS | NUMBER(1,0) | 1 if originated in last 12 months |
| ORIGINATED_LAST_24_MONTHS | NUMBER(1,0) | 1 if originated in last 24 months |

#### Credit Score Bands
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_CREDIT_BAND | VARCHAR(50) | Excellent (800+), Very Good (740-799), Good (670-739), Fair (580-669), Poor (<580) |
| CURRENT_CREDIT_BAND | VARCHAR(50) | Same bands as origination |

#### Credit Migration
| Column | Type | Description |
|--------|------|-------------|
| CREDIT_MIGRATION | VARCHAR(50) | Significant Improvement, Moderate Improvement, Stable, Moderate Decline, Significant Decline |

#### Risk Category
| Column | Type | Description |
|--------|------|-------------|
| RISK_CATEGORY | VARCHAR(20) | High Risk, Elevated Risk, Moderate Risk, Low Risk |

### Sample Queries

**Auto loan portfolio balance:**
```sql
SELECT SUM(CURRENT_BALANCE) as total_auto_loans
FROM LOAN_PORTFOLIO_VIEW
WHERE IS_AUTO_LOAN = 1
  AND IS_ACTIVE = 1;
```

**Loan portfolio composition:**
```sql
SELECT 
    LOAN_TYPE,
    COUNT(*) as loan_count,
    SUM(CURRENT_BALANCE) as total_balance,
    AVG(INTEREST_RATE) * 100 as avg_rate_pct
FROM LOAN_PORTFOLIO_VIEW
WHERE IS_ACTIVE = 1
GROUP BY LOAN_TYPE
ORDER BY total_balance DESC;
```

**Delinquent loans by type:**
```sql
SELECT 
    LOAN_TYPE,
    SUM(IS_30_DAYS_LATE) as delinquent_30d,
    SUM(IS_60_DAYS_LATE) as delinquent_60d,
    SUM(IS_90_DAYS_LATE) as delinquent_90d
FROM LOAN_PORTFOLIO_VIEW
WHERE IS_ACTIVE = 1
GROUP BY LOAN_TYPE;
```

---

## CREDIT_CARD_HEALTH_VIEW

### Purpose
Detailed credit card portfolio health analysis with focus on credit score migration, utilization, charge-offs, and risk assessment. **This is the primary view for all credit card-specific questions.**

### Source Tables
- `LOANS` (primary, filtered to LOAN_TYPE = 'Credit Card')
- `MEMBERS` (joined on MEMBER_ID)
- `BRANCHES` (joined on BRANCH_ID)

### Key Business Questions
- What does credit card portfolio health look like for loans originated in a given period?
- How are credit scores migrating from origination to current?
- What is credit utilization across the portfolio?
- How many credit cards are active vs. inactive?
- How many charge-offs by origination cohort?
- Which credit cards are high risk?

### Column Reference

#### Loan Identifiers
| Column | Type | Description |
|--------|------|-------------|
| LOAN_ID | VARCHAR(50) | Unique loan identifier |
| LOAN_NUMBER | VARCHAR(30) | Credit card account number |
| LOAN_STATUS | VARCHAR(20) | Active, Inactive, Charged Off |

#### Member & Branch
| Column | Type | Description |
|--------|------|-------------|
| MEMBER_ID | VARCHAR(50) | Member identifier |
| MEMBER_NUMBER | VARCHAR(20) | Member number |
| MEMBER_NAME | VARCHAR(200) | Member full name |
| MEMBER_SEGMENT | VARCHAR(50) | Member segment |
| MEMBER_STATUS | VARCHAR(20) | Member status |
| MEMBER_INCOME | NUMBER(15,2) | Annual income |
| BRANCH_ID | VARCHAR(50) | Branch identifier |
| BRANCH_NAME | VARCHAR(200) | Branch name |
| BRANCH_CODE | VARCHAR(10) | Branch code |
| BRANCH_REGION | VARCHAR(50) | Branch region |

#### Origination Details
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_DATE | DATE | When credit card was issued |
| ORIGINATION_YEAR | NUMBER | Year issued |
| ORIGINATION_QUARTER | NUMBER | Quarter issued |
| ORIGINATION_MONTH | NUMBER | Month issued |
| ORIGINATION_MONTH_NAME | VARCHAR | Month name |
| ORIGINATION_MONTH_START | DATE | First day of origination month |
| ORIGINATION_QUARTER_START | DATE | First day of origination quarter |
| MONTHS_ON_BOOK | NUMBER | Months since origination |

#### Credit Limit & Balances
| Column | Type | Description |
|--------|------|-------------|
| CREDIT_LIMIT | NUMBER(15,2) | Maximum credit line |
| CURRENT_BALANCE | NUMBER(15,2) | Current balance |
| AVAILABLE_CREDIT | NUMBER(15,2) | Credit limit - balance |
| CALCULATED_AVAILABLE_CREDIT | NUMBER(15,2) | Recalculated available credit |

#### Utilization Metrics
| Column | Type | Description |
|--------|------|-------------|
| UTILIZATION_PERCENTAGE | NUMBER | (Balance / Limit) * 100 |
| UTILIZATION_BAND | VARCHAR(50) | Very High (90%+), High (70-89%), Moderate (50-69%), Low (30-49%), Very Low (<30%) |

#### Credit Score Tracking
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_CREDIT_SCORE | NUMBER | Credit score at origination |
| CURRENT_CREDIT_SCORE | NUMBER | Current credit score |
| CREDIT_SCORE_CHANGE | NUMBER | Current - Origination (can be negative) |
| CREDIT_SCORE_CHANGE_ABS | NUMBER | Absolute value of change |

#### Credit Score Bands
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_CREDIT_BAND | VARCHAR(50) | Excellent (800+), Very Good (740-799), Good (670-739), Fair (580-669), Poor (<580) |
| CURRENT_CREDIT_BAND | VARCHAR(50) | Same bands |

#### Credit Migration Analysis
| Column | Type | Description |
|--------|------|-------------|
| CREDIT_MIGRATION_CATEGORY | VARCHAR(100) | Significant Improvement (50+ points), Moderate Improvement (20-49 points), Slight Improvement (10-19 points), Stable (+/-10 points), Slight Decline (10-19 points), Moderate Decline (20-49 points), Significant Decline (50+ points) |

#### Interest Rate & Payments
| Column | Type | Description |
|--------|------|-------------|
| INTEREST_RATE | NUMBER(6,4) | Annual interest rate |
| MONTHLY_PAYMENT | NUMBER(10,2) | Minimum monthly payment |
| LAST_PAYMENT_DATE | DATE | Last payment date |
| LAST_PAYMENT_AMOUNT | NUMBER(10,2) | Last payment amount |

#### Delinquency Tracking
| Column | Type | Description |
|--------|------|-------------|
| DAYS_DELINQUENT | NUMBER | Days past due |
| DELINQUENCY_BUCKET | VARCHAR(50) | Current, 1-29 Days, 30-59 Days, 60-89 Days, 90+ Days |

#### Status Flags
| Column | Type | Description |
|--------|------|-------------|
| IS_ACTIVE | NUMBER(1,0) | 1 if active |
| IS_INACTIVE | NUMBER(1,0) | 1 if inactive |
| IS_CHARGED_OFF | NUMBER(1,0) | 1 if charged off |
| IS_30_PLUS_DELINQUENT | NUMBER(1,0) | 1 if 30+ days late |
| IS_60_PLUS_DELINQUENT | NUMBER(1,0) | 1 if 60+ days late |
| IS_90_PLUS_DELINQUENT | NUMBER(1,0) | 1 if 90+ days late |

#### Origination Cohorts
| Column | Type | Description |
|--------|------|-------------|
| ORIGINATION_COHORT | VARCHAR(50) | Last 3 Months, Last 6 Months, Last 12 Months, Last 24 Months, Over 24 Months |

#### Risk Indicators
| Column | Type | Description |
|--------|------|-------------|
| RISK_LEVEL | VARCHAR(20) | Critical, Severe, High, Elevated, Moderate, Watch, Low |

#### Revenue Metrics
| Column | Type | Description |
|--------|------|-------------|
| ESTIMATED_ANNUAL_INTEREST_REVENUE | NUMBER(15,2) | Current balance * interest rate |

### Sample Queries

**Credit card health for last 12 months originations:**
```sql
SELECT 
    COUNT(*) as total_cards,
    AVG(UTILIZATION_PERCENTAGE) as avg_utilization_pct,
    AVG(CREDIT_SCORE_CHANGE) as avg_score_change,
    SUM(IS_CHARGED_OFF) as charge_offs,
    SUM(IS_ACTIVE) as active_cards
FROM CREDIT_CARD_HEALTH_VIEW
WHERE ORIGINATION_COHORT = 'Last 12 Months';
```

**Credit score migration distribution:**
```sql
SELECT 
    CREDIT_MIGRATION_CATEGORY,
    COUNT(*) as card_count,
    AVG(CREDIT_SCORE_CHANGE) as avg_change,
    AVG(UTILIZATION_PERCENTAGE) as avg_utilization
FROM CREDIT_CARD_HEALTH_VIEW
WHERE ORIGINATION_DATE >= DATEADD(month, -12, CURRENT_DATE())
GROUP BY CREDIT_MIGRATION_CATEGORY
ORDER BY 
    CASE CREDIT_MIGRATION_CATEGORY
        WHEN 'Significant Improvement (50+ points)' THEN 1
        WHEN 'Moderate Improvement (20-49 points)' THEN 2
        WHEN 'Slight Improvement (10-19 points)' THEN 3
        WHEN 'Stable (+/-10 points)' THEN 4
        WHEN 'Slight Decline (10-19 points)' THEN 5
        WHEN 'Moderate Decline (20-49 points)' THEN 6
        WHEN 'Significant Decline (50+ points)' THEN 7
    END;
```

**High-risk credit cards:**
```sql
SELECT 
    MEMBER_NAME,
    CREDIT_LIMIT,
    CURRENT_BALANCE,
    UTILIZATION_PERCENTAGE,
    CREDIT_SCORE_CHANGE,
    RISK_LEVEL,
    LOAN_STATUS
FROM CREDIT_CARD_HEALTH_VIEW
WHERE RISK_LEVEL IN ('Critical', 'Severe', 'High')
ORDER BY RISK_LEVEL, UTILIZATION_PERCENTAGE DESC;
```

**Charge-offs by origination quarter:**
```sql
SELECT 
    ORIGINATION_QUARTER_START,
    COUNT(*) as total_originated,
    SUM(IS_CHARGED_OFF) as charge_offs,
    (SUM(IS_CHARGED_OFF)::FLOAT / COUNT(*)) * 100 as charge_off_rate_pct
FROM CREDIT_CARD_HEALTH_VIEW
GROUP BY ORIGINATION_QUARTER_START
ORDER BY ORIGINATION_QUARTER_START DESC;
```

---

## BRANCH_PERFORMANCE_VIEW

### Purpose
Branch-level performance metrics across all products and services. Enables branch comparison, regional analysis, and manager performance tracking.

### Source Tables
- `BRANCHES` (primary)
- `MEMBERS` (subqueries for member metrics)
- `ACCOUNTS` (subqueries for account metrics)
- `LOANS` (subqueries for loan metrics)

### Key Business Questions
- Which branches have the most members/deposits/loans?
- How does Encinitas branch compare to others?
- Which branch managers are top performers?
- What is the product mix by branch?
- Which branches have the most certificates maturing?

### Column Reference

#### Branch Identifiers & Details
| Column | Type | Description |
|--------|------|-------------|
| BRANCH_ID | VARCHAR(50) | Branch identifier |
| BRANCH_NAME | VARCHAR(200) | Branch name |
| BRANCH_CODE | VARCHAR(10) | Branch code |
| BRANCH_CITY | VARCHAR(100) | Branch city |
| BRANCH_STATE | VARCHAR(2) | Branch state |
| REGION | VARCHAR(50) | Geographic region |
| BRANCH_TYPE | VARCHAR(50) | Full Service, Limited Service, Online Only |
| MANAGER_NAME | VARCHAR(200) | Branch manager |
| BRANCH_OPEN_DATE | DATE | When branch opened |
| YEARS_OPEN | NUMBER | Years since opening |

#### Member Metrics
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_MEMBERS | NUMBER | All members at this branch |
| ACTIVE_MEMBERS | NUMBER | Active status members |
| NEW_MEMBERS_12_MONTHS | NUMBER | Members joined in last 12 months |
| NEW_MEMBERS_6_MONTHS | NUMBER | Members joined in last 6 months |
| NEW_MEMBERS_3_MONTHS | NUMBER | Members joined in last 3 months |

#### Account Metrics
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_ACCOUNTS | NUMBER | All deposit accounts |
| CHECKING_ACCOUNTS | NUMBER | Checking account count |
| SAVINGS_ACCOUNTS | NUMBER | Savings account count |
| CERTIFICATE_ACCOUNTS | NUMBER | Certificate account count |

#### Deposit Balances
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_DEPOSITS | NUMBER(15,2) | Sum of all deposit balances |
| CHECKING_BALANCE | NUMBER(15,2) | Total checking balance |
| SAVINGS_BALANCE | NUMBER(15,2) | Total savings balance |
| CERTIFICATE_BALANCE | NUMBER(15,2) | Total certificate balance |

#### Loan Metrics
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_LOANS | NUMBER | All loans |
| ACTIVE_LOANS | NUMBER | Active status loans |
| AUTO_LOANS | NUMBER | Auto loan count |
| CREDIT_CARD_LOANS | NUMBER | Credit card count |
| MORTGAGE_LOANS | NUMBER | Mortgage count |
| PERSONAL_LOANS | NUMBER | Personal loan count |

#### Loan Balances
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_LOAN_BALANCE | NUMBER(15,2) | Sum of active loan balances |
| AUTO_LOAN_BALANCE | NUMBER(15,2) | Auto loan balance |
| CREDIT_CARD_BALANCE | NUMBER(15,2) | Credit card balance |
| MORTGAGE_BALANCE | NUMBER(15,2) | Mortgage balance |
| PERSONAL_LOAN_BALANCE | NUMBER(15,2) | Personal loan balance |

#### Certificate Renewal Pipeline
| Column | Type | Description |
|--------|------|-------------|
| CERTIFICATES_MATURING_30_DAYS | NUMBER | Count maturing in 30 days |
| CERTIFICATES_MATURING_90_DAYS | NUMBER | Count maturing in 90 days |
| VALUE_MATURING_90_DAYS | NUMBER(15,2) | Value maturing in 90 days |

#### Credit Quality
| Column | Type | Description |
|--------|------|-------------|
| CHARGED_OFF_LOANS | NUMBER | Count of charged off loans |
| DELINQUENT_LOANS_30_PLUS | NUMBER | Count 30+ days delinquent |
| AVG_CREDIT_SCORE | NUMBER | Average credit score of loans |

#### Calculated Metrics
| Column | Type | Description |
|--------|------|-------------|
| AVG_DEPOSIT_PER_MEMBER | NUMBER(15,2) | Total deposits / total members |
| AVG_LOAN_PER_ACTIVE_MEMBER | NUMBER(15,2) | Total loans / active members |

### Sample Queries

**Rank branches by total deposits:**
```sql
SELECT 
    BRANCH_NAME,
    TOTAL_DEPOSITS,
    ACTIVE_MEMBERS,
    AVG_DEPOSIT_PER_MEMBER
FROM BRANCH_PERFORMANCE_VIEW
ORDER BY TOTAL_DEPOSITS DESC;
```

**Encinitas vs. all other branches:**
```sql
SELECT 
    CASE WHEN BRANCH_NAME = 'Encinitas Main Branch' THEN 'Encinitas' ELSE 'Other Branches' END as branch_group,
    SUM(TOTAL_DEPOSITS) as deposits,
    SUM(ACTIVE_MEMBERS) as members,
    SUM(CERTIFICATES_MATURING_90_DAYS) as certs_maturing_90d
FROM BRANCH_PERFORMANCE_VIEW
GROUP BY branch_group;
```

**Branch product penetration:**
```sql
SELECT 
    BRANCH_NAME,
    TOTAL_MEMBERS,
    CHECKING_ACCOUNTS,
    SAVINGS_ACCOUNTS,
    CERTIFICATE_ACCOUNTS,
    TOTAL_LOANS,
    (CHECKING_ACCOUNTS + SAVINGS_ACCOUNTS + CERTIFICATE_ACCOUNTS + TOTAL_LOANS)::FLOAT / NULLIF(TOTAL_MEMBERS, 0) as products_per_member
FROM BRANCH_PERFORMANCE_VIEW
ORDER BY products_per_member DESC;
```

---

## TIME_SERIES_METRICS_VIEW

### Purpose
Historical trending for all key metrics. **This is the primary view for "How are X trending?" and "Show me over time" questions.**

### Source Tables
- Date spine (generated for last 24 months)
- `MEMBERS` (subqueries for member metrics)
- `ACCOUNTS` (subqueries for account metrics)
- `LOANS` (subqueries for loan metrics by type)

### Key Business Questions
- How are auto loan balances trending over time?
- Is the auto loan percentage of total portfolio increasing or decreasing?
- What is month-over-month member growth?
- Show loan originations by type over time
- What are seasonal patterns?

### Column Reference

#### Time Dimensions
| Column | Type | Description |
|--------|------|-------------|
| METRIC_MONTH | DATE | First day of month (metric period) |
| METRIC_YEAR | NUMBER | Year |
| METRIC_QUARTER | NUMBER | Quarter (1-4) |
| METRIC_MONTH_NUMBER | NUMBER | Month (1-12) |
| METRIC_MONTH_NAME | VARCHAR | Month name |

#### Member Growth
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_MEMBERS_EOY | NUMBER | Total members at end of month |
| NEW_MEMBERS_MONTH | NUMBER | New members added in month |

#### Account Growth
| Column | Type | Description |
|--------|------|-------------|
| TOTAL_ACCOUNTS_EOM | NUMBER | Total accounts at end of month |

#### Loan Originations (Monthly)
| Column | Type | Description |
|--------|------|-------------|
| LOANS_ORIGINATED | NUMBER | All loans originated in month |
| AUTO_LOANS_ORIGINATED | NUMBER | Auto loans originated in month |
| CREDIT_CARDS_ORIGINATED | NUMBER | Credit cards originated in month |
| MORTGAGES_ORIGINATED | NUMBER | Mortgages originated in month |

#### Loan Balances (End of Month Snapshot)
| Column | Type | Description |
|--------|------|-------------|
| AUTO_LOAN_BALANCE_EOM | NUMBER(15,2) | Auto loan portfolio balance |
| CREDIT_CARD_BALANCE_EOM | NUMBER(15,2) | Credit card portfolio balance |
| MORTGAGE_BALANCE_EOM | NUMBER(15,2) | Mortgage portfolio balance |
| PERSONAL_LOAN_BALANCE_EOM | NUMBER(15,2) | Personal loan portfolio balance |
| TOTAL_LOAN_BALANCE_EOM | NUMBER(15,2) | Total loan portfolio balance |

#### Portfolio Composition (Percentages)
| Column | Type | Description |
|--------|------|-------------|
| AUTO_LOAN_PCT_OF_PORTFOLIO | NUMBER | (Auto balance / Total) * 100 |
| CREDIT_CARD_PCT_OF_PORTFOLIO | NUMBER | (CC balance / Total) * 100 |
| MORTGAGE_PCT_OF_PORTFOLIO | NUMBER | (Mortgage balance / Total) * 100 |

#### Month-over-Month Changes
| Column | Type | Description |
|--------|------|-------------|
| AUTO_LOAN_MOM_CHANGE | NUMBER(15,2) | Change in auto balance from prior month |
| TOTAL_LOAN_MOM_CHANGE | NUMBER(15,2) | Change in total loans from prior month |
| NEW_MEMBERS_MOM_CHANGE | NUMBER | Change in new members from prior month |

### Sample Queries

**Auto loan balance trend (last 12 months):**
```sql
SELECT 
    METRIC_MONTH,
    AUTO_LOAN_BALANCE_EOM,
    AUTO_LOAN_PCT_OF_PORTFOLIO,
    AUTO_LOAN_MOM_CHANGE
FROM TIME_SERIES_METRICS_VIEW
ORDER BY METRIC_MONTH DESC
LIMIT 12;
```

**Portfolio composition trending:**
```sql
SELECT 
    METRIC_MONTH,
    AUTO_LOAN_PCT_OF_PORTFOLIO,
    CREDIT_CARD_PCT_OF_PORTFOLIO,
    MORTGAGE_PCT_OF_PORTFOLIO
FROM TIME_SERIES_METRICS_VIEW
WHERE METRIC_MONTH >= DATEADD(month, -12, CURRENT_DATE())
ORDER BY METRIC_MONTH;
```

**Member acquisition momentum:**
```sql
SELECT 
    METRIC_MONTH,
    NEW_MEMBERS_MONTH,
    NEW_MEMBERS_MOM_CHANGE,
    CASE 
        WHEN NEW_MEMBERS_MOM_CHANGE > 0 THEN 'Accelerating'
        WHEN NEW_MEMBERS_MOM_CHANGE < 0 THEN 'Decelerating'
        ELSE 'Flat'
    END as momentum
FROM TIME_SERIES_METRICS_VIEW
WHERE METRIC_MONTH >= DATEADD(month, -12, CURRENT_DATE())
ORDER BY METRIC_MONTH DESC;
```

**Loan origination trends:**
```sql
SELECT 
    METRIC_MONTH,
    AUTO_LOANS_ORIGINATED,
    CREDIT_CARDS_ORIGINATED,
    MORTGAGES_ORIGINATED,
    LOANS_ORIGINATED as total_originated
FROM TIME_SERIES_METRICS_VIEW
WHERE METRIC_MONTH >= DATEADD(month, -12, CURRENT_DATE())
ORDER BY METRIC_MONTH;
```

---

## Cross-View Analysis Patterns

### Pattern 1: Member Acquisition + Branch Performance
**Question**: "Which branches are growing fastest?"
```sql
SELECT 
    B.BRANCH_NAME,
    B.TOTAL_MEMBERS,
    B.NEW_MEMBERS_12_MONTHS,
    (B.NEW_MEMBERS_12_MONTHS::FLOAT / NULLIF(B.TOTAL_MEMBERS - B.NEW_MEMBERS_12_MONTHS, 0)) * 100 as growth_rate_pct
FROM BRANCH_PERFORMANCE_VIEW B
ORDER BY growth_rate_pct DESC;
```

### Pattern 2: Loan Portfolio + Credit Card Health
**Question**: "Show me credit card portfolio health summary"
```sql
SELECT 
    'Total Credit Cards' as metric,
    COUNT(*) as value
FROM CREDIT_CARD_HEALTH_VIEW
UNION ALL
SELECT 'Average Utilization %', AVG(UTILIZATION_PERCENTAGE)
FROM CREDIT_CARD_HEALTH_VIEW
UNION ALL
SELECT 'Improving Credit Scores', COUNT(*)
FROM CREDIT_CARD_HEALTH_VIEW
WHERE CREDIT_SCORE_CHANGE > 0
UNION ALL
SELECT 'Charge-Offs', SUM(IS_CHARGED_OFF)
FROM CREDIT_CARD_HEALTH_VIEW;
```

### Pattern 3: Time Series + Branch Performance
**Question**: "Show auto loan trending for Encinitas"
```sql
-- Requires combining branch filter with time series
-- Use LOAN_PORTFOLIO_VIEW grouped by month for branch-specific trending
SELECT 
    DATE_TRUNC('MONTH', ORIGINATION_DATE) as month,
    COUNT(*) as autos_originated,
    SUM(CURRENT_BALANCE) as balance
FROM LOAN_PORTFOLIO_VIEW
WHERE IS_AUTO_LOAN = 1
  AND BRANCH_NAME = 'Encinitas Main Branch'
GROUP BY month
ORDER BY month DESC
LIMIT 12;
```

---

## Performance Optimization Tips

1. **Use Pre-Calculated Flags**: Instead of complex WHERE clauses, use the boolean flags (IS_ACTIVE, IS_MATURING_90_DAYS, etc.)

2. **Leverage Time Dimensions**: Use DATE_TRUNC fields (ORIGINATION_MONTH_START) instead of calculating in queries

3. **Filter Early**: Apply branch, date, or status filters before aggregations

4. **Use Appropriate View**: 
   - Credit card questions → CREDIT_CARD_HEALTH_VIEW
   - Trending questions → TIME_SERIES_METRICS_VIEW
   - Branch questions → BRANCH_PERFORMANCE_VIEW
   - Certificate renewals → CERTIFICATE_RENEWAL_VIEW

5. **Avoid Table Scans**: Use indexed columns (built into view definitions)

---

## View Selection Decision Tree

```
START: What is the question about?

├─ "How many new members?" → MEMBER_ACQUISITION_VIEW
├─ "Certificates maturing/renewing?" → CERTIFICATE_RENEWAL_VIEW
│  └─ "At Encinitas branch?" → Add BRANCH_NAME filter
│
├─ "Credit card health/migration/utilization?" → CREDIT_CARD_HEALTH_VIEW
│
├─ "Loan portfolio/auto loans/mortgages?"
│  ├─ "Trending over time?" → TIME_SERIES_METRICS_VIEW
│  └─ "Current snapshot?" → LOAN_PORTFOLIO_VIEW
│
├─ "Branch performance/comparison?" → BRANCH_PERFORMANCE_VIEW
│
└─ "Trending/over time/month-over-month?" → TIME_SERIES_METRICS_VIEW
```

---

**Document Version**: 1.0  
**Last Updated**: October 2025  
**Total Views**: 6  
**Total Columns**: 300+

