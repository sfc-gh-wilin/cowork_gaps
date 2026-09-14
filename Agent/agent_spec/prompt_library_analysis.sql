-- =============================================================================
-- Phase 4: Prompt Library Analysis
-- CoWork Gaps / Credit Intelligence Demo
-- =============================================================================
-- Purpose: Analyze agent usage patterns to identify high-frequency, high-quality
--          prompts and recommend new skills to create. This implements Daniel's
--          "collect → classify → surface the best" prompt library vision.
--
-- Data Source: SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY
-- Note: This view requires ACCOUNTADMIN or SNOWFLAKE database grants.
-- Activate by granting: GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE <your_role>;
-- =============================================================================

USE DATABASE CREDIT_INTELLIGENCE_DB;
USE SCHEMA MAIN;
USE WAREHOUSE CREDIT_INTEL_WH;

-- -----------------------------------------------------------------------------
-- 1. PROMPT ANALYTICS VIEW
--    Classifies agent prompts into skill categories using pattern matching.
--    Extend the CASE logic as new prompt patterns emerge.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW CREDIT_INTELLIGENCE_DB.MAIN.PROMPT_ANALYTICS AS
WITH raw_usage AS (
    SELECT
        DATE_TRUNC('day', CONVERSATION_START_TIME)::DATE  AS conversation_date,
        USER_NAME,
        CONVERSATION_ID,
        FIRST_USER_MESSAGE,
        MESSAGE_COUNT,
        USER_FEEDBACK_SCORE,   -- NULL if no feedback given
        AGENT_NAME,
        CONVERSATION_START_TIME,
        CONVERSATION_END_TIME,
        DATEDIFF('second', CONVERSATION_START_TIME, CONVERSATION_END_TIME) AS session_duration_sec
    FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY
    WHERE AGENT_NAME ILIKE '%CREDIT_INTELLIGENCE%'
      AND CONVERSATION_START_TIME >= DATEADD(day, -90, CURRENT_TIMESTAMP())
)
SELECT
    conversation_date,
    USER_NAME,
    CONVERSATION_ID,
    FIRST_USER_MESSAGE,
    MESSAGE_COUNT,
    session_duration_sec,
    USER_FEEDBACK_SCORE,
    AGENT_NAME,
    -- -------------------------------------------------------------------------
    -- Skill category classification (pattern matching)
    -- Add new patterns here as the library grows
    -- -------------------------------------------------------------------------
    CASE
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(rating|downgrad|upgrad|outlook|watchlist).*(change|action|week|days|today).*'
          OR LOWER(FIRST_USER_MESSAGE) RLIKE '.*(overnight|recent).*(rating|credit action).*'
            THEN 'Rating Watch'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(deep dive|credit profile|full analysis|issuer analysis).*'
          OR LOWER(FIRST_USER_MESSAGE) RLIKE '.*(summar|profile|leverage|history).*(issuer|company|corp|inc).*'
            THEN 'Issuer Deep Dive'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(sector|industry).*(spread|credit|analysis|outlook|scan|compare).*'
          OR LOWER(FIRST_USER_MESSAGE) RLIKE '.*(healthcare|technology|financial|energy|industrial).*(credit|spread|rating).*'
            THEN 'Sector Scan'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(muni|municipal).*(watchlist|change|watch|alert).*'
            THEN 'Muni Watchlist'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(macro|rate|yield|treasury|cpi|gdp|inflation|fed|cdx).*'
          OR LOWER(FIRST_USER_MESSAGE) RLIKE '.*(snapshot|environment|monetary|bps).*'
            THEN 'Macro & Rates'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(compliance|alert|breach|violation|ips|limit|policy).*'
            THEN 'Compliance'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(fund flow|aum|inflow|outflow|subscription|redemption|net flow).*'
            THEN 'Fund Flows'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(new issue|pipeline|pricing|priced|primary market|deal|ipo).*'
            THEN 'New Issues'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(portfolio|holding|position|weight|exposure|allocation).*'
            THEN 'Portfolio'
        WHEN LOWER(FIRST_USER_MESSAGE) RLIKE '.*(spread|oas|credit spread|basis point).*'
            THEN 'Spread Analysis'
        ELSE 'Other / Unclassified'
    END                                                    AS prompt_category,

    -- -------------------------------------------------------------------------
    -- Quality signals
    -- -------------------------------------------------------------------------
    CASE
        WHEN USER_FEEDBACK_SCORE >= 4 THEN 'Positive'
        WHEN USER_FEEDBACK_SCORE <= 2 THEN 'Negative'
        WHEN USER_FEEDBACK_SCORE = 3  THEN 'Neutral'
        ELSE 'No Feedback'
    END                                                    AS feedback_label,

    -- Engagement proxy: longer sessions with more messages = higher engagement
    CASE
        WHEN MESSAGE_COUNT >= 5 AND session_duration_sec >= 120 THEN 'High'
        WHEN MESSAGE_COUNT >= 3 OR session_duration_sec >= 60   THEN 'Medium'
        ELSE 'Low'
    END                                                    AS engagement_level

