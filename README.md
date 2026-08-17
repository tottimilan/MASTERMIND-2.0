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
│   ├── rules/                         # Always-on instructions for Cursor (9 rules: 00..08)
│   │   ├── 00-project-operating-system.mdc   # CANONICAL
│   │   ├── 01-karpathy-principles.mdc        # CANONICAL (Karpathy, verbatim)
│   │   ├── 02-tech-stack.mdc                 # Filled per project
│   │   ├── …                                 # 03-testing-policy … 07-subagent-orchestration
│   │   └── 08-design-system.mdc              # Platform-aware (web / mobile / cross)
│   ├── skills/                        # 26 reusable playbooks (SKILL.md each) — CANONICAL SOURCE
│   │   └── …                          # full inventory in OPERATING-GUIDE.md §15.1
│   ├── hooks/                         # Agent behavioral hooks (instruction files) + HOOKS.md
│   └── plans/                         # Approved Plan Mode plans
│
├── .claude/                           # Mirror for Claude Code / Claude Desktop
│   ├── CLAUDE.md                      # Reference to root CLAUDE.md (no duplication)
│   ├── skills/                        # GENERATED — mirror of .cursor/skills/ (see scripts/)
│   ├── commands/                      # 17 /mm-* slash commands
│   ├── workflows/                     # 7 end-to-end recipes
│   ├── hooks/                         # Claude-side hooks (extension point)
│   ├── agents/
│   └── memory/
│
├── memory/                            # Long-term project intelligence (Git-versioned, 15 files)
│   ├── 00-project-brief.md
│   ├── 01-product-vision.md
│   ├── …                              # 02-current-state … 11-session-summary
│   ├── 12-open-doubts-and-questions.md   # CANONICAL template
│   ├── 13-phase-history.md
│   └── 14-design-system.md
│
├── phase-criteria.json                # Single source of truth for phase entry/exit criteria
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
- **Phase bootstrap.** You specify the initial phase (Idea / Discovery / Definition / Prototype / MVP / Iteration / Launch); the script writes `memory/02-current-state.md` + a `memory/13-phase-history.md` entry coherently.
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

### Design system + prototyping (platform-aware: web & mobile)

MASTERMIND's design layer is **platform-aware**. `memory/14-design-system.md §Platform` drives the whole stack:

