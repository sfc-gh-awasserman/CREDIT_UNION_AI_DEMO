# Quick Start Guide
## Credit Union Snowflake Intelligence Demo

Get your demo up and running in **10 minutes**.

---

## Prerequisites

✅ Snowflake account (Enterprise Edition or higher)  
✅ Snowflake Intelligence / Cortex features enabled  
✅ ACCOUNTADMIN or equivalent privileges  
✅ Snowsight web interface access

---

## Step 1: Create Database Schema (2 minutes)

### Open Snowsight

1. Log into your Snowflake account
2. Navigate to **Worksheets**
3. Create a new SQL worksheet

### Execute Schema Script

1. Open file: `01_create_database_schema.sql`
2. Copy entire contents
3. Paste into Snowsight worksheet
4. Click **Run All** (or press `Ctrl+Enter` / `Cmd+Return`)

### Verify

You should see:
```
Schema creation completed successfully!
```

And a list of 11 tables created:
- BRANCHES
- MEMBERS
- ACCOUNTS
- LOANS
- TRANSACTIONS
- LOAN_PAYMENTS
- CREDIT_SCORE_HISTORY
- MARKETING_CAMPAIGNS
- MEMBER_CAMPAIGN_RESPONSES
- MEMBER_INTERACTIONS

---

## Step 2: Load Synthetic Data (5 minutes)

### Execute Data Load Script

1. Open file: `02_load_synthetic_data.sql`
2. Copy entire contents
3. Paste into a new Snowsight worksheet (or replace previous)
4. Click **Run All**

**Note**: This will take 3-5 minutes as it generates:
- 5,000 members
- ~8,000 accounts (checking, savings, certificates)
- ~5,000 loans (auto, credit card, mortgage, personal)
- Credit score history tracking
- Marketing campaigns and responses
- Member interactions

### Verify

You should see:
```
Data loading completed successfully!
```

And row counts for each table:
```
TABLE_NAME                    | ROW_COUNT
------------------------------|----------
BRANCHES                      |         8
MEMBERS                       |     5,000
ACCOUNTS                      |    ~8,000
LOANS                         |    ~5,000
CREDIT_SCORE_HISTORY          |   ~50,000
MARKETING_CAMPAIGNS           |         8
MEMBER_CAMPAIGN_RESPONSES     |    ~2,000
MEMBER_INTERACTIONS           |    ~1,250
```

**Quick Check:**
```sql
SELECT COUNT(*) FROM CREDIT_UNION_DEMO.CREDIT_UNION_DATA.MEMBERS;
-- Should return ~5,000
```

---

## Step 3: Create Semantic Views (1 minute)

### Execute Semantic Model Script

1. Open file: `03_create_semantic_model.sql`
2. Copy entire contents
3. Paste into Snowsight worksheet
4. Click **Run All**

### Verify

You should see:
```
Semantic model creation completed successfully!
```

And 6 views created with row counts:
```
VIEW_NAME                     | ROW_COUNT
------------------------------|----------
BRANCH_PERFORMANCE_VIEW       |         8
CERTIFICATE_RENEWAL_VIEW      |    ~1,500
CREDIT_CARD_HEALTH_VIEW       |    ~2,250
LOAN_PORTFOLIO_VIEW           |    ~5,000
MEMBER_ACQUISITION_VIEW       |     5,000
TIME_SERIES_METRICS_VIEW      |        24
```

**Quick Check:**
```sql
SELECT * FROM CREDIT_UNION_DEMO.CREDIT_UNION_DATA.BRANCH_PERFORMANCE_VIEW;
-- Should show 8 branches with performance metrics
```

---

## Step 4: Configure Snowflake Intelligence Agent (2 minutes)

### Navigate to Snowflake Intelligence

1. In Snowsight, go to **AI & ML** → **Snowflake Intelligence** (or **Cortex**)
2. Click **Create Agent** or select existing agent

### Configure Agent Settings

**Basic Settings:**
- **Agent Name**: `Credit Union Analytics Agent`
- **Database**: `CREDIT_UNION_DEMO`
- **Schema**: `CREDIT_UNION_DATA`

**Semantic Views:**
Select all 6 views:
- ✅ MEMBER_ACQUISITION_VIEW
- ✅ CERTIFICATE_RENEWAL_VIEW
- ✅ LOAN_PORTFOLIO_VIEW
- ✅ CREDIT_CARD_HEALTH_VIEW
- ✅ BRANCH_PERFORMANCE_VIEW
- ✅ TIME_SERIES_METRICS_VIEW

