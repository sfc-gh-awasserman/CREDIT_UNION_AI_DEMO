-- =====================================================================
-- Snowflake Intelligence Demo: Credit Union
-- File: 02_load_synthetic_data.sql
-- Purpose: Generate and load synthetic data for the credit union demo
-- =====================================================================

USE DATABASE CREDIT_UNION_DEMO;
USE SCHEMA CREDIT_UNION_DATA;

-- =====================================================================
-- LOAD BRANCHES DATA
-- 8 branch locations across California and nearby states
-- =====================================================================
INSERT INTO BRANCHES (BRANCH_ID, BRANCH_NAME, BRANCH_CODE, ADDRESS, CITY, STATE, ZIP_CODE, REGION, BRANCH_TYPE, OPEN_DATE, MANAGER_NAME, PHONE)
VALUES
    ('BR001', 'Encinitas Main Branch', 'ENC', '123 Coast Highway', 'Encinitas', 'CA', '92024', 'San Diego County', 'Full Service', '2010-01-15', 'Sarah Mitchell', '760-555-0001'),
    ('BR002', 'Carlsbad Branch', 'CAR', '456 Carlsbad Village Dr', 'Carlsbad', 'CA', '92008', 'San Diego County', 'Full Service', '2012-03-20', 'Michael Johnson', '760-555-0002'),
    ('BR003', 'San Diego Downtown', 'SDD', '789 Broadway', 'San Diego', 'CA', '92101', 'San Diego County', 'Full Service', '2008-06-10', 'Jennifer Lee', '619-555-0003'),
    ('BR004', 'Oceanside Branch', 'OCS', '234 Mission Ave', 'Oceanside', 'CA', '92054', 'San Diego County', 'Full Service', '2015-09-01', 'David Chen', '760-555-0004'),
    ('BR005', 'Vista Branch', 'VST', '567 Vista Village Dr', 'Vista', 'CA', '92083', 'San Diego County', 'Limited Service', '2018-02-15', 'Amanda Rodriguez', '760-555-0005'),
    ('BR006', 'Escondido Branch', 'ESC', '890 Grand Ave', 'Escondido', 'CA', '92025', 'San Diego County', 'Full Service', '2013-11-20', 'Robert Taylor', '760-555-0006'),
    ('BR007', 'Online Branch', 'ONL', 'PO Box 1000', 'Encinitas', 'CA', '92024', 'Digital', 'Online Only', '2019-01-01', 'Lisa Anderson', '800-555-0007'),
    ('BR008', 'Temecula Branch', 'TEM', '345 Old Town Front St', 'Temecula', 'CA', '92590', 'Riverside County', 'Full Service', '2016-05-10', 'James Martinez', '951-555-0008');

