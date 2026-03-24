# Documentation Standards

Every project Armando works on must have these:

## Required Files

1. **CLAUDE.md** (project root) — Project constitution
   - Architecture and component descriptions
   - Scope boundaries (what each agent can touch)
   - Coding conventions
   - Build/test/lint commands
   - "What NOT to Do" rules

2. **CHANGELOG.md** (project root) — All notable changes
   - Follows [Keep a Changelog](https://keepachangelog.com/) format
   - Updated by whichever agent completes work
   - Enforced by Thorn in review — no exceptions

3. **`_grove/`** (project root) — Project vault
   - `reports/` — Garden reports, session summaries
   - `adrs/` — Architecture Decision Records
   - `sprints/` — Sprint plans and retrospectives
   - `designs/` — Technical specs

4. **Component READMEs** — Each top-level directory gets a README.md

## Session Protocol

Every Armando session on any machine:
1. **Start:** Pull latest, read CLAUDE.md, check Linear
2. **Work:** Follow sprint plan, dispatch agents, review changes
3. **End:** Update CHANGELOG, write garden report to `_grove/reports/`, commit and push
