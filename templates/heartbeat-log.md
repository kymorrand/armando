# Heartbeat Log Template

> Lives at `/home/kyle/trellis/missions/[mission-id]/heartbeat-log.md`.
> Append-only. Armando writes one entry per tick (default 60m cadence).
> Sub-agents never write here. When Greenhouse exists, entries sync to
> `library_entries` with `kind: heartbeat`.

---

# Mission [mission-id] heartbeat log

**Cadence:** [60m | custom value from mission brief]
**Timer started:** [ISO-8601 at plan approval, not at brief read]
**Tolerance:** ±10 minutes per tick

---

## Heartbeat [N]: [ISO-8601 timestamp, Eastern time]

> For a flash heartbeat, title it `## Heartbeat [N] (flash): ...`. Flash
> heartbeats don't count against cadence and are only used when a
> mission-critical event occurred AND the next scheduled tick is more than
> 20 minutes away.

**Since last heartbeat:**
- [What was accomplished. Include sub-agent dispatches completed this cycle,
  files changed, tests run, decisions made.]

**Current:**
- [What's happening right now. Include any sub-agents currently running with
  their dispatch summary and expected completion time.]

**Next:**
- [Immediate next step. One or two lines.]

**For Kyle:**
- [New queue items this cycle, or "None"]
- [Kyle responses processed this cycle, or omit if none]
- [Yellow disclosures from this cycle: pushes to feature branches, new
  dependencies, CLAUDE.md rule additions, Linear Done transitions, etc.]

**Blockers:**
- [Hard stops the mission cannot complete without, or "None"]

**ETA:** [Estimated time to mission complete, or "H1 complete; working toward H2"]

---

## Cadence rules

1. **Timer starts at plan approval**, not at brief read. Planning time
   doesn't count toward a tick.
2. **Atomic-operation yield:** if mid-commit / mid-test / mid-dispatch at
   tick time, complete the atomic operation first, then heartbeat. Tolerance
   is ±10m per spec §2.
3. **No spam.** One heartbeat per tick. If a mission-critical event fires
   between ticks and the next tick is more than 20 minutes away, write a
   flash heartbeat (header marks it a flash).
4. **Final heartbeat on mission complete** is mandatory regardless of
   cadence. Header: `## Heartbeat [N] (final): [timestamp]`.
5. **Session-end heartbeat** is mandatory regardless of cadence. Header:
   `## Heartbeat [N] (session-end): [timestamp]`. Bridges into the
   checkpoint state file.
6. **Session-resume flash heartbeat** is written at the start of every
   resumed session. Header: `## Heartbeat [N] (flash, session resumed):
   [timestamp]`. Notes any for_kyle responses processed during resume.
7. **Accuracy matters.** Don't say "completed X" unless X is verifiably
   done (tests pass, commit exists, artifact written).
