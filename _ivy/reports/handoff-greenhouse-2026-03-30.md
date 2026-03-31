# Handoff — Greenhouse — 2026-03-30

## Machine
Greenhouse (home server)

## Project
Trellis v1.0 (trellis-app frontend + trellis runtime)

## What Was Done

### Week 3 Validation Complete
All Week 3 features validated by Kyle and working:

1. **Ivy Chat (MOR-47)** — Streaming works end-to-end. Fixed three issues:
   - Chat proxy now transforms AI SDK v6 UIMessage format to Greenhouse's `{role, content}` format
   - Root fixed `chat_stream.py` to emit proper UI Message Stream Protocol v1 (`start → text-start → text-delta* → text-end → finish`)
   - Fixed stale closure bug in `useIvyChat` — `useMemo` captured initial useState values, causing `AbstractChat.setStatus()` guard to skip the streaming→ready transition. Fixed with `useRef` for getter values.

2. **Inbox (MOR-48/49)** — Questions and approvals working. Kyle submitted answers and approved spend requests through the UI.

3. **Activity Feed (MOR-50)** — Filter chips, day-grouped events, relative timestamps, load-more pagination all working.

4. **Dashboard** — Live data from Greenhouse. Real activity feed (replaced mock data). Live inbox badge counts via `GreenhouseStatusProvider` context. Relative timestamp formatting.

5. **Garden Home (MOR-50)** — Public page at `/` with artifact grid, server component.

### Issues Created
- **MOR-71** — Wire circuit breakers into tick loop (Root)
- **MOR-72** — Fix chat message timestamps (Bloom, low priority)
- **MOR-73** — Add markdown rendering to Ivy chat (Week 4)
- **MOR-74** — Clean up duplicate TRELLIS_API_KEY in .env
- **MOR-75** — Chat conversation persistence (Week 4)

### CLAUDE.md Updates
Added rules 17-20 from session learnings:
- Rule 17: Don't forward AI SDK request bodies unmodified to Greenhouse
- Rule 18: Don't use stale closures in useMemo for mutable state adapters
- Rule 19: Don't hardcode badge counts or use mock data
- Rule 20: Don't forget to format timestamps for display

### Test Data Seeded
Seeded ivy-vault with realistic data for validation:
- 3 questions in `mm-business-model-research.md` (all answered by Kyle)
- 2 approval JSONs in `_ivy/approvals/` (both approved by Kyle)
- 12 activity events in `_ivy/activity.jsonl`

### Session Closeout
- **MOR-74** — Fixed. Deleted duplicate placeholder `TRELLIS_API_KEY` from Greenhouse `.env`. Marked Done.
- **MOR-31** — Closed as superseded by MOR-48 (was pre-Trellis-app inbox design).
- **MOR-71** — Bumped from Low to High priority. Circuit breakers need wiring before real quests run unsupervised.
- **MOR-76** — Created. Push notifications (Web Push + service worker). Deferred from Week 3 MOR-50, now has its own ticket.
- **MOR-77** — Created. Set up Vitest + testing infrastructure. High priority — do first in Week 4.
- **MOR-19** — Still in "In Review" from 3/23 (Linear read into heartbeat). Needs Kyle's decision: still relevant or superseded by Trellis dashboard?

## In Progress
Nothing — clean state.

## Next Steps (Week 4)

**Do first:**
1. **MOR-77** — Set up Vitest + testing infrastructure (before building new features)
2. **MOR-71** — Wire circuit breakers into tick loop (safety net for real quests)

**Then per the Linear board and `trellis-v1-master.md`:**
3. **PWA** — Service worker with Serwist, precaching, offline shell
4. **Fumadocs** — Internal design docs at `/docs`
5. **Garden pages** — Individual artifact view at `/garden/[slug]`
6. **Admin page** — Tick system admin, model usage dashboard
7. **Theming** — Circadian HSL warmth adjustment
8. **Mobile polish** — Final pass on 280px viewport (Galaxy Fold 3)
9. **MOR-73** — Markdown rendering in Ivy chat
10. **MOR-75** — Chat conversation persistence
11. **MOR-76** — Push notifications (depends on PWA/Serwist)

## Blockers
- **MOR-19** — Needs Kyle's decision: keep or close?
- Otherwise clear. Week 3 fully validated. Ready for Week 4.

## Git State
- `trellis-app` main: `617a1d3` (CLAUDE.md rules 17-20)
- `trellis` main: `97b8ba4` (chat SSE protocol fix) + `.env` fix (not committed — .env is gitignored)
- Both repos clean, pushed to origin.

## Linear State
- MOR-31, MOR-47, MOR-48, MOR-49, MOR-50, MOR-57, MOR-74 → Done
- MOR-71 (High), MOR-77 (High) → Week 4 priority
- MOR-72, MOR-73, MOR-75, MOR-76 → Week 4 backlog
- MOR-19 → In Review (needs Kyle's call)