FROM raw_usage;


-- -----------------------------------------------------------------------------
-- 2. PROMPT FREQUENCY LEADERBOARD
--    Shows which prompt categories are used most. Run this weekly to find
--    candidates for new sample_questions or skills.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW CREDIT_INTELLIGENCE_DB.MAIN.PROMPT_FREQUENCY_LEADERBOARD AS
SELECT
    prompt_category,
    COUNT(*)                                                   AS total_sessions,
    COUNT(DISTINCT USER_NAME)                                  AS unique_users,
    ROUND(AVG(MESSAGE_COUNT), 1)                               AS avg_messages_per_session,
    ROUND(AVG(session_duration_sec) / 60.0, 1)                 AS avg_session_min,
    COUNT(CASE WHEN feedback_label = 'Positive' THEN 1 END)    AS positive_feedback_count,
    COUNT(CASE WHEN feedback_label = 'Negative' THEN 1 END)    AS negative_feedback_count,
    COUNT(CASE WHEN feedback_label = 'No Feedback' THEN 1 END) AS no_feedback_count,
    ROUND(
        COUNT(CASE WHEN feedback_label = 'Positive' THEN 1 END)::FLOAT /
        NULLIF(COUNT(CASE WHEN feedback_label IN ('Positive','Negative') THEN 1 END), 0) * 100
    , 1)                                                       AS positive_feedback_pct,
    COUNT(CASE WHEN engagement_level = 'High' THEN 1 END)      AS high_engagement_sessions,
    -- Composite score: frequency * quality (for skill promotion ranking)
    ROUND(
        COUNT(*) * 0.4 +
        COALESCE(AVG(NULLIF(USER_FEEDBACK_SCORE, NULL)), 3) * 10 * 0.3 +
        COUNT(CASE WHEN engagement_level = 'High' THEN 1 END) * 0.3
    , 2)                                                       AS skill_promotion_score,
    MIN(conversation_date)                                     AS first_seen,
    MAX(conversation_date)                                     AS last_seen
FROM CREDIT_INTELLIGENCE_DB.MAIN.PROMPT_ANALYTICS
GROUP BY prompt_category
ORDER BY total_sessions DESC;


-- -----------------------------------------------------------------------------
-- 3. HIGH-VALUE PROMPT CANDIDATES
--    Specific prompts that appear frequently and have positive feedback.
--    These are candidates to promote into sample_questions or new skills.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW CREDIT_INTELLIGENCE_DB.MAIN.HIGH_VALUE_PROMPT_CANDIDATES AS
SELECT
    prompt_category,
    FIRST_USER_MESSAGE,
    COUNT(*)                    AS frequency,
    ROUND(AVG(NULLIF(USER_FEEDBACK_SCORE, NULL)), 2) AS avg_feedback,
    MAX(conversation_date)      AS most_recent,
    COUNT(DISTINCT USER_NAME)   AS unique_users_who_asked,
    -- Recommendation action
    CASE
        WHEN COUNT(*) >= 10 AND AVG(NULLIF(USER_FEEDBACK_SCORE, NULL)) >= 4.0
            THEN 'PROMOTE TO SKILL'
        WHEN COUNT(*) >= 5 AND AVG(NULLIF(USER_FEEDBACK_SCORE, NULL)) >= 3.5
            THEN 'ADD TO SAMPLE_QUESTIONS'
        WHEN COUNT(*) >= 3
            THEN 'MONITOR'
        ELSE 'INSUFFICIENT DATA'
    END AS recommendation
