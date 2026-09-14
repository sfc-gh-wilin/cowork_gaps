-- =============================================================================
-- Automation Tasks: Scheduled Daily Reports
-- CoWork Gaps / Credit Intelligence Demo
-- =============================================================================
-- These Snowflake Tasks run on a daily schedule to generate fresh report
-- snapshots. Each report is stored in DAILY_REPORTS and can be surfaced
-- by the Credit Intelligence Agent as an Artifact in CoWork.
--
-- Schedule overview (all times ET, weekdays only):
--   5:00 AM  - Fund Flows Summary
--   5:50 AM  - Compliance Alerts
--   6:00 AM  - Overnight Credit Rating Actions
--   6:00 AM  - Macro & Rates Snapshot
--   6:30 AM  - Muni Watchlist Changes
--   7:15 AM  - New Issue Pipeline
-- =============================================================================

USE DATABASE CREDIT_INTELLIGENCE_DB;
USE SCHEMA MAIN;
USE WAREHOUSE CREDIT_INTEL_WH;

-- Ensure the reports table exists
CREATE TABLE IF NOT EXISTS CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (
    REPORT_ID       VARCHAR(50)        DEFAULT UUID_STRING(),
    REPORT_DATE     DATE               NOT NULL,
    REPORT_TYPE     VARCHAR(50)        NOT NULL,
    REPORT_CONTENT  VARCHAR(16777216),
    GENERATED_AT    TIMESTAMP_NTZ      DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_DAILY_REPORTS PRIMARY KEY (REPORT_ID)
);

-- =============================================================================
-- TASK 1: Fund Flows Summary — 5:00 AM ET daily (weekdays)
-- =============================================================================
CREATE OR REPLACE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_FUND_FLOWS_DAILY
  WAREHOUSE = CREDIT_INTEL_WH
  SCHEDULE  = 'USING CRON 0 5 * * 1-5 America/New_York'
  COMMENT   = 'Daily 5:00 AM ET — Fund Flows Summary for all portfolios'
AS
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (REPORT_DATE, REPORT_TYPE, REPORT_CONTENT)
SELECT
    CURRENT_DATE(),
    'FUND_FLOWS',
    'Fund Flows Summary — ' || TO_VARCHAR(CURRENT_DATE(), 'YYYY-MM-DD') || CHR(10) ||
    '---' || CHR(10) ||
    LISTAGG(
        fund_name || ': Inflow $' || TO_VARCHAR(ROUND(inflow_usd/1e6,1)) || 'M | ' ||
        'Outflow $' || TO_VARCHAR(ROUND(outflow_usd/1e6,1)) || 'M | ' ||
        'Net ' || CASE WHEN net_flow_usd >= 0 THEN '+' ELSE '' END ||
        TO_VARCHAR(ROUND(net_flow_usd/1e6,1)) || 'M | AUM $' ||
        TO_VARCHAR(ROUND(aum_usd/1e9,2)) || 'B',
        CHR(10)
    ) WITHIN GROUP (ORDER BY fund_name)
FROM CREDIT_INTELLIGENCE_DB.MAIN.FUND_FLOWS
WHERE FLOW_DATE = DATEADD(day, -1, CURRENT_DATE())
   OR (FLOW_DATE = CURRENT_DATE() AND EXTRACT(HOUR FROM CURRENT_TIME()) >= 5);

ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_FUND_FLOWS_DAILY RESUME;


-- =============================================================================
-- TASK 2: Compliance Alerts — 5:50 AM ET daily (weekdays)
-- =============================================================================
CREATE OR REPLACE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_COMPLIANCE_DAILY
  WAREHOUSE = CREDIT_INTEL_WH
  SCHEDULE  = 'USING CRON 50 5 * * 1-5 America/New_York'
  COMMENT   = 'Daily 5:50 AM ET — Compliance Alert Snapshot'
AS
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (REPORT_DATE, REPORT_TYPE, REPORT_CONTENT)
SELECT
    CURRENT_DATE(),
    'COMPLIANCE_ALERTS',
    'Compliance Alert Dashboard — ' || TO_VARCHAR(CURRENT_DATE(), 'YYYY-MM-DD') || CHR(10) ||
    '---' || CHR(10) ||
    'OPEN ALERTS: ' || COUNT(*) || CHR(10) ||
    'HIGH: ' || COUNT(CASE WHEN SEVERITY='HIGH' THEN 1 END) ||
    ' | MEDIUM: ' || COUNT(CASE WHEN SEVERITY='MEDIUM' THEN 1 END) ||
    ' | LOW: ' || COUNT(CASE WHEN SEVERITY='LOW' THEN 1 END) || CHR(10) ||
    '---' || CHR(10) ||
    LISTAGG(
        '[' || SEVERITY || '] ' || ALERT_TYPE || ' — ' || COALESCE(PORTFOLIO_NAME,'') ||
        CASE WHEN ISSUER_NAME IS NOT NULL THEN ' (' || ISSUER_NAME || ')' ELSE '' END ||
        ': ' || LEFT(DESCRIPTION, 100),
        CHR(10)
    ) WITHIN GROUP (ORDER BY
        CASE SEVERITY WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END,
        ALERT_DATE
    )
