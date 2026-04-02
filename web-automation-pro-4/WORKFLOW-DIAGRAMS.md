# Workflow Diagrams

Direct system diagrams for the hardened Web Automation Pro contract.

These diagrams reflect the intended operating model defined in:
- [`REQUIREMENTS.md`](./REQUIREMENTS.md)
- [`.postqode/skills/web-automation-pro/SKILL.md`](./.postqode/skills/web-automation-pro/SKILL.md)
- [`.postqode/workflows/automate.md`](./.postqode/workflows/automate.md)
- [`.postqode/workflows/finalize.md`](./.postqode/workflows/finalize.md)
- [`.postqode/skills/web-automation-pro/references/session-protocol.md`](./.postqode/skills/web-automation-pro/references/session-protocol.md)

---

## 1. Whole System

```mermaid
flowchart TD
    A["User Request"] --> B{"Reusable automation<br/>or one-time browser task?"}
    B -->|One-time task| C["Standard browser exploration"]
    B -->|Reusable automation| D["Skill reads saved state<br/>before writing runtime files"]

    D --> E{"Locked SPEC.md exists?"}
    E -->|No| F["Route to /spec-gen"]
    E -->|Yes| G{"test-session.md exists?"}

    G -->|No| H["Route to /automate"]
    G -->|Yes| I{"ACTIVE_WORKFLOW<br/>+ STOP_REASON<br/>+ PHASE"}

    I -->|SPEC_GEN| J["/spec-gen resumes"]
    I -->|AUTOMATE| K["/automate resumes"]
    I -->|SPEC_UPDATE| L["/spec-update resumes"]
    I -->|DEBUG| M["/debug resumes"]
    I -->|FINALIZE| N["/finalize resumes"]
    I -->|COMPLETE| O["Run is already finalized"]

    F --> P["Draft, approve, and lock SPEC.md"]
    P --> H

    H --> Q["Plan persisted with stop-state fields"]
    Q --> R["Setup"]
    R --> S["Flat-first grouped execution"]
    S --> T["Review and validate each group"]
    T --> U{"More groups?"}
    U -->|Yes| S
    U -->|No| V["Set ACTIVE_WORKFLOW: FINALIZE"]
    V --> N

    N --> W["Architect analyzes evidence with explicit heuristics"]
    W --> X["User chooses COM / POM / Flat"]
    X --> Y["Refactor and validate"]
    Y --> Z["Cleanup and keep completion ledger"]
    Z --> AA["PHASE: COMPLETE"]
```

---

## 2. Skill Orchestrator Routing

```mermaid
flowchart TD
    A["Skill Activated"] --> B{"Recording mode?"}
    B -->|No| C["Handle as one-time browser task"]
    B -->|Yes| D["Read SPEC.md"]

    D --> E{"SPEC locked?"}
    E -->|No| F["Route into /spec-gen<br/>before any scaffolding"]
    E -->|Yes| G["Read test-session.md"]

    G --> H{"Session file exists?"}
    H -->|No| I["Route into /automate Phase 0<br/>before setup"]
    H -->|Yes| J["Read ACTIVE_WORKFLOW, STOP_REASON, PHASE, LAST_ACTIVE"]

    J --> K{"Stale session?"}
    K -->|Yes| L["Offer resume / re-validate / fresh start"]
    K -->|No| M{"ACTIVE_WORKFLOW"}

    L --> M

    M -->|SPEC_GEN| N["Route to /spec-gen"]
    M -->|AUTOMATE| O["Route to /automate"]
    M -->|SPEC_UPDATE| P["Route to /spec-update"]
    M -->|DEBUG| Q["Route to /debug"]
    M -->|FINALIZE| R["Route to /finalize"]
    M -->|COMPLETE| S["Inform user run is already finalized"]
```

---

## 3. `/spec-gen` Flow

