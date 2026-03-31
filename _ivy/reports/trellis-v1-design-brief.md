# Trellis v1.0 Design Brief

**Prepared by:** Thorn (Armando PM agent)
**Date:** 2026-03-31
**For:** Design session with Claude to define Trellis v1.0

---

## What Trellis Is

Trellis is Kyle Morrand's personal AI workspace at morrandmore.com. Two zones in one Next.js app:

1. **Private dashboard** — Kyle manages Ivy, his AI agent system that runs autonomous research quests. He reviews quest progress, answers Ivy's questions, approves spend requests, adjusts tick schedules, and chats with Ivy directly.

2. **Public digital garden** — Published research, writing, and artifacts from Ivy's work and Kyle's thinking. Visitors see polished output; Kyle sees the messy process behind it.

The backend is a Python/FastAPI runtime called Greenhouse, running on Kyle's home server and connected to Vercel via Cloudflare Tunnel. The frontend is this Next.js app on Vercel. All AI intelligence lives in Greenhouse — the frontend is a presentation and control layer.

## Where We Are (v0.4)

Four weekly sprints completed. The app is functional and Kyle uses it daily. Here's what's shipped and validated:

### Working well
- **Dashboard** — Live quest cards with progress, budget, status. Activity feed. Inbox badge counts from shared context.
- **Inbox** — Question batch review with suggestion chips + custom reply. Approval queue with approve/reject.
- **Sidequests** — List view with status/priority badges. Detail page with step timeline, budget meter, goal/criteria.
- **Ivy Chat** — Streaming conversation via Vercel AI SDK v6. Markdown rendering (react-markdown + remark-gfm). As of today, Ivy has full tool access in web chat (vault read/write/search, shell, Linear, journal) — parity with Discord.
- **Activity Feed** — Cross-quest event stream with filter chips, day grouping, load-more pagination.
- **Admin** — Quest controls (pause/resume/abandon), tick config (interval/window), model usage dashboard with budget progress bars, tick history table.
- **Auth** — Magic link via Resend. Single-user (Kyle only). Sign out in sidebar + mobile overflow.
- **PWA** — Serwist service worker, precaching, standalone display, app icons.
- **Docs** — Fumadocs at /docs with 8 pages covering architecture, design system, screens, data flow, development, conventions, changelog.
- **Responsive** — Everything works at 280px (Galaxy Fold 3 folded viewport). Desktop sidebar, mobile bottom nav with overflow.
- **Solarpunk theme** — oklch warm palette, film grain texture, Fraunces/Literata/Recursive typography, variable font axes, light + dark mode.

### Functional but needs design
- **Garden** — Public pages exist (`/garden` grid, `/garden/[slug]` detail) but are empty shells. No published content. No design for what a garden artifact looks like, how content flows from Ivy's work to published pieces, or what the public experience should be.
- **Garden Management** (`/app/garden`) — Placeholder page. No design for how Kyle curates, edits, and publishes garden content.
- **Chat UX with tools** — Ivy now has 7 tools in web chat, but the UI doesn't show tool execution status. There's a pause while tools run, then text appears. No visual indicator of "Ivy is searching the vault..." or "Ivy is reading a file..." This could feel broken to someone who doesn't know what's happening.

### Not built yet
- **Push notifications** — PWA infrastructure is there (service worker), but no notification permission flow, no notification triggers from Greenhouse, no notification UI.
- **Chat persistence** — Conversations reset on page reload. No history, no ability to continue a previous conversation.
- **Circadian theming** — Described in the design system (JS adjusts HSL warmth based on time of day) but not implemented.
- **Approval flow in web chat** — Two tools (armando_dispatch, request_restart) require Kyle's approval. In Discord this works via the approval queue. In web chat, these tools are refused with "use Discord." Need an inline approval UI if we want full parity.

## Kyle's Stated Preferences and Decisions

These came from direct conversations during the build:

1. **"This isn't v1.0."** — Kyle explicitly said after Week 4 that it needs another design pass before the v1.0 label. The current state is a working prototype, not a finished product.

2. **Admin should have controls, not just read-only dashboards.** — When we planned the admin page, Kyle wanted pause/resume/abandon buttons and tick config changes, not just a monitoring view.

3. **Garden needs its own design pass.** — Kyle said to put garden content into the backlog and do design specifically for it rather than building something without a clear vision.

4. **Fumadocs was deferred, then un-deferred.** — Originally cut from Week 4 as not user-facing. Kyle brought it back because he wanted well-formed documentation to share with Claude for design discussion (this session).

