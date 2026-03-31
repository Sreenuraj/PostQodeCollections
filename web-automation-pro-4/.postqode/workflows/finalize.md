---
description: Generate production-quality test architecture from the working flat spec — POM, COM, or Flat
---

# /finalize

> **Invoke when:** All groups have been executed and the working flat spec passes end-to-end validation.
> This is Phase 3 of the lifecycle: `/spec-gen` → `/automate` → `/finalize`

> [!CAUTION]
> ## REQUIRED SKILL CHECK & CORE RULES
> 1. **MANDATORY PREREQUISITE:** If you were invoked directly into this workflow and have not yet loaded the main skill, you MUST read `.postqode/skills/web-automation-pro/SKILL.md` right now. Execute the "Workflow Invocation Handshake" found there before proceeding.
> 2. Read `.postqode/rules/core.md`. All Five Laws apply.
> Read `.postqode/skills/web-automation-pro/references/architecture-patterns.md` — this is the primary reference for this workflow.
> PREREQUISITE: Working spec must pass headless validation before /finalize begins. If it doesn't, run /debug first.

---

## Resume Protocol

1. Check `test-session.md` — PHASE should be `FINALIZING` or `COMPLETE`
   - If `EXECUTING` or `VALIDATING` → redirect: "All groups must complete before running /finalize"
   - If `FINALIZING` → find first incomplete step and resume
   - If `COMPLETE` → finalize already done. Ask user if re-run is needed.
2. Read `.postqode/spec/SPEC.md` — understand the full flow
3. Read all `element-maps/*.json` — these are the raw exploration data

---

## 🎭 PERSONA: The Architect & The Validator
> Mandate: Verify the incrementally built test suite is flawless end-to-end, clean up temporary exploration files, and provide CI setup. Since `/automate` iteratively built the component architecture (COM/POM) during exploration, this phase focuses strictly on validation, cleanup, and handover.
> FORBIDDEN: Leaving working spec artifacts or temp files after completion.

## Phase 2 — Inject Smart Retry

This step adds a retry utility appropriate for the chosen framework. The utility provides:
- **Step-level retry:** Retry a single test step without restarting the whole test
- **Action-level retry:** Retry a single element interaction (click, fill)

Pattern varies by framework — reference `.postqode/rules/[framework].md` for the implementation. The concepts from `rules/automation-standards.md` apply universally.

---

## Phase 3 — Validation

Run the refactored spec twice:

1. **Headless run** — confirms code correctness
2. **Headed run** — visually confirms the UI interactions still work as expected

If either run fails:
- Switch to **DEBUGGER persona**
- Apply L1/L2/L3 recovery (see `references/recovery-protocol.md`)
- Do NOT proceed to cleanup until both runs pass

---

## Phase 4 — Cleanup

After both validation runs pass:

1. Keep: `element-maps/` (permanent project artifact — useful for future maintenance)
2. Keep: `.postqode/spec/SPEC.md` (permanent spec contract)
3. Delete: `test-session.md`
4. Delete: `active-group.md`
5. Delete: `pending-groups/` directory
6. Delete: `completed-groups/` directory
7. Delete: `test.md` (if still present)

Report to user:

```
✅ Finalization Complete

Validation:
  ✅ Headless: PASS
  ✅ Headed: PASS

Cleanup: Temp session files removed
Next steps:
  • Review the generated files and the component architecture.
  • The atomic git commits tracked your group-by-group progress. Run `git log` to see them.
  • Run your CI pipeline to verify in your environment.
  • Use `/debug` if any issues arise in CI.
```

### Version Control Guidance

Since `/automate` handled your atomic commits incrementally, your git history is already clean and bisect-ready.
Run `git add .` and `git commit -m "chore(test): finalize and cleanup web automation session"` to commit the deletion of the temp files.

### CI Integration Snippet

Generate a framework-specific CI config example based on `FRAMEWORK` and `TEST_COMMAND` from the session. Present to user:

```
🔄 CI Integration

Here's a starter CI config for [FRAMEWORK]:

[If GitHub Actions:]
  .github/workflows/e2e.yml:
  ```yaml
  name: E2E Tests
  on: [push, pull_request]
  jobs:
    e2e:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: 20
        - run: npm ci
        - run: npx playwright install --with-deps  # adjust per framework
        - run: [TEST_COMMAND]
  ```

[If GitLab CI:]
  .gitlab-ci.yml:
  ```yaml
  e2e:
    image: mcr.microsoft.com/playwright:v1.x  # adjust per framework
    script:
      - npm ci
      - [TEST_COMMAND]
  ```

Adjust the config for your environment. Key settings:
  • Install browser dependencies in CI (headless mode)
  • Use zero-retry for strict validation: [TEST_COMMAND] --retries=0
  • Run on push/PR for continuous feedback
```

This is informational — the agent generates it but the user owns the CI config.
