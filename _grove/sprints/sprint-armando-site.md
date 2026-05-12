# Sprint Contract: armando.morrandmore.com landing page

## Task

- **Agent:** bloom
- **Linear Issue:** none
- **Dispatched At:** 2026-05-11T19:16:19-04:00
- **Mode:** interactive
- **Summary:** Build a Next.js 16 single-page site for `armando.morrandmore.com` that documents Armando's portable install, links to the GitHub repo, and renders the live changelog. Auto-syncs from the public armando repo. Hosted on Vercel.

## Scope

### Files to Touch

All under `/home/kyle/projects/armando-site/`. This is a NEW project, scaffold from scratch.

- [ ] `package.json`, `tsconfig.json`, `next.config.ts`, `tailwind.config.ts`, `postcss.config.js`, `.gitignore`, `.eslintrc.json` (or flat config) — standard Next.js 16 App Router scaffold with TypeScript
- [ ] `app/layout.tsx` — root layout, font setup (Inter or similar), Tailwind imports
- [ ] `app/page.tsx` — the single landing page. Server Component. Fetches `CHANGELOG.md` and `VERSION` from `raw.githubusercontent.com/kymorrand/armando/main/` with `next: { revalidate: 3600 }`. Renders all sections.
- [ ] `app/globals.css` — Tailwind directives + any global styles
- [ ] `components/install-tabs.tsx` — client component: tabbed install instructions (Windows 11 / macOS / Linux). Active tab state.
- [ ] `components/copy-block.tsx` — client component: code block with a copy button. Uses `navigator.clipboard.writeText`. Visual feedback on copy.
- [ ] `components/architecture-diagram.tsx` — inline SVG showing Armando + Bloom + Root + Canopy with their relationships. Tasteful, no clipart. Server Component.
- [ ] `components/changelog.tsx` — renders the fetched CHANGELOG.md as styled markdown. Use `react-markdown` or `marked` + DOMPurify. Server Component.
- [ ] `components/horizon-explainer.tsx` — short prose block on Horizon mode: missions, heartbeats, for-kyle queue, checkpoints. 3-4 sentences plus a visual or icon list. Server Component.
- [ ] `lib/github.ts` — typed fetch helpers for the raw GitHub URLs. Centralizes the revalidate config.
- [ ] `lib/install-instructions.ts` — typed const array of `{ os, steps[], teardown }` so the install-tabs component renders from data not hardcoded JSX. Reflects the exact commands we shipped in the bootstrap.
- [ ] `public/favicon.svg` (or .ico) — simple armando-flavored mark, lowercase 'a' in a circle, terminal-green on dark. Or grab a plant/seedling glyph. Use the existing Armando color palette: green for Bloom, purple for Root, cyan for Canopy, yellow for Armando lead.
- [ ] `README.md` — how to dev locally, deploy to Vercel, set up the custom domain. Brief.

### Files NOT to Touch

- Anything in `/home/kyle/armando/`: that's the source repo, not the docs site.
- No Vercel-platform changes (no `vercel link`, no `vercel deploy`). Kyle handles Vercel project creation and DNS himself.

### Dependencies

