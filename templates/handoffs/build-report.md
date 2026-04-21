# Build Report Template

> Produced by Armando when a build is ready to be tested. Stored as
> `library_entries` with `kind: build_report`. Written to
> `/home/kyle/projects/trellis/handoffs/outgoing/` and the mission's
> `artifacts/` directory when Greenhouse doesn't exist yet.

---

# Build Report: [Prototype / feature name]

## Links

- **Research brief:** [link to brief, if applicable]
- **Mission brief:** [link to mission, if Horizon mode]
- **Repo / branch:** [link]
- **Build artifact:** [path / link / deployed URL]
- **Commit:** [commit hash]

---

## What I built

[Summary of implementation approach, 2-4 paragraphs]

- Architecture decisions
- Libraries / frameworks used
- Key files touched

---

## How to run

```bash
# Exact commands to run the build from scratch
# Include env var setup, installation, run command
```

```bash
# If there's a deployed instance, link here and include any auth info
```

---

## Test environment

- **OS:** [OS and version tested on]
- **Hardware:** [Specific hardware requirements if any: GPU, RAM, etc.]
- **Dependencies:** [Any non-obvious deps]

---

## Deviations from brief

[If the build deviates from the research brief's spec, what changed and why]

- [Deviation 1]: [reason]
- [Deviation 2]: [reason]

If no deviations: "No deviations. Built to spec."

---

## Known issues

- [What doesn't work yet]
- [What's partially working]
- [Any flaky behavior observed]

If none: "None observed."

---

## What to test

Scenarios Mr. Owl should run:

1. **[Scenario name]:** [How to trigger, what should happen]
2. **[Scenario name]:** [How to trigger, what should happen]

Match these scenarios to the research brief's success criteria where
possible.

---

## Handoff metadata

- **Produced by:** Armando
- **Produced at:** [ISO-8601 timestamp]
- **Handoff target:** Mr. Owl
- **Expected follow-up:** Critique
