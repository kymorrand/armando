# Handoff: rootstock, 2026-04-21

**Mode:** Interactive
**Session topic:** Retire the current (pre-Trellis) Ivy

## What was done

Killed the old Discord-based Ivy and removed her system integration. The new
Trellis-based Ivy will replace her once the Trellis build in
`~/projects/trellis/` reaches that milestone.

Actions, all on rootstock:

1. Stopped systemd services:
   - `trellis.service` (was: Ivy Personal Agent Runtime, ran `run_discord.py`)
   - `trellis-restarter.service` (was: watchdog restarter for the above)
2. Disabled both services
3. Removed unit files at `/etc/systemd/system/trellis.service` and
   `/etc/systemd/system/trellis-retarter.service` (and the
   `multi-user.target.wants/` symlinks)
4. `systemctl daemon-reload` + `systemctl reset-failed`
5. Killed orphaned processes that survived the dir wipe:
   - PID 3161: `trellis_restarter.sh` (cwd was already in `_archive/trellis-old`)
   - PID 3489: `run_discord.py` (same)
6. Renamed `~/projects/_archive/trellis-old` →
   `~/projects/_archive/ivy-retired-2026-04-21` for clarity

## What was deliberately NOT touched

- `~/projects/trellis/` — the NEW Trellis project, active build by another
  Armando instance. Kyle's explicit hands-off.
- `~/projects/trellis-startup/` — startup/planning docs for the new Trellis
  (mission briefs, specs). Hands-off.
- `~/projects/ivy-vault/` — Kyle's personal data vault. Data survives Ivy's
  retirement; untouched by design.
- `~/projects/_archive/trellis-app/` — old Next.js web UI archive (separate
  from the daemon). Not renamed; not in scope of this retirement pass.

## Why the names looked confusing

The old Ivy daemon project was called "Trellis" and lived at
`~/projects/trellis/`. That name is now being reused for the new Kyle +
Armando Trellis system at the same path. The old directory had already been
replaced on disk before this session started; the daemon's processes were
only still running because they held open file descriptors to the old binary
(cwd pointed at `_archive/trellis-old`). Killing the services also killed
the orphans.

## In progress

None. Clean retirement.

## Next steps

- When the new Trellis reaches Ivy-replacement milestone, a new systemd unit
  (probably named something other than `trellis.service` to avoid confusion)
  will register the replacement.
- Until then: no Ivy on rootstock.

## Blockers

None.

## Rules added this session

- None (this was ops, not code).

## Sudo usage note

Kyle provided the sudo password inline this session for the one-time systemd
cleanup. Password is not stored anywhere in Armando state. Future sudo-gated
ops still require Kyle to provide or approve.
