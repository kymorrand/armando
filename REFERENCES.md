# References & Influences

Sources that informed Armando's design, with attribution for what was adopted.
This file is maintained as part of Armando's version history. When adding new
influences, include: what the source is, what pattern was adopted, and why.

---

## Academic

### CAID — Centralized Asynchronous Isolated Delegation
- **Authors:** Jiayi Geng & Graham Neubig, Carnegie Mellon University
- **Published:** March 2026
- **Link:** https://arxiv.org/abs/2603.21489
- **What it is:** Multi-agent coordination paradigm using centralized task delegation, async execution, and isolated workspaces. 26.7% improvement over single-agent baselines.
- **Adopted patterns:** Dependency-aware task graphs (Thorn checks for file overlap before parallel dispatch), self-verification before commit, dynamic re-planning after merge.

### YC-Bench — Long-Term Planning and Consistent Execution
- **Authors:** He et al. (Collinear AI)
- **Published:** April 2026
- **Link:** https://arxiv.org/abs/2604.01212
- **What it is:** Benchmark evaluating agent strategic coherence over hundreds of turns. Scratchpad usage is the strongest predictor of success.
- **Adopted patterns:** Aggressive scratchpad/memory writes after every dispatch completion (not just session end), parallelization guards (over-parallelization is a distinct failure mode), early adaptation checkpoints.

---

## Anthropic Engineering

### Claude Code Auto Mode
- **Published:** March 25, 2026
- **Link:** https://www.anthropic.com/engineering/claude-code-auto-mode
- **What it is:** Two-layer classifier system (input probe + transcript classifier) that replaces `--dangerously-skip-permissions` with model-based approval.
- **Adopted patterns (deferred to v0.3):** Multi-agent handoff classifiers, deny-and-continue recovery, tiered permission model. Currently noted as target migration from `--dangerously-skip-permissions`.

### Harness Design for Long-Running Application Development
- **Author:** Prithvi Rajasekaran (Anthropic Labs)
- **Published:** March 24, 2026
- **Link:** https://www.anthropic.com/engineering/harness-design-long-running-apps
- **What it is:** Three-agent architecture (planner, generator, evaluator) for multi-hour autonomous coding sessions.
- **Adopted patterns:** Sprint contracts (generator and evaluator negotiate "done" definition before coding), separation of evaluation from generation (Thorn's review should use fresh context with skepticism), file-based inter-agent communication.

---

## Open Source

### Superpowers
- **Author:** Jesse Vincent / Prime Radiant
- **License:** MIT
- **Link:** https://github.com/obra/superpowers
- **What it is:** Agentic skills framework with structured workflow (brainstorm → worktree → plan → subagent-driven-dev → review → finish).
- **Adopted patterns:** Task spec granularity (2-5 minute tasks with exact file paths and verification criteria), two-stage review (spec compliance then code quality), fresh subagent per task.
- **Decision:** Referenced, not adopted as dependency. Armando's architecture is distinct.

### everything-claude-code
- **Author:** affaan-m
- **License:** MIT
- **Link:** https://github.com/affaan-m/everything-claude-code
- **What it is:** Agent harness optimization system — skills, instincts, memory, security, hooks.
- **Adopted concepts:** Instinct evolution with confidence scoring (future upgrade for "What NOT to Do" system), hooks as first-class mechanism (deferred to v0.3), skills/rules/agents as distinct layers.
- **Decision:** Referenced, not adopted as dependency.

### Paperclip
- **Link:** https://docs.paperclip.ing
- **What it is:** Control plane for autonomous AI agent companies. Manages agent registry, task lifecycle, budget tracking, governance.
- **Adopted patterns:** Heartbeat protocol (structured dispatch cycle), atomic task checkout (explicit file scope claim per agent in sprint contracts), agent registry formalization, cost tracking aggregation.
- **Decision:** Referenced now. Evaluate for adoption when Armando scales to 6+ agents or 4+ concurrent projects.

---

## Industry & Community

### Open SWE — LangChain
- **Published:** March 17, 2026
- **Link:** https://blog.langchain.com/open-swe-an-open-source-framework-for-internal-coding-agents/
- **What it is:** Open-source framework capturing patterns from Stripe (Minions), Ramp (Inspect), Coinbase (Cloudbot) internal coding agents.
- **Adopted patterns:** Middleware/safety net concept (deferred to v0.3), mid-run message injection pattern, curated-not-accumulated tooling principle.

### Agent Evaluation Readiness Checklist — LangChain
- **Published:** March 27, 2026
- **Link:** https://blog.langchain.com/agent-evaluation-readiness-checklist/
- **What it is:** Step-by-step checklist for agent eval: error analysis, dataset construction, grader design.
- **Adopted patterns:** Separate capability evals from regression evals, grade outcomes not paths, garden reports as eval traces with failure taxonomy.

### Karpathy's LLM Knowledge Bases
- **Author:** Andrej Karpathy
- **Source:** Twitter, April 2026
- **What it is:** Pattern for LLM-compiled markdown wikis as personal knowledge bases.
- **Adopted patterns:** Grove as compiled project memory — Thorn maintains indexed, queryable, self-compounding wiki per project.

### Agent Harness Taxonomy
- **Source:** Dan Hock / Aakash Gupta ("2026 Is Agent Harnesses")
- **What it is:** Five-component harness model: Context Injection, Control, Action, Persist, Observe & Verify.
- **Adopted patterns:** Used as organizing framework for Armando upgrade spec. Identified gaps in Control (no middleware) and Observe & Verify (no separated evaluator).

### AI Agent Velocity Metrics
- **Sources:** Scrum.org, Agile Leadership Day India, LangChain skill evaluation
- **What it is:** Emerging consensus that story points are broken for AI agents. Wall-clock time, Agent Efficiency Score, and Human-Agent Handoff Time replace traditional velocity.
- **Adopted patterns:** Per-dispatch velocity tracking (wall-clock, review duration, outcome, revision count) in sprint contracts and garden reports.
