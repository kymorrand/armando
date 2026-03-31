# Sprint Plan — Week 4

**Date:** 2026-03-30 (planning) → 2026-03-31 through 2026-04-06
**Project:** Trellis (trellis-app + trellis runtime)
**Goal:** Operational foundation — the app is installable, controllable, and safe for daily use. Not v1.0 — a design pass follows Week 4.

---

## Board State (entering Week 4)

**Done (Weeks 1-3):** MOR-19, MOR-31, MOR-39, MOR-40, MOR-43, MOR-44, MOR-45, MOR-47, MOR-48, MOR-49, MOR-50, MOR-51, MOR-52, MOR-54, MOR-57, MOR-58–70, MOR-74
**Active (Week 4):** MOR-71, MOR-73, MOR-77, MOR-78, MOR-79, MOR-80
**Deferred (post-Week 4):** MOR-53 (garden management + polish), MOR-72 (chat timestamps), MOR-75 (chat persistence), MOR-76 (push notifications), Fumadocs

---

## Waves

### Wave 1 — Foundation (no dependencies)
Dispatch simultaneously. Everything else builds on this.

| Ticket | Agent | Task | Est. |
|--------|-------|------|------|
| **MOR-77** | Bloom | Set up Vitest + testing infra. Install vitest, RTL, jsdom. Add `npm test`. Write initial tests for `formatRelativeTime`, `mapPriority`, `mapStatus`, `applyQuestEvent`, chat proxy message transform. | Small |
| **MOR-71** | Root | Wire circuit breakers into tick loop. Import `CircuitBreakerRunner`, call `pre_tick_check()` before each tick, `post_tick()` after. All breakers already built + tested. | Small |

**Exit criteria:** `npm test` runs and passes. Circuit breakers are called on every tick.

### Wave 2 — PWA + Admin API (parallel, independent)
Dispatch simultaneously after Wave 1 completes.

| Ticket | Agent | Task | Est. |
|--------|-------|------|------|
| **MOR-78** | Bloom | PWA — Serwist service worker + offline shell. Precache app shell, web manifest, install prompt. Offline fallback shows cached pages. | Medium |
| **MOR-79** | Root | Admin API — quest controls (`PATCH /api/quests/{id}` pause/resume/abandon, tick config), model usage endpoint (`GET /api/admin/usage`), tick history (`GET /api/admin/ticks`). | Medium |

**Exit criteria:** App passes Lighthouse PWA audit and installs. Admin endpoints return real data and can pause/resume quests.

### Wave 3 — Admin UI + Chat Polish (dependent on Wave 2)
MOR-80 depends on MOR-79 (needs the API). MOR-73 is independent.

| Ticket | Agent | Task | Est. |
|--------|-------|------|------|
| **MOR-80** | Bloom | Admin page — quest control cards (pause/resume, tick config), model usage dashboard (total spend, per-quest breakdown, daily trend), tick history table. | Medium-Large |
| **MOR-73** | Bloom | Markdown rendering in Ivy chat. `react-markdown` for assistant messages. Code blocks, bold, lists, inline code. | Small |

**Exit criteria:** Kyle can pause/resume quests and see spend from the admin page. Chat responses render markdown properly.

### Wave 4 — Validation
| Ticket | Agent | Task | Est. |
|--------|-------|------|------|
| **MOR-55** | Kyle | Week 4 validation. PWA install, offline behavior, admin controls, chat markdown. | — |

---

## Dependency Graph

```
Wave 1 (parallel):   MOR-77 (Bloom)  +  MOR-71 (Root)
                          |                   |
Wave 2 (parallel):   MOR-78 (Bloom)  +  MOR-79 (Root)
                          |                   |
Wave 3:              MOR-73 (Bloom)  +  MOR-80 (Bloom, needs MOR-79)
                                              |
Wave 4:                          MOR-55 (Kyle validates)
```

## Dispatch Notes

- **Wave 1** can start immediately. Both are small, independent tasks.
- **Wave 2** starts after Wave 1. Bloom does PWA while Root builds admin API — fully parallel.
- **Wave 3** has a sequencing issue: MOR-80 (admin UI) depends on MOR-79 (admin API), but MOR-73 (markdown) is independent. Dispatch MOR-73 as soon as Wave 2 Bloom work finishes. Dispatch MOR-80 after MOR-79 completes.
- **Root's proxy routes** for admin (`app/api/admin/`) will need to be created. Root owns `app/api/**/*` per CLAUDE.md. Coordinate with Bloom on response shapes before Root starts MOR-79.

## What's NOT in Week 4

Explicitly deferred to the post-Week 4 design pass:
- **Fumadocs** (`/docs` route) — internal docs, not user-facing
- **Garden content rendering** — `/garden/[slug]` needs design for how content is displayed
- **Garden management** (MOR-53) — needs design for the management UI
- **Push notifications** (MOR-76) — complex vertical slice, depends on PWA
- **Chat persistence** (MOR-75) — works fine for single sessions
- **Circadian theming** — polish, needs design direction
- **Chat timestamps** (MOR-72) — cosmetic

## Risks

1. **Serwist + Next.js 15 compatibility** — Serwist's Next.js plugin may have edge cases with App Router. Bloom should check compatibility early and fall back to manual service worker registration if needed.
2. **Admin API scope** — MOR-79 touches quest state mutation (pause/resume). Root must ensure the tick scheduler respects paused state and doesn't race with API updates.
3. **`/app/ivy` bundle size** — Already 203KB. Adding `react-markdown` (MOR-73) will increase it. Consider dynamic import for the markdown renderer.
