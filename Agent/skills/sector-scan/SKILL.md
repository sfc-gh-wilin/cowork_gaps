# Sector Scan

Compare credit spread trends, rating distributions, and portfolio exposure across a specified sector, benchmarked against prior periods.

## Skill Invocation

Invoke this skill with `/sector-scan [sector name]` or by asking for sector analysis, spread comparison, or sector-level credit view.

**Examples:**
- `/sector-scan Healthcare`
- `/sector-scan Technology`
- "Compare credit spreads in Financials this month vs last month"
- "What's the credit picture for the Energy sector?"

## Instructions

EXECUTE IMMEDIATELY upon invocation. If a sector is provided, use it. If none is provided, ask: "Which sector would you like to scan? Options: Technology, Financials, Healthcare, Energy, Consumer Discretionary, Industrials, Communication Services, Consumer Staples"

### Steps:

1. **Current period spread analysis** using credit_analyst:
   - Query CREDIT_SPREADS for the named sector for the current calendar month
   - Compute: avg spread, min spread, max spread, spread volatility (stddev), count of observations

2. **Prior period comparison** using credit_analyst:
   - Same query for the prior calendar month
   - Compute same metrics for comparison

3. **Rating distribution in sector** using credit_analyst:
   - Query ISSUERS WHERE SECTOR = [sector]
   - Group by RATING_SP, show distribution (count and % of sector)
   - Separate IG vs HY breakdown

4. **Portfolio exposure to sector** using credit_analyst:
   - Query PORTFOLIO_HOLDINGS WHERE SECTOR = [sector]
   - Group by PORTFOLIO_NAME, show total market value and weight %

5. **Recent rating actions in sector** using credit_analyst:
   - Query RATING_HISTORY WHERE ISSUER_ID IN (SELECT ISSUER_ID FROM ISSUERS WHERE SECTOR = [sector])
   - Last 30 days, all agencies

6. **Search for sector research** using research_search:
   - Search: "[sector name] sector credit outlook"
   - Return top 2 most relevant research documents

7. **Generate comparison chart** using data_to_chart:
   - Line chart: daily average spread for the sector — current month vs prior month overlay
   - Title: "[Sector] 5Y Credit Spread: This Month vs. Last Month"

8. **Compose sector scan report:**

---
### [SECTOR] Sector Scan
**As of:** [Current Date] | **vs.** Prior Month

**Spread Summary**
| Metric | This Month | Last Month | Change |
|--------|-----------|-----------|--------|
| Avg Spread (bps) | | | |
| Min Spread | | | |
| Max Spread | | | |
| Spread Volatility | | | |

**Spread Trend Chart**
[Chart]

**Rating Distribution**
[Table: rating → count → % of sector]
IG: X issuers (X%) | HY: X issuers (X%)

**Portfolio Exposure**
[Table by fund]

**Recent Rating Actions (Last 30 Days)**
[Table]

**Sector Research Highlights**
[Key findings from documents]
---

## Output Format

Deliver as a clean structured report suitable for saving as a CoWork Artifact.
