# Web Automation Pro

> **PostQode Agent System** — Spec-driven, persona-powered web automation for any framework.
> Successor to `web-automation-pro-3`. Built for speed without sacrificing reliability.

---

## What This Is

A self-contained PostQode agent system that takes raw test requirements and produces production-quality, maintainable web automation — using any testing framework the user chooses.

**System components:**
- **1 Skill** — the entry point and router
- **5 Workflows** — `/spec-gen`, `/spec-update`, `/automate`, `/finalize`, `/debug`  
- **4 Rules** — always-on behavioral constraints
- **11 Reference files** — JIT-loaded detail (keeps context lean)

---

## Quick Start

### Step 1 — Generate the Spec

```
/spec-gen
```

The agent will ask a few clarifying questions, then produce a locked `SPEC.md` — the contract for everything that follows.

### Step 2 — Plan and Execute

```
/automate
```

The agent reads `SPEC.md`, performs a workspace intelligence scan, proposes a grouped execution plan, and waits for your approval. After approval it executes group by group — exploring the UI, mapping elements, writing code, and validating each group before moving on.

**TURBO MODE is ON by default.** The agent auto-continues between groups (no manual gate needed). It will only stop when:
- A validation failure occurs
- The agent's milestone heuristic decides a check-in is warranted
- All groups are complete

### Step 3 — Generate Production Architecture

```
/finalize
```

Reads the element maps generated during execution, analyzes reuse patterns, and asks YOU which architecture to build: **Component Object Model (COM)**, **Page Object Model (POM)**, or **Flat** (keep as-is). Generates the architecture, refactors the spec, validates. Cleans up temp files.

### When Things Break

```
/debug
```

For diagnosing and fixing test failures post-finalization or outside normal execution.

### When the App Changes

```
/spec-update
```

Surgically add, modify, or remove steps in a LOCKED spec without starting from scratch. The system analyzes impact on any active sessions.

---

## The Lifecycle

```
User provides requirements
       ↓
   /spec-gen                     ← Strategist generates + locks SPEC.md
       ↓
   /automate                     ← Strategist plans, Engineer codes, Reviewer + Validator verify
       ↓ (per group, TURBO auto-continues)
   /automate (resume)            ← State is in test-session.md — pick up anywhere
       ↓ (all groups done)
   /finalize                     ← Architect asks: COM, POM, or Flat?
       ↓
   Production test suite ✅

   ←─ /spec-update ─→              ← App changed? Update the spec, re-run affected groups
   ←─ /debug ───────→              ← Test failing? Diagnose and fix
```

---

## Framework Support

This system is **framework-agnostic**. During the first `/automate` run, if no framework is detected, the agent will ask which framework you want to use. Your answer creates a `.postqode/rules/[framework].md` file with framework-specific conventions.

Supported: Playwright, Cypress, Selenium, WebdriverIO, Puppeteer, and any other framework the agent can install.

---

## TURBO MODE

TURBO MODE (default: ON) eliminates the manual gate after each group. The agent continues automatically when:
- Validation passed
- The reviewer rubric scored PASS or resolved WARN
- The agent's milestone signals are below threshold

The agent will stop automatically when:
- Any validation fails (L2 or L3 escalation required)
- It detects 2+ milestone signals (e.g., complex recovery, quality warnings, many pending groups)
- All groups are complete

To turn TURBO OFF (v3 behavior): reply "C" or "TURBO OFF" during plan approval.

---

## What Gets Created During Execution

| File/Folder | Purpose | Persists? |
|---|---|---|
| `.postqode/spec/SPEC.md` | Automation contract | ✅ Permanent |
| `test-session.md` | Live execution ledger | ❌ Deleted by /finalize |
| `active-group.md` | Current group being executed | ❌ Deleted by /finalize |
| `pending-groups/` | Queued groups | ❌ Deleted by /finalize |
| `completed-groups/` | Collapsed group archives | ❌ Deleted by /finalize |
| `element-maps/` | Locator intelligence from exploration | ✅ Permanent |
| `[framework-test-spec]` | The actual test code | ✅ Permanent |
| `[COM/POM files]` | Generated architecture (user chooses) | ✅ Permanent |

---

## Personas

Every phase of every workflow is handled by a specialized persona with a distinct thinking mode and strict forbidden actions. You'll see persona declarations like `🎭 PERSONA: The Engineer` at the start of each phase. This is by design — it prevents the agent from, for example, reviewing its own code as the same persona that wrote it.

| Persona | Active In |
|---|---|
| Strategist | Spec generation, execution planning |
| Engineer | Step exploration and code writing |
| Reviewer | Pre-validation rubric check |
| Validator | Headless test execution |
| Architect | Architecture decision + generation |
| Debugger | Failure recovery |

---

## File Structure

```
web-automation-pro/
├── REQUIREMENTS.md                     # System design document
└── .postqode/
    ├── rules/
    │   ├── core.md                     # 5 Laws + persona protocol (always active)
    │   ├── automation-standards.md     # Framework-agnostic testing standards
    │   ├── interaction-fallbacks.md    # Coordinates, hover, slider strategies
    │   └── debug-context-capture.md   # Debug injection protocol
    ├── workflows/
    │   ├── automate.md                 # /automate — master orchestrator
    │   ├── spec-gen.md                 # /spec-gen — spec generation
    │   ├── spec-update.md              # /spec-update — spec evolution
    │   ├── finalize.md                 # /finalize — COM/POM/Flat architecture generation
    │   └── debug.md                   # /debug — failure recovery
    └── skills/
        └── web-automation-pro/
            ├── SKILL.md               # Entry point and router
            └── references/
                ├── personas.md
                ├── spec-format.md
                ├── session-protocol.md
                ├── tool-priority.md
                ├── reviewer-rubric.md
                ├── tip-protocol.md
                ├── grouping-algorithm.md
                ├── recovery-protocol.md
                ├── architecture-patterns.md
                ├── element-map-schema.md
                └── framework-rule-template.md
```

---

## Differences From v3

| v3 | v4 |
|---|---|
| 3-file split (setup/explore/final) | Single `/automate` entry point |
| Stop after every group | TURBO MODE — auto-continues |
| No spec contract; re-derives intent each session | `SPEC.md` — locked before execution |
| Rules copy-pasted into workflows | Centralized `rules/` + JIT reference loading |
| No personas | 6 specialized personas per phase |
| Auto-selects POM or PCM | User chooses COM / POM / Flat with evidence |
| No pre-validation review | Reviewer rubric runs before every validation |
| Playwright/Cypress only | Any framework — rule generated during setup |
