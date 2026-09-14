# Issuer Deep Dive

Generate a comprehensive credit profile for a single issuer, including rating history, portfolio exposure, spread trends, and relevant research.

## Skill Invocation

Invoke this skill with `/issuer-deep-dive [issuer name]` or by asking for a credit profile, deep dive, or full analysis of a specific company.

**Examples:**
- `/issuer-deep-dive Ford Motor`
- `/issuer-deep-dive Apple`
- "Give me a deep dive on Pfizer"
- "Full credit profile for JPMorgan"

## Instructions

EXECUTE IMMEDIATELY upon invocation. If an issuer name is provided, use it. If none is provided, ask: "Which issuer would you like to deep dive? (e.g., Ford Motor, Apple, Pfizer)"

### Steps:

1. **Retrieve issuer master data** using credit_analyst:
   - Query ISSUERS table for the named issuer (use fuzzy matching on ISSUER_NAME)
   - Get: ratings (S&P, Moody's, Fitch), outlook, sector, subsector, country

2. **Retrieve rating history** using credit_analyst:
   - Query RATING_HISTORY for all events for this issuer, ordered by EVENT_DATE DESC
   - Show last 12 months of rating actions

3. **Retrieve spread trend** using credit_analyst:
   - Query CREDIT_SPREADS for the issuer, last 60 days
   - Calculate: current spread, 30-day avg, 60-day avg, min, max for the period

4. **Retrieve portfolio exposure** using credit_analyst:
   - Query PORTFOLIO_HOLDINGS for current holdings in all portfolios
   - Show: portfolio name, face value, market value, weight %, duration, current spread

5. **Search for relevant research** using research_search:
   - Search for the issuer name + "credit" + "rating"
   - Return top 3 most relevant documents with titles and key excerpts

6. **Generate a spread trend chart** using data_to_chart:
   - Line chart: credit spread (bps) over last 60 days
   - Annotate rating change dates on the chart if any occurred in the period

7. **Compose the deep dive report** with these sections:

---
### [ISSUER NAME] — Credit Deep Dive
**As of:** [Current Date]

**Credit Profile**
| Metric | Value |
|--------|-------|
| S&P Rating | |
| Moody's Rating | |
| Fitch Rating | |
| Outlook | |
| Sector | |
| IG / HY | |

**Rating History (Last 12 Months)**
[Table of rating events]

**Credit Spread Trend**
[Chart] + [Table: Current / 30D Avg / 60D Avg / 60D Range]

**Portfolio Exposure**
[Table of holdings across all funds]

**Recent Research & Coverage**
[List of top 3 research documents with 1-sentence summaries]

**Key Risks**
[Brief bullet points from research_search results]
---

## Output Format

Deliver as a clean, structured report that can be saved as an Artifact in CoWork.
The report should be self-contained and readable without needing to ask follow-up questions.
