-- =====================================================================
-- Snowflake Intelligence Demo: Credit Union
-- File: 01_create_database_schema.sql
-- Purpose: Create database, schema, and all tables for the credit union demo
-- =====================================================================

-- Create the database and schema
CREATE OR REPLACE DATABASE CREDIT_UNION_DEMO;
CREATE OR REPLACE SCHEMA CREDIT_UNION_DATA;

USE DATABASE CREDIT_UNION_DEMO;
USE SCHEMA CREDIT_UNION_DATA;

-- =====================================================================
-- BRANCHES TABLE
-- Stores information about credit union branch locations
-- =====================================================================
CREATE OR REPLACE TABLE BRANCHES (
    BRANCH_ID VARCHAR(50) PRIMARY KEY,
    BRANCH_NAME VARCHAR(200) NOT NULL,
    BRANCH_CODE VARCHAR(10) NOT NULL,
    ADDRESS VARCHAR(500),
    CITY VARCHAR(100),
    STATE VARCHAR(2),
    ZIP_CODE VARCHAR(10),
    REGION VARCHAR(50),
    BRANCH_TYPE VARCHAR(50), -- Full Service, Limited Service, Online Only
    OPEN_DATE DATE,
    MANAGER_NAME VARCHAR(200),
    PHONE VARCHAR(20),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================================
-- MEMBERS TABLE
-- Core member demographic and relationship information
-- =====================================================================
CREATE OR REPLACE TABLE MEMBERS (
    MEMBER_ID VARCHAR(50) PRIMARY KEY,
    MEMBER_NUMBER VARCHAR(20) UNIQUE NOT NULL,
    FIRST_NAME VARCHAR(100) NOT NULL,
    LAST_NAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(200),
    PHONE VARCHAR(20),
    DATE_OF_BIRTH DATE,
    JOIN_DATE DATE NOT NULL,
    PRIMARY_BRANCH_ID VARCHAR(50),
    MEMBER_STATUS VARCHAR(20), -- Active, Inactive, Suspended, Closed
    MEMBER_SEGMENT VARCHAR(50), -- New, Established, Loyal, Premium
    RISK_RATING VARCHAR(20), -- Low, Medium, High
    ADDRESS VARCHAR(500),
    CITY VARCHAR(100),
    STATE VARCHAR(2),
    ZIP_CODE VARCHAR(10),
    EMPLOYMENT_STATUS VARCHAR(50),
    ANNUAL_INCOME DECIMAL(15,2),
    MARKETING_CHANNEL VARCHAR(100), -- How they joined (Referral, Online, Branch, Social Media, etc.)
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PRIMARY_BRANCH_ID) REFERENCES BRANCHES(BRANCH_ID)
);

-- =====================================================================
-- ACCOUNTS TABLE
-- Deposit accounts including checking, savings, certificates (CDs)
-- =====================================================================
CREATE OR REPLACE TABLE ACCOUNTS (
    ACCOUNT_ID VARCHAR(50) PRIMARY KEY,
    ACCOUNT_NUMBER VARCHAR(30) UNIQUE NOT NULL,
    MEMBER_ID VARCHAR(50) NOT NULL,
    BRANCH_ID VARCHAR(50),
    ACCOUNT_TYPE VARCHAR(50) NOT NULL, -- Checking, Savings, Certificate (CD), Money Market
    ACCOUNT_STATUS VARCHAR(20), -- Active, Dormant, Closed
    OPEN_DATE DATE NOT NULL,
    CLOSE_DATE DATE,
    CURRENT_BALANCE DECIMAL(15,2) DEFAULT 0,
    AVAILABLE_BALANCE DECIMAL(15,2) DEFAULT 0,
    INTEREST_RATE DECIMAL(5,4),
    MINIMUM_BALANCE DECIMAL(15,2),
    -- Certificate-specific fields
    CERTIFICATE_TERM_MONTHS INT, -- For CDs: 6, 12, 18, 24, 36, 60 months
    MATURITY_DATE DATE, -- For CDs: when they mature
    RENEWAL_STATUS VARCHAR(20), -- For CDs: Auto-Renew, Manual-Renew, Pending, Closed
    ORIGINAL_DEPOSIT_AMOUNT DECIMAL(15,2), -- For CDs: initial deposit
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID),
    FOREIGN KEY (BRANCH_ID) REFERENCES BRANCHES(BRANCH_ID)
);

