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

## Role of This Skill

This skill is the orchestrator and router for the system.

It must:
- detect whether the user wants reusable automation or a one-time browser task
- read saved state from disk
- route the user to the correct workflow
- prevent direct freeform coding when the workflow path should be used
- make persona activation visible when the workflow changes phase
- repair malformed saved state before trusting it for resume
- force natural-language automation requests onto the workflow chain before any framework or test files are created

It must not:
- skip the workflow chain
- reconstruct state from memory when state files exist
- make the COM/POM/Flat decision during `/automate`
- silently default framework or language when the user has not confirmed them
- treat non-active-group failures as permission to keep coding
- create multiple runnable group test files during `/automate`
- present a paused progress checkpoint as if the framework were complete
- trust markdown-table session ledgers or stray pending files as valid canonical state
- interpret a natural-language request for automation help as permission to start generic framework scaffolding outside the workflow chain

---

## Workflow Invocation Handshake

If a workflow command is typed directly:

1. announce: `[⚙️ Activating Web Automation Pro Skill]`
2. read `.postqode/rules/core.md`
3. read the requested workflow file
4. continue according to persisted state, not memory

Do not skip this handshake.

If the user enters through natural language instead of an explicit workflow command:

1. announce the routed workflow, for example:
   - `[⚙️ Routing to /spec-gen]`
   - `[⚙️ Routing to /automate]`
2. read the same rules and workflow file that explicit command would have used
3. follow that workflow contract exactly, including persisted stops and approval gates

Natural-language entry is still workflow entry. It is not a freeform framework-generator mode.

---

## Browser Tool Priority

| Priority | Tool | Use |
|---|---|---|
| 1 | `postqode_browser_agent` MCP | standard browser work |
| 2 | Playwright browser tooling | fallback browser work |
| 3 | DevTools tooling | last resort only |

See `references/tool-priority.md` for details.

---

## Step 0 — Mode Detection

Decide first:
- **Recording Mode** for reusable automation
- **Exploration Mode** for one-time browser work

If the user asks to generate tests, automate a flow, or gives a reusable browser scenario, enter Recording Mode immediately.

This applies whether the user gives:
- a vague opener
- a full detailed step list
- a framework-specific request
- or a request spread across multiple messages

---

## Step 1 — State Detection for Recording Mode

Read in this order:
1. `.postqode/spec/SPEC.md`
2. `test-session.md` if present
3. `PHASE`
4. `ACTIVE_WORKFLOW`
5. `STOP_REASON`
6. `LAST_ACTIVE`

Use `references/session-protocol.md` as the canonical state router.

### Required routing

- no locked spec
  - route to `/spec-gen`

- `PHASE: COMPLETE`
  - inform the user the run is already finalized
  - suggest `/debug` or `/spec-update` only if relevant
  - do not route back to `/finalize` by default

- `ACTIVE_WORKFLOW: SPEC_GEN`
  - route to `/spec-gen`

- `ACTIVE_WORKFLOW: SPEC_UPDATE`
  - route to `/spec-update`

- `ACTIVE_WORKFLOW: DEBUG`
  - route to `/debug`

- `ACTIVE_WORKFLOW: FINALIZE`
  - route to `/finalize`

- `ACTIVE_WORKFLOW: AUTOMATE`
  - route to `/automate`

- locked spec exists and no session
  - route to `/automate`

When routing says `/spec-gen`, the skill must not create:
- framework config files
- fixtures
- page objects
- utility modules
- runtime environment files
- executable tests

When routing says `/automate` but `test-session.md` does not yet exist:
- begin at `/automate` Phase 0 planning
- do not skip directly to setup

### Resume messaging rule

When resuming, state clearly:
- current workflow
- current phase
- stop reason
- next expected action
- exact workflow command to continue

---

## Agent Autonomy Guard

If the user asks for browser automation and the workflow path applies:
- do not jump directly into coding
- do not install frameworks immediately
- do not create framework scaffolding, fixtures, config helpers, page objects, or utility modules before the routed workflow explicitly allows it
- do not invent page objects or components before the spec and state model allow it
- do not write runnable future-group code before those groups are explored
- do not validate more than the active group during `/automate`
- do not continue past the Group 1 foundation gate without an explicit user reply
- do not present a success summary while speculative code or non-target validation failures remain
- do not create one runnable test file per group during `/automate`
- do not replay the whole flow before first inspecting the current browser state or saved failure artifacts when diagnosing an in-progress group
- do not treat a malformed `test-session.md`, a stale `active-group.md`, or a stray non-canonical pending-group file as acceptable resume state
- do not turn a general request for automation help into a generic framework-generator checklist

The orchestrator's job is to keep the system on rails.

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

Load only what is needed:

| File | Use |
|---|---|
| `references/session-protocol.md` | state routing and resume logic |
| `references/personas.md` | persona definitions |
| `references/spec-format.md` | SPEC schema |
| `references/grouping-algorithm.md` | plan grouping |
| `references/tip-protocol.md` | evidence-driven exploration |
| `references/reviewer-rubric.md` | group review |
| `references/recovery-protocol.md` | failure recovery |
| `references/architecture-patterns.md` | final architecture decision |
| `references/element-map-schema.md` | element map format |
| `references/framework-rule-template.md` | framework rule generation |

---

## Key Always-On Rules

- `rules/core.md`
- `rules/automation-standards.md`
- `rules/interaction-fallbacks.md`
- `rules/debug-context-capture.md`
- `rules/[framework].md` when available

---

## Operating Summary

The intended operating model is:
- the skill orchestrates
- `/spec-gen` creates the contract
- `/automate` executes flat-first group by group
- `/finalize` makes the actual COM/POM/Flat decision
- every stop is stateful and resumable
- saved state, not memory, is what makes long sessions reliable
