# Week 2 Sprint Plan — Connected

**Project:** Trellis v1.0
**Sprint:** Week 2 (Connected)
**Goal:** Wire the app to live Greenhouse data. Dashboard shows real sidequests, detail page lets Kyle drill into any sidequest, real-time updates stream through SSE.

## Ticket Overview

| Ticket | Agent | Repo | Depends On | Priority |
|---|---|---|---|---|
| MOR-42 | Root | trellis | — | P1 (Urgent) |
| MOR-43 | Root | trellis | MOR-42 | P2 |
| MOR-44 | Root | trellis | — | P2 |
| MOR-45 | Bloom | trellis-app | MOR-42, MOR-43 | P2 |
| MOR-46 | Kyle | — | All above | P2 |

## Dependency Graph

```
MOR-42 (tick scheduler) ──┐
                          ├──> MOR-45 (Bloom wires dashboard + detail)
MOR-43 (question/SSE) ───┘         │
                                   ├──> MOR-46 (Kyle validates)
MOR-44 (chat stream protocol) ────(independent, Week 3 prereq)
```

## Dispatch Plan

### Wave 1 — Root (parallel, both independent)

**MOR-42: Quest tick scheduler + six-phase execution**
- Repo: ~/projects/trellis
- Async scheduler loop with per-quest configurable cadence (2-30 min)
- Tick window enforcement (e.g., 8am-11pm)
- Six phases: Awake → Input → Plan → Execute → Persist → Notify
- Time-box per tick to prevent runaway
- Bonus tick on Kyle answer events
- Must work with existing quest.py loader and quest_api.py
- Tests required: scheduler lifecycle, phase execution, window enforcement, bonus tick trigger

**MOR-44: UI Message Stream Protocol in FastAPI**
- Repo: ~/projects/trellis
- Implement Vercel AI SDK v6 UI Message Stream Protocol
- POST /api/chat streams SSE with message parts (text, tool-call, tool-result, reasoning)
- No vercel-labs/py-ai dependency — hand-rolled ~100-150 lines
- Must integrate with existing Ivy conversation loop
- Tests required: stream encoding, message part types, error handling

### Wave 2 — Root (depends on MOR-42)

**MOR-43: Question + approval + SSE endpoints**
- Repo: ~/projects/trellis
- GET /api/quests/{id}/questions — list pending questions for a quest
- POST /api/quests/{id}/questions — submit answers (triggers bonus tick)
- GET /api/approvals — list pending approvals
- POST /api/approvals — approve/reject
- GET /api/agent/state — SSE broadcast of agent state changes (quest status, tick events)
- All Bearer auth like existing quest endpoints
- Tests required: CRUD operations, SSE stream format, answer→bonus tick flow

### Wave 3 — Bloom (depends on MOR-42 + MOR-43)

**MOR-45: Wire dashboard + sidequest detail to live data**
- Repo: ~/projects/trellis-app
- **trellis-client.ts:** Create typed API client for Greenhouse
  - GET /api/quests → QuestSummary[]
  - GET /api/quests/{id} → QuestDetail
  - GET /api/quests/{id}/questions → Question[]
  - GET /api/agent/state → EventSource SSE
  - All requests include TRELLIS_API_KEY Bearer auth
  - Error handling for Greenhouse unreachable
- **Proxy routes:** Wire app/api/quests/route.ts, app/api/approvals/route.ts
  - Session check → forward to Greenhouse → pipe response
  - Add app/api/agent/state/route.ts for SSE proxy
- **Dashboard (/app):** Replace mockSidequests import with SWR/fetch from /api/quests
  - Map QuestSummary fields to existing card components
  - Poll every 30s for status updates
  - Shimmer loading state while fetching
  - Error state when Greenhouse unreachable
- **Sidequest detail (/app/sidequests/[id]):** New page
  - Fetch QuestDetail from /api/quests/{id}
  - Step timeline with checkmarks, blocked indicators
  - Goal + success criteria display
  - Artifacts section
  - Activity log
  - Budget meter (spent/total)
  - Questions section (pending, with context)
  - Left-accent card pattern from kiosk theme
  - Mobile: single column stacked
  - Desktop: split layout (info left, timeline right)
- **Real-time:** EventSource on /api/agent/state for live status updates
  - Optimistic UI updates on quest status change
  - Toast/notification on new questions
- Keep mock data as fallback for development (feature flag or env check)

### Wave 4 — Kyle validation

**MOR-46: Milestone 2 validation — Connected**
- Live quest data shows accurately
- Sidequest detail is trustworthy (matches quest file content)
- Real-time updates arrive within seconds
- Greenhouse unreachable shows clear error state
- Exit: "Do you trust the Trellis app as much as Discord?"

## JSON Contract (Root → Bloom)

Bloom's TypeScript interfaces must match these Pydantic models from quest_api.py:

```typescript
// Maps to QuestSummary
interface SidequestSummary {
  id: string
  title: string
  status: string      // "draft" | "active" | "waiting" | "paused" | "complete" | "abandoned"
  priority: string    // "urgent" | "high" | "standard" | "low"
  type: string        // "research" | "writing" | "review" | "side-quest"
  role: string
  steps_completed: number
  total_steps: number
  budget_claude: number
  budget_spent_claude: number
  updated: string | null  // ISO date
}

// Maps to QuestDetail
interface SidequestDetail extends SidequestSummary {
  created: string | null
  tick_interval: string
  tick_window: string
  goal_hash: string
  drift_check_interval: number
  goal: string
  success_criteria: string
  steps: { text: string; done: boolean; blocked_by: string | null }[]
  questions: string
  artifacts: string
  log: string
  blockers: string
  extra: Record<string, unknown>
}

// Maps to QuestListResponse
interface SidequestListResponse {
  quests: SidequestSummary[]
  count: number
}
```

## Risks & Mitigations

1. **Tick scheduler complexity:** Six phases is ambitious. Root should start with a minimal 2-phase loop (Awake → Execute) and iterate.
2. **SSE through Cloudflare Tunnel:** May need to verify Cloudflare doesn't buffer SSE responses. Kyle can test with curl.
3. **Question/approval endpoints don't exist yet:** MOR-43 builds these fresh. Bloom can't wire inbox to live data until MOR-43 lands — but inbox isn't in this sprint (that's Week 3, MOR-48).
4. **Mock data fallback:** Keep mock-data.ts around. Dashboard should gracefully fall back if Greenhouse is unreachable (dev mode or network error).

## Session Execution Order

1. Dispatch Root for MOR-42 + MOR-44 (parallel — no dependencies between them)
2. When MOR-42 completes, dispatch Root for MOR-43
3. When MOR-43 completes, dispatch Bloom for MOR-45
4. Review all changes, update Linear, write garden report
5. Kyle runs MOR-46 validation
