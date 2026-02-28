# Web Automation Workflow

This is a comprehensive, agent-driven workflow for generating production-quality web automation tests using Playwright or Cypress. It solves the biggest problems with AI-generated tests: **flakiness, context limitations, and poor architecture.**

The workflow is split into three distinct phases, orchestrated by three markdown files. You act as the human director, and the agent executes the steps.

## The Three Files

1. **`/web-automate-setup.md`** — Planning & Framework setup (Phase 0-1)
2. **`/web-automate-explore.md`** — Execution & Component Discovery (Phase 2)
3. **`/web-automate-final.md`** — Code Refactoring & Production Architecture (Phase 3)

---

## 🚀 How to Use

### Step 1: Initialize the Task
Open a new chat with the agent and provide the setup file along with your test requirements:

> *"@/web-automate-setup.md Please automate this flow on https://example.com:*
> *1. Login with user X password Y*
> *2. Navigate to dashboard*
> *3. Create a new project named 'Alpha'*
> *4. Verify project appears in the list"*

### Step 2: Approve the Plan (Setup Phase)
The agent will read the setup file, analyze your request, and propose a execution plan grouped into logical steps (e.g., Group 1: Login, Group 2: Create Project).

1. Review the proposed table in `test.md`.
2. Reply with **"Approved"** (or ask for changes).
3. The agent will ask about the framework (Playwright/Cypress) and then generate the execution ledger (`test-session.md`) and stop.

### Step 3: Execute the Groups (Explore Phase)
When Setup is done, the agent will prompt you to start a new task.

1. Start a fresh chat (this clears context).
2. Say: **"@/web-automate-explore.md continue"**.
3. The agent will open the browser and execute **Group 1** step-by-step.
   - It takes snapshots, monitors network requests, and generates highly resilient, evidence-based code.
   - It maps UI components on the fly (`component-maps/*.json`).
4. At the end of Group 1, it will validate the code and show you a final menu.
5. **Repeat for each group:** Reply "A" to continue to the next group in a new chat.

### Step 4: Finalize the Suite (Final Phase)
Once all groups have been successfully executed and the temporary "working spec" passes end-to-end, it's time to build production architecture.

1. Start a fresh chat.
2. Say: **"@/web-automate-final.md continue"**.
3. The agent will:
   - Generate true Page Object / Component models from the JSON maps.
   - Inject a Smart Retry mechanism.
   - Refactor the working spec to use the new Page Objects.
   - Validate the refactored code (headed and headless).
   - Clean up all temporary execution files.

---

## 🧠 Advanced Features

### Partial Finalization (For Large Tests)
If your test has many groups (e.g., 10+), the context window for generating Component classes at the very end can become strained. You can run **Partial Finalization** mid-way through.

At the end of any group in the Explore phase, choose Option (B):
> *(B) New task — run partial final for completed groups, then continue*

1. Start a new chat with `@/web-automate-final.md continue`.
2. The agent will generate the Component class files for the groups just completed.
3. It will then automatically prompt you to return to `@/web-automate-explore.md` to pick up the next pending group.
4. When you eventually run the Full Finalization at the end, it skips the heavy component generation (already done) and just refactors the spec.

### Smart Failure Recovery (Level 1, 2, 3)
If the agent encounters a broken UI or wrong locator during exploration:
- **Level 1 (Auto):** It immediately drops into a debugger mode, re-snaps the DOM, checks the network, and attempts to fix the locator automatically (max 2 attempts).
- **Level 2 (Ask):** If it still fails, it stops and explicitly asks you to provide the `outerHTML` of the target element.
- **Level 3 (Graceful):** If the step is impossible, it comments the code out and continues, rather than failing the whole suite.

### Transition Intelligence Protocol (TIP)
AI agents are "blind" to dynamic loading states. The explore workflow uses TIP:
1. Snapshot BEFORE action.
2. Monitor network IMMEDIATELY after action.
3. Wait 3s to let the page settle.
4. Snapshot AFTER action.
5. Diff the DOM and Network footprint.

The generated code uses this evidence. If an API call fired, it generates a `waitForResponse`. If the DOM mutated, it generates a `waitFor` visibility assertion. No arbitrary `sleep()` or `waitForTimeout()` calls are used.

---

## 📂 File Artifacts Generated

During execution, you will see these files in your root directory:

- `test-session.md`: The brain. Contains the current state, active framework vars, and the strict execution checklist.
- `active-group.md`: The current step-by-step instructions being executed.
- `pending-groups/`: Future steps waiting to execute.
- `completed-groups/`: Past steps that successfully passed validation.
- `component-maps/*.json`: The raw structural maps of the UI components interacting with.

**All of these (except component-maps) are automatically deleted by `/web-automate-final.md` at the very end.**
