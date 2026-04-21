# Checkpoint Template

> Written (rewritten, not appended) at every session end during a Horizon
> mission. Lives at `/home/kyle/trellis/missions/[mission-id]/checkpoint.md`.
> Read at the start of every resume. Target: resume the mission within 1-2
> prompt exchanges from this file alone.

---

# Mission [mission-id] checkpoint

## Session metadata

- **Session end timestamp:** [ISO-8601]
- **Machine:** [rootstock | sprout | other hostname]
- **Session duration:** [HH:MM]
- **Heartbeats written this session:** [N]
- **Total heartbeats mission-to-date:** [M]

---

## Git state

- **Active branch:** [branch name]
- **Last commit SHA:** [hash]
- **Last commit message:** [short summary]
- **Working tree:** [clean | dirty: list uncommitted files]
- **Active worktrees:**
  - `path/to/worktree` on `branch` (sub-agent: bloom | root | canopy | none)

---

## In progress

- **Current goal:** [one sentence describing what Armando is actively working
  toward at session end]
- **Files open / being edited:** [list, or "none"]
- **Next concrete action:** [one sentence; specific enough to execute
  without re-reading anything else]

---

## Sub-agent state

> One entry per sub-agent dispatched this mission, even if completed.

### Bloom

- **State:** [idle | running | returned-pending-review | error | completed]
- **Last dispatch:** [sprint contract filename or inline summary]
- **Worktree:** [path or "none"]
- **Notes:** [blockers, revisions needed, flag events seen]

### Root

- **State:** [...]
- **Last dispatch:** [...]
- **Worktree:** [...]
- **Notes:** [...]

### Canopy

- **State:** [...]
- **Last dispatch:** [...]
- **Worktree:** [...]
- **Notes:** [...]

---

## Ephemeral state worth preserving

> Values computed this session that aren't in files yet, external service
> state, in-session assumptions. This section is how next session avoids
> redoing discovery work.

- [Value or assumption, with source]
- [Value or assumption, with source]

---

## Reading list for next session

> Specific files next session should read before doing anything else, in
> order. Keep this short; the point is to bias the resume toward action,
> not exploration.

1. This checkpoint (always)
2. `heartbeat-log.md` tail 5
3. `for-kyle.md` (scan for new `Kyle response` values)
4. [Other mission-specific files]

---

## For-Kyle queue state at session end

- **Open items (pending):** [count, or list Q-IDs]
- **Awaiting response (Q-IDs):** [list, or "none"]
- **Resolved this session (Q-IDs):** [list, or "none"]

---

## Next action on resume

> One sentence. The very first thing the next session should execute after
> the resume protocol completes. This is the single most important field in
> this file.

[e.g., "Dispatch Root with sprint contract at
sprint-2026-04-20-auth-migration.md to finish the Argon2 password hasher
migration started this session."]
