# Web Automation Pro v5.1 — Fix Plan

**Date**: July 4, 2026  
**Status**: DRAFT — Awaiting approval  
**Goal**: Fix the broken v5 agent system so it actually follows its own rules

---

## Problem Summary

The v5 `web-automation-pro` agent was designed as a spec-driven orchestrator but in practice:
1. Ignores its own #1 rule (no code before spec) within 90 seconds
2. References non-existent tools (`playwright-cli`, `use_subagents`)
3. Has a 4,500-word prompt that the LLM can't reliably follow
4. Never reaches subagents because it never follows the workflow

See: `.postqode/agents/AGENT-EVALUATION-REPORT.md` for full evidence.

---

## Architecture: v5.1

**Core insight**: v4's architecture (short orchestrator + on-demand workflows) worked better than v5's (everything in one massive prompt). v5.1 combines the best of both:

- **Agent** as orchestrator (like v5) — gives us intent detection, memory, skill invocation
- **Skills** as phase executors (like v4 workflows) — loaded on-demand, don't bloat the agent prompt
- **References** stay as-is — loaded by skills when needed
- **Subagents** parked for now — reviewer/element-mapper logic embedded in execution skill

```
web-automation-pro (AGENT) — ~1,200 words, always in context
  │
  ├── skills: (declared in agent frontmatter)
  │   ├── wap-spec-creation    — /spec-gen procedure
  │   ├── wap-execution        — /automate procedure (plan + setup + group loop)
  │   ├── wap-finalize         — /finalize procedure
  │   ├── wap-spec-update      — /spec-update procedure
  │   └── wap-debug            — /debug procedure
  │
  ├── references/ (loaded on-demand by skills)
  │   ├── core-laws.md              ← NEW: full 11 laws (condensed 5 in agent)
  │   ├── tip-protocol.md           ← existing
  │   ├── element-map-schema.md     ← existing
  │   ├── reviewer-rubric.md        ← existing
  │   ├── grouping-algorithm.md     ← existing
  │   ├── architecture-patterns.md  ← existing
  │   ├── spec-format.md            ← existing
  │   ├── framework-rule-template.md ← existing
  │   ├── interaction-fallbacks.md  ← existing
  │   ├── session-protocol.md       ← existing (simplified)
  │   ├── protocol-guard.md         ← existing
  │   ├── automation-standards.md   ← from v4 rules/
  │   ├── personas.md               ← existing
  │   ├── recovery-protocol.md      ← existing
  │   └── tool-priority.md          ← existing (fixed)
  │
  └── agents/ (parked — not invoked in v5.1)
      ├── reviewer.md               ← preserved, fixed, not invoked
      └── element-mapper.md         ← preserved, fixed, not invoked
```

---

## File-by-File Plan

### Phase 1: Create the Agent (rewrite)

#### File: `.postqode/agents/web-automation-pro.md`

**Action**: REWRITE from scratch (~1,200 words)

**Frontmatter**:
```yaml
---
name: web-automation-pro
description: |
  Your collaborative web automation partner. Tell me what you want to automate in plain language 
  and I'll handle the rest — asking the right questions, drafting a spec for your approval, 
  planning execution, exploring each step in a real browser, writing evidence-based code, 
  reviewing quality, validating headless, and finalizing the architecture. I detect your intent 
  automatically — no commands to memorize. I keep you informed and in control at every step.

  I also handle: resuming interrupted sessions, updating specs when the app changes, debugging 
  failures with L1→L2→L3 recovery, and building on past project decisions via persistent memory.

  Use me when you want to create, run, fix, or evolve browser automation — for any framework 
  (Playwright, Cypress, Selenium, WebdriverIO, Puppeteer) or when SPEC.md / test-session.md 
  already exist in your workspace.
model: inherit
memory: project
max_turns: 100
skills: wap-spec-creation, wap-execution, wap-finalize, wap-spec-update, wap-debug
---
```

**System prompt structure** (~1,200 words):

