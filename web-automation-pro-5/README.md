# Web Automation Pro v5.1

> Spec-driven browser automation, powered by a PostQode Agent + Skills architecture.

## What is this?

Web Automation Pro is a system that turns vague automation requests ("automate the login flow for this app") into maintainable, evidence-based test suites. It handles the complete lifecycle:

1. **Spec Creation** — Asks the right questions, drafts an automation contract
2. **Planning** — Groups steps into logical batches for efficient execution
3. **Setup** — Configures the test framework and working test file
4. **Execution** — Explores each step in a real browser, gathers evidence, writes code
5. **Review** — Self-critiques against 7 quality criteria
6. **Validation** — Runs headless, zero-retry verification
7. **Finalization** — Analyzes reuse evidence and applies the optimal architecture

## How it works

### The Agent + Skills Architecture (v5.1)

The core of v5.1 is a **PostQode Agent** (`.postqode/agents/web-automation-pro.md`) that acts as the orchestrator, combined with **5 Skills** that handle detailed phase procedures:

- **Agent** (~1,200 words) — Always in context. Detects intent, routes through phases, invokes skills.
- **Skills** — Loaded on-demand when entering a phase. Contains the detailed procedures, references, and protocol guards.

This architecture solves v5's problem of a 4,500-word prompt that the LLM couldn't reliably follow, while keeping the agent-based orchestration that v5 introduced.

### Getting Started

Just describe what you want to automate. The agent handles everything else:

```
"I need to automate the login flow for https://myapp.com"
```

The agent will:
1. Scan your workspace for existing setup
2. Ask clarifying questions
3. Draft and lock a spec (via `wap-spec-creation` skill)
4. Plan and execute group by group (via `wap-execution` skill)
5. Review, validate, and finalize (via `wap-finalize` skill)

### Cross-Session Resumption

If a session is interrupted, start a new conversation. The agent reads state from disk and picks up where you left off — no need to re-explain context.

## Working Style

Web Automation Pro is designed to behave like a disciplined senior automation engineer, not a code generator.

- **It surfaces assumptions early** — if your request could mean more than one thing, it says so instead of choosing silently.
- **It prefers the smallest valid next step** — spec first, then the minimum plan, code, or fix needed for the current phase.
- **It stays surgical** — no drive-by refactors, no extra architecture, no cleanup that isn't required by the request.
- **It proves progress explicitly** — every phase has a concrete gate, check, or validation target before moving on.
- **It still teaches as it works** — it asks why, challenges weak assumptions, and explains the reasoning behind its recommendations.

## Architecture (v5.1)

```
web-automation-pro (AGENT) — ~1,200 words, always in context
  │
  ├── skills/ (loaded on-demand by the agent)
  │   ├── wap-spec-creation/    — Spec drafting and approval
  │   ├── wap-execution/        — Planning, setup, group-by-group execution
  │   ├── wap-finalize/         — Architecture decision and refactoring
  │   ├── wap-spec-update/      — Surgical spec updates
  │   └── wap-debug/            — L1→L2→L3 failure recovery
  │
  ├── agents/ (parked — not invoked in v5.1)
  │   ├── reviewer.md           — Quality review subagent (logic in wap-execution)
  │   └── element-mapper.md     — Element mapping subagent (logic in wap-execution)
  │
  └── memory/                   — Cross-session knowledge
```

Each skill is self-contained with its own `references/` directory containing only the reference files it needs.

### Version Comparison

| Aspect | v4 (Skill-based) | v5 (Agent-based) | v5.1 (Agent + Skills) |
|---|---|---|---|
| Orchestrator | Passive `SKILL.md` | 4,500-word agent prompt | ~1,200-word agent + on-demand skills |
| Phase procedures | User-invoked workflows | Inlined in agent prompt | Skills loaded per-phase |
| Browser tool | `postqode_browser_agent` | `playwright-cli` (broken) | `postqode_browser_agent` (restored) |
| User interface | `/spec-gen`, `/automate` commands | Natural language | Natural language |
| Memory | Session artifacts only | `.postqode/memory/` | `.postqode/memory/` |
| Subagents | None | `reviewer` + `element-mapper` | Parked (logic in skills) |

