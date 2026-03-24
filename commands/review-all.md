Review all recent development activity across The Gardener's worktrees:

1. **Git activity:** Run `git log --oneline -15 --all` to see recent commits across all branches. For each active worktree branch, check what changed.

2. **Status reports:** Read all files in `_ivy/reports/status-*.md` to see what Bloom, Root, and Canopy reported.

3. **Quality gate:** Run `/test-all` to verify the codebase is healthy.

4. **Scope check:** Read CLAUDE.md for agent scope boundaries, then review recent diffs to ensure:
   - Each agent only touched files within their defined scope
   - Nobody modified agent definition files or .env
   - Canopy (if active) stayed within the Unity project directory

5. **Coordination:** Identify:
   - Any merge conflicts between worktree branches
   - API contract changes (one agent changed an interface another depends on)
   - Missing tests for new code
   - CLAUDE.md rules that need adding based on mistakes found

6. **Garden report:** Write a coordination summary to `_ivy/reports/garden-report-{date}.md` covering: what shipped, what's blocked, what needs Kyle, any scope violations found.

7. **Queue:** If anything needs Kyle's judgment, write it to `_ivy/queue/`.
