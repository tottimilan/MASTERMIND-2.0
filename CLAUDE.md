# CLAUDE.md — Project Operating System Kernel (MASTERMIND 2.0)

> This is the kernel of the project. It is short on purpose. High signal, no noise.
> It applies to both **Cursor** and **Claude Desktop** (and any other agent reading this repo).

---

## Mission

Build high-quality, maintainable, and secure software with the minimum number of unnecessary iterations.
The repository structure is the real intelligence. Questions and doubts surface clarity. Every change must be traceable to a clear need.

---

## Mental Model

- **Structure over prompts.** The `memory/`, `docs/`, `.cursor/` and `.claude/` folders are the brain. A prompt is just a query over that brain.
- **Continuity over cleverness.** Nothing important lives only in chat. If it matters, it lives in `memory/` and is versioned in Git.
- **Clarity before code.** Doubts and questions always come before implementation.
- **Surgical over sweeping.** Smallest change that meets the goal.

---

## Core Execution Rules (Non-Negotiable)

### 1. Karpathy Principles (always active)

Full text in `.cursor/rules/01-karpathy-principles.mdc`. Summary:

1. **Think Before Coding** — State assumptions. If uncertain, ask. Present trade-offs. Don't pick silently.
2. **Simplicity First** — Minimum code that solves the problem. No speculative abstractions.
3. **Surgical Changes** — Touch only what you must. Every changed line traces directly to the user request.
4. **Goal-Driven Execution** — Define success criteria. Loop until verified.

### 2. Question & Doubt Protocol (critical for this user)

Before proposing any change, document, or implementation:

- Always list **all current doubts** (technical, business, UX, risk, assumptions).
- Generate **8–20 high-quality questions** for the user, grouped by category.
- Present doubts + questions **before** any final output.
- Update `memory/12-open-doubts-and-questions.md`.
- End with: *"Do you have any doubts, observations, or additional notes before we continue?"*

This rule is at the same level as the Karpathy principles. It is never optional.

### 3. Self-Review Protocol (before any substantive output)

Before delivering any non-trivial document, plan, code change, or analysis, perform a 30-second self-critique on three axes:

1. **Assumptions that could be false.** Which assumption is the output most dependent on, and how would the output change if it were wrong?
2. **Weakest part of the output.** Which section is least rigorous, most speculative, or most likely to be wrong? Name it.
3. **Risk not mentioned.** What risk, edge case, or constraint was omitted, and why?

Write the self-critique as 2–5 bullets at the bottom of the output **only when the skill does not already enforce an equivalent step**. Skills that satisfy this requirement automatically: `implementation-planner` Step 4 (Self-review), `code-reviewer` (Categorize findings + Verdict), `project-deep-audit` (Hard Truth), `research-first` (Caveats + Open questions), `flow-analyzer` (Error paths + Edge cases), `security-review` (Accepted risks + Compensating controls).

Never produce a numeric quality score. Self-critique is qualitative — numeric scores become performative.

### 4. Context Discipline

- **Invoke skills** instead of inlining their process into the prompt. Skills load on demand (progressive disclosure) and keep the system prompt lean.
- Use **Context7 MCP** for any library or API behavior — never restate it from training data.
- Keep chat responses scannable: short paragraphs, explicit headers, fenced code for anything literal (paths, commands, schema).
- Prefer **referencing** an existing file (`memory/…`, `docs/…`) over rewriting its content.
- When answering inside a session with many long tool outputs, summarize older content compactly before continuing rather than carrying the raw output forward.

### 5. General Rules

- Every non-trivial task → use **Plan Mode** first (Cursor) or an explicit written plan (Claude).
- Every important session → update `memory/11-session-summary.md` (append mode — see `memory-updater`) and `memory/12-open-doubts-and-questions.md`.
- For deep analysis, strategy, or high-stakes decisions → prefer **Claude Opus** (via Claude Desktop or an MCP bridge).
- Use **Context7** automatically whenever code uses an external library or API.
- Use **Playwright MCP** only for real browser verification of critical flows, with a very specific prompt.
- Never commit secrets. `.env*` files are gitignored by default.
- For the skill interaction map (who calls whom), see `README.md §Skill Interaction Graph`.

---

## Memory Architecture

- `CLAUDE.md` (this file) → **kernel / system brain**.
- `memory/` → **long-term project intelligence**, versioned in Git.
- `docs/` → **source of truth** for product, architecture, features, flows, API, testing, security, ADRs.
- `.cursor/rules/*.mdc` → **permanent instructions** always loaded by Cursor. Key rules for execution discipline: `00-project-operating-system` · `01-karpathy-principles` · `04-safety-and-git` · `06-execution-modes` (Coach/Executor/Auditor) · `07-subagent-orchestration` (subagents + parallel worktrees).
- `.cursor/skills/*/SKILL.md` → **reusable playbooks**, loaded on demand to save context. **This is the canonical source** for skills. 16 skills total: 14 System 1 (analysis & documentation) + 2 System 2 (execution foundation: `phase-gate-reviewer`, `approval-gatekeeper`).
- `.claude/skills/` → **generated mirror** of `.cursor/skills/` for Claude Code / Claude Desktop. Do not edit directly; run `scripts/sync-skills.ps1` (or `.sh`) after editing the source.
- `memory/` → 13 canonical files. Notably `memory/13-phase-history.md` tracks phase transitions; `memory/11-session-summary.md` is append-mode.
- `.claude/` → mirror for Claude Desktop (kernel reference + memory + skills + agents + workflows + hooks).
- `claude-side/mcp-config.json` → MCP servers the project relies on.
- `scripts/` → automation: `sync-skills` (canonical↔mirror), `phase-gate-check` (dry-run gate), `worktree-spawn` / `worktree-cleanup` (parallel execution).
- Optional local `CLAUDE.md` files can be placed in risky modules (e.g. `src/auth/CLAUDE.md`) to override the kernel for that subtree.

---

## Model Routing

| Task type | Preferred |
|---|---|
| Deep analysis, strategy, multi-angle thinking, risks, long-form docs | **Claude Opus** (Claude Desktop or MCP bridge) |
| Daily coding, refactoring, small features, bug fixing | **Cursor** (GPT-5.5 Max or Claude Sonnet/Opus depending on task) |
| Library/API usage verification | Any model + **Context7 MCP** |
| UI behavior verification | Any model + **Playwright MCP** |

---

## Golden Rule

**Doubts and Questions first → Clarity → Documents and Code after.**

If this rule is ever skipped, the agent has failed the protocol.