FROM CREDIT_INTELLIGENCE_DB.MAIN.COMPLIANCE_ALERTS
WHERE STATUS = 'OPEN';

ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_COMPLIANCE_DAILY RESUME;


-- =============================================================================
-- TASK 3: Overnight Credit Rating Actions — 6:00 AM ET daily (weekdays)
-- =============================================================================
CREATE OR REPLACE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_RATING_WATCH_DAILY
  WAREHOUSE = CREDIT_INTEL_WH
  SCHEDULE  = 'USING CRON 0 6 * * 1-5 America/New_York'
  COMMENT   = 'Daily 6:00 AM ET — Overnight Credit Rating Actions'
AS
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (REPORT_DATE, REPORT_TYPE, REPORT_CONTENT)
SELECT
    CURRENT_DATE(),
    'RATING_WATCH',
    'Overnight Credit Rating Actions — ' || TO_VARCHAR(CURRENT_DATE(), 'YYYY-MM-DD') || CHR(10) ||
    'Actions in last 24h: ' || COUNT(*) || CHR(10) ||
    '---' || CHR(10) ||
    COALESCE(
        LISTAGG(
            EVENT_DATE::VARCHAR || ' | ' || ISSUER_NAME || ' | ' ||
            AGENCY || ' | ' || ACTION_TYPE ||
            CASE WHEN MAGNITUDE != 0
                 THEN ' (' || OLD_RATING || '→' || NEW_RATING || ')'
                 ELSE ' (Outlook: ' || OLD_OUTLOOK || '→' || NEW_OUTLOOK || ')' END,
            CHR(10)
        ) WITHIN GROUP (ORDER BY ABS(MAGNITUDE) DESC, EVENT_DATE DESC),
        'No rating actions in the last 24 hours.'
    )
FROM CREDIT_INTELLIGENCE_DB.MAIN.RATING_HISTORY
WHERE EVENT_DATE >= DATEADD(day, -1, CURRENT_DATE());

ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_RATING_WATCH_DAILY RESUME;


-- =============================================================================
-- TASK 4: Macro & Rates Snapshot — 6:00 AM ET daily (weekdays)
-- =============================================================================
CREATE OR REPLACE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_MACRO_RATES_DAILY
  WAREHOUSE = CREDIT_INTEL_WH
  SCHEDULE  = 'USING CRON 0 6 * * 1-5 America/New_York'
  COMMENT   = 'Daily 6:00 AM ET — Macro and Rates Snapshot'
AS
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (REPORT_DATE, REPORT_TYPE, REPORT_CONTENT)
SELECT
    CURRENT_DATE(),
    'MACRO_RATES',
    'Macro & Rates Snapshot — ' || TO_VARCHAR(CURRENT_DATE(), 'YYYY-MM-DD') || CHR(10) ||
    '---' || CHR(10) ||
    LISTAGG(
        INDICATOR || ': ' || VALUE::VARCHAR || ' ' || UNIT ||
        ' (' || CASE WHEN CHANGE_BPS > 0 THEN '+' ELSE '' END || CHANGE_BPS::VARCHAR || ' bps)',
        CHR(10)
    ) WITHIN GROUP (ORDER BY CATEGORY, INDICATOR)
FROM CREDIT_INTELLIGENCE_DB.MAIN.MACRO_RATES
WHERE RATE_DATE = (SELECT MAX(RATE_DATE) FROM CREDIT_INTELLIGENCE_DB.MAIN.MACRO_RATES);

ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_MACRO_RATES_DAILY RESUME;


-- =============================================================================
-- TASK 5: Muni Watchlist Changes — 6:30 AM ET daily (weekdays)
-- =============================================================================
CREATE OR REPLACE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_MUNI_WATCHLIST_DAILY
  WAREHOUSE = CREDIT_INTEL_WH
  SCHEDULE  = 'USING CRON 30 6 * * 1-5 America/New_York'
  COMMENT   = 'Daily 6:30 AM ET — Municipal Bond Watchlist Changes'
