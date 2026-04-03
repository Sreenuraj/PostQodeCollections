---
name: web-automation-pro
description: >
  Use this skill for browser automation, test generation, Playwright, Cypress,
  Selenium, WebdriverIO, Puppeteer, URLs, navigation, login flows, form flows,
  page objects, component objects, browser exploration, or any reusable web
  automation request. Activate immediately if the user mentions a workflow
  command such as /spec-gen, /automate, /finalize, /spec-update, or /debug.
---

# Web Automation Pro

Spec-driven browser automation for long and stateful UI flows.

---

## ⚠️ CRITICAL RULES — READ FIRST, ENFORCE ALWAYS

These 7 rules are non-negotiable and apply at every turn of every session.
Before each response, silently verify all 7.

1. **Never skip the workflow chain.** Every automation request — vague or detailed — enters through a workflow command or is routed to one. No freeform coding outside the chain.
2. **State files, not memory.** Always read `test-session.md` and `SPEC.md` from disk before acting. Never reconstruct state from conversation history.
3. **No code before the spec is locked.** Do not create framework config, fixtures, page objects, or executable tests until `/spec-gen` has produced a `LOCKED` spec and the routing says `/automate`.
4. **One runnable test file throughout `/automate`.** Never create a new test file per group. `WORKING_TEST_FILE` is set once and stable until `/finalize`.
5. **Stop at every gate.** Approval gates are mandatory pauses. Always write the stop state to disk before presenting the gate. Never self-approve.
6. **Run PROTOCOL_GUARD before any write, transition, or summary** that could move the session off-rails. The inline guard below is always available — use it.
7. **No COM/POM/Flat decision during `/automate`.** That decision belongs to `/finalize` and requires evidence. Never pre-select an architecture during execution.

### Inline PROTOCOL_GUARD

Run this mental checklist before every high-impact action:

```
PROTOCOL_GUARD:
[ ] Is ACTIVE_WORKFLOW correct for this step?
[ ] Is PHASE the right phase for this action?
[ ] Does this write fall within the current workflow's write boundary?
[ ] Is the stop state already persisted before I present a gate?
[ ] Would this summary claim completion for work that is still unresolved?
If any box is [ ] NO → STOP. Do not proceed. Resolve the conflict first.
```

---

## Workflow Invocation Handshake

### On explicit workflow command (`/spec-gen`, `/automate`, `/finalize`, `/spec-update`, `/debug`):

1. Output: `[⚙️ Activating Web Automation Pro Skill]`
2. Read `.postqode/rules/core.md`
3. Confirm load by stating: `core.md loaded. Active rules: [list top 3 rules from the file]`
4. Read the requested workflow file
5. Read `test-session.md` and `SPEC.md` from disk
6. Route using persisted state, not memory

### On natural-language entry (no slash command):

Use this decision tree — do not guess:

```
Does the message mention a URL, flow, login, form, navigation, or test?
  AND does it imply reuse / repeatability / a test suite?
    → Recording Mode → route to /spec-gen (if no locked spec) or /automate (if locked spec exists)

Does the message ask to "check", "explore", "see what happens", or "try"?
    → Exploration Mode → one-time browser task, no workflow chain required

Is it ambiguous?
    → Ask ONE clarifying question: "Do you want a reusable automated test, or a one-time browser check?"
    → Do not start coding while waiting for the answer
```

After routing, announce: `[⚙️ Routing to /[workflow]]`
Then read `core.md` and the workflow file exactly as explicit command entry would.

Natural-language entry is workflow entry. It is never a freeform framework-generator mode.

### core.md load is not optional

If `core.md` cannot be read (file missing, path error), stop and tell the user:
```
Cannot load .postqode/rules/core.md. Please verify the file exists before continuing.
```
Never proceed past the handshake without confirming core.md loaded.

---

## Step 0 — Mode Detection

Decide before anything else:
- **Recording Mode** — for reusable automation (test suites, repeatable flows)
- **Exploration Mode** — for one-time browser inspection

Use the decision tree in the Handshake section above.
If any signal points toward Recording Mode, enter it immediately regardless of how vague or detailed the request is.

---

## Step 1 — State Detection (Recording Mode only)

Read in this exact order from disk:
1. `.postqode/spec/SPEC.md`
2. `test-session.md`
3. `PHASE`
4. `ACTIVE_WORKFLOW`
5. `STOP_REASON`
6. `LAST_ACTIVE`

Do not rely on earlier conversation turns for any of these values.

### Routing table