-- =====================================================================
-- LOAD MEMBERS DATA
-- 5,000 members with varying join dates, segments, and demographics
-- =====================================================================
INSERT INTO MEMBERS (
    MEMBER_ID, MEMBER_NUMBER, FIRST_NAME, LAST_NAME, EMAIL, PHONE, DATE_OF_BIRTH, JOIN_DATE,
    PRIMARY_BRANCH_ID, MEMBER_STATUS, MEMBER_SEGMENT, RISK_RATING, ADDRESS, CITY, STATE, ZIP_CODE,
    EMPLOYMENT_STATUS, ANNUAL_INCOME, MARKETING_CHANNEL
)
WITH member_base AS (
    SELECT 
        'MEM' || LPAD(SEQ4(), 6, '0') AS MEMBER_ID,
        'M' || LPAD(SEQ4(), 8, '0') AS MEMBER_NUMBER,
        -- Random first names
        CASE UNIFORM(1, 20, RANDOM())
            WHEN 1 THEN 'James' WHEN 2 THEN 'Mary' WHEN 3 THEN 'John' WHEN 4 THEN 'Patricia'
            WHEN 5 THEN 'Robert' WHEN 6 THEN 'Jennifer' WHEN 7 THEN 'Michael' WHEN 8 THEN 'Linda'
            WHEN 9 THEN 'William' WHEN 10 THEN 'Elizabeth' WHEN 11 THEN 'David' WHEN 12 THEN 'Barbara'
            WHEN 13 THEN 'Richard' WHEN 14 THEN 'Susan' WHEN 15 THEN 'Joseph' WHEN 16 THEN 'Jessica'
            WHEN 17 THEN 'Thomas' WHEN 18 THEN 'Sarah' WHEN 19 THEN 'Christopher' ELSE 'Karen'
        END AS FIRST_NAME,
        -- Random last names
        CASE UNIFORM(1, 20, RANDOM())
            WHEN 1 THEN 'Smith' WHEN 2 THEN 'Johnson' WHEN 3 THEN 'Williams' WHEN 4 THEN 'Brown'
            WHEN 5 THEN 'Jones' WHEN 6 THEN 'Garcia' WHEN 7 THEN 'Miller' WHEN 8 THEN 'Davis'
            WHEN 9 THEN 'Rodriguez' WHEN 10 THEN 'Martinez' WHEN 11 THEN 'Hernandez' WHEN 12 THEN 'Lopez'
            WHEN 13 THEN 'Gonzalez' WHEN 14 THEN 'Wilson' WHEN 15 THEN 'Anderson' WHEN 16 THEN 'Thomas'
            WHEN 17 THEN 'Taylor' WHEN 18 THEN 'Moore' WHEN 19 THEN 'Jackson' ELSE 'Martin'
        END AS LAST_NAME,
        DATEADD(day, -UNIFORM(90, 10950, RANDOM()), CURRENT_DATE()) AS JOIN_DATE, -- Last 30 years, weighted recent
        DATEADD(year, -UNIFORM(25, 75, RANDOM()), CURRENT_DATE()) AS DATE_OF_BIRTH,
        UNIFORM(1, 100, RANDOM()) AS BRANCH_RAND,
        UNIFORM(1, 100, RANDOM()) AS STATUS_RAND,
        UNIFORM(45000, 250000, RANDOM()) AS ANNUAL_INCOME,
        UNIFORM(1, 100, RANDOM()) AS CHANNEL_RAND,
        UNIFORM(1, 10, RANDOM()) AS RISK_RAND,
        UNIFORM(1, 10, RANDOM()) AS EMPLOYMENT_RAND
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
)
SELECT 
    MEMBER_ID,
    MEMBER_NUMBER,
    FIRST_NAME,
    LAST_NAME,
    LOWER(FIRST_NAME || '.' || LAST_NAME || '@email.com') AS EMAIL,
    '(' || UNIFORM(200, 999, RANDOM()) || ') ' || UNIFORM(200, 999, RANDOM()) || '-' || LPAD(UNIFORM(0, 9999, RANDOM()), 4, '0') AS PHONE,
    DATE_OF_BIRTH,
    JOIN_DATE,
    -- Branch distribution (Encinitas gets 25% for drill-down questions)
    CASE 
        WHEN BRANCH_RAND BETWEEN 1 AND 25 THEN 'BR001' -- Encinitas 25%
        WHEN BRANCH_RAND BETWEEN 26 AND 40 THEN 'BR002' -- Carlsbad 15%
        WHEN BRANCH_RAND BETWEEN 41 AND 55 THEN 'BR003' -- San Diego 15%
        WHEN BRANCH_RAND BETWEEN 56 AND 68 THEN 'BR004' -- Oceanside 13%
        WHEN BRANCH_RAND BETWEEN 69 AND 78 THEN 'BR007' -- Online 10%
        WHEN BRANCH_RAND BETWEEN 79 AND 88 THEN 'BR006' -- Escondido 10%
        WHEN BRANCH_RAND BETWEEN 89 AND 95 THEN 'BR005' -- Vista 7%
        ELSE 'BR008' -- Temecula 5%
    END AS PRIMARY_BRANCH_ID,
    -- Member status (95% active)
    CASE 
        WHEN STATUS_RAND BETWEEN 1 AND 95 THEN 'Active'
        WHEN STATUS_RAND BETWEEN 96 AND 98 THEN 'Inactive'
        ELSE 'Dormant'
    END AS MEMBER_STATUS,
    -- Member segment based on tenure
    CASE 
        WHEN DATEDIFF(month, JOIN_DATE, CURRENT_DATE()) < 12 THEN 'New'
        WHEN DATEDIFF(month, JOIN_DATE, CURRENT_DATE()) BETWEEN 12 AND 60 THEN 'Established'
        WHEN DATEDIFF(month, JOIN_DATE, CURRENT_DATE()) > 60 AND ANNUAL_INCOME > 150000 THEN 'Premium'
        ELSE 'Loyal'
    END AS MEMBER_SEGMENT,
    -- Risk rating
    CASE 
        WHEN RISK_RAND BETWEEN 1 AND 8 THEN 'Low'
        WHEN RISK_RAND BETWEEN 9 AND 10 THEN 'Medium'
        ELSE 'High'
    END AS RISK_RATING,
    UNIFORM(100, 9999, RANDOM()) || ' Main St' AS ADDRESS,
    CASE 
        WHEN BRANCH_RAND BETWEEN 1 AND 25 THEN 'Encinitas'
        WHEN BRANCH_RAND BETWEEN 26 AND 40 THEN 'Carlsbad'
        WHEN BRANCH_RAND BETWEEN 41 AND 55 THEN 'San Diego'
        WHEN BRANCH_RAND BETWEEN 56 AND 68 THEN 'Oceanside'
        WHEN BRANCH_RAND BETWEEN 89 AND 95 THEN 'Vista'
        WHEN BRANCH_RAND BETWEEN 79 AND 88 THEN 'Escondido'
        WHEN BRANCH_RAND BETWEEN 69 AND 78 THEN 'San Diego'
        ELSE 'Temecula'
    END AS CITY,
    'CA' AS STATE,
    CASE 
        WHEN BRANCH_RAND BETWEEN 1 AND 25 THEN '92024'
        WHEN BRANCH_RAND BETWEEN 26 AND 40 THEN '92008'
        WHEN BRANCH_RAND BETWEEN 41 AND 55 THEN '92101'
        WHEN BRANCH_RAND BETWEEN 56 AND 68 THEN '92054'
        WHEN BRANCH_RAND BETWEEN 89 AND 95 THEN '92083'
        WHEN BRANCH_RAND BETWEEN 79 AND 88 THEN '92025'
        WHEN BRANCH_RAND BETWEEN 69 AND 78 THEN '92101'
        ELSE '92590'
    END AS ZIP_CODE,
    -- Employment status
    CASE 
        WHEN EMPLOYMENT_RAND BETWEEN 1 AND 6 THEN 'Employed Full-time'
        WHEN EMPLOYMENT_RAND BETWEEN 7 AND 8 THEN 'Self-employed'
        WHEN EMPLOYMENT_RAND = 9 THEN 'Retired'
        ELSE 'Part-time'
    END AS EMPLOYMENT_STATUS,
    ANNUAL_INCOME,
    -- Marketing channel distribution
    CASE 
        WHEN CHANNEL_RAND BETWEEN 1 AND 30 THEN 'Referral'
        WHEN CHANNEL_RAND BETWEEN 31 AND 50 THEN 'Online'
        WHEN CHANNEL_RAND BETWEEN 51 AND 65 THEN 'Branch Walk-in'
        WHEN CHANNEL_RAND BETWEEN 66 AND 80 THEN 'Social Media'
        WHEN CHANNEL_RAND BETWEEN 81 AND 90 THEN 'Email Campaign'
        ELSE 'Direct Mail'
    END AS MARKETING_CHANNEL
FROM member_base;

-- =====================================================================
-- LOAD ACCOUNTS DATA
-- Multiple accounts per member: checking, savings, certificates
-- =====================================================================

-- Checking accounts (80% of members have one)
INSERT INTO ACCOUNTS (
    ACCOUNT_ID, ACCOUNT_NUMBER, MEMBER_ID, BRANCH_ID, ACCOUNT_TYPE, ACCOUNT_STATUS,
    OPEN_DATE, CURRENT_BALANCE, AVAILABLE_BALANCE, INTEREST_RATE, MINIMUM_BALANCE
)
SELECT 
    'ACC' || LPAD(ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID), 8, '0') AS ACCOUNT_ID,
    'CHK' || LPAD(ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID), 10, '0') AS ACCOUNT_NUMBER,
    M.MEMBER_ID,
    M.PRIMARY_BRANCH_ID,
    'Checking' AS ACCOUNT_TYPE,
    'Active' AS ACCOUNT_STATUS,
    DATEADD(day, UNIFORM(0, 30, RANDOM()), M.JOIN_DATE) AS OPEN_DATE,
    UNIFORM(500, 15000, RANDOM()) AS CURRENT_BALANCE,
    UNIFORM(500, 15000, RANDOM()) AS AVAILABLE_BALANCE,
    0.0050 AS INTEREST_RATE,
    500 AS MINIMUM_BALANCE
