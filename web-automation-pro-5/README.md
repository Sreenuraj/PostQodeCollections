# Web Automation Pro v5

> Spec-driven browser automation, powered by a PostQode Agent.

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

### The Agent

The core of v5 is a **PostQode Agent** (`.postqode/agents/web-automation-pro.md`) that acts as both the orchestrator and doer. Unlike previous versions that used passive Skills and user-invoked `/commands`, the agent:

- **Detects intent** from natural language — no commands to memorize
- **Routes itself** through phases automatically based on disk state
- **Communicates transparently** — explains what it's doing and why at every step
- **Persists memory** across sessions via `.postqode/memory/`
- **Enforces strict protocols** — evidence-first, flat-first, spec-driven

### Getting Started

Just describe what you want to automate. The agent handles everything else:

```
"I need to automate the login flow for https://myapp.com"
```

The agent will:
1. Scan your workspace for existing setup
2. Ask clarifying questions
3. Draft and lock a spec
4. Plan and execute group by group
5. Review, validate, and finalize

### Cross-Session Resumption

If a session is interrupted, start a new conversation. The agent reads state from disk and picks up where you left off — no need to re-explain context.

## Architecture (v5 vs v4)

| Aspect | v4 (Skill-based) | v5 (Agent-based) |
|---|---|---|
| Orchestrator | Passive `SKILL.md` — hopes LLM follows instructions | Active agent with own behavioral contract |
| Subagents | None | `reviewer` (quality gate) + `element-mapper` (evidence → schema) |
| User interface | `/spec-gen`, `/automate`, `/finalize` commands | Natural language — agent detects intent |
| Memory | Session artifacts only | `.postqode/memory/` for cross-session + session artifacts |
| Workflows | 5 user-invoked `/command` files | 0 — logic inlined in agent, details in reference files |
| Rules | 4 separate files loaded on demand | Core rules inlined in agent prompt (always-on) |

## Key Principles

- **Spec-Driven**: No code exists until a spec is locked by the user
- **Evidence-First**: Every step is explored in a real browser before code is written
- **Flat-First**: Code stays flat during execution; architecture decisions come at the end
- **One Artifact**: Exactly one working test file during execution (no per-group files)
- **Gate-Driven**: The agent stops at defined checkpoints and waits for user approval
- **Memory-Persistent**: User preferences and project decisions survive across sessions

## File Structure

```
web-automation-pro-5/
├── README.md                          ← you are here
├── REQUIREMENTS.md                    ← system requirements (authoritative)
├── WORKFLOW-DIAGRAMS.md               ← visual lifecycle diagrams
└── .postqode/
    ├── agents/
    │   ├── web-automation-pro.md      ← THE AGENT (orchestrator + doer)
    │   ├── reviewer.md                ← quality review subagent
    │   └── element-mapper.md          ← element mapping subagent
    ├── memory/
    │   └── MEMORY.md                  ← cross-session knowledge index
    ├── skills/
    │   └── web-automation-pro/
    │       ├── SKILL.md               ← deprecated (v4 reference only)
    │       └── references/            ← phase-specific procedure details
    │           ├── spec-creation-procedure.md
    │           ├── execution-procedure.md
    │           ├── finalize-procedure.md
    │           ├── spec-update-procedure.md
    │           ├── debug-and-recovery.md
    │           ├── spec-format.md
    │           ├── grouping-algorithm.md
    │           ├── tip-protocol.md
    │           ├── reviewer-rubric.md
    │           ├── architecture-patterns.md
    │           ├── element-map-schema.md
    │           ├── framework-rule-template.md
    │           └── interaction-fallbacks.md
    └── spec/                          ← empty (populated during runs)
```

## Version History

| Version | Architecture | Key Change |
|---|---|---|
| v2 | Split-phase workflow | Initial attempt at structured automation |
| v3 | Context-aware single workflow | Reduced token overhead |
| v4 | Skill + Workflows + Rules | Full spec-driven framework with state machine |
| **v5** | **PostQode Agent** | **Agent replaces Skill as orchestrator; workflows become agent phases; memory integration** |
