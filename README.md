# MASTERMIND 2.0 — Master Project Template

> A reusable **Project Operating System** for SaaS / app / product projects.
> Designed for a hybrid **Cursor + Claude Opus Max + MCP** workflow.
> Every file is in English on purpose (consistency with upstream skills and to avoid translation drift). The user can write their own content in any language.

---

## What this is

MASTERMIND 2.0 is a template repository that you **clone once per project**. It gives any AI agent working on the project:

> **Start here:**
> - [`OPERATING-GUIDE.md`](OPERATING-GUIDE.md) — the full operational manual (~2000 lines). Read linearly the first time; consult by section afterwards. Covers every phase, every skill, every workflow, with a worked end-to-end example ("Notas-AI") and an FAQ.
> - [`COMMANDS.md`](COMMANDS.md) — the fast reference for the 11 `/mm-*` slash commands. Keep it open to answer *"which command now?"* in 5 seconds.


- A **kernel** (`CLAUDE.md`) that defines the operating rules.
- A **memory bank** (`memory/`) that survives across sessions and models.
- A **rules layer** (`.cursor/rules/`) always loaded by Cursor.
- A **skills layer** (`.cursor/skills/`) with reusable playbooks loaded on demand.
- A **Claude-side** mirror (`.claude/` and `claude-side/`) for Claude Desktop and MCP configuration.
- A **docs** folder (`docs/`) as source of truth for product, architecture, features, flows, API, testing, security, and ADRs.

It is built on three foundations:

