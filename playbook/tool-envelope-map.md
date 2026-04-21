# Tool Envelope Map (Horizon Mode)

> The authoritative tool-by-tool Green/Yellow/Red tier assignment for
> Horizon missions. Mission briefs can override any tier via their
> `authority_envelope` section; in the absence of an override, these
> defaults apply.
>
> Governing principle: `~/.claude/settings.json` has
> `skipDangerousModePermissionPrompt: true`. The Claude Code harness does
> not ask for confirmation on dangerous ops. The envelope is the only
> guardrail. Treat it as hard, not suggestive.
>
> When a tool's tier is unclear, treat it as Red. Better to queue and ask
> than act and regret.

---

## Tier definitions

- **Green.** Proceed. Log the action in the next heartbeat's
  "Since last heartbeat" row.
- **Yellow.** Proceed. Flag the decision prominently in the next heartbeat's
  "For Kyle" row with reasoning.
- **Red.** Do not proceed. Append to `for_kyle` queue with the Q-[N]
  schema. Route around the blocker. Continue other work.

---

## 1. Built-in tools (file and code)

| Tool | Within `permitted_write_paths` | Outside `permitted_write_paths` (within Kyle's filesystem) |
|---|---|---|
| `Read` | Green | Green for project dirs; Yellow for other user data (CLAUDE.md in other projects etc); Red for `.env` / credentials files anywhere |
| `Grep` | Green | Green for project dirs; Yellow for broad home-dir searches |
| `Glob` | Green | Green for project dirs; Yellow for broad home-dir globs |
| `Edit` | Green | Yellow (write outside `permitted_write_paths` is significant; flag) |
| `Write` | Green (including new files) | Yellow; Red if creating files in `~/.claude/` or agent soul paths |
| `NotebookEdit` | Green | Yellow |
| `Bash` | See "Bash command specifics" below | See below |
| `Agent` (sub-agent dispatch) | Green, with sprint contract | Green, with sprint contract |
| `Skill` | Green for internal workflows (`/spiral`, `/status`, `/test-all`, `/review-all`, `/unity-verify`); Red for any skill that modifies Kyle's Claude Code config (`update-config`, `fewer-permission-prompts`, `keybindings-help`) | Same |
| `ToolSearch` | Green | Green |
| `ScheduleWakeup` | Green | Green |
| `Monitor` | Green (watching a background process Armando started) | Green |
| `EnterWorktree` / `ExitWorktree` | Green (sub-agent dispatch mechanic) | Green |
| `EnterPlanMode` / `ExitPlanMode` | Green | Green |
| `AskUserQuestion` | **Red.** Forbidden in Horizon mode. Blocks synchronously on Kyle. Use `for_kyle` queue instead. | Red |
| `PushNotification` | **Red.** Outbound human signal not allowed in Horizon mode; Kyle defines when he's reached. | Red |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskOutput` / `TaskStop` / `TaskUpdate` | Green | Green |

---

## 2. Bash command specifics

Bash is a superset. Tier by command class, not tool.

### 2.1 Read-only ops

| Command | Tier | Notes |
|---|---|---|
| `ls`, `find`, `stat`, `file`, `du`, `df` | Green | Information only |
| `cat`, `head`, `tail` (prefer Read tool) | Green within mission / project; Yellow on other user data; Red on `.env` / credentials |
| `ps`, `uptime`, `free`, `top -b -n 1` | Green | |
| `git status`, `git diff`, `git log`, `git show`, `git branch`, `git remote -v` | Green | |

### 2.2 Git write ops

| Command | Tier | Notes |
|---|---|---|
| `git add`, `git commit` (non-amend) | Green | Log in heartbeat |
| `git checkout <existing-branch>` | Green | |
| `git checkout -b <new-branch>` | Green | |
| `git worktree add` / `git worktree remove` | Green | |
| `git merge` into feature branch | Green | |
| `git merge` into main / master / prod | **Red** | |
| `git push` to feature branch | **Yellow** | Flag the branch name and rationale |
| `git push` to main / master / prod | **Red** | |
| `git push --force` or `--force-with-lease` | **Red** | |
| `git reset --hard` | **Red** | |
| `git branch -D` (force delete) | **Red** | |
| `git commit --amend` | Yellow | Avoid when possible; create a new commit |
| `git tag` (lightweight) | Green | |
| `git tag -s` (signed) | Yellow | |
| `git rebase` (non-interactive) on feature branch | Yellow | |
| `git rebase` onto main / master | **Red** | |
| `git rebase -i` | **Red.** Interactive; can't run in batch. |
| `git clean -f` | **Red** | |
| `git cherry-pick` | Yellow | Can introduce surprising history |

### 2.3 Package / dependency ops

| Command | Tier | Notes |
|---|---|---|
| `npm install` / `pnpm install` / `yarn install` (reading lockfile only) | Green | No new packages added |
| `npm install <pkg>` / `pnpm add <pkg>` / `yarn add <pkg>` (project-local) | **Yellow** | New dependency; flag the package name in heartbeat |
| `npm install -g <pkg>` / `pnpm add -g <pkg>` | **Yellow** | System-wide install |
| `pip install <pkg>` in a venv | **Yellow** | |
| `pip install <pkg>` system-wide | **Yellow** | |
| `brew install` / `apt install` / `apt-get install` | **Yellow** (Red if sudo required per policy below) | |
| `cargo add` / `cargo install` | Yellow | |
| `go get` / `go install` | Yellow | |
| `nuget` package installs | Yellow | |
| Unity package add via `Packages/manifest.json` edit | Yellow | |

### 2.4 System / privilege ops

| Command | Tier | Notes |
|---|---|---|
| `sudo <anything>` | **Red** | Never |
| `rm` of files inside `permitted_write_paths` | Green | |
| `rm` of files inside a project Armando owns | Yellow | |
| `rm -rf` outside `permitted_write_paths` | **Red** | |
| `chmod` / `chown` on files Armando created | Green | |
| `chmod` / `chown` on system paths | **Red** | |
| `kill` / `pkill` on processes Armando started | Green | |
| `kill -9` on system processes | **Red** | |
| `systemctl` / `service` | **Red** | |
| `crontab -e` | **Red** (use `CronCreate` tool instead) | |

### 2.5 Test / lint / build

| Command | Tier | Notes |
|---|---|---|
| Project-local test runners | Green | Tests, lint, typecheck, format |
| Project-local build / compile | Green | `npm run build`, `cargo build`, Unity batch-mode compile |
| Deployment commands (`vercel deploy`, `flyctl deploy`) | **Yellow** if preview; **Red** if production | |

### 2.6 Network

| Command | Tier | Notes |
|---|---|---|
| `curl` / `wget` GET | Green | |
| `curl` / `wget` POST / PUT / DELETE to external APIs | **Yellow** unless charter elevates | |
| `ssh` to Kyle's machines | **Red** | |
| `scp` / `rsync` to remote | **Yellow** | |

---

## 3. Web tools

| Tool | Tier | Notes |
|---|---|---|
| `WebFetch` GET | Green | |
| `WebFetch` with write verbs (POST/PUT/DELETE) | **Yellow** | |
| `WebSearch` | Green | |

---

## 4. Scheduling and triggers

| Tool | Tier | Notes |
|---|---|---|
| `CronCreate` (short-horizon, mission-internal) | **Yellow** | New cron job worth Kyle's visibility |
| `CronList` / `CronGet` | Green | |
| `CronDelete` of a cron Armando created | Green | |
| `CronDelete` of a cron Armando did not create | **Red** | |
| `RemoteTrigger` | **Yellow** | External event dispatch |

---

## 5. Linear

| Operation | Tier | Notes |
|---|---|---|
| `list_*`, `get_*`, `search_*`, `list_issue_statuses`, `list_cycles` | Green | Reads |
| Status transition Todo ↔ InProgress ↔ InReview | Green | Routine |
| Status transition → Done | **Yellow** | Shipping deserves visibility |
| `save_issue` create (new bug, tech debt, scope violation) | Green | |
| `save_issue` edit (scope / priority / title change on existing issue) | **Yellow** | Changing what Kyle already sees |
| `linear_bulk_update_issues` | **Yellow** | Bulk ops are higher-impact |
| `linear_delete_issue` | **Red** | Kyle-only |
| `linear_delete_comment` | **Yellow** | |
| `save_project`, `save_milestone`, `save_initiative` (create) | **Yellow** | |
| `linear_delete_project_milestone` | **Red** | |
| `save_status_update`, `delete_status_update` | Yellow | |
| `create_attachment`, `delete_attachment` | Yellow | |
| `linear_resolve_comment` / `unresolve_comment` | Green | |
| `save_comment`, `update_comment` | Green | |
| `create_document`, `update_document`, `get_document`, `list_documents` | Yellow for writes; Green for reads | |
| `create_issue_label`, `list_issue_labels`, `list_project_labels` | Green (list) / Yellow (create) | |
| `search_documentation` | Green | |

---

## 6. Google Workspace

### 6.1 Google Calendar

| Operation | Tier | Notes |
|---|---|---|
| `list_calendars`, `list_events`, `get_event`, `suggest_time` | **Yellow** | Reading Kyle's calendar is worth flagging |
| `create_event`, `update_event`, `delete_event`, `respond_to_event` | **Red** | Calendar writes change Kyle's schedule |

### 6.2 Gmail

| Operation | Tier | Notes |
|---|---|---|
| `search_threads`, `get_thread`, `list_drafts`, `list_labels` | **Yellow** | Reading Kyle's mail |
| `create_draft`, `create_label`, `label_message`, `label_thread`, `unlabel_message`, `unlabel_thread` | **Yellow** | Drafts and labels are reversible |
| Sending mail (any op that actually sends) | **Red** | Outbound human-visible signal |

### 6.3 Google Drive

| Operation | Tier | Notes |
|---|---|---|
| `list_recent_files`, `search_files`, `get_file_metadata`, `get_file_permissions`, `read_file_content`, `download_file_content` | **Yellow** | Reads |
| `create_file` | **Yellow** | Writes |

### 6.4 Granola (meeting transcripts)

| Operation | Tier | Notes |
|---|---|---|
| All (`get_meeting_transcript`, `get_meetings`, `list_meeting_folders`, `list_meetings`, `query_granola_meetings`) | **Yellow** | Kyle's meeting content |

---

## 7. Notion

| Operation | Tier | Notes |
|---|---|---|
| `notion-search`, `notion-fetch`, `notion-get-comments`, `notion-get-teams`, `notion-get-users`, `notion-query-database-view`, `notion-query-meeting-notes` | **Yellow** | Reads |
| `notion-create-pages`, `notion-create-database`, `notion-create-view`, `notion-create-comment`, `notion-duplicate-page`, `notion-move-pages`, `notion-update-page`, `notion-update-view`, `notion-update-data-source` | **Yellow** | Writes; flag each in heartbeat |

---

## 8. Gamma

| Operation | Tier | Notes |
|---|---|---|
| `generate`, `read_gamma`, `get_folders`, `get_generation_status`, `get_themes` | **Yellow** | Generation is high-visibility output |

---

## 9. Vercel plugin

| Operation | Tier | Notes |
|---|---|---|
| `authenticate`, `complete_authentication` | **Red** | Credential flow |
| Other Vercel plugin ops | Evaluate per-op; default Yellow for reads, Red for production deploys |

---

## 10. Agent / sub-agent dispatch

| Aspect | Tier | Notes |
|---|---|---|
| Dispatching Bloom / Root / Canopy with a sprint contract inheriting the mission's envelope | Green | |
| Dispatching an agent NOT named in the mission's `collaboration_charter` | **Red** | Out-of-charter invocation |
| Dispatching to an agent that doesn't exist (Ivy / Mr. Owl pre-existence) | **Red** | Queue and route around |
| Dispatching with `inherited_envelope: red` (for an explicitly Red sub-task) | **Red** | Don't do it; queue the task instead |

---

## 11. Special cases

### 11.1 Agent soul files

Any write to `~/armando/agents/*.md`, `~/.claude/agents/*.md`, the
sub-agent description fields, or the repo README: **Red.** These are
Armando's self-definition; only Kyle changes them.

### 11.2 `.env` and credentials

Any read or write touching `.env`, `.env.*`, `credentials.json`,
`service-account.json`, SSH keys, `~/.config/gcloud/`, `~/.aws/`,
`~/.kube/`, or similarly named files: **Red.** Mission briefs that need
credentialed access must pre-provision specific values; do not discover
credentials mid-mission.

### 11.3 Spending

- Within pre-provisioned mission budget: Green (log actual spend in
  heartbeat).
- Up to 2× pre-provisioned budget without mission-brief authorization:
  Yellow.
- Above 2× pre-provisioned budget: **Red.** Queue and route around.
- Spending outside any pre-provisioned budget: **Red.**

### 11.4 Destructive ops that Claude Code can't undo

Force-push, hard reset, branch force-delete, `rm -rf` outside mission
dir, any sudo: **Red.** No exceptions even with charter override in the
mission brief; Kyle must explicitly whitelist the specific command in the
brief's pre-provisioned section.

---

## 12. Default when unclear

**If a tool's tier is not listed here and not overridden in the mission
brief, treat it as Red.** Append to `for_kyle` as a Priority: soft
item with the tool name and intended use case; route around and continue
other work. Kyle can respond inline; once he does, Armando has a
precedent for future missions and this playbook gets updated.

---

## 13. Maintenance

This file is canonical. Changes to it are Yellow-tier (disclose in
heartbeat) during missions and standard PRs during Interactive mode. Rows
that consistently trip alerts during actual missions should get promoted
to explicit Red or demoted to explicit Green based on what Kyle actually
cares about. The point is that by Mission 05 or so, this file reflects
how Kyle actually runs rather than how Armando guessed.
