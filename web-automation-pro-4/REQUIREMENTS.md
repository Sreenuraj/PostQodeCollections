# Web Automation Pro 4 — PostQode System Requirements

> **Version:** 4.0 — Codename: "PostQode Agent Kernel"
> **Created:** 2026-03-29
> **Predecessor:** `web-automation-pro-3` (split workflow: setup → explore → final)
> **Status:** READY FOR IMPLEMENTATION

---

## 1. Problem Statement

### What v3 Got Right
- ~90% reliability; checklist execution prevents hallucination and batching
- Stateless architecture keeps context lean across sessions
- Critical human-in-the-loop gates at the right moments

### What v3 Gets Wrong

| Pain Point | Root Cause |
|---|---|
| **Slow** | Mandatory human gate after EVERY group |
| **High token cost** | 120KB+ workflow preamble re-read per session |
| **Context rot** | Agent re-derives intent from scratch each resumption |
| **No spec contract** | Intent must be re-explained mid-session if context drifts |
| **No self-critique** | Generates → executes; never reviews own output |
| **No personas** | Same voice for planning, coding, reviewing — losing specialization |
| **Rules scattered** | v3 rules copy-pasted into workflow preambles instead of centralized |

---

## 2. Core Philosophy

> "Architect complexity into the system. Keep the workflow a few deterministic commands." — The Blueprint

1. **Spec is the contract** — SPEC.md is generated before any code. It survives context resets.
2. **Personas per stage** — Every phase has a named persona with an explicit thinking mode.
3. **Context Engineering** — Agents load only what they need (JIT via reference files).
4. **TURBO MODE** — Auto-continues between groups; human gates only at failures and earned milestones.
5. **Self-critique is mandatory** — Same-session persona switch to Reviewer before every validation.
6. **All v3 rules migrate** — Nothing is lost; everything is consolidated into `rules/`.
7. **PostQode primitives used correctly** — Skill, Workflow, Rules — each with a clear job.

---

## 3. PostQode Primitives — Correct Usage

PostQode supports exactly three primitives:

| Primitive | Location | Invocation | Job |
|---|---|---|---|
| **Skill** | `.postqode/skills/{name}/SKILL.md` | Agent reads it as a capability context | Entry point, intent detection, routing, JIT reference loading. **Not stateful.** |
| **Workflow** | `.postqode/workflows/{name}.md` | User runs `/workflow-name` command | Stateful, checklist-driven, phased execution with human gates |
| **Rules** | `.postqode/rules/{name}.md` | Referenced by Skill or Workflow | Always-on behavioral constraints — protocols, standards, anti-patterns |

### Critical Distinction: Skill vs. Workflow

```
SKILL = "What can I do and how do I start?"
  → Reads state, picks the right workflow, directs user to run it
  → Contains: intent detection, tool priority, persona roster, state router
  → SKILL cannot invoke a workflow — it tells the USER which /command to run

WORKFLOW = "How do I execute this phase step by step?"
  → Stateful: reads/writes test-session.md, active-group.md etc.
  → Contains: checklists, human gates, explicit step sequences
  → Invoked by user via /command
```

### Skill Sub-Resources (utilized in v4)

Skills can have sub-folders alongside `SKILL.md`. The existing `web-automation-pro-skill` pattern shows this:

```
.postqode/skills/web-automation-pro-4/
├── SKILL.md                      # Master entry point (lean — routes to references)
└── references/                   # JIT-loaded detail files
    ├── personas.md               # Full persona roster + declaration templates
    ├── spec-format.md            # SPEC.md schema + example
    ├── session-protocol.md       # State machine + state reading protocol
    ├── tool-priority.md          # Browser tool priority (postqode > chrome-devtools)
    ├── reviewer-rubric.md        # Self-critique checklist (replaces LLM-as-Judge)
    ├── tip-protocol.md           # Transition Intelligence Protocol
    ├── grouping-algorithm.md     # Component-aware + code-aware grouping logic
    └── recovery-protocol.md     # L1→L2→L3 debug recovery (DEBUGLOOP template)
```