FROM MEMBERS M
WHERE UNIFORM(1, 100, RANDOM()) <= 80;

-- Savings accounts (70% of members have one)
INSERT INTO ACCOUNTS (
    ACCOUNT_ID, ACCOUNT_NUMBER, MEMBER_ID, BRANCH_ID, ACCOUNT_TYPE, ACCOUNT_STATUS,
    OPEN_DATE, CURRENT_BALANCE, AVAILABLE_BALANCE, INTEREST_RATE, MINIMUM_BALANCE
)
SELECT 
    'ACC' || LPAD((SELECT COUNT(*) FROM ACCOUNTS) + ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID), 8, '0') AS ACCOUNT_ID,
    'SAV' || LPAD(ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID), 10, '0') AS ACCOUNT_NUMBER,
    M.MEMBER_ID,
    M.PRIMARY_BRANCH_ID,
    'Savings' AS ACCOUNT_TYPE,
    'Active' AS ACCOUNT_STATUS,
    DATEADD(day, UNIFORM(0, 30, RANDOM()), M.JOIN_DATE) AS OPEN_DATE,
    UNIFORM(2000, 50000, RANDOM()) AS CURRENT_BALANCE,
    UNIFORM(2000, 50000, RANDOM()) AS AVAILABLE_BALANCE,
    0.0350 AS INTEREST_RATE,
    1000 AS MINIMUM_BALANCE
FROM MEMBERS M
WHERE UNIFORM(1, 100, RANDOM()) <= 70;

-- Certificate (CD) accounts with various maturity dates
-- 30% of members have certificates
INSERT INTO ACCOUNTS (
    ACCOUNT_ID, ACCOUNT_NUMBER, MEMBER_ID, BRANCH_ID, ACCOUNT_TYPE, ACCOUNT_STATUS,
    OPEN_DATE, CURRENT_BALANCE, AVAILABLE_BALANCE, INTEREST_RATE, MINIMUM_BALANCE,
    CERTIFICATE_TERM_MONTHS, MATURITY_DATE, RENEWAL_STATUS, ORIGINAL_DEPOSIT_AMOUNT
)
WITH cd_base AS (
    SELECT 
        M.MEMBER_ID,
        M.PRIMARY_BRANCH_ID,
        DATEADD(month, -UNIFORM(1, 36, RANDOM()), CURRENT_DATE()) AS OPEN_DATE,
        CASE UNIFORM(1, 6, RANDOM())
            WHEN 1 THEN 6
            WHEN 2 THEN 12
            WHEN 3 THEN 18
            WHEN 4 THEN 24
            WHEN 5 THEN 36
            ELSE 60
        END AS CERTIFICATE_TERM_MONTHS,
        UNIFORM(5000, 100000, RANDOM()) AS ORIGINAL_DEPOSIT_AMOUNT,
        ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID) AS ROW_NUM
    FROM MEMBERS M
    WHERE UNIFORM(1, 100, RANDOM()) <= 30
)
SELECT 
    'ACC' || LPAD((SELECT COUNT(*) FROM ACCOUNTS) + ROW_NUM, 8, '0') AS ACCOUNT_ID,
    'CD' || LPAD(ROW_NUM, 10, '0') AS ACCOUNT_NUMBER,
    MEMBER_ID,
    PRIMARY_BRANCH_ID,
    'Certificate' AS ACCOUNT_TYPE,
    'Active' AS ACCOUNT_STATUS,
    OPEN_DATE,
    ORIGINAL_DEPOSIT_AMOUNT AS CURRENT_BALANCE,
    0 AS AVAILABLE_BALANCE,
    CASE CERTIFICATE_TERM_MONTHS
        WHEN 6 THEN 0.0300
        WHEN 12 THEN 0.0425
        WHEN 18 THEN 0.0475
        WHEN 24 THEN 0.0525
        WHEN 36 THEN 0.0575
        ELSE 0.0625
    END AS INTEREST_RATE,
    ORIGINAL_DEPOSIT_AMOUNT AS MINIMUM_BALANCE,
    CERTIFICATE_TERM_MONTHS,
    DATEADD(month, CERTIFICATE_TERM_MONTHS, OPEN_DATE) AS MATURITY_DATE,
    CASE 
        WHEN DATEADD(month, CERTIFICATE_TERM_MONTHS, OPEN_DATE) < DATEADD(month, 3, CURRENT_DATE()) THEN 'Pending'
        WHEN DATEADD(month, CERTIFICATE_TERM_MONTHS, OPEN_DATE) < DATEADD(month, 6, CURRENT_DATE()) THEN 'Auto-Renew'
        ELSE 'Auto-Renew'
    END AS RENEWAL_STATUS,
    ORIGINAL_DEPOSIT_AMOUNT
FROM cd_base;

-- =====================================================================
-- LOAD LOANS DATA
-- Auto loans, credit cards, mortgages, personal loans
-- =====================================================================