```
⚠️ ABSOLUTE RULE (repeated at top and bottom):
You MUST create and lock SPEC.md BEFORE any code, framework setup, or npm commands.
If the user asks to "build a framework" or "create tests", your FIRST action is 
ALWAYS spec creation via the wap-spec-creation skill. ZERO exceptions.

§ 1 — WHO YOU ARE
[3 sentences: spec-driven browser automation agent, orchestrator role]

§ 2 — COMMUNICATION PROTOCOL  
[5 rules: tell before acting, summarize after, announce transitions, present options, short updates]

§ 3 — THE FIVE ALWAYS-ON LAWS
1. NO CODE BEFORE LOCKED SPEC (Law 10 from core.md)
2. STATE FILES NOT MEMORY — read test-session.md and SPEC.md from disk (Law 5)
3. ANTI-BATCHING — one step at a time during execution (Law 1)
4. STOP AT EVERY GATE — persist state, present gate, wait (Laws 3+4)
5. PROTOCOL GUARD — verify route/write/transition before acting (Law 11)

§ 4 — BROWSER TOOL
Primary: postqode_browser_agent (browser_navigate, browser_click, browser_snapshot, etc.)
Fallback: execute_command with actual Playwright CLI
Last resort: chrome-devtools MCP (only for perf traces, device emulation)

§ 5 — INTENT DETECTION & ROUTING
[Intent detection matrix — same as v5 § 8, condensed]
[Phase routing table — same as v5 § 8]
[Mode detection: Recording vs Exploration]

§ 6 — SKILL INVOCATION
When entering a phase, invoke the corresponding skill:
| Phase | Skill to invoke | When |
| Spec creation | wap-spec-creation | No locked spec exists |
| Planning/Setup/Execution | wap-execution | Locked spec, entering automate |
| Finalize | wap-finalize | All groups complete |
| Spec update | wap-spec-update | User requests spec change |
| Debug | wap-debug | Validation fails or user reports bug |

§ 7 — STATE MODEL (condensed)
[6 core states: SPEC_DRAFTING, PLANNING, EXECUTING, DEBUGGING, FINALIZING, COMPLETE]
[10 essential ledger fields]
[Resume protocol: read disk → route → present resume summary]

§ 8 — MEMORY PROTOCOL
[What to save and when — same as v5 § 12 but condensed]

⚠️ ABSOLUTE RULE (repeated at bottom):
You MUST create and lock SPEC.md BEFORE any code, framework setup, or npm commands.
NEVER offer architecture choices (POM/COM/Flat) until the finalize phase.
```

---

### Phase 2: Create the Skills (5 new skills)

All skills go in: `.postqode/skills/` (each in its own directory with `SKILL.md`)

#### Skill 1: `.postqode/skills/wap-spec-creation/SKILL.md`

**Source**: v4 `workflows/spec-gen.md` + v5 `references/spec-creation-procedure.md`

**Frontmatter**:
```yaml
---
name: wap-spec-creation
description: |
  Spec creation procedure for Web Automation Pro. Activated when the user wants to 
  automate a browser flow and no locked SPEC.md exists. Handles workspace scan, 
  intake interview, spec drafting, self-critique, and approval gate.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---
```

**Content includes**:
- Entry checklist (from v4 spec-gen.md)
- Strategist persona declaration
- Write boundary (SPEC and SESSION files only — NO framework files)
- Phase 1: Workspace intelligence scan
- Phase 2: Intake interview (mandatory fields: URL, flow, framework, language)
- Phase 3: Draft SPEC.md (load `references/spec-format.md`)
- Phase 4: Self-critique checklist
- Phase 5: Present and approve (persist stop state first)
- On approval: lock spec, set ACTIVE_WORKFLOW: AUTOMATE
- Protocol Guard inline (condensed)

**References to load**: `spec-format.md`, `protocol-guard.md`

---

#### Skill 2: `.postqode/skills/wap-execution/SKILL.md`

**Source**: v4 `workflows/automate.md` + v5 `references/execution-procedure.md`

**Frontmatter**:
```yaml
---
name: wap-execution
description: |
  Execution procedure for Web Automation Pro. Handles planning, setup, group-by-group 
  execution, review, validation, and rotation. Activated after spec is locked.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---
```

**Content includes**:
- Phase 0: Planning (Strategist persona)
  - Read locked spec, workspace scan, detect pre-coded steps
  - Group steps (load `references/grouping-algorithm.md`)
  - Write test.md + test-session.md with PLAN_PENDING
  - Plan approval gate