**Why references?** The SKILL.md stays lean (< 150 lines). Detail is loaded JIT when the agent needs it. This eliminates the 120KB+ preamble problem from v3.

---

## 4. On "LLM-as-Judge" — Honest Assessment

> ⚠️ **Reality check:** A true second-model review (passing output to an independent model) requires a separate session in PostQode and currently needs human intervention to trigger. We cannot automate a true multi-model review loop within a single agent session.

**What we CAN do (and will do):**

| Technique | Implementation | Effectiveness |
|---|---|---|
| **Same-session Persona Switch** | Agent switches to `REVIEWER` persona explicitly, with forbidden actions (cannot write code). Reviews own output against rubric. | High — catches anti-patterns, spec mismatches, missing assertions |
| **Rubric-based Self-Critique** | Structured checklist in `references/reviewer-rubric.md` — agent must answer each criterion before proceeding | High — forces structured review, not vague "looks good" |
| **Explicit role boundary** | Personas have forbidden actions. REVIEWER cannot write code. ENGINEER cannot approve spec. | Medium — prevents cross-role contamination |
| **Fresh session review (optional)** | User can start `/debug` in a new session to get a fresh-context review. Human-triggered but clean. | High — true context independence |

**The REVIEWER persona IS the practical LLM-as-Judge for PostQode.** It's not a second model, but it's the closest we can get without human-triggered fresh sessions.

---

## 5. Full System Structure (Corrected)

```
web-automation-pro-4/
├── REQUIREMENTS.md                          # ← This document
└── .postqode/
    ├── rules/
    │   ├── core.md                          # Universal laws + persona protocol + templates
    │   ├── framework-standards.md           # Playwright/Cypress standards (from v3)
    │   ├── interaction-fallbacks.md         # Coordinates + hover + slider (merged from v3)
    │   └── debug-context-capture.md        # Debug injection protocol (from v3, unchanged)
    │
    ├── workflows/
    │   ├── automate.md                      # /automate — master orchestrator (replaces v3 split)
    │   ├── spec-gen.md                      # /spec-gen — spec generation + approval
    │   ├── finalize.md                      # /finalize — POM generation + refactor
    │   └── debug.md                         # /debug — smart failure recovery
    │
    └── skills/
        └── web-automation-pro-4/
            ├── SKILL.md                     # Entry point (lean router — < 150 lines)
            └── references/
                ├── personas.md              # All 6 persona declarations + thinking modes
                ├── spec-format.md           # SPEC.md schema + full example
                ├── session-protocol.md      # State machine + session file read protocol
                ├── tool-priority.md         # Browser tool priority rules
                ├── reviewer-rubric.md       # Self-critique rubric (6-criteria)
                ├── tip-protocol.md          # Transition Intelligence Protocol
                ├── grouping-algorithm.md    # Component-aware + code-aware grouping
                └── recovery-protocol.md    # L1→L2→L3 DEBUGLOOP escalation
```

---

## 6. Workflow Map — What Each `/command` Does

| Command | Workflow File | Persona(s) | Triggers | Output |
|---|---|---|---|---|
| `/spec-gen` | `spec-gen.md` | Strategist | No SPEC.md exists; user has raw requirements | `SPEC.md` (LOCKED) |
| `/automate` | `automate.md` | Strategist → Engineer → Reviewer → Validator | SPEC.md exists; ready to execute | Code, component maps, test-session.md |
| `/finalize` | `finalize.md` | Architect | All groups complete; working spec passes | POM structure, refactored spec, cleanup |
| `/debug` | `debug.md` | Debugger | Test is failing outside of normal execution | Fixed test or diagnosis report |

### Workflow Invocation Convention

The Skill CANNOT invoke workflows. It **directs the user** to run the correct `/command`:

```
# In SKILL.md or references/session-protocol.md:

Based on state detected:
- SPEC.md missing → "Please run /spec-gen to generate your automation spec first."
- SPEC.md exists, no session → "Please run /automate to begin execution."
- Session mid-execution → "Please run /automate to resume."
- All groups done → "Please run /finalize to generate the production POM structure."
- Test failing post-finalize → "Please run /debug to diagnose and fix."
```

---

## 7. SKILL.md Design (Lean Router)

The SKILL.md stays lean by pointing to references. It handles:

**Section 1 — Frontmatter (activation triggers)**
```yaml
---
name: web-automation-pro-4
description: >
  Use for ANY task involving: browser, URL, website, navigation, click,
  form fill, login, automation, playwright, cypress, E2E test, page object,
  web testing. If a URL (http/https) or web interaction appears in the prompt,
  activate this skill.
---
```

**Section 2 — Tool Priority (inline — must always be visible)**
Browser tool priority rule (never reference-file this — too critical to miss):
```
Priority 1: postqode_browser_agent MCP (browser_navigate, browser_click, etc.)
Priority 2: browser_action built-in (launch, click, type, scroll, close)
Priority 3: chrome-devtools MCP (LAST RESORT ONLY — DevTools-specific features)
```

**Section 3 — Persona Roster (summary only, detail in `references/personas.md`)**
Names + one-line mandate for each. Agent reads `references/personas.md` for full declaration.

**Section 4 — Intent Detection**
Ask once: "Are you automating this flow for test generation, or is this a one-time task?"
→ Recording Mode (automation) or Exploration Mode (one-time)

**Section 5 — State Router**
Read `test-session.md`. Direct user to the correct `/command`. (Detail in `references/session-protocol.md`)

**Section 6 — Reference Registry**
Table of all reference files with one-line descriptions — agent loads JIT.

---

## 8. Personas — Full Roster

Defined in full in `references/personas.md`. Summary:

| Persona | Phase | Mandate | Forbidden |
|---|---|---|---|
| **Strategist** | spec-gen, planning, grouping | Surface ambiguity, ask before committing, never assume | Cannot write code, cannot touch browser |
| **Engineer** | EXPLORE + WRITE per step | Observe evidence first, then write one step | Cannot batch rows, cannot skip snapshot evidence, cannot review |
| **Reviewer** | Post-code, pre-validation | Review against SPEC.md rubric, find failures before tests do | Cannot write or fix code — only flags issues |
| **Validator** | Headless validation | Binary pass/fail, report facts | Cannot interpret ambiguous results — escalates to user |
| **Architect** | Phase 3 finalize | Structural patterns, POM, abstractions | Cannot write flat ad-hoc code, cannot skip pattern consistency |
| **Debugger** | Failure recovery | Root cause first, then fix, L1→L2→L3 only | Cannot skip L1 before trying L2, cannot guess without evidence |

**Persona Declaration Format** (used at the opening of every phase in every workflow):
```
## 🎭 PERSONA: The [Name]
> Mandate: [one sentence]
> Thinking mode: [how to reason about this phase]
> FORBIDDEN: [what this persona must never do]
```

---

## 9. SPEC.md — The Contract

The SPEC.md is generated before any code and persists across sessions. Generated by `/spec-gen`.

**Lock Policy — Soft Lock:**
- `DRAFT` → `LOCKED` on user approval
- LOCKED = stable, not immutable
- Adding steps mid-session: Strategist opens SPEC.md, adds step, routes to appropriate pending-group. Brief gate: "Updated SPEC.md. Continues in [group N]. (A) Yes (B) Adjust" — NO full re-plan
- This is designed for "malau test cases" (many steps from a test case document) where scope evolves

**SPEC.md lives at:** `.postqode/spec/SPEC.md`
**SPEC.md schema detail:** `references/spec-format.md`

---

## 10. /automate Workflow Design

### State Router (Phase 0 of every /automate invocation)