AS
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (REPORT_DATE, REPORT_TYPE, REPORT_CONTENT)
SELECT
    CURRENT_DATE(),
    'MUNI_WATCHLIST',
    'Municipal Bond Watchlist — ' || TO_VARCHAR(CURRENT_DATE(), 'YYYY-MM-DD') || CHR(10) ||
    'Total on watch: ' || COUNT(*) ||
    ' (Negative: ' || COUNT(CASE WHEN WATCH_TYPE='NEGATIVE' THEN 1 END) ||
    ', Positive: ' || COUNT(CASE WHEN WATCH_TYPE='POSITIVE' THEN 1 END) ||
    ', Developing: ' || COUNT(CASE WHEN WATCH_TYPE='DEVELOPING' THEN 1 END) || ')' || CHR(10) ||
    '---' || CHR(10) ||
    LISTAGG(
        WATCH_TYPE || ' | ' || ISSUER_NAME || ' (' || STATE || ') | ' ||
        CURRENT_RATING || ' | Day ' || DAYS_ON_WATCH || ' | ' || LEFT(WATCH_REASON, 80),
        CHR(10)
    ) WITHIN GROUP (ORDER BY
        CASE WATCH_TYPE WHEN 'NEGATIVE' THEN 1 WHEN 'DEVELOPING' THEN 2 ELSE 3 END,
        DAYS_ON_WATCH DESC
    )
FROM CREDIT_INTELLIGENCE_DB.MAIN.MUNI_WATCHLIST
WHERE WATCH_DATE = (SELECT MAX(WATCH_DATE) FROM CREDIT_INTELLIGENCE_DB.MAIN.MUNI_WATCHLIST);

ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_MUNI_WATCHLIST_DAILY RESUME;


-- =============================================================================
-- TASK 6: New Issue Pipeline — 7:15 AM ET daily (weekdays)
-- =============================================================================
CREATE OR REPLACE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_NEW_ISSUES_DAILY
  WAREHOUSE = CREDIT_INTEL_WH
  SCHEDULE  = 'USING CRON 15 7 * * 1-5 America/New_York'
  COMMENT   = 'Daily 7:15 AM ET — New Issue Pipeline Status'
AS
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS (REPORT_DATE, REPORT_TYPE, REPORT_CONTENT)
SELECT
    CURRENT_DATE(),
    'NEW_ISSUES',
    'New Issue Pipeline — ' || TO_VARCHAR(CURRENT_DATE(), 'YYYY-MM-DD') || CHR(10) ||
    'Active pipeline: ' || COUNT(CASE WHEN STATUS IN ('PRICING','ANNOUNCED') THEN 1 END) || ' deals' || CHR(10) ||
    'Total pipeline size: $' || TO_VARCHAR(ROUND(SUM(CASE WHEN STATUS IN ('PRICING','ANNOUNCED') THEN SIZE_USD_MM ELSE 0 END)/1000,1)) || 'B' || CHR(10) ||
    '---' || CHR(10) ||
    LISTAGG(
        '[' || STATUS || '] ' || ISSUER_NAME || ' | $' ||
        SIZE_USD_MM::VARCHAR || 'M | ' || DEAL_TYPE || ' | ' ||
        MATURITY_YEARS || 'Y | ' || RATING ||
        CASE WHEN GUIDANCE_BPS IS NOT NULL THEN ' | Talk: ' || GUIDANCE_BPS || 'bps' ELSE '' END ||
        CASE WHEN FINAL_SPREAD_BPS IS NOT NULL THEN ' → Priced: ' || FINAL_SPREAD_BPS || 'bps' ELSE '' END,
        CHR(10)
    ) WITHIN GROUP (ORDER BY
        CASE STATUS WHEN 'PRICING' THEN 1 WHEN 'ANNOUNCED' THEN 2 WHEN 'PRICED' THEN 3 ELSE 4 END,
        ANNOUNCEMENT_DATE DESC
    )
FROM CREDIT_INTELLIGENCE_DB.MAIN.NEW_ISSUES
WHERE ANNOUNCEMENT_DATE >= DATEADD(day, -7, CURRENT_DATE())
   OR STATUS IN ('PRICING', 'ANNOUNCED');

ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_NEW_ISSUES_DAILY RESUME;


-- =============================================================================
-- VERIFICATION: Check all tasks are active
-- =============================================================================
SELECT
    TASK_NAME,
    STATE,
    SCHEDULE,
    LAST_COMMITTED_ON,
    COMMENT
FROM INFORMATION_SCHEMA.TASKS
WHERE TASK_SCHEMA = 'MAIN'
ORDER BY TASK_NAME;
