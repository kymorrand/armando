# Handoff: Rootstock, 2026-05-12

**Mode:** Interactive
**Active mission:** none (Mission 03 still closed; Mission 03.5 not started)
**Status at session end:** armando.morrandmore.com is LIVE in production.

## What shipped this session

- Closed the `sprint-armando-site` review loop from 2026-05-11 (Bloom's dispatch).
  Build was complete on disk but unverified and unshipped. Verified:
  - `npm run lint` clean
  - `npm run build` green (Next 16.2.6, static prerender, 1h revalidate on `/`)
  - dev server returns 200, page HTML contains `0.3.3` (3x) and `Armando` (33x)
  - em-dash sweep clean
  - GitHub raw URLs correct (`kymorrand/armando/main`)
  - Sidecar written: `_grove/sprints/sprint-armando-site.verify.json` (5/5 load-bearing pass)
  - Contract Outcome section filled.

- GitHub: `git init -b main` + first commit, repo `kymorrand/armando-site` created public,
  `main` pushed and tracking `origin/main`. Description fixed mid-session (em dash slipped in).

- Vercel: linked to `morrandmore-projects/armando-site`, GitHub auto-deploy connected,
  first deploy READY (`dpl_4Vb3Qh95XM7o9K1WF79Fa8piTjEA`), custom domain attached.

- DNS: Kyle added `A armando 76.76.21.21` at Cloudflare (gray cloud / DNS only).
  Let's Encrypt cert issued; **https://armando.morrandmore.com** serves 200, cache HIT
  from `iad1`, live CHANGELOG fetch confirmed in prod HTML.

## Yellow disclosures (open follow-ups)

1. **Vercel CLI 50.41.0** treated `vercel deploy --target preview` as `target: production`
   on a fresh project where `main` is the implied production branch. No prior prod
   existed to disturb so practical risk was zero, but the flag was effectively ignored.
   Upgrade to `vercel@latest` (currently 52/53) before the next deploy to restore the
   intended preview-first gate.

2. **Acceptance criteria #10, #11, and the install-command cross-check** were not
   verified this session:
   - Responsive layout at 375px (iPhone SE) and 1440px
   - Browser console clean on load
   - Quick-install one-liners and per-step manual commands in
     `lib/install-instructions.ts` diffed against the actual `bootstrap.sh` /
     `bootstrap.ps1`
   Recommend a Bloom browser-verify pass + a Root drift-check on the install commands
   in the next session.

3. **VERCEL_DEPLOYMENT_TOKEN leak** from Mission 03 S16 (2026-04-29) still pending
   rotation. Log at `/tmp/m03-s16-prod-deploy.log`. Not breach-grade.

## Carryover from prior handoff (Mission 03.5 candidates)

- Q-1: M02-post-4 merge to main (cleanup)
- Q-4: Real email transport (Resend recommended)
- Q-7: Mr. Owl MCP wiring + interactive dry-run

## Next session pickup

Either:
- Address the three Yellow items on armando-site (browser-verify + install-command drift + CLI upgrade), or
- Start Mission 03.5 spec, or
- Pick a fresh mission. Trellis web shell still hasn't been started.

## Live infrastructure

- **armando.morrandmore.com**: Vercel project `morrandmore-projects/armando-site`,
  GitHub `kymorrand/armando-site`, auto-deploy on push to `main`.
- DNS: Cloudflare, A record `armando -> 76.76.21.21`, proxy off.
- TLS: Let's Encrypt R13.
- First prod deploy: `dpl_4Vb3Qh95XM7o9K1WF79Fa8piTjEA`.
