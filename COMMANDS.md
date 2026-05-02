# COMMANDS.md — Quick reference for `/mm-*`

> **What this is.** A fast, operational reference for the **11 slash commands** in this project. Designed to stay open and answer the question *"which command do I run now?"* in 5 seconds.
>
> **What this is NOT.** This is not the deep system documentation — for that, open [`OPERATING-GUIDE.md`](OPERATING-GUIDE.md). This is not the skill catalog — those live in `.cursor/skills/` and `.claude/skills/`.

---

## How to invoke the commands

### In Claude Code (native)

```text
/mm-bootstrap                    (no arguments)
/mm-ship auth-mvp                (with argument)
/mm-gate Discovery               (with argument)
```

### In Cursor (by reference)

Cursor does not yet execute `/mm-*` natively the same way Claude Code does. Invoke them by reference instead:

> *"Run the command `.claude/commands/mm-ship.md` with argument `auth-mvp`."*

The agent reads the file and follows the script. Same end result.

---

## Summary table (all 11 at a glance)

| Command                                            | What it does                                               | When to use                                                      | Typical argument                |
| -------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------- |
| [`/mm-bootstrap`](.claude/commands/mm-bootstrap.md) | Empty clone → Discovery phase complete                     | First day of a brand-new project                                 | One-sentence idea               |
| [`/mm-doubt`](.claude/commands/mm-doubt.md)         | Force the Question & Doubt Protocol                        | Agent moving too fast; heavy decision imminent; you feel unsure  | Specific topic (optional)       |
| [`/mm-audit`](.claude/commands/mm-audit.md)         | 12-angle deep audit                                        | Onboarding, resuming after a pause, before a big phase change    | Angle to emphasize (optional)   |
| [`/mm-plan`](.claude/commands/mm-plan.md)           | Bite-sized TDD plan for one slice                          | Any feature/change touching > 1 file                             | Slice slug or description       |
| [`/mm-ship`](.claude/commands/mm-ship.md)           | Full epic: breakdown → review → merge                       | An approved epic is ready to build                               | Epic slug                       |
| [`/mm-bug`](.claude/commands/mm-bug.md)             | Bug → reproduce → surgical fix → regression test            | Any bug, failing test, incident                                  | Description / ID / link         |
| [`/mm-next`](.claude/commands/mm-next.md)           | Tells you the next task to work on                         | Start of a session, to re-enter context fast                     | "details" or empty              |
| [`/mm-review`](.claude/commands/mm-review.md)       | Code review (+ security when applicable) of the branch     | Before merging, after any large slice                            | Branch / PR (optional)          |
| [`/mm-gate`](.claude/commands/mm-gate.md)           | Phase advance with hard verification                       | End of a phase (Idea/Discovery/Definition/MVP/Iteration/Launch)  | Target phase                    |
| [`/mm-retro`](.claude/commands/mm-retro.md)         | 20–40 min weekly retrospective                             | Once a week during MVP/Iteration/Launch                          | Period (optional)               |
| [`/mm-learn`](.claude/commands/mm-learn.md)         | Promote lessons to the cross-project global memory         | End of phase, notable post-mortem, weekly retro                  | Time window (optional)          |

> **Pattern:** all share the `mm-` prefix (MASTERMIND) to group them visually and avoid clashes with Claude's native commands.

---

## Each command explained

### 1. `/mm-bootstrap` — Start a project from scratch

- **Wraps:** workflow [`01-new-project-bootstrap`](.claude/workflows/01-new-project-bootstrap.md).
- **When:** you have just cloned the MASTERMIND template for a new idea and want to go from empty repo to Discovery-phase-complete in a single guided flow.
- **Do NOT use if:** `memory/00-project-brief.md` already has real content; jump directly to `/mm-audit` or `/mm-doubt`.
- **Duration:** 60–120 minutes.
- **Produces:** brief, doubts log, full 12-angle audit, transition to Discovery, first commit.
- **Argument:** one sentence describing the idea (optional; if missing, the agent asks).

### 2. `/mm-doubt` — Force the Question & Doubt Protocol

