# Critique Request Template

> Produced by Armando when a build is ready for Mr. Owl to test and
> critique. Written to `/home/kyle/projects/trellis/handoffs/outgoing/` with a ULID
> filename alongside a `build_report` artifact. When Greenhouse exists, POST
> as a `library_entries` row with `kind: critique_request`.

---

# Critique Request: [Prototype / feature name]

## Metadata

- **Request ID:** [ULID]
- **Produced by:** armando
- **Produced at:** [ISO-8601]
- **Requesting mission:** [mission-id]
- **Target agent:** mr_owl
- **Priority:** [soft | medium | hard]
- **Expected response within:** [hours or "by next session"]

---

## Collaboration charter check

- **Is Mr. Owl invocation within this mission's collaboration charter?**
  [yes | no. If no, Armando queues as Red and routes around.]
- **Is Mr. Owl operational (inbox exists)?** [yes | no. If no, same as
  above.]

---

## Links

- **Build report:** [path or library ID]
- **Research brief** (if applicable): [path or library ID]
- **Mission brief:** `/home/kyle/projects/trellis/missions/[mission-id]/brief.md`
- **Build artifact:** [path, deployed URL, or commit hash]
- **Repo / branch:** [link]

---

## What to test

> The build report's "What to test" section is authoritative. This section
> adds anything Mr. Owl should know specifically about this request.

### Success criteria to verify

> From the research brief or mission brief.

- [ ] [Criterion 1]
- [ ] [Criterion 2]

### Known limitations Armando already knows about

> So Mr. Owl doesn't waste a critique row on something Armando plans to
> address in the next dispatch.

- [Limitation 1, and what Armando plans to do about it]
- [Limitation 2, and plan]

### Specific scenarios Armando wants evaluated

1. **[Scenario name]:** [why it matters]
2. **[Scenario name]:** [why it matters]

---

## Envelope context

- **Mission envelope:** green / yellow / red tier summary (one line each)
- **Any envelope-flag events during the build:** [list any of the seven
  triggered during sub-agent dispatches, with resolution; or "None"]

---

## Handoff metadata

- **Response location:** `/home/kyle/projects/trellis/handoffs/incoming/` addressed
  to `mission-id`
- **Response template:** `~/armando/templates/handoffs/critique.md`
- **Armando's fallback if no response:** [what Armando does if Mr. Owl
  doesn't respond within the expected window]
- **Logged in heartbeat:** [heartbeat N, For Kyle row]
