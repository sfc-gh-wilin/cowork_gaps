# Fund Flows Summary

Report fund flow data including inflows, outflows, net flows, and AUM trends across credit portfolios.

## Skill Invocation

Invoke this skill with `/fund-flows` or by asking about fund flows, AUM movements, subscriptions/redemptions, or capital allocation trends.

**Examples:**
- `/fund-flows`
- `/fund-flows IG Core`
- "Show me fund flow trends"
- "Any significant redemptions this week?"
- "AUM changes across our funds"

## Instructions

EXECUTE IMMEDIATELY upon invocation. If a specific fund is mentioned, filter to that fund. Otherwise, show all funds.

### Steps:

1. **Retrieve recent fund flow data** using credit_analyst:
   - Query FUND_FLOWS for the last 30 calendar days (business days only via DAYOFWEEK filter)
   - Include all funds unless a specific fund was named
   - Columns: flow_date, fund_name, asset_class, inflow_usd, outflow_usd, net_flow_usd, aum_usd, flow_pct_aum

2. **Calculate summary statistics** using credit_analyst:
   - Per fund: total inflows, total outflows, total net flow, current AUM, avg daily net flow, max single-day inflow, max single-day outflow
   - Across all funds: aggregate net flow for the period

3. **Identify notable flow events** using credit_analyst:
   - Flag days where |net_flow_pct_aum| > 1% as significant
   - Flag consecutive negative days (redemption pressure)

4. **Generate AUM trend chart** using data_to_chart:
   - Line chart: AUM over last 30 days, one line per fund
   - Title: "Fund AUM Trends — Last 30 Days"

5. **Generate net flow bar chart** using data_to_chart:
   - Bar chart: daily net flows by fund (grouped bars)
   - Color: green bars = positive flow, red bars = negative
   - Title: "Daily Net Fund Flows"

6. **Compose the fund flows report:**

---
### Fund Flows Summary
**Period:** [Date Range] | **As of:** [Current Date]

**📊 Flow Summary**
| Fund | Asset Class | Total Inflows | Total Outflows | Net Flow | Current AUM | Avg Daily Net |
|------|-------------|--------------|---------------|----------|-------------|--------------|
| IG Core Bond Fund | Investment Grade | | | | | |
| HY Opportunities | High Yield | | | | | |
| Municipal Bond Fund | Municipal | | | | | |
| **Total** | | | | | | |

**AUM Trend Chart**
[Chart: AUM over 30 days by fund]

**Daily Net Flow Chart**
[Chart: daily net flows]

**Notable Flow Events**
[List any days with significant flows (>1% AUM), or consecutive redemption days]

**Flow Interpretation**
[Brief narrative: Is IG seeing inflows while HY sees outflows? Rotation? Trend acceleration?]
---

## Output Format

Designed to be saved as a daily refreshable Artifact. Note significant deviations from normal flow patterns in the interpretation section.
