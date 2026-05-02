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

### 2026-05-02 — Integrated design system + prototyping layer (shadcn/ui via MCP+Skill + Claude Design + prototype-designer skill + /mm-design + memory/14 + rule 08)
- **Decision:** Add a lightweight design system + prototyping layer to MASTERMIND that leverages shadcn/ui's official MCP and Skill (released in shadcn CLI 3.0, August 2025) plus Anthropic's Claude Design (April 2026 research preview). No custom component library. No Totti-UI package. The "Totti personality" lives in `memory/14-design-system.md` (per-project tokens, likes, anti-patterns, patterns, references) and in `~/.mastermind/global/design-patterns.md` (cross-project visual lessons, promoted by `continuous-learner`). The integration adds 9 pieces: rule `08-design-system.mdc`, memory file `memory/14-design-system.md`, skill `prototype-designer`, command `/mm-design`, helper script `scripts/install-shadcn-mcp.ps1/.sh`, updates to `02-tech-stack.mdc` + workflows 01 and 02, index updates, docs updates.
- **Reason:** The user is not a designer, produces many projects, wants visual coherence across projects without maintaining a bespoke library. shadcn/ui already is the standard (112k stars, official MCP + Skill make it agent-native); Claude Design already bridges design→code (reads shadcn install, hands off to Claude Code). Building a custom Totti-UI package on top would duplicate what shadcn already does and create a maintenance burden. The right leverage is at the MASTERMIND-glue level: record decisions in memory, guide the round-trip, capture the intent.
- **Alternatives considered:**
  - Build `@tottimilan/ui` package on top of shadcn/ui — rejected (scope: ~150 files; maintenance burden; duplicates shadcn's copy-paste model which already lets each project own its components).
  - Use Artifacts instead of Claude Design — rejected (Artifacts has no persistent design system, no handoff bundle, is single-file).
  - Use v0/Lovable/Bolt for prototyping — rejected (don't read the project's shadcn install; generic output; no Claude Code handoff like Claude Design offers).
  - Skip the prototyping layer entirely — rejected (the user prototypes in most projects; without structure, output is generic-IA flavored and doesn't compound across projects).
  - Have agents just "know" about shadcn without the MCP — rejected (prop hallucinations, outdated component info; the MCP is free and official).
- **Consequences:**
  - New rule `.cursor/rules/08-design-system.mdc` (~110 lines): shadcn/ui default, non-negotiables (components.json required, installed components recorded, token changes are decisions), how-to sections for install + add component + prototype, anti-patterns. `alwaysApply: true`.
  - New memory file `memory/14-design-system.md` (~150 lines skeleton, "recommended" depth): Project identity (name, personality adjectives, references, dark mode), Tokens (colors/typography/spacing/motion), Installed components table, Custom components table, What I like, What I don't like, Patterns we use repeatedly, References, Changelog, Integration with tooling, Open questions.
  - New skill `prototype-designer` (~220 lines): bridges memory + Claude Design + shadcn. Reads memory/05, 06, 14; composes structured prompt (goal+layout+content+audience+constraints); guides user through Claude Design round-trip; captures handoff under `docs/design/prototypes/<feature>/`; extracts decisions back into memory/14 with per-entry approval; closes with HIGH rec to `/mm-plan`. Listed under new "System 1 — Design & prototyping" sub-bucket in skill-creator registry.
  - New command `/mm-design` (~35 lines): wraps prototype-designer. Precondition checks (components.json + MCP + memory/14 identity filled). Argument parsing for fidelity/audience/skip-memory-update.
  - New helper script `scripts/install-shadcn-mcp.ps1/.sh` (~270 lines combined): dry-run by default; runs `npx shadcn@latest init`, registers shadcn MCP in `.cursor/mcp.json` and `.mcp.json` (merge-safe, preserves other servers), installs official shadcn Skill via `npx skills add shadcn/ui`. Idempotent (skips shadcn init if components.json exists). Includes Node.js check, stack detection, next-step guidance.
  - `02-tech-stack.mdc` extended with "Design system" and "Prototyping tool" fields, defaulting to shadcn/ui (via MCP+Skill) and Claude Design.
  - Workflow `01-new-project-bootstrap` gains Phase 5.5 "Design system bootstrap" (optional for non-UI projects): runs install-shadcn-mcp, reloads IDE, seeds memory/14 identity + tokens, installs baseline components.
  - Workflow `02-feature-lifecycle` gains Phase 1.5 "Prototype" (optional for non-UI slices): invokes prototype-designer between breakdown and plan, produces bundle under `docs/design/prototypes/`, updates memory/14.
  - skill-creator registry: 21 skills (15 System 1 + 6 System 2). New sub-bucket "System 1 — Design & prototyping" for prototype-designer.
  - memory-updater "Invoked by" list gains `prototype-designer`; notes that memory-updater now writes to memory/14 when the caller is prototype-designer.
  - README.md: new section "Design system + prototyping (shadcn/ui + Claude Design)". Final map updated (15 System 1 skills, 13 commands, 9 helper scripts).
  - CLAUDE.md: script list gains `install-shadcn-mcp`; skill count updated to 21.
  - COMMANDS.md: row + dedicated section 13 for /mm-design; decision tree gains UI-prototyping branch.
  - OPERATING-GUIDE.md: memory/14 in memory table, rule 08 in rules table, prototype-designer under new sub-bucket, /mm-design in commands appendix, install-shadcn-mcp in scripts appendix.
  - Indexes updated (.claude/commands/README.md).
  - No breaking changes to existing projects. Existing rules keep working; the new rule + memory file + skill + command are additive. Existing projects that want the integration run `scripts/sync-from-template` to pull the new files, then `scripts/install-shadcn-mcp.ps1 -Apply`.
- **Files affected:** `.cursor/rules/08-design-system.mdc` (new), `memory/14-design-system.md` (new), `.cursor/skills/prototype-designer/SKILL.md` (new), `.claude/skills/prototype-designer/SKILL.md` (new, synced), `.claude/commands/mm-design.md` (new), `scripts/install-shadcn-mcp.ps1` (new), `scripts/install-shadcn-mcp.sh` (new), `.cursor/rules/02-tech-stack.mdc` (updated), `.claude/workflows/01-new-project-bootstrap.md` (Phase 5.5 added), `.claude/workflows/02-feature-lifecycle.md` (Phase 1.5 added), `.cursor/skills/skill-creator/SKILL.md`, `.claude/skills/skill-creator/SKILL.md`, `.cursor/skills/memory-updater/SKILL.md`, `.claude/skills/memory-updater/SKILL.md`, `CLAUDE.md`, `README.md`, `COMMANDS.md`, `OPERATING-GUIDE.md`, `.claude/commands/README.md`, `memory/07-decisions-log.md` (this entry).
- **Supersedes:** earlier proposal to build `@tottimilan/ui` (the user and I agreed against it in the same session: too much scope for what the shadcn ecosystem already provides).

### 2026-05-02 — Added onboarding path for existing projects (script + workflow 06 + skill + /mm-onboard)
- **Decision:** Ship a full onboarding path for projects that exist outside MASTERMIND and want to join the system. The path covers: (1) `scripts/onboard-existing-project.ps1` / `.sh` for the shell install + stack auto-detect + phase bootstrap + conflict-as-proposal pattern + rules relocation to backup; (2) workflow `06-onboard-existing-project.md` for the full procedure (8 phases); (3) skill `retroactive-documenter` that seeds memory/ from code+git+README with per-file user approval; (4) slash command `/mm-onboard` that orchestrates the in-IDE phases 5–8.
- **Reason:** Before this, MASTERMIND covered "new project from idea" (`/mm-bootstrap`) and "project clone of the template that fell behind" (`sync-from-template`). Projects not born from MASTERMIND but with real history had no safe on-ramp. The user has ~10 such projects (mostly Next.js + TS). Without a formal onboarding path, they either stay outside the system (no compounding benefit, no cross-project memory) or get migrated by hand (error-prone, easy to overwrite project state).
- **Alternatives considered:**
  - Reuse `sync-from-template` as-is — rejected: it assumes the project already has the full shell, just outdated. Existing projects have no shell at all, and may have `.cursor/rules/` customizations that belong to the user.
  - Brute-force copy the whole template on top — rejected: overwrites custom rules, risks stomping on README / `.gitignore` / any pre-existing `CLAUDE.md`. No phase bootstrap, no stack awareness.
  - Fork the template and pull — rejected: existing projects are independent git repos, not forks. Rebasing onto a fork is invasive and breaks project history.
  - Manual checklist in docs — rejected: not repeatable, no machine-assisted conflict detection, easy to miss a file.
  - Single command, auto-write without review — rejected: opaque and dangerous for projects with custom state. The conflict-as-proposal pattern makes every change explicit.
- **Consequences:**
  - New scripts: `onboard-existing-project.ps1` (~360 lines) and `.sh` (~310 lines). Dry-run default. Conflict-as-proposal pattern: existing-and-different files are written as `<file>.mastermind-proposal` next to the original; never overwrites. Pre-existing `.cursor/rules/` relocated to `.cursor/rules-backup-<ts>/` (opt-out via `-KeepExistingRules`). Stack auto-detected from package.json / pyproject.toml / Cargo.toml and pre-fills `02-tech-stack.mdc`. Phase argument required on `-Apply`; writes to `memory/02-current-state.md` and `memory/13-phase-history.md` coherently.
  - New skill: `retroactive-documenter` (~220 lines). Reads code + git log + README + lockfiles + tests. Drafts content for `memory/00`, `02`, `03`, `04`, `06`, `08` based on observed reality (never strategy — that's the audit's job). Per-file user approval (approve / edit / skip). Writes only on approval; one commit per file. Flags what code cannot tell (strategy, Hard Truth, personas) and recommends `/mm-audit` as the natural next step.
  - New workflow: `06-onboard-existing-project.md` (~180 lines). Eight phases: Prep, Install, Resolve conflicts, Commit+Reload, Retroactive seed, Strategic audit, Confirm phase, First retro (optional for MVP/Iteration/Launch).
  - New slash command: `/mm-onboard` (~35 lines). Wraps phases 5–8 of workflow 06. Checks preconditions (shell installed, no pending proposals, phase concrete).
  - Skill-creator registry updated: 20 skills now (14 System 1 + 6 System 2). `retroactive-documenter` listed under a new "System 2 — Onboarding" sub-bucket.
  - `memory-updater` Interactions updated: `retroactive-documenter` added to "Invoked as the finishing step by".
  - README.md: new section "Onboarding an EXISTING project (not born from MASTERMIND)" with the recommended flow (commands + safety notes). Final map updated: 6 skills in System 2, 6 workflows, 12 commands, 8 script helpers.
  - COMMANDS.md: new row for `/mm-onboard` in the summary table, new section "12. `/mm-onboard` — Bring an existing project into MASTERMIND", decision tree updated with the "existing project" branch first.
  - Workflows and commands README indexes updated.
  - CLAUDE.md memory architecture script list gains `onboard-existing-project`.
  - OPERATING-GUIDE.md appendix lists workflow 06, command `/mm-onboard`, skill `retroactive-documenter`, and the two new scripts.
- **Files affected:** `scripts/onboard-existing-project.ps1` (new), `scripts/onboard-existing-project.sh` (new), `.cursor/skills/retroactive-documenter/SKILL.md` (new), `.claude/skills/retroactive-documenter/SKILL.md` (new, synced), `.claude/workflows/06-onboard-existing-project.md` (new), `.claude/commands/mm-onboard.md` (new), `.cursor/skills/skill-creator/SKILL.md`, `.claude/skills/skill-creator/SKILL.md`, `.cursor/skills/memory-updater/SKILL.md`, `.claude/skills/memory-updater/SKILL.md`, `CLAUDE.md`, `README.md`, `COMMANDS.md`, `OPERATING-GUIDE.md`, `.claude/workflows/README.md`, `.claude/commands/README.md`, `memory/07-decisions-log.md` (this entry).
- **Supersedes:** no previous mechanism; first formal onboarding path for non-MASTERMIND projects.

### 2026-05-02 — Added `scripts/sync-from-template` (safe template sync for cloned projects)
- **Decision:** Ship a new pair of scripts (`sync-from-template.ps1` + `.sh`) that pulls updates from an up-to-date MASTERMIND template into an existing project cloned from an older version of the template, without touching project-specific content.
- **Reason:** Projects cloned from the template drift as the template evolves (new skills, new rules, new hooks). Without a safe-by-construction sync mechanism, users copy files by hand and either forget something or accidentally overwrite project data (memory/, docs/, .cursor/plans/). The script formalizes the whitelist (template files) and blacklist (project-specific files), with dry-run by default and per-file timestamped backups.
- **Alternatives considered:**
  - Cherry-pick commits from the template git history — rejected: projects cloned without preserving the template remote cannot cherry-pick cleanly.
  - Git submodule for `.cursor/` and `.claude/` — rejected: adds operational complexity and blocks per-project customization of skills/rules.
  - Manual `Copy-Item` instructions in a doc — rejected: not repeatable, error-prone, no protection against overwriting project data.
  - Apply-by-default, dry-run as flag — rejected: too destructive for a cross-project operation; inconsistent with the implicit user expectation that "sync" means "safe".
- **Consequences:**
  - Two new scripts under `scripts/`: `sync-from-template.ps1` and `sync-from-template.sh`.
  - Hardened whitelist: CLAUDE.md, AGENTS.md, README.md, OPERATING-GUIDE.md, COMMANDS.md, .gitignore, .env.example, all `.cursor/rules/*.mdc`, all `.cursor/skills/**`, `.cursor/hooks/*.md`, `.claude/CLAUDE.md`, all `.claude/skills/**`, `.claude/hooks/*.md`, all `.claude/workflows/**`, all `.claude/commands/**`, scripts/*.ps1 / *.sh, `scripts/git-hooks/pre-commit|pre-push|README.md`. `claude-side/mcp-config.json` is OFF by default, opt-in via `-IncludeMcpConfig` / `--include-mcp-config`.
  - Hardened blacklist with defense in depth: `memory/**`, `docs/**`, `.cursor/plans/**`, `.taskmaster/**`, `.env`, `.env.local`, `.env.*` (except `.env.example` / `.env.sample`), `.git/**`, `node_modules/**`, `dist/**`, `.next/**`, `claude-side/prompts/**`. The blacklist check runs even for files that happen to match a whitelist glob.
  - Dry-run is the default; `-Apply` (PS) / `--apply` (bash) required to write. `-Force` / `--force` skips the confirmation prompt.
  - Per-file backups (`<file>.backup-YYYYMMDD-HHMMSS`) on every overwrite.
  - Self-protection: refuses to run when `pwd == -Template`.
  - Exit codes: 0 in-sync / user-confirmed, 1 drift in dry-run or user aborted, 2 bad args / missing template / run-inside-template.
  - README.md gains a dedicated subsection "Syncing an existing project from an updated template" with the recommended flow.
  - CLAUDE.md §Memory Architecture scripts list updated to include `sync-from-template`.
  - Smoke test verified: detects drift on a simulated outdated project clone, protects `memory/00-project-brief.md` and `.cursor/plans/*.md`, refuses to run inside the template itself.
- **Files affected:** `scripts/sync-from-template.ps1` (new), `scripts/sync-from-template.sh` (new), `README.md`, `CLAUDE.md`, `memory/07-decisions-log.md` (this entry).
- **Supersedes:** no previous mechanism; this is the first formal template-to-project sync path.

### 2026-05-02 — Added Command Recommendation Protocol (HIGH / MEDIUM / LOW)
- **Decision:** Introduce a template-wide contract for the agent to recommend the next `/mm-*` command at the end of every non-trivial turn, with a confidence level (HIGH / MEDIUM / LOW) dictating the format. Lives in `CLAUDE.md §5` as the canonical spec, enforced by the new `.cursor/hooks/post-output.suggest-command.md` hook, and referenced from rule `00-project-operating-system.mdc` Output Contract. Unified the "Closing" step of 14 skills to use the new format (HIGH when one command is obvious, MEDIUM when options are plausible, LOW when context is exploratory).
- **Reason:** The system depends on skills and workflows chaining correctly. Before this protocol, skills closed with "hand off to skill X" — which is correct but not **operational**: the user (especially a new one) has to translate skill names into `/mm-*` commands. Adding an explicit, actionable next-command block with a confidence level closes that gap without creating spam: HIGH gives decisive direction, MEDIUM shows the real ambiguity when it exists, LOW admits when there is no next command to recommend.
- **Alternatives considered:**
  - Auto-execute HIGH recommendations when the user types nothing — rejected: the user must retain explicit control; auto-executing violates the safety contract for sensitive commands (auth / payments / schema).
  - Single confidence level with a verbose block — rejected: 90% of HIGH cases don't need options; 90% of LOW cases would become dishonest HIGHs if forced. The three levels match how the agent actually reasons.
  - Implement only as the hook without updating the skills — rejected: the hook alone is discoverable only by agents; users reading a skill's `SKILL.md` would still see the old handoff format and get mixed signals.
- **Consequences:**
  - New canonical spec in `CLAUDE.md §5`; rule 00 references it; new hook `.cursor/hooks/post-output.suggest-command.md`.
  - 14 skills updated with the three-level format in their Closing step: `project-deep-audit`, `product-requirements`, `architecture-mapper`, `feature-breakdown`, `flow-analyzer`, `implementation-planner`, `test-strategist`, `code-reviewer`, `security-review`, `phase-gate-reviewer`, `research-first`, `subagent-dispatcher`, `parallel-executor`, `bug-investigator`.
  - 5 skills intentionally NOT updated: `doubt-surfacer` (its own closing is the user invitation; LOW-by-design), `memory-updater` (invoked by others, no user-facing closing), `skill-creator` (meta; users don't chain from it), `continuous-learner` (emits approve/edit/skip prompts per entry — different format on purpose), `approval-gatekeeper` (it's an interrupt, not a terminal step).
  - `COMMANDS.md` and `OPERATING-GUIDE.md §6.6 + §Hooks` reference the protocol.
  - Kill-switch available: `MM_HOOK_SUGGEST_COMMAND=off`.
- **Files affected:** `CLAUDE.md`, `.cursor/rules/00-project-operating-system.mdc`, `.cursor/hooks/post-output.suggest-command.md` (new), `.cursor/hooks/HOOKS.md`, `.claude/hooks/HOOKS.md`, 14 `.cursor/skills/<name>/SKILL.md` files, `COMMANDS.md`, `OPERATING-GUIDE.md`, `memory/07-decisions-log.md` (this entry).
- **Supersedes:** the previous informal "Closing" handoff pattern ("Do you want to (a)/(b)/(c)…") which is now replaced by the canonical three-level format.

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
