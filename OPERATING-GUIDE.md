# MASTERMIND 2.0 — Operating Guide

> **Who this is for.** Anyone cloning the template to drive a SaaS or app project end-to-end: the author, collaborators, future-you, and AI agents (Cursor, Claude Code, Claude Desktop) reading this repo.
>
> **What this is.** The operational manual for the template. It explains how the 19 skills, 5 workflows, 11 slash commands, 8 rules, 13 memory files, hooks, scripts, and MCPs coordinate across the five project phases (Idea → Discovery → Definition → MVP → Iteration → Launch). It shows which component runs when, why, and what to do when the plan no longer fits reality.
>
> **How to read this.** Linearly for the first read. By section afterwards (the TOC is organized by operational need, not by layer).

**Version.** v1.0 — System 1 + System 2 feature-complete.

---

## Table of contents

1. [The 30-second map](#1-the-30-second-map)
2. [Architecture in four layers](#2-architecture-in-four-layers)
3. [Skill inventory map](#3-skill-inventory-map)
4. [Project lifecycle — the full arc](#4-project-lifecycle--the-full-arc)
5. [Phase by phase (operational playbook)](#5-phase-by-phase-operational-playbook)
6. [Execution modes — Coach, Executor, Auditor](#6-execution-modes--coach-executor-auditor)
7. [How components coordinate](#7-how-components-coordinate)
8. [Going back — when System 2 bounces you to System 1](#8-going-back--when-system-2-bounces-you-to-system-1)
9. [End-to-end worked example: "Notas-AI"](#9-end-to-end-worked-example-notas-ai)
10. [Parallel execution patterns](#10-parallel-execution-patterns)
11. [Cross-project memory in practice](#11-cross-project-memory-in-practice)
12. [Hooks in action](#12-hooks-in-action)
13. [FAQ — common situations](#13-faq--common-situations)
14. [Operator cheatsheet](#14-operator-cheatsheet)
15. [Appendix — full component index](#15-appendix--full-component-index)

---

## 1. The 30-second map

MASTERMIND 2.0 is **a Project Operating System** that makes AI-assisted development predictable, reviewable, and persistent. It is not a framework; it is a **repository layout + a discipline**.

```
                   ┌──────────────────────────────────────────┐
                   │          YOU (the operator)              │
                   │       + AI agents (Cursor / Claude)      │
                   └───────────────────┬──────────────────────┘
                                       │  invokes
                                       ▼
          ┌───────────────────────────────────────────────────────┐
          │  SLASH COMMANDS  (.claude/commands/mm-*)              │
          │  /mm-bootstrap /mm-ship /mm-bug /mm-gate /mm-retro    │
          │  /mm-audit /mm-plan /mm-doubt /mm-next /mm-review     │
          │  /mm-learn                                            │
          └───────────────────────────────────────────────────────┘
                                       │  wraps
                                       ▼
          ┌───────────────────────────────────────────────────────┐
          │  WORKFLOWS  (.claude/workflows/)                      │
          │  01 bootstrap · 02 feature-lifecycle · 03 bug-triage  │
          │  04 phase-gate · 05 weekly-retro                      │
          └───────────────────────────────────────────────────────┘
                                       │  composes
                                       ▼
          ┌───────────────────────────────────────────────────────┐
          │  SKILLS  (.cursor/skills/, 19 total)                  │
          │  System 1 — doubt-surfacer · project-deep-audit ·     │
          │  product-requirements · architecture-mapper ·         │
          │  feature-breakdown · flow-analyzer · research-first · │
          │  implementation-planner · test-strategist ·           │
          │  bug-investigator · code-reviewer · security-review · │
          │  memory-updater · skill-creator                       │
          │  System 2 — phase-gate-reviewer · approval-gatekeeper │
          │  · subagent-dispatcher · parallel-executor ·          │
          │  continuous-learner                                   │
          └───────────────────────────────────────────────────────┘
                                       │  governed by
                                       ▼
          ┌───────────────────────────────────────────────────────┐
          │  RULES  (.cursor/rules/00..07.mdc, always loaded)     │
          │  00 OS · 01 Karpathy · 02 stack · 03 testing ·        │
          │  04 safety+git · 05 MCP · 06 modes · 07 subagents     │
          └───────────────────────────────────────────────────────┘
                                       │  persists to
                                       ▼
          ┌───────────────────────────────────────────────────────┐
          │  MEMORY  (memory/, 14 Git-versioned files)            │
          │  brief · vision · state · architecture · data model · │
          │  flows · features · decisions log · risks · testing · │
          │  open Qs · session summary · open doubts · phase log  │
          └───────────────────────────────────────────────────────┘
                                       │  feeds & is fed by
                                       ▼
          ┌───────────────────────────────────────────────────────┐
          │  CROSS-PROJECT MEMORY  (~/.mastermind/global/)        │
          │  lessons · patterns · pitfalls · stacks · vendors     │
          └───────────────────────────────────────────────────────┘
```

Five ideas hold everything together:

1. **Structure is intelligence.** A well-organized repo beats the smartest prompt. The repo is the brain.
2. **Clarity before code.** Every non-trivial action runs the Question & Doubt Protocol first. Assumptions become explicit; questions get asked before deliverables are produced.
3. **Surgical over sweeping.** Karpathy principles are always active. Every changed line traces back to a named request.
4. **Gates, not drift.** Phase transitions are ceremonies with exit criteria, not gradual slides.
5. **Memory that survives.** Sessions end, models change; the repo's `memory/` and `~/.mastermind/global/` remain.

The rest of this guide is how those five ideas become a day-to-day workflow.

---

## 2. Architecture in four layers

The template has four layers, in increasing order of abstraction. Every artifact belongs to exactly one layer, and the dependencies flow one way: upper layers reference lower ones, not the reverse.

```
┌────────────────────────────────────────────────────────────┐
│  L4  COMMANDS + WORKFLOWS     (the "what do I invoke?")    │
│       /mm-* · .claude/workflows/                           │
└────────────────────────────────────────────────────────────┘
                   │ composes
                   ▼
┌────────────────────────────────────────────────────────────┐
│  L3  SKILLS                   (the "how do I do X well?")  │
│       .cursor/skills/<name>/SKILL.md                       │
└────────────────────────────────────────────────────────────┘
                   │ constrained by
                   ▼
┌────────────────────────────────────────────────────────────┐
│  L2  RULES                    (the "what is always true?") │
│       .cursor/rules/00..07.mdc + CLAUDE.md kernel          │
└────────────────────────────────────────────────────────────┘
                   │ produces & consumes
                   ▼
┌────────────────────────────────────────────────────────────┐
│  L1  MEMORY                   (the "what do I remember?")  │
│       memory/ (14 files) + docs/ + ~/.mastermind/global/   │
└────────────────────────────────────────────────────────────┘
```

### L1 — Memory (the substrate)

**Purpose.** State that must survive a session, a model switch, or a restart. If it matters, it lives here or in `docs/`.

| File | Holds |
|---|---|
| `memory/00-project-brief.md` | Product, users, value prop, tech stack, non-negotiables |
| `memory/01-product-vision.md` | North Star, 12-month + 3-year vision, what we are NOT |
| `memory/02-current-state.md` | One-page snapshot: what exists, what is in progress, what is blocked |
| `memory/03-architecture.md` | One-page architecture view + ADR index |
| `memory/04-data-model.md` | Entities, relationships, migrations policy |
| `memory/05-user-flows.md` | Index of critical flows (details in `docs/flows/`) |
| `memory/06-feature-map.md` | MVP + backlog + killed, with statuses |
| `memory/07-decisions-log.md` | Append-only decision log (canonical format) |
| `memory/08-known-risks.md` | Risk table (Impact × Likelihood × Mitigation × Status) |
| `memory/09-testing-status.md` | Coverage snapshot, gaps, flaky tests |
| `memory/10-open-questions.md` | Long-lived strategic questions |
| `memory/11-session-summary.md` | Append-mode log of every meaningful session |
| `memory/12-open-doubts-and-questions.md` | AI ↔ user Q&A register |
| `memory/13-phase-history.md` | Append-only log of phase transitions |

Plus the `docs/` folder (8 subfolders: product, architecture, features, flows, api, testing, security, adr) for human-readable artifacts, and `~/.mastermind/global/` for cross-project memory.

### L2 — Rules (the contract)

**Purpose.** Invariants loaded on every turn. They define what *always* happens.

| Rule | Responsibility |
|---|---|
| `00-project-operating-system.mdc` | Read order, Question Protocol, execution discipline, model routing |
| `01-karpathy-principles.mdc` | Think / Simplicity / Surgical / Goal-Driven — verbatim canon |
| `02-tech-stack.mdc` | Stack chosen per project; universal JS/TS conventions when applicable |
| `03-testing-policy.mdc` | Adaptive pyramid (70/20/10 / 30/20/50 / 100% smoke per phase); mandatory areas |
| `04-safety-and-git.mdc` | Safety guardrails; branching; Conventional Commits; git hooks |
| `05-claude-mcp-integration.mdc` | MCP policy (Context7 always, Playwright on demand); cross-project memory; task-master activation |
| `06-execution-modes.mdc` | Coach / Executor / Auditor modes, selection priority, transitions |
| `07-subagent-orchestration.mdc` | Subagent dispatch; worktrees; two-stage review; continuous learning loop |

Plus the kernel `CLAUDE.md` at the root and `AGENTS.md` for non-Cursor agents.

### L3 — Skills (the playbooks)

**Purpose.** Reusable, composable procedures for specific tasks. Each skill has a single responsibility.

19 skills, organized in the next section.

### L4 — Commands + Workflows (the ergonomics)

**Purpose.** Turn "remember to run skill X, then Y, then Z, then log to `memory/07`" into a single invocation.

5 workflows + 11 slash commands. Workflows are the sequences; commands are shortcuts to workflows or skills with curated context loading.

---

## 3. Skill inventory map

The 19 skills, grouped by role along the project lifecycle.

### System 1 — Analysis & Documentation (14 skills)

**Foundation (3).** The cross-cutting skills every other one depends on.

| Skill | Role |
|---|---|
| `doubt-surfacer` | Force the Question & Doubt Protocol. Surface assumptions, ask 8–20 questions, wait for answers. |
| `memory-updater` | Persist session output to the right `memory/` files. Append-mode for session summary. Flag lesson candidates. |
| `skill-creator` | Author and audit skills per the Agent Skills spec and MASTERMIND conventions. |

**Discovery (4).** Understand the space before shaping the product.

| Skill | Role |
|---|---|
| `project-deep-audit` | Multi-angle audit (12 angles) of a new project or existing codebase. Always ends with a Hard Truth. |
| `product-requirements` | Turn a validated problem into a PRD: personas, MVP boundary, epics, user stories with RICE. |
| `flow-analyzer` | Document user flows with happy path + 7 categories of error paths + ≥5 edge cases + test matrix. |
| `research-first` | Force Context7 / web research before any code that uses an external library or service. |

**Design (2).** Translate the PRD into a buildable plan.

| Skill | Role |
|---|---|
| `architecture-mapper` | Map services, data flow, NFRs (numbers only), dependencies (each backed by a research note), ADRs. |
| `feature-breakdown` | Decompose an epic into independent shippable slices (≤5 days each), with dependency graph. |

**Execution (2).** Produce code.

| Skill | Role |
|---|---|
| `implementation-planner` | Turn a slice into a bite-sized TDD plan under `.cursor/plans/` with complete code + verification per step. |
| `test-strategist` | Decide pyramid ratio per phase, mock strategy, coverage gap analysis. Feeds CI. |

**Quality (3).** Prevent and fix defects.

| Skill | Role |
|---|---|
| `bug-investigator` | 4-phase debugging: reproduce → isolate → diagnose root cause → surgical fix with regression test. |
| `code-reviewer` | 11-category review (plan compliance, scope, correctness, tests, architecture, quality, performance, readability, simplicity, docs, git hygiene). Verdict by severity. |
| `security-review` | Threat model + OWASP-contextual review for auth, payments, schema, public API, etc. |

### System 2 — Execution & Orchestration (5 skills)

**Execution foundation (2).** When and who intervenes.

| Skill | Role |
|---|---|
| `phase-gate-reviewer` | Validate phase transitions (Idea → Discovery → Definition → MVP → Iteration → Launch). Verdict: PROCEED / PROCEED WITH CAVEATS / BLOCK. |
| `approval-gatekeeper` | Human-in-the-Loop enforcer: classify action (Trivial / Routine / Moderate / Sensitive / High-impact / Forbidden) and return AUTO_APPROVE / REQUIRE_HUMAN_APPROVAL / BLOCK. |

**Orchestration (2).** Multi-agent execution.

| Skill | Role |
|---|---|
| `subagent-dispatcher` | Within one workspace. Fresh subagent per task + two-stage review (spec then quality). |
| `parallel-executor` | Across workspaces (Git worktrees). Independence analysis, merge order, runtime isolation decisions. |

**Learning (1).** Close the loop between projects.

| Skill | Role |
|---|---|
| `continuous-learner` | Promote qualifying lessons from the project to `~/.mastermind/global/`. Applies the 3-part test (project-agnostic, evidence-backed, actionable). Requires per-entry user approval. |

### Shape of a skill

Every `SKILL.md` follows the MASTERMIND 9-section template:

1. Title
2. Goal
3. When to use (Always / Do NOT / Trigger keywords)
4. Prerequisites (files to read, skills to run first)
5. Process (numbered steps with checkpoints)
6. Outputs (exact paths)
7. Interactions (Invoked by / Invokes / Pairs with)
8. Completion checklist
9. Anti-patterns

This shape is enforced by `skill-creator`. New skills live at `.cursor/skills/<name>/SKILL.md` and are auto-mirrored to `.claude/skills/<name>/SKILL.md` via `scripts/sync-skills`.

---

## 4. Project lifecycle — the full arc

A MASTERMIND project moves through six phases. Each phase has a purpose, entry criteria, expected artifacts, exit criteria, and a canonical workflow. Transitions are gated — you do not slide between phases, you cross them with explicit approval.

### 4.1 Lifecycle diagram (Mermaid)

```mermaid
flowchart TD
    A([Idea]) -->|/mm-bootstrap| B([Discovery])
    B -->|/mm-audit + /mm-doubt| B
    B -->|/mm-gate Discovery→Definition| C([Definition])
    C -->|/mm-plan per epic| C
    C -->|/mm-gate Definition→MVP| D([MVP])
    D -->|/mm-ship per epic| D
    D -->|/mm-gate MVP→Iteration| E([Iteration])
    E -->|/mm-ship + /mm-retro weekly| E
    E -->|/mm-gate Iteration→Launch| F([Launch])
    F -->|/mm-retro weekly| F
    F -->|next cycle| E

    D -.->|bug report| G[/mm-bug/]
    E -.->|bug report| G
    F -.->|bug report| G
    G -.->|post-mortem + optional /mm-learn| D
    G -.->|post-mortem + optional /mm-learn| E
    G -.->|post-mortem + optional /mm-learn| F

    E -.->|weekly discipline| H[/mm-learn/]
    F -.->|weekly discipline| H
    H -.->|promotes lessons to| I[(~/.mastermind/global/)]

    style A fill:#eee
    style F fill:#dcf
    style I fill:#fdd
```

### 4.2 Phase summary table

| # | Phase | Purpose | Duration (typical) | Canonical workflow |
|---|---|---|---|---|
| 1 | **Idea** | A sentence-to-paragraph description exists | Hours to a day | `/mm-bootstrap` starts the transition |
| 2 | **Discovery** | Validate problem + user + market | 1–3 weeks | `/mm-audit` + `/mm-doubt`; ends with `/mm-gate Discovery→Definition` |
| 3 | **Definition** | Lock MVP scope + architecture + ADRs | 1–2 weeks | `/mm-plan` per epic + `architecture-mapper`; ends with `/mm-gate Definition→MVP` |
| 4 | **MVP** | Build and ship the MVP | 4–12 weeks | `/mm-ship` per epic (workflow 02); `/mm-bug` when issues arise |
| 5 | **Iteration** | Learn from real users, improve | Continuous | `/mm-ship` for new slices; `/mm-retro` weekly |
| 6 | **Launch** | Public release, scale, SLA | Continuous | Same as Iteration + tighter `/mm-review` + security pass |

### 4.3 Non-negotiables at the lifecycle level

- **Phase transitions never happen silently.** Every transition runs `/mm-gate` → `phase-gate-reviewer` → user approval → `memory/13-phase-history.md` entry.
- **Every phase ends with a `memory-updater` pass.** No un-persisted learning between phases.
- **Bugs live in parallel with whatever phase you're in.** `/mm-bug` is a pull-in-from-anywhere workflow; it never interrupts the phase, it runs alongside.
- **Cross-project lessons are promoted at the gate or in the weekly retro, not randomly.** `continuous-learner` reads sessions in a window, applies the 3-part test, writes only on user approval.

---

## 5. Phase by phase (operational playbook)

Each phase section has the same shape: purpose, entry criteria, what happens inside, artifacts produced, exit criteria, and the transition out.

### 5.1 Phase — Idea

**Purpose.** You have a sentence-to-paragraph description of something. Nothing is decided.

**Entry criteria.**
- The template is cloned into a new repo.
- `memory/02-current-state.md` Phase field reads `Idea` (or is the template placeholder).
- No PRD, no architecture, no audit yet.

**What happens.**

Run `/mm-bootstrap <idea>`. This invokes workflow `01-new-project-bootstrap` which is:

```
Phase 1 — Orientation (Coach)
    Read CLAUDE.md + rules 00, 01, 06.
    If ~/.mastermind/global/ exists: read lessons, pitfalls, patterns.

Phase 2 — Rough brief
    Fill memory/00-project-brief.md with real data or explicit _TBD_.
    Commit docs(memory): draft initial project brief.

Phase 3 — doubt-surfacer
    Run the Question Protocol. 8–20 questions. User answers.
    Update memory/12-open-doubts-and-questions.md.

Phase 4 — project-deep-audit
    12 mandatory angles → artifacts in docs/product/ + docs/architecture/.
    Top 10 risks → memory/08-known-risks.md.
    Hard Truth paragraph → docs/product/executive-summary.md.

Phase 5 — phase-gate-reviewer, target Discovery
    Dry-run with scripts/phase-gate-check.ps1 -NextPhase Discovery.
    Formal review. User approves.
    Write transition entry to memory/13-phase-history.md.

Phase 6 — memory-updater
    Append session summary to memory/11-session-summary.md.
    Log bootstrap decision in memory/07-decisions-log.md.
```

**Artifacts produced.**
- Full `memory/00` filled.
- `docs/product/executive-summary.md`, `product-map.md`, `personas.md`, `competitive-analysis.md`, `business-model.md`, `scenarios-and-pivots.md`, `top-10-actions.md`.
- Early `docs/architecture/system-map.md`.
- `docs/features/feature-inventory.md`.
- `docs/security/security-risk-map.md`.
- `memory/08-known-risks.md` with Top 10.
- `memory/12-open-doubts-and-questions.md` populated.
- `memory/13-phase-history.md` with first transition entry.

**Exit criteria.**
- `scripts/phase-gate-check.ps1 -NextPhase Discovery` reports PASS.
- Phase advanced to `Discovery` in `memory/02-current-state.md`.
- Hard Truth present and acknowledged.

**Transition out.**
- Workflow 01 runs `/mm-gate Discovery` internally; at exit the phase is already Discovery.

---

### 5.2 Phase — Discovery

**Purpose.** Validate the problem is real, the users exist, the market matters. Build shared understanding, not a PRD yet.

**Entry criteria.**
- `memory/02-current-state.md` Phase = `Discovery`.
- The Idea bootstrap artifacts from phase 1 exist.
- `memory/08-known-risks.md` has Top 10 risks listed.

**What happens.**

Discovery is the most iterative phase. Typical operations:

- **`/mm-audit`** when you want to re-run or deepen the audit as you learn more.
- **`/mm-doubt`** anytime you feel uncertain about an assumption.
- **Direct conversation** with `doubt-surfacer` about specific risks ("what could kill this pivot?").
- **`research-first`** invoked manually for any claim about a tool, vendor, stack, or competitor.

Discovery is **Coach mode by default**. No code is written; documents in `docs/product/` grow; `memory/08-known-risks.md` evolves.

**Exit criteria to Definition.**
- `docs/product/executive-summary.md` is current and the Hard Truth is accepted or actively being addressed.
- At least one validated persona in `docs/product/personas.md` (validated = you interviewed real users, or you have clear data, not "I think solo freelancers care about X").
- `memory/08-known-risks.md` has mitigations for every Critical risk, or those risks are explicitly accepted.
- No unresolved P0 question in `memory/12-open-doubts-and-questions.md`.

**Transition out.**
- Run `/mm-gate Definition`. This invokes workflow 04 which calls `phase-gate-reviewer`.
- User explicitly confirms the draft transition entry.
- `memory/13-phase-history.md` gains the `Discovery → Definition` row.

**Typical duration.** 1–3 weeks. If it takes > 6 weeks, something is off — either the idea has a fatal flaw that phase gate keeps catching, or the user is avoiding a decision.

**Common anti-patterns in Discovery.**
- Skipping real user validation and calling the personas "done".
- Treating the Hard Truth as a suggestion instead of a hard input to the next phase.
- Running audit after audit without ever committing to a single persona.

---

### 5.3 Phase — Definition

**Purpose.** Decide exactly what ships for the MVP. Lock personas, scope, architecture, and the rough plan.

**Entry criteria.**
- `memory/02-current-state.md` Phase = `Definition`.
- Discovery artifacts are current.

**What happens.**

```
Step 1 — product-requirements (per primary persona)
    Invoke via /mm-plan <epic-slug> or directly.
    Produces docs/product/prd.md with:
      - MVP Boundary (one persona, one JTBD, one metric, three non-goals)
      - 3–7 epics (no more)
      - User stories with Given/When/Then acceptance criteria
      - RICE table, MVP cut-line

Step 2 — architecture-mapper
    System map, container diagram, data flow, dependencies (each with research-first note),
    NFRs in numbers only, ADRs numbered sequentially.
    Output: docs/architecture/system-map.md + docs/architecture/data-flow.md + docs/architecture/dependencies.md + docs/adr/NNNN-*.md.

Step 3 — flow-analyzer (per critical flow)
    For each user story marked critical (auth, payments, data mutations, core monetization flow):
    - Happy path step-by-step (Actor / Action / UI / Data / External)
    - Mermaid diagram
    - State machine if non-linear
    - Error paths across 7 categories
    - ≥ 5 edge cases
    - Test matrix
    Output: docs/flows/<slug>.md (one per critical flow).

Step 4 — test-strategist
    Decide pyramid ratio (in MVP: usually 30/20/50 skewed to E2E smoke).
    Mock strategy per external dependency.
    Gap analysis. Flake policy.
    Output: docs/testing/strategy.md.

Step 5 — feature-breakdown (per epic)
    Decompose approved epics into ≤5-day shippable slices.
    Dependency graph, merge order hints, risk per sensitive slice.
    Output: docs/features/<epic>/breakdown.md.
```

**Artifacts produced.**
- `docs/product/prd.md` with MVP boundary locked.
- `docs/features/<epic-slug>.md` per epic + `docs/features/<epic>/breakdown.md` per slice.
- `docs/architecture/system-map.md`, `data-flow.md`, `dependencies.md`.
- `docs/adr/NNNN-*.md` per major architectural decision.
- `docs/flows/<slug>.md` for every critical flow.
- `docs/testing/strategy.md`.
- `memory/03-architecture.md` (one-page executive view), `memory/04-data-model.md`, `memory/05-user-flows.md` index, `memory/06-feature-map.md` rows.

**Exit criteria to MVP.**
- PRD approved (signed line in `memory/07-decisions-log.md`).
- Every architectural decision has an ADR.
- Every slice of every MVP epic has a breakdown file.
- Testing strategy exists.
- `scripts/phase-gate-check.ps1 -NextPhase MVP` PASS.

**Transition out.**
- `/mm-gate MVP`. `phase-gate-reviewer` verifies all exit criteria.
- Optional: activate `task-master-ai` at this point via `scripts/install-taskmaster.ps1` if the plan has ≥10 tasks.

**Typical duration.** 1–2 weeks. Definition that takes months is a sign Discovery was skipped.

---

### 5.4 Phase — MVP

**Purpose.** Build the shipped product. Sweat, commit, review, merge.

**Entry criteria.**
- PRD approved; epics defined; breakdowns done; flows documented; test strategy chosen.
- Phase gate passed.
- Stack confirmed in `.cursor/rules/02-tech-stack.mdc`.

**What happens.**

Primary loop, per epic (or per slice if large):

```
/mm-ship <epic-slug>
   → Workflow 02-feature-lifecycle:

    Phase 1 — feature-breakdown (confirm or re-do breakdown)
    Phase 2 — implementation-planner per slice (saved under .cursor/plans/)
    Phase 3 — approval-gatekeeper on the plan
    Phase 4a — subagent-dispatcher (single workspace)
        OR
    Phase 4b — parallel-executor (across Git worktrees if slices are independent)
    Phase 5 — cross-track code-reviewer (only if 4b was used)
    Phase 6 — security-review (if feature touches auth / payments / data / public API)
    Phase 7 — merge to main + memory-updater
    Phase 8 — next slice or next epic
```

Parallel to the primary loop:

- **`/mm-bug <description>`** every time a bug arrives (workflow 03).
- **`/mm-review <branch>`** for reviewing PRs created outside the dispatcher path.
- **`/mm-doubt <topic>`** if mid-flight you hit an unclear decision.

**Artifacts produced.**
- Merged PRs per slice.
- Commits following Conventional Commits.
- Tests per slice matching the pyramid ratio.
- Updated `memory/06-feature-map.md` statuses (Planned → In progress → Shipped).
- Updated `memory/09-testing-status.md`.
- `docs/bugs/YYYY-MM-DD-<slug>.md` post-mortems for non-trivial bugs.
- Optional: lesson candidates flagged in `memory/11-session-summary.md`.

**Exit criteria to Iteration.**
- All MVP epics in `memory/06-feature-map.md` have status `Shipped`.
- Primary success metric is instrumented and collecting data.
- Zero open Critical bugs.
- Security review passed for sensitive surfaces.
- At least one end-to-end test covers the critical monetization flow.

**Transition out.**
- `/mm-gate Iteration`. Typically a celebration gate — the MVP is real.

**Typical duration.** 4–12 weeks. Longer than 16 weeks usually means the MVP was not really an MVP (scope creep in Definition).

**MVP-specific discipline.**
- **Approval gatekeeper is strict now.** Every change touching auth, payments, or schema gets an explicit user approval before execution.
- **Testing pyramid is adaptive.** In early MVP, ratio is often 30/20/50 (heavy E2E on critical flows, light unit). As the MVP stabilizes toward Iteration, it shifts toward 70/20/10.
- **Weekly retrospective becomes useful.** Run `/mm-retro` every Friday.

---

### 5.5 Phase — Iteration

**Purpose.** Real users are using the product. Learn from them. Ship improvements. Kill dead weight.

**Entry criteria.**
- MVP phase gate passed.
- Metrics instrumented.
- At least one real user (or dogfood user, or beta cohort).

**What happens.**

Most loops are the same as MVP, but with a different emphasis:

- **`/mm-ship`** for new features (slow cadence, prioritized by observed value, not by speculative PRD).
- **`/mm-bug`** for incoming issues (higher volume than MVP — real users find edges).
- **`/mm-retro`** weekly, **not optional**. This is the phase where lessons compound.
- **`/mm-learn`** at the retro (or ad-hoc after notable post-mortems). Promotes qualifying lessons to `~/.mastermind/global/`.
- **Phase check periodically** with `scripts/phase-gate-check.ps1` to catch drift.

**Artifacts produced.**
- Same as MVP, plus richer `memory/11-session-summary.md` (entries every week).
- Entries in `~/.mastermind/global/lessons.md` / `patterns.md` / `pitfalls.md` as cross-project learning accrues.
- Updated `memory/08-known-risks.md` (real-world risks discovered post-launch).

**Exit criteria to Launch.**
- Product is feature-complete enough to support a public launch.
- Observability in place (logs, metrics, alerts).
- Runbook for at least one common incident class.
- Security review passed for new surfaces.

**Transition out.**
- `/mm-gate Launch`. Usually a tightening gate: SLO/SLA definitions, compliance scope, legal review if needed.

**Typical duration.** Months to indefinite. Some projects live in Iteration forever.

**Iteration-specific discipline.**
- **`continuous-learner` runs regularly.** Every week at the retro.
- **Worktrees become common.** Two or three slices ship in parallel because they are truly independent.
- **Hooks pay for themselves.** The `pre-task.doubt-surfacer` hook catches moments of rushed scoping. The `post-merge.docs-refresh` hook catches drift.

---

### 5.6 Phase — Launch

**Purpose.** Public release. Scale. SLA. Real operational discipline.

**Entry criteria.**
- Iteration phase gate passed.
- Product shippable to the public with defensible quality.

**What happens.**

Same workflows, tighter gates:

- **`approval-gatekeeper` is strictest.** Default for any production-touching action is REQUIRE_HUMAN_APPROVAL.
- **`security-review` is run proactively**, not just when sensitive changes ship.
- **`/mm-retro`** weekly, with extra attention to incident patterns.
- **Phase check weekly** against `Launch` criteria.

**Exit criteria.**
- Launch is a terminal phase. The "exit" is either the product is retired, archived, or pivoted (which brings you back to Discovery for the pivot).

**Launch-specific discipline.**
- **Hooks are required, not optional.** Both agent-level (pre-task, post-task, post-merge) and git-level (pre-commit, pre-push) hooks should be installed.
- **`memory/08-known-risks.md`** is a living doc with real incidents and mitigations.
- **Cross-project memory (`~/.mastermind/global/`) gets fed aggressively.** This is where the compounding advantage lives.

---

## 6. Execution modes — Coach, Executor, Auditor

The same agent behaves in **three different modes** depending on the current goal. Modes are **states**, not separate agents. The agent transitions between them with explicit handoffs.

### 6.1 The three modes

```
┌─────────────────────────┐   ┌─────────────────────────┐   ┌─────────────────────────┐
│        COACH            │   │       EXECUTOR          │   │        AUDITOR          │
│  ─────────────────────  │   │  ─────────────────────  │   │  ─────────────────────  │
│ Think with the user     │   │ Execute an approved     │   │ Review what was done    │
│ Explore options         │   │  plan                   │   │ Findings by severity    │
│ Socratic questions      │   │ Surgical changes, TDD   │   │ Verdict: Ready / fixes  │
│ Runs Question Protocol  │   │ Commit at every green   │   │ Does NOT edit code      │
│ WRITES NO CODE          │   │ Runs memory-updater     │   │ Runs code-reviewer      │
└─────────────────────────┘   └─────────────────────────┘   └─────────────────────────┘
```

### 6.2 Mode selection — three-level priority

When a prompt arrives, the agent decides which mode to enter using this priority order (higher wins):

```
1. ACTIVE WORKFLOW dictates
      ↓ if no workflow active
2. USER OVERRIDE (explicit declaration)
      ↓ if no override
3. ORCHESTRATOR DEDUCES from prompt keywords
```

**Examples:**

| Prompt | Selected mode | Why |
|---|---|---|
| *"Ship the auth epic"* via `/mm-ship auth` | Workflow 02 dictates: Coach → Executor → Auditor | Workflow > user, user's choice is to run the workflow |
| *"Coach mode — help me decide between Supabase and Neon"* | Coach | Explicit user override |
| *"Fix the login bug reported yesterday"* | Executor | No workflow active, keyword *fix* → Executor |
| *"Review the PR that just opened"* | Auditor | No workflow, keyword *review* → Auditor |
| *"What do you think about this idea?"* | Coach (default) | Deduced ambiguously → Coach is the safe default |

### 6.3 Typical mode sequences by task

| Task type | Mode sequence |
|---|---|
| New feature from a raw idea | Coach → Executor → Auditor |
| Bug with clear repro | Executor → Auditor (skip Coach) |
| Code review only | Auditor |
| Strategic brainstorm | Coach |
| Pivot decision | Coach → Coach (two passes) |
| Technical refactor | Executor → Auditor |
| Write a plan, don't implement yet | Coach → Executor (planner only) |
| Audit existing project | Auditor → Coach |
| Phase gate | Auditor → Coach → proceed or block |
| Security incident | Executor (bug-investigator) → Auditor (security-review) |

### 6.4 Transition protocol — how modes hand off

Between modes, the agent always emits a **Handoff block**:

```markdown
## Handoff — <CurrentMode> complete

- **What was produced:** <files, artifacts>
- **Key decisions:** <1–3 bullets>
- **Open items carried forward:** <or "none">
- **Recommended next mode:** Coach | Executor | Auditor
- **Reason:** <1 sentence>
```

The user confirms (or the workflow auto-confirms if the policy allows). The next mode receives a **curated context** — not the full session history, just the artifacts it needs.

### 6.5 What does NOT happen

- **No silent mode switching.** Switches are always explicit.
- **No code written in Coach mode.** If you want code, you hand off to Executor first.
- **No subagents per mode by default.** The modes are states of the same agent. Subagents enter only when `subagent-dispatcher` or `parallel-executor` is invoked (that is a different axis — see section 10).

Full rule at [`.cursor/rules/06-execution-modes.mdc`](.cursor/rules/06-execution-modes.mdc).

### 6.6 Command Recommendation Protocol (closing every turn)

At the **end of any non-trivial turn** — regardless of the active mode — the agent emits a **Command Recommendation block** with one of three confidence levels:

- **HIGH** — one command clearly applies; the agent shows it, explains why, and offers `go` as confirmation.
- **MEDIUM** — two or more commands are plausible; the agent presents options `(a)/(b)/(c)` and asks the user to pick.
- **LOW** — no command fits the situation; the agent says so explicitly instead of forcing one.

The agent **never auto-executes** a recommended command; the user either types `go` (shortcut to proceed as if the command were invoked) or runs the command themselves. This prevents drift ("I forgot the next step") and at the same time keeps the human in charge of every transition.

Full contract: [`CLAUDE.md §5`](CLAUDE.md), [`.cursor/hooks/post-output.suggest-command.md`](.cursor/hooks/post-output.suggest-command.md). Quick reference: [`COMMANDS.md`](COMMANDS.md) §Command Recommendation Protocol.

---

## 7. How components coordinate

This section answers: "who calls whom, and when?". It is the **operational graph** of the system.

### 7.1 Coordination rules

1. **Rules are passive.** They never call skills. They set the behavior frame. They are always loaded.
2. **Skills call other skills.** Documented in each skill's §Interactions block (Invoked by / Invokes / Pairs with).
3. **Workflows call skills in order.** They are the deterministic sequencers.
4. **Commands wrap either a single skill or a single workflow.** They never chain > 1 skill themselves (that would be a workflow in disguise).
5. **Memory is the sink.** Almost every skill invokes `memory-updater` at close. Writing to `memory/` is always the last step, not the first.
6. **`approval-gatekeeper` is an interrupt.** Any sensitive action routes through it before proceeding.
7. **`phase-gate-reviewer` is a ceremony.** It only fires at phase boundaries, never between.
8. **`continuous-learner` is periodic.** Weekly or per-phase-end; never per-task.

### 7.2 The coordination graph

```mermaid
flowchart TD
    subgraph L4["L4 — Commands + Workflows"]
        CMD[slash commands /mm-*]
        WF[workflows 01..05]
    end

    subgraph L3["L3 — Skills"]
        subgraph FND["Foundation"]
            DS[doubt-surfacer]
            MU[memory-updater]
            SC[skill-creator]
        end
        subgraph DSC["Discovery"]
            PDA[project-deep-audit]
            PR[product-requirements]
            FA[flow-analyzer]
            RF[research-first]
        end
        subgraph DSG["Design"]
            AM[architecture-mapper]
            FB[feature-breakdown]
        end
        subgraph EXC["Execution"]
            IP[implementation-planner]
            TS[test-strategist]
        end
        subgraph QLT["Quality"]
            BI[bug-investigator]
            CR[code-reviewer]
            SR[security-review]
        end
        subgraph SYS2["System 2"]
            PGR[phase-gate-reviewer]
            AG[approval-gatekeeper]
            SD[subagent-dispatcher]
            PE[parallel-executor]
            CL[continuous-learner]
        end
    end

    subgraph L1["L1 — Memory + Global"]
        MEM[(memory/ 14 files)]
        DOCS[(docs/ 8 folders)]
        GLOBAL[(~/.mastermind/global/)]
    end

    CMD --> WF
    CMD --> DS
    CMD --> PDA
    CMD --> IP
    CMD --> PGR
    CMD --> CL

    WF --> PDA
    WF --> PR
    WF --> FB
    WF --> IP
    WF --> SD
    WF --> PE
    WF --> CR
    WF --> SR
    WF --> PGR
    WF --> CL

    PDA --> DS
    PDA --> RF
    PDA --> MU
    PR --> DS
    PR --> MU
    IP --> AG
    IP --> RF
    IP --> SD
    IP --> PE
    SD --> CR
    SD --> SR
    SD --> MU
    PE --> SD
    PE --> CR
    PE --> SR
    BI --> RF
    BI --> CR
    BI --> MU
    PGR --> MU
    PGR --> AG
    AG --> MU
    CL --> MU
    CR --> MU
    SR --> MU
    MU --> CL
    MU -->|writes| MEM
    MU -->|writes| DOCS
    CL -->|writes| GLOBAL

    style GLOBAL fill:#fdd
    style MEM fill:#dfd
    style DOCS fill:#dfd
```

### 7.3 Key patterns

**Pattern A — Every skill ends with `memory-updater`.**
This is non-negotiable. The only exception is `memory-updater` itself (it doesn't call itself).

**Pattern B — Before any sensitive action, `approval-gatekeeper` runs.**
`implementation-planner` invokes it before execution, `bug-investigator` before a schema migration, `architecture-mapper` before a new dependency, `phase-gate-reviewer` for the phase transition itself.

**Pattern C — Research is cited, not invented.**
Every mention of a library, service, or external behavior has a `research-first` note at `docs/architecture/research/<topic>.md`.

**Pattern D — Commands do one thing.**
`/mm-ship` calls workflow 02. `/mm-bug` calls workflow 03. `/mm-audit` calls skill `project-deep-audit`. No command chains multiple skills directly — that's a workflow's job.

**Pattern E — Memory is append-mode where history matters.**
- `memory/07-decisions-log.md` — append only.
- `memory/11-session-summary.md` — append mode (newest on top).
- `memory/13-phase-history.md` — append only.
- `memory/08-known-risks.md` — in-place update of statuses, but closed risks move to Archive, never deleted.

**Pattern F — Subagents run with curated context.**
When `subagent-dispatcher` spawns a fresh subagent, it **never** passes the orchestrator's full history. It passes exactly the task spec + project conventions + relevant memory slice.

### 7.4 Non-patterns (things that do NOT happen)

- **Skills don't modify rules.** Rules change only by human edit + a decision entry in `memory/07-decisions-log.md`.
- **Rules don't invoke skills.** They describe behavior; skills run the behavior.
- **Workflows don't edit skills.** They sequence them.
- **`memory-updater` does not write to `~/.mastermind/global/`.** Only `continuous-learner` does, and only with user approval per entry.
- **The template is not a runtime.** It's a repository layout. The agent (Cursor / Claude Code) is the runtime.

---

## 8. Going back — when System 2 bounces you to System 1

The happy path is Idea → Discovery → Definition → MVP → Iteration → Launch. Reality is not always happy. Mid-execution, you sometimes discover that the PRD was wrong, the architecture doesn't support a requirement, or a risk that was flagged "accepted" just materialized.

MASTERMIND is designed to **pull you back** when that happens, not forward through a bad plan.

### 8.1 The four common reverse-flow triggers

**Trigger 1 — Mid-execution discovery that the spec is wrong.**
Example: while `implementation-planner` is breaking down a task, it hits something that contradicts `docs/product/prd.md`. The feature "log in with magic link" is being implemented; halfway through, the user realizes they also need SSO for enterprise. That's not a feature creep; it's a PRD gap.

**Trigger 2 — Architecture reveal.**
A slice of work exposes that the architecture as documented does not support the feature. Example: `docs/architecture/data-flow.md` shows the checkout service writing directly to the ledger; the actual implementation needs an event queue.

**Trigger 3 — Risk materialized.**
A `memory/08-known-risks.md` entry marked "Accepted" just became a production bug. Example: "We accepted the risk that a single-region DB has SLA at 99.5%, good enough for MVP." The DB has been down 2 hours, MVP is in Iteration, paying users exist.

**Trigger 4 — Hard Truth re-surfaces.**
The `docs/product/executive-summary.md` §Hard Truth section had a paragraph like *"The monetization model is not validated with real willingness-to-pay data."* Six weeks into MVP, it's still not validated. The Hard Truth has been dodged too long.

### 8.2 How to go back — the mechanism

For each trigger, the sequence is:

```
Step 1 — STOP current execution.
  Halt the workflow (Ctrl+C equivalent: explicit "pause" message).
  Do NOT continue the current /mm-ship or /mm-bug.

Step 2 — RUN /mm-doubt.
  Force the Question Protocol on the discovery:
    - What assumption was wrong?
    - What part of which document contradicts reality?
    - What are the candidate responses?

Step 3 — DECIDE the level of rollback.
  Options (in order of increasing disruption):
    (a) Update the affected memory file(s), keep the phase.
        Example: add a new row to memory/06-feature-map.md, proceed.
    (b) Re-run the relevant System 1 skill for the affected area.
        Example: flow-analyzer for a flow that was underspecified.
    (c) Re-visit the phase.
        Example: phase-gate-reviewer to revert to Definition from MVP (rare).
    (d) Declare a pivot.
        Example: back to Discovery.

Step 4 — EXECUTE the rollback.
  Update memory/13-phase-history.md if the phase moved.
  Update memory/07-decisions-log.md with the rollback decision (rationale, trigger, scope).
  Update memory/02-current-state.md if the phase changed.

Step 5 — RESUME with the corrected frame.
  Re-plan, re-dispatch, or re-scope as needed.
```

### 8.3 Reverse flows — common concrete cases

**Case A — PRD gap in MVP.**

```
Current state: MVP phase, /mm-ship auth in Phase 4 (subagent-dispatcher running).
Trigger: dispatcher reports DONE_WITH_CONCERNS — implementer found the spec misses SSO.

Response:
  1. Halt dispatcher.
  2. /mm-doubt "auth spec may be incomplete for enterprise users"
  3. Decide level: (b) re-run product-requirements only for the auth epic.
  4. product-requirements adds the SSO user stories + RICE + updates docs/product/prd.md.
  5. feature-breakdown updates the breakdown (new slice: SSO integration).
  6. implementation-planner regenerates the plan for the affected slice.
  7. Resume dispatcher with the updated plan.

Result: stayed in MVP, but the spec is now correct.
Memory trace: memory/07 gains a decision entry; docs/product/prd.md has a change-log row.
```

**Case B — Architecture reveal in MVP.**

```
Current state: MVP, implementing the checkout slice.
Trigger: the slice needs a queue; docs/architecture/system-map.md doesn't include one.

Response:
  1. Halt the executor.
  2. /mm-doubt "checkout implementation implies architectural change"
  3. Decide level: (b) run architecture-mapper focused on the affected path.
  4. architecture-mapper adds a queue container, updates data-flow.md, writes a new ADR.
  5. If the change is material, run approval-gatekeeper on the ADR (classified Moderate→Sensitive).
  6. Re-run implementation-planner for the affected slice.
  7. Resume execution.

Result: MVP continues; architecture caught up with reality.
Memory trace: new docs/adr/NNNN-add-queue.md; memory/03-architecture.md updated; memory/07 logs the decision.
```

**Case C — Accepted risk materializes in Iteration.**

```
Current state: Iteration phase.
Trigger: the "single-region DB" risk becomes a production incident (2h downtime).

Response:
  1. /mm-bug "DB regional failure incident YYYY-MM-DD"
     → workflow 03-bug-triage
     → bug-investigator reproduces, isolates, diagnoses. Tag: Dependency + Config.
  2. Post-mortem at docs/bugs/YYYY-MM-DD-db-failure.md.
  3. The risk was "Accepted" in memory/08-known-risks.md. Status moves to "Open" and a mitigation (multi-region replica) is proposed.
  4. /mm-plan new-mitigation for the multi-region slice.
  5. implementation-planner produces the plan.
  6. /mm-ship the mitigation.
  7. At the next /mm-retro, /mm-learn promotes the lesson "do not accept single-region risk past MVP" to ~/.mastermind/global/pitfalls.md.

Result: stayed in Iteration, but the risk posture is hardened and the lesson propagates to future projects.
```

**Case D — Pivot.**

```
Current state: MVP phase, 6 weeks in, monetization metric flat.
Trigger: the Hard Truth from docs/product/executive-summary.md is reality: nobody is paying.

Response:
  1. Halt all feature-lifecycle workflows.
  2. /mm-doubt "MVP metrics suggest monetization assumption failed"
  3. Decide level: (d) pivot. Back to Discovery.
  4. /mm-gate Discovery (this is unusual — moving BACKWARD through the gate).
     phase-gate-reviewer verdict: PROCEED WITH CAVEATS (the caveat is: we are reverting intentionally).
     Transition entry in memory/13 notes "reverted from MVP to Discovery on YYYY-MM-DD".
  5. Run project-deep-audit fresh, emphasizing the monetization angle.
  6. New Hard Truth, new PRD if needed.
  7. Normal flow resumes from Discovery.

Result: the project pivoted cleanly. No code was thrown away that didn't need to be. Memory contains the full trail.
Memory trace: memory/13 gains a "reverted" entry. memory/07 logs the pivot decision with rationale. The old PRD is marked Superseded in place.
```

### 8.4 Non-negotiable principles when going back

- **Never "just keep going" with a known-bad plan.** That's how projects become zombies.
- **Never delete history.** Move to Archive, mark Superseded, but always preserve.
- **Every reverse step is logged.** `memory/07-decisions-log.md` gets an entry; `memory/13-phase-history.md` gets an entry if phase moved.
- **The user confirms the rollback.** `approval-gatekeeper` treats phase reversions as Sensitive.

### 8.5 Reverse flow diagram

```mermaid
flowchart LR
    MVP([MVP]) -->|discovered spec gap| DEFA[Re-run affected skill]
    MVP -->|architecture reveal| DEFB[architecture-mapper + ADR]
    MVP -->|risk materialized| IT([Iteration])
    MVP -->|Hard Truth dodged too long| PIV[Pivot]
    IT -->|risk materialized| BUG[/mm-bug/]
    BUG -->|notable lesson| CL[/mm-learn/]
    PIV -->|gate reversion| DIS([Discovery])
    DEFA -->|resume| MVP
    DEFB -->|resume| MVP
    BUG -->|resume| IT
    DIS -->|forward path restarts| DEF([Definition])
    DEF --> MVP

    style PIV fill:#fcc
    style DIS fill:#fcc
```

---

## 9. End-to-end worked example: "Notas-AI"

A fictional project used as a hilo conductor. Everything below is realistic but illustrative — do not copy-paste paths and content literally, adapt to your real context.

### 9.1 The idea

**Notas-AI.** A note-taking SaaS for freelancers that auto-categorizes notes using an LLM and surfaces the three notes most relevant to the current calendar block. Monetization: 12 €/month per user, freemium with 100 notes cap.

### 9.2 Day 0 — Clone + bootstrap

Clone the template:

```powershell
git clone https://github.com/<you>/MASTERMIND-2.0 notas-ai
cd notas-ai
Remove-Item -Recurse -Force .git
git init
git add .
git commit -m "chore: bootstrap from MASTERMIND 2.0"
```

Fill basic stack choice later. First, run the bootstrap workflow:

```
You → /mm-bootstrap "A note-taking SaaS for freelancers that auto-categorizes
                     notes with an LLM and surfaces the 3 most relevant notes
                     for the current calendar block. 12 €/month, freemium."
```

Agent enters workflow 01. Coach mode. Reads rules, checks `~/.mastermind/global/` (empty for your first project, skipped silently).

Agent fills `memory/00-project-brief.md` draft. Commits.

Agent runs `doubt-surfacer`. Surfaces, for example:

- *"Is 'freelancer' a primary persona or a secondary? Freelancer-as-designer behaves very differently from freelancer-as-writer."*
- *"Is the calendar integration blocking the MVP or a follow-up? MVP-without-calendar is 3 weeks, MVP-with-calendar is 8 weeks."*
- *"How are LLM costs absorbed at 100 notes free tier? Rough napkin math?"*
- *"What platform first — web, iOS, or both? Splitting effort hurts speed."*
- … (8–20 total)

You answer:
- Primary persona: **solo freelancer writers / consultants**. Not designers.
- Calendar is **MVP-blocking** because "3 relevant notes for this calendar block" is the differentiator.
- LLM costs: budget 2 €/user/month for OpenAI in freemium; cap aggressively.
- Platform: **web first**, no mobile for MVP.
- Name: **Notas-AI** (mixed language is fine for this user).

Agent runs `project-deep-audit`. 12 angles. Generates docs/product/*.md. Top 10 risks identified. Hard Truth:

> *"The value proposition depends on the 'relevant notes for this calendar block' feature being accurate enough to be useful. That accuracy depends on a semantic search + LLM pipeline that has not been prototyped. If the pipeline is <70% user-perceived-useful, the whole differentiator collapses. The first slice to build should be a throwaway prototype of this pipeline, not authentication."*

That Hard Truth changes the MVP shape. Noted.

Agent runs `phase-gate-reviewer Discovery`. You approve. `memory/13-phase-history.md` gains the `Idea → Discovery` entry on today's date.

### 9.3 Day 1–5 — Discovery iteration

You use `/mm-audit risks` and `/mm-doubt` multiple times to sharpen specific angles:

- Deep dive on the calendar integration space (Google Calendar + Apple iCloud via CalDAV + Outlook).
- Validation interviews with 5 freelancer writers (external to the tool; you summarize in `memory/11-session-summary.md`).
- Research note on semantic search approaches (pgvector, Pinecone, Upstash Vector). Written to `docs/architecture/research/vector-search-2026-05.md`.

At end of week 1:

```
You → /mm-gate Definition
```

Agent runs `phase-gate-check`: PASS. Runs `phase-gate-reviewer Definition`. Verdict: PROCEED. You approve. Phase transitions to `Definition`.

### 9.4 Day 6–12 — Definition

```
You → Use product-requirements to turn the Discovery findings into a PRD.
```

Agent produces `docs/product/prd.md`:

- **Primary persona:** solo freelancer writer, 1–10 years experience, uses 2+ tools for notes/calendar today.
- **MVP JTBD:** *"When I sit down for a 45-min focus block to work on Client X, surface my 3 most relevant prior notes so I don't waste 5 min remembering context."*
- **Success metric (North Star input):** % of focus blocks where the user clicked ≥1 of the 3 surfaced notes within 2 min. Target: > 40% after 2 weeks of use.
- **Non-goals:** no mobile, no team collaboration, no export to third parties, no custom LLM fine-tuning.
- **Epics:**
  1. `auth-mvp` — email + password + session + password reset. ~4 days.
  2. `notes-crud` — create / edit / list / delete notes. Markdown. No attachments. ~3 days.
  3. `semantic-search-spike` — **first thing** (Hard Truth dictated this). Build the vector search + LLM pipeline, evaluate accuracy with 50 real notes from the founder. ~5 days.
  4. `calendar-integration` — Google Calendar only for MVP; read-only; 15-min polling. ~4 days.
  5. `relevant-notes-surface` — the differentiator. Combines `semantic-search` output + current calendar block context. ~4 days.
  6. `freemium-billing` — Stripe checkout, 100-note limit, paywall. ~3 days.

You approve. RICE sorts the list the way Hard Truth demanded: `semantic-search-spike` first.

Agent runs `architecture-mapper`:

- Stack picked: **Next.js 15 + TypeScript strict + Supabase (Auth + Postgres with pgvector) + OpenAI API + Stripe + Vercel.** All five dependencies have `research-first` notes.
- System map diagram. Data flow for the critical flow (focus block → surface 3 notes).
- NFRs: p95 < 800ms for note retrieval; < 200ms for calendar block lookup; SLA 99% for MVP.
- ADRs:
  - `docs/adr/0001-use-pgvector-over-pinecone.md` — pgvector chosen because same DB + simpler ops.
  - `docs/adr/0002-openai-embeddings-small-model.md` — text-embedding-3-small for cost.
  - `docs/adr/0003-stripe-over-paddle.md` — Stripe chosen for pricing simplicity in EU.

Agent runs `flow-analyzer` on the two critical flows:

- `docs/flows/signup.md` — magic-link signup, error paths (email bounce, token replay, rate limit).
- `docs/flows/relevant-notes-surface.md` — the differentiator. 7 error categories covered.

Agent runs `test-strategist`:

- Ratio for MVP: **30/20/50** (heavy E2E on the critical flow).
- Mock strategy: Stripe sandbox, OpenAI via MSW fixtures + one live canary weekly, Supabase via local Docker.
- `docs/testing/strategy.md` saved.

Agent runs `feature-breakdown` per epic. Each epic has a `docs/features/<epic-slug>/breakdown.md` with slices.

Sample breakdown for `auth-mvp`:

```
Slice 1 — DB migration: users, sessions, password_reset_tokens.  (S, 1 day)
Slice 2 — Signup endpoint + form.                                (M, 2 days)
Slice 3 — Login endpoint + session cookie.                       (S, 1 day)
Slice 4 — Password reset flow.                                   (M, 1.5 days)
Slice 5 — Auth middleware for protected routes.                  (S, 0.5 day)
```

End of week 2:

```
You → /mm-gate MVP
```

Agent verifies: PRD, breakdowns per epic, test strategy, architecture, ADRs — all in place. PROCEED. Phase → MVP.

### 9.5 Day 13–55 — MVP execution

#### Day 13 — Activate task-master-ai

The MVP plan has 6 epics × ~4 slices × ~5 tasks per slice = ~120 tasks. Threshold reached (≥ 10 tasks).

```
You → pwsh -File scripts/install-taskmaster.ps1 -ClaudeCodeAuth
     → Restart Cursor.
     → "Parse the PRD at .taskmaster/docs/prd.md"
```

Agent runs `parse-prd`. `.taskmaster/tasks.json` gains 120+ tasks with dependencies.

#### Day 13 — First slice: the semantic-search-spike

Hard Truth dictated this order. Do it first, before auth.

```
You → /mm-ship semantic-search-spike
```

Workflow 02 runs. Phase 1 (breakdown already done). Phase 2 (`implementation-planner`):

```
Task 1 — Set up pgvector extension + embeddings table.
Task 2 — Write OpenAI embedding fetcher with retry/backoff.
Task 3 — Ingest 50 seed notes (imported from founder's old Notion).
Task 4 — Write the semantic-search query.
Task 5 — Build a manual eval harness: given 10 "focus blocks", rank 3 notes; founder rates each set 1-5.
Task 6 — Run eval, record results in memory/07-decisions-log.md.
```

Phase 3 (`approval-gatekeeper`): classify as Moderate (data mutations + external API). User confirms.

Phase 4 (`subagent-dispatcher`): the plan has 6 tasks. Dispatcher walks them. For each: implementer subagent (standard model, tasks are multi-file integration) → spec reviewer → code quality reviewer.

Task 5 surfaces an issue: `NEEDS_CONTEXT` — subagent asks what scale the eval should use. Controller provides: 1–5 Likert. Re-dispatched. DONE.

Day 18 — eval result: **average 3.6 / 5**. Bordering on the 70% threshold. You decide (with Claude Opus help via `/mm-doubt`) this is viable, but add a tighter pre-retrieval filter (calendar keyword match). New mini-slice added.

**Reverse flow moment.** Plan updated with new mini-slice `semantic-search-pre-filter`. `memory/07-decisions-log.md` gains an entry. PRD is unchanged (this is architectural; not a scope change).

#### Day 19–22 — auth-mvp slices

```
You → /mm-ship auth-mvp
```

Workflow 02. Dispatcher runs 5 slices. All go smoothly; the two-stage review catches:

- **Spec gap on slice 2:** implementer added a "Remember me" checkbox not in the spec. Scope creep. Spec reviewer says SPEC_GAPS. Fixed: removed.
- **Code quality on slice 5:** magic number `15 * 60 * 1000` for session TTL. Suggestion: extract `SESSION_TTL_MS`. Applied.

All merged by day 22. `memory/06-feature-map.md` shows `auth-mvp` as `Shipped`.

#### Day 23–28 — notes-crud + calendar-integration in parallel

These two epics are genuinely independent (different routes, different data).

```
You → /mm-ship notes-crud
(later in the day)
You → "Can we also run calendar-integration in parallel? The slices don't share files."
Agent → Running parallel-executor.
```

`parallel-executor` sequence:

1. **Independence analysis matrix:** notes-crud vs calendar-integration = files disjoint, no shared runtime state. → PARALLEL.
2. **Spawn two worktrees:**
   ```
   pwsh -File scripts/worktree-spawn.ps1 -Slug notes-crud -Type feat -InstallDeps
   pwsh -File scripts/worktree-spawn.ps1 -Slug calendar-integration -Type feat -InstallDeps
   ```
3. **Per worktree:** its own `subagent-dispatcher`.
4. **Runtime decision:** both spin up Next.js dev servers → port collision risk. Solution: `.worktree-env` per worktree assigns `MM_DEV_PORT` deterministically via hash. First gets 13421, second gets 15692. No Docker needed.
5. **Merge order:** notes-crud first (schema lands first), then calendar-integration rebased on top.
6. **Per PR:** `code-reviewer` + `security-review`. Both approved and merged.
7. **Cleanup:** `scripts/worktree-cleanup.ps1` sweeps both merged worktrees.

Day 28: two epics shipped in 6 wall-clock days instead of ~10.

#### Day 29–35 — relevant-notes-surface

The differentiator. Heavy testing. `test-strategist` invoked for targeted E2E coverage. Playwright MCP activated temporarily (via `claude-side/mcp-config.json` manual edit) for UI verification of the "3 surfaced notes" panel.

#### Day 36–42 — freemium-billing

Stripe integration. `approval-gatekeeper` is strict: every touch of billing requires explicit approval. Sandbox + webhook signing. `security-review` is mandatory (payments). Merged.

#### Day 43 — MVP gate

```
You → /mm-gate Iteration
```

Dry-run: PASS. `phase-gate-reviewer`: PROCEED. `memory/13` row: `MVP → Iteration` on day 43.

### 9.6 Day 44 onward — Iteration

#### First bug (day 48)

User reports: *"My notes aren't showing up in my calendar block."* You run:

```
You → /mm-bug "notes missing from calendar block for user X"
```

Workflow 03. `bug-investigator`:

- **Phase 1 (Reproduce):** can't reproduce locally. The user agrees to share scrubbed logs. Found: timezone handling bug — calendar block starts are interpreted in server TZ, user is in EST.
- **Phase 2 (Isolate):** `src/surface/calendar-block.ts:42`.
- **Phase 3 (Diagnose):** Category = **Assumption** — code assumed UTC.
- **Phase 4 (Surgical fix):** regression test first (asserts 3PM EST block matches notes tagged near that local time). Test red on broken commit, green after fix.

Post-mortem at `docs/bugs/2026-05-18-tz-calendar-block.md`.

Lesson candidate flagged: *"Any feature that anchors to wall-clock time needs explicit TZ handling in the spec and a regression test per timezone."*

#### Weekly retro (every Friday)

```
You → /mm-retro
```

Workflow 05. Week in review. Risk posture check. Drift check (sync-skills + phase-gate + memory/code). Flaky test review. Lesson promotion via `/mm-learn`.

At the retro ending day 52, 3 lesson candidates:

1. *"TZ anchor features need per-TZ regression."* → PROMOTE to `~/.mastermind/global/pitfalls.md`.
2. *"In-house parse-PRD workflow works; task-master autopilot felt too aggressive for this stack."* → PROMOTE to `~/.mastermind/global/lessons.md`.
3. *"The pgvector pre-filter approach worked better than raw embedding search at scale."* → PROMOTE to `~/.mastermind/global/patterns.md`.

Each with user approval per entry. Each is a dedicated commit in the `~/.mastermind/global/` repo.

### 9.7 Day 120 — Launch gate

Two months of iteration. Metrics: **42% focus-block note-click rate** (above the 40% target). Paying users: **18** (above the 10-user MVP exit bar). Observability deployed. Incident runbook for DB failure, OpenAI outage, Stripe webhook loss.

```
You → /mm-gate Launch
```

`phase-gate-reviewer`: **PROCEED WITH CAVEATS**. The caveat: SLA is declared 99% but the DB is single-region. A multi-region plan exists in `docs/adr/0004-multi-region-plan.md`, scheduled for Q3.

Launch approved. `memory/13` gains `Iteration → Launch` entry.

### 9.8 The journey in commits (simplified)

```
f00d...  chore: bootstrap from MASTERMIND 2.0 (day 0)
a1b2...  docs(memory): discovery complete — PRD-ready hard truth (day 5)
c3d4...  docs(product): PRD v1 + architecture + flows (day 12)
e5f6...  feat(semantic-search): spike + eval — 3.6/5 accepted (day 18)
aabb...  feat(auth): MVP auth complete (day 22)
ccdd...  feat(notes-crud)(calendar): parallel shipped via worktrees (day 28)
eeff...  feat(surface): relevant-notes-in-calendar-block (day 35)
0011...  feat(billing): freemium with Stripe (day 42)
2233...  docs(memory): MVP gate passed — phase→Iteration (day 43)
4455...  fix(calendar): TZ handling regression + test (day 48)
...
9988...  docs(memory): launch gate passed — 42% click rate, 18 paying users (day 120)
```

### 9.9 What the memory looks like at Launch

```
memory/
├── 00-project-brief.md                 — full, up to date
├── 01-product-vision.md                — expanded with post-MVP learnings
├── 02-current-state.md                 — Phase: Launch
├── 03-architecture.md                  — v2 (added queue, caching layer)
├── 04-data-model.md                    — 7 entities
├── 05-user-flows.md                    — 8 critical flows indexed
├── 06-feature-map.md                   — 6 MVP epics Shipped + 4 Iteration epics
├── 07-decisions-log.md                 — 38 entries, incl. 3 supersessions
├── 08-known-risks.md                   — 11 risks, 7 Mitigated, 2 Accepted, 2 Open
├── 09-testing-status.md                — unit 45 / integration 22 / e2e 14 / smoke 8
├── 10-open-questions.md                — 2 strategic questions deferred to Q3
├── 11-session-summary.md               — 61 session entries (append mode)
├── 12-open-doubts-and-questions.md     — 3 open, 34 resolved
└── 13-phase-history.md                 — 5 transitions (all 5 phase jumps logged)

~/.mastermind/global/
├── lessons.md     — 7 entries promoted (3 from Notas-AI)
├── patterns.md    — 4 entries (1 from Notas-AI: pgvector pre-filter)
├── pitfalls.md    — 6 entries (1 from Notas-AI: TZ anchor)
├── stacks.md      — Next.js+Supabase+Stripe verdict: Good
└── vendors.md     — OpenAI, Stripe, Supabase, Vercel verdicts
```

The system's promise is visible here: every major decision, every major lesson, every transition — persisted. Open the folder in 6 months and you can reconstruct the entire project.

---

## 10. Parallel execution patterns

Running multiple agents at once is a real productivity unlock, but also the biggest source of silent conflicts and runtime surprises. MASTERMIND has a disciplined approach.

### 10.1 The rules (recap from rule 07)

1. **Parallelize branches, not the same branch.** Git enforces this — do not fight it.
2. **Feature-named worktrees, not agent-named.** `feat/auth-refactor`, never `agent-3-tuesday`.
3. **Max 3–4 concurrent local worktrees.** Above that, go to cloud agents.
4. **Lifecycle ≤ 1 working day.** If a worktree lives longer, the task was too big.
5. **Same base commit.** All parallel worktrees fork from the same `main` SHA.
6. **Task assignment by domain, not by file type.** `Agent-auth` end-to-end, not `Agent-backend + Agent-frontend + Agent-tests`.
7. **Clean up after merge.** `scripts/worktree-cleanup.ps1` after every merge.

### 10.2 Decision tree — parallel or sequential?

```
You have 2+ tasks from the same breakdown.
                │
                ▼
Task B needs an artifact Task A produces? ──yes──▶ SEQUENTIAL (subagent-dispatcher)
                │ no
                ▼
Task A and B edit overlapping files? ────────yes──▶ SEQUENTIAL
                │ no
                ▼
Tasks share runtime state (DB, port, cache)? ─yes──▶ Can we isolate? 
                │ no                              ─yes──▶ PARALLEL w/ runtime isolation
                │                                 │
                ▼                                 ▼ no
   PARALLEL (parallel-executor) ◄────── SEQUENTIAL
                │
                ▼
   How many concurrent?
      ≤ 4 local worktrees     → local parallel-executor
      > 4 concurrent agents   → Cursor Cloud Agents
      Critical task, need best → /best-of-n (2-4 models, one task, pick winner)
```

### 10.3 Pattern A — Sequential pipeline (default)

```
implementation-planner (plan)
       │
       ▼
subagent-dispatcher
       │
       ├── Task 1 → implementer → spec reviewer → code quality reviewer → ✓
       ├── Task 2 → implementer → spec reviewer → code quality reviewer → ✓
       └── Task 3 → implementer → spec reviewer → code quality reviewer → ✓
       │
       ▼
code-reviewer (final roll-up over branch)
       │
       ▼
memory-updater
```

**Use when:** plans with tightly coupled tasks, or ≤ 2 tasks, or when certainty > speed.

### 10.4 Pattern B — Parallel worktrees

```
parallel-executor
       │
       ├── Worktree A (/worktrees/slice-a) → dispatcher → merge PR
       ├── Worktree B (/worktrees/slice-b) → dispatcher → merge PR
       └── Worktree C (/worktrees/slice-c) → dispatcher → merge PR
       │
       ▼
cross-track code-reviewer (combined diff vs main)
       │
       ▼
memory-updater + scripts/worktree-cleanup
```

**Use when:** 2+ genuinely independent slices, local machine can sustain them.

### 10.5 Pattern C — `/best-of-n` (quality over speed)

```
parallel-executor (best-of-n mode)
       │
       ├── Worktree A with Claude Opus   → implementation 1
       ├── Worktree B with GPT-5-class   → implementation 2
       └── Worktree C with Composer      → implementation 3
       │
       ▼
Compare diffs side-by-side
       │
       ▼
Pick the winner (or merge ideas across them) → keep that worktree
       │
       ▼
Cleanup the losers (scripts/worktree-cleanup.ps1 -All -Force on the non-winners)
```

**Use when:** one critical task where quality matters far more than cost. **Rarely.** Cost scales linearly with N.

### 10.6 Pattern D — Cloud agents

When > 4 concurrent agents are needed, or you want to disconnect and come back to PRs, use Cursor Cloud Agents (self-hosted or Cursor-hosted). See [`cursor.com/blog/self-hosted-cloud-agents`](https://cursor.com/blog/self-hosted-cloud-agents).

Record the activation in `memory/07-decisions-log.md`: *"Switching to cloud agents for epic X because local concurrency exceeded laptop capacity."*

### 10.7 Runtime isolation — the Docker question

**Default: no Docker.** Worktrees isolate code, not runtime. Runtime conflicts only happen when parallel agents all spin up something that holds a resource (port, DB, Redis, Docker daemon itself).

**When Docker IS needed:** introduce `docker compose -p <worktree-slug> up` — each worktree gets its own Compose project namespace (networks, volumes, service names all prefixed). No default, opt-in per project.

**Signals that you need Docker Compose project-per-worktree:**
- Two agents each start a Next.js dev server (port collision — can be solved by the `MM_DEV_PORT` offset alone, no Docker needed).
- Two agents each run DB migrations against the local DB (need separate DBs — Docker Compose is the cleanest).
- Two agents each spin up Redis, Postgres, a queue (need isolated networks — Docker Compose).
- An agent needs specific OS-level dependencies (a native build tool).

Introduce Docker only when one of these bites you, not "just in case".

### 10.8 The scripts

| Script | What it does | When to run |
|---|---|---|
| `scripts/worktree-spawn.ps1 -Slug <slug> -Type feat -InstallDeps` | Create a worktree at `../<repo>-worktrees/<slug>` on branch `feat/<slug>`, assign port offset, write `.worktree-env`, install deps | Before dispatching a parallel slice |
| `scripts/worktree-cleanup.ps1` | Sweep merged worktrees; prune stale metadata | Daily or after `/mm-ship` completes |
| `scripts/worktree-cleanup.ps1 -Slug <slug>` | Remove a specific worktree (respects uncommitted work unless `-Force`) | When a specific slice is done or aborted |
| `scripts/worktree-cleanup.ps1 -All` | Remove ALL spawned worktrees (blocks on uncommitted unless `-Force`) | End of a parallel sprint |
| `scripts/worktree-cleanup.ps1 -DryRun` | Report what WOULD be removed | Before running a sweep you are unsure about |

Each has a `.sh` sibling for macOS/Linux with equivalent flags.

### 10.9 Common parallel failure modes

| Failure | Why it happens | Fix |
|---|---|---|
| Two worktrees with the same branch | Git prevents this; error is confusing | Use unique slugs |
| Port collision on dev server | Both default to `:3000` | Use `.worktree-env MM_DEV_PORT` in your dev startup |
| DB migration clash | Both agents touch the same DB | Docker Compose project per worktree, or separate DBs |
| Merge conflicts at integration | "Independent" was wrong — files overlapped | Re-run independence analysis; one slice absorbs the other |
| Orphan worktrees on disk | Someone deleted the folder manually | `git worktree prune` recovers the metadata |
| Disk bloat | Too many worktrees, each with node_modules | Cap concurrency at 4; cleanup aggressively |

---

## 11. Cross-project memory in practice

`~/.mastermind/global/` is how MASTERMIND gets smarter **between** projects, not just within each one. Without it, every new project starts from zero.

### 11.1 The five files

```
~/.mastermind/global/
├── lessons.md     — "what worked / what failed, with evidence"
├── patterns.md    — "reusable patterns (architectural, product, workflow)"
├── pitfalls.md    — "anti-patterns observed repeatedly, with cost"
├── stacks.md      — "stack choices with outcomes across projects"
├── vendors.md     — "third-party providers with verdicts"
└── README.md      — protocol + privacy + consumers
```

### 11.2 The 3-part test (canonical)

Before promoting a project finding to `~/.mastermind/global/`, it must pass all three:

1. **Project-agnostic.** Strip project-specific nouns. Does the lesson still read as useful and true?
2. **Evidence-backed.** At least one concrete reference (post-mortem, decision entry, retrospective) that the lesson derives from. Citation is mandatory.
3. **Actionable.** It changes a future decision, not just informs.

Fails any → do not promote. Log the reason (do not silently drop).

### 11.3 Feeding the memory — when to run `/mm-learn`

- **At the weekly retrospective** (workflow 05 phase 5). Default cadence in Iteration and Launch.
- **At a phase gate** (workflow 04 phase 6, optional). A phase ending is a natural reflection moment.
- **After a notable post-mortem** (bug-investigator phase 7, manual). When a bug teaches something cross-project.
- **Ad-hoc** when the user says *"that's a lesson for next project"*.

`continuous-learner`:
1. Scans sessions + decisions + risks + post-mortems in the window (default 7 days).
2. Classifies each candidate by target file.
3. Applies the 3-part test.
4. Drafts entries in the canonical format per target file.
5. **Per entry** asks the user `approve` / `edit` / `skip`.
6. On approval, writes + commits in the global repo.

### 11.4 Consuming the memory — when and how

| Skill | Consumes what | When |
|---|---|---|
| `project-deep-audit` | `lessons.md`, `pitfalls.md`, `patterns.md` | At the start of a new audit — surfaces as "Cross-project signals" |
| `research-first` | `vendors.md`, `stacks.md` | Before any external search — a prior "Avoid" verdict reframes the research question |
| `architecture-mapper` | `patterns.md` | When proposing topology or a service split |
| `skill-creator` | `patterns.md` | Before creating a new skill — check if the idea already exists elsewhere |

### 11.5 Privacy rules (binding)

`~/.mastermind/global/` must **never** contain:

- Secrets, tokens, API keys.
- Client names, customer IDs, internal URLs.
- PII, PHI, payment data.
- Confidential product details.

Use neutral references: *"a B2C SaaS in the logistics domain"*, not *"Project Acme for Client X"*.

The global repo is typically hosted **privately** (not on a public GitHub org). The template does not push it for you — you initialize and connect it manually.

### 11.6 Example entry (from Notas-AI → global)

An entry promoted after the TZ bug:

```markdown
### Wall-clock features need explicit timezone handling in the spec
- **Symptom:** A feature that reads "now" on the server (UTC) and anchors
  to user time-of-day returns wrong data for non-UTC users.
- **Trigger:** Server computes `new Date()` and compares to user-local timestamps
  without converting, OR user timestamps are stored without TZ metadata.
- **Cost:** 3h debug + incident response + user trust loss; often undetected
  in local testing (most dev machines are in the same TZ as the seed data).
- **Evidence:** 1 post-mortem (B2C SaaS with calendar integration, 2026-05-18).
- **Prevention:** For any feature whose output depends on "current time",
  the spec MUST state the TZ policy and tests MUST cover ≥ 2 TZs (UTC + one offset).
- **Recovery:** Identify affected records, backfill corrected view, notify users
  in the blast radius.
- **Seen in N projects:** 1 (add "Seen in N" when reused).
```

Note: zero project-specific nouns. Pattern is generalizable.

### 11.7 Global memory repo lifecycle

- **Init once**, when you finish the first project: `git init` inside `~/.mastermind/global/`.
- **Connect to private remote** (optional): `git remote add origin <private-repo-url>`.
- **Commit every promotion** as its own commit with a typed message:
  - `lesson: <title>`
  - `pattern: <title>`
  - `pitfall: <title>`
  - `stack: <title>`
  - `vendor: <name>`
- **Never delete entries**. Supersede in place, append new.
- **Audit semi-annually**. Some entries expire (vendor verdicts after 12 months, per convention).

---

## 12. Hooks in action

Hooks are automations that fire on defined events. MASTERMIND has two classes of hooks, active in this repo.

### 12.1 Agent-level behavioral hooks (`.cursor/hooks/`)

Instruction files that MASTERMIND-aware agents read at the relevant lifecycle event. They do not require installation; the agent reads them from the repo.

| Hook | Event | Behavior |
|---|---|---|
| [`pre-task.doubt-surfacer.md`](.cursor/hooks/pre-task.doubt-surfacer.md) | Before non-trivial user turns | If keywords (design, pivot, auth, ≥5 files, etc.) or phase (Launch + prod-touching) or scope (>4h) match, force `doubt-surfacer` before any output. Kill-switch: `MM_HOOK_DOUBT_SURFACER=off`. |
| [`post-task.memory-updater.md`](.cursor/hooks/post-task.memory-updater.md) | After task completion | If a skill finished, commits were created, memory was edited, or a decision was taken, ensure `memory-updater` ran. Emits "no-op" if nothing changed. Kill-switch: `MM_HOOK_MEMORY_UPDATER=off`. |
| [`post-merge.docs-refresh.md`](.cursor/hooks/post-merge.docs-refresh.md) | After merge to main | If the merge touched architecture / data / flows / MCP, propose refreshing the matching docs. Offers refresh/later/not-needed; never refreshes silently. Kill-switch: `MM_HOOK_DOCS_REFRESH=off`. |
| [`post-output.suggest-command.md`](.cursor/hooks/post-output.suggest-command.md) | End of any non-trivial turn | Emits a HIGH / MEDIUM / LOW recommendation for the next `/mm-*` command per the Command Recommendation Protocol (`CLAUDE.md §5`). Never auto-executes — user types `go` or runs the command manually. Kill-switch: `MM_HOOK_SUGGEST_COMMAND=off`. |

**Example in practice.** Day 13 of Notas-AI — you type:

```
"Let's pivot from password auth to magic-link only. Design the flow."
```

The `pre-task.doubt-surfacer` hook arms (trigger: "pivot" + "design"). Instead of producing a flow diagram immediately, the agent says:

> *"(Doubt-Surfacer pre-task hook armed — running Question Protocol before proceeding.)"*
>
> *"Before designing the new flow, I have assumptions and questions:*
> - *Is this pivot a hard decision, or an exploration? If exploration, let's keep password auth for MVP and add magic-link as a v2.*
> - *Which personas use magic-link today vs password today? If your freelancer writer persona is older-skewing, password may have better compatibility.*
> - *Does this affect the existing auth-mvp breakdown (already committed)? If yes, we need to either supersede slices or re-do the breakdown.*
> - *… (14 more)"*

### 12.2 Git client-side hooks (`scripts/git-hooks/`)

Shell scripts installed into `.git/hooks/` via an installer. **Not** auto-installed on clone; run the installer once per clone.

**Install:**

```powershell
pwsh -File scripts/install-git-hooks.ps1
```

```bash
bash scripts/install-git-hooks.sh
```

**What they do:**

| Hook | Event | Blocks on |
|---|---|---|
| `pre-commit` | Before every commit | Skill drift (`sync-skills --check`); secret patterns in staged diff (AWS / Stripe / GitHub / Google / Slack / Anthropic / OpenAI keys, PEM, `.env*` files except `.env.example`). |
| `pre-push` | Before every push | Direct push to `main`/`master` (escape `MM_ALLOW_MAIN_PUSH=1`). Soft-warns on phase-gate gaps. |

**Escape hatches:**
- `git commit --no-verify` / `git push --no-verify` — one-shot skip.
- `MM_SKIP_PRECOMMIT=1` / `MM_SKIP_PREPUSH=1` — shell-scoped disable.
- `MM_ALLOW_MAIN_PUSH=1` — allow a direct push to main (release engineer path).

**Example in practice.** Day 20 of Notas-AI — you accidentally stage a line like `ANTHROPIC_API_KEY=sk-ant-live-xxxx...`. You try to commit:

```
$ git commit -m "feat(auth): password reset"

=== MASTERMIND pre-commit ===

[1/2] Skill sync check (.cursor/skills/ ↔ .claude/skills/) ...
OK: .claude/skills/ is in sync with .cursor/skills/.

[2/2] Secret scan over staged diff ...
BLOCK: possible secret matching pattern /ANTHROPIC_API_KEY\s*=\s*[A-Za-z0-9\-_]{30,}/ in src/config/env.ts
       Review the staged lines. If this is a false positive,
       commit with MM_SKIP_PRECOMMIT=1 git commit ...
```

The key never makes it to Git. You realize it leaked via a copy-paste from your `.env.local`, remove it, re-commit.

### 12.3 When to introduce new hooks

Same three criteria for any new hook:

1. The action has been performed manually ≥ 3 times.
2. The action is deterministic.
3. A hook failure cannot silently corrupt state.

If any is uncertain, leave the action manual. The three current agent hooks and the two current git hooks all satisfy these.

### 12.4 The hooks folder is an extension point

The canonical hook documentation is in [`scripts/git-hooks/README.md`](scripts/git-hooks/README.md) and [`.cursor/hooks/HOOKS.md`](.cursor/hooks/HOOKS.md). When you add a new hook:

1. Write it in `.cursor/hooks/` (agent-level) or `scripts/git-hooks/` (git-level).
2. Document in the respective README / HOOKS.md.
3. Log the addition in `memory/07-decisions-log.md`.
4. Review with `code-reviewer` (skills are code-like artifacts).

---

## 13. FAQ — common situations

### Starting out

**Q: I just cloned the template. What's the one command I run?**
`/mm-bootstrap "<your idea in a sentence>"`. That invokes workflow 01 and walks you through Idea → Discovery.

**Q: Do I need to fill every file in `memory/` before starting?**
No. The bootstrap workflow fills them progressively. You only need to answer the questions the agent asks you.

**Q: My project is existing code, not a new idea. How do I onboard?**
Run `/mm-audit` first on the existing codebase. `project-deep-audit` handles both greenfield and brownfield — it reads existing code, maps architecture, finds risks. Once the audit is done, run `/mm-gate Discovery` or wherever the project actually is.

### Phases and gates

**Q: Can I skip a phase?**
Technically yes, but you must document the rationale in `memory/07-decisions-log.md` and `memory/13-phase-history.md`. `phase-gate-reviewer` flags skips explicitly as requiring written justification. The most common legitimate skip is `Idea → Definition` if you come in with an already-validated idea.

**Q: What if I never enter the Launch phase?**
That's fine. Many projects live in Iteration indefinitely. Launch is for products with a public scale / SLA commitment.

**Q: How do I know when to advance a phase?**
Run `scripts/phase-gate-check.ps1 -NextPhase <target>`. If it returns PASS, run `/mm-gate <target>`. If GAPS, address them first.

**Q: I advanced the phase and realized it was premature. Can I roll back?**
Yes. Run `/mm-gate <previous-phase>`. `phase-gate-reviewer` treats backward transitions as notable decisions: PROCEED WITH CAVEATS and an explicit note in the transition entry.

### During MVP

**Q: My plan has 3 tasks. Do I need `subagent-dispatcher`?**
3 is the threshold. Below 3, use Cursor Plan Mode directly. At 3+, the dispatcher pays for itself because the two-stage review catches mistakes the single-agent flow misses.

**Q: The dispatcher reported BLOCKED on a task. What do I do?**
Triage: context problem, model problem, task-too-big problem, or plan-is-wrong problem. Never silently re-dispatch with the same prompt and model. If the plan is wrong, go back to `implementation-planner`.

**Q: Should I activate `task-master-ai`?**
Install it when (1) you're in MVP execution, (2) the plan has ≥ 10 tasks, (3) the dispatcher will drive. Before that, the Plan Mode + plan file is enough and saves 5k tokens of MCP overhead.

**Q: I want to run `/mm-ship` in parallel for two epics. How?**
Only if the independence analysis confirms they don't share files or state. If confirmed, `parallel-executor` handles it — or just say *"run these two in parallel via worktrees"* and the agent calls `parallel-executor`.

### Bugs and incidents

**Q: A bug just came in. Do I interrupt the current `/mm-ship`?**
Severity-dependent. If Critical (prod-breaking, data-at-risk), yes: halt, run `/mm-bug`, resume `/mm-ship` after merge. If lower, schedule it; `bug-investigator` can wait until the current slice lands.

**Q: The bug turns out to be a spec issue, not a code bug. What now?**
`bug-investigator` Phase 3 will flag it as "not a bug, a feature gap". The skill redirects you to `product-requirements` to update the PRD, then back to `feature-breakdown` / `implementation-planner` for the missing scope. See Section 8 (Going back).

**Q: Must I write a post-mortem for every bug?**
Only for non-trivial ones. A typo fix doesn't need a post-mortem. A 2-hour-to-find bug does. Rule of thumb: if investigation took > 2 hours, write the post-mortem.

### Memory and documentation

**Q: I edited a `memory/` file directly. Is that OK?**
For quick corrections, yes. But the canonical flow is to let `memory-updater` handle it, because the skill ensures formats, timestamps, and cross-references are consistent. For manual edits, commit them with `docs(memory): <reason>` so the log reflects the change.

**Q: Can I delete old entries in `memory/07-decisions-log.md`?**
**No.** It is append-only. Old decisions stay as history. When a decision is superseded, append a new entry and link back.

**Q: `memory/11-session-summary.md` is getting huge. What do I do?**
When it exceeds ~20 session entries, archive the oldest to `docs/archive/sessions-YYYY-QN.md` in a single `docs(memory): archive older sessions` commit. Keep the structure intact.

**Q: When do I update `docs/` vs `memory/`?**
`memory/` holds the one-page executive view per topic (current state, decisions log, open questions). `docs/` holds the detailed artifacts (PRD, flows, architecture, ADRs, post-mortems). They reference each other.

### Cross-project memory

**Q: When do I initialize `~/.mastermind/global/`?**
Whenever you finish your first real project and have ≥ 1 lesson worth promoting. Until then, skip — the folder can stay empty and the skills handle it gracefully.

**Q: Can I share `~/.mastermind/global/` with my team?**
Yes, via a private Git repo. Everyone clones it to `~/.mastermind/global/`. Promotions via `/mm-learn` commit locally; team members push/pull on their own cadence.

**Q: Can the memory contain client names or secrets?**
**No.** Binding rule in `.cursor/rules/05-claude-mcp-integration.mdc`. Use neutral references. `continuous-learner` strips project-specific nouns before proposing entries.

### Hooks and automation

**Q: The `pre-commit` hook is blocking me because of a false positive secret match. What do I do?**
One-shot: `git commit --no-verify`. Persistent for your session: `MM_SKIP_PRECOMMIT=1` in your shell. Fix later: refine the pattern in `scripts/git-hooks/pre-commit` if the false positive is common.

**Q: I pushed to main accidentally and the pre-push hook blocked it. How do I recover?**
You didn't push anything — the hook prevented it. Create a feature branch: `git checkout -b feat/<slug>`, then push. If you genuinely need to push to main (e.g. you're a release engineer), `MM_ALLOW_MAIN_PUSH=1 git push`.

**Q: I don't like the `pre-task.doubt-surfacer` hook triggering so often.**
Adjust its triggers in [`.cursor/hooks/pre-task.doubt-surfacer.md`](.cursor/hooks/pre-task.doubt-surfacer.md) (it's a markdown instruction file). Or disable with `MM_HOOK_DOUBT_SURFACER=off`.

### Scaling up

**Q: I want to run 10 agents concurrently. Possible?**
Not locally. Above 4, move to Cursor Cloud Agents (self-hosted or Cursor-hosted). `parallel-executor` documents this path. Cloud agents run in isolated VMs and scale horizontally.

**Q: Multiple people on the same repo using MASTERMIND. Conflicts?**
Treat `.cursor/skills/`, `.cursor/rules/`, and the top-level docs as carefully reviewed code. Each person should pull + sync-skills before editing. Skill drift between `.cursor/` and `.claude/` is caught by the pre-commit hook. PRs that touch skills should be reviewed by `code-reviewer`.

**Q: Can I use this with models other than Claude / GPT?**
Yes. The skills and workflows are model-agnostic at the contract level. The MCP stack ships Context7, Memory Graph, and GitHub — those work with any agent. Model-specific optimizations (model selection tables in rule 07) assume you pick the cheapest model that works, regardless of provider.

### Edge cases

**Q: I'm in the middle of a session and Cursor crashes. Do I lose progress?**
The skills themselves commit to git frequently (TDD rhythm). `memory/11-session-summary.md` is append-mode. You lose the chat context but not the work.

**Q: My project doesn't match the stack defaults (not JS/TS). Does MASTERMIND still work?**
Yes. The rules and skills are stack-agnostic at the contract level. Only `.cursor/rules/02-tech-stack.mdc` has a JS/TS section, and it's explicitly conditional ("apply ONLY when stack is JS/TS"). Delete that block for non-JS projects.

**Q: Can I use MASTERMIND for a non-SaaS project (library, CLI tool, research code)?**
Yes, with adaptation. Discovery + Definition + MVP + Iteration still apply. The Phases in `memory/13` might collapse (a research project might only have Discovery + Iteration). Adapt the canonical phase definitions in `memory/13-phase-history.md §Phase definitions` and log the adaptation.

---

## 14. Operator cheatsheet

The one-page reference for daily work.

### Start-of-day

```
1. scripts/phase-gate-check.ps1            — Current phase + artifact gaps.
2. /mm-next                                — What do I work on now?
```

### Common flows

```
New project:       /mm-bootstrap "<idea>"
New epic in MVP:   /mm-ship <epic-slug>
A bug arrives:     /mm-bug "<description>"
Weekly discipline: /mm-retro
Advance phase:     /mm-gate <target-phase>
Learn cross-proj:  /mm-learn [window]
Force doubt prot:  /mm-doubt [topic]
Review a diff:     /mm-review [branch]
New plan:          /mm-plan <slice>
Multi-angle audit: /mm-audit [focus]
```

### Script cheatsheet

```
Sync skills:           pwsh -File scripts/sync-skills.ps1          -Check
Check phase:           pwsh -File scripts/phase-gate-check.ps1     -NextPhase MVP
Spawn worktree:        pwsh -File scripts/worktree-spawn.ps1       -Slug <slug> -InstallDeps
Cleanup worktrees:     pwsh -File scripts/worktree-cleanup.ps1     -DryRun
Install git hooks:     pwsh -File scripts/install-git-hooks.ps1
Install task-master:   pwsh -File scripts/install-taskmaster.ps1   -ClaudeCodeAuth
```

Each has a `.sh` sibling for macOS / Linux.

### Escape hatches

```
Skip hook once:          git commit --no-verify
Skip precommit (shell):  $env:MM_SKIP_PRECOMMIT = "1"
Skip prepush (shell):    $env:MM_SKIP_PREPUSH = "1"
Allow main push (once):  $env:MM_ALLOW_MAIN_PUSH = "1"; git push
Disable doubt hook:      $env:MM_HOOK_DOUBT_SURFACER = "off"
Disable memory hook:     $env:MM_HOOK_MEMORY_UPDATER = "off"
Disable docs hook:       $env:MM_HOOK_DOCS_REFRESH = "off"
```

### Key files to know

```
Kernel:                CLAUDE.md
Rules:                 .cursor/rules/00..07.mdc
Skills (canonical):    .cursor/skills/<name>/SKILL.md
Skills (mirror):       .claude/skills/ (auto-synced)
Workflows:             .claude/workflows/01..05
Commands:              .claude/commands/mm-*.md
Memory:                memory/00..13
Cross-project memory:  ~/.mastermind/global/
Plans:                 .cursor/plans/YYYY-MM-DD-<slug>.md
```

---

## 15. Appendix — full component index

### 15.1 Skills (19)

**System 1 — Foundation**
- `.cursor/skills/doubt-surfacer/SKILL.md`
- `.cursor/skills/memory-updater/SKILL.md`
- `.cursor/skills/skill-creator/SKILL.md`

**System 1 — Discovery**
- `.cursor/skills/project-deep-audit/SKILL.md`
- `.cursor/skills/product-requirements/SKILL.md`
- `.cursor/skills/flow-analyzer/SKILL.md`
- `.cursor/skills/research-first/SKILL.md`

**System 1 — Design**
- `.cursor/skills/architecture-mapper/SKILL.md`
- `.cursor/skills/feature-breakdown/SKILL.md`

**System 1 — Execution**
- `.cursor/skills/implementation-planner/SKILL.md`
- `.cursor/skills/test-strategist/SKILL.md`

**System 1 — Quality**
- `.cursor/skills/bug-investigator/SKILL.md`
- `.cursor/skills/code-reviewer/SKILL.md`
- `.cursor/skills/security-review/SKILL.md`

**System 2 — Execution foundation**
- `.cursor/skills/phase-gate-reviewer/SKILL.md`
- `.cursor/skills/approval-gatekeeper/SKILL.md`

**System 2 — Orchestration**
- `.cursor/skills/subagent-dispatcher/SKILL.md`
- `.cursor/skills/parallel-executor/SKILL.md`

**System 2 — Learning**
- `.cursor/skills/continuous-learner/SKILL.md`

### 15.2 Rules (8)

- `.cursor/rules/00-project-operating-system.mdc`
- `.cursor/rules/01-karpathy-principles.mdc`
- `.cursor/rules/02-tech-stack.mdc`
- `.cursor/rules/03-testing-policy.mdc`
- `.cursor/rules/04-safety-and-git.mdc`
- `.cursor/rules/05-claude-mcp-integration.mdc`
- `.cursor/rules/06-execution-modes.mdc`
- `.cursor/rules/07-subagent-orchestration.mdc`

### 15.3 Workflows (5)

- `.claude/workflows/01-new-project-bootstrap.md`
- `.claude/workflows/02-feature-lifecycle.md`
- `.claude/workflows/03-bug-triage.md`
- `.claude/workflows/04-phase-gate-transition.md`
- `.claude/workflows/05-weekly-retrospective.md`
- `.claude/workflows/README.md` (index)

### 15.4 Commands (11)

- `.claude/commands/mm-bootstrap.md`
- `.claude/commands/mm-audit.md`
- `.claude/commands/mm-plan.md`
- `.claude/commands/mm-ship.md`
- `.claude/commands/mm-bug.md`
- `.claude/commands/mm-doubt.md`
- `.claude/commands/mm-next.md`
- `.claude/commands/mm-review.md`
- `.claude/commands/mm-gate.md`
- `.claude/commands/mm-retro.md`
- `.claude/commands/mm-learn.md`
- `.claude/commands/README.md` (index)

### 15.5 Memory files (14)

- `memory/00-project-brief.md`
- `memory/01-product-vision.md`
- `memory/02-current-state.md`
- `memory/03-architecture.md`
- `memory/04-data-model.md`
- `memory/05-user-flows.md`
- `memory/06-feature-map.md`
- `memory/07-decisions-log.md`
- `memory/08-known-risks.md`
- `memory/09-testing-status.md`
- `memory/10-open-questions.md`
- `memory/11-session-summary.md`
- `memory/12-open-doubts-and-questions.md`
- `memory/13-phase-history.md`

### 15.6 Hooks

**Agent-level** (`.cursor/hooks/`, no installation needed):
- `pre-task.doubt-surfacer.md`
- `post-task.memory-updater.md`
- `post-merge.docs-refresh.md`
- `HOOKS.md` (documentation)

**Git-level** (`scripts/git-hooks/`, install via `scripts/install-git-hooks.*`):
- `pre-commit` (bash)
- `pre-push` (bash)
- `README.md` (documentation)

### 15.7 Scripts

**Automation helpers** (PowerShell + bash siblings):
- `scripts/sync-skills.ps1` / `.sh`
- `scripts/phase-gate-check.ps1` / `.sh`
- `scripts/worktree-spawn.ps1` / `.sh`
- `scripts/worktree-cleanup.ps1` / `.sh`
- `scripts/install-taskmaster.ps1` / `.sh`
- `scripts/install-git-hooks.ps1` / `.sh`

### 15.8 MCP stack

Active in `.cursor/mcp.json` + `claude-side/mcp-config.json`:
- `context7` — library/API docs (always on).
- `memory-graph` — cross-project memory (points to `~/.mastermind/global/memory-graph.json`).
- `github` — repo, issues, PRs (needs PAT).

Reserved, install per-project when needed:
- `task-master-ai` (via `scripts/install-taskmaster.ps1`).
- `playwright` (manual enablement for UI verification).

### 15.9 Cross-project memory (`~/.mastermind/global/`)

- `lessons.md`
- `patterns.md`
- `pitfalls.md`
- `stacks.md`
- `vendors.md`
- `README.md`

Optionally mirrored into Memory Graph MCP as `memory-graph.json`.

---

## Closing

This guide is the operational manual for MASTERMIND 2.0. Keep it open while you use the template the first time; consult it by section later.

Corrections, improvements, and edge cases learned in real use should be promoted as lessons via `/mm-learn` (for cross-project wisdom) or as direct edits to this file (for template-specific refinements). If the edit changes a contract (a skill interaction, a workflow sequence, a rule), log the change in `memory/07-decisions-log.md` so future readers see the rationale.

**Version.** v1.0 — in sync with the repo at commit **System 2 complete + audit**.

**Upstream.** [https://github.com/tottimilan/MASTERMIND-2.0](https://github.com/tottimilan/MASTERMIND-2.0)

