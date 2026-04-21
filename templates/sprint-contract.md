# Sprint Contract

> Written by Armando before every dispatch. Both Armando and the assigned
> sub-agent reference this contract. After completion, Armando updates the
> Outcome section.

## Task

- **Agent:** [bloom | root | canopy]
- **Linear Issue:** [MOR-XX or "none"]
- **Dispatched At:** [ISO timestamp]
- **Mode:** [interactive | horizon]
- **Mission ID** (horizon only): [mission-id or "n/a"]
- **Inherited Envelope** (horizon only): [green | yellow | red]
- **Summary:** [One-line description of what the agent will build]

> The `Inherited Envelope` is the baseline tier the sub-agent operates under
> for this dispatch. Default green. The mission's authority envelope can raise
> the baseline. Sub-agents cannot unilaterally escalate; they flag prominently
> in their status report and Armando classifies.

## Scope

### Files to Touch
- [ ] `path/to/file.ext`: [what changes]
- [ ] `path/to/file.ext`: [what changes]

### Files NOT to Touch
- `path/to/shared-file.ext`: [why: owned by other agent / out of scope]

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

> Armando completes this section ONLY when dispatching multiple agents
> simultaneously.

- **Other active agents:** [agent: task summary]
- **File overlap check:** [CLEAR: no shared files | CONFLICT: describe overlap]
- **Decision:** [PARALLEL: safe to dispatch simultaneously | SEQUENCE: dispatch after other agent completes]

---

## Outcome

> Armando fills this section after reviewing the agent's completed work.

- **Completed At:** [ISO timestamp]
- **Agent Wall Clock:** [minutes]
- **Armando Review Duration:** [minutes]
- **Outcome:** [pass | revision-needed | failed]
- **Revision Count:** [0 if first attempt passed]
- **Tests:** [X passing, Y failing, Z new]
- **Envelope-flag events** (horizon only): [list any of the seven triggered, or "none"]
- **Rules Added:** [any new CLAUDE.md rules from this dispatch, or "none"]
- **Notes:** [brief review notes]
