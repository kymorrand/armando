# Sprint Contract

> Written by Thorn before every dispatch. Both Thorn and the assigned agent
> reference this contract. After completion, Thorn updates the Outcome section.

## Task

- **Agent:** [bloom | root | canopy]
- **Linear Issue:** [MOR-XX or "none"]
- **Dispatched At:** [ISO timestamp]
- **Summary:** [One-line description of what the agent will build]

## Scope

### Files to Touch
- [ ] `path/to/file.ext` — [what changes]
- [ ] `path/to/file.ext` — [what changes]

### Files NOT to Touch
- `path/to/shared-file.ext` — [why: owned by other agent / out of scope]

### Dependencies
- **Depends on:** [another task / "none"]
- **Blocks:** [another task / "none"]

## Acceptance Criteria

1. [Specific, testable criterion]
2. [Specific, testable criterion]
3. [Specific, testable criterion]

## Verification Commands

```bash
# Tests
[project-specific test command from CLAUDE.md]

# Lint
[project-specific lint command from CLAUDE.md]

# Smoke check
[project-specific import/build/compile check]
```

## Parallelization Check

> Thorn completes this section ONLY when dispatching multiple agents simultaneously.

- **Other active agents:** [agent — task summary]
- **File overlap check:** [CLEAR — no shared files | CONFLICT — describe overlap]
- **Decision:** [PARALLEL — safe to dispatch simultaneously | SEQUENCE — dispatch after other agent completes]

---

## Outcome

> Thorn fills this section after reviewing the agent's completed work.

- **Completed At:** [ISO timestamp]
- **Agent Wall Clock:** [minutes]
- **Thorn Review Duration:** [minutes]
- **Outcome:** [pass | revision-needed | failed]
- **Revision Count:** [0 if first attempt passed]
- **Tests:** [X passing, Y failing, Z new]
- **Rules Added:** [any new CLAUDE.md rules from this dispatch, or "none"]
- **Notes:** [brief review notes]
