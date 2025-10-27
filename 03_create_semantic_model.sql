-- =====================================================================
-- Snowflake Intelligence Demo: Credit Union
-- File: 03_create_semantic_model.sql
-- Purpose: Create Semantic Model using YAML Configuration
-- =====================================================================

USE DATABASE CREDIT_UNION_DEMO;
USE SCHEMA CREDIT_UNION_DATA;

-- Create the semantic model using YAML configuration
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'CREDIT_UNION_DEMO.CREDIT_UNION_DATA',
  $$
  name: CREDIT_UNION_ANALYTICS
  description: Comprehensive semantic model for credit union operations covering member acquisition, certificate renewals, loan portfolio health, branch performance, and marketing effectiveness
  tables:
    - name: BRANCHES
      description: Credit union branch locations and details
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: BRANCHES
      primary_key:
        columns:
          - BRANCH_ID
      dimensions:
        - name: BRANCH_ID
          description: Unique identifier for the branch
          expr: branches.BRANCH_ID
          data_type: VARCHAR
        - name: BRANCH_NAME
          description: Name of the branch (e.g., Encinitas Main Branch)
          expr: branches.BRANCH_NAME
          data_type: VARCHAR
        - name: BRANCH_CODE
          description: Short code for the branch (e.g., ENC)
          expr: branches.BRANCH_CODE
          data_type: VARCHAR
        - name: BRANCH_CITY
          description: City where the branch is located
          expr: branches.CITY
          data_type: VARCHAR
        - name: BRANCH_STATE
          description: State where the branch is located
          expr: branches.STATE
          data_type: VARCHAR
        - name: BRANCH_REGION
          description: Geographic region of the branch
          expr: branches.REGION
          data_type: VARCHAR
        - name: BRANCH_TYPE
          description: Type of branch (Full Service, Limited Service, Online Only)
          expr: branches.BRANCH_TYPE
          data_type: VARCHAR
        - name: BRANCH_MANAGER
          description: Name of the branch manager
          expr: branches.MANAGER_NAME
          data_type: VARCHAR
        - name: BRANCH_OPEN_DATE
          description: Date when the branch opened
          expr: branches.OPEN_DATE
          data_type: DATE

    - name: MEMBERS
      description: Credit union members with demographics and relationship information
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: MEMBERS
      primary_key:
        columns:
          - MEMBER_ID
      dimensions:
        - name: MEMBER_ID
          description: Unique identifier for the member
          expr: members.MEMBER_ID
          data_type: VARCHAR
        - name: MEMBER_NUMBER
          description: Member account number
          expr: members.MEMBER_NUMBER
          data_type: VARCHAR
        - name: MEMBER_FIRST_NAME
          description: Member's first name
          expr: members.FIRST_NAME
          data_type: VARCHAR
        - name: MEMBER_LAST_NAME
          description: Member's last name
          expr: members.LAST_NAME
          data_type: VARCHAR
        - name: MEMBER_EMAIL
          description: Member's email address
          expr: members.EMAIL
          data_type: VARCHAR
        - name: MEMBER_JOIN_DATE
          description: Date when member joined the credit union
          expr: members.JOIN_DATE
          data_type: DATE
        - name: MEMBER_STATUS
          description: Current member status (Active, Inactive, Dormant, Closed)
          expr: members.MEMBER_STATUS
          data_type: VARCHAR
        - name: MEMBER_SEGMENT
          description: Member segment (New, Established, Loyal, Premium)
          expr: members.MEMBER_SEGMENT
          data_type: VARCHAR
        - name: MEMBER_RISK_RATING
          description: Risk rating of the member (Low, Medium, High)
          expr: members.RISK_RATING
          data_type: VARCHAR
        - name: MEMBER_CITY
          description: City where member resides
          expr: members.CITY
          data_type: VARCHAR
        - name: MEMBER_STATE
          description: State where member resides
          expr: members.STATE
          data_type: VARCHAR
        - name: MEMBER_ZIP_CODE
          description: Member's ZIP code
          expr: members.ZIP_CODE
          data_type: VARCHAR
        - name: EMPLOYMENT_STATUS
          description: Member's employment status (Employed Full-time, Self-employed, Retired, Part-time)
          expr: members.EMPLOYMENT_STATUS
          data_type: VARCHAR
        - name: MARKETING_CHANNEL
          description: Channel through which member was acquired (Referral, Online, Branch Walk-in, Social Media, Email Campaign, Direct Mail)
          expr: members.MARKETING_CHANNEL
          data_type: VARCHAR
      facts:
        - name: ANNUAL_INCOME
          description: Member's annual income in dollars
          expr: members.ANNUAL_INCOME
          data_type: NUMBER

    - name: ACCOUNTS
      description: Deposit accounts including checking, savings, and certificates
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: ACCOUNTS
      primary_key:
        columns:
          - ACCOUNT_ID
      dimensions:
        - name: ACCOUNT_ID
          description: Unique identifier for the account
          expr: accounts.ACCOUNT_ID
          data_type: VARCHAR
        - name: ACCOUNT_NUMBER
          description: Account number
          expr: accounts.ACCOUNT_NUMBER
          data_type: VARCHAR
        - name: ACCOUNT_TYPE
          description: Type of account (Checking, Savings, Certificate, Money Market)
          expr: accounts.ACCOUNT_TYPE
          data_type: VARCHAR
        - name: ACCOUNT_STATUS
          description: Status of the account (Active, Dormant, Closed)
          expr: accounts.ACCOUNT_STATUS
          data_type: VARCHAR
        - name: ACCOUNT_OPEN_DATE
          description: Date when account was opened
          expr: accounts.OPEN_DATE
          data_type: DATE
        - name: ACCOUNT_CLOSE_DATE
          description: Date when account was closed
          expr: accounts.CLOSE_DATE
          data_type: DATE
        - name: CERTIFICATE_MATURITY_DATE
          description: Maturity date for certificate accounts
          expr: accounts.MATURITY_DATE
          data_type: DATE
        - name: CERTIFICATE_RENEWAL_STATUS
          description: Renewal status for certificates (Auto-Renew, Manual-Renew, Pending, Closed)
          expr: accounts.RENEWAL_STATUS
          data_type: VARCHAR
      facts:
        - name: CURRENT_BALANCE
          description: Current account balance in dollars
          expr: accounts.CURRENT_BALANCE
          data_type: NUMBER
        - name: AVAILABLE_BALANCE
          description: Available balance in dollars
          expr: accounts.AVAILABLE_BALANCE
          data_type: NUMBER
        - name: INTEREST_RATE
          description: Interest rate on the account
          expr: accounts.INTEREST_RATE
          data_type: NUMBER
        - name: CERTIFICATE_TERM_MONTHS
          description: Term length in months for certificate accounts
          expr: accounts.CERTIFICATE_TERM_MONTHS
          data_type: NUMBER
        - name: ORIGINAL_DEPOSIT_AMOUNT
          description: Original deposit amount for certificates
          expr: accounts.ORIGINAL_DEPOSIT_AMOUNT
          data_type: NUMBER

    - name: LOANS
      description: All loan products including auto, credit cards, mortgages, and personal loans
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: LOANS
      primary_key:
        columns:
          - LOAN_ID
      dimensions:
        - name: LOAN_ID
          description: Unique identifier for the loan
          expr: loans.LOAN_ID
          data_type: VARCHAR
        - name: LOAN_NUMBER
          description: Loan account number
          expr: loans.LOAN_NUMBER
          data_type: VARCHAR
        - name: LOAN_TYPE
          description: Type of loan (Auto, Credit Card, Mortgage, Personal, Home Equity)
          expr: loans.LOAN_TYPE
          data_type: VARCHAR
        - name: LOAN_STATUS
          description: Current loan status (Active, Paid Off, Charged Off, Delinquent, Suspended, Inactive)
          expr: loans.LOAN_STATUS
          data_type: VARCHAR
        - name: ORIGINATION_DATE
          description: Date when loan was originated
          expr: loans.ORIGINATION_DATE
          data_type: DATE
        - name: CLOSE_DATE
          description: Date when loan was closed or paid off
          expr: loans.CLOSE_DATE
          data_type: DATE
        - name: COLLATERAL_TYPE
          description: Type of collateral for secured loans
          expr: loans.COLLATERAL_TYPE
          data_type: VARCHAR
      facts:
        - name: ORIGINAL_LOAN_AMOUNT
          description: Original loan amount in dollars (NULL for credit cards)
          expr: loans.ORIGINAL_LOAN_AMOUNT
          data_type: NUMBER
        - name: CURRENT_BALANCE
          description: Current outstanding balance in dollars
          expr: loans.CURRENT_BALANCE
          data_type: NUMBER
        - name: INTEREST_RATE
          description: Annual interest rate on the loan
          expr: loans.INTEREST_RATE
          data_type: NUMBER
        - name: TERM_MONTHS
          description: Loan term in months
          expr: loans.TERM_MONTHS
          data_type: NUMBER
        - name: MONTHLY_PAYMENT
          description: Monthly payment amount in dollars
          expr: loans.MONTHLY_PAYMENT
          data_type: NUMBER
        - name: DAYS_DELINQUENT
          description: Number of days the loan is delinquent
          expr: loans.DAYS_DELINQUENT
          data_type: NUMBER
        - name: CREDIT_LIMIT
          description: Credit limit for credit card loans
          expr: loans.CREDIT_LIMIT
          data_type: NUMBER
        - name: AVAILABLE_CREDIT
          description: Available credit for credit card loans
          expr: loans.AVAILABLE_CREDIT
          data_type: NUMBER
        - name: ORIGINATION_CREDIT_SCORE
          description: Credit score at loan origination
          expr: loans.ORIGINATION_CREDIT_SCORE
          data_type: NUMBER
        - name: CURRENT_CREDIT_SCORE
          description: Current credit score
          expr: loans.CURRENT_CREDIT_SCORE
          data_type: NUMBER
        - name: LOAN_TO_VALUE_RATIO
          description: Loan-to-value ratio for secured loans
          expr: loans.LOAN_TO_VALUE_RATIO
          data_type: NUMBER

    - name: MARKETING_CAMPAIGNS
      description: Marketing campaigns for member acquisition and product promotion
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: MARKETING_CAMPAIGNS
      primary_key:
        columns:
          - CAMPAIGN_ID
      dimensions:
        - name: CAMPAIGN_ID
          description: Unique identifier for the marketing campaign
          expr: marketing_campaigns.CAMPAIGN_ID
          data_type: VARCHAR
        - name: CAMPAIGN_NAME
          description: Name of the marketing campaign
          expr: marketing_campaigns.CAMPAIGN_NAME
          data_type: VARCHAR
        - name: CAMPAIGN_TYPE
          description: Type of campaign (Member Acquisition, Product Promotion, Retention, Cross-sell)
          expr: marketing_campaigns.CAMPAIGN_TYPE
          data_type: VARCHAR
        - name: CAMPAIGN_CHANNEL
          description: Marketing channel (Email, Social Media, Direct Mail, Online Ads, Branch, Referral)
          expr: marketing_campaigns.CAMPAIGN_CHANNEL
          data_type: VARCHAR
        - name: CAMPAIGN_START_DATE
          description: Campaign start date
          expr: marketing_campaigns.START_DATE
          data_type: DATE
        - name: CAMPAIGN_END_DATE
          description: Campaign end date
          expr: marketing_campaigns.END_DATE
          data_type: DATE
        - name: TARGET_AUDIENCE
          description: Target audience for the campaign
          expr: marketing_campaigns.TARGET_AUDIENCE
          data_type: VARCHAR
        - name: CAMPAIGN_GOAL
          description: Goal or objective of the campaign
          expr: marketing_campaigns.CAMPAIGN_GOAL
          data_type: VARCHAR
      facts:
        - name: CAMPAIGN_BUDGET
          description: Campaign budget in dollars
          expr: marketing_campaigns.BUDGET
          data_type: NUMBER
        - name: CAMPAIGN_ACTUAL_SPEND
          description: Actual campaign spend in dollars
          expr: marketing_campaigns.ACTUAL_SPEND
          data_type: NUMBER

    - name: MEMBER_CAMPAIGN_RESPONSES
      description: Member responses to marketing campaigns
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: MEMBER_CAMPAIGN_RESPONSES
      primary_key:
        columns:
          - RESPONSE_ID
      dimensions:
        - name: RESPONSE_ID
          description: Unique identifier for the response
          expr: member_campaign_responses.RESPONSE_ID
          data_type: VARCHAR
        - name: RESPONSE_DATE
          description: Date of the response
          expr: member_campaign_responses.RESPONSE_DATE
          data_type: DATE
        - name: RESPONSE_TYPE
          description: Type of response (Click, Open, Application, Conversion, Opt-out)
          expr: member_campaign_responses.RESPONSE_TYPE
          data_type: VARCHAR
        - name: PRODUCT_APPLIED
          description: Product the member applied for
          expr: member_campaign_responses.PRODUCT_APPLIED
          data_type: VARCHAR
        - name: APPLICATION_APPROVED
          description: Whether the application was approved
          expr: member_campaign_responses.APPLICATION_APPROVED
          data_type: BOOLEAN
      facts:
        - name: REVENUE_GENERATED
          description: Revenue generated from the response in dollars
          expr: member_campaign_responses.REVENUE_GENERATED
          data_type: NUMBER

    - name: MEMBER_INTERACTIONS
      description: Member service interactions and satisfaction tracking
      base_table:
        database: CREDIT_UNION_DEMO
        schema: CREDIT_UNION_DATA
        table: MEMBER_INTERACTIONS
      primary_key:
        columns:
          - INTERACTION_ID
      dimensions:
        - name: INTERACTION_ID
          description: Unique identifier for the interaction
          expr: member_interactions.INTERACTION_ID
          data_type: VARCHAR
        - name: INTERACTION_DATE
          description: Date of the interaction
          expr: member_interactions.INTERACTION_DATE
          data_type: DATE
        - name: INTERACTION_TYPE
          description: Type of interaction (Service Request, Complaint, Inquiry, Feedback, Loan Application)
          expr: member_interactions.INTERACTION_TYPE
          data_type: VARCHAR
        - name: INTERACTION_CHANNEL
          description: Channel of interaction (Phone, Email, Chat, Branch, Mobile App)
          expr: member_interactions.INTERACTION_CHANNEL
          data_type: VARCHAR
        - name: INTERACTION_TOPIC
          description: Topic or subject of the interaction
          expr: member_interactions.INTERACTION_TOPIC
          data_type: VARCHAR
        - name: RESOLUTION_STATUS
          description: Resolution status (Resolved, Pending, Escalated)
          expr: member_interactions.RESOLUTION_STATUS
          data_type: VARCHAR
        - name: FEEDBACK_TEXT
          description: Text feedback from the member
          expr: member_interactions.FEEDBACK_TEXT
          data_type: VARCHAR
        - name: HANDLED_BY
          description: Staff member who handled the interaction
          expr: member_interactions.HANDLED_BY
          data_type: VARCHAR
      facts:
        - name: SATISFACTION_RATING
          description: Member satisfaction rating (1-5 scale)
          expr: member_interactions.SATISFACTION_RATING
          data_type: NUMBER

  relationships:
    - name: MEMBERS_BRANCHES
      left_table: MEMBERS
      right_table: BRANCHES
      relationship_columns:
        - left_column: PRIMARY_BRANCH_ID
          right_column: BRANCH_ID
      relationship_type: many_to_one

    - name: ACCOUNTS_MEMBERS
      left_table: ACCOUNTS
      right_table: MEMBERS
      relationship_columns:
        - left_column: MEMBER_ID
          right_column: MEMBER_ID
      relationship_type: many_to_one

    - name: ACCOUNTS_BRANCHES
      left_table: ACCOUNTS
      right_table: BRANCHES
      relationship_columns:
        - left_column: BRANCH_ID
          right_column: BRANCH_ID
      relationship_type: many_to_one

    - name: LOANS_MEMBERS
      left_table: LOANS
      right_table: MEMBERS
      relationship_columns:
        - left_column: MEMBER_ID
          right_column: MEMBER_ID
      relationship_type: many_to_one

    - name: LOANS_BRANCHES
      left_table: LOANS
      right_table: BRANCHES
      relationship_columns:
        - left_column: BRANCH_ID
          right_column: BRANCH_ID
      relationship_type: many_to_one

    - name: MEMBER_CAMPAIGN_RESPONSES_CAMPAIGNS
      left_table: MEMBER_CAMPAIGN_RESPONSES
      right_table: MARKETING_CAMPAIGNS
      relationship_columns:
        - left_column: CAMPAIGN_ID
          right_column: CAMPAIGN_ID
      relationship_type: many_to_one

    - name: MEMBER_CAMPAIGN_RESPONSES_MEMBERS
      left_table: MEMBER_CAMPAIGN_RESPONSES
      right_table: MEMBERS
      relationship_columns:
        - left_column: MEMBER_ID
          right_column: MEMBER_ID
      relationship_type: many_to_one

    - name: MEMBER_INTERACTIONS_MEMBERS
      left_table: MEMBER_INTERACTIONS
      right_table: MEMBERS
      relationship_columns:
        - left_column: MEMBER_ID
          right_column: MEMBER_ID
      relationship_type: many_to_one

    - name: MEMBER_INTERACTIONS_BRANCHES
      left_table: MEMBER_INTERACTIONS
      right_table: BRANCHES
      relationship_columns:
        - left_column: BRANCH_ID
          right_column: BRANCH_ID
      relationship_type: many_to_one

  metrics:
    # Member Acquisition Metrics
    - name: TOTAL_MEMBERS
      description: Total number of members
      expr: COUNT(DISTINCT members.MEMBER_ID)
      
    - name: NEW_MEMBERS_LAST_30_DAYS
      description: Number of members who joined in the last 30 days
      expr: COUNT(DISTINCT CASE WHEN DATEDIFF(day, members.JOIN_DATE, CURRENT_DATE()) <= 30 THEN members.MEMBER_ID END)
      
    - name: NEW_MEMBERS_LAST_90_DAYS
      description: Number of members who joined in the last 90 days
      expr: COUNT(DISTINCT CASE WHEN DATEDIFF(day, members.JOIN_DATE, CURRENT_DATE()) <= 90 THEN members.MEMBER_ID END)
      
    - name: NEW_MEMBERS_LAST_12_MONTHS
      description: Number of members who joined in the last 12 months
      expr: COUNT(DISTINCT CASE WHEN DATEDIFF(month, members.JOIN_DATE, CURRENT_DATE()) <= 12 THEN members.MEMBER_ID END)
      
    - name: ACTIVE_MEMBERS
      description: Number of active members
      expr: COUNT(DISTINCT CASE WHEN members.MEMBER_STATUS = 'Active' THEN members.MEMBER_ID END)
      
    # Certificate Renewal Metrics
    - name: TOTAL_CERTIFICATES
      description: Total number of certificate accounts
      expr: COUNT(DISTINCT CASE WHEN accounts.ACCOUNT_TYPE = 'Certificate' THEN accounts.ACCOUNT_ID END)
      
    - name: CERTIFICATES_MATURING_30_DAYS
      description: Number of certificates maturing in the next 30 days
      expr: COUNT(DISTINCT CASE WHEN accounts.ACCOUNT_TYPE = 'Certificate' AND DATEDIFF(day, CURRENT_DATE(), accounts.MATURITY_DATE) BETWEEN 0 AND 30 THEN accounts.ACCOUNT_ID END)
      
    - name: CERTIFICATES_MATURING_90_DAYS
      description: Number of certificates maturing in the next 90 days
      expr: COUNT(DISTINCT CASE WHEN accounts.ACCOUNT_TYPE = 'Certificate' AND DATEDIFF(day, CURRENT_DATE(), accounts.MATURITY_DATE) BETWEEN 0 AND 90 THEN accounts.ACCOUNT_ID END)
      
    - name: CERTIFICATES_MATURING_180_DAYS
      description: Number of certificates maturing in the next 180 days
      expr: COUNT(DISTINCT CASE WHEN accounts.ACCOUNT_TYPE = 'Certificate' AND DATEDIFF(day, CURRENT_DATE(), accounts.MATURITY_DATE) BETWEEN 0 AND 180 THEN accounts.ACCOUNT_ID END)
      
    - name: CERTIFICATE_VALUE_MATURING_90_DAYS
      description: Total value of certificates maturing in next 90 days
      expr: SUM(CASE WHEN accounts.ACCOUNT_TYPE = 'Certificate' AND DATEDIFF(day, CURRENT_DATE(), accounts.MATURITY_DATE) BETWEEN 0 AND 90 THEN accounts.CURRENT_BALANCE ELSE 0 END)
      
    # Deposit Metrics
    - name: TOTAL_DEPOSITS
      description: Total deposit balances across all accounts
      expr: SUM(accounts.CURRENT_BALANCE)
      
    - name: TOTAL_CHECKING_BALANCE
      description: Total balance in checking accounts
      expr: SUM(CASE WHEN accounts.ACCOUNT_TYPE = 'Checking' THEN accounts.CURRENT_BALANCE ELSE 0 END)
      
    - name: TOTAL_SAVINGS_BALANCE
      description: Total balance in savings accounts
      expr: SUM(CASE WHEN accounts.ACCOUNT_TYPE = 'Savings' THEN accounts.CURRENT_BALANCE ELSE 0 END)
      
    - name: TOTAL_CERTIFICATE_BALANCE
      description: Total balance in certificate accounts
      expr: SUM(CASE WHEN accounts.ACCOUNT_TYPE = 'Certificate' THEN accounts.CURRENT_BALANCE ELSE 0 END)
      
    # Loan Portfolio Metrics
    - name: TOTAL_LOANS
      description: Total number of loans
      expr: COUNT(DISTINCT loans.LOAN_ID)
      
    - name: ACTIVE_LOANS
      description: Number of active loans
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_STATUS = 'Active' THEN loans.LOAN_ID END)
      
    - name: TOTAL_LOAN_BALANCE
      description: Total outstanding loan balance
      expr: SUM(CASE WHEN loans.LOAN_STATUS = 'Active' THEN loans.CURRENT_BALANCE ELSE 0 END)
      
    - name: AUTO_LOAN_BALANCE
      description: Total auto loan portfolio balance
      expr: SUM(CASE WHEN loans.LOAN_TYPE = 'Auto' AND loans.LOAN_STATUS = 'Active' THEN loans.CURRENT_BALANCE ELSE 0 END)
      
    - name: AUTO_LOAN_COUNT
      description: Number of active auto loans
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_TYPE = 'Auto' AND loans.LOAN_STATUS = 'Active' THEN loans.LOAN_ID END)
      
    - name: CREDIT_CARD_BALANCE
      description: Total credit card portfolio balance
      expr: SUM(CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.LOAN_STATUS = 'Active' THEN loans.CURRENT_BALANCE ELSE 0 END)
      
    - name: CREDIT_CARD_COUNT
      description: Number of active credit cards
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.LOAN_STATUS = 'Active' THEN loans.LOAN_ID END)
      
    - name: MORTGAGE_BALANCE
      description: Total mortgage portfolio balance
      expr: SUM(CASE WHEN loans.LOAN_TYPE = 'Mortgage' AND loans.LOAN_STATUS = 'Active' THEN loans.CURRENT_BALANCE ELSE 0 END)
      
    - name: PERSONAL_LOAN_BALANCE
      description: Total personal loan portfolio balance
      expr: SUM(CASE WHEN loans.LOAN_TYPE = 'Personal' AND loans.LOAN_STATUS = 'Active' THEN loans.CURRENT_BALANCE ELSE 0 END)
      
    # Credit Card Health Metrics
    - name: AVG_CREDIT_UTILIZATION
      description: Average credit card utilization percentage
      expr: AVG(CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.CREDIT_LIMIT > 0 THEN (loans.CURRENT_BALANCE / loans.CREDIT_LIMIT) * 100 END)
      
    - name: HIGH_UTILIZATION_CARDS
      description: Number of credit cards with utilization above 70%
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.CREDIT_LIMIT > 0 AND (loans.CURRENT_BALANCE / loans.CREDIT_LIMIT) >= 0.70 THEN loans.LOAN_ID END)
      
    - name: AVG_CREDIT_SCORE_CHANGE
      description: Average change in credit score from origination to current
      expr: AVG(CASE WHEN loans.LOAN_TYPE = 'Credit Card' THEN loans.CURRENT_CREDIT_SCORE - loans.ORIGINATION_CREDIT_SCORE END)
      
    - name: IMPROVING_CREDIT_SCORES
      description: Number of credit cards with improving credit scores
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.CURRENT_CREDIT_SCORE > loans.ORIGINATION_CREDIT_SCORE THEN loans.LOAN_ID END)
      
    - name: DECLINING_CREDIT_SCORES
      description: Number of credit cards with declining credit scores
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.CURRENT_CREDIT_SCORE < loans.ORIGINATION_CREDIT_SCORE THEN loans.LOAN_ID END)
      
    - name: CHARGED_OFF_LOANS
      description: Number of charged off loans
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_STATUS = 'Charged Off' THEN loans.LOAN_ID END)
      
    - name: CHARGED_OFF_CREDIT_CARDS
      description: Number of charged off credit cards
      expr: COUNT(DISTINCT CASE WHEN loans.LOAN_TYPE = 'Credit Card' AND loans.LOAN_STATUS = 'Charged Off' THEN loans.LOAN_ID END)
      
    # Delinquency Metrics
    - name: DELINQUENT_LOANS_30_PLUS
      description: Number of loans 30+ days delinquent
      expr: COUNT(DISTINCT CASE WHEN loans.DAYS_DELINQUENT >= 30 THEN loans.LOAN_ID END)
      
    - name: DELINQUENT_LOANS_60_PLUS
      description: Number of loans 60+ days delinquent
      expr: COUNT(DISTINCT CASE WHEN loans.DAYS_DELINQUENT >= 60 THEN loans.LOAN_ID END)
      
    - name: DELINQUENT_LOANS_90_PLUS
      description: Number of loans 90+ days delinquent
      expr: COUNT(DISTINCT CASE WHEN loans.DAYS_DELINQUENT >= 90 THEN loans.LOAN_ID END)
      
    # Marketing Metrics
    - name: TOTAL_MARKETING_SPEND
      description: Total marketing campaign spend
      expr: SUM(marketing_campaigns.ACTUAL_SPEND)
      
    - name: CAMPAIGN_REVENUE
      description: Total revenue generated from campaigns
      expr: SUM(member_campaign_responses.REVENUE_GENERATED)
      
    - name: CAMPAIGN_CONVERSIONS
      description: Number of campaign conversions
      expr: COUNT(CASE WHEN member_campaign_responses.RESPONSE_TYPE = 'Conversion' THEN 1 END)
      
    - name: CAMPAIGN_APPLICATIONS
      description: Number of campaign applications
      expr: COUNT(CASE WHEN member_campaign_responses.RESPONSE_TYPE IN ('Application', 'Conversion') THEN 1 END)
      
    - name: TOTAL_CAMPAIGN_RESPONSES
      description: Total number of campaign responses
      expr: COUNT(member_campaign_responses.RESPONSE_ID)
      
    # Member Satisfaction Metrics
    - name: AVG_SATISFACTION_RATING
      description: Average member satisfaction rating
      expr: AVG(member_interactions.SATISFACTION_RATING)
      
    - name: TOTAL_INTERACTIONS
      description: Total number of member interactions
      expr: COUNT(member_interactions.INTERACTION_ID)
      
    - name: COMPLAINTS
      description: Number of complaints
      expr: COUNT(CASE WHEN member_interactions.INTERACTION_TYPE = 'Complaint' THEN 1 END)
      
    - name: RESOLVED_INTERACTIONS
      description: Number of resolved interactions
      expr: COUNT(CASE WHEN member_interactions.RESOLUTION_STATUS = 'Resolved' THEN 1 END)
      
    - name: RESOLVED_RATE_NUMERATOR
      description: Count of resolved interactions (for calculating resolution rate)
      expr: COUNT(CASE WHEN member_interactions.RESOLUTION_STATUS = 'Resolved' THEN 1 END)
      
    # Branch Performance Metrics - using simple sums and counts
    - name: TOTAL_ACCOUNT_COUNT
      description: Total number of accounts
      expr: COUNT(DISTINCT accounts.ACCOUNT_ID)
      
    - name: TOTAL_LOAN_COUNT
      description: Total number of loans
      expr: COUNT(DISTINCT loans.LOAN_ID)
  $$
);

-- Verify the semantic model was created successfully
SHOW SEMANTIC MODELS;

-- Grant usage permissions (adjust as needed for your environment)
-- GRANT USAGE ON SEMANTIC MODEL CREDIT_UNION_ANALYTICS TO ROLE PUBLIC;

SELECT 'Semantic model creation completed successfully!' AS STATUS;