-- AUTO LOANS (35% of members, focus area for trending questions)
INSERT INTO LOANS (
    LOAN_ID, LOAN_NUMBER, MEMBER_ID, BRANCH_ID, LOAN_TYPE, LOAN_STATUS,
    ORIGINATION_DATE, ORIGINAL_LOAN_AMOUNT, CURRENT_BALANCE, INTEREST_RATE,
    TERM_MONTHS, MONTHLY_PAYMENT, PAYMENT_DUE_DAY, NEXT_PAYMENT_DATE,
    LAST_PAYMENT_DATE, LAST_PAYMENT_AMOUNT, DAYS_DELINQUENT,
    ORIGINATION_CREDIT_SCORE, CURRENT_CREDIT_SCORE, LOAN_TO_VALUE_RATIO, COLLATERAL_TYPE
)
WITH auto_loan_base AS (
    SELECT 
        M.MEMBER_ID,
        M.PRIMARY_BRANCH_ID,
        DATEADD(month, -UNIFORM(1, 72, RANDOM()), CURRENT_DATE()) AS ORIGINATION_DATE,
        UNIFORM(15000, 65000, RANDOM()) AS ORIGINAL_LOAN_AMOUNT,
        CASE UNIFORM(1, 3, RANDOM())
            WHEN 1 THEN 48
            WHEN 2 THEN 60
            ELSE 72
        END AS TERM_MONTHS,
        UNIFORM(650, 800, RANDOM()) AS ORIGINATION_CREDIT_SCORE,
        ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID) AS ROW_NUM
    FROM MEMBERS M
    WHERE M.MEMBER_STATUS = 'Active' AND UNIFORM(1, 100, RANDOM()) <= 35
)
SELECT 
    'LN' || LPAD(ROW_NUM, 8, '0') AS LOAN_ID,
    'AUTO' || LPAD(ROW_NUM, 10, '0') AS LOAN_NUMBER,
    MEMBER_ID,
    PRIMARY_BRANCH_ID,
    'Auto' AS LOAN_TYPE,
    CASE 
        WHEN DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE()) >= TERM_MONTHS THEN 'Paid Off'
        WHEN UNIFORM(1, 100, RANDOM()) > 96 THEN 'Delinquent'
        WHEN UNIFORM(1, 100, RANDOM()) > 98 THEN 'Charged Off'
        ELSE 'Active'
    END AS LOAN_STATUS,
    ORIGINATION_DATE,
    ORIGINAL_LOAN_AMOUNT,
    -- Calculate remaining balance
    CASE 
        WHEN DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE()) >= TERM_MONTHS THEN 0
        ELSE ORIGINAL_LOAN_AMOUNT * (1 - (DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE())::FLOAT / TERM_MONTHS))
    END AS CURRENT_BALANCE,
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN 0.0399
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN 0.0499
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN 0.0599
        ELSE 0.0699
    END AS INTEREST_RATE,
    TERM_MONTHS,
    ORIGINAL_LOAN_AMOUNT / TERM_MONTHS AS MONTHLY_PAYMENT,
    UNIFORM(1, 28, RANDOM()) AS PAYMENT_DUE_DAY,
    DATEADD(month, 1, CURRENT_DATE()) AS NEXT_PAYMENT_DATE,
    DATEADD(day, -UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) AS LAST_PAYMENT_DATE,
    ORIGINAL_LOAN_AMOUNT / TERM_MONTHS AS LAST_PAYMENT_AMOUNT,
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) > 96 THEN UNIFORM(1, 90, RANDOM())
        ELSE 0
    END AS DAYS_DELINQUENT,
    ORIGINATION_CREDIT_SCORE,
    -- Credit score can improve or decline slightly over time
    ORIGINATION_CREDIT_SCORE + UNIFORM(-30, 50, RANDOM()) AS CURRENT_CREDIT_SCORE,
    0.8500 AS LOAN_TO_VALUE_RATIO,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Toyota Camry'
        WHEN 2 THEN 'Honda Accord'
        WHEN 3 THEN 'Ford F-150'
        WHEN 4 THEN 'Chevrolet Silverado'
        WHEN 5 THEN 'Tesla Model 3'
        WHEN 6 THEN 'Honda CR-V'
        WHEN 7 THEN 'Toyota RAV4'
        WHEN 8 THEN 'Nissan Altima'
        WHEN 9 THEN 'Jeep Grand Cherokee'
        ELSE 'Subaru Outback'
    END AS COLLATERAL_TYPE
FROM auto_loan_base;

