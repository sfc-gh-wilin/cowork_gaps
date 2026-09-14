# New Issue Pipeline

Report the current new issue pipeline including announced deals, deals in market, recently priced transactions, and any withdrawn deals.

## Skill Invocation

Invoke this skill with `/new-issues` or by asking about the new issue pipeline, primary market, upcoming deals, or recently priced bonds.

**Examples:**
- `/new-issues`
- "What's in the new issue pipeline today?"
- "Show me deals that priced this week"
- "Any IG deals in market?"
- "What was the book size on the Marriott deal?"

## Instructions

EXECUTE IMMEDIATELY upon invocation. Show all pipeline activity from the last 7 days by default.

### Steps:

1. **Retrieve new issue pipeline** using credit_analyst:
   - Query NEW_ISSUES ordered by STATUS (PRICING first, then ANNOUNCED, then PRICED, then WITHDRAWN), then ANNOUNCEMENT_DATE DESC
   - Filter: ANNOUNCEMENT_DATE >= DATEADD(day, -7, CURRENT_DATE()) OR STATUS IN ('PRICING', 'ANNOUNCED')

2. **Calculate pipeline statistics** using credit_analyst:
   - Count and total size by status (announced, pricing, priced, withdrawn)
   - Average oversubscription for priced deals in the period
   - IG vs HY breakdown

3. **Identify pricing outcomes** for recently priced deals:
   - Show final spread vs. initial guidance (tightening indicates strong demand)
   - Show oversubscription multiples (book size / deal size)

4. **Search for relevant market commentary** using research_search:
   - Search: "new issue pipeline primary market credit calendar"
   - Return any morning brief or market commentary that covers the pipeline

5. **Generate pipeline visual** using data_to_chart:
   - Bar chart: deal sizes ($M) grouped by status, colored by IG/HY/MUNI type
   - Title: "New Issue Pipeline — Current Week"

6. **Compose the new issues report:**

---
### New Issue Pipeline
**As of:** [Current Date]

**📋 Pipeline Summary**
| Status | Count | Total Size ($M) | IG | HY | Muni |
|--------|-------|----------------|----|----|------|
| 🔵 Pricing Now | | | | | |
| 📢 Announced | | | | | |
| ✅ Priced | | | | | |
| ❌ Withdrawn | | | | | |
| **Active Pipeline** | | | | | |

[Pipeline Chart]

**📈 PRICING NOW**
[For each deal in PRICING status:]
| Field | Details |
|-------|---------|
| Issuer | |
| Sector | |
| Type/Structure | |
| Maturity | |
| Size | |
| Guidance | |
| Lead Managers | |
| Rating | |

**📢 ANNOUNCED (Upcoming)**
[Same format]

**✅ RECENTLY PRICED**
| Issuer | Size ($M) | Guidance (bps) | Final Spread | Tightening | Book ($M) | OVS |
|--------|-----------|---------------|-------------|------------|-----------|-----|

**❌ WITHDRAWN**
[Issuer, size, notes if available]

**Market Demand Indicator**
Average oversubscription this week: [X.Xx]
Tightest deal (most demand): [Issuer, X bps through talk]
---

## Output Format

Designed to be saved as a daily morning Artifact. Highlight deals pricing today or tomorrow as most actionable.