- **Wraps:** skill [`doubt-surfacer`](.claude/skills/doubt-surfacer/SKILL.md).
- **When:** you sense the agent is about to produce something without thinking it through; a heavy decision is ahead; the last output felt suspiciously fluid; you are entering a new phase.
- **Does:** lists all technical / product / UX / risk doubts and generates 8–20 high-quality questions grouped by category. Blocks any other output until you respond.
- **Project golden rule:** *Doubts and questions first → Clarity → Documents and code after.* Skipping this rule means the agent has failed the protocol.
- **Argument:** a specific topic (optional). Without one, the skill sweeps the whole current context.

### 3. `/mm-audit` — Deep multi-angle audit

- **Wraps:** skill [`project-deep-audit`](.claude/skills/project-deep-audit/SKILL.md).
- **When:** onboarding to an existing repo; returning to the project after a long pause; you want to "tear apart" the project before a big decision; you are about to change phase and need maximum awareness.
- **Does:** examines the project from 12 explicit angles (first-principles, JTBD, Porter, Blue Ocean, risks, scenarios, pivots, metrics, competitors, UX, business model, technical dependencies) and delivers executive summary, top 10 risks, top 10 actions, and a final **Hard Truth** paragraph without softening.
- **Recommended prerequisite:** run `/mm-doubt` first if target user, monetization, non-negotiables, and success metric are not yet clear.
- **Argument:** angle to emphasize (optional, e.g. "risks", "competitive", "pivots").

### 4. `/mm-plan` — Detailed TDD plan for a slice

- **Wraps:** skill [`implementation-planner`](.claude/skills/implementation-planner/SKILL.md).
- **When:** you are about to touch more than one or two files; the work touches sensitive areas (auth, payments, schema); you want a reviewable plan before coding.
- **Do NOT use if:** it is a trivial one-liner with obvious success criteria. Go direct.
- **Does:** scope + success criteria, file map, bite-sized tasks with red-green-commit TDD rhythm, self-review, handoff with 5 execution options (A–E). Saves to `.cursor/plans/YYYY-MM-DD-<slug>.md`.
- **Argument:** slice slug (e.g. `slice-3-auth-mvp`) or a free-form description.
- **Ends by asking:** *"Which option do we execute: A, B, C, D, or E?"*

### 5. `/mm-ship` — Complete pipeline for an epic

- **Wraps:** workflow [`02-feature-lifecycle`](.claude/workflows/02-feature-lifecycle.md).
- **When:** an epic is approved (`docs/features/<epic>.md` exists) and you are in MVP or Iteration phase. You want to go from epic → merged with tests and review.
- **Do NOT use if:** you are still in Definition (no approved PRD) or the epic is not scoped (run `/mm-plan` per epic first).
- **Does:** breakdown → planner per slice → approval-gatekeeper when touching sensitive areas → execution (subagent-dispatcher by default, parallel-executor when slices are independent) → code-reviewer → security-review when applicable → merge → memory-updater.
- **Argument:** epic slug (e.g. `auth-mvp`, `billing-v1`).

### 6. `/mm-bug` — Bug triage with a surgical fix

- **Wraps:** workflow [`03-bug-triage`](.claude/workflows/03-bug-triage.md).
- **When:** a bug report arrives, a test breaks, a production incident happens, you see unexpected behavior.
- **Hard rule:** **no fix is proposed without reproducing the bug** (locally or via a failing automated test). If Phase 2 cannot reproduce, the bug is logged as "Unreproducible" in `memory/08-known-risks.md` with an evidence-gathering plan and stops.
- **Does:** intake + severity classification → reproduce → isolate → root-cause diagnosis → surgical fix with regression test → review → merge → post-mortem at `docs/bugs/YYYY-MM-DD-<slug>.md` → optional `/mm-learn`.
- **Argument:** bug description, ticket ID, failing test name, or link.
- **Escalation:** if investigation exceeds 1 day without a root cause, the "bug" is probably something bigger (architectural audit).

### 7. `/mm-next` — What do I do now?

- **Wraps:** `task-master-ai` when installed, or reading the latest plan in `.cursor/plans/`.
- **When:** you open a new session and need to re-enter context quickly without re-reading all of `memory/`.
- **Does:** shows current phase, how the last session ended, next pending task, files to touch, first step, blockers (open doubts affecting this task), and recommended mode (Coach / Executor / Auditor).
- **It does NOT execute anything.** It only prepares context. To execute, follow up with `/mm-plan` or `/mm-ship` or a direct prompt.
- **Argument:** `details` to show the full task, `context` to show dependencies.