5. **Galaxy Fold 3 is the primary device.** — ~280px folded viewport. Every design decision must account for this. It's not an edge case — it's the primary use case.

6. **Solarpunk aesthetic is intentional and should deepen, not retreat.** — The kiosk warmth theme (oklch, film grain, variable font axes) was deliberately brought from an earlier project. The visual identity matters.

7. **Versioning: 0.1 per week.** — Kyle set the versioning convention: each weekly sprint is a 0.x release. v1.0 is earned through a deliberate design pass, not just feature completeness.

## Open Questions for the Design Session

### Garden
- What does a published garden artifact look like? Is it a blog post? A research brief? A living document that updates?
- How does content flow from Ivy's quest work to the garden? Does Kyle manually curate, or does Ivy propose pieces?
- What's the public experience? Is `/garden` a grid of cards? A feed? A wiki-like structure with tags and connections?
- Should garden artifacts show their provenance (which quest produced them, how many ticks, what tools were used)?
- Is the garden just text, or can it include data visualizations, embedded code, interactive elements?

### Chat UX
- Now that Ivy has tools in web chat, how should tool execution be visualized? A "thinking..." state? Expandable tool-use cards showing what Ivy searched/read/wrote? Or keep it invisible?
- Should chat conversations persist? If so, how are they organized — by date? By topic? Linked to quests?
- Should Ivy be able to proactively message Kyle (not just respond)? Push a notification when a quest hits a blocker?

### Navigation and Information Architecture
- Is the current 7-screen structure right? (Dashboard, Inbox, Sidequests, Ivy, Activity, Garden, Admin)
- The "More" overflow menu on mobile hides Activity, Garden, and Admin. Are these the right items to hide?
- Should there be a unified search across quests, garden content, and Ivy's vault?

### Identity and Polish
- The solarpunk theme is warm and distinctive. What's missing to make it feel "finished"?
- Circadian theming — is this still desired? What should it actually feel like? Warmer at night, cooler in morning?
- Are there micro-interactions or animations that would make the app feel more alive? (Currently everything is static cards and tables.)
- Should Ivy have a visual presence in the app beyond the chat page? An avatar? A status indicator?

### Scope for v1.0
- What's the minimum set of features that earns the v1.0 label?
- Is v1.0 "Kyle uses this daily and trusts it" or "Kyle would show this to other people"?
- Are there features we built that should be cut or simplified for v1.0?

## Technical Context for Design Decisions

Things that affect what's feasible:

- **Vercel Hobby plan** — 25s serverless function limit. SSE connections drop and reconnect. This is normal but affects real-time UX patterns.
- **Single user** — Auth is Kyle-only. No multi-user considerations. But the public garden is truly public.
- **Greenhouse is a home server** — It can go offline (power outage, maintenance). The app needs graceful offline states. The PWA service worker helps but the dashboard currently shows errors when Greenhouse is unreachable.
- **AI SDK v6** — Strict SSE protocol validation. Custom event types crash the parser. Any real-time UI features need to work within the UI Message Stream Protocol v1 spec.
- **280px minimum width** — Every component, every layout, every interaction must work on the Galaxy Fold 3 folded viewport.

## Files to Reference

These documents provide deeper context. Import them into the conversation as needed:

| Document | What it covers |
|---|---|
| `content/docs/architecture.mdx` | System topology, auth, data patterns, SSE protocol |
| `content/docs/screens.mdx` | All 10 current screens |
| `content/docs/design-system.mdx` | Theme tokens, typography, AI Elements, responsive patterns |
| `content/docs/data-flow.mdx` | Every API endpoint, SSE protocols |
| `content/docs/conventions.mdx` | 22 rules with rationale — shows what went wrong |
| `content/docs/changelog.mdx` | v0.1 through v0.4 build history |
| `CLAUDE.md` | Full project constitution |

## What a Good v1.0 Design Session Produces

By the end of the design conversation, we should have:

1. **A v1.0 scope document** — what's in, what's deferred to v1.1+
2. **Garden design** — content model, public UX, management flow, visual design
3. **Chat UX design** — tool visualization, persistence, proactive messaging
4. **Polish list** — specific UI/UX improvements across existing screens
5. **Prioritized build order** — what to build first, dependencies between pieces
6. **Updated screen specs** — revised versions of the 10 screens with v1.0 changes

This becomes the input for the next sprint cycle with Armando.
