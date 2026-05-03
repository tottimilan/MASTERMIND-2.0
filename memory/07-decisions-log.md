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

### 2026-05-03 — Converted design layer to platform-aware (web + mobile tracks); adopted react-native-reusables as mobile default; added DESIGN.md portable export + mobile CLAUDE.md template
- **Decision:** Refactor the MASTERMIND design layer from its original web/SaaS assumption into a **platform-aware** stack that supports three platforms: `web` (Next.js/React + shadcn/ui + Tailwind), `mobile` (Expo + React Native + react-native-reusables (RNR) + NativeWind), and `cross` (both in one repo). The Platform field in `memory/14-design-system.md §Platform` drives branching in all downstream pieces: rule 08 (two tracks), install-shadcn-mcp (detects Expo vs Next.js and installs the right set), prototype-designer (composes web or mobile Claude Design prompts; mobile also includes Expo Go on-device preview in the workflow). Added `scripts/export-design-md` to emit the portable 9-section DESIGN.md format (cross-tool standard read by Claude Design, Google Stitch, Cursor, v0, Claude Code). Added `.cursor/templates/CLAUDE.md.mobile.md` — a reusable template with mobile non-negotiables (Expo Router, NativeWind, Platform.OS minimization, SafeAreaView, Reanimated 3, expo-secure-store, touch targets ≥ 44pt/48dp, etc.) that gets seeded into the project's CLAUDE.md on mobile installs.
- **Reason:** APP ARMARIO (the user's first pilot) is Expo + React Native + mobile — but the design layer we shipped on 2026-05-02 implicitly assumed web (Claude Design defaults to web aesthetics, the install script only checked for Next.js, rule 08 mentioned shadcn without disambiguating). The user caught this. Without platform-awareness, mobile projects get generic IA web-flavored prototypes and incorrect Claude Code implementations. Future-you creates 10 more projects; >50% are likely mobile; the bias compounds fast.
- **Research evidence (mayo 2026):**
  - `react-native-reusables (RNR)` by @mrzachnugent: 8,195 GitHub stars, active (last push Apr 2026), 50 contributors, MIT. Same author shipped shadcn/ui's official Expo support (PR #7540 merged June 2025). Universal: components share 80%+ API with shadcn/ui web. NativeWind v4 + rn-primitives (Radix-equivalent on native). Undisputed community choice among shadcn-style mobile libraries.
  - Alternatives: native-shadcn (<1k stars), NativeCN (129 stars, near-abandoned since Apr 2025), gluestack v3 (popular but not shadcn-philosophy), Tamagui (excellent but different paradigm). All inferior signals.
  - DESIGN.md 9-section format: emerging cross-tool standard. VoltAgent/awesome-claude-design catalogs 68 templates. Google Stitch generates DESIGN.md natively. Claude Design uploads it as design system source. Cursor / v0 / Claude Code all read it.
  - Claude Design itself: supports mobile prototyping with the right prompt (mentioning Expo + Expo Router + NativeWind explicitly). Anthropic's own docs and community guides (claudelab.net) validate the Claude Code + Expo + RN workflow in 2026.
- **Alternatives considered:**
  - Leave the layer web-only, document mobile as "unsupported for now" — rejected: half of user's projects are mobile; would freeze adoption.
  - Pick native-shadcn or NativeCN over RNR — rejected: weaker community signals, smaller component surface, some near-abandoned. RNR wins on every metric.
  - Replace memory/14 entirely with DESIGN.md — rejected: memory/14 is MASTERMIND-native (read by skills, updated by memory-updater, persists across tools). DESIGN.md is derived/exported. Keeping them separate lets MASTERMIND evolve independently of the cross-tool standard.
  - Build a bespoke mobile component library (Totti-Mobile-UI) — rejected: same reasoning as the rejected Totti-UI proposal for web. shadcn/RNR already provide copy-paste ownership without the maintenance burden.
  - Skip the mobile CLAUDE.md template — rejected: the non-negotiables (Expo Router, no Platform.OS overuse, SafeAreaView always, Reanimated 3 over legacy Animated, expo-secure-store for tokens, touch targets) are the exact delta that makes Claude Code produce mobile-correct code on first try vs. requiring heavy cleanup. 40 lines of template amortize across every future mobile project.
- **Consequences:**
  - Modified: `memory/14-design-system.md` (added Platform field at top; mobile-specific section with safe-area / platform differences / orientation / tab bar / gestures / preview pipeline; Platform column in patterns table; touch target minimum in spacing section).
  - Modified: `.cursor/rules/08-design-system.mdc` (~200 lines) — dual track with web section + mobile section + cross-platform section + DESIGN.md export policy. Platform field branching documented.
  - Modified: `.cursor/rules/02-tech-stack.mdc` — added Platform field; split "Design system" into web vs mobile defaults; added mobile-specific section (Expo SDK, navigation, styling, animations, gestures, safe-area, state mgmt, data fetching, secure storage, notifications, native modules, build & submit).
  - Modified: `scripts/install-shadcn-mcp.ps1/.sh` — platform detection from memory/14 §Platform + package.json signals; `-Platform auto|web|mobile|cross` flag; mobile path installs NativeWind + safe-area-context + Reanimated + Gesture Handler + CVA + clsx + tailwind-merge (via `npx expo install`) on top of shadcn init; optional seeding of `.cursor/templates/CLAUDE.md.mobile.md` into the project's CLAUDE.md if empty/minimal; `-SkipMobileClaudeMd` flag to disable that.
  - Modified: `.cursor/skills/prototype-designer/SKILL.md` — new "Platform detection" step; two prompt skeletons (web + mobile) with mobile emphasizing "MOBILE APP, not a responsive website" + Expo Router + NativeWind + SafeAreaView + touch targets + haptics + platform differences; mobile preview workflow via Expo Go; anti-pattern against ignoring Platform field.
  - New: `scripts/export-design-md.ps1/.sh` (~280 lines combined) — reads memory/14, extracts sections (identity, tokens colors/typo/spacing/motion, mobile-specific, likes, anti-patterns, patterns, installed components), composes DESIGN.md with the 9 canonical sections (Visual Theme, Color Palette, Typography, Component Stylings, Layout, Depth, Do's/Don'ts, Responsive, Agent Prompt Guide), backs up any existing DESIGN.md to `.mastermind-backups/design-md-<ts>/`, writes the new one. Dry-run default; `-Apply` writes.
  - New: `.cursor/templates/CLAUDE.md.mobile.md` (~140 lines) — complete mobile CLAUDE.md template with Project Overview + Tech Stack + Coding Conventions + Important Rules (Navigation/Platform differences/Safe-area/Animations/Storage/Accessibility/Packages) + Orientation & Layout + Testing + Build & Deploy + Common pitfalls. Used by `install-shadcn-mcp` on mobile installs.
  - Updates: CLAUDE.md (scripts list), README.md (design section rewritten to dual-track with explicit mobile stack), COMMANDS.md (/mm-design now documented as platform-aware), OPERATING-GUIDE.md (rule 08 row, memory/14 row, scripts list).
  - No backward-incompatible changes for existing web projects — Platform field defaults to auto-detection, and web behavior is preserved.
- **Files affected:** `memory/14-design-system.md`, `.cursor/rules/08-design-system.mdc`, `.cursor/rules/02-tech-stack.mdc`, `scripts/install-shadcn-mcp.ps1`, `scripts/install-shadcn-mcp.sh`, `.cursor/skills/prototype-designer/SKILL.md`, `.claude/skills/prototype-designer/SKILL.md` (synced), `scripts/export-design-md.ps1` (new), `scripts/export-design-md.sh` (new), `.cursor/templates/CLAUDE.md.mobile.md` (new), `CLAUDE.md`, `README.md`, `COMMANDS.md`, `OPERATING-GUIDE.md`, `memory/07-decisions-log.md` (this entry).

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

### 2026-05-03 — Plan `build-skill-quality-evaluator` drafted (awaiting execution option)
- **Decision:** Approve the implementation plan at `.cursor/plans/2026-05-03-build-skill-quality-evaluator.md` against branch `feat/skill-quality-evaluator`. The plan builds a MASTERMIND-native skill `skill-quality-evaluator` (PluginEval-inspired, static-only v1) in 13 bite-sized TDD tasks covering: scaffold, fixtures, Pester tests, frontmatter validator, BLOATED_SKILL / MISSING_TRIGGER / MISSING_SECTION detectors, batch `-All` mode, canonical SKILL.md, anti-patterns reference, baseline of the 21 existing skills, peer skill update (`skill-creator`), and mirror sync.
- **Reason:** Closes the longest-standing blind spot in MASTERMIND — the skill library has 21 entries with no automated quality gate. PluginEval was the single component of `wshobson/agents` (research/06-subagent-collections.md) that filled a unique gap. Static-only v1 is deterministic, dependency-free, and survives any future evolution; LLM-judge layer (v2) becomes a clean addition once 4-8 weeks of static output reveal what the heuristics miss.
- **Alternatives considered:**
  - Single monolithic plan (PluginEval skill + 4 ToB pattern absorptions in one go) — rejected: 10+ files violates `implementation-planner` "split if > 8 files" rule and prevents using the new evaluator to baseline before/after the absorptions. Approved split into Plan A (this) + Plan B (ToB absorptions, deferred).
  - Static + LLM-judge in v1 — rejected: introduces non-determinism and API key dependency before the static foundation has been validated. Defer to v2.
  - Wire evaluator into pre-commit hook in v1 — rejected: hook trust is sacred; never gate with an unvalidated tool. Manual CLI for ≥4 weeks first, calibrate, then PR for hook integration.
  - Adopt `wshobson/agents` as plugin marketplace — rejected: importing 80 plugins ruins the opinionated 21-skill inventory; cantidad ≠ calidad; only PluginEval added unique value.
- **Consequences:**
  - New plan file `.cursor/plans/2026-05-03-build-skill-quality-evaluator.md` (13 tasks, ~10-12h estimated work, 8 files created + 3 modified).
  - On execution: skill count 21 → 22, baseline of all skills captured, `skill-creator` interaction graph updated, mirror synced.
  - Plan B (`adopt-tob-patterns`) becomes feasible after baseline: refactor the 3 worst-scoring skills with Trail of Bits patterns (blast radius → `code-reviewer`; First Principles + 5 Whys → `project-deep-audit`; Insecure Defaults + Rationalizations to Reject → `security-review`).
  - `memory/02-current-state.md` will move "Plan A" to "In progress" once the user picks an execution option (A/C/E).
- **Files affected:** `.cursor/plans/2026-05-03-build-skill-quality-evaluator.md` (new), `memory/07-decisions-log.md` (this entry).

### 2026-05-03 — Plan `build-skill-quality-evaluator` executed (13/13 tasks complete, 10/10 tests green, self-eval 100/100)
- **Decision:** Execution of `.cursor/plans/2026-05-03-build-skill-quality-evaluator.md` complete on branch `feat/skill-quality-evaluator`. Skill `skill-quality-evaluator` is operational, scores 100/100 against itself, baseline of 22 skills captured (avg 97.5/100). Two-stage subagent review applied to substantive Tasks 5-8 with verdict APPROVED_WITH_FIXES — 3 fixes applied (cross-platform paths, test cleanup in finally, typo).
- **Reason:** Closes the longest-standing blind spot in MASTERMIND. The library now has an automated quality measure. First baseline reveals 3 skills with findings: 1 real bug (prototype-designer description >1024 chars) and 2 likely false positives (heuristic for MISSING_TRIGGER does not recognize "use at" / "use during" / "when the user asks" patterns). Calibration backlog for v1.1 documented in baseline notes.
- **Alternatives considered:**
  - Apply ToB pattern absorptions in this same plan (Plan B merged in) — rejected per planning-stage decision (see prior log entry). Confirmed correct in retrospect: the evaluator immediately surfaced 3 candidates for Plan B with concrete data, making the absorption sequencing data-driven instead of speculative.
  - Calibrate heuristic on the spot for the 2 false positives — rejected: violates "do not calibrate before 4 weeks of observation" principle (Plan A anti-patterns section). Tracked in baseline notes for v1.1.
- **Consequences:**
  - 13 plan tasks executed across 16 commits on `feat/skill-quality-evaluator` (`be5253a..HEAD`, including planning commit + 13 task commits + 1 post-review fixes commit + 1 final session/testing memory commit).

### 2026-05-03 — Plan A merged to `main` (--no-ff, history preserved)
- **Decision:** Merge `feat/skill-quality-evaluator` into `main` via `git merge --no-ff` (merge commit `e012a5e`). Preserves the 17-commit TDD history (red→green→commit rhythm) and the dispatcher review checkpoints. Squash-merge was rejected because the per-task atomic commits ARE the audit trail of the dispatcher run.
- **Reason:** `/mm-ship` workflow aborted by preconditions (no MVP phase, no epic file, no PRD — this is meta-template work, not a user feature). Direct merge is the right shape for this class of work; a future `/mm-internal` or equivalent command may eventually formalize the "template-development" lifecycle path. For now, manual merge with explicit decision log.
- **Alternatives considered:**
  - `--squash` merge — rejected: would collapse the 17 atomic commits into 1, destroying the TDD red→green trail that documents the dispatcher's discipline. The history IS valuable here (first dispatcher run on the template).
  - PR-based review via `gh pr create` — rejected: redundant after the holistic final review by code-reviewer subagent. Would add ceremony without new information.
  - Bureaucratic backfill (create `docs/features/skill-quality-evaluator.md` retroactively) — rejected: would force a feature-shape onto meta-template work that does not need it.
- **Consequences:**
  - `main` advances by 1 merge commit (`e012a5e`). Branch `feat/skill-quality-evaluator` retained until Plan B starts (no immediate `branch -d`).
  - Post-merge verification on `main`: 10/10 Pester green, `sync-skills.ps1 -Check` exit 0, self-eval of `skill-quality-evaluator` = 100/100. No regressions.
  - `memory/02-current-state.md` updated: skill-quality-evaluator now "shipped" on main, Plan B is the next planned work.
  - `main` has NOT been pushed to `origin`. The user controls when to push.
- **Files affected:** `memory/02-current-state.md`, `memory/07-decisions-log.md` (this entry).

### 2026-05-03 — Plan B `adopt-tob-patterns` drafted (awaiting execution option)
- **Decision:** Approve the implementation plan at `.cursor/plans/2026-05-03-adopt-tob-patterns.md` against branch `feat/adopt-tob-patterns`. The plan absorbs 3 cherry-picked patterns from Trail of Bits skills marketplace into 3 existing MASTERMIND skills, plus fixes the 1 real bug surfaced by Plan A's evaluator baseline (`prototype-designer` description >1024 chars). Total: 4 skill edits + memory + sync = 5 tasks, ~1.5-2.5h estimated.
- **Reason:** First dog-food validation of the new `skill-quality-evaluator` (merged on main as `e012a5e`). The evaluator surfaced 1 Critical finding (real bug) and 2 Important findings (heuristic false positives, deferred to v1.1). Plan B addresses the real bug + executes the cherry-pick strategy from `research/03-trail-of-bits-skills.md` §Veredicto with explicit source attribution per pattern.
- **Alternatives considered:**
  - Drop the prototype-designer fix from Plan B (handle as separate one-line PR) — rejected: surgical to bundle since both touch the skills inventory and both validate the evaluator's signal.
  - Add a 4th absorption (Persona-driven into skill-creator) — rejected per Plan A planning swap (too abstract, low ROI for v1).
  - Use parallel-executor for Tasks 2-4 (independent skills) — rejected: 30 min gain not worth orchestration overhead; merge order is trivial.
  - Subagent-driven execution (Option A) — rejected because the plan ships the prose verbatim; dispatching for "paste + verify" is overhead without value.
- **Consequences:**
  - New plan file `.cursor/plans/2026-05-03-adopt-tob-patterns.md` (5 tasks, 4 source files modified + 1 baseline created).
  - On execution: 4 skills updated, baseline delta captured, prototype-designer recovered 75 → 100, no regressions expected.
  - Trail of Bits credited explicitly in 4 places (one per absorption); `research/03-trail-of-bits-skills.md` referenced as evaluation context.
  - 2 false-positive findings (retroactive-documenter, phase-gate-reviewer MISSING_TRIGGER) intentionally NOT addressed in Plan B (calibration deferred to v1.1 after observation).
  - `memory/02-current-state.md` will move "Plan B" to "In progress" once user picks an execution option (C or E).
- **Files affected:** `.cursor/plans/2026-05-03-adopt-tob-patterns.md` (new), `memory/07-decisions-log.md` (this entry).
  - 8 new files: `.cursor/skills/skill-quality-evaluator/SKILL.md`, `scripts/eval.ps1`, `scripts/eval.Tests.ps1`, `references/anti-patterns.md`, 2 fixtures, `.cursor/plans/baselines/2026-05-03-skill-baseline.txt`, plus `.gitkeep`s.
  - 3 modified files: `.cursor/skills/skill-creator/SKILL.md` (interaction added), `memory/02-current-state.md`, `memory/07-decisions-log.md` (this entry).
  - Skill count: 21 → 22 (15 System 1 + 7 System 2; `skill-quality-evaluator` joins System 2 as a quality gate).
  - Pester 5.7.1 installed in CurrentUser scope as test framework. Documented in skill prerequisites.
  - Plan B (`adopt-tob-patterns`) is now data-driven: prototype-designer needs real fix first, then ToB absorption into the 3 target skills, with the evaluator measuring before/after.
- **Files affected:** all of the above + `.claude/skills/skill-quality-evaluator/**` mirror created in Task 13 sync, `memory/07-decisions-log.md` (this entry).
