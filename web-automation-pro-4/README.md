# Web Automation Pro

Spec-driven web automation for long, stateful browser flows.

---

## What It Is

Web Automation Pro is a PostQode setup for turning raw browser requirements into maintainable automation without losing control when:
- the steps are long,
- the AUT is complicated,
- the session exceeds one context window,
- or the right architecture is not obvious up front.

The system is built around three ideas:
- **The skill orchestrates**
- **The workflows execute**
- **The code stays flat until there is enough evidence to refactor**

This hardened version also adds:
- explicit stop reasons
- deterministic resume fields
- narrow helper extraction rules
- repeatable finalize heuristics
- explicit framework and language confirmation
- active-group-only validation
- a ban on runnable future-group code during `/automate`
- one stable working test file during `/automate`
- refinement checkpoints that persist exact failure state before handoff
- strict natural-language routing before any scaffolding is created
- a protocol-guard loop before writes, transitions, and completion claims

The `Protocol Guard` and the `Reviewer` do different jobs:
- the guard checks whether the next move is allowed
- the reviewer checks whether the finished group is good enough

---

## Lifecycle

```text
Raw requirements
  ↓
/spec-gen
  ↓
Locked SPEC.md
  ↓
/automate
  ↓
Plan persisted + approved
  ↓
Flat-first group execution
  ↓
Review + validate per group
  ↓
Resume anytime using saved state
  ↓
/finalize
  ↓
Evidence-based COM / POM / Flat decision
  ↓
Refactor + validate + cleanup
```

---

## Core Model

### Skill

The skill is the orchestrator and router. It reads saved state, decides which workflow should run next, and keeps the agent from skipping the system path.

That includes natural-language starts in general. A vague opener, a fully detailed browser flow, or a framework-specific request must still route into `/spec-gen` or `/automate`; none of them should trigger a freeform framework-generator mode.

### Workflows

The workflows are stateful executors:
- `/spec-gen`
- `/automate`
- `/finalize`
- `/spec-update`
- `/debug`

### Rules

Rules are always-on constraints:
- anti-batching
- stop gates
- state-first resume behavior
- flat-first execution standards
- visible persona activation
- ledger sync between `test-session.md` and `active-group.md`

---

## Architecture Timing

During `/automate`, the system writes **flat-first** code and gathers evidence:
- TIP observations
- element maps
- reuse signals

That code lives in one stable working test file with one runnable test body for the whole `/automate` run. It does not rotate into `g1-*`, `g2-*`, or other per-group runnable files.

It may create a small neutral helper only after the same interaction pattern has appeared in at least 2 completed explored steps in the same run. It still does **not** make the final architecture decision there.

The real `COM / POM / Flat` choice happens in `/finalize`, when the Architect has full evidence from all groups.

---

## Resumability

This system is designed to survive context loss.

State is persisted in:
- `.postqode/spec/SPEC.md`
- `test.md`
- `test-session.md`
- `active-group.md`
- `pending-groups/`
- `completed-groups/`
- `element-maps/`

Key ledger fields include:
- `PHASE`
- `STOP_REASON`
- `ACTIVE_WORKFLOW`
- `ACTIVE_GROUP`
- `ACTIVE_STEP`
- `LANGUAGE`
- `WORKING_TEST_FILE`
- `VALIDATION_STATE`
- `LAST_FAILURE_REASON`
- `NEXT_EXPECTED_ACTION`

That is what lets the skill route correctly in the same session or a fresh one.

---

## Why This Exists

The goal is to help an AI agent automate long UI flows without falling into the usual traps:
- jumping into code too early,
- silently picking a stack the user never chose,
- forgetting where it is,
- over-abstracting too soon,
- validating too much at once,
- hallucinating future-group selectors,
- batching too much work into one step,
- or losing continuity across sessions.

The system is opinionated on purpose so the agent follows a reliable path instead of improvising.

---

## Workflow Diagrams

A full system diagram set is available in [WORKFLOW-DIAGRAMS.md](./WORKFLOW-DIAGRAMS.md).

It includes:
- whole-system lifecycle,
- skill orchestration and resume routing,
- `/spec-gen`,
- `/automate` state flow,
- per-group execution,
- architecture timing,
- `/finalize`,
- stale-session handling,
- and failure recovery situations.