**Web track** (Platform = `web` or `cross` on web files):
- Component library: **shadcn/ui** via [official MCP](https://ui.shadcn.com/docs/mcp) + [official Skill](https://ui.shadcn.com/docs/skills).
- Styling: Tailwind CSS + Radix primitives.
- Prototyping: Claude Design (web mode) → Claude Code handoff.

**Mobile track** (Platform = `mobile` or `cross` on mobile files):
- Component library: **[react-native-reusables](https://reactnativereusables.com)** (RNR) — the mobile sibling of shadcn/ui by the same author behind shadcn's official Expo PR. 8k+ stars, active, universal (works on React Native Web too). Same `npx shadcn init` CLI — the tool detects Expo and uses RNR under the hood.
- Styling: NativeWind v4 (Tailwind for React Native).
- Stack: Expo + Expo Router + Reanimated 3 + Gesture Handler + safe-area-context.
- Prototyping: Claude Design (mobile mode — prompt tuned to "mobile app, iOS + Android") + Expo Go on-device preview + Claude Code handoff with mobile CLAUDE.md conventions.

**Cross-platform** (single repo for both): both tracks live side by side; components share 80%+ API.

**Portable export — `DESIGN.md`:** memory/14 stays canonical inside MASTERMIND. Run `scripts/export-design-md.ps1` (`.sh`) to regenerate a portable `DESIGN.md` at the project root — the 9-section cross-tool format that Claude Design, Google Stitch, Cursor, v0, and Claude Code all read. Edit memory/14, re-export. One source of truth.

Entry points:

- **Rule:** [`.cursor/rules/08-design-system.mdc`](.cursor/rules/08-design-system.mdc) — platform-aware conventions (web track + mobile track + cross).
- **Memory:** [`memory/14-design-system.md`](memory/14-design-system.md) — per-project source of truth with a Platform field, shared identity + tokens, mobile-specific section, patterns, likes, anti-patterns.
- **Context efficiency:** Optional Code Intelligence MCP (tree-sitter/graph) for precise code retrieval (symbols, callers, impact) instead of full files — see CLAUDE.md §Code Context Layer. Reduces tokens in audits/plans/multi-agent work.
- **Skill:** [`.cursor/skills/prototype-designer/SKILL.md`](.cursor/skills/prototype-designer/SKILL.md) — composes Claude Design prompts tuned by Platform.
- **Command:** [`/mm-design`](.claude/commands/mm-design.md).
- **Script (install):** [`scripts/install-shadcn-mcp.ps1`](scripts/install-shadcn-mcp.ps1) (`.sh`) — platform-aware installer, auto-detects Expo vs Next.js.
- **Script (export):** [`scripts/export-design-md.ps1`](scripts/export-design-md.ps1) (`.sh`) — memory/14 → DESIGN.md.
- **Template:** [`.cursor/templates/CLAUDE.md.mobile.md`](.cursor/templates/CLAUDE.md.mobile.md) — mobile CLAUDE.md seed for new Expo projects (Expo Router + NativeWind + SafeAreaView + Reanimated 3 + touch-target/secure-store policies).

**Typical flow:** set `§Platform` in `memory/14` → run `scripts/install-shadcn-mcp.ps1 -Apply` (auto-detects Expo vs Next.js, wires MCP + Skill + the platform stack) → fill the visual identity in `memory/14` → install baseline components via the shadcn MCP → later, `/mm-design <feature>` composes a platform-tuned Claude Design prompt and extracts decisions back into `memory/14`. Step-by-step commands live in rule 08 and the `install-shadcn-mcp` script header.

**Empty `memory/14` produces generic IA-flavored prototypes.** Fill even the minimum (Platform, primary color, 3 personality adjectives, 2 likes, 2 anti-patterns, plus for mobile: safe-area + orientation + tab bar) and every prototype from then on is on-brand AND platform-correct. That's the whole trick.

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

System 1 produces clarity, plans, and quality gates (docs, memory, 17 skills). System 2 is the **execution layer**: how the project is driven from idea to launch, which behavior the agent uses in each moment, and how parallel work is orchestrated.

### Three execution modes (Coach / Executor / Auditor)

The same agent behaves differently depending on the active mode (states, not separate agents; transitions via explicit handoffs): **Coach** (think with you — explore/decide, runs the Question & Doubt Protocol, no code), **Executor** (run an approved plan — surgical TDD, commits at green), **Auditor** (review — findings by severity + verdict). Mode is chosen by: active workflow > your override (`"Coach mode: …"`) > orchestrator deduction. Full definition + the task→sequence matrix in [`.cursor/rules/06-execution-modes.mdc`](.cursor/rules/06-execution-modes.mdc).

### Phase gates (Idea → Launch)

Seven phases — **Idea → Discovery → Definition → Prototype → MVP → Iteration → Launch** (`Prototype` is the only optional one: UI projects mock up a full app via `mockup-factory`; non-UI projects skip `Definition → MVP` with `--skip-reason "no UI"`). Criteria are single-sourced in [`phase-criteria.json`](phase-criteria.json) (rendered into [`memory/13-phase-history.md`](memory/13-phase-history.md)). Each transition runs [`phase-gate-reviewer`](.cursor/skills/phase-gate-reviewer/SKILL.md) (verdict PROCEED / WITH CAVEATS / BLOCK), dry-runnable via `scripts/phase-gate-check.ps1 -NextPhase <phase>`, and is logged to `memory/07` + `memory/13`.

### Human-in-the-Loop (approval-gatekeeper)

Sensitive actions (auth, payments, schema, prod deploys, new deps, destructive commands, tasks > 4h) pass through [`approval-gatekeeper`](.cursor/skills/approval-gatekeeper/SKILL.md), which classifies the action, applies [`.cursor/rules/04-safety-and-git.mdc`](.cursor/rules/04-safety-and-git.mdc), and returns `AUTO_APPROVE` / `REQUIRE_HUMAN_APPROVAL` / `BLOCK`. Every decision is logged.

### Subagents and parallel execution

Policy in [`.cursor/rules/07-subagent-orchestration.mdc`](.cursor/rules/07-subagent-orchestration.mdc) (orchestrator + 2–4 narrow specialists, message-passing not shared state, two-stage review spec-then-quality, model-by-role, status codes). Two skills operationalize it: [`subagent-dispatcher`](.cursor/skills/subagent-dispatcher/SKILL.md) (within one workspace, ≥3 coupled tasks) and [`parallel-executor`](.cursor/skills/parallel-executor/SKILL.md) (across Git worktrees for ≥2 genuinely independent tasks). Worktree helpers: `scripts/worktree-spawn` / `worktree-cleanup` (feature-named branches, ≤3–4 concurrent, deterministic port offset; Docker only on a real runtime conflict).

### Task Master AI — activation-on-demand (per project)

[`task-master-ai`](https://github.com/eyaltoledano/claude-task-master) (PRD → dependency-aware tasks) is **not always on** — activate per project when entering MVP with a ≥10-task plan that `subagent-dispatcher` will drive: `scripts/install-taskmaster.ps1` (`-ClaudeCodeAuth` for no API key). Full contract in [`.cursor/rules/references/task-master.md`](.cursor/rules/references/task-master.md).

### Workflows & slash commands

Workflows are ordered recipes that chain skills into end-to-end operations. Slash commands (`/mm-*`) are one-line shortcuts that wrap a workflow or a skill with curated context loading.

- **7 workflows** — see [`.claude/workflows/README.md`](.claude/workflows/) for the index (bootstrap, feature-lifecycle, bug-triage, phase-gate-transition, weekly-retrospective, onboard-existing-project, full-app-prototyping).
- **17 slash commands** — see [`COMMANDS.md`](COMMANDS.md) for the full reference and the decision tree of which to run when.

> The authoritative, always-current counts and inventory are produced by `/mm-template-audit`; this README intentionally points to the canonical lists instead of duplicating them (so they can't drift).

In Cursor (which does not natively interpret `/`-prefixed commands the same way Claude Code does), invoke them by reference: *"Run `.claude/commands/mm-ship.md` with `auth-mvp`"*.

### Command Recommendation Protocol (active on every turn)

The agent closes every non-trivial turn by recommending the next `/mm-*` command with a confidence level — **HIGH** (one command clearly applies; type `go` to proceed), **MEDIUM** (pick `a`/`b`/`c`), or **LOW** (no recommendation forced). It never auto-executes without your consent, and sensitive actions still route through `approval-gatekeeper`. Full contract in [`CLAUDE.md §5`](CLAUDE.md) and [`.cursor/hooks/post-output.suggest-command.md`](.cursor/hooks/post-output.suggest-command.md) (kill-switch `MM_HOOK_SUGGEST_COMMAND=off`); user-facing reference in [`COMMANDS.md`](COMMANDS.md).

### Hooks

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

## Component map (at a glance)

| Layer | What it is | Count |
|---|---|---|
| **Kernel** | `CLAUDE.md` + `AGENTS.md` | 2 files |
| **Rules** | `.cursor/rules/00..08.mdc` | 9 rules (4 always-on, 5 on-demand) |
| **Skills (System 1)** | Analysis, documentation, quality, design & prototyping | 17 skills |
| **Skills (System 2)** | Execution + orchestration + learning + onboarding + skill QA + evals + context discipline | 9 skills |
| **Workflows** | End-to-end recipes | 7 workflows |
| **Slash commands** | `/mm-*` shortcuts | 17 commands |
| **Memory bank** | Per-project intelligence (Git-versioned) | 15 files |
| **Docs folder** | Product, architecture, features, flows, api, testing, security, adr | 8 subfolders |
| **Cross-project memory** | `~/.mastermind/global/` (outside the repo) | 5 files + README |
| **Hooks** | Agent behavioral (`.cursor/hooks/`) + git client-side (`scripts/git-hooks/`) | 4 + 2 |
| **Scripts** | Automation helpers (PowerShell + bash parity) | see `scripts/` |

Skills are canonical in `.cursor/skills/` and mirrored to `.claude/skills/` via `scripts/sync-skills`. The full **skill interaction graph (System 1 + System 2)** lives in [`OPERATING-GUIDE.md §7`](OPERATING-GUIDE.md). MCPs (`context7`, `memory-graph`, `github`; `task-master-ai`/`playwright` on-demand) are configured in `.cursor/mcp.json`.

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

The 26 skills compose along the project lifecycle (Foundation → Discovery → Design → Execution → Quality → System 2), with `doubt-surfacer` running first, `memory-updater` closing every skill, and `continuous-learner` promoting lessons to `~/.mastermind/global/`. Each `SKILL.md` declares its own `Invoked by` / `Invokes` / `Pairs with`.

The full **coordination graph** (all four layers, System 1 + System 2, plus the memory/global writes) lives in [`OPERATING-GUIDE.md §7.2`](OPERATING-GUIDE.md) — kept in one place to avoid drift.

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

Use the cheapest model that fits the task: Opus-class for deep analysis/strategy/long-form, a fast capable model for daily coding, Context7 MCP for library/API verification, Playwright MCP for UI flows. Full table in [`CLAUDE.md §Model Routing`](CLAUDE.md); per-role subagent routing in [`.cursor/rules/07-subagent-orchestration.mdc`](.cursor/rules/07-subagent-orchestration.mdc).

---

## Credits and references

- [Karpathy Principles — forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)
- Nainsi Dwivedi — kernel + memory + skills-as-stdlib + agents + hooks architecture.
- Anthropic Claude Projects and MCP documentation.
- Cursor documentation on Rules, Skills, Plan Mode, and Cloud Agents.

---

## Note for the template author (advanced)

> **If you cloned MASTERMIND to start a project, you can skip this section.** It only applies if you are developing the MASTERMIND template itself.

The repository serves two roles: (a) the template that anyone clones, and (b) the working dir of the template author. To prevent the second from contaminating the first, the author's live meta-work — current state of the template, decisions log entries about MASTERMIND itself, session summaries of template development, and in-progress plans — lives under a local-only folder:

```
.template-meta/
├── README.md                    # explains the convention
├── memory/02|07|11-*.md         # author's live working memory
└── plans/<date>-<slug>.md       # template-development plans
└── plans/baselines/*.txt        # skill-quality-evaluator snapshots
```

`.template-meta/` is `.gitignore`d so that clones get clean placeholders at `memory/02`, `memory/07`, `memory/11`, and an empty `.cursor/plans/`. The folder is **not** versioned in Git; preserve it via cloud backup or a private side-repo if you care about its history (see `.template-meta/README.md`).

When working on the template itself, read from `.template-meta/memory/` to recover state. Structural changes (new skills, rules, scripts, docs) are committed normally — only the live meta-work stays out of Git.

---

## Status

This repository is the template. Per-project clones diverge from here.
Canonical files (`CLAUDE.md`, `.cursor/rules/00-*`, `.cursor/rules/01-*`, `memory/12-*`, `AGENTS.md`, this `README.md`) should only be edited here and back-ported — not modified on forks.