```
Read .postqode/spec/SPEC.md → exists?
  NO  → "Please run /spec-gen first"  ⛔ STOP
  YES ↓
Read test-session.md → exists?
  NO  → begin Phase 0 (plan from SPEC)
  YES → read PHASE field:
    SETUP → resume Phase 1
    EXECUTING → resume Phase 2 (active group)
    VALIDATING → resume validation
    ROTATING → resume next group
    MILESTONE → show milestone menu
    COMPLETE → redirect to /finalize
```

### Phase 0 — Plan (STRATEGIST persona)

1. Read `SPEC.md` fully → extract step definitions
2. Workspace Intelligence Scan: `package.json`, existing specs, `component-maps/`
3. Detect pre-coded steps → Case A/B/C decision (from v3, preserved exactly)
4. Apply grouping algorithm → see `references/grouping-algorithm.md`
5. Generate plan table → ⛔ STOP for user approval (ONE gate)
6. TURBO consent: "(A) TURBO ON — auto-continue between groups  (B) TURBO OFF — stop after each group (default: A)"
7. Write `test-session.md` header + SETUP rows + Group 1 rows only (stateless pattern from v3)

### Phase 1 — Setup (ENGINEER persona)

Exact port of v3 Phase 1. Minimal framework install only.

### Phase 2 — Execution Loop

```
FOR each pending group:
  [ENGINEER] reads active-group.md
  FOR each step:
    TIP: pre-snapshot → action → network monitor → post-snapshot → diff
    COMPONENT MAP: check/create → references/tip-protocol.md for TIP detail
    WRITE CODE: evidence-based, one step at a time
    MARK [x] → save test-session.md (SAVE RULE, unchanged from v3)
  
  [REVIEWER] reads references/reviewer-rubric.md → runs rubric
    PASS → proceed to validation
    WARN → Engineer fixes flagged issues → re-run rubric
    FAIL → ⛔ STOP (present issues to user)
  
  [VALIDATOR] run headless validation
    PASS → COLLAPSE CHECKLIST → ROTATE
    FAIL → [DEBUGGER] references/recovery-protocol.md → L1→L2→L3
  
  MILESTONE CHECK (references/session-protocol.md):
    Evaluate 4 signals → 2+ signals → ⛔ STOP
    Else IF TURBO=ON → AUTO-CONTINUE
    Else IF TURBO=OFF → ⛔ STOP always
```

### Milestone Intelligence (Agent-Decided)

The **Validator** persona evaluates after each group:

| Signal | Indicates |
|---|---|
| L2 or L3 recovery was needed this group | Flow is complex — user should check |
| Reviewer flagged any WARN or FAIL | Quality issue — scan before continuing |
| 5+ groups still pending | Long session — periodic sanity check |
| 3+ groups since last user check-in | Trust decay — re-establish alignment |

**2+ signals triggered → MILESTONE GATE → ⛔ STOP**

---

## 11. Reviewer Rubric (references/reviewer-rubric.md)

Runs after EVERY group's code is written, before headless validation.

```
REVIEWER RUBRIC — 6 Criteria:
□ 1. Every step in active-group.md has corresponding code in the spec file
□ 2. Zero sleep() or waitForTimeout() — only evidence-based waits
□ 3. Every locator has ≥1 fallback strategy captured
□ 4. Every major action (navigate, submit, drag) has a DOM assertion after it
□ 5. All expected outcomes match the SPEC.md step definitions exactly
□ 6. TIP protocol citation in code comments (what network/DOM change observed)

VERDICT:
  6/6 → PASS — proceed to validation
  4-5/6 → WARN — Engineer fixes, re-run rubric  
  <4/6 → FAIL → ⛔ STOP, present to user
```

---

## 12. Rules Migration (v3 → v4)