-- CREDIT CARD LOANS (45% of members, focus area for health analysis)
INSERT INTO LOANS (
    LOAN_ID, LOAN_NUMBER, MEMBER_ID, BRANCH_ID, LOAN_TYPE, LOAN_STATUS,
    ORIGINATION_DATE, ORIGINAL_LOAN_AMOUNT, CURRENT_BALANCE, INTEREST_RATE,
    MONTHLY_PAYMENT, PAYMENT_DUE_DAY, NEXT_PAYMENT_DATE,
    LAST_PAYMENT_DATE, LAST_PAYMENT_AMOUNT, DAYS_DELINQUENT,
    CREDIT_LIMIT, AVAILABLE_CREDIT,
    ORIGINATION_CREDIT_SCORE, CURRENT_CREDIT_SCORE
)
WITH cc_loan_base AS (
    SELECT 
        M.MEMBER_ID,
        M.PRIMARY_BRANCH_ID,
        DATEADD(month, -UNIFORM(6, 60, RANDOM()), CURRENT_DATE()) AS ORIGINATION_DATE,
        UNIFORM(650, 820, RANDOM()) AS ORIGINATION_CREDIT_SCORE,
        ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID) AS ROW_NUM
    FROM MEMBERS M
    WHERE M.MEMBER_STATUS = 'Active' AND UNIFORM(1, 100, RANDOM()) <= 45
)
SELECT 
    'LN' || LPAD((SELECT COUNT(*) FROM LOANS) + ROW_NUM, 8, '0') AS LOAN_ID,
    'CC' || LPAD(ROW_NUM, 10, '0') AS LOAN_NUMBER,
    MEMBER_ID,
    PRIMARY_BRANCH_ID,
    'Credit Card' AS LOAN_TYPE,
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) > 97 THEN 'Inactive'
        WHEN UNIFORM(1, 100, RANDOM()) > 98 THEN 'Charged Off'
        ELSE 'Active'
    END AS LOAN_STATUS,
    ORIGINATION_DATE,
    NULL AS ORIGINAL_LOAN_AMOUNT,
    -- Current balance (utilization varies)
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN UNIFORM(15000, 30000, RANDOM()) * UNIFORM(5, 35, RANDOM()) / 100.0
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN UNIFORM(10000, 20000, RANDOM()) * UNIFORM(10, 45, RANDOM()) / 100.0
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN UNIFORM(5000, 12000, RANDOM()) * UNIFORM(20, 60, RANDOM()) / 100.0
        ELSE UNIFORM(2000, 8000, RANDOM()) * UNIFORM(30, 80, RANDOM()) / 100.0
    END AS CURRENT_BALANCE,
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN 0.1299
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN 0.1599
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN 0.1899
        ELSE 0.2199
    END AS INTEREST_RATE,
    -- Monthly payment is minimum 2% of balance
    (CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN UNIFORM(15000, 30000, RANDOM()) * UNIFORM(5, 35, RANDOM()) / 100.0
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN UNIFORM(10000, 20000, RANDOM()) * UNIFORM(10, 45, RANDOM()) / 100.0
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN UNIFORM(5000, 12000, RANDOM()) * UNIFORM(20, 60, RANDOM()) / 100.0
        ELSE UNIFORM(2000, 8000, RANDOM()) * UNIFORM(30, 80, RANDOM()) / 100.0
    END) * 0.02 AS MONTHLY_PAYMENT,
    UNIFORM(1, 28, RANDOM()) AS PAYMENT_DUE_DAY,
    DATEADD(month, 1, CURRENT_DATE()) AS NEXT_PAYMENT_DATE,
    DATEADD(day, -UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) AS LAST_PAYMENT_DATE,
    (CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN UNIFORM(15000, 30000, RANDOM()) * UNIFORM(5, 35, RANDOM()) / 100.0
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN UNIFORM(10000, 20000, RANDOM()) * UNIFORM(10, 45, RANDOM()) / 100.0
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN UNIFORM(5000, 12000, RANDOM()) * UNIFORM(20, 60, RANDOM()) / 100.0
        ELSE UNIFORM(2000, 8000, RANDOM()) * UNIFORM(30, 80, RANDOM()) / 100.0
    END) * 0.02 AS LAST_PAYMENT_AMOUNT,
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) > 95 THEN UNIFORM(1, 60, RANDOM())
        ELSE 0
    END AS DAYS_DELINQUENT,
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN UNIFORM(15000, 30000, RANDOM())
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN UNIFORM(10000, 20000, RANDOM())
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN UNIFORM(5000, 12000, RANDOM())
        ELSE UNIFORM(2000, 8000, RANDOM())
    END AS CREDIT_LIMIT,
    -- Available credit = limit - balance
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 750 THEN UNIFORM(15000, 30000, RANDOM()) - (UNIFORM(15000, 30000, RANDOM()) * UNIFORM(5, 35, RANDOM()) / 100.0)
        WHEN ORIGINATION_CREDIT_SCORE >= 700 THEN UNIFORM(10000, 20000, RANDOM()) - (UNIFORM(10000, 20000, RANDOM()) * UNIFORM(10, 45, RANDOM()) / 100.0)
        WHEN ORIGINATION_CREDIT_SCORE >= 650 THEN UNIFORM(5000, 12000, RANDOM()) - (UNIFORM(5000, 12000, RANDOM()) * UNIFORM(20, 60, RANDOM()) / 100.0)
        ELSE UNIFORM(2000, 8000, RANDOM()) - (UNIFORM(2000, 8000, RANDOM()) * UNIFORM(30, 80, RANDOM()) / 100.0)
    END AS AVAILABLE_CREDIT,
    ORIGINATION_CREDIT_SCORE,
    -- Credit score migration over time (can go up or down)
    ORIGINATION_CREDIT_SCORE + UNIFORM(-50, 80, RANDOM()) AS CURRENT_CREDIT_SCORE
FROM cc_loan_base;

-- MORTGAGE LOANS (25% of members)
INSERT INTO LOANS (
    LOAN_ID, LOAN_NUMBER, MEMBER_ID, BRANCH_ID, LOAN_TYPE, LOAN_STATUS,
    ORIGINATION_DATE, ORIGINAL_LOAN_AMOUNT, CURRENT_BALANCE, INTEREST_RATE,
    TERM_MONTHS, MONTHLY_PAYMENT, PAYMENT_DUE_DAY, NEXT_PAYMENT_DATE,
    LAST_PAYMENT_DATE, LAST_PAYMENT_AMOUNT, DAYS_DELINQUENT,
    ORIGINATION_CREDIT_SCORE, CURRENT_CREDIT_SCORE, LOAN_TO_VALUE_RATIO, COLLATERAL_TYPE
)
WITH mortgage_base AS (
    SELECT 
        M.MEMBER_ID,
        M.PRIMARY_BRANCH_ID,
        DATEADD(month, -UNIFORM(12, 180, RANDOM()), CURRENT_DATE()) AS ORIGINATION_DATE,
        UNIFORM(250000, 800000, RANDOM()) AS ORIGINAL_LOAN_AMOUNT,
        CASE UNIFORM(1, 3, RANDOM())
            WHEN 1 THEN 180  -- 15 year
            WHEN 2 THEN 240  -- 20 year
            ELSE 360         -- 30 year
        END AS TERM_MONTHS,
        UNIFORM(680, 820, RANDOM()) AS ORIGINATION_CREDIT_SCORE,
        ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID) AS ROW_NUM
    FROM MEMBERS M
    WHERE M.MEMBER_STATUS = 'Active' AND M.ANNUAL_INCOME > 80000 AND UNIFORM(1, 100, RANDOM()) <= 25
)
SELECT 
    'LN' || LPAD((SELECT COUNT(*) FROM LOANS) + ROW_NUM, 8, '0') AS LOAN_ID,
    'MTG' || LPAD(ROW_NUM, 10, '0') AS LOAN_NUMBER,
    MEMBER_ID,
    PRIMARY_BRANCH_ID,
    'Mortgage' AS LOAN_TYPE,
    CASE 
        WHEN DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE()) >= TERM_MONTHS THEN 'Paid Off'
        WHEN UNIFORM(1, 100, RANDOM()) > 98 THEN 'Delinquent'
        ELSE 'Active'
    END AS LOAN_STATUS,
    ORIGINATION_DATE,
    ORIGINAL_LOAN_AMOUNT,
    -- Calculate remaining balance
    CASE 
        WHEN DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE()) >= TERM_MONTHS THEN 0
        ELSE ORIGINAL_LOAN_AMOUNT * (1 - (DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE())::FLOAT / TERM_MONTHS) * 0.7)
    END AS CURRENT_BALANCE,
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 760 THEN 0.0350
        WHEN ORIGINATION_CREDIT_SCORE >= 720 THEN 0.0399
        WHEN ORIGINATION_CREDIT_SCORE >= 680 THEN 0.0449
        ELSE 0.0499
    END AS INTEREST_RATE,
    TERM_MONTHS,
    ORIGINAL_LOAN_AMOUNT / TERM_MONTHS * 1.2 AS MONTHLY_PAYMENT,
    1 AS PAYMENT_DUE_DAY,
    DATEADD(month, 1, CURRENT_DATE()) AS NEXT_PAYMENT_DATE,
    DATEADD(day, -UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) AS LAST_PAYMENT_DATE,
    ORIGINAL_LOAN_AMOUNT / TERM_MONTHS * 1.2 AS LAST_PAYMENT_AMOUNT,
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) > 98 THEN UNIFORM(1, 90, RANDOM())
        ELSE 0
    END AS DAYS_DELINQUENT,
    ORIGINATION_CREDIT_SCORE,
    ORIGINATION_CREDIT_SCORE + UNIFORM(-20, 40, RANDOM()) AS CURRENT_CREDIT_SCORE,
    0.8000 AS LOAN_TO_VALUE_RATIO,
    UNIFORM(100, 9999, RANDOM()) || ' Main St, ' || 
    CASE UNIFORM(1, 8, RANDOM())
        WHEN 1 THEN 'Encinitas'
        WHEN 2 THEN 'Carlsbad'
        WHEN 3 THEN 'San Diego'
        WHEN 4 THEN 'Oceanside'
        WHEN 5 THEN 'Vista'
        WHEN 6 THEN 'Escondido'
        WHEN 7 THEN 'Del Mar'
        ELSE 'Temecula'
    END || ', CA' AS COLLATERAL_TYPE