- Phase 1: Setup (Engineer persona)
  - Framework detection/install
  - Create single working test file
  - Set TEST_COMMAND
- Phase 2: Group loop (Engineer persona)
  - Per-step: Explore with TIP → Element map → Write flat code → Update state
  - Load `references/tip-protocol.md` and `references/element-map-schema.md`
  - Reviewer rubric (embedded, load `references/reviewer-rubric.md`)
  - Validation: headless, zero retries
  - Rotation: collapse → promote → milestone check
- Foundation trust gate (Group 1 only)
- Milestone logic
- Browser tool: `postqode_browser_agent` (load `references/tool-priority.md`)
- Flat-first execution policy (load `references/automation-standards.md`)
- Full 11 laws (load `references/core-laws.md`)
- Persona definitions (load `references/personas.md`)
- Protocol Guard (load `references/protocol-guard.md`)

**References to load**: `grouping-algorithm.md`, `tip-protocol.md`, `element-map-schema.md`, `reviewer-rubric.md`, `automation-standards.md`, `core-laws.md`, `personas.md`, `protocol-guard.md`, `tool-priority.md`, `interaction-fallbacks.md`, `framework-rule-template.md`

---

#### Skill 3: `.postqode/skills/wap-finalize/SKILL.md`

**Source**: v4 `workflows/finalize.md` + v5 `references/finalize-procedure.md`

**Frontmatter**:
```yaml
---
name: wap-finalize
description: |
  Finalization procedure for Web Automation Pro. Analyzes reuse evidence from element maps, 
  recommends COM/POM/Flat architecture, applies user's choice, validates, and cleans up.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---
```

**Content includes**:
- Architect persona declaration
- Read working spec + all element maps
- Quantify reuse signals with explicit heuristics
- Present evidence-based recommendation (load `references/architecture-patterns.md`)
- Architecture choice gate (user decides)
- Refactor according to choice
- Validate finalized suite
- Cleanup session artifacts
- Set PHASE: COMPLETE

**References to load**: `architecture-patterns.md`, `protocol-guard.md`

---

#### Skill 4: `.postqode/skills/wap-spec-update/SKILL.md`

**Source**: v4 `workflows/spec-update.md` + v5 `references/spec-update-procedure.md`

**Frontmatter**:
```yaml
---
name: wap-spec-update
description: |
  Spec update procedure for Web Automation Pro. Handles surgical updates to a locked SPEC.md 
  when the application changes or steps need modification. Identifies stale groups.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---
```

**Content includes**:
- Understand the change request
- Apply surgical changes to SPEC.md
- Identify stale groups (mark in test-session.md)
- Re-lock spec
- Route back to execution if needed

**References to load**: `spec-format.md`, `protocol-guard.md`

---

#### Skill 5: `.postqode/skills/wap-debug/SKILL.md`

**Source**: v4 `workflows/debug.md` + v5 `references/debug-and-recovery.md`

**Frontmatter**:
```yaml
---
name: wap-debug
description: |
  Debug and recovery procedure for Web Automation Pro. Handles L1 auto-recovery, 
  L2 human-guided recovery, and L3 graceful degradation when validation fails.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---
```

**Content includes**:
- Debugger persona declaration
- L1: Auto-recovery (2 attempts, evidence-based)
- L2: Human-guided (persist L2_ESCALATION, ask user)
- L3: Graceful degradation
- Debug context capture (from v4 `rules/debug-context-capture.md`)
- Recovery protocol (load `references/recovery-protocol.md`)

**References to load**: `recovery-protocol.md`, `protocol-guard.md`

---

### Phase 3: Create/Update Reference Files

#### NEW: `references/core-laws.md`

**Source**: v4 `rules/core.md` (the full 11 laws)

**Action**: Create new file. Contains the complete 11 laws from v4's core.md, formatted as a reference that skills can load.

---

#### NEW: `references/automation-standards.md`

**Source**: v4 `rules/automation-standards.md`

**Action**: Create new file (or move from rules/ to references/). Contains flat-first execution policy, locator hierarchy, wait strategy principles.

---

#### UPDATE: `references/tool-priority.md`