-- =====================================================================
-- LOANS TABLE
-- All loan products including auto, credit cards, mortgages, personal
-- =====================================================================
CREATE OR REPLACE TABLE LOANS (
    LOAN_ID VARCHAR(50) PRIMARY KEY,
    LOAN_NUMBER VARCHAR(30) UNIQUE NOT NULL,
    MEMBER_ID VARCHAR(50) NOT NULL,
    BRANCH_ID VARCHAR(50),
    LOAN_TYPE VARCHAR(50) NOT NULL, -- Auto, Credit Card, Mortgage, Personal, Home Equity
    LOAN_STATUS VARCHAR(20), -- Active, Paid Off, Charged Off, Delinquent, Suspended
    ORIGINATION_DATE DATE NOT NULL,
    CLOSE_DATE DATE,
    ORIGINAL_LOAN_AMOUNT DECIMAL(15,2) NOT NULL,
    CURRENT_BALANCE DECIMAL(15,2) NOT NULL,
    INTEREST_RATE DECIMAL(6,4) NOT NULL,
    TERM_MONTHS INT, -- Loan term in months
    MONTHLY_PAYMENT DECIMAL(10,2),
    PAYMENT_DUE_DAY INT, -- Day of month payment is due
    NEXT_PAYMENT_DATE DATE,
    LAST_PAYMENT_DATE DATE,
    LAST_PAYMENT_AMOUNT DECIMAL(10,2),
    DAYS_DELINQUENT INT DEFAULT 0,
    -- Credit Card specific fields
    CREDIT_LIMIT DECIMAL(15,2), -- For credit cards
    AVAILABLE_CREDIT DECIMAL(15,2), -- For credit cards
    -- Credit quality fields
    ORIGINATION_CREDIT_SCORE INT,
    CURRENT_CREDIT_SCORE INT,
    LOAN_TO_VALUE_RATIO DECIMAL(5,4), -- For secured loans
    COLLATERAL_TYPE VARCHAR(100), -- Auto Make/Model, Property Address, etc.
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID),
    FOREIGN KEY (BRANCH_ID) REFERENCES BRANCHES(BRANCH_ID)
);

-- =====================================================================
-- TRANSACTIONS TABLE
-- All account transactions (deposits, withdrawals, transfers)
-- =====================================================================
CREATE OR REPLACE TABLE TRANSACTIONS (
    TRANSACTION_ID VARCHAR(50) PRIMARY KEY,
    ACCOUNT_ID VARCHAR(50) NOT NULL,
    MEMBER_ID VARCHAR(50) NOT NULL,
    BRANCH_ID VARCHAR(50),
    TRANSACTION_DATE DATE NOT NULL,
    TRANSACTION_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    TRANSACTION_TYPE VARCHAR(50) NOT NULL, -- Deposit, Withdrawal, Transfer, Fee, Interest
    TRANSACTION_CATEGORY VARCHAR(100), -- ATM, ACH, Wire, Check, Debit Card, Direct Deposit, etc.
    AMOUNT DECIMAL(15,2) NOT NULL,
    BALANCE_AFTER DECIMAL(15,2),
    DESCRIPTION VARCHAR(500),
    CHANNEL VARCHAR(50), -- ATM, Online, Mobile, Branch, Phone
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (ACCOUNT_ID) REFERENCES ACCOUNTS(ACCOUNT_ID),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID),
    FOREIGN KEY (BRANCH_ID) REFERENCES BRANCHES(BRANCH_ID)
);

-- =====================================================================
-- LOAN_PAYMENTS TABLE
-- Track all loan payment history
-- =====================================================================
CREATE OR REPLACE TABLE LOAN_PAYMENTS (
    PAYMENT_ID VARCHAR(50) PRIMARY KEY,
    LOAN_ID VARCHAR(50) NOT NULL,
    MEMBER_ID VARCHAR(50) NOT NULL,
    PAYMENT_DATE DATE NOT NULL,
    PAYMENT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    PAYMENT_AMOUNT DECIMAL(10,2) NOT NULL,
    PRINCIPAL_AMOUNT DECIMAL(10,2),
    INTEREST_AMOUNT DECIMAL(10,2),
    FEES_AMOUNT DECIMAL(10,2),
    PAYMENT_METHOD VARCHAR(50), -- ACH, Check, Online, Auto-Pay, Branch
    PAYMENT_STATUS VARCHAR(20), -- Posted, Pending, Returned, Late
    DAYS_LATE INT DEFAULT 0,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (LOAN_ID) REFERENCES LOANS(LOAN_ID),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID)
);

-- =====================================================================
-- CREDIT_SCORE_HISTORY TABLE
-- Track member credit scores over time for trend analysis
-- =====================================================================
CREATE OR REPLACE TABLE CREDIT_SCORE_HISTORY (
    SCORE_ID VARCHAR(50) PRIMARY KEY,
    MEMBER_ID VARCHAR(50) NOT NULL,
    SCORE_DATE DATE NOT NULL,
    CREDIT_SCORE INT NOT NULL,
    SCORE_SOURCE VARCHAR(50), -- Equifax, Experian, TransUnion, Internal
    SCORE_REASON_CODE VARCHAR(10),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID)
);

