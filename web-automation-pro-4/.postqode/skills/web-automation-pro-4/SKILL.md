---
name: web-automation-pro-4
description: >
  Use this skill for ANY task involving: a browser, URL, website, web page,
  navigation, login, form fill, click, scrolling, automation, E2E test,
  Playwright, Cypress, Selenium, WebdriverIO, Puppeteer, page object,
  web testing, or test generation. If a URL (http:// or https://) appears
  anywhere in the user's prompt, or they mention any web interaction —
  activate this skill immediately.
---

# Web Automation Pro 4

Production-quality web automation: spec-first, persona-driven, context-engineered, with zero guesswork in generated code.

---

## ⚠️ Tool Priority — Read This First

**Always follow this order for browser actions:**

| Priority | Tool | Use For |
|---|---|---|
| **1st** | `postqode_browser_agent` built-in | ALL standard browser actions |
| **2nd** | `playwright` CLI | Fallback if Priority 1 unavailable |
| **3rd** | `chrome-devtools` MCP | **LAST RESORT** — DevTools-exclusive features ONLY |

→ Full details: `references/tool-priority.md`

---

## Step 0 — Intent Detection

Before any browser action or planning, determine intent:

> "Are you automating this flow to generate reusable tests, or is this a one-time browser task?"

| Answer | Mode | What Changes |
|---|---|---|
| Automation / tests | **Recording Mode** | Full lifecycle: spec → plan → explore → code → validate |
| One-time task | **Exploration Mode** | Standard browser interaction only; no spec or test generation |

**If the user directly asks to "generate tests", "automate this", or provides a test case → activate Recording Mode immediately without asking.**

---

## Step 1 — State Detection (Recording Mode Only)

Read the session state to determine which workflow to direct the user to.

→ See `references/session-protocol.md` for full state routing logic.

**Quick routing:**

```
.postqode/spec/SPEC.md missing?
  → "Please run /spec-gen to create your automation spec first."

SPEC.md exists (LOCKED) but test-session.md missing?
  → "Please run /automate to begin execution planning."

test-session.md exists?
  → Read PHASE field → route accordingly (see session-protocol.md)
```

---

## Workflow Commands

| Command | When to Use |
|---|---|
| `/spec-gen` | No SPEC.md yet. Start here. Generates and locks the spec contract. |
| `/automate` | SPEC.md is locked. Runs planning → setup → group execution. Resume anytime. |
| `/finalize` | All groups complete. Generates POM/PCM architecture, refactors spec, validates. |
| `/debug` | A test is failing outside normal execution. Diagnose and fix. |

---

## Personas in This System

Six specialized personas are used across the lifecycle. Each workflow phase activates the right one.

→ Full definitions with thinking modes and forbidden actions: `references/personas.md`

| Persona | Stage | Core Job |
|---|---|---|
| **Strategist** | spec-gen, planning | Surfaces ambiguity, builds precise plans |
| **Engineer** | EXPLORE + WRITE | Evidence-first code generation, one step at a time |
| **Reviewer** | Post-code, pre-validation | Adversarial rubric check against SPEC.md |
| **Validator** | Headless validation | Binary pass/fail, facts only |
| **Architect** | Finalization | POM/PCM structure, patterns, maintainability |
| **Debugger** | Failure recovery | Root cause first, minimum-change fix |

---

## Reference Files (Load JIT When Needed)

| File | Load When |
|---|---|
| `references/personas.md` | Starting any workflow phase — get the full persona declaration |
| `references/spec-format.md` | Generating or reading SPEC.md |
| `references/session-protocol.md` | Routing state or resuming a session |
| `references/tool-priority.md` | Starting any browser interaction |
| `references/reviewer-rubric.md` | Reviewer persona is active |
| `references/tip-protocol.md` | Engineer is about to write a step |
| `references/grouping-algorithm.md` | Strategist is grouping steps (Phase 0) |
| `references/recovery-protocol.md` | Test validation fails |
| `references/architecture-patterns.md` | /finalize — choosing POM vs COM vs Flat |

---

## Key Rules (Always Active)

→ `rules/core.md` — 5 Laws + Persona Protocol + Named Templates (ALWAYS in effect)
→ `rules/automation-standards.md` — Framework-agnostic testing standards
→ `rules/interaction-fallbacks.md` — Coordinates, hover, slider strategies
→ `rules/debug-context-capture.md` — Debug injection protocol
→ `rules/[framework].md` — Generated during Setup; framework-specific conventions

---

## Best Practices

**DO:**
- ✅ Always run `/spec-gen` before `/automate` — spec is the contract
- ✅ Use `browser_snapshot` for analysis; `browser_take_screenshot` for visual evidence
- ✅ Follow TIP protocol for every step (see `references/tip-protocol.md`)
- ✅ Trust TURBO MODE — it only auto-continues when conditions are safe
- ✅ Check element maps before creating new ones — reuse what exists

**DON'T:**
- ❌ Skip intent detection — always ask or infer
- ❌ Write code before running TIP and capturing evidence
- ❌ Use chrome-devtools for standard browser actions
- ❌ Batch checklist rows — one at a time, always
- ❌ Proceed past a ⛔ STOP without explicit user input