FROM mortgage_base;

-- PERSONAL LOANS (15% of members)
INSERT INTO LOANS (
    LOAN_ID, LOAN_NUMBER, MEMBER_ID, BRANCH_ID, LOAN_TYPE, LOAN_STATUS,
    ORIGINATION_DATE, ORIGINAL_LOAN_AMOUNT, CURRENT_BALANCE, INTEREST_RATE,
    TERM_MONTHS, MONTHLY_PAYMENT, PAYMENT_DUE_DAY, NEXT_PAYMENT_DATE,
    LAST_PAYMENT_DATE, LAST_PAYMENT_AMOUNT, DAYS_DELINQUENT,
    ORIGINATION_CREDIT_SCORE, CURRENT_CREDIT_SCORE
)
WITH personal_loan_base AS (
    SELECT 
        M.MEMBER_ID,
        M.PRIMARY_BRANCH_ID,
        DATEADD(month, -UNIFORM(1, 60, RANDOM()), CURRENT_DATE()) AS ORIGINATION_DATE,
        UNIFORM(5000, 35000, RANDOM()) AS ORIGINAL_LOAN_AMOUNT,
        CASE UNIFORM(1, 3, RANDOM())
            WHEN 1 THEN 24
            WHEN 2 THEN 36
            ELSE 48
        END AS TERM_MONTHS,
        UNIFORM(640, 780, RANDOM()) AS ORIGINATION_CREDIT_SCORE,
        ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID) AS ROW_NUM
    FROM MEMBERS M
    WHERE M.MEMBER_STATUS = 'Active' AND UNIFORM(1, 100, RANDOM()) <= 15
)
SELECT 
    'LN' || LPAD((SELECT COUNT(*) FROM LOANS) + ROW_NUM, 8, '0') AS LOAN_ID,
    'PL' || LPAD(ROW_NUM, 10, '0') AS LOAN_NUMBER,
    MEMBER_ID,
    PRIMARY_BRANCH_ID,
    'Personal' AS LOAN_TYPE,
    CASE 
        WHEN DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE()) >= TERM_MONTHS THEN 'Paid Off'
        WHEN UNIFORM(1, 100, RANDOM()) > 94 THEN 'Delinquent'
        WHEN UNIFORM(1, 100, RANDOM()) > 97 THEN 'Charged Off'
        ELSE 'Active'
    END AS LOAN_STATUS,
    ORIGINATION_DATE,
    ORIGINAL_LOAN_AMOUNT,
    -- Calculate remaining balance
    CASE 
        WHEN DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE()) >= TERM_MONTHS THEN 0
        ELSE ORIGINAL_LOAN_AMOUNT * (1 - (DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE())::FLOAT / TERM_MONTHS))
    END AS CURRENT_BALANCE,
    CASE 
        WHEN ORIGINATION_CREDIT_SCORE >= 740 THEN 0.0699
        WHEN ORIGINATION_CREDIT_SCORE >= 680 THEN 0.0899
        ELSE 0.1099
    END AS INTEREST_RATE,
    TERM_MONTHS,
    ORIGINAL_LOAN_AMOUNT / TERM_MONTHS AS MONTHLY_PAYMENT,
    UNIFORM(1, 28, RANDOM()) AS PAYMENT_DUE_DAY,
    DATEADD(month, 1, CURRENT_DATE()) AS NEXT_PAYMENT_DATE,
    DATEADD(day, -UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) AS LAST_PAYMENT_DATE,
    ORIGINAL_LOAN_AMOUNT / TERM_MONTHS AS LAST_PAYMENT_AMOUNT,
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) > 94 THEN UNIFORM(1, 90, RANDOM())
        ELSE 0
    END AS DAYS_DELINQUENT,
    ORIGINATION_CREDIT_SCORE,
    ORIGINATION_CREDIT_SCORE + UNIFORM(-40, 60, RANDOM()) AS CURRENT_CREDIT_SCORE
FROM personal_loan_base;

