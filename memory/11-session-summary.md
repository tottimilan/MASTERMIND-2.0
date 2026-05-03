# Session Summary — [PROJECT NAME]

> **Append-mode log.** Each meaningful session appends a new section at the top (newest first).
> Previous sessions are preserved below. Never delete. When this file exceeds ~20 sessions, archive the oldest to `docs/archive/sessions-YYYY-QN.md` in a single move-commit.
>
> **Conventions**
> - Newest session goes immediately under the `## Latest session` heading.
> - When a new session starts, copy the previous "Latest session" block (without the heading) into `## Previous sessions` as the topmost entry, then rewrite the template in place.
> - Always use the real date (ISO 8601). Never leave a placeholder.

---

## Latest session

**Date:** 2026-05-03 (continuation)
**Who worked:** User + Claude Opus 4.7 (Cursor)
**Duration:** ~2h (Prototype phase work + audit)

### What was done

1. **Prototype phase introduction (commit `a17b411`):** Added `Prototype` as canonical 7th phase between `Definition` and `MVP` (taking MASTERMIND from 6 to 7 canonical phases). Built `mockup-factory` skill (~340 lines, 3 modes: create / iterate / freeze, platform-aware via memory/14 §Platform). Built `/mm-mockup` slash command. Built workflow `07-full-app-prototyping.md` (10 internal phases). Updated `phase-gate-reviewer` with new transitions (`Definition → Prototype`, `Prototype → MVP`) + skip rule for non-UI projects. Documentation surface updated across CLAUDE.md / README.md / COMMANDS.md / OPERATING-GUIDE.md / `skill-creator` / `memory-updater` / `memory/13-phase-history.md`.

2. **Deep audit (this session):** User requested full-template audit ("auditoría completa, ver si todo está redondo, si no nos hemos sobrecomplicado, token usage"). Auditor-mode pass produced a categorized report:
   - **Structural health:** sync 0 drift (28 skills synced), `main` pushed (0 ahead of origin), Pester suite green, evaluator runs clean. ✅
   - **Token usage in runtime:** kernel ~18k tokens (CLAUDE.md + 9 rules + AGENTS.md). OPERATING-GUIDE.md (1552 lines / ~25k tokens) is **NOT loaded** in any session — only on explicit user/agent request. Verified by grepping all rules and skills: zero references make it auto-loaded. So no runtime cost from its size, only maintenance cost.
   - **4 findings surfaced** (1 Critical, 1 Critical-runtime, 2 Important, see below).

3. **4 audit fixes applied (this commit):**
   - **C1 — `mockup-factory` description trimmed** from 1461 chars to ≤1024 (fits agentskills.io spec). Same bug pattern that Plan B had fixed in `prototype-designer` hours earlier — recurrence is itself the lesson.
   - **C2 — `OPERATING-GUIDE.md` 8 stale numerical mentions** updated (lines 181, 187, 193, 195, 236, 1899, 1943, 1955, 1966): "19 skills"→"23", "5 workflows"→"7", "11 commands"→"14", "(8) Rules"→"(9)", and System-1 / System-2 sub-counts. The Prototype-phase commit (a17b411) had updated the body bullets but missed the cardinality headers.
   - **C3 — `memory/02-current-state.md`** corrected: 22→23 skills (3 mentions), removed self-contradiction in "What is next" (it listed "Plan B merge to `main`" while the same file already declared Plan B MERGED), added Prototype-phase entry, added counter-drift script as next priority.
   - **I1 — `memory/11-session-summary.md`** (this entry): the previous Latest-session block did not cover the Prototype phase work, leaving a trace gap. Rotated to Previous sessions; this new Latest entry documents both the Prototype work and the audit.

### Decisions taken
_No new strategic decisions — audit + cosmetic fixes only. Existing decision entries in `memory/07-decisions-log.md` (Prototype phase, ToB absorption, Plan A) remain accurate as-of-their-date._

### New or mitigated risks
- **New, low-medium:** Recurring template-debt pattern surfaced. Cardinality numbers (skill / workflow / command / rule counts) are hardcoded in **5+ kernel-doc locations** (CLAUDE.md, README.md, OPERATING-GUIDE.md, COMMANDS.md, `skill-creator` registry). Every skill addition risks silent drift. Two skill additions in 24h already caused this exact bug twice. Mitigation: build `scripts/check-counts.ps1` (next priority) so a pre-commit hook fails when kernel docs disagree with filesystem reality.
- **Confirmed, low:** `mockup-factory` recurrence of the EMPTY_DESCRIPTION bug confirms the heuristic chosen for the evaluator is the right one — it caught a real bug in a freshly-authored skill within 24h. Validates Plan A's design choice.

### Current state
_Link: `memory/02-current-state.md`._
- Skills: 23 (16 System 1 + 7 System 2). Latest two: `skill-quality-evaluator`, `mockup-factory`.
- Commands: 14. Workflows: 7. Rules: 9. Memory files: 14.
- Sync canonical ↔ mirror: 0 drift.
- `main` pushed; no pending feature branches besides retained `feat/skill-quality-evaluator` and `feat/adopt-tob-patterns` (deletable).