**Instructions:**
1. Open file: `agent_instructions.md`
2. Copy entire contents
3. Paste into **Agent Instructions** field
4. Save agent configuration

---

## Step 5: Test Your Setup (1 minute)

### Try These Questions

In the Snowflake Intelligence chat interface, ask:

**Test 1 - Member Acquisition:**
```
How many new members have we acquired in the last 90 days?
```
**Expected**: Answer with count (~387 members)

**Test 2 - Certificate Renewals:**
```
How many certificates are renewing in the next 90 days at the Encinitas branch?
```
**Expected**: Count of certificates with branch breakdown

**Test 3 - Auto Loan Trending:**
```
How are balances in our auto loans portfolio trending over the last 12 months?
```
**Expected**: Trend data showing month-over-month changes

**Test 4 - Credit Card Health:**
```
What does the health of credit card loans originated in the last 12 months look like?
```
**Expected**: Summary with utilization, credit score migration, charge-offs

### Follow-Up Questions

Try natural follow-ups:
- _"Which branch had the most?"_
- _"Compare that to last year"_
- _"Show me a chart"_
- _"Break that down by member segment"_

---

## Common Setup Issues

### ❌ "Database does not exist"
**Solution**: Ensure you completed Step 1 and the database was created. Check:
```sql
SHOW DATABASES LIKE 'CREDIT_UNION_DEMO';
```

### ❌ "View does not exist"
**Solution**: Complete Step 3 to create semantic views. Verify:
```sql
SHOW VIEWS IN CREDIT_UNION_DEMO.CREDIT_UNION_DATA;
```

### ❌ "No data returned"
**Solution**: Ensure Step 2 completed successfully. Check row counts:
```sql
SELECT 'MEMBERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT 
FROM CREDIT_UNION_DEMO.CREDIT_UNION_DATA.MEMBERS;
```

### ❌ "Agent not responding correctly"
**Solution**: 
1. Verify all 6 semantic views are selected in agent configuration
2. Ensure agent instructions were pasted completely
3. Try refreshing the agent or creating a new one

### ❌ "Permission denied"
**Solution**: Ensure you have sufficient privileges:
```sql
-- Grant necessary permissions
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON DATABASE CREDIT_UNION_DEMO TO ROLE [YOUR_ROLE];
GRANT USAGE ON SCHEMA CREDIT_UNION_DATA TO ROLE [YOUR_ROLE];
GRANT SELECT ON ALL VIEWS IN SCHEMA CREDIT_UNION_DATA TO ROLE [YOUR_ROLE];
```

---

## Next Steps

### 📚 Explore Documentation

- **`README.md`**: Comprehensive overview, use cases, and demo tips
- **`sample_questions.md`**: 100 curated questions organized by role
- **`semantic_view_description.md`**: Detailed technical view documentation
- **`agent_instructions.md`**: Complete agent configuration guide

### 🎯 Prepare Your Demo

1. Review sample questions in `sample_questions.md`
2. Practice key scenarios:
   - Member acquisition by channel
   - Certificate renewal pipeline
   - Auto loan portfolio trending
   - Credit card health analysis
3. Prepare follow-up questions
4. Identify wow moments for your audience
5. Customize data/questions for your specific use case

### 🔧 Customize the Demo

**Change Member Count:**
```sql
-- In 02_load_synthetic_data.sql, line ~35
FROM TABLE(GENERATOR(ROWCOUNT => 5000))  -- Change to desired count
```

**Adjust Date Ranges:**
```sql
-- In 02_load_synthetic_data.sql
DATEADD(day, -UNIFORM(90, 10950, RANDOM()), CURRENT_DATE())
-- Adjust the 90 and 10950 values
```

**Add Custom Branch:**
```sql
-- In 02_load_synthetic_data.sql, add to BRANCHES insert
('BR009', 'Your Branch Name', 'YBR', ...)
```

---

## Verification Checklist

Before demoing, verify:

- [ ] Database `CREDIT_UNION_DEMO` exists
- [ ] Schema `CREDIT_UNION_DATA` exists
- [ ] 11 tables created and populated
- [ ] 6 semantic views created
- [ ] ~5,000 members in MEMBERS table
- [ ] Snowflake Intelligence agent configured
- [ ] Agent instructions loaded
- [ ] All 6 views selected in agent
- [ ] Test questions return expected results
- [ ] Can drill down with follow-up questions