-- =====================================================================
-- LOAD CREDIT SCORE HISTORY
-- Track credit scores over time for trend analysis
-- =====================================================================
INSERT INTO CREDIT_SCORE_HISTORY (SCORE_ID, MEMBER_ID, SCORE_DATE, CREDIT_SCORE, SCORE_SOURCE)
WITH score_dates AS (
    SELECT 
        L.MEMBER_ID,
        L.ORIGINATION_DATE,
        L.ORIGINATION_CREDIT_SCORE,
        L.CURRENT_CREDIT_SCORE,
        DATEADD(month, VALUE, L.ORIGINATION_DATE) AS SCORE_DATE,
        VALUE AS MONTHS_SINCE_ORIG
    FROM LOANS L,
    LATERAL FLATTEN(INPUT => ARRAY_GENERATE_RANGE(0, GREATEST(DATEDIFF(month, L.ORIGINATION_DATE, CURRENT_DATE()), 1)))
    WHERE L.LOAN_TYPE IN ('Credit Card', 'Auto', 'Personal')
        AND DATEADD(month, VALUE, L.ORIGINATION_DATE) <= CURRENT_DATE()
)
SELECT 
    'CS' || LPAD(ROW_NUMBER() OVER (ORDER BY MEMBER_ID, SCORE_DATE), 10, '0') AS SCORE_ID,
    MEMBER_ID,
    SCORE_DATE,
    -- Gradually migrate from origination to current score
    CASE 
        WHEN MONTHS_SINCE_ORIG = 0 THEN ORIGINATION_CREDIT_SCORE
        ELSE ORIGINATION_CREDIT_SCORE + 
             ((CURRENT_CREDIT_SCORE - ORIGINATION_CREDIT_SCORE) * 
              (MONTHS_SINCE_ORIG::FLOAT / DATEDIFF(month, ORIGINATION_DATE, CURRENT_DATE())))
    END AS CREDIT_SCORE,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Equifax'
        WHEN 2 THEN 'Experian'
        ELSE 'TransUnion'
    END AS SCORE_SOURCE
FROM score_dates;

-- =====================================================================
-- LOAD MARKETING CAMPAIGNS
-- =====================================================================
INSERT INTO MARKETING_CAMPAIGNS (
    CAMPAIGN_ID, CAMPAIGN_NAME, CAMPAIGN_TYPE, CAMPAIGN_CHANNEL,
    START_DATE, END_DATE, BUDGET, ACTUAL_SPEND, TARGET_AUDIENCE, CAMPAIGN_GOAL
)
VALUES
    ('CAMP001', 'New Member Welcome 2024', 'Member Acquisition', 'Email', '2024-01-01', '2024-03-31', 50000, 47500, 'Prospective Members', 'Acquire 500 new members'),
    ('CAMP002', 'Summer Auto Loan Promo', 'Product Promotion', 'Social Media', '2024-06-01', '2024-08-31', 75000, 72000, 'Existing Members', 'Originate $5M in auto loans'),
    ('CAMP003', 'Certificate Rate Special Q2', 'Product Promotion', 'Direct Mail', '2024-04-01', '2024-06-30', 35000, 33500, 'High Balance Members', 'Attract $10M in CD deposits'),
    ('CAMP004', 'Credit Card Rewards Launch', 'Product Promotion', 'Online Ads', '2024-03-01', '2024-05-31', 60000, 58000, 'All Members', 'Issue 1,000 new credit cards'),
    ('CAMP005', 'Referral Bonus Program', 'Member Acquisition', 'Referral', '2024-01-01', '2024-12-31', 100000, 85000, 'Existing Members', 'Acquire 1,000 new members via referrals'),
    ('CAMP006', 'Mobile App Adoption Drive', 'Retention', 'Email', '2024-07-01', '2024-09-30', 25000, 24000, 'Active Members', 'Increase mobile app users by 40%'),
    ('CAMP007', 'Holiday Personal Loan Special', 'Product Promotion', 'Branch', '2024-11-01', '2024-12-31', 40000, 38000, 'Established Members', 'Originate $2M in personal loans'),
    ('CAMP008', 'Mortgage Rate Match Program', 'Product Promotion', 'Online', '2024-02-01', '2024-12-31', 125000, 118000, 'First-time Homebuyers', 'Originate $50M in mortgages');

-- =====================================================================
-- LOAD MEMBER CAMPAIGN RESPONSES
-- =====================================================================
INSERT INTO MEMBER_CAMPAIGN_RESPONSES (
    RESPONSE_ID, CAMPAIGN_ID, MEMBER_ID, RESPONSE_DATE, RESPONSE_TYPE,
    PRODUCT_APPLIED, APPLICATION_APPROVED, REVENUE_GENERATED
)
WITH campaign_with_duration AS (
    SELECT 
        CAMPAIGN_ID,
        START_DATE,
        COALESCE(END_DATE, CURRENT_DATE()) AS END_DATE,
        DATEDIFF(day, START_DATE, COALESCE(END_DATE, CURRENT_DATE())) AS CAMPAIGN_DAYS
    FROM MARKETING_CAMPAIGNS
),
campaign_responses AS (
    SELECT 
        C.CAMPAIGN_ID,
        M.MEMBER_ID,
        C.START_DATE,
        C.CAMPAIGN_DAYS,
        CASE UNIFORM(1, 5, RANDOM())
            WHEN 1 THEN 'Click'
            WHEN 2 THEN 'Open'
            WHEN 3 THEN 'Application'
            WHEN 4 THEN 'Conversion'
            ELSE 'Opt-out'
        END AS RESPONSE_TYPE,
        ROW_NUMBER() OVER (ORDER BY C.CAMPAIGN_ID, M.MEMBER_ID) AS ROW_NUM
    FROM campaign_with_duration C
    CROSS JOIN (SELECT MEMBER_ID FROM MEMBERS ORDER BY RANDOM() LIMIT 2000) M
    WHERE UNIFORM(1, 100, RANDOM()) <= 15
)
SELECT 
    'RESP' || LPAD(ROW_NUM, 8, '0') AS RESPONSE_ID,
    CAMPAIGN_ID,
    MEMBER_ID,
    DATEADD(day, FLOOR(UNIFORM(0, 1, RANDOM()) * CAMPAIGN_DAYS), START_DATE) AS RESPONSE_DATE,
    RESPONSE_TYPE,
    CASE 
        WHEN RESPONSE_TYPE IN ('Application', 'Conversion') THEN 
            CASE CAMPAIGN_ID
                WHEN 'CAMP001' THEN 'Checking Account'
                WHEN 'CAMP002' THEN 'Auto Loan'
                WHEN 'CAMP003' THEN 'Certificate'
                WHEN 'CAMP004' THEN 'Credit Card'
                WHEN 'CAMP005' THEN 'Checking Account'
                WHEN 'CAMP006' THEN 'Mobile App'
                WHEN 'CAMP007' THEN 'Personal Loan'
                WHEN 'CAMP008' THEN 'Mortgage'
            END
        ELSE NULL
    END AS PRODUCT_APPLIED,
    CASE 
        WHEN RESPONSE_TYPE IN ('Application', 'Conversion') THEN UNIFORM(1, 100, RANDOM()) <= 75
        ELSE NULL
    END AS APPLICATION_APPROVED,
    CASE 
        WHEN RESPONSE_TYPE = 'Conversion' THEN UNIFORM(500, 5000, RANDOM())
        ELSE 0
    END AS REVENUE_GENERATED
