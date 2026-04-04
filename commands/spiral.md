Let's go do it, dude. Review the current state of your assigned scope and execute one spiral iteration.

**If you are Thorn (dispatching agents):**

1. **ORIENT:** Read CLAUDE.md, `_grove/index.md`, and the Linear board. Check velocity data in the Grove index for realistic time estimates.

2. **PLAN:** Identify the highest-priority task. Write or update the sprint plan in `_grove/sprints/`. If dispatching multiple agents, run the parallelization check — list files each agent will touch and confirm no overlap.

3. **CONTRACT:** Write a sprint contract (template: `~/armando/templates/sprint-contract.md`) with task scope, file boundaries, acceptance criteria, verification commands, and dispatched timestamp.

4. **DISPATCH:** Send the contract to the assigned agent(s).

5. **REVIEW:** When an agent completes, follow the re-plan loop:
   - Review changes (git log, diff, test results)
   - Check scope compliance against CLAUDE.md and the contract
   - Complete the contract's Outcome section (timestamps, wall clock, outcome, revisions)
   - Update `_grove/index.md` (recent reports, velocity, known issues)
   - **Re-evaluate the remaining sprint plan** before dispatching the next task

6. **REPEAT:** Write the next contract and dispatch. Continue until sprint is complete or 30+ minutes have elapsed.

7. **LOG:** Write a garden report to `_grove/reports/garden-{date}.md` including:
   - What was dispatched and to whom
   - Velocity summary (wall clock per task, review time, outcomes)
   - Rules added this session
   - Updated `_grove/index.md` with session summary

---

**If you are Bloom, Root, or Canopy (executing a task):**

1. **PLAN:** Read the sprint contract from Thorn. Read CLAUDE.md for project context and scope boundaries. If you're Bloom, also read DESIGN.md if it exists. Identify the specific files and acceptance criteria from the contract.

2. **PROTOTYPE:** Implement the plan. Keep changes small and focused — one task per spiral. If you're Root, write tests first. If you're Canopy, plan your compilation verification points.

3. **TEST:** Read CLAUDE.md for this project's test and lint commands, then run them. If CLAUDE.md doesn't specify:
   - **Python projects:** `python -m pytest tests/ -v` for tests, `ruff check .` for lint
   - **Unity projects:** Run `/unity-verify` (compile check, EditMode tests, meta file check)
   - **Web projects:** Check package.json for test/lint scripts
   If tests fail, fix them. If no tests exist for your changes, write them.

4. **REVIEW:** Run `git diff` and self-review your changes. Check against CLAUDE.md conventions and the sprint contract's acceptance criteria. Verify you stayed within the file boundaries specified in the contract. If anything violates the architecture, fix it before committing.

5. **COMMIT:** If all tests pass, all acceptance criteria are met, and the review looks good, commit with a descriptive message that references the task.

6. **LOG:** Write a status report to `_grove/reports/status-{your-agent-name}-{date}.md` summarizing: what you did, what tests you wrote/updated, what's blocked, what needs Kyle's input.

7. **NEXT:** Check if there are more tasks in scope. If yes and you've been running less than 30 minutes, start the next spiral iteration. If you've been running 30+ minutes, pause and ensure your status report is written.

If anything needs Kyle's judgment or approval, write it to `_ivy/queue/` as a markdown file with YAML frontmatter (see existing queue items for format).