### Top 3 next priorities
1. **`scripts/check-counts.ps1`** — counter-drift validator + pre-commit hook integration. Highest leverage: prevents the C2/C3 class of bug from happening on the next skill addition.
2. **Heuristic calibration v1.1** of `skill-quality-evaluator` (~3 weeks left of the 4-week observation window).
3. **Cross-project promotion** via `/mm-learn` of accumulated lesson candidates (now 5+).

### Lessons learned (candidates for cross-project Memory Graph)
> Only promote here if project-agnostic, evidence-backed, and actionable. See promotion criteria in `.cursor/rules/05-claude-mcp-integration.mdc §Cross-project Memory Protocol`.

- **Lesson candidate (description-bloat recurrence):** When authoring a new skill, the temptation to make the YAML `description` field rich and self-documenting is recurring. The 1024-char limit (agentskills.io spec) is easy to blow past during creative bursts. Without an automated gate (e.g. evaluator wired into pre-commit), the limit is silently violated. Evidence: `prototype-designer` (1326 chars) and `mockup-factory` (1461 chars) both exceeded the limit on creation, fixed only in retrospect by the evaluator. Counter-pattern: enforce the evaluator as a pre-commit gate once heuristics are calibrated.
- **Lesson candidate (cardinality drift in kernel docs):** When project-wide counts (number of skills, workflows, commands, rules) are hardcoded in 5+ documentation surfaces, every additive change introduces silent doc drift. Evidence: this session, two consecutive skill additions (`skill-quality-evaluator`, `mockup-factory`) each created 5–8 stale numerical mentions across kernel docs. Counter-pattern: derive the numbers from filesystem reality at doc-render or pre-commit time, not at write-time.
- **Lesson candidate (audit before push, not after):** A targeted audit pass between "feature complete" and "merge to main" surfaces the cosmetic-but-confusing inconsistencies that no individual commit reviews because each commit was internally coherent. Evidence: 4 findings in this audit, all introduced by the previous-but-one commit (`a17b411`), none caught at commit-review time. Counter-pattern: run a 5-min audit (eval + sync-check + cardinality grep + last-session-entry presence) as the last step before merging any structural change to `main`.

---

## Previous sessions

### 2026-05-03 — Plan A + Plan B (skill-quality-evaluator + ToB pattern absorption)

**Who worked:** User + Claude Opus 4.7 (Cursor)
**Duration:** ~6h (research + planning + execution)

#### What was done

1. **Research phase (~1h):** Deep-dive analysis of 6 tools from a viral X thread by @regent0x_ ("How I Turned My Claude Code Into 24/7 Dev Team"). Verified live data — found 2 of 7 URLs in the thread were 404 (correct repos identified), star counts inflated 30-40%, claude-squad confirmed broken on native Windows (issue #275). Output: 7 deep-dive `.md` files in `research/` (gitignored) totaling ~3,400 lines.

2. **Recommendation phase (~30 min):** Of the 6 tools, identified 2 with real value-add to MASTERMIND: `PluginEval` framework from `wshobson/agents` (unique gap-filler) and 4 patterns from Trail of Bits skills (cherry-pick into existing skills). Other 4 tools rejected (Windows broken / demo / cantidad ≠ calidad).

3. **Planning phase (~45 min):** Drafted Plan A (`build-skill-quality-evaluator`) — 13 bite-sized TDD tasks with complete code snippets, full test coverage, ~10-12h estimated execution. Saved at `.cursor/plans/2026-05-03-build-skill-quality-evaluator.md` (1,302 lines). Decisions locked: split into Plan A + Plan B, static-only v1, defer pre-commit hook integration, swap "persona-driven" for "Rationalizations to Reject" in Plan B.

4. **Execution phase (~3.5h):** Executed Plan A on branch `feat/skill-quality-evaluator` via Option A (subagent-driven). 13/13 tasks complete, 15 commits. New skill `skill-quality-evaluator` operational: PowerShell 7+ static lint detecting 6 anti-patterns (MISSING_FRONTMATTER, INVALID_NAME, EMPTY_DESCRIPTION, BLOATED_SKILL, MISSING_TRIGGER, MISSING_SECTION). 10/10 Pester tests green. Self-evaluation 100/100. Two-stage subagent review on Tasks 5-8 verdict APPROVED_WITH_FIXES → 3 fixes applied (cross-platform paths, test cleanup in finally, typo).

5. **Baseline captured:** 22 skills evaluated, average 97.5/100. Identified 1 real bug (`prototype-designer` description >1024 chars) and 2 likely heuristic false positives (`retroactive-documenter` + `phase-gate-reviewer` MISSING_TRIGGER — heuristic doesn't recognize "use at" / "when the user asks" patterns). Calibration backlog documented for v1.1 after 4-8 weeks of observation.

6. **Plan B (ToB absorption) executed and merged**: 4 skills updated (`prototype-designer` 75→100 description fix, `code-reviewer` +blast-radius, `project-deep-audit` +First-Principles+5-Whys, `security-review` +Insecure-Defaults+Rationalizations-to-Reject). New baseline avg 98.6/100 across 22 skills.

#### Key outcomes

- Both Plan A and Plan B merged to `main` via `--no-ff` (commits `e012a5e`, `4a8f4c4`).
- Skill count: 21 → 22 (mockup-factory came later, in this same calendar day's continuation session).
- Pester 5+ now required for skill development (CurrentUser scope).
- Heuristic for MISSING_TRIGGER produces false positives on 2 valid skills — accepted for v1, calibration scheduled.
