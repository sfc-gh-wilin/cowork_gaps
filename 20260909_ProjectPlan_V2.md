# CoWork Gaps: Project Plan V2

> **Guiding principle:** Building a custom app is **tech debt**. CoWork can and should have all these features natively. Our job is to push CoWork as far as it goes today, identify the real gaps, and feed those gaps back to product.

**Team:** Daniel Sandler (Lead/Architect), Jake Neal (Customer Requirements / Invesco), Stephanie Higa (Development), William Lin (Development)

**Slack Channel:** IntSD Chatbot Offering

---

## 1. Strategy: Work With CoWork, Not Around It

Instead of building a custom chatbot app, we:

1. **Configure** a Cortex Agent with the right tools, skills, and instructions
2. **Deploy** it through CoWork as the front-end (no custom UI)
3. **Extend** CoWork using its native extension points (agent skills, user skills, automations, artifacts)
4. **Document** the remaining gaps where CoWork falls short of customer expectations
5. **Deliver** that gap report to the CoWork product team as a roadmap input

---

## 2. Jake's Gaps vs. CoWork Today

| # | Gap (Jake Neal) | CoWork Feature Today | Status | Action |
|---|-----------------|---------------------|--------|--------|
| 1 | **Chart visualizations / markdown** | `data_to_chart` tool + `code_execution` tool (matplotlib, plotly). CoWork renders interactive charts and tables with sort/filter/resize. | **Available (GA)** | Enable both tools on the agent. No custom work needed. |
| 2 | **Citations** | Cortex Search tool returns source citations automatically. CoWork displays them inline in responses. | **Available (GA)** | Configure `cortex_search` tool with `title_column`, `id_column`, and `columns_and_descriptions`. |
| 3 | **Tool output formatting** | CoWork natively formats SQL results as tables, search results with citations, and chart outputs. | **Available (GA)** | Use `instructions.response` to guide formatting preferences. No custom work needed. |
| 4 | **Chat state / Thread API** | Thread API provides full conversation history, branching, compaction/summarization, and persistence. CoWork manages threads automatically. | **Available (GA)** | No custom work needed -- CoWork handles this natively. |
| 5 | **Interactivity / input processing** | Text input, `/skill` invocation, `+` menu for skills. No buttons, forms, or structured inputs. | **Partial -- Gap remains** | See Gap Analysis below. |
| 6 | **Streaming responses** | SSE streaming enabled by default on all agent:run calls. CoWork streams responses to the UI. | **Available (GA)** | No custom work needed. |

### Invesco-Specific Features

| # | Feature | CoWork Feature Today | Status | Action |
|---|---------|---------------------|--------|--------|
| 7 | **Standard Prompts** (categorized, ranked by frequency/quality) | `sample_questions` in agent spec (static starter questions shown in UI). User Skills (repeatable workflows invoked via `/` or natural language). | **Partially available** | Use `sample_questions` for onboarding. Build User Skills for each standard prompt template (Rating Watch, Issuer Deep Dive, Sector Scan, etc.). |
| 8 | **Shared Artifacts** (pinned reports on home screen) | Artifacts (GA): save charts/tables, share via link, auto-refresh on view, RBAC-enforced. Shared tab in artifacts hub. | **Partially available -- Gaps remain** | Use Artifacts + Automations for recurring reports. See Gap Analysis below. |

---

## 3. Implementation Plan: What We Build (Within CoWork)

### Phase 1: Agent Configuration

Configure a Cortex Agent that maximizes CoWork's native capabilities.

**Agent Specification:**