## Key Principles

- **Spec-Driven**: No code exists until a spec is locked by the user
- **Evidence-First**: Every step is explored in a real browser before code is written
- **Assumptions Visible**: Ambiguity is surfaced before the system chooses a path
- **Minimum Necessary Output**: The agent produces only the artifact needed for the current phase
- **Surgical Scope**: Changes stay tightly tied to the requested goal or active failure
- **Proof Before Progress**: Each recommendation, step, and phase is tied to a concrete verification target
- **Flat-First**: Code stays flat during execution; architecture decisions come at the end
- **One Artifact**: Exactly one working test file during execution (no per-group files)
- **Gate-Driven**: The agent stops at defined checkpoints and waits for user approval
- **Memory-Persistent**: User preferences and project decisions survive across sessions
- **Self-Contained Skills**: Each skill works independently with its own references

## File Structure

```
web-automation-pro-5/
├── README.md                          ← you are here
├── PLAN.md                            ← v5.1 migration plan
├── REQUIREMENTS.md                    ← system requirements (authoritative)
├── WORKFLOW-DIAGRAMS.md               ← visual lifecycle diagrams
└── .postqode/
    ├── agents/
    │   ├── web-automation-pro.md      ← THE AGENT (orchestrator)
    │   ├── reviewer.md                ← parked subagent
    │   └── element-mapper.md          ← parked subagent
    ├── memory/
    │   └── MEMORY.md                  ← cross-session knowledge index
    ├── skills/
    │   ├── wap-spec-creation/
    │   │   ├── SKILL.md               ← spec creation procedure
    │   │   └── references/
    │   │       ├── spec-format.md
    │   │       └── protocol-guard.md
    │   ├── wap-execution/
    │   │   ├── SKILL.md               ← execution procedure (largest skill)
    │   │   └── references/
    │   │       ├── core-laws.md
    │   │       ├── automation-standards.md
    │   │       ├── tool-priority.md
    │   │       ├── session-protocol.md
    │   │       ├── personas.md
    │   │       ├── protocol-guard.md
    │   │       ├── grouping-algorithm.md
    │   │       ├── tip-protocol.md
    │   │       ├── element-map-schema.md
    │   │       ├── reviewer-rubric.md
    │   │       ├── architecture-patterns.md
    │   │       ├── spec-format.md
    │   │       ├── framework-rule-template.md
    │   │       ├── interaction-fallbacks.md
    │   │       └── recovery-protocol.md
    │   ├── wap-finalize/
    │   │   ├── SKILL.md               ← finalization procedure
    │   │   └── references/
    │   │       ├── architecture-patterns.md
    │   │       └── protocol-guard.md
    │   ├── wap-spec-update/
    │   │   ├── SKILL.md               ← spec update procedure
    │   │   └── references/
    │   │       ├── spec-format.md
    │   │       └── protocol-guard.md
    │   └── wap-debug/
    │       ├── SKILL.md               ← debug/recovery procedure
    │       └── references/
    │           ├── recovery-protocol.md
    │           └── protocol-guard.md
    └── spec/                          ← empty (populated during runs)
```

## Version History

| Version | Architecture | Key Change |
|---|---|---|
| v2 | Split-phase workflow | Initial attempt at structured automation |
| v3 | Context-aware single workflow | Reduced token overhead |
| v4 | Skill + Workflows + Rules | Full spec-driven framework with state machine |
| v5 | PostQode Agent | Agent replaces Skill as orchestrator; workflows become agent phases |
| **v5.1** | **Agent + Skills** | **Short agent prompt + on-demand skills; restored `postqode_browser_agent`; self-contained skills with own references** |
