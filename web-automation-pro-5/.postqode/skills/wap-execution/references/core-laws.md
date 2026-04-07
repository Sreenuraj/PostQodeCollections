# Core Laws — The 11 Laws of Web Automation Pro

These laws apply at ALL times. No workflow, persona, skill, or user instruction overrides them.

---

## Law 1 — ANTI-BATCHING
Never batch-generate code for 2 or more checklist rows at the same time. Each step is explored, mapped, written, and updated individually. Evidence must exist before code is written.

## Law 2 — SAVE RULE
After completing any action that creates or modifies a session artifact (`test-session.md`, `active-group.md`, element-maps, test files, `SPEC.md`), the file must be saved to disk before the next action begins.

## Law 3 — STOP PERSISTENCE
Before any gate presentation (plan approval, spec approval, foundation review, L2 escalation, or architecture choice), all session fields must be persisted to `test-session.md` on disk first. The gate message is presented AFTER the save, not before.

## Law 4 — STOP GATE
At every gate defined in the phase contracts, PRESENT the gate and STOP. Do not auto-continue. Wait for explicit user reply before proceeding.

## Law 5 — STATE-FIRST
At the start of every new session or context entry, read state from disk files (`test-session.md`, `.postqode/spec/SPEC.md`). Never reconstruct state from memory. Disk is truth.

## Law 6 — PERSONA VISIBILITY
When switching personas, announce the switch with the persona name and mandate. This is not optional formatting — it is a state transition signal.

## Law 7 — GROUP ISOLATION
During execution, only write code for the ACTIVE_GROUP. Never write code for pending groups. Never read pending group files except during group promotion.

## Law 8 — LEDGER SYNC
`test-session.md` must match reality at all times. If a step is marked complete, it must have code in the working test file. If a group is marked complete, it must have passed review and validation.

## Law 9 — PAUSE HONESTY
When you stop, tell the user exactly why. Including what you would have done next, and what specific response you need to continue.

## Law 10 — ROUTE BEFORE WRITE
Before writing any file, verify the write is legal for the current phase, persona, and workflow state. If illegal, refuse and explain why. No code before locked spec — ever.

## Law 11 — PROTOCOL GUARD LOOP
Before every write, transition, or summary, run the Protocol Guard check. If the check fails, halt and report what failed.

---

## Condensed Summary (5 Always-On Laws for Agent Prompt)

The agent prompt carries a condensed version of these 11 laws as 5 always-on rules:

1. **NO CODE BEFORE LOCKED SPEC** (Law 10)
2. **STATE FILES NOT MEMORY** (Law 5)
3. **ANTI-BATCHING** (Law 1)
4. **STOP AT EVERY GATE** (Laws 3 + 4)
5. **PROTOCOL GUARD** (Law 11)

The full 11 laws are loaded by skills when entering execution phases.