| v3 File | v4 Destination | Change |
|---|---|---|
| Core rules (in workflow CAUTION blocks) | `rules/core.md` | Extracted and centralized |
| `rules/playwright-framework-best-practices.md` | `rules/framework-standards.md` | Renamed, enriched with PCM |
| `rules/coordinate-fallback.md` | `rules/interaction-fallbacks.md` | Merged with hover + slider |
| `rules/hover-handling.md` | `rules/interaction-fallbacks.md` | Merged |
| `rules/slider-handling.md` | `rules/interaction-fallbacks.md` | Merged |
| `rules/debug-context-capture.md` | `rules/debug-context-capture.md` | Port as-is (proven) |
| TIP protocol (inline in v3 explore) | `references/tip-protocol.md` | Extracted to skill reference |
| L1/L2/L3 recovery (inline in v3 explore) | `references/recovery-protocol.md` | Extracted to skill reference |
| Grouping algorithm (inline in v3 setup) | `references/grouping-algorithm.md` | Extracted to skill reference |
| Pre-coded step Case A/B/C (in v3 setup) | `references/grouping-algorithm.md` | Extracted to skill reference |

**Nothing is lost. Everything is reorganized.**

---

## 13. Build Order (Implementation Sequence)

```
1. rules/core.md                           Foundation — all workflows reference this
2. rules/framework-standards.md            Playwright/Cypress standards
3. rules/interaction-fallbacks.md          Merged interaction rules
4. rules/debug-context-capture.md         Port from v3 as-is

5. skills/web-automation-pro-4/references/personas.md          Persona definitions
6. skills/web-automation-pro-4/references/tool-priority.md     Browser tool priority
7. skills/web-automation-pro-4/references/spec-format.md       SPEC.md schema
8. skills/web-automation-pro-4/references/session-protocol.md  State machine
9. skills/web-automation-pro-4/references/reviewer-rubric.md   Self-critique rubric
10. skills/web-automation-pro-4/references/tip-protocol.md     TIP protocol
11. skills/web-automation-pro-4/references/grouping-algorithm.md  Grouping + pre-coded
12. skills/web-automation-pro-4/references/recovery-protocol.md  L1→L2→L3

13. workflows/spec-gen.md                  Spec generation (needs personas)
14. workflows/debug.md                     Debug workflow (needs recovery-protocol)
15. workflows/finalize.md                  POM workflow (port from v3 + Architect persona)
16. workflows/automate.md                  Master orchestrator (depends on all above)

17. skills/web-automation-pro-4/SKILL.md   Entry point (depends on all references)
18. README.md                              Human usage guide
```

---

## 14. Design Decisions Log

| Decision | Choice | Rationale |
|---|---|---|
| TURBO default | **ON** (user opts out) | Speed is the primary v3 complaint |
| SPEC.md lock policy | **Soft lock** | Malau-style many-step inputs need to evolve without full re-plan |
| Milestone trigger | **Agent-decided** (4-signal heuristic) | LLM better than fixed count at judging context |
| LLM-as-Judge | **Reviewer persona + rubric** | Honest — no multi-model in single session; rubric makes it rigorous |
| Skills scope | **Project-level** | `.postqode/` per project; global sharing deferred |
| Domain | **Web automation first** | SPEC.md has domain field for future extension |
| Workflow invocation | **Only by user via /command** | Skill cannot invoke workflows; routes user to right command |
| Sub-resources | **`references/` folder** | JIT loading keeps SKILL.md lean; follows existing skill pattern |

---

## 15. Success Metrics

| Metric | v3 | v4 Target |
|---|---|---|
| Human gates (6-group TURBO session) | 6+ | ~2 (plan + final) |
| SKILL.md token footprint | ~15K (full workflow) | < 3K (SKILL.md only, refs JIT) |
| Active test-session.md rows (peak) | 50+ | ≤ 30 (collapse enforced) |
| Step reliability | ~90% | ≥ 90% (no regression) |
| Spec mismatches caught pre-validation | 0% | > 80% (Reviewer rubric) |
| Time to resume after context reset | Re-read 3 files | Read SPEC.md + test-session.md only |
