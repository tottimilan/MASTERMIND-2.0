# AGENTS.md

This file is read by OpenAI Codex, Cursor agents, Claude Desktop, and any agent that supports the `AGENTS.md` convention.
It mirrors the contract defined in `CLAUDE.md` so that **any** agent operating on this repository follows the same rules.

---

## Required startup context

Before any task, read (in this order):

1. `CLAUDE.md`
2. `memory/00-project-brief.md`
3. `memory/02-current-state.md`
4. `memory/07-decisions-log.md`
5. `memory/11-session-summary.md`
6. `memory/12-open-doubts-and-questions.md`

If the task is larger than a trivial edit, also read:

- `memory/03-architecture.md` (if the task affects architecture)
- `memory/05-user-flows.md` (if the task affects flows)
- `memory/04-data-model.md` (if the task affects data)

---

## Working process

For any task bigger than a small edit:

1. **Explain what you understood** — a one-paragraph summary.
2. **Surface doubts and questions** — follow the Question & Doubt Protocol in `CLAUDE.md`. List doubts, then 8–20 high-quality questions for the user grouped by category. Do not skip this.
3. **Inspect relevant files** — read before writing.
4. **Propose a plan** — steps, files affected, tests, risks.
5. **Wait for approval** if the task is risky (auth, payments, schema, production).
6. **Implement in small steps.**
7. **Run tests** or explain why tests cannot run.
8. **Update memory** — `memory/11-session-summary.md` and any other affected `memory/*.md` file via the `memory-updater` skill.

---

## Karpathy Principles (always active)

Full text in `.cursor/rules/01-karpathy-principles.mdc`.

1. Think Before Coding.
2. Simplicity First.
3. Surgical Changes.
4. Goal-Driven Execution.

---

## Safety

Never:

- Delete production data.
- Run destructive commands (`rm -rf`, `DROP`, `--force`, production deploys) without explicit user confirmation.
- Change auth or payments logic without an explicit plan and approval.
- Modify DB schema without a migration.
- Install packages without explaining why.
- Commit secrets, tokens, API keys, or `.env*` files.

---

## Output contract

- Be direct and concrete.
- State assumptions.
- If ambiguous, apply the Question & Doubt Protocol instead of guessing.
- Prefer small reversible steps over large irreversible ones.