### 8. `/mm-review` — Code and security review

- **Wraps:** skills [`code-reviewer`](.claude/skills/code-reviewer/SKILL.md) + [`security-review`](.claude/skills/security-review/SKILL.md) when touching trust boundaries.
- **When:** before merging to `main`; after a large slice; when someone hands you a PR to review.
- **Does:** walks 11 categories (plan compliance, scope, correctness, tests, architecture fit, quality, performance, readability, simplicity, docs, git hygiene). Categorizes findings as Critical / Important / Suggestion. Acknowledges 2–3 specific strengths. Issues a verdict: **Ready to merge** / **Ready with fixes** / **Not ready**.
- **Triggers security-review in parallel** when the diff touches: `auth/`, `session/`, `token/`, `permissions/`, `rbac/`, `rls/`, payments, webhooks, migrations/backfills/deletes, public APIs, third-party integrations, file uploads, cryptographic code.
- **It does NOT fix anything inline.** It finds; the author (or a subsequent `/mm-plan`) fixes.
- **Argument:** branch, PR number, or file range. Without argument: current branch vs `origin/main`.

### 9. `/mm-gate` — Phase transition

- **Wraps:** workflow [`04-phase-gate-transition`](.claude/workflows/04-phase-gate-transition.md).
- **When:** you believe you have completed the exit criteria of the current phase (Idea / Discovery / Definition / MVP / Iteration) and want to advance to the next.
- **Does:** dry-run with `scripts/phase-gate-check.ps1` → reports PASS/GAPS/BLOCK → remediation if gaps exist → invokes `phase-gate-reviewer` → presents the transition entry to the user → waits for `approve`/`adjust`/`block` → writes to `memory/13-phase-history.md`, `memory/02-current-state.md`, and `memory/07-decisions-log.md` → hands off to the next natural workflow.
- **Hard rule:** **never advance a phase by editing `memory/02-current-state.md` by hand**. The workflow runs end-to-end, always.
- **Argument (required):** one of `Discovery`, `Definition`, `MVP`, `Iteration`, `Launch`.

### 10. `/mm-retro` — Weekly retrospective

- **Wraps:** workflow [`05-weekly-retrospective`](.claude/workflows/05-weekly-retrospective.md).
- **When:** once a week in MVP, Iteration, or Launch phases. Keeps memory alive and catches drift between code and documentation.
- **Does:** week in review (sessions, decisions, commits) → risk posture → drift check (skills sync, phase-gate, feature-map vs PRs, architecture vs code) → flaky tests and stuck PRs → lesson promotion → **Top 3 priorities for next week** (not 5, not 7, **three**).
- **Discipline:** 20–40 minutes. If it runs longer, the project is doing too many things at once.
- **Argument:** `period:<YYYY-MM-DD..YYYY-MM-DD>` (optional; default = last 7 days).

### 11. `/mm-learn` — Promote lessons to global memory

- **Wraps:** skill [`continuous-learner`](.claude/skills/continuous-learner/SKILL.md).
- **When:** end of a phase, weekly retro, after a post-mortem worth generalizing.
- **Does:** scans `memory/11-session-summary.md`, `memory/07-decisions-log.md`, `memory/08-known-risks.md`, and `docs/bugs/` within the requested window → classifies candidates by target file (`lessons.md` / `patterns.md` / `pitfalls.md` / `stacks.md` / `vendors.md`) → applies the **3-part test** (project-agnostic + evidence-backed + actionable) → presents each candidate one by one for `approve`/`edit`/`skip` → writes to `~/.mastermind/global/` with commits of the form `lesson:`, `pattern:`, `pitfall:`, `stack:`, `vendor:`.
- **Privacy:** strips client names, domain specifics, tokens. Nothing sensitive ever reaches global memory.
- **Prerequisite:** `~/.mastermind/global/` must exist (see `.cursor/rules/05-claude-mcp-integration.mdc §Cross-project Memory Protocol`).
- **Argument:** time window (optional, e.g. `last 30 days`, `since 2026-04-01`, `since last gate`).

