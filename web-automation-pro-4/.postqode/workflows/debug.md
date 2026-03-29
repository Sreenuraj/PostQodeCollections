---
description: Smart failure recovery for broken web automation tests
---

# /debug

> **Invoke when:** A test that was previously working is now failing, OR a newly written test fails outside of the normal `/automate` execution flow.
> Use `/automate` for failures during group execution — it has L1/L2/L3 built in.
> Use `/debug` for standalone diagnosis of a broken test file.

> [!CAUTION]
> ## CORE RULES — LOAD BEFORE STARTING
> Read `.postqode/rules/core.md` and `.postqode/rules/debug-context-capture.md`. All Five Laws apply.
> CLEAN FIRST: Always check for and delete any leftover `debug-context/` directory before starting a new debug session.

---

## 🎭 PERSONA: The Debugger
> Mandate: Find the root cause of this failure using evidence — not guesses — then fix it with the minimum change possible.
> Thinking mode: Methodical and evidence-driven. Never jump to conclusions. Confirm root cause before touching code.
> FORBIDDEN: Guessing without evidence. Making broad code changes. Fixing multiple things at once. Leaving debug injection code in the spec after cleanup.

---

## Phase 0 — Setup

1. **Cleanup check:** Delete `debug-context/` if it exists from a previous session
2. **Read spec file** — identify the failing test(s) and the relevant code section
3. **Read `.postqode/spec/SPEC.md`** — understand what the test is supposed to do
4. **Read `.postqode/rules/[framework].md`** (if exists) — understand framework conventions

---

## Phase 1 — Initial Run (Headed)

Run the failing test in **headed mode** (visible browser) first:

```
Purpose: Watch what actually happens vs. what should happen
```

Observe during the run:
- At what step does it fail?
- What does the page look like when it fails?
- Does an error message appear? What does it say?
- Is the element missing, or is it there but wrong state?
- Is there a loading state that never completes?

Take notes. Do NOT modify any code yet.

**If headed run passes but headless fails:**
This is a timing issue. The fix is almost always adding an explicit wait for a specific element/network event (not sleep). Go to Phase 3 immediately.

---

## Phase 2 — Debug Bundle Capture

Inject debug context capture into the failing test following `rules/debug-context-capture.md`:

1. Inject `// DEBUG-HELPER` function at the end of the spec file
2. After the failing step, inject `// DEBUG-CONTEXT` call: `captureDebugContext(page, 'step-[N]')`
3. Run the test (headless is fine now — we're collecting artifacts)
4. Read `debug-context/step-[N].json`
5. View `debug-context/step-[N].jpg`

Analyze the debug bundle (see `rules/debug-context-capture.md` — AI Analysis Protocol):
- Screenshot: Is the element visible? Is the page in the right state?
- Interaction log: Was focus on the right element?
- Network log: Any 4xx/5xx errors explaining the failure?
- DOM: Find the target element — what is its actual structure and state?

---

## Phase 3 — Root Cause Confirmation

**Do not fix until root cause is confirmed.** Present diagnosis to user:

```
🔍 Diagnosis — Step [N]: [step description]

Error: [exact error from test runner]

Root cause: [specific, evidence-backed explanation]
Evidence:
  • Screenshot shows: [what was visible]
  • DOM analysis: [what the element looks like / why the locator failed]
  • Network: [any API failures? timing issues?]

Proposed fix: [exact minimal change — one thing only]

(A) Apply this fix
(B) I have more context — let me tell you more
(C) This is the wrong diagnosis
```

**⛔ STOP — wait for user reply.**

---

## Phase 4 — Apply Fix

After user confirms diagnosis:

1. Apply the minimum change necessary
2. Re-run test headless with fix applied
3. If PASS → go to Phase 5 (cleanup)
4. If still FAIL → return to Phase 2 (new debug bundle with updated code)
5. Maximum 3 fix-attempt cycles before escalating back to user with updated analysis

---

## Phase 5 — Cleanup

After fix is confirmed working:

1. Remove `// DEBUG-HELPER` block from spec file
2. Remove all `// DEBUG-CONTEXT` lines from spec file
3. Delete `debug-context/` directory
4. Run test one final time headless to confirm clean pass

Report to user:
```
✅ Debug Complete

Fixed: [what was fixed]
Test status: PASSING (headless, zero retries)
Cleanup: Debug injection removed, debug-context/ deleted

Suggested follow-up:
  • Update .postqode/spec/SPEC.md if the expected behavior changed
  • Update component-maps/[component].json if the UI structure changed
  • Consider running /finalize if this fix reveals a POM-level issue
```