```mermaid
flowchart TD
    A["/spec-gen"] --> B["Workspace scan"]
    B --> C{"Locked spec already exists?"}
    C -->|Yes| D["Stop and direct to /automate"]
    C -->|No| E["Ask clarifying questions"]
    E --> F["Decompose user flow into step definitions"]
    F --> G["Write SPEC.md as DRAFT"]
    G --> H["Strategist self-critique"]
    H --> I["Persist SPEC_APPROVAL stop state"]
    I --> J["Present draft to user"]
    J --> K{"Approved?"}
    K -->|No| L["Revise draft and present again"]
    L --> I
    K -->|Yes| M["Set SPEC.md to LOCKED"]
    M --> N["Set ACTIVE_WORKFLOW: AUTOMATE"]
    N --> O["Next step: /automate"]

    F -.-> P["No framework/runtime files may be created here"]
```

---

## 4. `/automate` State Flow

```mermaid
flowchart TD
    A["/automate entry"] --> B["Read locked SPEC.md and test-session.md"]
    B --> C{"PHASE"}

    C -->|No session| D["Phase 0: plan and persist"]
    C -->|PLAN_PENDING| E["Re-show saved plan"]
    C -->|SETUP| F["Resume setup"]
    C -->|EXECUTING| G["Resume active group from ACTIVE_GROUP and ACTIVE_STEP"]
    C -->|VALIDATING| H["Resume validation"]
    C -->|ROTATING| I["Resume collapse/rotate"]
    C -->|MILESTONE| J["Re-show foundation or milestone gate"]
    C -->|FINALIZING| K["Stop and send user to /finalize"]
    C -->|COMPLETE| L["Tell user run is already finalized"]

    D --> M["Write test.md"]
    M --> N["Write test-session.md with PLAN_APPROVAL stop state"]
    N --> O["Stop for approval"]
    O --> P{"Approved?"}
    P -->|No, adjust| D
    P -->|Yes| Q["Expand setup + Group 1 rows"]
    Q --> F

    F --> R{"Framework known?"}
    R -->|No| S["Persist FRAMEWORK_CHOICE stop state"]
    S --> T["Ask user to choose framework"]
    T --> U["Prepare working runtime<br/>only after plan approval"]
    R -->|Yes| U
    U --> V["Prepare one stable working test file"]
    V --> W["Set PHASE: EXECUTING"]
    W --> G

    G --> X["Per-step loop"]
    X --> Y["Persist ACTIVE_GROUP, ACTIVE_STEP, NEXT_EXPECTED_ACTION"]
    Y --> Z["Explore with TIP"]
    Z --> AA["Create/update element map"]
    AA --> AB["Append to same working test file"]
    AB --> AC["Optional local helper only after 2 matching completed patterns"]
    AC --> AD["Save state"]
    AD --> AE{"More steps in group?"}
    AE -->|Yes| X
    AE -->|No| AF["Reviewer"]

    AF --> AG["Run 7-criterion rubric"]
    AG --> AH{"Pass or warn?"}
    AH -->|Warn| AI["Engineer fixes and reviewer re-runs"]
    AI --> AF
    AH -->|Fail| AJ["Persist GROUP_REFINEMENT stop state"]
    AH -->|Pass| AK["Set PHASE: VALIDATING"]

    AK --> AL["Validator runs headless"]
    AL --> AM{"Validation pass?"}
    AM -->|No| AN["Debugger L1 -> L2 -> L3"]
    AN --> AO{"Resolved and revalidated?"}
    AO -->|No| AP["Persist GROUP_REFINEMENT with failure reason"]
    AO -->|Yes| AL
    AM -->|Yes| AQ["Evaluate foundation and milestone logic"]

    AQ --> AR{"Foundation gate?"}
    AR -->|Yes| AS["Persist FOUNDATION_GATE stop state"]
    AS --> AT["Stop for Group 1 approval"]
    AR -->|No| AU{"Milestone gate?"}
    AU -->|Yes| AV["Persist MILESTONE_GATE stop state"]
    AV --> AW["Stop for milestone review"]
    AU -->|No| AX["Collapse and rotate"]

    AJ --> AY["Pause with progress checkpoint"]
    AP --> AY
    AT --> AX
    AW --> AX
    AX --> AZ["Confirm active-group.md + stable working file"]
    AZ --> BA{"More groups?"}
    BA -->|Yes| G
    BA -->|No| K
```

---