**Source**: v4 `references/tool-priority.md` (this was correct in v4!)

**Action**: Copy from v4. This file correctly references `postqode_browser_agent` as Priority 1. The v5 version incorrectly replaced this with `playwright-cli`.

---

#### UPDATE: `references/session-protocol.md`

**Action**: Simplify. Reduce from 11 states to 6 core states. Reduce ledger fields from 20+ to 10.

**Simplified states**:
```
SPEC_DRAFTING → PLANNING → EXECUTING → DEBUGGING → FINALIZING → COMPLETE
```

**Essential ledger fields** (10):
```
PHASE, ACTIVE_GROUP, ACTIVE_STEP, WORKING_TEST_FILE, FRAMEWORK, 
LANGUAGE, TURBO, SPEC_STATUS, BROWSER_STATUS, LAST_COMPLETED_ROW
```

Plus stop-state fields when paused:
```
STOP_REASON, GATE_TYPE, ACTIVE_WORKFLOW, NEXT_EXPECTED_ACTION
```

---

#### KEEP AS-IS (no changes needed):
- `tip-protocol.md`
- `element-map-schema.md`
- `reviewer-rubric.md`
- `grouping-algorithm.md`
- `architecture-patterns.md`
- `spec-format.md`
- `framework-rule-template.md`
- `interaction-fallbacks.md`
- `personas.md`
- `protocol-guard.md`

---

### Phase 4: Update Subagent Files (park, don't delete)

#### UPDATE: `.postqode/agents/reviewer.md`

**Changes**:
- Fix "working spec file" → "working test file" ambiguity
- Add output protocol section
- Remove `memory: project` (stateless)
- Add comment: "PARKED — not invoked in v5.1. Logic embedded in wap-execution skill."

#### UPDATE: `.postqode/agents/element-mapper.md`

**Changes**:
- Add output protocol section
- Remove `memory: project` (stateless)
- Increase `max_turns` from 5 to 8
- Add comment: "PARKED — not invoked in v5.1. Logic embedded in wap-execution skill."

---

### Phase 5: Cleanup

#### DELETE: `.postqode/skills/web-automation-pro/SKILL.md`

Already marked as deprecated. Remove entirely — the agent is the orchestrator now.

#### MOVE: Reference files

Move all references from `.postqode/skills/web-automation-pro/references/` to `.postqode/skills/wap-execution/references/` (or a shared location). Skills need to be able to find them.

**Decision needed**: Should references live:
- (A) Under each skill that uses them (duplicated if shared)
- (B) In a shared location like `.postqode/references/` that all skills reference
- (C) Keep in current location and have skills reference the full path

**Recommendation**: Option (B) — create `.postqode/references/` as a shared reference library. All skills load from there.

#### UPDATE: `.postqode/memory/MEMORY.md`

Remove stale entries. The memory index should only reference files that actually exist.

---

## Migration Checklist

### Phase 1: Agent Rewrite
- [ ] Rewrite `.postqode/agents/web-automation-pro.md` (~1,200 words)
- [ ] Add `skills` metadata to frontmatter
- [ ] Set `max_turns: 100`
- [ ] Include `postqode_browser_agent` as browser tool
- [ ] Repeat critical rule at top AND bottom of prompt

### Phase 2: Create Skills
- [ ] Create `.postqode/skills/wap-spec-creation/SKILL.md`
- [ ] Create `.postqode/skills/wap-execution/SKILL.md`
- [ ] Create `.postqode/skills/wap-finalize/SKILL.md`
- [ ] Create `.postqode/skills/wap-spec-update/SKILL.md`
- [ ] Create `.postqode/skills/wap-debug/SKILL.md`

### Phase 3: References
- [ ] Create `references/core-laws.md` (from v4 rules/core.md)
- [ ] Create `references/automation-standards.md` (from v4 rules/)
- [ ] Update `references/tool-priority.md` (restore v4 version with postqode_browser_agent)
- [ ] Simplify `references/session-protocol.md` (6 states, 10 fields)
- [ ] Decide on shared reference location and move files

### Phase 4: Subagents
- [ ] Update `reviewer.md` (fix ambiguity, add output protocol, park)
- [ ] Update `element-mapper.md` (add output protocol, park)