---

## Decision tree "I don't know which one to use"

```
Are you starting a project from scratch?
└── Yes → /mm-bootstrap

Do you have a bug, failing test, or incident?
└── Yes → /mm-bug

Are you about to produce an important document / decision / piece of code and you're unsure?
└── Yes → /mm-doubt (always first)

Just opened a session and don't remember where you were?
└── Yes → /mm-next

Want to understand a project deeply before touching it?
└── Yes → /mm-audit

Have a concrete slice or task and want a TDD plan?
└── Yes → /mm-plan <slug>

Have an approved epic ready to build?
└── Yes → /mm-ship <epic-slug>

Finished a branch and want a review before merging?
└── Yes → /mm-review

Think you've completed the current phase?
└── Yes → /mm-gate <target-phase>

It's Friday / end of week?
└── Yes → /mm-retro

Just closed a phase or a notable post-mortem?
└── Yes → /mm-learn
```

---

## Natural flow by phase

| Current phase        | Typical commands in order                                                                                              |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Idea**             | `/mm-bootstrap`                                                                                                        |
| **Discovery**        | `/mm-audit` · `/mm-doubt` · `/mm-gate Discovery`                                                                       |
| **Definition**       | `/mm-plan` per epic · `/mm-gate Definition`                                                                            |
| **MVP**              | `/mm-ship` per epic · `/mm-bug` when they appear · `/mm-review` · `/mm-gate MVP`                                       |
| **Iteration**        | `/mm-ship` for new slices · `/mm-retro` weekly · `/mm-learn` occasionally · `/mm-gate Iteration`                        |
| **Launch**           | Same as Iteration + `/mm-review` with a stricter security pass                                                         |

> **Cross-phase shortcuts** (any phase): `/mm-doubt`, `/mm-audit`, `/mm-bug`, `/mm-next`.

---

## Golden rules for the commands

1. **Command ≠ skill ≠ workflow.** A command is a *shortcut* that loads context and fires a skill or a workflow. If you're unsure what it does under the hood, open the matching `.md` — they're intentionally short.
2. **The argument matters.** When a command requires an argument (e.g. `/mm-gate Discovery`), do not invoke it without one: it will ask and you lose a turn.
3. **Never skip `/mm-doubt`** before an important output. It's the project's master rule, at the same level as the Karpathy principles.
4. **Never advance a phase manually.** Only `/mm-gate` modifies `memory/02-current-state.md` and `memory/13-phase-history.md`. Editing by hand leaves the project inconsistent.
5. **`/mm-bug` proposes no fix without reproducing.** If Phase 2 (reproduce) fails, the bug is logged as Unreproducible and stops. No "fixing from the description".
6. **`/mm-review` does not fix.** It finds and decides. The fix is done by the author or a subsequent `/mm-plan`.
7. **`/mm-retro` runs 20–40 minutes.** If it overruns, there are too many open things — that itself is a finding.
8. **`/mm-learn` does not batch-approve.** Each lesson candidate is approved one by one. Even when you say "approve all", the command insists on walking through each.

---

## Anti-patterns (what NOT to do)

- **DO NOT** invoke `/mm-ship` while still in Discovery or Definition. The epic doesn't exist yet. Run `/mm-plan` per epic first.
- **DO NOT** invoke `/mm-plan` for a one-line fix with obvious success criteria. Process over-engineering.
- **DO NOT** invoke `/mm-audit` every time you want to "have a look". It's a 30–60 min operation with persistent artifacts. For quick questions, use normal chat.
- **DO NOT** use `/mm-gate` as a rubber stamp. If the dry-run reports GAPS and you ignore them, the phase stays dirty and `/mm-retro` will catch it next week.
- **DO NOT** fire `/mm-learn` without passing through `/mm-retro` earlier in the same week. You lose the evidence filter.

---

## Maintaining this file

When a new command is added under `.claude/commands/`, this file must be updated in the same commit. The canonical sources are:

- `.claude/commands/<command>.md` — the real command.
- `.claude/commands/README.md` — the master technical index.
- `OPERATING-GUIDE.md` — the full system view.
- **This file** — the fast, user-facing reference.

If a command is removed, drop it here too and log the decision in `memory/07-decisions-log.md`.