```yaml
models:
  orchestration: auto

instructions:
  response: |
    You are a Credit Investment Intelligence assistant.
    Provide concise, data-driven answers with source citations.
    When presenting data, prefer charts and tables.
    Always cite the source document or data table.
  orchestration: |
    For structured data questions (portfolio, ratings, trades), use Analyst.
    For document/policy/research questions, use Search.
    For calculations or custom visualizations, use code execution.
  sample_questions:
    - question: "List all issuers with a rating or outlook change in the last 5 trading days, sorted by magnitude of impact."
    - question: "Summarize the latest credit profile, leverage trend, and rating history for [Issuer Name]."
    - question: "Compare average credit spreads for the Healthcare sector this month vs. last month."
    - question: "What are today's overnight credit rating actions?"
    - question: "Show me the real-time credit risk dashboard."

tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: credit_analyst
      description: "Analyzes structured credit, portfolio, and trading data"
  - tool_spec:
      type: cortex_search
      name: research_search
      description: "Searches credit research, rating reports, and compliance documents"
  - tool_spec:
      type: data_to_chart
      name: data_to_chart
      description: "Generates charts and visualizations from query results"
  - tool_spec:
      type: code_execution
      name: code_execution

tool_resources:
  credit_analyst:
    semantic_view: "<db>.<schema>.<semantic_view>"
  research_search:
    search_service: "<db>.<schema>.<search_service>"
    max_results: "10"
    title_column: "title"
    id_column: "doc_id"
    columns_and_descriptions:
      content:
        description: "Full text of the research document"
        type: "string"
        searchable: true
        filterable: false
  code_execution:
    artifact_repositories:
      - SNOWFLAKE.SNOWPARK.PYPI_SHARED_REPOSITORY
```

**Tasks:**
1. Create Semantic View(s) over credit/portfolio/rating data
2. Create Cortex Search Service over research documents
3. Create Agent with the specification above
4. Configure `sample_questions` matching Invesco's "Standard Prompts" categories
5. Deploy to CoWork with display name, avatar, and color
6. Test all 6 core features (charts, citations, formatting, threads, streaming, interactivity)

---

### Phase 2: User Skills (Standard Prompt Templates)

CoWork User Skills (Preview, Aug 2026) replace the need for a custom "Standard Prompts" sidebar. Each skill is a reusable workflow invoked via `/skill-name` or natural language.

**Skills to create:**

| Skill Name | Maps to Invesco Mockup | What It Does |
|------------|----------------------|--------------|
| `/rating-watch` | "RATING WATCH" card | List all issuers with rating/outlook changes in last N trading days, sorted by impact magnitude |
| `/issuer-deep-dive` | "ISSUER DEEP DIVE" card | Summarize credit profile, leverage trend, rating history for a given issuer |
| `/sector-scan` | "SECTOR SCAN" card | Compare average credit spreads for a sector, this month vs. last month |
| `/muni-watchlist` | "Muni Watchlist Changes" artifact | Show municipal bond watchlist changes |
| `/macro-rates` | "Macro & Rates Snapshot" artifact | Summarize current macro environment and key rate movements |
| `/compliance-check` | "Compliance Alerts" artifact | Surface any compliance alerts or policy violations |
| `/fund-flows` | "Fund Flows Summary" artifact | Summarize fund flow data |
| `/new-issues` | "New Issue Pipeline" artifact | Show new issue pipeline status |

**How to create:** Users can create these conversationally in CoWork, or developers can author SKILL.md files and attach them to the agent via a stage or Git repo.

**Tasks:**
1. Author SKILL.md files for each standard prompt template
2. Upload to a Snowflake stage or Git repo
3. Attach skills to the agent specification
4. Test invocation via `/` command and natural language matching
5. Document the skill library for Invesco users

---

### Phase 3: Shared Artifacts via Automations

CoWork Artifacts (GA) + Automations (Preview) together cover most of the "shared artifacts" need:

- **Artifacts** = saved charts/tables that auto-refresh and can be shared via link
- **Automations** = scheduled recurring reports delivered by email with a link back to CoWork

**Workflow for each "shared artifact":**

1. Run the skill/query that produces the report (e.g., `/rating-watch`)
2. Save the resulting chart/table as an Artifact
3. Share the Artifact link with the team
4. Optionally, create an Automation to re-run the report on a schedule (e.g., "Send me the overnight credit rating actions every weekday at 6 AM")

**Artifacts to set up (matching Invesco mockup):**

