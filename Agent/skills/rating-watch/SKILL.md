# Rating Watch

Monitor and report credit rating changes, outlook revisions, and watchlist placements across all tracked issuers.

## Skill Invocation

Invoke this skill with `/rating-watch` or by asking about recent rating changes, upgrades, downgrades, or outlook revisions.

**Examples:**
- `/rating-watch`
- `/rating-watch last 3 days`
- "Show me all rating changes this week"
- "Any downgrades in Healthcare recently?"

## Instructions

EXECUTE IMMEDIATELY upon invocation. Do not ask clarifying questions — use default parameters and proceed.

### Default behavior (no parameters specified):
Report all rating and outlook actions in the **last 5 trading days**, sorted by magnitude of impact (downgrades first, then upgrades, then outlook changes).

### Steps:

1. **Query the RATING_HISTORY table** using the credit_analyst tool:
   - Filter: `EVENT_DATE >= DATEADD(day, -7, CURRENT_DATE())`
   - Include: issuer name, old rating, new rating, action type, magnitude, analyst comment, event date, agency
   - Sort: ORDER BY ABS(MAGNITUDE) DESC, EVENT_DATE DESC

2. **Format output as a structured table** with these columns:
   | Date | Issuer | Sector | Agency | Action | Rating Change | Comment |

3. **Highlight key items:**
   - 🔴 Downgrades (especially IG→HY fallen angels)
   - 🟢 Upgrades (especially HY→IG crossover candidates)
   - 🟡 Outlook changes and watchlist placements
   - ⚡ Investment grade boundary crossings (BBB-/BB+ threshold)

4. **Generate a summary chart** using data_to_chart showing:
   - Bar chart: count of actions by type (upgrade/downgrade/outlook/watch) for the period

5. **Close with a one-paragraph summary** noting:
   - Total actions in period
   - Most impactful action (largest magnitude)
   - Any investment grade crossovers
   - Sectors with elevated activity

### Optional Parameters:
- `last N days` — override lookback window (default: 5 trading days)
- `sector [name]` — filter to a specific sector
- `agency [S&P/Moodys/Fitch]` — filter by rating agency
- `downgrades only` / `upgrades only` — filter by action type

## Output Format

Return results in this order:
1. Header: "**Rating Watch** — [Date Range]"
2. Summary statistics (total actions, upgrades, downgrades, outlook changes)
3. Detailed table of all actions
4. Bar chart visualization
5. Narrative summary paragraph
