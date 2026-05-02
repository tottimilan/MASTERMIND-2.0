# Decisions Log — [PROJECT NAME]

> _To be developed. Append-only. Never edit past decisions; add a new entry that supersedes them._

## Format

```
### YYYY-MM-DD — Decision title
- **Decision:**
- **Reason:**
- **Alternatives considered:**
- **Consequences:**
- **Files affected:**
- **Supersedes:** (optional link to previous decision)
```

## Entries

### 2026-05-02 — Added `COMMANDS.md` (root-level quick reference for `/mm-*`)
- **Decision:** Introduce a new top-level `COMMANDS.md` as a fast, operational reference for the 11 `/mm-*` slash commands, in English, linked from `README.md`.
- **Reason:** Users (and future collaborators) need a single-screen answer to *"which command do I run now?"* that is scannable in 5 seconds. The `OPERATING-GUIDE.md` is exhaustive (~2000 lines) and the `.claude/commands/README.md` is a technical index; neither serves as a fast daily cheat-sheet. `COMMANDS.md` fills that gap without duplicating either.
- **Alternatives considered:**
  - Extend `OPERATING-GUIDE.md` with a prominent quick-reference section — rejected: the guide is already long and the section would get buried.
  - Rely only on `.claude/commands/README.md` — rejected: that file is a technical catalog, not a scan-friendly operator cheat-sheet.
  - Keep the Spanish draft written during a pilot project — rejected: the rest of the template is in English for consistency and broader reach. A single English version is the source of truth.
- **Consequences:**
  - New canonical doc at `COMMANDS.md` (root), English, 233 lines.
  - `README.md` "Start here" block now lists both `OPERATING-GUIDE.md` and `COMMANDS.md`.
  - Maintenance contract: when a new command is added under `.claude/commands/`, `COMMANDS.md` must be updated in the same commit. This contract is stated inside `COMMANDS.md §Maintaining this file`.
- **Files affected:** `COMMANDS.md` (new), `README.md` (link added), `memory/07-decisions-log.md` (this entry).
