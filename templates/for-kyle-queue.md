# For-Kyle Queue Template

> Lives at `/home/kyle/trellis/missions/[mission-id]/for-kyle.md`.
> Append-only log of items requiring Kyle's async input during a Horizon
> mission. Only Armando writes. Kyle responds inline by filling the
> **Kyle response** field on each item. Resolved items stay in the file;
> never delete (audit trail).

---

# Mission [mission-id]: Queue for Kyle

**Mission status:** [active | paused | complete]
**Last updated:** [ISO-8601, bumped on every append or status change]

---

## Q-[N]: [Short title. 6-10 words]

- **Timestamp:** [ISO-8601]
- **Type:** [blocker | decision | input-needed | disclosure]
- **Priority:** [soft | medium | hard]
- **Description:**
  [Full description. Include relevant file paths, line numbers, links to
  sub-agent status reports, Linear issues, commits. Enough for Kyle to
  decide without re-reading the heartbeat log.]
- **What I did instead:**
  [If blocker: how Armando routed around. What work continued while this
  item was queued. If disclosure: "No action needed; proceeding."]
- **Kyle response:**
  [Kyle fills this inline when responding. Can be a decision, a pointer to
  a longer conversation, or "approved / go ahead".]
- **Status:** [pending | responded | resolved]

---

## Priority definitions

- **Soft:** can wait until Kyle is back. Armando has already routed around.
  Example: "Dependency install pattern used a different package than the
  mission brief named; substitute was functionally equivalent; flagged for
  visibility."
- **Medium:** wanted in next 2 hours. Mission will complete with or without
  the response but quality degrades if answered late. Example: "Design
  token name mismatch; Armando picked best guess; Kyle's ruling preferred
  before merging."
- **Hard:** mission cannot complete without this. Armando may pause if no
  other work is available. Example: "Production credentials were not
  pre-provisioned; cannot deploy the H2 artifact without them."

Default to Soft. Mark Medium or Hard only when genuinely warranted.

## Armando's responsibilities

- At every heartbeat tick start: scan this file for new `Kyle response`
  values on items newer than the last checkpoint timestamp. Process and
  mark `responded` or `resolved`.
- At every session resume: same scan, broader window.
- At session end: ensure `Last updated` is current.
- Never delete items. Resolved items stay as audit trail.
- Never block on a queue item. If truly no other work is available,
  heartbeat immediately and pause the mission.