| Artifact | Source Skill/Query | Refresh Cadence |
|----------|-------------------|-----------------|
| Last IST Meeting Summary | Manual or automation | After each IST meeting |
| Overnight Credit Rating Actions | `/rating-watch` | Daily, 6:00 AM |
| Real-Time Credit Risk Dashboard | Analyst query | On-view auto-refresh |
| New Issue Pipeline | `/new-issues` | Daily, 7:15 AM |
| Muni Watchlist Changes | `/muni-watchlist` | Daily, 6:30 AM |
| Macro & Rates Snapshot | `/macro-rates` | Daily, 6:00 AM |
| Compliance Alerts | `/compliance-check` | Daily, 5:50 AM |
| Fund Flows Summary | `/fund-flows` | Daily, 5:00 PM |

**Tasks:**
1. Run each skill and save the output as an Artifact
2. Share Artifact links with the team (link-based sharing)
3. Set up Automations for reports that need scheduled refresh
4. Document the artifact/automation setup for Invesco admins

---

### Phase 4: Prompt Library (Daniel's Vision)

Daniel's idea: collect every prompt/response, classify them, and surface the best ones. This can be partially achieved today:

**What's available:**
- `CORTEX_AGENT_USAGE_HISTORY` view -- captures all agent interactions (but not CoWork interactions, which go to `SNOWFLAKE_COWORK_USAGE_HISTORY`)
- Agent Observability pane -- lists each conversation thread with first input, feedback, thread length, user, last updated
- User Skills -- can be created from successful conversations ("Create a skill from this")

**What we can do without a custom app:**
1. Use `SNOWFLAKE_COWORK_USAGE_HISTORY` to analyze prompt patterns
2. Build an Agent Skill or automation that periodically:
   - Queries usage history
   - Uses `AI_CLASSIFY` to categorize prompts
   - Identifies high-frequency, high-quality prompts
   - Recommends new User Skills to create
3. Manually promote the best prompts into `sample_questions` or User Skills

**What requires a gap filing (see Section 5):**
- Automated prompt-to-skill promotion
- Frequency/quality scoring visible in the UI
- Category-based organization of skills in CoWork

---

## 4. Due Diligence Checklist

Daniel asked us to verify what exists in adjacent platforms:

| Platform | What to Check | Finding |
|----------|--------------|---------|
| **CoWork** | Artifacts, User Skills, Automations, sample_questions | All available (GA or Preview). See mapping above. |
| **Cortex Agent API** | Streaming, Thread API, citations, tool output | All available (GA). SSE streaming default, Thread API full-featured. |
| **AI Gateway (Natoma)** | Request logging, response caching, rate limiting | Check if Natoma adds any observability beyond agent usage views. |
| **Observe** | Prompt logging, classification, quality scoring | Agent Observability pane exists. Usage history views available. Check depth. |
| **Code Execution** | Chart generation, data processing, document gen | Available (Preview). Python sandbox with numpy, pandas, matplotlib, plotly. |
| **Document Generation** | PDF/PowerPoint creation | Available (Preview). Can generate decks and briefs from conversation context. |

**Tasks:**
1. Validate each finding against a live Snowflake account
2. Test AI Gateway / Natoma for any additional observability
3. Confirm Observe covers enough for prompt analysis
4. Document results

---

## 5. Gap Analysis: What CoWork Cannot Do Today

These are the **real gaps** to report to the CoWork product team:

### Gap 1: No Customizable Home Screen / Pinned Artifacts

**What Invesco wants:** A landing page with pinned artifact cards (like the mockup shows 8 artifacts in a grid with icons and timestamps).

**What CoWork has:** An Artifacts hub with "Saved" and "Shared with me" tabs. No ability to customize a home/landing screen, pin artifacts for a team, or arrange artifacts in a grid layout.

**Impact:** High. This is the most visible gap between the Invesco mockup and CoWork's current UX.

**Recommendation to product:** Support a customizable home screen or "dashboard" view in CoWork where admins can pin shared artifacts for all users of an agent.

---

### Gap 2: No Categorized Skill Organization

**What Invesco wants:** Standard Prompts organized by category (Credit Research, Portfolio, Risk) with counts, in a sidebar.

