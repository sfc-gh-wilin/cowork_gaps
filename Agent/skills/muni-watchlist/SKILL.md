# Muni Watchlist

Report current municipal bond watchlist changes, including issuers placed on positive, negative, or developing watch, with risk assessment and portfolio impact.

## Skill Invocation

Invoke this skill with `/muni-watchlist` or by asking about municipal bond watchlist changes, muni credit risk, or GO/revenue bond alerts.

**Examples:**
- `/muni-watchlist`
- "Show me muni watchlist changes"
- "Any municipal bonds on negative watch?"
- "What's the current muni credit risk picture?"

## Instructions

EXECUTE IMMEDIATELY upon invocation. Do not ask clarifying questions — show the full current watchlist.

### Steps:

1. **Retrieve full muni watchlist** using credit_analyst:
   - Query MUNI_WATCHLIST ordered by WATCH_TYPE (NEGATIVE first, then DEVELOPING, then POSITIVE), then DAYS_ON_WATCH DESC
   - Include all columns

2. **Cross-reference portfolio holdings** using credit_analyst:
   - For each CUSIP in the watchlist, check if it appears in PORTFOLIO_HOLDINGS (PORT_MUNI)
   - Flag portfolio holdings that are on the watchlist

3. **Calculate portfolio impact**:
   - Sum MARKET_VALUE of portfolio holdings on the watchlist
   - Show as % of total PORT_MUNI market value
   - Separate by watch type (negative/positive/developing)

4. **Generate watchlist summary chart** using data_to_chart:
   - Horizontal bar chart: issuers by days on watch, color-coded by watch type
   - Red = NEGATIVE, Green = POSITIVE, Yellow = DEVELOPING

5. **Compose the watchlist report:**

---
### Municipal Bond Watchlist
**As of:** [Current Date]

**⚠️ Summary**
| Watch Type | Count | Portfolio Exposure |
|-----------|-------|-------------------|
| 🔴 Negative Watch | | |
| 🟡 Developing Watch | | |
| 🟢 Positive Watch | | |
| **Total** | | |

**Watchlist Detail**
| Issuer | State | Type | Rating | Watch | Days | Reason | In Portfolio |
|--------|-------|------|--------|-------|------|--------|-------------|

**Portfolio Exposure to Watchlist Names**
[Table: CUSIP, Description, Market Value, Weight %, Watch Type]

**Risk Assessment**
- Total portfolio exposure to negative-watch names: $X.XM (X.X% of muni fund)
- Highest risk: [Issuer] — [brief reason]
- Recommended actions: [any positions approaching compliance limits]

[Chart: Days on Watch by Issuer]
---

### Key Monitoring Points

For **NEGATIVE** watch names: review holdings against IPS minimum rating threshold (BBB+/Baa1 for PORT_MUNI). Any downgrade below threshold triggers a compliance alert.

For **DEVELOPING** watch names: outcome is binary — treat as elevated risk until resolved.

## Output Format

Return results as a structured report. Highlight any portfolio holdings that are on NEGATIVE watch in red/bold.