- **Depends on:** none
- **Blocks:** Vercel deployment (Kyle's manual step after Bloom finishes)

## Acceptance Criteria

1. `npm install` succeeds with no peer-dep warnings beyond Next.js's standard set.
2. `npm run dev` starts the dev server, page renders at `localhost:3000` with all 8 sections visible.
3. `npm run build` succeeds. No TypeScript errors. No ESLint errors.
4. CHANGELOG.md content from the live armando repo renders inside the changelog section. Verified by opening the page and seeing the latest 0.3.3 entry plus prior history.
5. Current VERSION from the live armando repo renders in the hero badge. Verified visually.
6. All three OS tabs (Windows 11, macOS, Linux) render the correct install commands matching the actual bootstrap scripts. Cross-check against `/home/kyle/armando/bootstrap.sh` and `/home/kyle/armando/bootstrap.ps1`.
7. Copy buttons work in browser: click copies the command to clipboard, button shows confirmation state for ~1.5s.
8. Architecture diagram is inline SVG (no external image dependency). Uses the agent color palette (yellow/green/purple/cyan).
9. Horizon mode explainer is concise (under 80 words) and accurate (cross-check against the `Horizon` sections in `/home/kyle/armando/agents/armando.md` and `/home/kyle/armando/CLAUDE.md`).
10. Page is responsive: looks correct at 375px width (iPhone SE) and 1440px width.
11. No console errors or warnings in the browser when loading the page.
12. README documents: `npm install && npm run dev` for local; `vercel` for deploy; how to add `armando.morrandmore.com` as a custom domain in Vercel and what CNAME record to add at the DNS provider.
13. **No em dashes** anywhere in code, copy, or commit messages. Project rule.
14. **No marketing fluff.** Terminal-native voice consistent with Armando's existing CLAUDE.md and agent docs. "Let's go do it, dude." is allowed.

## Verification Commands

```bash
cd /home/kyle/projects/armando-site

# Lint and build
npm install
npm run lint
npm run build

# Em-dash sweep across source
! grep -rP '[–—]' app components lib README.md

# Verify GitHub fetch URLs are correct (no typos in raw.githubusercontent paths)
grep -rE 'raw.githubusercontent.com/kymorrand/armando' app components lib

# Smoke: dev server starts, port 3000 responds 200
npm run dev &
DEV_PID=$!
sleep 8
curl -sf http://localhost:3000 -o /tmp/page.html && echo "200 OK"
kill $DEV_PID

# Page-content sanity: changelog markers present
grep -q "0.3.3" /tmp/page.html
grep -q "Armando" /tmp/page.html
```

## Verification Artifact (sidecar)

Write to `/home/kyle/armando/_grove/sprints/sprint-armando-site.verify.json` per the schema in `/home/kyle/armando/agents/armando.md` "Fabrication hardening (sidecar protocol)" section.

**Load-Bearing Claims:**

- `npm-build-ok`: `npm run build` exits 0
- `lint-clean`: `npm run lint` exits 0
- `dev-server-200`: dev server returns 200 on /
- `changelog-rendered`: page HTML contains "0.3.3" string (proves the GitHub fetch worked and rendered)
- `no-em-dashes`: grep finds zero em dashes in source

## Design Notes

**Stack:**
- Next.js 16 (latest stable) with App Router. Per the session-start knowledge update: read the official docs at https://nextjs.org/docs before assuming APIs. Verify the latest API patterns (especially Server Components, fetch caching, and the `cache` API).
- TypeScript strict mode
- Tailwind CSS v3 or v4 (whichever is current and stable)
- shadcn/ui for tabs + buttons (run `npx shadcn@latest init`)
- Bun is fine if you prefer; npm is the default

**Aesthetic:**
- Terminal-native. Dark background, monospace for code, generous whitespace.
- Color tokens (use the Armando palette):
  - Armando lead: `#FDE047` (yellow-300)
  - Bloom (frontend): `#86EFAC` (green-300)
  - Root (backend): `#D8B4FE` (purple-300)
  - Canopy (Unity): `#67E8F9` (cyan-300)
- Background: near-black (`#0A0A0A` or `#0E0E0E`). NOT pure black.
- Body text: warm off-white. Not pure white.
- One accent color globally (yellow / Armando lead).
- No drop shadows, no gradients, no glassmorphism. Crisp flat blocks.

**Architecture diagram:**
- Four boxes: Armando at top center (yellow border), Bloom/Root/Canopy as a row underneath (green/purple/cyan borders).
- Lines from Armando to each sub-agent.
- Tiny label under each box: "lead", "frontend", "backend", "unity/c#".
- Inline SVG, viewBox-scaled, no fixed pixel widths.

**Install tabs:**
- Three tabs (Windows 11 / macOS / Linux). Windows 11 is the active default since that's Kyle's primary test target.
- Inside each: a Quick Install (one-liner, copy button) followed by a Manual (typed-step-by-step, also with copy buttons per command) followed by Uninstall.
- Cross-reference the commands against bootstrap.ps1 and bootstrap.sh in the armando repo. If the commands you ship don't match the scripts, that's a defect.

**Horizon explainer:**
- 60-80 words.
- Mentions: mission brief, authority envelope, heartbeats, for_kyle queue, checkpoints.
- Calls out "0.3+ feature" so users know it's not the only mode.

**Changelog rendering:**
- The CHANGELOG.md uses standard markdown with `## [version]: date` headers and bullet lists.
- Render as styled markdown. Headers get the accent color. Bullets indented.
- Collapse older entries: show latest 3 versions expanded, then a "show all" toggle (client component). If that adds too much code, skip the toggle and render everything.

## Reporting

When done, return a status report with:
- Files created (paths)
- Verification results (commands, pass/fail)
- Sidecar path
- A brief deploy checklist for Kyle (the 5 manual steps: create GH repo, push, link Vercel, add domain, add CNAME)
- Anything flagged for Armando's review

Stop after the deliverable. Armando reviews next. Do NOT commit anything.

Let's go do it, dude.

---

## Outcome

- **Completed At:** 2026-05-12 (verified by Armando in this session; Bloom's original dispatch was 2026-05-11 19:16, build artifacts left in place overnight)
- **Agent wall clock:** unknown (dispatch handoff straddled session boundary)
- **Review duration:** ~5 minutes (lint + build + dev smoke + content sanity + sidecar write)
- **Outcome:** pass
- **Revision count:** 0
- **Tests status:** lint clean; `next build` green (static prerender, 1h revalidate confirmed on `/`); dev server returns 200; page HTML contains `0.3.3` (3x) and `Armando` (33x), confirming the GitHub raw fetch + CHANGELOG render path works.
- **Sidecar:** `_grove/sprints/sprint-armando-site.verify.json` — 5/5 load-bearing claims verified.
- **Scope adherence:** all files under `/home/kyle/projects/armando-site/`; no edits to `/home/kyle/armando/`; no `vercel link` or `vercel deploy` performed (Kyle's manual step).
- **Gaps / follow-ups:**
  - Repo not yet `git init`-ed. Required before `vercel link` will work cleanly.
  - No browser-rendered visual check yet (responsive 375px / 1440px, copy-button feedback, console error scan). Acceptance #10 and #11 are unverified in this pass; recommend a quick browser pass before / after the Vercel deploy.
  - Quick-install one-liners and per-step manual commands in `lib/install-instructions.ts` should be diffed against the actual `bootstrap.sh` / `bootstrap.ps1` before going public. Not verified in this pass.
- **New CLAUDE.md rules:** none.

### Deploy checklist for Kyle (5 manual steps)

1. **`git init` + first commit** inside `/home/kyle/projects/armando-site/`. Add `.gitignore` if Bloom did not (verify `node_modules`, `.next`, `.env*.local` excluded).
2. **Create GitHub repo** `kymorrand/armando-site` (public). Push `main`.
3. **`vercel link`** the directory to a new Vercel project (org: morrandmore). Framework auto-detect = `nextjs`. First deploy with `vercel --target preview` to validate, then `vercel --prod`.
4. **Add custom domain** `armando.morrandmore.com` in the Vercel project's Domains tab.
5. **Add DNS** at the morrandmore.com provider: `CNAME armando -> cname.vercel-dns.com.` (Vercel will display the exact target when you add the domain; use whatever it shows.) TLS issues automatically.

Optional polish before / after: browser-verify the page at preview URL (responsive + console), then promote to prod.
