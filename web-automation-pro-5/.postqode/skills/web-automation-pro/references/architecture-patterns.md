# Architecture Patterns — COM vs POM vs Flat

Primary reference for `/finalize`.

During `/automate`, this file may inform structure hints, but it must not be used to force the final architecture decision early.

---

## Decision Timing

The real architecture decision happens in `/finalize`, after:
- the working flat implementation exists
- element maps have been collected
- reuse signals can be measured
- any local helpers from `/automate` can be assessed in context

`/automate` may gather evidence and create narrow local helpers only. It must not make the final structural decision.

---

## Deterministic Recommendation Heuristics

The user still decides, but the recommendation must be repeatable.

### Recommend COM when all of these are true

1. at least **2 distinct UI blocks** repeat
2. each repeated block appears on **2 or more distinct pages**
3. the repeated blocks contain meaningful behavior, not just trivial navigation links

### Recommend POM when all of these are true

1. the COM threshold is not met
2. page responsibilities are clearly distinct
3. most interactions are page-specific instead of shared-block specific

### Recommend Flat when any of these are true

1. total scope is small, such as **6 or fewer total steps**
2. the flow spans **2 or fewer pages** and shared-block reuse is low
3. refactoring cost is likely higher than the maintainability benefit

These are the recommendation rules, not mandatory outcomes. The user can still choose differently.

---

## Option 1 — Flat

Best when:
- the flow is short
- reuse is low
- this is a proof of concept or one-off validation
- refactoring overhead adds little value

Flat means:
- keep the working spec as the primary artifact
- optionally tidy local helpers
- do not force POM or COM for ceremony alone

---

## Option 2 — POM

Best when:
- pages are distinct
- reuse across pages is limited
- the suite is moderate in size
- a simple page-centered model is sufficient

POM means:
- one class or module per page
- page methods wrap page interactions
- shared logic stays modest and page-centered

---

## Option 3 — COM

Best when:
- shared UI blocks appear across pages
- the app behaves like a component-driven frontend
- the suite will grow
- reuse signals are strong enough to justify shared abstractions

COM means:
- reusable components hold interaction logic
- pages stay thin
- shared UI changes can be updated in one place

---

## Evidence the Architect Should Present

Before asking the user, quantify:
- how many element maps exist
- how many UI blocks repeat across pages
- which blocks repeat
- how many pages are involved
- whether any `/automate` local helpers remained isolated or now point to broader shared structure

---

## Decision Gate Template

```text
📐 Architecture Decision

Evidence gathered:
- [N] element maps analyzed
- [X] repeated UI blocks across [Y] pages
- repeated blocks: [...]
- local helper count: [...]

Recommendation: [COM | POM | Flat]
Reason: [...]

(A) COM
(B) POM
(C) Flat
```

Stop and wait for the user's decision.

---

## Guardrail

Do not ask this question during `/automate` setup or normal group execution.

The purpose of `/finalize` is to make this decision with evidence, not with guesswork.