### Quick Verification Script

Run this to verify everything:

```sql
-- Check database and schema
USE DATABASE CREDIT_UNION_DEMO;
USE SCHEMA CREDIT_UNION_DATA;

-- Check table counts
SELECT 'MEMBERS' AS OBJECT, COUNT(*) AS COUNT FROM MEMBERS
UNION ALL SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL SELECT 'BRANCHES', COUNT(*) FROM BRANCHES;

-- Check view counts
SELECT 'MEMBER_ACQUISITION_VIEW' AS VIEW_NAME, COUNT(*) FROM MEMBER_ACQUISITION_VIEW
UNION ALL SELECT 'CERTIFICATE_RENEWAL_VIEW', COUNT(*) FROM CERTIFICATE_RENEWAL_VIEW
UNION ALL SELECT 'LOAN_PORTFOLIO_VIEW', COUNT(*) FROM LOAN_PORTFOLIO_VIEW
UNION ALL SELECT 'CREDIT_CARD_HEALTH_VIEW', COUNT(*) FROM CREDIT_CARD_HEALTH_VIEW
UNION ALL SELECT 'BRANCH_PERFORMANCE_VIEW', COUNT(*) FROM BRANCH_PERFORMANCE_VIEW
UNION ALL SELECT 'TIME_SERIES_METRICS_VIEW', COUNT(*) FROM TIME_SERIES_METRICS_VIEW;

-- Check Encinitas branch data (important for demo)
SELECT 
    BRANCH_NAME,
    ACTIVE_MEMBERS,
    CERTIFICATES_MATURING_90_DAYS,
    TOTAL_DEPOSITS
FROM BRANCH_PERFORMANCE_VIEW
WHERE BRANCH_NAME = 'Encinitas Main Branch';

-- Check recent member data
SELECT COUNT(*) as recent_members
FROM MEMBER_ACQUISITION_VIEW
WHERE IS_NEW_MEMBER_90_DAYS = 1;

-- Check certificate renewal pipeline
SELECT 
    SUM(IS_MATURING_30_DAYS) as maturing_30d,
    SUM(IS_MATURING_90_DAYS) as maturing_90d,
    SUM(CASE WHEN IS_MATURING_90_DAYS = 1 THEN CURRENT_BALANCE ELSE 0 END) as value_90d
FROM CERTIFICATE_RENEWAL_VIEW;
```

**Expected Results:**
- Members: ~5,000
- Accounts: ~8,000
- Loans: ~5,000
- Branches: 8
- Views: Each should have data
- Encinitas: Should be the largest branch
- Recent members: ~387 in last 90 days
- Certificates maturing: ~300-400 in next 90 days

---

## Demo Ready! 🚀

Your Credit Union Snowflake Intelligence demo is now ready to use!

### Suggested Demo Flow

**1. Start Simple (2 min)**
- _"How many new members in last 90 days?"_
- _"Which marketing channels are most effective?"_

**2. Branch-Specific (3 min)**
- _"How many certificates renewing at Encinitas in next 90 days?"_
- _"Compare Encinitas to other branches"_

**3. Loan Portfolio (5 min)**
- _"How are auto loan balances trending?"_
- _"What percentage of portfolio is auto loans?"_
- _"Show credit score migration for credit cards"_

**4. Advanced Analysis (3 min)**
- _"Identify high-risk credit cards"_
- _"Which members should we target for loan products?"_

### Key Talking Points

✨ **Speed**: Answers in seconds, not days  
✨ **Accessibility**: No SQL knowledge required  
✨ **Flexibility**: Natural language, any question  
✨ **Depth**: Can drill down as deep as needed  
✨ **Context**: Agent understands credit union terminology  

---

## Support Resources

**Setup Issues**: Review this QUICK_START.md  
**Demo Questions**: See `sample_questions.md`  
**Technical Details**: See `semantic_view_description.md`  
**Agent Configuration**: See `agent_instructions.md`  
**Complete Guide**: See `README.md`

---

**Total Setup Time**: ~10 minutes  
**Demo Ready**: Immediately after setup  
**Skill Level Required**: Basic SQL knowledge (copy/paste)  
**Snowflake Edition**: Enterprise or higher with Cortex

**Questions?** Review the comprehensive documentation in README.md or contact your Snowflake account team.

---

*Last Updated: October 2025 | Version 1.0*

