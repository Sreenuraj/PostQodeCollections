# Grouping Algorithm — Component-Aware + Code-Aware Batching

Used by **The Strategist persona** during `/automate` Phase 0 to group SPEC.md steps into execution chunks. The quality of grouping directly affects agent context efficiency.

---

## Default Grouping Target

2–4 related steps per group. Adjust based on:
- Component complexity (complex UI like data grids → tighter groups)
- Step independence (if a step fails, does it invalidate all following steps?)
- Already-coded steps (batch large pre-coded sequences together)

---

## Algorithm — Step by Step

### 1. Read Step Definitions from SPEC.md

Extract the full table from SPEC.md. For each step, note:
- The `Component` column (what UI block is being interacted with)
- The `Action` type (navigate, fill, click, assert, etc.)
- Whether the step appears to be already implemented in existing test files

---

### 2. Workspace Intelligence Scan (Run BEFORE grouping)

```
Scan: package.json → detect framework and test command
Scan: Existing test spec files → grep for step-matching patterns
Scan: component-maps/ → list any existing component maps
```

This scan determines:
- **Path 1:** Framework exists, some steps match existing code
- **Path 2:** Framework exists, no pre-coded steps
- **Path 3:** No framework (install needed first)

---

### 3. Pre-Coded Step Detection (CASE A/B/C)

If the workspace scan found existing spec files AND some steps match:

**CASE A — No steps match existing code:**
Skip this section. Proceed to grouping.

**CASE B — Some steps match:**

⛔ STOP — wait for user:
```
🔍 Workspace scan found steps [X, Y, Z] appear implemented in [spec-file].

How to handle pre-coded steps?
  (A) EXTEND — Add new steps to the existing test file
  (B) SEPARATE — Create a new isolated test file

In both cases:
- I'll create an isolation spec with the pre-coded steps
- The checklist will only contain rows for NEW steps
- Pre-coded steps will replay automatically to reach the correct starting state
```
**⛔ STOP — wait for reply.**

Record: `IMPLEMENTED_STEPS: [numbers]`, `IMPLEMENTED_SOURCE: [file]`, `MODE: EXTEND | SEPARATE`

**CASE C — ALL steps match:**

⛔ STOP — wait for user:
```
🔍 All requested steps appear already implemented in [spec-file].
  (A) Re-validate — Run existing test to confirm it still passes
  (B) Duplicate — Create a separate test (different test data)
  (C) Cancel
```
**⛔ STOP — wait for reply.**

---

### 4. Grouping Rules

Apply in priority order:

#### Rule A — CODE-AWARE BATCHING (Highest Priority)
If Steps 1-5 are all pre-coded, batch them as "Group 0: Pre-Coded Steps". Do NOT split pre-coded steps across groups. The Explore phase will replay them as a single isolation spec run.

#### Rule B — COMPONENT-AWARE GROUPING
Group steps that interact with the **same logical UI component**. A component is one logical unit (e.g., `login-form`, `data-grid`, `vote-slider`). Steps that share a component should usually be in the same group so one component map serves all steps in the group.

**Example:**
- Steps 2, 3, 4 all interact with `login-form` → Group 1: Login
- Steps 5, 6 navigate and load `meeting-list` → Group 2: Meeting Selection
- Steps 7, 8 use `vote-slider` → Group 3: Vote Allocation
- Steps 9, 10 use `vote-submit` → Group 4: Submit and Confirm

#### Rule C — COHESIVE USER FLOW
When steps form a single user intent (e.g., "configure the data export"), keep them together even if they span multiple components. Agent context stays focused on achieving one user goal per group.

#### Rule D — COMPLEXITY CEILING
Never put more than 5 steps in one group. Complex steps (drag-and-drop, slider, canvas) count as 2x. If a group would exceed 5 effective steps, split it.

---

### 5. Plan Table Format

Generate the plan as a Markdown table in `test.md`:

```
| Group | Step | Action | Target | Data | Expected Result | Component | Flag |
|---|---|---|---|---|---|---|---|
| 0 | 1 | Navigate + Login | Login page | User: x, Pass: y | Dashboard loads | login-form | ✅ PRE-CODED |
| 0 | 2 | Click Meeting | Meeting link | — | Meeting page loads | — | ✅ PRE-CODED |
| 1 | 3 | Drag slider | Vote slider | 60% | Slider shows 60% | vote-slider | — |
| 1 | 4 | Assert value | Slider display | 60±1 | Correct % shown | vote-slider | — |
| 2 | 5 | Click Submit | Submit button | — | Confirm modal appears | vote-submit | — |
| 2 | 6 | Click Confirm | Confirm button | — | Success toast: "Recorded" | vote-submit | — |
```

**Flag values:**
- `✅ PRE-CODED` — step already implemented, will replay via isolation spec
- `⚠️ NEEDS_DECOMPOSITION` — step is vague, needs clarification
- _(blank)_ — standard new step

---

### 6. Generate Session Files (After Plan Approval)

Stateless generation rule:
- **Only** generate checklist rows for SETUP phase and Group 1
- Do NOT generate rows for Groups 2, 3, etc.
- Future group rows are generated dynamically during ROTATE (see `session-protocol.md`)

**Files to create:**
- `test-session.md` — header + SETUP rows + Group 1 rows only
- `active-group.md` — Group 1 step definitions (full template per step)
- `pending-groups/group-2.md` — Group 2 step definitions (step template only, no checklist rows)
- `pending-groups/group-N.md` — same for all remaining groups
- `completed-groups/` — empty directory
- `component-maps/` — empty directory (populated during exploration)

**After files created:** Delete the temporary `test.md` file.

---

## active-group.md Step Template

Each step in `active-group.md` follows this structure:

```markdown
### Step [N]
- Action: [exact action verb]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [observable outcome]
- Component: [component name or none]
- Component Map: [file path or (none)]
- Access Context: MAIN_FRAME | IFRAME | SHADOW_DOM
- Step Type: [navigation | fill | click | assert | drag | hover | other]
- Wait Strategy: [TIP-based — filled during exploration]
- Timeout Tier: [standard | extended | navigation]
- Anchor Locator: [TIP-based — filled during exploration]
- Network Endpoints: [TIP-based — filled during exploration]
- Status: [ ]
```
