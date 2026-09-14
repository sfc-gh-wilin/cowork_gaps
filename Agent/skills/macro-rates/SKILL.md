# Macro & Rates Snapshot

Summarize the current macro environment, key rate movements, and credit index levels with daily change analysis.

## Skill Invocation

Invoke this skill with `/macro-rates` or by asking about interest rates, Treasury yields, macro indicators, or credit index levels.

**Examples:**
- `/macro-rates`
- "Show me the macro and rates snapshot"
- "What are Treasury yields doing today?"
- "Give me the current macro picture"
- "CDX levels?"

## Instructions

EXECUTE IMMEDIATELY upon invocation. Do not ask clarifying questions — deliver the full snapshot.

### Steps:

1. **Retrieve today's macro and rates data** using credit_analyst:
   - Query MACRO_RATES WHERE RATE_DATE = CURRENT_DATE() (or most recent available date)
   - Include all indicators across RATES, MACRO, and CREDIT_INDICES categories

2. **Retrieve yesterday's data for comparison** using credit_analyst:
   - Query MACRO_RATES WHERE RATE_DATE = DATEADD(day, -1, CURRENT_DATE())
   - Calculate day-over-day changes

3. **Build the Treasury yield curve** using data_to_chart:
   - Line chart: 2Y, 5Y, 10Y, 30Y Treasury yields
   - Show today's curve vs. 1 month ago (use historical data from MACRO_RATES)
   - Title: "US Treasury Yield Curve"

4. **Build credit spread index chart** using data_to_chart:
   - Bar/line chart: CDX IG 5Y, CDX HY 5Y, IG Corp OAS, HY Corp OAS
   - Show current vs. 1-week-ago levels

5. **Search for market commentary** using research_search:
   - Search: "morning credit brief rates macro"
   - Return the most recent market commentary document

6. **Compose the snapshot:**

---
### Macro & Rates Snapshot
**As of:** [Date] [Time]

**📊 US Treasury Yields**
| Tenor | Today | Chg (bps) | Direction |
|-------|-------|-----------|-----------|
| 2Y | | | |
| 5Y | | | |
| 10Y | | | |
| 30Y | | | |
| 2Y-10Y Spread | | | |

[Yield Curve Chart]

**💹 Credit Indices**
| Index | Level | Day Chg | Direction |
|-------|-------|---------|-----------|
| CDX IG 5Y | | | |
| CDX HY 5Y | | | |
| IG Corp OAS | | | |
| HY Corp OAS | | | |
| MUNI 10Y/UST Ratio | | | |

[Credit Indices Chart]

**📈 Key Macro Indicators**
| Indicator | Current | Prior | Change |
|-----------|---------|-------|--------|
| Fed Funds Rate | | | |
| US CPI YoY | | | |
| US Core PCE YoY | | | |
| US GDP QoQ | | | |
| US Unemployment | | | |
| USD Index (DXY) | | | |

**🗒️ Market Commentary Highlights**
[Key excerpt from most recent morning brief or market commentary]

**Rate Outlook**
Fed funds futures pricing: [implied rate path narrative from commentary if available]
---

## Output Format

Deliver as a compact, information-dense snapshot. Use directional arrows (↑↓→) for changes.
This report is designed to be saved as a daily refreshable Artifact in CoWork.