FROM campaign_responses;

-- =====================================================================
-- LOAD MEMBER INTERACTIONS
-- =====================================================================
INSERT INTO MEMBER_INTERACTIONS (
    INTERACTION_ID, MEMBER_ID, BRANCH_ID, INTERACTION_DATE, INTERACTION_TIMESTAMP,
    INTERACTION_TYPE, INTERACTION_CHANNEL, INTERACTION_TOPIC, RESOLUTION_STATUS,
    SATISFACTION_RATING, FEEDBACK_TEXT, HANDLED_BY
)
WITH interactions AS (
    SELECT 
        M.MEMBER_ID,
        M.PRIMARY_BRANCH_ID,
        DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS INTERACTION_DATE,
        CASE UNIFORM(1, 5, RANDOM())
            WHEN 1 THEN 'Service Request'
            WHEN 2 THEN 'Complaint'
            WHEN 3 THEN 'Inquiry'
            WHEN 4 THEN 'Feedback'
            ELSE 'Loan Application'
        END AS INTERACTION_TYPE,
        CASE UNIFORM(1, 5, RANDOM())
            WHEN 1 THEN 'Phone'
            WHEN 2 THEN 'Email'
            WHEN 3 THEN 'Chat'
            WHEN 4 THEN 'Branch'
            ELSE 'Mobile App'
        END AS INTERACTION_CHANNEL,
        UNIFORM(1, 10, RANDOM()) AS RESOLUTION_RAND,
        ROW_NUMBER() OVER (ORDER BY M.MEMBER_ID) AS ROW_NUM
    FROM MEMBERS M
    WHERE UNIFORM(1, 100, RANDOM()) <= 25
)
SELECT 
    'INT' || LPAD(ROW_NUM, 8, '0') AS INTERACTION_ID,
    MEMBER_ID,
    PRIMARY_BRANCH_ID,
    INTERACTION_DATE,
    DATEADD(hour, UNIFORM(8, 17, RANDOM()), INTERACTION_DATE) AS INTERACTION_TIMESTAMP,
    INTERACTION_TYPE,
    INTERACTION_CHANNEL,
    CASE INTERACTION_TYPE
        WHEN 'Service Request' THEN CASE UNIFORM(1, 3, RANDOM())
            WHEN 1 THEN 'Card Replacement'
            WHEN 2 THEN 'Statement Request'
            ELSE 'Account Update'
        END
        WHEN 'Complaint' THEN CASE UNIFORM(1, 3, RANDOM())
            WHEN 1 THEN 'Long Wait Time'
            WHEN 2 THEN 'Fee Dispute'
            ELSE 'Service Quality'
        END
        WHEN 'Inquiry' THEN CASE UNIFORM(1, 3, RANDOM())
            WHEN 1 THEN 'Loan Rates'
            WHEN 2 THEN 'Account Balance'
            ELSE 'Product Information'
        END
        WHEN 'Feedback' THEN 'General Feedback'
        ELSE 'Loan Application Assistance'
    END AS INTERACTION_TOPIC,
    CASE 
        WHEN INTERACTION_TYPE = 'Complaint' THEN 
            CASE 
                WHEN RESOLUTION_RAND BETWEEN 1 AND 7 THEN 'Resolved'
                WHEN RESOLUTION_RAND BETWEEN 8 AND 9 THEN 'Pending'
                ELSE 'Escalated'
            END
        ELSE 'Resolved'
    END AS RESOLUTION_STATUS,
    CASE 
        WHEN INTERACTION_TYPE = 'Complaint' THEN UNIFORM(2, 4, RANDOM())
        ELSE UNIFORM(3, 5, RANDOM())
    END AS SATISFACTION_RATING,
    CASE INTERACTION_TYPE
        WHEN 'Complaint' THEN 'Issue needs attention. Staff was helpful but process took too long.'
        WHEN 'Feedback' THEN 'Great service! Very satisfied with my experience.'
        ELSE 'Question answered satisfactorily.'
    END AS FEEDBACK_TEXT,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Sarah Mitchell'
        WHEN 2 THEN 'Michael Johnson'
        WHEN 3 THEN 'Jennifer Lee'
        WHEN 4 THEN 'David Chen'
        WHEN 5 THEN 'Amanda Rodriguez'
        WHEN 6 THEN 'Robert Taylor'
        WHEN 7 THEN 'Lisa Anderson'
        WHEN 8 THEN 'James Martinez'
        WHEN 9 THEN 'Emily Wilson'
        ELSE 'Chris Brown'
    END AS HANDLED_BY
FROM interactions;

-- =====================================================================
-- Verification and Summary
-- =====================================================================

SELECT 'Data loading completed successfully!' AS STATUS;

-- Show row counts for all tables
SELECT 'BRANCHES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM BRANCHES
UNION ALL
SELECT 'MEMBERS', COUNT(*) FROM MEMBERS
UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL
SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
UNION ALL
SELECT 'LOAN_PAYMENTS', COUNT(*) FROM LOAN_PAYMENTS
UNION ALL
SELECT 'CREDIT_SCORE_HISTORY', COUNT(*) FROM CREDIT_SCORE_HISTORY
UNION ALL
SELECT 'MARKETING_CAMPAIGNS', COUNT(*) FROM MARKETING_CAMPAIGNS
UNION ALL
SELECT 'MEMBER_CAMPAIGN_RESPONSES', COUNT(*) FROM MEMBER_CAMPAIGN_RESPONSES
UNION ALL
SELECT 'MEMBER_INTERACTIONS', COUNT(*) FROM MEMBER_INTERACTIONS
ORDER BY TABLE_NAME;