1. The [Karpathy principles](https://github.com/forrestchang/andrej-karpathy-skills) — think before coding, simplicity first, surgical changes, goal-driven execution.
2. A **Question & Doubt Protocol** — the AI must surface all doubts and ask 8–20 high-quality questions **before** producing any important output.
3. A four-layer architecture (Kernel + Rules + Skills + Memory) that treats **structure as intelligence**.

---

## Repository structure

```
MASTERMIND-2.0/
├── CLAUDE.md                          # Kernel (system brain, canonical)
├── AGENTS.md                          # Same contract for non-Cursor agents (Codex, etc.)
├── README.md                          # This file
├── .gitignore
│
├── .cursor/
│   ├── rules/                         # Always-on instructions for Cursor
│   │   ├── 00-project-operating-system.mdc   # CANONICAL
│   │   ├── 01-karpathy-principles.mdc        # CANONICAL (Karpathy, verbatim)
│   │   ├── 02-tech-stack.mdc                 # Filled per project
│   │   ├── 03-testing-policy.mdc             # Filled per project
│   │   ├── 04-safety-and-git.mdc             # Filled per project
│   │   └── 05-claude-mcp-integration.mdc     # Filled per project
│   ├── skills/                        # Reusable playbooks (SKILL.md each) — CANONICAL SOURCE
│   │   ├── project-deep-audit/
│   │   ├── doubt-surfacer/
│   │   ├── product-requirements/
│   │   ├── architecture-mapper/
│   │   ├── feature-breakdown/
│   │   ├── flow-analyzer/
│   │   ├── implementation-planner/
│   │   ├── test-strategist/
│   │   ├── security-review/
│   │   ├── bug-investigator/
│   │   ├── code-reviewer/
│   │   ├── research-first/
│   │   ├── skill-creator/
│   │   └── memory-updater/
│   └── plans/                         # Approved Plan Mode plans
│
├── .claude/                           # Mirror for Claude Code / Claude Desktop
│   ├── CLAUDE.md                      # Reference to root CLAUDE.md (no duplication)
│   ├── skills/                        # GENERATED — mirror of .cursor/skills/ (see scripts/)
│   ├── hooks/                         # Claude-side hooks (extension point)
│   ├── agents/
│   ├── memory/
│   └── workflows/
│
├── memory/                            # Long-term project intelligence (Git-versioned)
│   ├── 00-project-brief.md
│   ├── 01-product-vision.md
│   ├── 02-current-state.md
│   ├── 03-architecture.md
│   ├── 04-data-model.md
│   ├── 05-user-flows.md
│   ├── 06-feature-map.md
│   ├── 07-decisions-log.md
│   ├── 08-known-risks.md
│   ├── 09-testing-status.md
│   ├── 10-open-questions.md
│   ├── 11-session-summary.md
│   └── 12-open-doubts-and-questions.md   # CANONICAL template
│
├── docs/                              # Human-readable source of truth
│   ├── product/
│   ├── architecture/
│   ├── features/
│   ├── flows/
│   ├── api/
│   ├── testing/
│   ├── security/
│   └── adr/
│
├── claude-side/                       # Claude Desktop + MCP
│   ├── mcp-config.json
│   └── prompts/
│
└── scripts/                           # Automation scripts (sync, setup, etc.)
    ├── sync-skills.ps1                # Windows / cross-platform PowerShell
    ├── sync-skills.sh                 # Unix / macOS
    └── sync-from-template.ps1/.sh     # Pull template updates into an existing project safely
```

### Skills — canonical source + mirror

- Canonical source: `.cursor/skills/` (edit here).
- Mirror for Claude: `.claude/skills/` (generated — never edit by hand).
- After editing any SKILL.md, run `pwsh -File scripts/sync-skills.ps1` (or the `.sh` variant).
- Verify before commit: `pwsh -File scripts/sync-skills.ps1 -Check` (exits 1 on drift).

### Onboarding an EXISTING project (not born from MASTERMIND)

If you already have a project with code, commits, README, maybe tests and CI, and you want to bring it into MASTERMIND without starting over, use [`scripts/onboard-existing-project.ps1`](scripts/onboard-existing-project.ps1) (`.sh`) + workflow [`06-onboard-existing-project`](.claude/workflows/06-onboard-existing-project.md) + slash command `/mm-onboard`.

What makes it safe:
- **Dry-run by default.** Nothing is written unless `-Apply`.
- **Conflict-as-proposal pattern.** If a file already exists in the target AND differs from the template, the template version is written next to it as `<file>.mastermind-proposal`. The original is NEVER overwritten. You merge manually.
- **Pre-existing `.cursor/rules/` are relocated**, not deleted, to `.cursor/rules-backup-YYYYMMDD-HHMMSS/`. Use `-KeepExistingRules` to treat them as conflicts instead.
- **Stack auto-detection** from `package.json` / `pyproject.toml` / `Cargo.toml` pre-fills `02-tech-stack.mdc` if the project does not already have one.
- **Phase bootstrap.** You specify the initial phase (Idea / Discovery / Definition / MVP / Iteration / Launch); the script writes `memory/02-current-state.md` + a `memory/13-phase-history.md` entry coherently.
- **Never touches** `src/`, `app/`, `tests/`, lockfiles, `.git/`, `node_modules/`, `dist/`, `.next/`, `.taskmaster/`, `.env*`, `docs/`, or `.cursor/plans/`.

Recommended flow (full workflow at [`.claude/workflows/06-onboard-existing-project.md`](.claude/workflows/06-onboard-existing-project.md)):

```powershell
# 0. In the target project: commit/push pending work, close Cursor/Claude.
cd "<target-project>"
git add . && git commit -m "wip: pre-onboard checkpoint"
# Copy the two scripts from the template:
Copy-Item "<template>\scripts\onboard-existing-project.*" -Destination "scripts\" -Force

# 1. Dry-run:
pwsh -File scripts/onboard-existing-project.ps1 -Template "<template path>" -Phase MVP

# 2. Apply:
pwsh -File scripts/onboard-existing-project.ps1 -Template "<template path>" -Phase MVP -Apply

# 3. Resolve any *.mastermind-proposal files manually (merge or delete).
# 4. Commit: git add . && git commit -m "chore: onboard existing project into MASTERMIND"
# 5. Reload Cursor, restart Claude. Sanity: ask "List active hooks" → expect 4.

# 6. In chat:
/mm-onboard
# → runs the in-IDE phases of workflow 06:
#   Phase 5: retroactive-documenter (seed memory/ from code + git log + README)
#   Phase 6: project-deep-audit (12 angles + Hard Truth)
#   Phase 7: phase-gate-reviewer (confirm the phase picked is correct)
#   Phase 8: first /mm-retro if phase is MVP/Iteration/Launch
```

Exit codes for the script: `0` in-sync, `1` drift detected / aborted, `2` BLOCK (bad args, missing template, or running inside the template).

### Design system + prototyping (shadcn/ui + Claude Design)

MASTERMIND's default design system is **shadcn/ui**, consumed via its [official MCP server](https://ui.shadcn.com/docs/mcp) and [official Skill](https://ui.shadcn.com/docs/skills). Default prototyping surface is **Claude Design** (`claude.ai/design`), which reads the project's shadcn install to produce prototypes that use your real components and tokens.

Why this combo: shadcn is copy-paste (you own the code), MCP gives agents live registry access without prop hallucinations, the Skill gives agents per-project context, and Claude Design hands off cleanly to Claude Code. Nothing to build, nothing to maintain — just integrate.

Entry points:

- **Rule:** [`.cursor/rules/08-design-system.mdc`](.cursor/rules/08-design-system.mdc) — conventions and non-negotiables.
- **Memory file:** [`memory/14-design-system.md`](memory/14-design-system.md) — per-project source of truth for tokens, installed components, likes, anti-patterns, patterns, references.
- **Skill:** [`.cursor/skills/prototype-designer/SKILL.md`](.cursor/skills/prototype-designer/SKILL.md) — bridges memory + Claude Design + shadcn.
- **Command:** [`/mm-design`](.claude/commands/mm-design.md) — wraps the skill for single-command invocation.
- **Script:** [`scripts/install-shadcn-mcp.ps1`](scripts/install-shadcn-mcp.ps1) (`.sh`) — one-shot install in a target project: CLI init + MCP registration + Skill install.

Typical flow in a new MASTERMIND project:

```powershell
# After /mm-bootstrap completes Phases 1-5 and you have memory/00 filled:
pwsh -File scripts/install-shadcn-mcp.ps1 -Apply -Defaults   # CLI + MCP + Skill in one shot.
# Reload Cursor / restart Claude Code. Sanity: shadcn MCP green dot.

# Fill the visual identity in memory/14-design-system.md (name, 3-5 personality adjectives, primary color, fonts, radius, likes, anti-patterns). 10 lines.

# Install baseline components via MCP:
# In chat: "Add button, card, input, dialog, badge from shadcn."

# Later, when prototyping a feature:
/mm-design notification-center fidelity:hi-fi audience:stakeholder
# -> opens the prototype-designer skill: composes the prompt, guides the
#    Claude Design session, captures the handoff bundle, extracts decisions
#    back into memory/14. Next step is /mm-plan.
```

Empty `memory/14` produces generic-IA-flavored prototypes. Fill even the minimum (primary color, 3 personality adjectives, 2 likes, 2 anti-patterns) and every prototype from then on is on-brand. That's the whole trick.

### Syncing an existing project from an updated template

When the template evolves and you have a project cloned from an older version, use [`scripts/sync-from-template.ps1`](scripts/sync-from-template.ps1) (`.sh`) to pull the updates **without touching project-specific content**.

Safe by construction:
- **Dry-run by default.** Nothing is written unless you pass `-Apply`.
- **Whitelist-driven.** Only template files get synced (rules, skills, workflows, commands, hooks, scripts, root docs).
- **Blacklist protected.** `memory/`, `docs/`, `.cursor/plans/`, `.taskmaster/`, `.env*`, `.git/`, `claude-side/prompts/` are never touched.
- **Per-file backups** (`.backup-YYYYMMDD-HHMMSS`) before overwriting, on every `-Apply`.
- **Self-protection:** refuses to run if the current directory IS the template.
- **Confirmation prompt** on `-Apply` unless `-Force` is set.

Recommended flow (in the target project):

```powershell
# 0. Prep: close Cursor/Claude on this project, commit/push pending work.

# 1. Dry-run to review what would change:
pwsh -File scripts/sync-from-template.ps1 -Template "C:\path\to\MASTERMIND-TEMPLATE-2.0"

# 2. If the list looks right, apply with backups + confirmation:
pwsh -File scripts/sync-from-template.ps1 -Template "C:\path\to\MASTERMIND-TEMPLATE-2.0" -Apply

# 3. Inspect the real diff:
git diff

# 4. Commit and reload Cursor + restart Claude:
git add . && git commit -m "chore: sync from MASTERMIND template"
```

```bash
bash scripts/sync-from-template.sh --template /path/to/template
bash scripts/sync-from-template.sh --template /path/to/template --apply
bash scripts/sync-from-template.sh --template /path/to/template --apply --force
```

Exit codes: `0` = in sync, `1` = drift detected (dry-run) or user aborted, `2` = BLOCK (bad args, template missing, or running inside the template).

---

## Execution in System 2

System 1 produces clarity, plans, and quality gates (docs, memory, 14 skills). System 2 is the **execution layer**: how the project is driven from idea to launch, which behavior the agent uses in each moment, and how parallel work is orchestrated.

### Three execution modes (Coach / Executor / Auditor)

The same agent behaves differently depending on the active mode. Modes are states, not separate agents; transitions between modes happen with explicit handoffs. Full definition in [`.cursor/rules/06-execution-modes.mdc`](.cursor/rules/06-execution-modes.mdc).

| Mode | Purpose | Writes code? |
|---|---|---|
| **Coach** | Think with the user. Explore, decide, refine. Socratic questions + options with trade-offs. Runs the Question & Doubt Protocol. | No |
| **Executor** | Execute an approved plan. Surgical changes, TDD, commit at every green. | Yes |
| **Auditor** | Review what was done. Findings by severity. Issue verdict (Ready / With fixes / Not ready). | No |

**Mode selection** follows this priority order:

1. **Workflow dictates** (if a predefined workflow is active, its sequence is enforced).
2. **User override** (`"Coach mode: ..."` at the start of a message).
3. **Orchestrator deduces** from keywords and context.

**Typical sequences by task type:**

| Task | Sequence |
|---|---|
| New feature from raw idea | Coach → Executor → Auditor |
| Bug with clear repro | Executor → Auditor |
| Code review only | Auditor |
| Strategic brainstorm | Coach |
| Pivot / major decision | Coach → Coach |
| Technical refactor | Executor → Auditor |
| Plan without implementing yet | Coach → Executor (planner only) |
| Phase gate transition | Auditor → Coach → proceed or block |

### Phase gates (Idea → Launch)

Projects advance through six phases: **Idea → Discovery → Definition → MVP → Iteration → Launch**. Each transition is gated:

- Canonical phase definitions, entry/exit criteria, and transition log live in [`memory/13-phase-history.md`](memory/13-phase-history.md).
- The [`phase-gate-reviewer`](.cursor/skills/phase-gate-reviewer/SKILL.md) skill verifies artifacts, risks, open doubts, and emits a verdict (PROCEED / PROCEED WITH CAVEATS / BLOCK).
- Dry-run: `pwsh -File scripts/phase-gate-check.ps1 -NextPhase MVP` (exits 1 if gaps exist).
- Gate decisions are logged in `memory/07-decisions-log.md` and `memory/13-phase-history.md`.

### Human-in-the-Loop (approval-gatekeeper)

Sensitive actions — auth, payments, schema, production deploys, new dependencies, destructive commands, tasks > 4h — pass through [`approval-gatekeeper`](.cursor/skills/approval-gatekeeper/SKILL.md). The skill classifies the action (Trivial / Routine / Moderate / Sensitive / High-impact / Forbidden), applies the policy from [`.cursor/rules/04-safety-and-git.mdc`](.cursor/rules/04-safety-and-git.mdc), and returns `AUTO_APPROVE`, `REQUIRE_HUMAN_APPROVAL`, or `BLOCK`. Every decision is logged.

### Subagents and parallel execution

Rules in [`.cursor/rules/07-subagent-orchestration.mdc`](.cursor/rules/07-subagent-orchestration.mdc). Two operational skills turn the rule into action:

| Skill | Scope | When |
|---|---|---|
| [`subagent-dispatcher`](.cursor/skills/subagent-dispatcher/SKILL.md) | Within **one workspace**. Drives an approved plan task-by-task with fresh subagent + two-stage review. | Plans with ≥3 tasks, tasks coupled enough that splitting workspaces would add more coordination than it saves. |
| [`parallel-executor`](.cursor/skills/parallel-executor/SKILL.md) | Across **multiple workspaces** (worktrees). Independence analysis → spawn worktrees → dispatch per workspace → merge in planned order → cleanup. | Plans with ≥2 tasks that are genuinely independent (no shared files / state). |

Core patterns (validated against Anthropic Agent SDK docs and Superpowers canon):

- **Orchestrator + narrow specialists** (2–4 agents max). Orchestrator strategic; specialists narrow.
- **Message-passing, not shared state.** The orchestrator curates exactly the context each subagent needs.
- **Two-stage review per task** — spec compliance **first**, then code quality.
- **Model selection by role** — cheap for mechanical tasks, standard for integration, most capable for architecture/review.
- **Implementer status codes** — DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED. Never silently re-dispatch a BLOCKED subagent.

**Parallel execution via Git worktrees** (helper scripts):

```powershell
# Spawn a new worktree with naming convention + port offset
pwsh -File scripts/worktree-spawn.ps1 -Slug auth-refactor -Type feat -InstallDeps

# Clean merged worktrees (safe default)
pwsh -File scripts/worktree-cleanup.ps1

# Remove a specific one, even with uncommitted work
pwsh -File scripts/worktree-cleanup.ps1 -Slug auth-refactor -Force
```

```bash
bash scripts/worktree-spawn.sh auth-refactor --type feat --install-deps
bash scripts/worktree-cleanup.sh                # sweep merged
bash scripts/worktree-cleanup.sh --slug auth-refactor --force
```

Conventions (enforced by the scripts):
- Worktrees live at `../<repo>-worktrees/<slug>/`.
- Branches are named after the feature (`feat/<slug>`), never the agent.
- Max 3–4 concurrent local worktrees.
- Every worktree gets a deterministic port offset (hash of slug → 10000–19999) in `.worktree-env`.
- Lifecycle ≤ 1 working day; longer means the task is too big — split.

**Docker is NOT required by default.** Worktrees isolate code, not runtime. Introduce Docker Compose project-per-worktree only when a concrete runtime conflict appears (same port, shared DB, shared cache, per-worktree `.env` needed). See rule 07 for the full policy.

### Task Master AI — activation-on-demand (per project)

[`task-master-ai`](https://github.com/eyaltoledano/claude-task-master) is an MCP that parses a PRD into dependency-aware tasks and drives execution via `next_task` / `set_task_status` / `expand_task`. In MASTERMIND 2.0 it is **not always on** — activate per project when:

1. The project is leaving Definition and entering MVP execution.
2. The approved implementation plan has **≥ 10 tasks** (or explicit fan-out).
3. `subagent-dispatcher` will drive the execution.

Install (idempotent; adds MCP entry, scaffolds `.taskmaster/docs/prd.md`, updates `.gitignore`):

```powershell
pwsh -File scripts/install-taskmaster.ps1                   # mode=core (7 tools, ~5k tokens)
pwsh -File scripts/install-taskmaster.ps1 -Mode standard    # 15 tools, ~10k tokens
pwsh -File scripts/install-taskmaster.ps1 -ClaudeCodeAuth   # Claude Code OAuth, no API key
```

```bash
bash scripts/install-taskmaster.sh
bash scripts/install-taskmaster.sh --mode standard
bash scripts/install-taskmaster.sh --claude-code-auth
```

Full integration contract in [`.cursor/rules/05-claude-mcp-integration.mdc`](.cursor/rules/05-claude-mcp-integration.mdc) §Activation-on-demand.

### Skill Interaction Graph updated for System 2 Sub-phase 2.2

```
implementation-planner
   ├── hands off to   subagent-dispatcher  (single workspace)
   ├── hands off to   parallel-executor    (across worktrees)
   └── with task-master-ai installed: emits PRD → parse_prd → tasks.json driver

subagent-dispatcher
   ├── dispatches     implementer subagent (fresh per task)
   ├── dispatches     spec reviewer        (first)
   ├── dispatches     code quality reviewer (second)
   └── invokes        code-reviewer + security-review at final roll-up

parallel-executor
   ├── uses scripts   worktree-spawn, worktree-cleanup
   ├── runs inside    subagent-dispatcher per worktree
   └── merges         via code-reviewer + security-review per PR
```

### Workflows & slash commands (Sub-phase 2.3 — 2.4)

Workflows are ordered recipes that chain skills into end-to-end operations. Slash commands (`/mm-*`) are one-line shortcuts that wrap a workflow or a skill with curated context loading.

**Workflows** ([`.claude/workflows/`](.claude/workflows/)):

| # | File | Purpose |
|---|---|---|
| 01 | `new-project-bootstrap` | Empty clone → Discovery-complete (brief + doubts + audit + transition) |
| 02 | `feature-lifecycle` | Approved epic → merged, tested, reviewed feature |
| 03 | `bug-triage` | Bug report → reproduced → surgical fix + regression test → merge + post-mortem |
| 04 | `phase-gate-transition` | Advance project phase with validation + approval + memory promotion |
| 05 | `weekly-retrospective` | Weekly review of work + risks + drift + lessons + Top 3 next |

**Slash commands** ([`.claude/commands/`](.claude/commands/)):

| Command | Wraps | Use when |
|---|---|---|
| `/mm-bootstrap <idea>` | Workflow 01 | Just cloned the template |
| `/mm-audit [focus]` | `project-deep-audit` | Multi-angle audit with Hard Truth |
| `/mm-plan <slice>` | `implementation-planner` | Need a bite-sized TDD plan |
| `/mm-ship <epic>` | Workflow 02 | Ship an approved epic end-to-end |
| `/mm-bug <description>` | Workflow 03 | A bug arrives |
| `/mm-doubt [topic]` | `doubt-surfacer` | Force the Question Protocol right now |
| `/mm-next [details]` | task-master / plan | Start of session, "what do I work on?" |
| `/mm-review [branch]` | `code-reviewer` + `security-review` | Review current branch or PR |
| `/mm-gate <phase>` | Workflow 04 | Transition to the next phase |
| `/mm-retro [period]` | Workflow 05 | Weekly retrospective |
| `/mm-learn [window]` | `continuous-learner` | Promote qualifying lessons to cross-project memory |

In Cursor (which does not natively interpret `/`-prefixed commands the same way Claude Code does), invoke them by reference: *"Run `.claude/commands/mm-ship.md` with `auth-mvp`"*.

### Command Recommendation Protocol (active on every turn)

The agent actively **recommends the next `/mm-*` command** at the end of any non-trivial turn, with an explicit **confidence level** so you always know the operational next step.

| Level | When it fires | Format the agent uses |
|---|---|---|
| **HIGH** | One command clearly applies | `Next recommended command: /mm-X [args]` + `Why:` + `Go ahead: type` `go` `to proceed` + `Skip if: …` |
| **MEDIUM** | Two or more commands plausible | `Possible next commands (pick one): a) /mm-X / b) /mm-Y / c) Nothing yet` — you reply `a`, `b`, or `c` |
| **LOW** | No command fits (pure exploration) | Explicit "no recommendation"; the agent does **not** force one |

**What "integrated" means in practice:**

- **Consistent output:** every non-trivial turn closes with one of these blocks. No more guessing "what's the next step?".
- **One-keystroke confirmation:** for HIGH, you type `go` and the agent proceeds as if you ran the command. For MEDIUM you pick the letter. For LOW you take the lead.
- **Never auto-executes without consent:** the agent always waits for your `go` (HIGH), your pick (MEDIUM), or your direction (LOW). Running the command yourself by typing `/mm-X` works identically.
- **Safety preserved:** even after `go`, sensitive actions (auth, payments, schema, production) still route through `approval-gatekeeper`. This protocol never bypasses safety rules.
- **Auto-downgrade built-in:** if a HIGH has a plausible alternative, the agent self-downgrades to MEDIUM. Protects against false confidence.
- **Never spam:** trivial replies, clarifying Q&A, or turns already inside `doubt-surfacer` get no recommendation block.

**Where it lives:**

- Contract: [`CLAUDE.md §5`](CLAUDE.md).
- Hook: [`.cursor/hooks/post-output.suggest-command.md`](.cursor/hooks/post-output.suggest-command.md) with activation conditions, templates, and auto-downgrade rule.
- Skill closings updated: the `Closing` step of 14 skills (project-deep-audit, product-requirements, architecture-mapper, feature-breakdown, flow-analyzer, implementation-planner, test-strategist, code-reviewer, security-review, phase-gate-reviewer, research-first, subagent-dispatcher, parallel-executor, bug-investigator) uses the three-level format.
- Quick reference for users: [`COMMANDS.md §Command Recommendation Protocol`](COMMANDS.md).
- Kill-switch: `MM_HOOK_SUGGEST_COMMAND=off`.

### Hooks (Sub-phase 2.4)

Two classes of hooks, both in place:

**Agent-level behavioral hooks** (`.cursor/hooks/`): instruction files that MASTERMIND-aware agents read at the relevant event.

| Hook | Event | Purpose |
|---|---|---|
| [`pre-task.doubt-surfacer`](.cursor/hooks/pre-task.doubt-surfacer.md) | Before non-trivial user turns | Force Question Protocol when keywords / phase / scope warrant it |
| [`post-task.memory-updater`](.cursor/hooks/post-task.memory-updater.md) | After task completion | Ensure memory-updater ran before closing the turn |
| [`post-merge.docs-refresh`](.cursor/hooks/post-merge.docs-refresh.md) | After a merge to main | Propose refreshing docs/memory that the merge made stale |
| [`post-output.suggest-command`](.cursor/hooks/post-output.suggest-command.md) | End of any non-trivial turn | Emit a HIGH / MEDIUM / LOW recommendation for the next `/mm-*` command (see Command Recommendation Protocol above) |

Each hook has a kill-switch env var (`MM_HOOK_DOUBT_SURFACER=off`, `MM_HOOK_MEMORY_UPDATER=off`, `MM_HOOK_DOCS_REFRESH=off`, `MM_HOOK_SUGGEST_COMMAND=off`). Full documentation in [`.cursor/hooks/HOOKS.md`](.cursor/hooks/HOOKS.md).

**Git client-side hooks** (`scripts/git-hooks/`, installable): shell scripts installed into `.git/hooks/` via installer.

```powershell
pwsh -File scripts/install-git-hooks.ps1    # install
pwsh -File scripts/install-git-hooks.ps1 -Uninstall
```

```bash
bash scripts/install-git-hooks.sh
bash scripts/install-git-hooks.sh --uninstall
```

| Hook | Event | Behavior |
|---|---|---|
| `pre-commit` | Before each commit | Blocks on skill drift (`sync-skills --check`); scans staged diff for AWS / Stripe / GitHub / Google / Slack / Anthropic / OpenAI key patterns and `.env*` files. |
| `pre-push` | Before each push | Blocks direct push to `main`/`master` (escape `MM_ALLOW_MAIN_PUSH=1`); soft-warns on phase-gate gaps. |

Escape hatches: `git commit --no-verify`, `git push --no-verify`, or env vars `MM_SKIP_PRECOMMIT=1` / `MM_SKIP_PREPUSH=1`. These hooks are a first-line check — **not** a substitute for server-side secret scanning or Gitleaks-in-CI. Full doc in [`scripts/git-hooks/README.md`](scripts/git-hooks/README.md).

---

## System 1 + System 2 — complete map

**Status:** MASTERMIND 2.0 v1.0 — System 1 + System 2 (Sub-phases 2.1–2.4) complete.

| Layer | What it is | Count |
|---|---|---|
| **Kernel** | `CLAUDE.md` + `AGENTS.md` | 2 files |
| **Rules** | `.cursor/rules/00..07.mdc` | 8 rules, always loaded |
| **Skills (System 1)** | Analysis, documentation, quality, design & prototyping | 15 skills |
| **Skills (System 2)** | Execution + orchestration + learning + onboarding | 6 skills |
| **Workflows** | End-to-end recipes | 6 workflows |
| **Slash commands** | `/mm-*` shortcuts | 13 commands |
| **Memory bank** | Per-project intelligence (Git-versioned) | 14 files |
| **Docs folder** | Product, architecture, features, flows, api, testing, security, adr | 8 subfolders |
| **Cross-project memory** | `~/.mastermind/global/` (outside the repo) | 5 files + README |
| **Hooks — agent** | Behavioral instruction files | 4 active + HOOKS.md |
| **Hooks — git** | Client-side shell scripts (installable) | pre-commit + pre-push |
| **Scripts** | Automation helpers | 9 helpers (PowerShell + bash variants) + 2 git hooks (bash) |

**Canonical source vs mirror:**
- Skills: canonical `.cursor/skills/`, mirror `.claude/skills/` (sync via `scripts/sync-skills`).
- Hooks (agent): canonical `.cursor/hooks/`, `.claude/hooks/HOOKS.md` references them.
- Workflows & commands: canonical `.claude/workflows/` and `.claude/commands/` (Cursor reads them by path).

**MCPs:**
- `context7`, `memory-graph`, `github` — active in `.cursor/mcp.json`.
- `task-master-ai` — reserved, installable per-project via `scripts/install-taskmaster.ps1`.
- `playwright` — reserved, activate only for real browser verification of critical flows.

### Skill Interaction Graph updated for System 2

All System 1 skills keep their interactions (see original graph above). System 2 adds:

```
phase-gate-reviewer
   ├── reads   memory/13-phase-history.md + memory/02-current-state.md + docs/
   ├── invokes memory-updater on PROCEED
   └── pairs with approval-gatekeeper (gates are approvals)

approval-gatekeeper
   ├── invoked by implementation-planner, bug-investigator, architecture-mapper,
   │             phase-gate-reviewer
   ├── invokes  memory-updater (log the decision)
   └── pairs with security-review (on high-impact actions)
```

---

## Core principles

1. **Structure over prompts.** A well-organized repo beats the cleverest prompt.
2. **Continuity over cleverness.** Anything important lives in `memory/` and is versioned.
3. **Clarity before code.** Every task starts with doubts and questions.
4. **Surgical over sweeping.** Every changed line traces back to the user request.

---

## Tech stack policy

This template is **stack-agnostic**. The concrete stack is chosen per project based on a "best-for-vibecoding" analysis (see `.cursor/rules/02-tech-stack.mdc`). The author's default palette, when nothing else is specified, is typically drawn from:

- Next.js + TypeScript
- Supabase / Postgres
- Stripe
- Vercel / Railway / Cloudflare

These are defaults, not constraints. Every new project must justify its stack in `memory/03-architecture.md`.

---

## Skill Interaction Graph

The 19 skills in `.cursor/skills/` are designed to compose. Each skill declares `Invoked by` / `Invokes` / `Pairs with` in its own `SKILL.md`. The diagram below is the System-1 spine; the System-2 additions (phase-gate-reviewer, approval-gatekeeper, subagent-dispatcher, parallel-executor, continuous-learner) extend it and are diagrammed in the sections above.

```
                          ┌─────────────────┐
                          │  doubt-surfacer │  (Question Protocol — runs first)
                          └────────┬────────┘
                                   │ runs before every Discovery/Design skill
                                   ▼
               ┌───────────────────────────────────────┐
               │         project-deep-audit            │
               │  (12 angles + Hard Truth, Discovery)  │
               └──────────┬────────────┬───────────────┘
                          │            │
                          ▼            ▼
              ┌────────────────┐  ┌─────────────────────┐
              │ research-first │  │ product-requirements│
              │  (Context7 +   │  │   (PRD + RICE,      │
              │   web, dated)  │  │   Definition)       │
              └───────┬────────┘  └──────┬──────────────┘
                      │                   │
                      │                   ▼
                      │       ┌──────────────────────┐
                      │       │    flow-analyzer     │
                      │       │  (flows, errors,     │
                      │       │   edge cases)        │
                      │       └──────────┬───────────┘
                      │                  │
                      ▼                  ▼
              ┌────────────────────────────────────┐
              │       architecture-mapper          │
              │  (system map, ADRs, NFRs, Design)  │
              └──────────┬─────────────────────────┘
                         │
                         ▼
                ┌──────────────────┐
                │ feature-breakdown│
                │ (slices, deps)   │
                └────────┬─────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │ implementation-planner│
              │ (TDD plan, Execution) │
              └────────┬──────────────┘
                       │
                       ▼
            ┌─────────────────────────┐
            │      test-strategist    │
            │  (pyramid + gaps)       │
            └──────────┬──────────────┘
                       │
                       ▼
           ┌─────────────────────────────┐
           │ bug-investigator            │
           │ (4-phase: reproduce→isolate │
           │  →diagnose→surgical fix)    │
           └──────────┬──────────────────┘
                      │
                      ▼
        ┌──────────────────────────────────┐
        │     code-reviewer   +   security-review           │
        │    (quality / scope)   (threat model / OWASP)     │
        └──────────────────┬───────────────────────────────┘
                           │ Both run on sensitive changes
                           ▼
                  ┌────────────────────┐
                  │   memory-updater   │◄── Finishing step of ALL skills
                  │  (append-mode SS,  │      (flags lesson candidates;
                  │  decisions, risks) │       never writes to global)
                  └─────────┬──────────┘
                            │
                            │ flagged candidates picked up by
                            ▼
                ┌────────────────────────────┐
                │   continuous-learner       │
                │ (3-part test + per-entry   │
                │  user approval, then       │
                │  writes to global memory)  │
                └──────────────┬─────────────┘
                               │ promotes to
                               ▼
                ┌────────────────────────────┐
                │ ~/.mastermind/global/      │
                │ lessons · patterns         │
                │ pitfalls · stacks · vendors│
                └────────────────────────────┘
                           ▲
                           │ Consumed at start by
            project-deep-audit · research-first · architecture-mapper · skill-creator

  skill-creator (meta) ◄─── invoked when adding / refactoring / auditing any skill
```

**Reading the graph:**
- **Vertical** = typical project lifecycle (Foundation → Discovery → Design → Execution → Quality).
- **`memory-updater`** closes every skill. It is the sink that keeps `memory/` alive.
- **`research-first`** is invoked on demand from multiple skills whenever an external dependency surfaces.
- **Cross-project memory** (`~/.mastermind/global/`) is populated by `memory-updater` (promotions) and consumed by the Discovery/Design skills.
- **Hooks** (`.cursor/hooks/`) are an extension point: they can automate invocation of the skills above when triggers repeat.

See each skill's own `SKILL.md` §Interactions for exact caller/callee relationships.

---

## How to use this template

### 1. Clone for a new project

```powershell
# Clone the template
git clone https://github.com/tottimilan/MASTERMIND-2.0 my-new-project
cd my-new-project

# Disconnect from the template remote and start fresh
Remove-Item -Recurse -Force .git
git init
git add .
git commit -m "chore: bootstrap from MASTERMIND 2.0"
```

### 2. Fill the minimum required context

Edit the following files before asking any agent to do anything:

1. `memory/00-project-brief.md` — product, business logic, tech stack, non-negotiables.
2. `.cursor/rules/02-tech-stack.mdc` — concrete stack for this project.
3. `README.md` — project name and short description.

### 3. Start the AI workflow

Open the project in **Cursor** or **Claude Desktop** and trigger the entry skill:

```
Use skill /project-deep-audit
```

The agent will read the memory, run a multi-angle analysis, and — crucially — come back with a list of doubts and 8–20 questions for you **before** producing any final document. Answer, iterate, then let it document.

---

## The Question & Doubt Protocol (non-negotiable)

Before any meaningful output, the AI must:

1. List all its current doubts (technical, product, UX, risks, assumptions).
2. Ask 8–20 high-quality questions grouped by category.
3. Wait for your answers (or mark them Open in `memory/12-open-doubts-and-questions.md`).
4. Only then produce documents or code.
5. Close every session asking: *"Do you have any doubts, observations, or additional notes before we continue?"*

This is the single rule that most differentiates MASTERMIND 2.0 from a chat-style workflow.

---

## Model routing

| Task | Preferred model |
|---|---|
| Deep analysis, strategy, long-form docs | Claude Opus (Claude Desktop or MCP) |
| Daily coding and refactoring | Cursor (GPT-5.5 Max or Claude Sonnet/Opus) |
| Library/API usage | Any model + Context7 MCP |
| UI flow verification | Any model + Playwright MCP |

---

## Credits and references

- [Karpathy Principles — forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)
- Nainsi Dwivedi — kernel + memory + skills-as-stdlib + agents + hooks architecture.
- Anthropic Claude Projects and MCP documentation.
- Cursor documentation on Rules, Skills, Plan Mode, and Cloud Agents.

---

## Status

This repository is the template. Per-project clones diverge from here.
Canonical files (`CLAUDE.md`, `.cursor/rules/00-*`, `.cursor/rules/01-*`, `memory/12-*`, `AGENTS.md`, this `README.md`) should only be edited here and back-ported — not modified on forks.
