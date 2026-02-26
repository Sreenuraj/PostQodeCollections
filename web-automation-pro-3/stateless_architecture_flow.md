# Stateless Architecture Flow (Dynamic Checklist Generation)

This sequence diagram illustrates how the architecture manages state, keeps `test-session.md` small, and handles agent handover.

```mermaid
sequenceDiagram
    participant User
    box rgb(230, 240, 255) Phase 0 Agent
    participant AgentA as Agent (Phase 0)
    end
    participant Workspace as File System
    box rgb(255, 240, 230) Execution Agents
    participant AgentB as Agent (Group 1)
    participant AgentC as Agent (Group 2)
    end

    %% Phase 0: Intelligence Scan, Planning & Finalization
    User->>AgentA: "Automate this epic..."
    AgentA->>Workspace: ✨ Intelligence Scan (Finds existing framework, code, maps)
    note right of AgentA: Code-Aware Grouping:<br>Batches already-coded steps together!
    AgentA-->>User: Propose optimized plan (Group 1-N)
    User->>AgentA: "Approved"
    
    rect rgb(245, 245, 245)
        note right of AgentA: Phase 0 File Generation
        AgentA->>Workspace: Create pending-groups/group-[1..N].md
        AgentA->>Workspace: Create test-session.md (Header ONLY)
        AgentA->>Workspace: Append [SETUP] checklist rows
        AgentA->>Workspace: Append [Group 1] checklist rows ONLY!
        AgentA->>Workspace: Make group-1.md the active-group.md
    end
    
    AgentA-->>User: "Setup complete. Start new task?"
    User->>AgentA: "Yes" (Trigger /web-automate.md continue)
    
    %% Handover to Group 1
    AgentA->>AgentB: Handover Context (NEW TASK)
    
    %% Group 1 Execution
    rect rgb(240, 255, 240)
        note right of AgentB: Group 1 Execution
        AgentB->>Workspace: Read test-session.md
        AgentB->>Workspace: Start executing [G1] actions sequentially
        
        loop EXPLORE > WRITE > MAP > UPDATE
            AgentB->>Workspace: Mark row [x], record timing/locator in Remarks
        end
        
        note right of AgentB: Group 1 Validation & Collapse
        AgentB->>Workspace: RUN VALIDATION (headless)
        AgentB->>Workspace: COLLAPSE CHECKLIST (Replace all G1 rows with 1 Summary row)
    end
    
    %% The Rotation Phase (Crucial Change inside Group 1 Agent)
    rect rgb(255, 230, 230)
        note right of AgentB: ROTATE AND GENERATE NEXT CHECKLIST
        AgentB->>Workspace: mv active-group.md -> completed-groups/group-1.md
        AgentB->>Workspace: mv pending-groups/group-2.md -> active-group.md
        AgentB->>Workspace: Read new active-group.md (Group 2)
        AgentB->>Workspace: DYNAMIC GENERATE: Append [Group 2] checklist rows to test-session.md!
    end
    
    AgentB-->>User: "Group 1 Complete. Start new task?"
    User->>AgentB: "Yes" (Trigger /web-automate.md continue)
    
    %% Handover to Group 2
    AgentB->>AgentC: Handover Context (NEW TASK)
    
    %% Group 2 Execution
    rect rgb(240, 255, 240)
        note right of AgentC: Group 2 Execution
        AgentC->>Workspace: Read test-session.md
        note right of AgentC: Agent C sees a pristine file:<br>1. Header<br>2. G1 Summary Row<br>3. Pristine [Group 2] checklist!
        AgentC->>Workspace: Start executing [G2] actions
    end
```

### Key Features
1. **No upfront massive checklist:** The `Phase 0 Agent` explicitly does **not** generate the checklist for Group 2 or beyond.
2. **Context stays tiny:** `COLLAPSE CHECKLIST` turns the old 20+ rows of Group 1 into a single 1-line `SUMMARY` row containing only the extracted page maps and locators (for Phase 3's POM refactoring). 
3. **The Rotation Heartbeat:** The crucial moment happens in the red block when the exhausted `Group 1 Agent` rotates the files, reads what `Group 2` is supposed to be, and dynamically generates the `[Group 2]` checklist rows *just before* pulling the ripcord to spawn the fresh `Group 2 Agent`.
4. **Pristine Wakeup:** When the `Group 2 Agent` spawns, it looks at `test-session.md` and only sees the Header, the single Summary row from G1, and the pristine rows it needs to execute for G2.
