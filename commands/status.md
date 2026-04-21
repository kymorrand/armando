Write a status report for your current session.

## Where it goes

Status reports have two scopes:

- **Project-scoped** (Bloom / Root / Canopy reporting dispatch results to Armando, or Armando writing a garden report): `_grove/reports/` inside the project directory.
- **Cross-project / cross-machine** (session handoffs between machines, global notes): `~/armando/_ivy/reports/`.

If you're a sub-agent finishing a dispatch, or Armando closing out a sprint session: write to `_grove/reports/`. If you're writing a handoff for the next session on another machine: write to `~/armando/_ivy/reports/`.

## Filename convention

- Sub-agent dispatch status: `_grove/reports/status-{your-agent-name}-{date}.md`
- Armando garden report: `_grove/reports/garden-{date}.md`
- Cross-machine handoff: `~/armando/_ivy/reports/handoff-{machine}-{date}.md`

## What to include

- **Agent:** Your name (armando, bloom, root, or canopy)
- **Date/Time:** Current timestamp (ISO-8601)
- **Mode (Armando only):** Interactive or Horizon (with mission-id if Horizon)
- **What was done:** List of changes made this session with file paths
- **Tests:** What tests were written, updated, or run. Pass/fail status.
- **What's blocked:** Anything you couldn't complete and why
- **Needs Kyle:** Any decisions or approvals needed from Kyle
- **Next up:** What should be tackled in the next spiral

### Horizon-mission-only additions for sub-agent reports

If your dispatch's sprint contract includes an `inherited_envelope` field, also include at the top of the report:

- **Envelope-flag events:** list any of the seven-event flags triggered, or state "No envelope-flag events." Armando reads this before the next heartbeat to classify correctly.

The seven events are: scope drift, unexpected push, unexpected dependency install, unexpected external API call, unexpected destructive op, unexpected spending, unexpected system modification.

Keep the report concise. It's read by Armando for coordination and by Kyle for async review.