FROM CREDIT_INTELLIGENCE_DB.MAIN.PROMPT_ANALYTICS
WHERE prompt_category != 'Other / Unclassified'
GROUP BY prompt_category, FIRST_USER_MESSAGE
HAVING COUNT(*) >= 2
ORDER BY frequency DESC, avg_feedback DESC NULLS LAST;


-- -----------------------------------------------------------------------------
-- 4. DAILY USAGE TREND
--    Day-by-day session count and active users. Useful for monitoring adoption.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW CREDIT_INTELLIGENCE_DB.MAIN.DAILY_USAGE_TREND AS
SELECT
    conversation_date,
    COUNT(*)                    AS total_sessions,
    COUNT(DISTINCT USER_NAME)   AS active_users,
    SUM(MESSAGE_COUNT)          AS total_messages,
    ROUND(AVG(MESSAGE_COUNT), 1) AS avg_messages_per_session,
    COUNT(CASE WHEN USER_FEEDBACK_SCORE IS NOT NULL THEN 1 END) AS sessions_with_feedback,
    ROUND(AVG(NULLIF(USER_FEEDBACK_SCORE, NULL)), 2)            AS avg_feedback_score
FROM CREDIT_INTELLIGENCE_DB.MAIN.PROMPT_ANALYTICS
GROUP BY conversation_date
ORDER BY conversation_date DESC;


-- -----------------------------------------------------------------------------
-- 5. PROMPT LIBRARY MAINTENANCE QUERY
--    Run monthly. Returns prompts ready for promotion + agent config updates.
--    Output can be handed to the agent developer to update sample_questions
--    and potentially author new SKILL.md files.
-- -----------------------------------------------------------------------------
SELECT
    '=== MONTHLY PROMPT LIBRARY REVIEW ===' AS section,
    NULL AS prompt_category, NULL AS recommendation,
    NULL AS frequency, NULL AS avg_feedback, NULL AS prompt
UNION ALL
SELECT NULL, NULL, NULL, NULL, NULL, NULL
UNION ALL
SELECT
    '--- PROMOTE TO SKILL (high frequency + high feedback) ---',
    NULL, NULL, NULL, NULL, NULL
UNION ALL
SELECT
    NULL,
    prompt_category,
    recommendation,
    frequency::VARCHAR,
    avg_feedback::VARCHAR,
    LEFT(FIRST_USER_MESSAGE, 120)
FROM CREDIT_INTELLIGENCE_DB.MAIN.HIGH_VALUE_PROMPT_CANDIDATES
WHERE recommendation = 'PROMOTE TO SKILL'
ORDER BY 4 DESC NULLS LAST
LIMIT 10
UNION ALL
SELECT NULL, NULL, NULL, NULL, NULL, NULL
UNION ALL
SELECT
    '--- ADD TO SAMPLE_QUESTIONS (moderate frequency + good feedback) ---',
    NULL, NULL, NULL, NULL, NULL
UNION ALL
SELECT
    NULL,
    prompt_category,
    recommendation,
    frequency::VARCHAR,
    avg_feedback::VARCHAR,
    LEFT(FIRST_USER_MESSAGE, 120)
FROM CREDIT_INTELLIGENCE_DB.MAIN.HIGH_VALUE_PROMPT_CANDIDATES
WHERE recommendation = 'ADD TO SAMPLE_QUESTIONS'
ORDER BY 4 DESC NULLS LAST
LIMIT 10;