### Phase 5: Cleanup
- [ ] Delete deprecated SKILL.md
- [ ] Reorganize reference file locations
- [ ] Update MEMORY.md
- [ ] Update README.md to reflect v5.1 architecture

### Phase 6: Validation
- [ ] Verify agent prompt is ≤1,500 words
- [ ] Verify all skill frontmatter is valid PostQode format
- [ ] Verify all reference file paths are correct
- [ ] Test: invoke agent with "automate login for https://example.com" — verify it routes to spec creation, NOT framework setup
- [ ] Test: verify skill loading works when agent enters each phase

---

## v4 → v5.1 Complete Artifact Map

| v4 Artifact | v5.1 Location | Status |
|---|---|---|
| `SKILL.md` (orchestrator) | `agents/web-automation-pro.md` (rewritten) | REWRITE |
| `workflows/spec-gen.md` | `skills/wap-spec-creation/SKILL.md` | NEW |
| `workflows/automate.md` | `skills/wap-execution/SKILL.md` | NEW |
| `workflows/finalize.md` | `skills/wap-finalize/SKILL.md` | NEW |
| `workflows/spec-update.md` | `skills/wap-spec-update/SKILL.md` | NEW |
| `workflows/debug.md` | `skills/wap-debug/SKILL.md` | NEW |
| `rules/core.md` (11 laws) | Top 5 in agent + `references/core-laws.md` | SPLIT |
| `rules/automation-standards.md` | `references/automation-standards.md` | MOVE |
| `rules/interaction-fallbacks.md` | `references/interaction-fallbacks.md` | KEEP |
| `rules/debug-context-capture.md` | Merged into `wap-debug` skill | MERGE |
| `references/tool-priority.md` | `references/tool-priority.md` (restored) | FIX |
| `references/session-protocol.md` | `references/session-protocol.md` (simplified) | SIMPLIFY |
| `references/tip-protocol.md` | `references/tip-protocol.md` | KEEP |
| `references/element-map-schema.md` | `references/element-map-schema.md` | KEEP |
| `references/reviewer-rubric.md` | `references/reviewer-rubric.md` | KEEP |
| `references/grouping-algorithm.md` | `references/grouping-algorithm.md` | KEEP |
| `references/architecture-patterns.md` | `references/architecture-patterns.md` | KEEP |
| `references/spec-format.md` | `references/spec-format.md` | KEEP |
| `references/framework-rule-template.md` | `references/framework-rule-template.md` | KEEP |
| `references/personas.md` | `references/personas.md` | KEEP |
| `references/protocol-guard.md` | `references/protocol-guard.md` | KEEP |
| `references/recovery-protocol.md` | `references/recovery-protocol.md` | KEEP |
| v5 `agents/reviewer.md` | `agents/reviewer.md` (parked) | FIX+PARK |
| v5 `agents/element-mapper.md` | `agents/element-mapper.md` (parked) | FIX+PARK |
| v5 § 8 intent detection | Agent prompt § 5 | KEEP |
| v5 § 12 memory protocol | Agent prompt § 8 | CONDENSE |

---

## Success Criteria

After v5.1 is implemented, the agent must:

1. **Route to spec creation** when user says "automate this" — NOT jump to npm init
2. **Never offer POM/COM/Flat** before the finalize phase
3. **Use `postqode_browser_agent`** for all browser interactions
4. **Load skills on-demand** — not carry 4,500 words in the prompt
5. **Persist state to disk** before every gate
6. **Resume correctly** from a fresh session by reading disk state
7. **Stay under 1,500 words** in the agent prompt

---

## Estimated Effort

| Phase | Files | Effort |
|---|---|---|
| Phase 1: Agent rewrite | 1 file | Medium — careful prompt engineering |
| Phase 2: Create skills | 5 files | High — largest phase, converting workflows |
| Phase 3: References | 4 files (create/update) | Low — mostly copy/adapt from v4 |
| Phase 4: Subagents | 2 files | Low — minor fixes |
| Phase 5: Cleanup | 3-4 files | Low |
| Phase 6: Validation | Testing | Medium — need to verify behavior |

**Total**: ~15 files to create/modify