## 5. Per-Group Execution Detail

```mermaid
flowchart LR
    A["Step N"] --> B["Persist ACTIVE_GROUP / ACTIVE_STEP"]
    B --> C["EXPLORE"]
    C --> D["TIP evidence"]
    D --> E["ELEMENT MAP"]
    E --> F["WRITE CODE in same working test file"]
    F --> G["Optional local helper<br/>only after 2 matching completed patterns"]
    G --> H["UPDATE state files"]
    H --> I{"More steps in group?"}
    I -->|Yes| A
    I -->|No| J["REVIEWER"]
    J --> K{"7-criterion rubric"}
    K -->|WARN| L["Engineer fixes"]
    L --> J
    K -->|FAIL| M["Persist GROUP_REFINEMENT"]
    K -->|PASS| N["VALIDATOR"]
    N --> O{"Test passes?"}
    O -->|No| P["DEBUGGER recovery"]
    P --> Q{"Resolved?"}
    Q -->|Yes| N
    Q -->|No| R["Pause with failure state"]
    O -->|Yes| S["FOUNDATION / MILESTONE gate"]
    S --> T["COLLAPSE"]
    T --> U["ROTATE with canonical file checks"]
```

---

## 6. Architecture Timing Model

```mermaid
flowchart TD
    A["/automate execution"] --> B["Working style: FLAT_FIRST"]
    B --> C["One stable working test file"]
    C --> D["Collect element maps and reuse signals"]
    D --> E{"2 matching completed patterns?"}
    E -->|No| F["Keep code flat"]
    E -->|Yes| G["Allow one local neutral helper"]
    G --> F

    F --> H["All groups done"]
    H --> I["/finalize"]
    I --> J["Architect analyzes evidence using explicit thresholds"]
    J --> K{"User decision"}
    K -->|COM| L["Build reusable components + thin pages"]
    K -->|POM| M["Build page objects"]
    K -->|Flat| N["Keep working spec as final shape"]
```

---

## 7. `/finalize` Flow

```mermaid
flowchart TD
    A["/finalize entry"] --> B["Read working spec + element maps + session ledger"]
    B --> C["Quantify reuse, page count, helper count"]
    C --> D["Persist ARCHITECTURE_CHOICE stop state"]
    D --> E["Present recommendation"]
    E --> F{"User chooses COM / POM / Flat"}

    F -->|COM| G["Refactor into component-oriented structure"]
    F -->|POM| H["Refactor into page objects"]
    F -->|Flat| I["Keep flat shape and tidy helpers"]

    G --> J["Validate finalized suite"]
    H --> J
    I --> J

    J --> K{"Validation pass?"}
    K -->|No| L["Debugger fixes and re-validate"]
    L --> J
    K -->|Yes| M["Cleanup temporary execution files"]
    M --> N["Retain slim test-session.md ledger"]
    N --> O["Set PHASE: COMPLETE"]
```

---

## 8. Resume and Stale Session Situations

```mermaid
flowchart TD
    A["New session starts"] --> B["Skill reads LAST_ACTIVE"]
    B --> C{"Older than 7 days?"}
    C -->|No| D["Resume normal routing"]
    C -->|Yes| E["Persist STALE_SESSION stop state"]

    E --> F["Show stale-session menu"]
    F --> G{"User choice"}
    G -->|Resume anyway| D
    G -->|Re-validate first| H["Run validation before resume"]
    H --> I{"Pass?"}
    I -->|Yes| D
    I -->|No| J["Suggest /debug or fresh start"]
    G -->|Start fresh| K["Delete active execution files"]
    K --> L["Keep locked spec and element maps"]
    L --> M["Return to /automate planning"]
```

---

## 9. Failure Handling Situations

```mermaid
flowchart TD
    A["Validation fails"] --> B["Debugger L1"]
    B --> C{"Fixed?"}
    C -->|Yes| D["Re-run validator"]
    C -->|No| E["Debugger L2"]
    E --> F["Persist L2_ESCALATION stop state"]
    F --> G{"Need user evidence or help?"}
    G -->|Yes| H["Stop for user"]
    G -->|No| I["Debugger L3"]
    I --> J["Graceful handling or explicit warning"]
    J --> D
```

