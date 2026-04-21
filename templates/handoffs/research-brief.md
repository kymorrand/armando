# Research Brief Template

> Produced by Ivy. Stored as a `library_entries` row with
> `kind: research_brief`. Armando reads incoming copies from
> `/home/kyle/projects/trellis/handoffs/incoming/`.

The `terminates_in` field determines downstream behavior:
- `prototype` → hands to Armando → Mr. Owl tests
- `whitepaper` → produces long-form doc, optional review
- `decision` → surfaces recommendation for Kyle approval
- `strategy_doc` → produces strategic synthesis, lands in Library
- `internal_note` → Ivy logs learnings, no downstream

---

# Research Brief: [Task name]

## Metadata

- **terminates_in:** prototype | whitepaper | decision | strategy_doc | internal_note
- **Project / scope:** [Tennis Social / Morrandmore / MF / personal]
- **Kyle approved plan at:** [session link or timestamp]
- **Produced by:** Ivy
- **Produced at:** [ISO-8601 timestamp]

---

## Problem statement

[1-2 paragraphs: what are we trying to understand or decide]

---

## Constraints

- [Technical constraints, e.g. "Unity 6, URP, mid-range GPU"]
- [Scope constraints]
- [Time/resource constraints]

---

## Research findings

- **[Source 1]:** [finding, with link]
- **[Source 2]:** [finding, with link]
- [...]

---

## Recommended direction(s)

### Primary

**[Direction name]:** [why this one, tradeoffs]

### Fallback

[Alternative if primary fails, why it's a fallback]

---

## Termination-specific section

### If terminates_in: prototype

#### Prototype spec

- What the prototype must demonstrate
- What "working" looks like concretely
- Build environment setup (for Armando)
- Reference repos / existing code to borrow from

#### Success criteria (for Mr. Owl)

- [ ] [Specific testable criterion]
- [ ] [Another criterion]

### If terminates_in: whitepaper | strategy_doc

#### Output spec

- Target audience
- Key arguments to support
- Structure / outline
- Length target

### If terminates_in: decision

#### Recommendation

- What to decide
- Options considered (with pros/cons)
- Ivy's recommendation + reasoning
- Kyle approval gates the outcome

### If terminates_in: internal_note

#### Learnings

- What Ivy learned
- What this unlocks for future work
- No downstream handoff

---

## References

- [Links, docs, papers, code samples]

---

## Handoff metadata

- **Terminates in:** [type]
- **Handoff target:** [Armando | none | Ivy self-review | Claude for second opinion]
- **Expected follow-up:** [build report | whitepaper | decision approval | strategy doc entry | none]
