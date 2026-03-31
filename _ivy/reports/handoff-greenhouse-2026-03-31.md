# Handoff — Greenhouse — 2026-03-31

**Machine:** Greenhouse (dev server)
**Project:** Trellis (trellis-app + trellis runtime)

## What Was Done

### Ivy Chat Tool Calling (MOR-82 + MOR-83)
Kyle discovered Ivy was hallucinating tool usage in web chat — generating fake `<vault_write>` tags and claiming they worked. Root cause: chat endpoint loaded full SOUL.md (which describes tools) but passed zero tools to the API.

- **MOR-82** (Done) — Added CHAT_TOOL_DISCLAIMER to system prompt as a quick safety patch. Then superseded by MOR-83.
- **MOR-83** (Done) — Wired full tool calling into chat endpoint. Server-side ReAct loop (up to 8 rounds). 7 tools: vault_search, vault_read, vault_save, shell_execute, journal_read, linear_read, linear_search. ASK-level tools (armando_dispatch, request_restart) refused with redirect to Discord. 833 tests pass.
- **SSE status event fix** — Initial implementation emitted `{"type":"status"}` events during tool execution. AI SDK v6 useChat does strict Zod validation and crashed. Removed status events, replaced with server-side logging.

### Fumadocs Documentation Site
Shipped 8 comprehensive doc pages at `/docs`:
- Overview, Architecture, Design System, Screens, Data Flow, Development, Conventions (22 rules with rationale), Changelog (v0.1-v0.4)
- fumadocs-core@15, fumadocs-ui@15, fumadocs-mdx@11
- Auth-protected (owner-only)

### Week 4 Validation Fixes
- react-markdown missing from package.json (lost in cherry-pick)
- Tick config dropdowns reverting to defaults (added savedConfigs state)
- Chat links not clickable on mobile (added remark-gfm + permanent underline)
- Sign out button added to sidebar + mobile overflow

### Thorn Rule Violation + Fix
Thorn directly edited chat_stream.py to remove status events instead of dispatching Root. Kyle called it out. Hardened the no-code rule in `armando/agents/thorn.md` — now explicitly lists allowed file types (docs/plans/reports only) and calls out "quick fixes" as not exceptions.

### Design Session Prep
Wrote `trellis-v1-design-brief.md` for Kyle to bring into a Claude conversation for v1.0 design. Covers current state, Kyle's decisions, open questions (garden, chat UX, navigation, polish, scope), technical constraints, and what a good session produces.

### CLAUDE.md Rules Added
- Rule 21: Always use remark-gfm with react-markdown
- Rule 22: No hover-only affordances on mobile
- Rule 23: No custom SSE event types through chat proxy (AI SDK validates strictly)

### Workspace Cleanup
- All worktrees pruned from both repos (34 total across both)
- All stale local branches deleted
- Orphaned Root work committed and pushed
- Both repos: just main, clean, pushed

## Git State

- **trellis-app:** `9359ac6` on main, pushed to origin
- **trellis:** `86663a7` on main, pushed to origin
- **armando:** `77f79d3` on main, pushed to origin
- All repos clean, no worktrees, no stale branches

## Linear State

- **MOR-81** (Backlog) — Root: add tick_interval/tick_window to quest summary endpoint
- **MOR-82** (Done) — Fix chat hallucination
- **MOR-83** (Done) — Wire tool calling into chat endpoint

## Next Steps

1. **Design session with Claude** — Kyle brings `trellis-v1-design-brief.md` + reference docs into a Claude conversation to define v1.0 scope, garden design, chat UX, and polish list
2. **Restart Greenhouse** — `sudo systemctl restart trellis` to pick up tool calling + admin API + circuit breakers
3. **MOR-81** — Quick Root task, can be done anytime
4. **Build whatever comes out of the design session** — garden content, chat UX, polish, etc.

## Blockers

None. Clean state. Next move is Kyle's design session with Claude.
