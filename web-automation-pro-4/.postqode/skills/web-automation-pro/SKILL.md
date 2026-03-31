---
name: web-automation-pro
description: >
  Use this skill for ANY task involving: a browser, URL, website, web page,
  navigation, login, form fill, click, scrolling, automation, E2E test,
  Playwright, Cypress, Selenium, WebdriverIO, Puppeteer, page object,
  web testing, or test generation. If a URL (http:// or https://) appears
  anywhere in the user's prompt, or they mention any web interaction,
  or they use the commands /automate, /spec-gen, /finalize, /spec-update, or /debug
  — activate this skill immediately.
---

# Web Automation Pro

Production-quality web automation: spec-first, persona-driven, context-engineered, with zero guesswork in generated code.

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

**If the user directly asks to "generate tests", "automate this", or provides a test case → acknowledge their request, but you MUST NOT skip the state routing in Step 1. You still must check if `SPEC.md` is missing and show the welcome message first.**

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

    Start with /spec-gen — I'll ask a few questions about your app,
    then build your automation spec.

    Commands:
      /spec-gen  → Create your automation spec
      /automate  → Execute the spec (after spec-gen)
      /finalize  → Generate production architecture (after automate)
      /debug     → Fix failing tests

  → ⛔ **CRITICAL STOP:** You must output EXACTLY the welcome message above and NOTHING ELSE. Do NOT open the browser. Do NOT explore the URL. Wait for the user to explicitly type `/spec-gen`.

SPEC.md missing but test-session.md exists?
  → Orphaned session — warn user and suggest /spec-gen

SPEC.md exists (LOCKED) but test-session.md missing?
  → Tell user: "SPEC.md is ready. Run /automate to begin execution planning."
  → ⛔ **CRITICAL STOP:** You must output EXACTLY the phrase above and NOTHING ELSE. Do NOT execute setup tasks. Do NOT generate test code. Wait for the user to explicitly type `/automate`.

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
| `/finalize` | All groups complete. Validate final test suite, cleanup temp files, and generate CI pipelines. |
| `/debug` | A test is failing outside normal execution. Diagnose and fix. |

---

## Executing `/automate` (STRICT PROTOCOL)

When the user types `/automate`, you MUST follow this exact sequence without exception:

1. **Load `references/session-protocol.md`** to route the state.
2. **If PHASE = SPEC_READY (Phase 0 Planning)**: 
   - Load `references/grouping-algorithm.md`.
   - **CRITICAL**: You MUST physically create the `active-group.md` and the `pending-groups/` directory as specified. Do NOT proceed to execution until the user explicitly approves the plan.
3. **If PHASE = SETUP (Phase 1)**:
   - Generate framework rules.
   - Execute setup tasks.
4. **If PHASE = EXECUTING (Phase 2)**:
   - Follow the `test-session.md` Checklist Format specified in `session-protocol.md`. DO NOT invent a custom summarized checklist.
   - **CRITICAL**: You MUST NOT write code for future groups. Only work on the current `active-group.md`.
   - **CRITICAL**: After completing an active group, you MUST trigger the **Reviewer** persona and run the rubric.
   - **CRITICAL**: Default `TURBO` mode to `OFF`. You MUST stop at the MILESTONE gate and wait for user approval before rotating to the next group.

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
| **Architect** | Setup Phase & Finalization | COM/POM/Flat decision, incremental component generation |
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