| State | Route |
|---|---|
| No locked spec | `/spec-gen` |
| `ACTIVE_WORKFLOW: SPEC_GEN` | `/spec-gen` |
| `ACTIVE_WORKFLOW: SPEC_UPDATE` | `/spec-update` |
| `ACTIVE_WORKFLOW: DEBUG` | `/debug` |
| `ACTIVE_WORKFLOW: FINALIZE` | `/finalize` |
| `ACTIVE_WORKFLOW: AUTOMATE` | `/automate` |
| Locked spec, no session | `/automate` Phase 0 |
| `PHASE: COMPLETE` | Inform user. Suggest `/debug` or `/spec-update` only if relevant. Do not re-route to `/finalize`. |

### Write boundary when routed to `/spec-gen`

May write: `.postqode/spec/SPEC.md`, minimal session ledger fields.
Must not write: framework config, fixtures, page objects, utility modules, runtime environment files, executable tests.

### Write boundary when routed to `/automate` with no session yet

Begin at Phase 0 planning only. Do not skip to setup. Do not create any runtime files before `PLAN_PENDING` is persisted and approved.

### Resume message format

When resuming any workflow, always state:
- Current workflow
- Current phase
- Stop reason
- Next expected action
- Exact command to continue

---

## Phase Transition Re-Anchor

At every workflow phase transition, re-state the 3 most relevant Critical Rules from the top of this file before acting. This prevents rule drift across long sessions.

Example (at start of `/automate` Phase 2 — Execution):
```
Re-anchoring rules for EXECUTING phase:
- Rule 4: One runnable test file. WORKING_TEST_FILE is stable.
- Rule 5: Stop at every gate. State persisted before presenting.
- Rule 6: PROTOCOL_GUARD runs before each step write.
```

---

## Browser Tool Priority

| Priority | Tool | Use |
|---|---|---|
| 1 | `postqode_browser_agent` MCP | standard browser work |
| 2 | Playwright browser tooling | fallback browser work |
| 3 | DevTools tooling | last resort only |

See `references/tool-priority.md` for details.

---

## Agent Autonomy Guard

This guard is active throughout every session. Before generating any output that involves writing files or advancing the session, verify each item silently:

- [ ] Am I inside the correct workflow for this action?
- [ ] Did I read `test-session.md` from disk this turn?
- [ ] Am I about to write code that belongs to a future group?
- [ ] Am I about to skip a stop gate?
- [ ] Am I about to create a second runnable test file?
- [ ] Am I about to default framework or language without user confirmation?
- [ ] Am I about to present a success summary while unresolved work remains?
- [ ] Am I about to treat malformed state as valid canonical state?
- [ ] Am I about to make the COM/POM/Flat decision inside `/automate`?

If any item would answer YES → stop and resolve before continuing.

---

## Workflow Commands

| Command | Purpose |
|---|---|
| `/spec-gen` | generate and lock the automation spec |
| `/spec-update` | update a locked spec safely |
| `/automate` | plan, set up, execute, review, validate, and resume |
| `/finalize` | make the architecture decision and refactor with evidence |
| `/debug` | diagnose failures outside the normal group loop |

---

## Reference Registry

Load only what is needed for the current action:

| File | Use |
|---|---|
| `references/session-protocol.md` | state routing and resume logic |
| `references/protocol-guard.md` | full route/write/transition/summary guard |
| `references/personas.md` | persona definitions |
| `references/spec-format.md` | SPEC schema |
| `references/grouping-algorithm.md` | plan grouping |
| `references/tip-protocol.md` | evidence-driven exploration |
| `references/reviewer-rubric.md` | group review |
| `references/recovery-protocol.md` | failure recovery |
| `references/architecture-patterns.md` | final architecture decision |
| `references/element-map-schema.md` | element map format |
| `references/framework-rule-template.md` | framework rule generation |

When a reference file is loaded mid-session, re-read it fresh from disk. Do not assume its content from earlier in the conversation.

---

## Key Always-On Rules

- `rules/core.md` — loaded and confirmed at every handshake
- `rules/automation-standards.md`
- `rules/interaction-fallbacks.md`
- `rules/debug-context-capture.md`
- `rules/[framework].md` when framework is known

---

## Operating Summary

```
Skill orchestrates
  → /spec-gen creates the locked contract
  → /automate executes flat-first, group by group
  → /finalize makes the COM/POM/Flat decision with evidence
  → every stop is stateful and resumable from disk
  → saved state, not memory, is what makes long sessions reliable
```