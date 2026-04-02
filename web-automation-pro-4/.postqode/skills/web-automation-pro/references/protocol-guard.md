# Protocol Guard — Route / Write / Transition / Summary Enforcement

Use this guard before any high-impact move.

This is the system's anti-deviation loop.

It is not the Reviewer.

Difference:
- `Protocol Guard` = pre-action legality check
- `Reviewer` = post-implementation quality check

The guard answers:
- am I allowed to do this next?

The Reviewer answers:
- was the completed group good enough?

If you are following Web Automation Pro, you must not do the opposite of what the workflow allows and hope to correct it later. Run this guard first.

---

## When The Guard Is Mandatory

Run the guard before:
- creating a new file
- editing a file in a new category
- changing workflow phase
- changing active group
- changing stop state
- presenting a summary, checkpoint, or completion message

If the guard fails:
- do not proceed
- repair the state or route first
- if repair requires the user, stop and ask

---

## The Four Checks

### 1. Route Check

Answer:

```text
ROUTE CHECK
- Current workflow: [...]
- Current phase: [...]
- Why this workflow is correct: [...]
- State files read: [...]
- Is another workflow required first? [YES/NO]
```

Hard rule:
- if another workflow is required first, stop and route there

---

### 2. Write Check

Answer:

```text
WRITE CHECK
- File to create or edit: [...]
- File category: [SPEC | SESSION | PLAN | ACTIVE_GROUP | PENDING_GROUP | ELEMENT_MAP | RUNTIME_SETUP | WORKING_TEST | FINAL_REFACTOR | OTHER]
- Current workflow/phase: [...]
- Why this file category is allowed now: [...]
- Which state file proves it: [...]
- Allowed right now? [YES/NO]
```

Hard rule:
- if `Allowed right now?` is `NO`, do not write the file

### File category policy

| Category | Allowed when |
|---|---|
| `SPEC` | `/spec-gen` drafting or approved spec maintenance |
| `SESSION` | any workflow phase that must persist state |
| `PLAN` | `/automate` Phase 0 only |
| `ACTIVE_GROUP` | `/automate` setup, execution, validation, rotation |
| `PENDING_GROUP` | `/automate` planning or rotation |
| `ELEMENT_MAP` | `/automate` execution and finalize evidence reads |
| `RUNTIME_SETUP` | `/automate` setup only, and only after plan approval |
| `WORKING_TEST` | `/automate` setup/execution only |
| `FINAL_REFACTOR` | `/finalize` only |

### Absolute denials

- Before spec approval, do not create `RUNTIME_SETUP`, `WORKING_TEST`, or `FINAL_REFACTOR`
- Before `PLAN_PENDING` is written, do not create `RUNTIME_SETUP`
- Before plan approval, do not create `RUNTIME_SETUP`
- During `/automate`, do not create a second runnable `WORKING_TEST`

---

### 3. Transition Check

Answer:

```text
TRANSITION CHECK
- From: [workflow / phase]
- To: [workflow / phase]
- Evidence earned: [...]
- Required file proof: [...]
- Transition legal? [YES/NO]
```

Hard rule:
- if `Transition legal?` is `NO`, do not change phase

### Critical transitions

| From | To | Required proof |
|---|---|---|
| `NO_SPEC` | `SPEC_DRAFTING` | intake started |
| `SPEC_DRAFTING` | `SPEC_READY` | fresh user approval |
| `SPEC_READY` | `PLAN_PENDING` | `test.md` and canonical `test-session.md` written |
| `PLAN_PENDING` | `SETUP` | fresh user approval |
| `SETUP` | `EXECUTING` | framework resolved, canonical working file chosen |
| `EXECUTING` | `VALIDATING` | reviewer completed |
| `VALIDATING` | `ROTATING` | active-group validation passed |
| `VALIDATING` | `MILESTONE` | explicit gate or refinement stop persisted |
| `ROTATING` | `EXECUTING` | next group promoted canonically |
| `ROTATING` | `FINALIZING` | no pending groups remain |
| `FINALIZING` | `COMPLETE` | final validation passed |

### Absolute denials

- Do not move `SPEC_DRAFTING -> SPEC_READY` without a fresh approval reply
- Do not move `SPEC_READY -> EXECUTING`
- Do not move `PLAN_PENDING -> EXECUTING`
- Do not move an active group to the next one without review/validation evidence
- Do not move `FINALIZING -> COMPLETE` before validation passes

---

### 4. Summary Check

Answer:

```text
SUMMARY CHECK
- Message type: [DRAFT | CHECKPOINT | GATE | COMPLETE]
- Current workflow/phase: [...]
- Stop state persisted already? [YES/NO]
- Does the detailed ledger support the summary? [YES/NO]
- Allowed wording: [...]
```

Hard rule:
- if the ledger does not support the summary, do not show the summary

### Summary wording policy

| Situation | Allowed wording |
|---|---|
| spec not approved | `draft`, `awaiting approval` |
| active group unresolved | `in progress`, `needs repair`, `needs revalidation` |
| milestone or foundation gate | `checkpoint`, `review gate`, `paused` |
| finalized run | `complete` |

### Absolute denials

- do not say `complete` unless `PHASE: COMPLETE`
- do not say `spec locked` unless approval actually happened
- do not say `group complete` unless review and validation evidence exist

---

## Minimal Guard Loop

When in doubt, run this exact sequence:

```text
1. ROUTE CHECK
2. WRITE CHECK
3. TRANSITION CHECK
4. SUMMARY CHECK
```

If any answer is uncertain:
- choose the stricter interpretation
- stop instead of freelancing

---

## Workflow Defaults

### `/spec-gen`
- default write categories: `SPEC`, `SESSION`
- forbidden before approval: `RUNTIME_SETUP`, `WORKING_TEST`

### `/automate` Phase 0
- default write categories: `PLAN`, `SESSION`
- forbidden before plan approval: `RUNTIME_SETUP`, `WORKING_TEST`

### `/automate` Setup
- default write categories: `SESSION`, `ACTIVE_GROUP`, `PENDING_GROUP`, `RUNTIME_SETUP`, `WORKING_TEST`

### `/automate` Execution
- default write categories: `SESSION`, `ACTIVE_GROUP`, `ELEMENT_MAP`, `WORKING_TEST`

### `/finalize`
- default write categories: `SESSION`, `FINAL_REFACTOR`

---

## Operator Mindset

The system does not reward “close enough.”

If the guard says:
- wrong workflow
- wrong phase
- wrong file category
- missing approval
- missing validation

then the correct action is:
- stop
- repair
- re-route

not:
- continue and hope the later summary makes it look consistent