-- =====================================================================
-- MARKETING_CAMPAIGNS TABLE
-- Track marketing campaigns for member acquisition and product promotion
-- =====================================================================
CREATE OR REPLACE TABLE MARKETING_CAMPAIGNS (
    CAMPAIGN_ID VARCHAR(50) PRIMARY KEY,
    CAMPAIGN_NAME VARCHAR(200) NOT NULL,
    CAMPAIGN_TYPE VARCHAR(100), -- Member Acquisition, Product Promotion, Retention, Cross-sell
    CAMPAIGN_CHANNEL VARCHAR(100), -- Email, Social Media, Direct Mail, Online Ads, Branch, Referral
    START_DATE DATE NOT NULL,
    END_DATE DATE,
    BUDGET DECIMAL(12,2),
    ACTUAL_SPEND DECIMAL(12,2),
    TARGET_AUDIENCE VARCHAR(200),
    CAMPAIGN_GOAL VARCHAR(200),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================================
-- MEMBER_CAMPAIGN_RESPONSES TABLE
-- Track member responses to marketing campaigns
-- =====================================================================
CREATE OR REPLACE TABLE MEMBER_CAMPAIGN_RESPONSES (
    RESPONSE_ID VARCHAR(50) PRIMARY KEY,
    CAMPAIGN_ID VARCHAR(50) NOT NULL,
    MEMBER_ID VARCHAR(50) NOT NULL,
    RESPONSE_DATE DATE NOT NULL,
    RESPONSE_TYPE VARCHAR(50), -- Click, Open, Application, Conversion, Opt-out
    PRODUCT_APPLIED VARCHAR(100), -- Which product they applied for
    APPLICATION_APPROVED BOOLEAN,
    REVENUE_GENERATED DECIMAL(12,2), -- Estimated revenue from conversion
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CAMPAIGN_ID) REFERENCES MARKETING_CAMPAIGNS(CAMPAIGN_ID),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID)
);

-- =====================================================================
-- MEMBER_INTERACTIONS TABLE
-- Track member service interactions and satisfaction
-- =====================================================================
CREATE OR REPLACE TABLE MEMBER_INTERACTIONS (
    INTERACTION_ID VARCHAR(50) PRIMARY KEY,
    MEMBER_ID VARCHAR(50) NOT NULL,
    BRANCH_ID VARCHAR(50),
    INTERACTION_DATE DATE NOT NULL,
    INTERACTION_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    INTERACTION_TYPE VARCHAR(100), -- Service Request, Complaint, Inquiry, Feedback, Loan Application
    INTERACTION_CHANNEL VARCHAR(50), -- Phone, Email, Chat, Branch, Mobile App
    INTERACTION_TOPIC VARCHAR(200),
    RESOLUTION_STATUS VARCHAR(50), -- Resolved, Pending, Escalated
    SATISFACTION_RATING INT, -- 1-5 scale
    FEEDBACK_TEXT VARCHAR(2000),
    HANDLED_BY VARCHAR(200), -- Staff member name
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBERS(MEMBER_ID),
    FOREIGN KEY (BRANCH_ID) REFERENCES BRANCHES(BRANCH_ID)
);

-- =====================================================================
-- Create indexes for better query performance
-- =====================================================================

-- Member indexes
CREATE INDEX idx_members_join_date ON MEMBERS(JOIN_DATE);
CREATE INDEX idx_members_branch ON MEMBERS(PRIMARY_BRANCH_ID);
CREATE INDEX idx_members_segment ON MEMBERS(MEMBER_SEGMENT);
CREATE INDEX idx_members_status ON MEMBERS(MEMBER_STATUS);

-- Account indexes
CREATE INDEX idx_accounts_member ON ACCOUNTS(MEMBER_ID);
CREATE INDEX idx_accounts_type ON ACCOUNTS(ACCOUNT_TYPE);
CREATE INDEX idx_accounts_maturity ON ACCOUNTS(MATURITY_DATE);
CREATE INDEX idx_accounts_branch ON ACCOUNTS(BRANCH_ID);

-- Loan indexes
CREATE INDEX idx_loans_member ON LOANS(MEMBER_ID);
CREATE INDEX idx_loans_type ON LOANS(LOAN_TYPE);
CREATE INDEX idx_loans_status ON LOANS(LOAN_STATUS);
CREATE INDEX idx_loans_origination ON LOANS(ORIGINATION_DATE);
CREATE INDEX idx_loans_branch ON LOANS(BRANCH_ID);

-- Transaction indexes
CREATE INDEX idx_transactions_account ON TRANSACTIONS(ACCOUNT_ID);
CREATE INDEX idx_transactions_member ON TRANSACTIONS(MEMBER_ID);
CREATE INDEX idx_transactions_date ON TRANSACTIONS(TRANSACTION_DATE);

-- Loan payment indexes
CREATE INDEX idx_loan_payments_loan ON LOAN_PAYMENTS(LOAN_ID);
CREATE INDEX idx_loan_payments_date ON LOAN_PAYMENTS(PAYMENT_DATE);

-- Credit score indexes
CREATE INDEX idx_credit_scores_member ON CREDIT_SCORE_HISTORY(MEMBER_ID);
CREATE INDEX idx_credit_scores_date ON CREDIT_SCORE_HISTORY(SCORE_DATE);

-- =====================================================================
-- Verification queries
-- =====================================================================

-- Show all created tables
SHOW TABLES;

-- Verify table structure
SELECT 'Schema creation completed successfully!' AS STATUS;

