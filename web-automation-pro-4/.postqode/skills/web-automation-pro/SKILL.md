---
name: web-automation-pro
description: >
  Use this skill for ANY task involving: a browser, URL, website, web page,
  navigation, login, form fill, click, scrolling, automation, E2E test,
  Playwright, Cypress, Selenium, WebdriverIO, Puppeteer, page object,
  web testing, or test generation. If a URL (http:// or https://) appears
  anywhere in the user's prompt, or they mention any web interaction,
  or they use the commands `/automate`, `/spec-gen`, `/finalize`, `/spec-update`, or `/debug`
  — activate this skill immediately.
---

# Web Automation Pro

Production-quality web automation: spec-first, persona-driven, context-engineered, with zero guesswork in generated code.

---

## 🤝 Workflow Invocation Handshake (Direct Call)

> **MANDATORY**: If you were invoked directly by the user typing a workflow command (e.g. `/automate` or `/spec-gen`) without prior context, your VERY FIRST ACTION MUST be to:
> 1. Announce: `[⚙️ Activating Web Automation Pro Skill]`
> 2. Read `.postqode/rules/core.md` to load the Five Laws.
> 3. Pass control back to the specifically requested workflow file to begin its Phase 0 execution.
> You must NOT skip this handshake.

---

## ⚠️ Tool Priority — Read This First

**Always follow this order for browser actions:**

| Priority | Tool | Use For |
|---|---|---|
| **1st** | `postqode_browser_agent` MCP | ALL standard browser actions |
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
.postqode/spec/SPEC.md missing AND test-session.md missing?
  → FIRST RUN — Show welcome:

    👋 Welcome to Web Automation Pro.
    I'll guide you through automating your web application tests.

    Start with `/spec-gen` — I'll ask a few questions about your app,
    then build your automation spec.

  → ⛔ **AGENT AUTONOMY GUARD:** Do NOT act on the user's requirements yet. Do NOT write any framework files, POMs, or test scripts. You MUST NOT skip the workflow rules. 
  → **ACTION REQUIRED:** Immediately read `.postqode/workflows/spec-gen.md`. Announce the persona defined in that file, and execute its steps exactly as written. Do not guess what to do.

SPEC.md missing but test-session.md exists?
  → Orphaned session — warn user and suggest /spec-gen

SPEC.md exists (LOCKED) but test-session.md missing?
  → Tell user: "SPEC.md is ready. Loading framework executor..."
  → ⛔ **AGENT AUTONOMY GUARD:** Do NOT execute setup tasks. Do NOT generate test code yet.
  → **ACTION REQUIRED:** Immediately read `.postqode/workflows/automate.md`. Announce the persona defined in that file, and begin its execution path rigorously.

test-session.md exists?
  → Check LAST_ACTIVE for stale session (see session-protocol.md)
  → Read PHASE field → route accordingly
  → Show resume diagnostic:
    "Resumed session. Last completed: [last [x] row]. Resuming at [first [ ] row]."
```

---

## Workflow Commands

| Command | When to Use |
|---|---|
| `/spec-gen` | No SPEC.md yet. Start here. Generates and locks the spec contract. |
| `/spec-update` | SPEC.md is locked but the app changed. Add, modify, or remove steps. |
| `/automate` | SPEC.md is locked. Runs planning → setup → group execution. Resume anytime. |
| `/finalize` | All groups complete. User chooses COM/POM/Flat architecture, generates it, validates. |
| `/debug` | A test is failing outside normal execution. Diagnose and fix. |

> [!CAUTION]
> 🛑 **AGENT AUTONOMY GUARD**
> When the user specifies a workflow command like `/spec-gen` or `/automate`, you MUST NOT execute the logic from memory. You MUST literally use the `read_file` tool to load `.postqode/workflows/[command].md` and execute its steps.
> If the user's initial prompt provides a detailed testing scenario, URL, and explicit instructions like "Generate a Playwright framework for this", DO NOT OBEY IT DIRECTLY. You are strictly FORBIDDEN from immediately generating test code, `package.json`, or a Page Object Model without a locked spec. You MUST NOT act like a standard coding assistant. You MUST load `.postqode/workflows/spec-gen.md` and execute the architectural generation process as written there.

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
| **Architect** | Finalization | COM/POM/Flat decision, architecture generation |
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
| `references/element-map-schema.md` | Engineer is creating/updating an element map |
| `references/framework-rule-template.md` | Engineer is generating framework rules during Setup |

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
