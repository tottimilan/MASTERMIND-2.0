# MASTERMIND 2.0 — Master Project Template

> A reusable **Project Operating System** for SaaS / app / product projects.
> Designed for a hybrid **Cursor + Claude Opus Max + MCP** workflow.
> Every file is in English on purpose (consistency with upstream skills and to avoid translation drift). The user can write their own content in any language.

---

## What this is

MASTERMIND 2.0 is a template repository that you **clone once per project**. It gives any AI agent working on the project:

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
│   ├── skills/                        # Reusable playbooks (SKILL.md each)
│   │   ├── project-deep-audit/
│   │   ├── doubt-surfacer/
│   │   ├── product-requirements/
│   │   ├── architecture-mapper/
│   │   ├── feature-breakdown/
│   │   ├── flow-analyzer/
│   │   ├── implementation-planner/
│   │   ├── test-strategist/
│   │   ├── security-review/
│   │   └── memory-updater/
│   └── plans/                         # Approved Plan Mode plans
│
├── .claude/                           # Mirror for Claude Desktop
│   ├── CLAUDE.md
│   ├── memory/
│   ├── skills/
│   ├── agents/
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
└── claude-side/                       # Claude Desktop + MCP
    ├── mcp-config.json
    └── prompts/
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

The 14 skills in `.cursor/skills/` are designed to compose. Each skill declares `Invoked by` / `Invokes` / `Pairs with` in its own `SKILL.md`. The diagram below is the top-level view.

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
                  │  (append-mode SS,  │
                  │  decisions, risks) │
                  └─────────┬──────────┘
                            │
                            │ Promotes cross-project lessons to
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