---

## 10. Persona Activation Overview

```mermaid
flowchart TD
    A["User enters Web Automation Pro flow"] --> B["Strategist"]
    B --> C["/spec-gen intake, decomposition, spec drafting"]
    B --> D["/automate planning, grouping, plan approval"]

    D --> E["Engineer"]
    E --> F["/automate setup"]
    E --> G["/automate step exploration, element mapping, flat-first code writing"]

    G --> H["Reviewer"]
    H --> I["Post-group rubric review"]

    I --> J["Validator"]
    J --> K["Headless validation of the group"]

    K --> L{"Validation fails?"}
    L -->|Yes| M["Debugger"]
    M --> N["L1 -> L2 -> L3 recovery with explicit stop reasons"]
    N --> J
    L -->|No| O{"All groups complete?"}

    O -->|No| G
    O -->|Yes| P["Architect"]
    P --> Q["/finalize evidence review and COM/POM/Flat recommendation"]
    Q --> R["Architect applies chosen structure"]
    R --> S["Validator"]
    S --> T["Final validation after refactor"]
```

---

## 11. Persona-by-Workflow Map

```mermaid
flowchart LR
    A["/spec-gen"] --> A1["Strategist<br/>Clarify requirements<br/>Decompose steps<br/>Draft and lock SPEC"]

    B["/automate Phase 0"] --> B1["Strategist<br/>Scan workspace<br/>Group steps<br/>Persist plan"]
    C["/automate Phase 1"] --> C1["Engineer<br/>Detect/select framework<br/>Prepare working spec"]
    D["/automate Phase 2"] --> D1["Engineer<br/>Explore UI<br/>Map elements<br/>Write flat-first code"]
    D --> D2["Reviewer<br/>Run rubric before validation"]
    D --> D3["Validator<br/>Run headless validation"]
    D --> D4["Debugger<br/>Recover from failures"]

    E["/finalize"] --> E1["Architect<br/>Analyze reuse evidence<br/>Recommend COM/POM/Flat<br/>Refactor final structure"]
    E --> E2["Validator<br/>Validate finalized suite"]
    E --> E3["Debugger<br/>Fix finalize-stage failures if needed"]

    F["/spec-update"] --> F1["Strategist<br/>Apply surgical spec changes<br/>Mark stale groups"]
    G["/debug"] --> G1["Debugger<br/>Root-cause analysis<br/>Minimal fix"]
    G --> G2["Validator<br/>Verify repaired result"]
```

---

## 12. Persona Responsibilities

```mermaid
flowchart TD
    A["Strategist"] --> A1["Owns clarity"]
    A --> A2["Creates and updates the spec contract"]
    A --> A3["Builds persisted plans and approval stops"]

    B["Engineer"] --> B1["Owns setup and execution"]
    B --> B2["Explores one step at a time"]
    B --> B3["Writes flat-first evidence-based code"]

    C["Reviewer"] --> C1["Owns pre-validation quality gate"]
    C --> C2["Checks 7-criterion rubric"]
    C --> C3["Flags issues but does not fix them"]

    D["Validator"] --> D1["Owns actual test execution"]
    D --> D2["Reports pass/fail facts"]
    D --> D3["Validates groups and finalized output"]

    E["Debugger"] --> E1["Owns failure recovery"]
    E --> E2["Uses L1 -> L2 -> L3 escalation"]
    E --> E3["Persists escalation stop reasons before asking for help"]

    F["Architect"] --> F1["Owns final structure"]
    F --> F2["Analyzes reuse evidence from element maps"]
    F --> F3["Implements COM, POM, or Flat in /finalize"]
```

---

## Reading Order

If someone wants the system from top to bottom, the best order is:

1. Whole System
2. Skill Orchestrator Routing
3. `/spec-gen`
4. `/automate` State Flow
5. Per-Group Execution Detail
6. Architecture Timing Model
7. `/finalize`
8. Resume and Stale Session Situations
9. Failure Handling Situations
10. Persona Activation Overview
11. Persona-by-Workflow Map
12. Persona Responsibilities
