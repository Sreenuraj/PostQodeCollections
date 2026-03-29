# Web Automation Pro 4

> **PostQode Agent System** — Spec-driven, persona-powered web automation for any framework.
> Successor to `web-automation-pro-3`. Built for speed without sacrificing reliability.

---

## What This Is

A self-contained PostQode agent system that takes raw test requirements and produces production-quality, maintainable web automation — using any testing framework the user chooses.

**System components:**
- **1 Skill** — the entry point and router
- **4 Workflows** — `/spec-gen`, `/automate`, `/finalize`, `/debug`  
- **4 Rules** — always-on behavioral constraints
- **8 Reference files** — JIT-loaded detail (keeps context lean)

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

The agent reads `SPEC.md`, performs a workspace intelligence scan, proposes a grouped execution plan, and waits for your approval. After approval it executes group by group — exploring the UI, mapping components, writing code, and validating each group before moving on.

**TURBO MODE is ON by default.** The agent auto-continues between groups (no manual gate needed). It will only stop when:
- A validation failure occurs
- The agent's milestone heuristic decides a check-in is warranted
- All groups are complete

### Step 3 — Generate Production Architecture

```
/finalize
```

Reads the component maps generated during execution and builds a proper Page Object or Page Component Model architecture. Refactors the working spec to use the new classes. Runs headed + headless validation. Cleans up all temp files.

### When Things Break

```
/debug
```

For diagnosing and fixing test failures post-finalization or outside normal execution.

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
   /finalize                     ← Architect generates POM/PCM architecture
       ↓
   Production test suite ✅
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
| `component-maps/` | UI component structure maps | ✅ Permanent |
| `[framework-test-spec]` | The actual test code | ✅ Permanent |
| `[POM/PCM files]` | Generated architecture | ✅ Permanent |

---

## Personas

Every phase of every workflow is handled by a specialized persona with a distinct thinking mode and strict forbidden actions. You'll see persona declarations like `🎭 PERSONA: The Engineer` at the start of each phase. This is by design — it prevents the agent from, for example, reviewing its own code as the same persona that wrote it.

| Persona | Active In |
|---|---|
| Strategist | Spec generation, execution planning |
| Engineer | Step exploration and code writing |
| Reviewer | Pre-validation rubric check |
| Validator | Headless test execution |
| Architect | Finalization and POM generation |
| Debugger | Failure recovery |

---

## File Structure

```
web-automation-pro-4/
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
    │   ├── finalize.md                 # /finalize — POM generation
    │   └── debug.md                   # /debug — failure recovery
    └── skills/
        └── web-automation-pro-4/
            ├── SKILL.md               # Entry point and router
            └── references/
                ├── personas.md
                ├── spec-format.md
                ├── session-protocol.md
                ├── tool-priority.md
                ├── reviewer-rubric.md
                ├── tip-protocol.md
                ├── grouping-algorithm.md
                └── recovery-protocol.md
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
| No pre-validation review | Reviewer rubric runs before every validation |
| Playwright/Cypress only | Any framework — rule generated during setup |
