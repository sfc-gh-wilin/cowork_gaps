# Credit Intelligence Agent — User Guide

**Agent:** `CREDIT_INTELLIGENCE_AGENT` in `CREDIT_INTELLIGENCE_DB.MAIN`  
**Display Name:** Credit Intelligence  
**Environment:** wl_sandbox (`SFPSCOGS-WLIN_AWS_W2`)  
**Last Updated:** September 14, 2026

---

## Where to Start

| If you want to… | Go to |
|-----------------|-------|
| **Test the whole project end to end** | [Full End-to-End Test Walkthrough](#full-end-to-end-test-walkthrough) ← start here |
| Just use the agent day to day | [Getting Started](#getting-started) |
| Look up what a specific skill does | [The 8 Standard Prompt Skills](#the-8-standard-prompt-skills) |
| Ask questions without a skill | [Natural Language Questions](#natural-language-questions-no-skill-needed) |
| Save or share a report | [Saving Reports as Artifacts](#saving-reports-as-artifacts) |
| Fix an error | [Troubleshooting](#troubleshooting) |
| See what data exists | [Data Reference](#data-reference) |
| Re-deploy or change something | [For Developers / Admins](#for-developers--admins) |

---

## Getting Started

### Accessing the Agent in CoWork

1. Sign in to Snowsight for the `wl_sandbox` account
2. Navigate to **AI & ML → Agents**
3. Find **CREDIT_INTELLIGENCE_AGENT** in the `CREDIT_INTELLIGENCE_DB.MAIN` schema
4. Click **Open in CoWork** (or the CoWork link)

The agent will open in CoWork with 8 starter questions visible on the new conversation screen.

### What the Agent Can Do

The Credit Intelligence Agent answers questions about:

| Domain | Data Available |
|--------|---------------|
| **Credit Ratings** | 20 issuers, 15 rating events (upgrades, downgrades, outlooks), last 3 months |
| **Portfolio Holdings** | 3 funds: IG Core ($12.5B), HY Opportunities ($4.8B), Municipal ($8.2B) |
| **Credit Spreads** | 10 issuers, 60 days of daily 5Y spread data |
| **Compliance Alerts** | 5 alerts across all portfolios (HIGH/MEDIUM/LOW severity) |
| **Fund Flows** | 3 funds, 30 days of daily inflow/outflow/net flow/AUM |
| **New Issues** | 8 deals (2 pricing, 2 announced, 3 priced, 1 withdrawn) |
| **Muni Watchlist** | 5 municipal bonds (2 negative, 2 positive, 1 developing watch) |
| **Macro & Rates** | Treasury yields, CDX indices, CPI, GDP, unemployment |
| **Research Docs** | 7 documents: credit reports, sector analyses, rating actions, morning brief, IPS |

---

## The 8 Standard Prompt Skills

Skills are reusable workflows that the agent follows step-by-step. Invoke them with `/skill-name` or describe what you want in plain English.

---

### `/rating-watch` — Overnight Credit Rating Actions

**What it does:** Reports all rating changes, outlook revisions, and watchlist placements from the last 5 trading days, sorted by impact magnitude.

**How to use:**
```
/rating-watch
/rating-watch last 3 days
/rating-watch sector Healthcare
```

**What you get:**
- Summary counts (upgrades / downgrades / outlook changes)
- Detailed table: date, issuer, agency, action, rating change, analyst comment
- Bar chart: actions by type
- Narrative paragraph highlighting key moves

**Example output includes:** Ford Motor (BB→BB+ upgrade), CVS Health (BBB+→BBB downgrade), Tesla (positive watch)

---

### `/issuer-deep-dive [issuer name]` — Full Credit Profile

**What it does:** Comprehensive single-issuer report covering ratings, spread trends, portfolio exposure, and relevant research.

**How to use:**
```
/issuer-deep-dive Ford Motor
/issuer-deep-dive Apple
Give me a deep dive on JPMorgan Chase
Full credit profile for Pfizer
```

**What you get:**
1. Credit profile table (all three agency ratings + outlook)
2. Rating history (last 12 months of actions)
3. 60-day credit spread trend chart
4. Portfolio exposure across all funds
5. Top 3 relevant research documents with excerpts

**Tips:**
- Works with partial issuer names ("Ford" finds "Ford Motor Co")
- If the issuer is not in the database, the agent will say so clearly

---

### `/sector-scan [sector name]` — Sector Credit Comparison

**What it does:** Compares credit spreads and rating distribution for a sector this month vs. last month.

**How to use:**
```
/sector-scan Healthcare
/sector-scan Technology
Compare credit spreads in Financials this month vs last month
```

**Available sectors:** Technology, Financials, Healthcare, Energy, Consumer Discretionary, Industrials, Communication Services, Consumer Staples

**What you get:**
- Spread comparison table (avg, min, max, volatility — this month vs. last)
- Overlay line chart: current month vs. prior month spread
- Rating distribution (IG vs. HY breakdown)
- Portfolio exposure to this sector
- Recent rating actions in the sector (last 30 days)
- Research highlights

---

### `/muni-watchlist` — Municipal Bond Watchlist

**What it does:** Full municipal bond watchlist with risk assessment and portfolio impact.

**How to use:**
```
/muni-watchlist
Show me muni watchlist changes
Any municipal bonds on negative watch?
```

**What you get:**
- Summary table: negative / positive / developing watch counts + portfolio exposure
- Detailed watchlist: issuer, state, obligation type, rating, days on watch, reason
- Portfolio cross-reference: flags holdings that are on the watchlist
- Risk assessment with portfolio dollar exposure to negative-watch names
- Chart: days on watch by issuer (color-coded by watch type)

**Current watchlist (as of demo data):**
- **Negative:** Chicago GO Bonds (45d), NYC Housing Dev Corp (22d)
- **Developing:** Jefferson County Sewer (89d)
- **Positive:** San Francisco Unified SD (12d), Oklahoma State GO (8d)

---

### `/macro-rates` — Macro & Rates Snapshot

**What it does:** Current macro environment snapshot with Treasury yields, credit indices, and key economic indicators.

**How to use:**
```
/macro-rates
Show me the macro and rates snapshot
What are Treasury yields doing today?
CDX levels?
```

**What you get:**
- Treasury yield table (2Y/5Y/10Y/30Y + 2Y-10Y spread) with day-over-day changes
- Yield curve chart
- Credit indices (CDX IG, CDX HY, IG Corp OAS, HY Corp OAS, Muni/UST ratio)
- Key macro indicators (CPI, PCE, GDP, unemployment, DXY)
- Market commentary excerpt from the most recent morning brief

**Current data highlights:**
- 10Y UST: 4.18% (−8bps today)
- CDX IG 5Y: 62.5bps | CDX HY 5Y: 358bps
- US CPI YoY: 3.2% (declining) | GDP QoQ: 2.8%
- Implied 68% probability of November Fed cut

---

### `/compliance-check` — Compliance Alert Dashboard

**What it does:** Shows all active IPS compliance alerts with action deadlines per the Investment Policy Statement.

**How to use:**
```
/compliance-check
Show me compliance alerts
Any IPS violations I need to know about?
What compliance actions are outstanding?
```

**What you get:**
- Alert summary: OPEN / ACKNOWLEDGED / RESOLVED (last 7 days)
- For each open alert: portfolio, type, issuer, limit vs. actual, severity, action deadline
- IPS policy excerpts relevant to each breach type
- Chart: open alerts by severity per portfolio

**Current open alerts:**
| Severity | Alert | Action Required |
|----------|-------|----------------|
| 🔴 HIGH | Baxter International — Rating at floor (BBB-) in IG Core | Within 5 business days |
| 🟠 MEDIUM | Ford Motor — 14.92% concentration vs. 12% soft limit in HY Opp | PM review within 48h |

---

### `/fund-flows` — Fund Flows Summary

**What it does:** Inflow/outflow/net flow trends for all credit funds, with AUM trend charts and notable flow events.

**How to use:**
```
/fund-flows
/fund-flows IG Core
Show me fund flow trends
Any significant redemptions this week?
```

**What you get:**
- Summary table: total inflows, outflows, net flow, current AUM per fund
- AUM trend chart (30-day line chart, one line per fund)
- Daily net flow bar chart (green=inflows, red=outflows)
- Notable flow events (days >1% of AUM)
- Flow narrative: rotation trends, anomalies

**Available funds:** IG Core Bond Fund, HY Opportunities Fund, Municipal Bond Fund

---

### `/new-issues` — New Issue Pipeline

**What it does:** Current new issue pipeline status with deal details, pricing outcomes, and demand metrics.

**How to use:**
```
/new-issues
What's in the new issue pipeline today?
Show me deals that priced this week
What was the book size on the Marriott deal?
```

**What you get:**
- Pipeline summary: deals by status, total size, IG vs. HY breakdown
- **Pricing now:** full deal sheet (issuer, size, guidance, lead managers, rating)
- **Announced:** upcoming deals
- **Recently priced:** final spread vs. guidance (tightening = strong demand), oversubscription multiple
- **Withdrawn:** withdrawn deals with notes
- Average oversubscription for the week

**Current pipeline (demo data):**
- **Pricing:** NextEra Energy $2.5Bn IG (A−), Centene Corp $750M HY (BB)
- **Announced:** P&G $2.0Bn 30Y IG (AA−), Duke Energy $1.5Bn 5Y IG (A−)
- **Priced this week:** Marriott 3.2x covered, Waste Connections 7.0x covered, United Rentals 3.5x covered

---

## Natural Language Questions (No Skill Needed)

You don't always need to use a skill. The agent handles plain English questions directly:

**Portfolio questions:**
- "What is the total market value of the IG Core Bond Fund?"
- "Show me all Healthcare holdings across all portfolios"
- "Which bonds in my HY fund have a duration over 5 years?"
- "What's my total exposure to Consumer Discretionary?"

**Rating questions:**
- "Has CVS Health been downgraded recently? What was the reason?"
- "Which issuers have a Negative outlook right now?"
- "List all investment grade issuers that are within one notch of HY"

**Spread questions:**
- "What's the average spread for Technology issuers vs. Healthcare?"
- "Show me Ford Motor's spread over the last 30 days as a chart"

**Research questions:**
- "What does the Q3 2026 credit outlook say about high yield?"
- "Summarize the Investment Policy Statement rules for the HY portfolio"
- "What are the key risks for Carnival Corp?"

---

## Saving Reports as Artifacts

After any response that contains a chart or table:

1. Hover over the chart or table in CoWork
2. Click the **Save as Artifact** button (bookmark icon)
3. Give it a name (e.g., "Rating Watch 2026-09-11")
4. The artifact is now accessible from your **Artifacts** tab

**To share:** Open the artifact → click **Share** → copy the link. Anyone with the link and CoWork access can view the artifact.

**To set up recurring refresh:** After saving an artifact, click **Create Automation** to schedule the underlying query to re-run on a schedule (e.g., every weekday at 6 AM).

> **Known gap:** Artifacts can only be shared one at a time via link. You cannot pin a collection of artifacts to a shared home screen visible to all team members. This is Gap 1 in the project's gap report.

---

## Setting Up Automations via Chat

You can create a CoWork Automation by describing the schedule in plain English:

```
"Send me the overnight credit rating actions every weekday at 6 AM"
"Run /muni-watchlist every Monday morning and email me the results"
"Remind me to check compliance alerts every weekday before market open"
```

CoWork will confirm the schedule and create the automation. You'll receive an email with a link to the latest report output at the scheduled time.

> **Note:** The Snowflake Tasks in `CREDIT_INTELLIGENCE_DB.MAIN` (the `TASK_*` objects) are a separate backend mechanism that writes report text to `DAILY_REPORTS`. These feed the Cortex Agent so it can answer "what was in yesterday's rating watch?" from the agent itself.

---

## Full End-to-End Test Walkthrough

> **Purpose:** A single ordered checklist that exercises **every feature this project supports** — backend objects, the agent's 4 tools, all 8 skills, artifacts, automations, scheduled tasks, and usage analytics. Budget ~45–60 minutes for a complete pass. Work top to bottom; each part assumes the previous one passed.
>
> **Where each step runs** is marked: 🖥️ **SQL** (Snowsight worksheet or `snow sql`), 💬 **CoWork** (chat UI), 🗂️ **Snowsight UI** (navigation/clicks).

### Test Scorecard (fill this in as you go)

| # | Part | What it proves | Pass? |
|---|------|---------------|-------|
| 0 | Prerequisites | Access + role + warehouse | ☐ |
| 1 | Backend objects | Data, semantic view, search, stage, agent all exist | ☐ |
| 2 | Open agent in CoWork | Agent is reachable by an end user | ☐ |
| 3 | Sample questions | 8 starter prompts render and answer | ☐ |
| 4 | Tool: Cortex Analyst | Text-to-SQL over semantic view | ☐ |
| 5 | Tool: Cortex Search | Doc retrieval **with citations** | ☐ |
| 6 | Tool: data_to_chart | Chart rendering | ☐ |
| 7 | Tool: code_execution | Python/calculation path | ☐ |
| 8 | All 8 skills | Each `/skill` runs its full workflow | ☐ |
| 9 | Multi-turn threads | Conversation state is retained | ☐ |
| 10 | Artifacts | Save + share a report output | ☐ |
| 11 | Automations (CoWork) | Natural-language scheduling | ☐ |
| 12 | Scheduled tasks (backend) | `DAILY_REPORTS` gets populated | ☐ |
| 13 | Usage analytics | Phase 4 views return rows | ☐ |
| 14 | Gap evidence | Screenshots captured for Gaps 1–6 | ☐ |

---

### Part 0 — Prerequisites

**0.1** 🗂️ Confirm you can sign in to Snowsight for account `SFPSCOGS-WLIN_AWS_W2` (`wl_sandbox`).

**0.2** 🖥️ Confirm your role can see the objects and the warehouse will start:

```sql
USE ROLE ACCOUNTADMIN;             -- or the role granted on CREDIT_INTELLIGENCE_DB
USE WAREHOUSE CREDIT_INTEL_WH;
USE DATABASE CREDIT_INTELLIGENCE_DB;
USE SCHEMA MAIN;
SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();
```

If you get `No active warehouse selected in the current session`, you skipped `USE WAREHOUSE` — this is the single most common failure in every step below.

**0.3** 🖥️ CLI users: verify the connection alias works.

```bash
snow sql -c wl_sandbox -q "USE WAREHOUSE CREDIT_INTEL_WH; SELECT CURRENT_ACCOUNT();"
```

**Pass criteria:** role, warehouse, database, and schema all resolve without error.

---

### Part 1 — Backend Object Verification (🖥️ SQL, ~5 min)

Run these **before** touching CoWork. If the backend is wrong, every CoWork test will fail for the wrong reason.

**1.1 — All 11 tables + 2 views exist with expected row counts**

```sql
SELECT table_name, table_type, row_count
FROM CREDIT_INTELLIGENCE_DB.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'MAIN'
ORDER BY table_name;
```

**Expected:** `ISSUERS` 20 · `RATING_HISTORY` 15 · `CREDIT_SPREADS` 440 · `PORTFOLIO_HOLDINGS` 20 · `COMPLIANCE_ALERTS` 5 · `MUNI_WATCHLIST` 5 · `FUND_FLOWS` 66 · `NEW_ISSUES` 8 · `MACRO_RATES` 22 · `RESEARCH_DOCUMENTS` 7 · `DAILY_REPORTS` 0 (until Part 12) · plus views `AGENT_USAGE_ANALYTICS` and `DAILY_USAGE_TREND` (row_count is `NULL` for views — that is correct, not a failure).

**1.2 — Semantic view is queryable**

```sql
SHOW SEMANTIC VIEWS IN SCHEMA CREDIT_INTELLIGENCE_DB.MAIN;

-- Prove it actually resolves metrics, not just that it exists:
SELECT * FROM SEMANTIC_VIEW(
  CREDIT_INTELLIGENCE_DB.MAIN.CREDIT_INTELLIGENCE_SV
  DIMENSIONS issuers.sector
  METRICS portfolio_holdings.total_market_value
) ORDER BY 1;
```

**Pass criteria:** returns one row per sector with a non-null market value (verified working). If this fails, Cortex Analyst (Part 4) and every data-driven skill will fail.

**Expected quirk:** one row comes back with `SECTOR = NULL` and ~$29.3M of value. That is the Municipal Bond Fund — muni holdings have no corporate issuer to join to, so they carry no sector. Not a bug.

**1.3 — Cortex Search Service is built and serving**

```sql
SHOW CORTEX SEARCH SERVICES IN SCHEMA CREDIT_INTELLIGENCE_DB.MAIN;
DESCRIBE CORTEX SEARCH SERVICE CREDIT_INTELLIGENCE_DB.MAIN.RESEARCH_SEARCH;
```

**Pass criteria:** `RESEARCH_SEARCH` is listed and `DESCRIBE` shows a completed/served state with a recent refresh. A brand-new service takes 5–15 minutes to index — if it is still building, continue with other parts and come back to Part 5.

**1.4 — All 8 SKILL.md files are on the stage**

```sql
LS @CREDIT_INTELLIGENCE_DB.MAIN.AGENT_SKILLS_STAGE;
```

**Expected:** exactly 8 files, one per folder: `compliance-check`, `fund-flows`, `issuer-deep-dive`, `macro-rates`, `muni-watchlist`, `new-issues`, `rating-watch`, `sector-scan`.

**1.5 — Agent exists with 4 tools and 8 skills attached**

```sql
SHOW AGENTS IN SCHEMA CREDIT_INTELLIGENCE_DB.MAIN;
DESCRIBE AGENT CREDIT_INTELLIGENCE_DB.MAIN.CREDIT_INTELLIGENCE_AGENT;
```

**Pass criteria:** the spec shows tools `credit_analyst` (Cortex Analyst), `research_search` (Cortex Search), `data_to_chart`, `code_execution`; 8 skill references pointing at the stage; display name **Credit Intelligence**; and 8 `sample_questions`.

**1.6 — Tasks are started**

```sql
SHOW TASKS IN SCHEMA CREDIT_INTELLIGENCE_DB.MAIN;
```

**Pass criteria:** 6 `TASK_*_DAILY` tasks with `state = started`.

---

### Part 2 — Open the Agent in CoWork (🗂️ + 💬, ~2 min)

**2.1** In Snowsight, go to **AI & ML → Agents**.
**2.2** Select **CREDIT_INTELLIGENCE_AGENT** (schema `CREDIT_INTELLIGENCE_DB.MAIN`).
**2.3** Click **Open in CoWork**.

**Pass criteria:** a new CoWork conversation opens, titled **Credit Intelligence**, showing starter question cards.

**If the agent does not appear:** your current Snowsight role has no privileges on the agent — switch to `ACCOUNTADMIN` (or the granted role) using the role picker in the top-right, then reload.

---

### Part 3 — The 8 Sample Questions (💬 CoWork, ~8 min)

Click each starter card in turn (do **not** type them — clicking is what proves the `sample_questions` feature works). After each one, note which tool the agent used; CoWork shows the tool-call trace above the answer.

| # | Starter question | Expect tool | Pass criteria |
|---|-----------------|-------------|---------------|
| 1 | Overnight rating actions | `credit_analyst` | Table of rating events, non-empty |
| 2 | Portfolio exposure question | `credit_analyst` | Table with dollar market values |
| 3 | Spread trend question | `credit_analyst` + `data_to_chart` | Chart renders |
| 4 | Compliance alert question | `credit_analyst` | 5 alerts, severities shown |
| 5 | Muni watchlist question | `credit_analyst` | 5 watchlist names |
| 6 | Macro/rates question | `credit_analyst` | Treasury + CDX values |
| 7 | New issue pipeline question | `credit_analyst` | Deals grouped by status |
| 8 | Research/document question | `research_search` | Answer **with citations** |

**Pass criteria for Part 3:** all 8 return a substantive answer with no tool errors. Record any that fail — a failure here localizes the problem to one tool, which Parts 4–7 then isolate.

---

### Part 4 — Tool Test: Cortex Analyst (text-to-SQL) (💬)

Type each of these and confirm the numbers match the SQL you can run yourself.

**4.1** `What is the total market value of the IG Core Bond Fund?`
**4.2** `Show me all Healthcare holdings across all portfolios`
**4.3** `Which issuers have a Negative outlook right now?`
**4.4** `What's the average 5Y spread by sector over the last 30 days?`

**Cross-check 4.1 in SQL** — the agent's number must match:

```sql
SELECT portfolio_name, COUNT(*) AS holdings, SUM(market_value) AS market_value
FROM CREDIT_INTELLIGENCE_DB.MAIN.PORTFOLIO_HOLDINGS
GROUP BY 1 ORDER BY 3 DESC;
```

**Verified actual values:** HY Opportunities Fund 6 holdings / $31,025,000 · IG Core Bond Fund 10 holdings / $29,753,000 · Municipal Bond Fund 4 holdings / $29,295,000.

**Pass criteria:** the agent shows the SQL it generated, and its IG Core figure matches `$29,753,000` above. A mismatch means the semantic view definition and the base table disagree — that is a real bug, not a UI issue.

> **Do not flag this as a bug:** the "What the Agent Can Do" table above lists fund sizes of $12.5B / $4.8B / $8.2B. Those are **AUM** values from `FUND_FLOWS`; the holdings table holds a representative ~$30M sample per fund. The two are intentionally different scales in the demo data, so an agent answer of ~$29.8M for IG Core holdings is correct.

**4.5 — Negative test (expected graceful failure):** `What is the credit rating of Nintendo?`
**Pass criteria:** the agent states clearly that the issuer is not in the data. It must **not** invent a rating.

---

### Part 5 — Tool Test: Cortex Search + Citations (💬)

**5.1** `Summarize the Ford Motor credit report`
**5.2** `What does the Q3 2026 credit outlook say about high yield?`
**5.3** `Summarize the Investment Policy Statement rules for the HY portfolio`
**5.4** `What are the key risks for Carnival Corp?`

**Pass criteria:** each answer cites a source document (title and/or `DOC00x` id) that you can find in the `RESEARCH_DOCUMENTS` table:

```sql
SELECT doc_id, title, doc_type FROM CREDIT_INTELLIGENCE_DB.MAIN.RESEARCH_DOCUMENTS ORDER BY doc_id;
```

An answer with **no citation** is a failure even if the content looks right — citation rendering is one of the gaps being validated (see Implementation Report, "Gaps Confirmed as GA").

---

### Part 6 — Tool Test: data_to_chart (💬)

**6.1** `Show me Ford Motor's 5Y spread over the last 60 days as a line chart`
**6.2** `Chart average credit spread by sector this month`
**6.3** `Plot AUM trend for all three funds over the last 30 days`
**6.4** Then ask a **follow-up on an existing table**: run any table question, then say `now chart that`.

**Pass criteria:** an interactive chart renders in-line (hover tooltips work). 6.4 is the important one — it proves `data_to_chart` can consume a prior tool result rather than needing a fresh query.

**Known constraint:** `data_to_chart` needs tabular data in context first. Asking for a chart as the very first message in a fresh thread can fail — that is expected behavior, not a defect.

---

### Part 7 — Tool Test: code_execution (💬)

**7.1** `Compute the duration-weighted average yield of the IG Core Bond Fund`
**7.2** `Calculate the 30-day realized volatility of Ford Motor's spread`
**7.3** `What percentage of total AUM across all three funds is in below-investment-grade names?`

**Pass criteria:** the agent runs a code block (visible in the trace) and returns a numeric answer with its working shown. If it answers purely in prose with no code step, `code_execution` is not being invoked — re-check the tool list from step 1.5.

---

### Part 8 — All 8 Skills (💬 CoWork, ~15 min)

This is the core of the demo. Invoke each skill **explicitly with the slash command first** (proves the skill is attached), then **once in plain English** (proves the description-based routing works).

| Skill | Slash invocation | Plain-English invocation | Must include |
|-------|-----------------|-------------------------|--------------|
| `rating-watch` | `/rating-watch` | `What rating actions happened overnight?` | Counts + table + bar chart + narrative |
| `issuer-deep-dive` | `/issuer-deep-dive Ford Motor` | `Give me a full credit profile for Pfizer` | 3-agency ratings, rating history, 60-day spread chart, portfolio exposure, 3 research excerpts |
| `sector-scan` | `/sector-scan Healthcare` | `Compare Financials spreads this month vs last month` | Spread comparison table, overlay chart, IG/HY split, exposure, recent actions |
| `muni-watchlist` | `/muni-watchlist` | `Any municipal bonds on negative watch?` | Summary counts, 5 names, portfolio cross-ref, days-on-watch chart |
| `macro-rates` | `/macro-rates` | `What are Treasury yields doing today?` | Yield table + curve chart, CDX levels, CPI/GDP, brief excerpt |
| `compliance-check` | `/compliance-check` | `Any IPS violations I need to know about?` | Alert summary, limit vs actual, IPS excerpt, severity chart |
| `fund-flows` | `/fund-flows` | `Any significant redemptions this week?` | Per-fund flow table, AUM line chart, daily net-flow bars, notable events |
| `new-issues` | `/new-issues` | `What's in the new issue pipeline today?` | Pipeline by status, deal sheets, spread vs guidance, oversubscription |

**8.1 — Also test skill arguments:**
```
/rating-watch last 3 days
/rating-watch sector Healthcare
/issuer-deep-dive Ford          ← partial name must resolve to Ford Motor Co
/fund-flows IG Core
/sector-scan Technology
```

**8.2 — Negative test:** `/issuer-deep-dive Nintendo`
**Pass criteria:** clean "not in dataset" response, no hallucinated profile.

**8.3 — Skill discovery test:** open the `+` menu → **Skills**.
**Pass criteria:** all 8 skills are listed. **Note the flat, uncategorized list — screenshot it now**; this is the evidence for Gap 2.

**Pass criteria for Part 8:** each skill produces every element in its "Must include" column. A skill that returns a bare table without its chart or narrative has not fully executed its SKILL.md workflow.

---

### Part 9 — Multi-Turn Thread State (💬)

Run this exact sequence in one thread, without repeating context:

1. `What's Ford Motor's current rating?`
2. `Why was it upgraded?`
3. `How much do we hold?`
4. `Chart its spread over the last 60 days`
5. `How does that compare to Tesla?`

**Pass criteria:** turns 2–5 resolve "it"/"that" to Ford Motor with no re-prompting, and turn 5 correctly brings Tesla in as a comparison rather than dropping Ford.

---

### Part 10 — Artifacts (💬 + 🗂️)

**10.1** Run `/macro-rates` and wait for the chart.
**10.2** Hover the chart → click **Save as Artifact** (bookmark icon).
**10.3** Name it `Macro Rates Test <today's date>`.
**10.4** Open the **Artifacts** tab and confirm it is listed.
**10.5** Open the artifact → **Share** → copy the link. Open the link in a private window (or have a teammate open it) and confirm it renders.
**10.6** Repeat 10.1–10.4 for `/fund-flows` and `/muni-watchlist` so you have 3 artifacts saved.

**Pass criteria:** all 3 artifacts saved and individually shareable.

**Now capture the gap evidence — these should all FAIL, and that is the point:**
- ☐ Try to group the 3 artifacts into a collection or folder → **not possible** (Gap 6)
- ☐ Try to pin them to a home screen visible to all agent users → **not possible** (Gap 1)
- ☐ Try to share all 3 at once, or set role-based visibility → **not possible, link-only** (Gap 4)

Screenshot each dead end.

---

### Part 11 — Automations via CoWork Chat (💬)

**11.1** Type: `Send me the overnight credit rating actions every weekday at 6 AM`
**11.2** Confirm the schedule when CoWork prompts.
**11.3** Check the **Automations** list and confirm the entry exists with the right cadence.
**11.4** Create a second one from a skill: `Run /muni-watchlist every Monday morning and email me the results`
**11.5** If the UI offers **Run now**, trigger it and confirm you receive the email with a link to the output.

**Pass criteria:** both automations are created and listed with correct schedules. Email delivery depends on your account's notification setup — if no email arrives, verify the automation ran successfully in its run history before calling it a failure.

**11.6 — Cleanup:** delete both test automations so they do not fire during the live demo.

---

### Part 12 — Scheduled Tasks / DAILY_REPORTS (🖥️ SQL)

The 6 `TASK_*_DAILY` tasks are the **backend** report generator (separate from CoWork Automations). They write text snapshots into `DAILY_REPORTS` so the agent can answer "what was in yesterday's rating watch?".

**12.1 — Current state (as of this guide's last verification, this is `0`):**

```sql
SELECT COUNT(*) AS report_rows FROM CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS;
```

**12.2 — Do not wait for 6 AM ET. Force each task to run now:**

```sql
USE WAREHOUSE CREDIT_INTEL_WH;
EXECUTE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_RATING_WATCH_DAILY;
EXECUTE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_MACRO_RATES_DAILY;
EXECUTE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_MUNI_WATCHLIST_DAILY;
EXECUTE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_COMPLIANCE_DAILY;
EXECUTE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_FUND_FLOWS_DAILY;
EXECUTE TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_NEW_ISSUES_DAILY;
```

**12.3 — Confirm all 6 succeeded (wait ~30s first):**

```sql
SELECT name, state, scheduled_time, error_message
FROM TABLE(CREDIT_INTELLIGENCE_DB.INFORMATION_SCHEMA.TASK_HISTORY(
       SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())))
WHERE name LIKE 'TASK_%_DAILY'
ORDER BY scheduled_time DESC;
```

**Pass criteria:** 6 rows with `state = SUCCEEDED` and `error_message = NULL`.

**12.4 — Confirm the report content landed:**

```sql
SELECT report_date, report_type, LEFT(report_content, 200) AS preview
FROM CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS
ORDER BY report_date DESC, report_type;
```

**Pass criteria:** 6 rows, one per report type, each with readable report text.

**12.5** 💬 Back in CoWork, ask: `What was in today's rating watch report?`
**Pass criteria:** the agent reads from `DAILY_REPORTS` rather than recomputing — this closes the loop between the task backend and the agent.

**Known gotcha:** several tasks filter on the **last 1–7 days** of data (e.g. `RATING_WATCH` uses `EVENT_DATE >= DATEADD(day, -1, CURRENT_DATE())`). Because the demo data was generated in September 2026, a task may legitimately insert a row that says "No rating actions in the last 24 hours." That is a **data recency** artifact, not a task failure — the task still succeeded. To get non-empty content, refresh the demo data dates.

---

### Part 13 — Usage / Prompt Analytics (🖥️ SQL)

Run these **after** Parts 3–9, so there is usage to report on.

```sql
SELECT * FROM CREDIT_INTELLIGENCE_DB.MAIN.DAILY_USAGE_TREND
ORDER BY usage_date DESC LIMIT 30;

SELECT * FROM CREDIT_INTELLIGENCE_DB.MAIN.AGENT_USAGE_ANALYTICS
ORDER BY 1 DESC LIMIT 50;
```

**Pass criteria:** both return rows covering today, with request counts reflecting your test session.

**Expected limitation (this is Gap 3):** neither view exposes the actual prompt text — `CORTEX_AGENT_USAGE_HISTORY` has no `FIRST_USER_MESSAGE` column, so you can count requests but cannot rank prompts by frequency. Confirm this yourself:

```sql
DESCRIBE VIEW SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY;
```

**Pass criteria for the gap:** no prompt-text column present. Screenshot for the product-team report.

> `ACCOUNT_USAGE` views have a latency of up to ~3 hours. If today's rows are missing, wait and re-run before treating it as a failure.

---

### Part 14 — Gap Evidence Checklist (🗂️ screenshots)

By the end of the walkthrough you should have collected:

| Gap | Screenshot needed | Captured in |
|-----|------------------|-------------|
| Gap 1 — No customizable home screen | CoWork landing screen (blank / recent conversations, no pinned cards) | Part 2 + 10 |
| Gap 2 — No skill categories | `+` → Skills flat list of all 8 | Part 8.3 |
| Gap 3 — No prompt ranking | `DESCRIBE VIEW` output with no prompt-text column | Part 13 |
| Gap 4 — No account-wide artifact sharing | Share dialog showing link-only option | Part 10.5 |
| Gap 5 — Limited interactivity | Conversation view — no clickable prompt cards after the first turn | Part 3 |
| Gap 6 — No artifact collections | Artifacts tab with 3 ungroupable artifacts | Part 10.6 |

Compare each against `ref/20260903 invesco ui mock up screen shot.png` to show the target-state delta.

---

### Post-Test Cleanup

```sql
-- Remove test report rows (optional — keeps the demo clean)
DELETE FROM CREDIT_INTELLIGENCE_DB.MAIN.DAILY_REPORTS WHERE report_date = CURRENT_DATE();

-- Suspend tasks if you don't want them firing between now and the demo
ALTER TASK CREDIT_INTELLIGENCE_DB.MAIN.TASK_RATING_WATCH_DAILY SUSPEND;
-- ...repeat for the other 5, or re-run automation_tasks.sql to restore RESUME state
```

Also: 🗂️ delete the test artifacts from Part 10 and the test automations from Part 11.6 so the demo environment starts clean.

### If Something Fails

Use this to localize the failure before debugging:

| Symptom | Failing layer | Go to |
|---------|--------------|-------|
| Part 1 fails | Deployment — objects missing or wrong | Re-run the Phase 1 deployment; see Implementation Report |
| Part 1 passes, Part 2 fails | RBAC / CoWork enablement | Check role grants on the agent |
| Part 4 fails but Part 5 works | Semantic view | `CREDIT_INTELLIGENCE_SV` definition |
| Part 5 fails but Part 4 works | Cortex Search | `RESEARCH_SEARCH` index state (step 1.3) |
| Part 6 fails | `data_to_chart` tool | Ask a data question first (see Part 6 constraint) |
| Part 8 fails for one skill only | That skill's SKILL.md | Re-upload it (see *For Developers / Admins*) |
| Part 8 fails for all skills | Stage or agent attachment | Steps 1.4 and 1.5 |
| Part 12 fails | Task privileges | Needs `EXECUTE TASK`; check `SHOW TASKS` state |
| Part 13 returns nothing | `ACCOUNT_USAGE` latency | Wait up to 3 hours |

The Troubleshooting table below covers individual error messages in more detail.

---

## Troubleshooting

| Issue | Likely Cause | Fix |
|-------|-------------|-----|
| "No data found for issuer X" | Issuer not in demo dataset (only 20 issuers) | Try Apple, Ford, JPMorgan, Pfizer, CVS Health, Tesla, etc. |
| Search results seem stale | Cortex Search Service still indexing (can take 5-15 min after creation) | Wait and retry; check `SHOW CORTEX SEARCH SERVICES` for status |
| Skill not triggering | Phrasing doesn't match skill description | Type `/rating-watch` explicitly or check available skills via `+` menu |
| Chart doesn't render | `data_to_chart` requires tabular data from `credit_analyst` first | Ask a data question first, then ask for a chart |
| Task not running | Tasks require `EXECUTE TASK` privilege | Confirm role has the privilege; check `SHOW TASKS` state = `started` |

---

## Data Reference

### Available Issuers in Demo Data

| Ticker | Issuer Name | Sector | S&P Rating | Outlook |
|--------|------------|--------|-----------|---------|
| AAPL | Apple Inc. | Technology | AA+ | Stable |
| MSFT | Microsoft Corp | Technology | AAA | Stable |
| JPM | JPMorgan Chase | Financials | A+ | Stable |
| F | Ford Motor Co | Consumer Discretionary | BB+ | Positive |
| PFE | Pfizer Inc | Healthcare | A | Negative |
| XOM | Exxon Mobil | Energy | AA− | Stable |
| AMZN | Amazon.com Inc | Technology | AA | Stable |
| TSLA | Tesla Inc | Consumer Discretionary | BB | Positive |
| MRK | Merck & Co | Healthcare | A+ | Stable |
| DAL | Delta Air Lines | Industrials | BB− | Stable |
| CVS | CVS Health | Healthcare | BBB | Negative |
| GS | Goldman Sachs | Financials | A+ | Stable |
| CMCSA | Comcast Corp | Communication Services | BBB+ | Stable |
| CAT | Caterpillar Inc | Industrials | A | Stable |
| CCL | Carnival Corp | Consumer Discretionary | B+ | Positive |
| BAX | Baxter International | Healthcare | BBB− | Negative |
| AAL | American Airlines | Industrials | B | Stable |
| KHC | Kraft Heinz | Consumer Staples | BB+ | Stable |
| WFC | Wells Fargo | Financials | BBB+ | Stable |
| VZ | Verizon Comms | Communication Services | BBB+ | Stable |

### Available Research Documents

| Doc ID | Title | Type |
|--------|-------|------|
| DOC001 | Apple Inc. Credit Update Q3 2026 | CREDIT_REPORT |
| DOC002 | Healthcare Sector Credit Outlook H2 2026 | SECTOR_ANALYSIS |
| DOC003 | Ford Motor Co. Rating Upgrade to BB+ | RATING_ACTION |
| DOC004 | Morning Credit Brief | MARKET_COMMENTARY |
| DOC005 | Investment Policy Statement — Credit Risk Guidelines | COMPLIANCE_POLICY |
| DOC006 | Carnival Corp — Credit Upgrade to B+ | RATING_ACTION |
| DOC007 | Q3 2026 Credit Market Outlook: Navigating the Late Cycle | SECTOR_ANALYSIS |

---

## For Developers / Admins

### Re-deploying or Updating Skills

To update a skill, edit the local `SKILL.md` file and re-upload:

```bash
snow stage copy Agent/skills/rating-watch/SKILL.md \
  @CREDIT_INTELLIGENCE_DB.MAIN.AGENT_SKILLS_STAGE/rating-watch/ \
  --connection wl_sandbox --overwrite
```

The agent reads SKILL.md files at request time — no agent restart needed.

### Adding New Research Documents

```sql
INSERT INTO CREDIT_INTELLIGENCE_DB.MAIN.RESEARCH_DOCUMENTS
VALUES ('DOC008', 'New Report Title', 'CREDIT_REPORT', 'Sector', 'Issuer', CURRENT_DATE(), 'Author', '...content...');
-- The Cortex Search Service re-indexes within TARGET_LAG (1 hour)
```

### Checking Agent Description (Skills Attached)

```sql
DESCRIBE AGENT CREDIT_INTELLIGENCE_DB.MAIN.CREDIT_INTELLIGENCE_AGENT;
```

### Querying Usage History

```sql
SELECT * FROM CREDIT_INTELLIGENCE_DB.MAIN.DAILY_USAGE_TREND
ORDER BY usage_date DESC
LIMIT 30;
```

### Snowflake Object Locations

| Object | Full Path |
|--------|-----------|
| Agent | `CREDIT_INTELLIGENCE_DB.MAIN.CREDIT_INTELLIGENCE_AGENT` |
| Semantic View | `CREDIT_INTELLIGENCE_DB.MAIN.CREDIT_INTELLIGENCE_SV` |
| Search Service | `CREDIT_INTELLIGENCE_DB.MAIN.RESEARCH_SEARCH` |
| Skills Stage | `@CREDIT_INTELLIGENCE_DB.MAIN.AGENT_SKILLS_STAGE` |
| Warehouse | `CREDIT_INTEL_WH` |

---

*CoWork Gaps Project — Credit Investment Intelligence Demo*  
*wl_sandbox account: SFPSCOGS-WLIN_AWS_W2*  
*Generated by Cortex Code | September 11, 2026 · Test walkthrough added September 14, 2026*
