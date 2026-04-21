Review all recent development activity across the Armando team's worktrees:

1. **Git activity:** Run `git log --oneline -15 --all` to see recent commits across all branches. For each active worktree branch, check what changed.

2. **Status reports:** Read all files in `_grove/reports/status-*.md` to see what Bloom, Root, and Canopy reported for project-scoped dispatches. Also check `~/armando/_ivy/reports/` for any cross-machine handoffs not yet integrated.

3. **Quality gate:** Run `/test-all` to verify the codebase is healthy.

4. **Scope check:** Read CLAUDE.md for agent scope boundaries, then review recent diffs to ensure:
   - Each sub-agent only touched files within their defined scope per CLAUDE.md and the sprint contract
   - Nobody modified agent definition files (`~/armando/agents/*.md`) or `.env`
   - Canopy (if active) stayed within the Unity project directory
   - In Horizon missions: nobody triggered any of the seven-event flags without flagging

5. **Envelope flag check (Horizon missions only):** Scan sub-agent status reports for the "Envelope-flag events" section. Any triggered flag (scope drift, unexpected push, unexpected dependency, unexpected external API, unexpected destructive op, unexpected spending, unexpected system modification) must be classified and queued to `for-kyle.md` if Yellow or Red per the mission envelope.

6. **Coordination:** Identify:
   - Any merge conflicts between worktree branches
   - API contract changes (one agent changed an interface another depends on)
   - Missing tests for new code
   - CLAUDE.md rules that need adding based on mistakes found

7. **Garden report:** Write a coordination summary to `_grove/reports/garden-report-{date}.md` covering: what shipped, what's blocked, what needs Kyle, any scope violations found, any envelope-flag events processed.

8. **Queue:**
   - **Interactive mode:** if anything needs Kyle's judgment, write it to `_ivy/queue/`.
   - **Horizon mode:** append to the mission's `for-kyle.md` using the Q-[N] schema.
