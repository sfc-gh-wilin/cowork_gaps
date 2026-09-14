# Compliance Check

Surface all active compliance alerts across portfolios, classify by severity, and provide required action timelines per the Investment Policy Statement.

## Skill Invocation

Invoke this skill with `/compliance-check` or by asking about compliance alerts, portfolio breaches, IPS violations, or required actions.

**Examples:**
- `/compliance-check`
- "Show me compliance alerts"
- "Any IPS violations I need to know about?"
- "What compliance actions are outstanding?"

## Instructions

EXECUTE IMMEDIATELY upon invocation. Do not ask clarifying questions — show all open and recently resolved alerts.

### Steps:

1. **Retrieve all OPEN compliance alerts** using credit_analyst:
   - Query COMPLIANCE_ALERTS WHERE STATUS = 'OPEN'
   - Order by SEVERITY (HIGH first, then MEDIUM, then LOW), then ALERT_DATE DESC

2. **Retrieve ACKNOWLEDGED alerts** (in progress):
   - Query COMPLIANCE_ALERTS WHERE STATUS = 'ACKNOWLEDGED'
   - Include who acknowledged and when

3. **Retrieve RESOLVED alerts from last 7 days** (for context):
   - Query COMPLIANCE_ALERTS WHERE STATUS = 'RESOLVED' AND RESOLVED_AT >= DATEADD(day, -7, CURRENT_TIMESTAMP())

4. **Cross-reference IPS policy** using research_search:
   - Search: "Investment Policy Statement compliance limits thresholds"
   - Extract relevant limits (rating floor, concentration limits, duration bands)

5. **Generate compliance summary chart** using data_to_chart:
   - Stacked bar: open alerts by severity per portfolio
   - Color: RED=HIGH, ORANGE=MEDIUM, YELLOW=LOW

6. **Calculate action deadlines** per IPS policy:
   - HIGH severity: must resolve within **5 business days** of alert date
   - MEDIUM severity: PM review within **48 hours**, action plan within **5 business days**
   - LOW severity: monthly review

7. **Compose compliance report:**

---
### Compliance Alert Dashboard
**As of:** [Current Timestamp]

**🚨 Alert Summary**
| Severity | Open | Acknowledged | Resolved (7d) |
|----------|------|-------------|---------------|
| 🔴 HIGH | | | |
| 🟠 MEDIUM | | | |
| 🟡 LOW | | | |
| **Total** | | | |

[Compliance Chart]

**⚠️ OPEN Alerts — Action Required**

**🔴 HIGH Priority** (Action required within 5 business days)
[For each HIGH alert:]
| Field | Detail |
|-------|--------|
| Alert ID | |
| Portfolio | |
| Type | |
| Issuer | |
| Description | |
| Limit / Actual | |
| Opened | |
| **Deadline** | |

**🟠 MEDIUM Priority** (PM review within 48h)
[Same table format]

**🟡 LOW Priority** (Monthly review)
[Same table format]

**✅ Recently Resolved (Last 7 Days)**
[Brief table: alert ID, type, resolved by, resolved at]

**📋 Relevant IPS Guidelines**
[Key limits extracted from policy document]
---

## Output Format

Format as a compliance dashboard. For each open alert, include the IPS-mandated action deadline so portfolio managers know exactly what needs to happen and when.
