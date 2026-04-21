# Research Brief Request Template

> Produced by Armando to request a research brief from Ivy mid-mission.
> Written to `/home/kyle/trellis/handoffs/outgoing/` with a ULID filename.
> When Greenhouse exists, POST as a `library_entries` row with
> `kind: research_brief_request`.

---

# Research Brief Request: [Short topic name]

## Metadata

- **Request ID:** [ULID]
- **Produced by:** armando
- **Produced at:** [ISO-8601]
- **Requesting mission:** [mission-id]
- **Target agent:** ivy
- **Priority:** [soft | medium | hard]
- **Expected response within:** [hours or "by next session"]

---

## Collaboration charter check

- **Is Ivy invocation within this mission's collaboration charter?**
  [yes | no. If no, this request should not exist; Armando queues as Red and
  routes around.]
- **Is Ivy operational (inbox exists)?** [yes | no. If no, same as above.]

---

## What I need

### Problem statement

[1-2 paragraphs. What is Armando stuck on that research would unblock?
Specific enough that Ivy can scope the work, broad enough that Ivy can
propose alternatives.]

### Constraints

- **Technical:** [relevant stack, versions, compatibility bounds]
- **Time:** [how urgent, when the blocker hits the mission's critical path]
- **Scope:** [what's in bounds; what's out of bounds]
- **Output format:** [prototype | whitepaper | decision | strategy_doc |
  internal_note]

### What I've already tried or ruled out

- [Attempt 1, outcome]
- [Attempt 2, outcome]

### Success criterion

How Armando will know Ivy's response unblocks the mission.

- [Specific, observable condition]

---

## Context Armando can provide

- **Relevant files:** [paths in the current mission or project]
- **Relevant prior research briefs:** [if any; cite library IDs]
- **Current sub-agent state:** [what Bloom/Root/Canopy are mid-task on, if
  relevant]

---

## Handoff metadata

- **Response location:** `/home/kyle/trellis/handoffs/incoming/` addressed
  to `mission-id`
- **Response template:** `~/armando/templates/handoffs/research-brief.md`
- **Armando's fallback if no response:** [what Armando does if Ivy doesn't
  respond within the expected window; e.g., "queue as Medium to for_kyle
  and proceed with best-guess direction"]
- **Logged in heartbeat:** [heartbeat N, For Kyle row]
