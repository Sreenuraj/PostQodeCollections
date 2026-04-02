# Grouping Algorithm — Component-Aware + Code-Aware Batching

Used by the Strategist during `/automate` Phase 0 to group `SPEC.md` steps into execution chunks.

---

## Default Grouping Target

Aim for **2-4 related steps per group**.

Adjust based on:
- component complexity
- step independence
- already-coded steps

---

## Algorithm

### 1. Read step definitions from `SPEC.md`

For each step, note:
- the component or logical UI block
- the action type
- whether it appears already implemented in existing test files

### 2. Workspace scan

Read:
- `package.json`
- framework config files
- existing test specs
- `element-maps/`

### 3. Pre-coded step detection

#### CASE A — no steps match
Proceed to grouping.

#### CASE B — some steps match

Stop and ask the user how to handle the pre-coded steps.

Before stopping, persist:
- `PHASE: PLAN_PENDING`
- `STOP_REASON: PLAN_APPROVAL`
- `GATE_TYPE: CHOICE`
- `ACTIVE_WORKFLOW: AUTOMATE`
- `NEXT_EXPECTED_ACTION: RESOLVE_PRECODED_STEPS`

Record:
- `PRE_CODED_STEPS`
- `PRE_CODED_SOURCE`

#### CASE C — all steps match

Stop and ask whether to re-validate, duplicate, or cancel.

Before stopping, persist:
- `PHASE: PLAN_PENDING`
- `STOP_REASON: PLAN_APPROVAL`
- `GATE_TYPE: CHOICE`
- `ACTIVE_WORKFLOW: AUTOMATE`
- `NEXT_EXPECTED_ACTION: RESOLVE_ALL_PRECODED_STEPS`

---

## Grouping Rules

Apply in priority order:

### Rule A — code-aware batching
If a contiguous set of steps is already implemented, batch it as a pre-coded group instead of splitting it.

### Rule B — component-aware grouping
Group steps that interact with the same logical UI block so one element map can serve the whole group.

### Rule C — cohesive user flow
Keep a single user intent together when that improves execution focus, even if it touches multiple nearby components.

### Rule D — complexity ceiling
Do not exceed **5 effective steps** in one group.

Count these as **2 effective steps**:
- drag-and-drop
- slider or canvas work
- multi-frame or shadow DOM interactions

---

## Plan Table Format

Generate `test.md` as a markdown table:

```text
| Group | Step | Action | Target | Data | Expected Result | Component | Flag |
|---|---|---|---|---|---|---|---|
```

Flag values:
- `✅ PRE-CODED`
- `⚠️ NEEDS_DECOMPOSITION`
- blank for standard new work

---

## Session File Generation After Plan Approval

Generate:
- `test-session.md` with setup + Group 1 rows only
- `active-group.md`
- `pending-groups/`
- `completed-groups/`
- `element-maps/`
- one canonical working test file only

That working test file should:
- have its path persisted in `WORKING_TEST_FILE`
- keep the same path for the full `/automate` run
- contain one runnable test body that grows as groups are appended

Set these fields explicitly:
- `ACTIVE_WORKFLOW: AUTOMATE`
- `PHASE: SETUP`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `ACTIVE_GROUP: G1`
- `ACTIVE_STEP: NONE`
- `LAST_COMPLETED_ROW: NONE`
- `NEXT_EXPECTED_ACTION: RUN_SETUP`

Do not generate one runnable test file per group during `/automate`.

Delete `test.md` only after plan approval has been resolved and setup can proceed.

---

## `active-group.md` Step Template

Each step should include:

```markdown
### Step [N]
- Action: [exact action verb]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [observable outcome]
- Component: [component name or none]
- Element Map: [file path or none]
- Access Context: MAIN_FRAME | IFRAME | SHADOW_DOM
- Step Type: [navigation | fill | click | assert | drag | hover | other]
- Wait Strategy: [TIP-based]
- Timeout Tier: [standard | extended | navigation]
- Anchor Locator: [TIP-based]
- Network Endpoints: [TIP-based]
- Status: [ ]
```

Pending-group files should use the canonical location pattern:
- `pending-groups/g1-[slug].md`
- `pending-groups/g2-[slug].md`
- `pending-groups/g3-[slug].md`