**What CoWork has:** User Skills are listed flat under `+` > Skills or via `/`. No categories, folders, or grouping. Agent `sample_questions` appear as starter cards but have no category structure.

**Impact:** Medium. Skills exist but lack organization for large skill libraries.

**Recommendation to product:** Support skill categories or folders in the CoWork skills menu and sample_questions UI.

---

### Gap 3: No Prompt Frequency / Quality Ranking

**What Invesco wants:** Prompts surfaced by how often they're used and how well they perform (Daniel's "frequency and quality" vision).

**What CoWork has:** Usage history views exist but there's no built-in mechanism to rank prompts and auto-surface them as suggestions or skills.

**Impact:** Medium. Can be approximated with manual analysis + skill creation, but not automated.

**Recommendation to product:** Auto-suggest skill creation from high-frequency, high-feedback prompts. Surface "trending" or "popular" prompts in the CoWork UI.

---

### Gap 4: No Account-Wide Artifact Sharing / Pinning

**What Invesco wants:** Shared artifacts visible to all users by default (like a team dashboard).

**What CoWork has:** Link-based sharing only. No user-level sharing permissions. No ability to pin artifacts for all users of an agent or role. Known limitation: "No folders or labels."

**Impact:** High. Admins can't push artifacts to users -- users must receive and open a link.

**Recommendation to product:** Support admin-pushed or role-based artifact pinning. Allow artifact folders/labels for organization.

---

### Gap 5: Limited Interactivity

**What Invesco wants:** Interactive elements beyond text (e.g., click a standard prompt card, buttons, structured forms).

**What CoWork has:** Text input + `/` skill invocation + `+` menu. Charts and tables are interactive (sort/filter/resize), but there are no custom buttons, forms, or structured input widgets.

**Impact:** Low-Medium. The `/` skill pattern covers most interactivity needs. Custom buttons/forms would be nice-to-have.

**Recommendation to product:** Support clickable prompt cards, structured input templates, and action buttons in agent responses.

---

### Gap 6: Artifact Collections

**What Invesco wants:** A dashboard-like view with multiple related artifacts together.

**What CoWork has:** Single artifacts only. Known limitation: "Currently, you can save and share an individual tile per artifact. Collections of multiple tiles aren't supported."

**Impact:** Medium. Each artifact is standalone; can't group "Morning Briefing" artifacts together.

**Recommendation to product:** Support artifact collections or dashboards -- save and share multiple related artifacts as a group.

---

## 6. Deliverables

| # | Deliverable | Type |
|---|-------------|------|
| D1 | Configured Cortex Agent with all tools | Agent object in Snowflake |
| D2 | User Skills library (8 standard prompt skills) | SKILL.md files on stage or Git |
| D3 | Shared Artifacts + Automations setup | CoWork artifacts + scheduled reports |
| D4 | Gap Analysis Report (this document, Section 5) | Report for CoWork product team |
| D5 | Usage analysis query/automation for prompt library | SQL + optional automation |

---

## 7. Open Questions

1. **Project name:** Still needs a name. Something beyond "chatbot."
2. **Data readiness:** Does Invesco have the semantic views and search services already, or do we need to build those?
3. **Agent skills vs. user skills:** Should we author developer SKILL.md files (more controlled, version-managed) or create user skills conversationally (faster, user-editable)?
4. **Artifact sharing workflow:** Who creates and shares the initial artifacts? Admin? Each PM?
5. **Automation cadence:** Confirm the refresh schedules for each report with Invesco.
6. **AI Gateway / Natoma:** Does it add value beyond what Agent Observability provides?

---

## 8. Reference Materials

| File | Description |
|------|-------------|
| `ref/20260903 invesco ui mock up screen shot.png` | Invesco "Central Investment Intelligence" UI mockup |
| `ref/Screenshot 2026-09-08 at 2.25.43 PM.png` | Daniel's whiteboard architecture drawing |
| `ref/20260908_image.png` | CoWork built-in artifacts example (Snowhouse) |
| `ref/Jake's Chatbot Transcript.txt` | Meeting transcript (Daniel, Stephanie, William -- 2026-09-08) |
