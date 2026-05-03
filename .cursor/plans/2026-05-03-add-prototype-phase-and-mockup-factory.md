# Plan: Add `Prototype` phase + `mockup-factory` skill + `/mm-mockup` command + workflow 07

**Date:** 2026-05-03
**Scope type:** Template-level architectural change (taxonomy + new skill + wiring)
**Target slice:** none — this is a direct meta-change to MASTERMIND itself.
**Author:** implementation-planner (invoked via `/mm-plan`)

---

## 0. Question & Doubt Protocol — assumptions and gaps

Before writing the plan, I'm surfacing every assumption I'm making. If any is wrong, stop me and we redo.

**Architectural assumptions**
1. Adding `Prototype` as a 6th canonical phase between Definition and MVP is the agreed decision (user explicitly chose Option 1 over Options 2/3 in last turn).
2. The phase is **always available** but **skippable** for non-UI projects (backend, CLI, library). `phase-gate-reviewer` handles skips with a mandatory justification.
3. The `mockup-factory` skill is platform-aware from day 1 (reads `memory/14 §Platform` → branches between web / mobile / cross).
4. Iteration support is **first-class**: the skill has 3 modes — `create v1` / `iterate vN+1` / `freeze`. N is unbounded; user decides when freeze happens.
5. Mockups live at `<project>/docs/design/mockups/` with one subfolder per iteration (`v1-YYYY-MM-DD/`, `v2-…/`, …, `final/` pointing to the approved version).
6. No existing project is broken: projects currently in `Definition` or `MVP` continue working without invoking mockup-factory. The new phase only applies when you explicitly transition to it.

**Integration assumptions**
7. `phase-gate-reviewer` is updated to know the new phase. New transitions: `Definition → Prototype`, `Prototype → MVP`. Existing `Definition → MVP` is preserved as "direct skip" with mandatory `--skip-reason` flag.
8. `memory/13-phase-history.md` canonical phase definitions go from 5 to 6 phases. The file itself gets an explanatory entry documenting the taxonomy change.
9. Skill count transitions 21 → 22 (mockup-factory adds one). Command count 13 → 14. Workflow count 6 → 7.
10. No MCP config change required. `mockup-factory` uses the same shadcn MCP + Claude Design that `prototype-designer` uses.

**Open risks / things I might be wrong about**
- **Risk 1:** The phase-gate-reviewer skill file may already have structural references to exactly "5 phases" that break when I add one. I'll inspect it before modifying and adjust in place.
- **Risk 2:** `memory/13-phase-history.md` in APP ARMARIO already has an entry referring to the 5-phase model. When syncing, APP ARMARIO keeps its memory file intact (blacklisted), so the taxonomy change reaches APP ARMARIO only via rule/skill/workflow updates, not via memory/13 content. I'll note this in the docs.
- **Risk 3:** The user might want the skill to auto-deploy the mockup/ to a preview URL (Vercel for web, Expo EAS Update for mobile). I'm **not** doing that in this plan — the skill stops at producing the navigable mockup locally + giving handoff instructions. Deploy is out of scope and can be a follow-up.

If any of these assumptions is wrong, stop me here.

---

## 1. Scope

**What this plan covers:**
- Promote `Prototype` to a canonical MASTERMIND phase (6th phase, between Definition and MVP).
- Build the `mockup-factory` skill (System 1, Design & Prototyping sub-bucket) with 3 modes and platform-awareness.
- Build the `/mm-mockup` slash command wrapping the skill.
- Build the `07-full-app-prototyping` workflow documenting the end-to-end process.
- Update `phase-gate-reviewer` to know the new phase and its transitions.
- Update all documentation surfaces where phases / counts are mentioned.

**What it does not cover (explicit non-goals):**
- Auto-deploy of the mockup to Vercel / EAS. Out of scope.
- A parallel "feature-level prototype" redesign. `prototype-designer` stays as-is and remains the right tool for single-feature prototypes; `mockup-factory` is for full-app, pre-MVP.
- Migration of existing APP ARMARIO memory/13 to the 6-phase model. That's a project-level task the user does manually if/when relevant.
- Tests for the scripts (none are being added). The existing `sync-from-template` smoke tests are enough.

## 2. Success criteria

The plan is successfully executed when ALL of the following are true:

1. New files exist and are valid:
   - `.cursor/skills/mockup-factory/SKILL.md` (canonical)
   - `.claude/skills/mockup-factory/SKILL.md` (mirror, via sync)
   - `.claude/commands/mm-mockup.md`
   - `.claude/workflows/07-full-app-prototyping.md`
2. Modified files are consistent:
   - `memory/13-phase-history.md` canonical phase definitions list **6 phases** (Idea, Discovery, Definition, Prototype, MVP, Iteration, Launch — wait, that's 7; recount: Idea, Discovery, Definition, **Prototype**, MVP, Iteration, Launch = 7 phases. Actually: Idea → Discovery → Definition → MVP → Iteration → Launch was **6 phases**, not 5. Inserting Prototype makes it **7**.).  
     **Correction to my assumption above:** current state is 6 phases. After this plan, 7 phases. Verified by reading memory/13.
   - `phase-gate-reviewer/SKILL.md` documents transitions `Definition → Prototype` and `Prototype → MVP` + skip rule.
   - `04-phase-gate-transition.md` workflow lists the 7 phases.
   - `06-execution-modes.mdc` mentions of the phase chain reflect 7 phases.
   - `skill-creator/SKILL.md` count is **22 skills** (was 21).
   - `memory-updater/SKILL.md` "Invoked by" list includes `mockup-factory`.
   - `CLAUDE.md`, `README.md`, `COMMANDS.md`, `OPERATING-GUIDE.md` reflect the updated counts (22 skills, 14 commands, 7 workflows) and the new phase in lifecycle diagrams.
   - `.claude/workflows/README.md` and `.claude/commands/README.md` have the new rows.
3. `scripts/sync-skills.ps1 -Check` returns zero pending changes.
4. `memory/07-decisions-log.md` has a new entry at the top documenting this architectural decision.
5. Git commit created with descriptive message, pushed to `origin/main`.
6. No breaking changes: `sync-from-template` dry-run against APP ARMARIO from the template root still shows only additive changes (nothing the script would mark as a conflict for an existing project).

## 3. File map

**CREATED (4 files):**
- `.cursor/skills/mockup-factory/SKILL.md` — ~300 lines, platform-aware skill
- `.claude/skills/mockup-factory/SKILL.md` — auto-generated via sync-skills
- `.claude/commands/mm-mockup.md` — ~60 lines, 5 subcommands
- `.claude/workflows/07-full-app-prototyping.md` — ~220 lines, 10 internal phases

**MODIFIED (~12 files):**
- `memory/13-phase-history.md` — add `Prototype` to canonical phase definitions, add entry about taxonomy change
- `.cursor/skills/phase-gate-reviewer/SKILL.md` — add Prototype transitions + skip rule
- `.claude/skills/phase-gate-reviewer/SKILL.md` — synced
- `.claude/workflows/04-phase-gate-transition.md` — update phase list
- `.cursor/rules/06-execution-modes.mdc` — update phase-chain mentions
- `.cursor/skills/skill-creator/SKILL.md` — skill count 21→22, new sub-bucket entry
- `.claude/skills/skill-creator/SKILL.md` — synced
- `.cursor/skills/memory-updater/SKILL.md` — add mockup-factory to callers
- `.claude/skills/memory-updater/SKILL.md` — synced
- `CLAUDE.md` — skill count
- `README.md` — lifecycle diagram, counts, mockup-factory section
- `COMMANDS.md` — count in header, new row, new section
- `OPERATING-GUIDE.md` — phases, skills appendix, workflows appendix, commands appendix
- `.claude/workflows/README.md` — new row
- `.claude/commands/README.md` — new row
- `memory/07-decisions-log.md` — new entry

Total files touched: ~16.

## 4. Bite-sized tasks

> TDD rhythm where applicable. For skill-authoring / docs work, "test" = structured verification (grep, sync-skills check, count consistency). Every task ≤ 30 minutes of focused work. Verification per task is explicit.

### T1 — Update canonical phase definitions in memory/13 (5–10 min)

**File:** `memory/13-phase-history.md`

**Steps:**
1. Read the current phase definitions section.
2. Insert `Prototype` between `Definition` and `MVP` with:
   - **Definition:** "Iterative design phase. Full-app mockup produced via `mockup-factory` skill; stakeholder feedback processed across v1, v2, …, vN; design frozen when approved. Output: `docs/design/mockups/final/` + memory/14 reflects final tokens/patterns/components. Duration: 1–3 weeks typical, variable by UI complexity."
   - **Entry criteria:** Definition gate passed; memory/14 §Platform set; project has UI. Non-UI projects skip this phase with `phase-gate-reviewer --skip-reason "no UI"`.
   - **Exit criteria:** design frozen (recorded in memory/14 changelog); stakeholder approval noted; mockup artefacts under `docs/design/mockups/final/`.
3. Add an entry at the top of "Transitions" section (historical log):
   ```markdown
   ### 2026-05-03 — Taxonomy change: added `Prototype` phase
   - Canonical phases increased from 6 to 7: Idea, Discovery, Definition, **Prototype**, MVP, Iteration, Launch.
   - Rationale: iterative design (v1 → v2 → … → freeze) is a first-class activity worth its own phase for UI-heavy projects; non-UI projects skip it with justification.
   - Skill: `mockup-factory` (new). Command: `/mm-mockup`. Workflow: `07-full-app-prototyping.md`.
   - Existing projects in Definition or MVP continue without disruption; only explicit transitions to `Prototype` activate the new phase.
   - Linked decision: memory/07-decisions-log.md#2026-05-03-prototype-phase
   ```

**Verification:**
- `grep "Prototype" memory/13-phase-history.md | wc -l` returns ≥ 2 (definition + entry).
- `grep "7 phases\|canonical phases increased from 6 to 7" memory/13-phase-history.md` returns at least 1 match.
- File is valid markdown (no orphan headings).

### T2 — Write the `mockup-factory` skill (40–60 min)

**File:** `.cursor/skills/mockup-factory/SKILL.md` (new)

**Steps:**
1. Create directory `.cursor/skills/mockup-factory/`.
2. Write the skill following the 9-section canonical template (frontmatter + Goal + When to use + When NOT to use + Prerequisites + Process + Outputs + Interactions + Completion checklist + Anti-patterns).
3. Key content:
   - **Frontmatter `description`:** makes clear this is full-app prototyping (distinct from prototype-designer), platform-aware, iterative (3 modes: create/iterate/freeze), outputs to `docs/design/mockups/`.
   - **When to use:** entering Prototype phase after Definition gate passed. User runs `/mm-mockup create`.
   - **When NOT:** single-feature (use prototype-designer instead), non-UI projects, during active MVP build.
   - **Prerequisites:** memory/14 §Platform set; memory/05 flows populated; memory/06 feature-map with MVP slice; `components.json` exists (shadcn installed); Claude Design access.
   - **Process (8 steps):**
     1. Scope & platform detection (read memory/14).
     2. Initialize `docs/design/mockups/` + `v1-YYYY-MM-DD/` structure.
     3. Compose platform-tuned Claude Design prompt for the FULL app (use all flows from memory/05, all MVP features from memory/06, all tokens from memory/14).
     4. User opens Claude Design, links the repo, iterates within Claude Design's canvas.
     5. Export handoff bundle from Claude Design → save under `v1-<date>/handoff-bundle/`.
     6. (Iteration mode) User provides feedback; skill drafts change summary; creates `v2-<date>/` with refined prompt; loop.
     7. (Freeze mode) User approves current version; skill copies to `final/`; updates memory/14 changelog with final tokens/patterns/components; writes entry in memory/13-phase-history.md "Design frozen at vN on YYYY-MM-DD"; recommends `/mm-gate MVP`.
     8. Close with memory-updater.
   - **Outputs:** `docs/design/mockups/<vN>/*`, updates to memory/14, entry in memory/13, entry in memory/07 if tokens changed.
   - **Interactions:** invoked by `/mm-mockup`; consumes outputs of product-requirements + flow-analyzer + feature-breakdown + prototype-designer (if any feature was pre-prototyped); feeds into phase-gate-reviewer (Prototype → MVP); closes with memory-updater.
   - **Completion checklist:** 7–9 boxes covering platform, scope, each mode's output, freeze criteria, memory updates.
   - **Anti-patterns:** skipping the Platform field, treating v1 as final without iteration, committing the mockup HTML/JSX to src/, freezing without stakeholder sign-off, mixing this with single-feature prototyping.

**Verification:**
- File exists; first line is `---` (valid frontmatter).
- `grep -E "^(name|description):" .cursor/skills/mockup-factory/SKILL.md` returns 2 matches.
- `grep "memory/14.*Platform" .cursor/skills/mockup-factory/SKILL.md` returns ≥ 1 match (confirms platform-aware).
- `grep -E "create|iterate|freeze" .cursor/skills/mockup-factory/SKILL.md | wc -l` returns ≥ 3 (confirms 3 modes documented).
- Line count is in the 250–350 range.

### T3 — Write the `/mm-mockup` command (10–15 min)

**File:** `.claude/commands/mm-mockup.md` (new)

**Steps:**
1. Write the command file with:
   - Frontmatter (description pointing to mockup-factory).
   - Subcommands: `create <feature-scope>` | `iterate --feedback "..."` | `feedback` (alias for iterate) | `freeze` | `status`.
   - Precondition checks: Definition phase completed (check memory/02 §Phase); memory/14 §Platform set; memory/05 + memory/06 populated; components.json exists.
   - If preconditions fail, STOP and point to what's missing.
   - Delegate to mockup-factory skill; pass mode + args.

**Verification:**
- File exists.
- `grep -E "(create|iterate|freeze|status)" .claude/commands/mm-mockup.md | wc -l` returns ≥ 4.
- File invokes / points to `.cursor/skills/mockup-factory/SKILL.md`.

### T4 — Write workflow `07-full-app-prototyping.md` (25–35 min)

**File:** `.claude/workflows/07-full-app-prototyping.md` (new)

**Steps:**
1. Structure: frontmatter → Purpose → Preconditions → Phases (8–10 internal phases) → Artefacts → Exit criteria → Invocation → Anti-patterns.
2. Internal phases:
   1. **Scope** — define what's in and out of the mockup (align with MVP from memory/06).
   2. **Setup** — branch aparte (recommended: `mockup/full-app-v1`); create `docs/design/mockups/` if missing.
   3. **Platform check** — confirm memory/14 §Platform; branch web vs mobile path (web = claude.ai/design + Vercel preview; mobile = claude.ai/design + Expo Go).
   4. **v1 generation** — compose prompt, run Claude Design, export bundle to `v1-<date>/`.
   5. **Stakeholder review** — share URL / QR / screenshots. Record feedback in `v1-<date>/feedback.md`.
   6. **Iterate** — feedback → v2 → stakeholder → v3 → … → vN. Each iteration is a `v<N>-<date>/` folder with prompt, bundle, screenshots, feedback.
   7. **Freeze** — user approves. Skill marks `final/` symbol + updates memory/14 changelog + memory/13 entry.
   8. **Handoff** — recommend `/mm-gate MVP`.
   9. **(Optional) Deploy preview** — Vercel / Expo EAS Update for ongoing stakeholder access.
   10. **Close** — memory-updater pass.
3. Reference the skill throughout; don't duplicate its content.

**Verification:**
- File exists.
- Line count 180–250.
- References `mockup-factory` skill at least 3 times.
- Phase list is numbered 1–10 (or 1–9 if optional excluded).

### T5 — Update `phase-gate-reviewer` with new transitions (20–30 min)

**File:** `.cursor/skills/phase-gate-reviewer/SKILL.md`

**Steps:**
1. Read current content.
2. Add section for the two new transitions:
   - **`Definition → Prototype`**
     - Entry criteria: Definition gate passed; memory/14 §Platform set; UI-carrying project (confirmed by user or inferred from package.json).
     - Output: `memory/02-current-state.md` §Phase set to `Prototype`; memory/13 entry "Definition → Prototype on YYYY-MM-DD".
   - **`Prototype → MVP`**
     - Entry criteria: `docs/design/mockups/final/` exists; memory/14 changelog has "Design frozen at vN" entry within the last 30 days; stakeholder approval recorded.
     - Output: memory/02 §Phase set to `MVP`; memory/13 entry "Prototype → MVP on YYYY-MM-DD".
3. Add **skip rule**: projects without UI can jump `Definition → MVP` directly when invoking `/mm-gate MVP` with `--skip-reason "no UI"`. The skill records the skip justification in memory/13 + memory/07.
4. Update phase enumeration wherever it lists the canonical sequence.

**Verification:**
- `grep "Definition → Prototype\|Prototype → MVP" .cursor/skills/phase-gate-reviewer/SKILL.md` returns ≥ 2 matches.
- `grep "skip-reason\|skip_reason\|no UI" .cursor/skills/phase-gate-reviewer/SKILL.md` returns ≥ 1 match.
- Sync-skills later will propagate to mirror.

### T6 — Update workflow `04-phase-gate-transition` (10 min)

**File:** `.claude/workflows/04-phase-gate-transition.md`

**Steps:**
1. Update the phase enumeration to 7 phases.
2. Add short note: "for UI projects, Definition → Prototype → MVP is the default; non-UI projects may skip with justification".

**Verification:**
- `grep "Prototype" .claude/workflows/04-phase-gate-transition.md | wc -l` returns ≥ 2.

### T7 — Update rule `06-execution-modes.mdc` (5–10 min)

**File:** `.cursor/rules/06-execution-modes.mdc`

**Steps:**
1. Search for any explicit chain `Idea → Discovery → Definition → MVP → Iteration → Launch`.
2. Update to `Idea → Discovery → Definition → Prototype → MVP → Iteration → Launch`.
3. If the rule enumerates phases as a list, insert `Prototype` between Definition and MVP.

**Verification:**
- `grep "Prototype" .cursor/rules/06-execution-modes.mdc | wc -l` returns ≥ 1.
- Old 6-phase chain no longer present (grep for old chain returns 0 matches).

### T8 — Update skill registries: skill-creator + memory-updater (15 min)

**Files:** `.cursor/skills/skill-creator/SKILL.md`, `.cursor/skills/memory-updater/SKILL.md`

**Steps:**
1. `skill-creator/SKILL.md`:
   - Update skill count: 21 → 22.
   - Add `mockup-factory` to the "System 1 — Design & prototyping" sub-bucket (alongside `prototype-designer`).
2. `memory-updater/SKILL.md`:
   - Add `mockup-factory` to the "Invoked as the finishing step by" list.
   - Add note: memory-updater writes to `memory/14 §Changelog` and `memory/13 §Transitions` when invoked by mockup-factory in freeze mode.

**Verification:**
- `grep "22 skills\|Total: \*\*22" .cursor/skills/skill-creator/SKILL.md | wc -l` returns ≥ 1.
- `grep "mockup-factory" .cursor/skills/skill-creator/SKILL.md | wc -l` returns ≥ 1.
- `grep "mockup-factory" .cursor/skills/memory-updater/SKILL.md | wc -l` returns ≥ 1.

### T9 — Update workflow/commands README indexes (5–10 min)

**Files:** `.claude/workflows/README.md`, `.claude/commands/README.md`

**Steps:**
1. Workflows README: add row `| 07 | 07-full-app-prototyping.md | Full-app iterative mockup before MVP gate. | 1–3 weeks typical | Definition exit → MVP entry |`.
2. Commands README: add row `| /mm-mockup | mockup-factory skill | Full-app prototype with iteration (create/iterate/freeze/status). |`.

**Verification:**
- `grep "07-full-app-prototyping\|mm-mockup" .claude/workflows/README.md .claude/commands/README.md | wc -l` returns ≥ 2.

### T10 — Update root docs (CLAUDE, README, COMMANDS, OPERATING-GUIDE) (30–40 min)

**Files:** `CLAUDE.md`, `README.md`, `COMMANDS.md`, `OPERATING-GUIDE.md`

**Steps:**
1. `CLAUDE.md`:
   - Update skill count (21 → 22) wherever it appears.
2. `README.md`:
   - Update lifecycle diagram to include Prototype.
   - Update final map counts: 22 skills, 14 commands, 7 workflows.
   - Add paragraph to the Design + Prototyping section differentiating mockup-factory (full-app, pre-MVP) from prototype-designer (single feature).
3. `COMMANDS.md`:
   - Header count (13 → 14).
   - Add row for `/mm-mockup` in the table.
   - Add a dedicated section for `/mm-mockup` (the canonical description).
4. `OPERATING-GUIDE.md`:
   - Update phase count references (6 → 7).
   - Add `mockup-factory` to the Design & Prototyping sub-bucket in the skills appendix.
   - Add workflow 07 to the workflows appendix.
   - Add `/mm-mockup` to the commands appendix.
   - Update lifecycle mentions (several places in the guide enumerate phases).

**Verification:**
- Grep for old skill count "21 skills" across root docs → 0 matches.
- Grep for "22 skills" across root docs → ≥ 3 matches (CLAUDE, README, OPERATING-GUIDE, skill-creator).
- Grep for "14 commands" → ≥ 2 matches.
- Grep for "7 workflows" → ≥ 2 matches.
- Grep for "Prototype" in README.md and OPERATING-GUIDE.md → ≥ 3 matches each.

### T11 — Write entry in decisions log (10 min)

**File:** `memory/07-decisions-log.md`

**Steps:**
1. Prepend a new entry at the top (above the 2026-05-03 platform-aware entry):
   ```markdown
   ### 2026-05-03 — Added Prototype phase + mockup-factory skill (iterative full-app design before MVP)
   - Decision: ...
   - Reason: ...
   - Alternatives considered: ...
   - Consequences: ...
   - Files affected: ...
   - Supersedes: none.
   ```
2. Fill with full content referencing: 3 options considered, user chose Option 1 explicitly due to "always iterates 2–5 times", architectural impact (5 → 6 → 7 phases corrected), skill philosophy (3 modes), platform-awareness from day 1.

**Verification:**
- `grep "2026-05-03 — Added Prototype phase" memory/07-decisions-log.md` returns 1 match.
- Entry has all required fields (Decision / Reason / Alternatives considered / Consequences / Files affected).

### T12 — Sync skills (2 min)

**Command:** `pwsh -File scripts/sync-skills.ps1`

**Expected result:** 1 NEW (mockup-factory) + 3 CHANGED (skill-creator, memory-updater, phase-gate-reviewer) = 4 file changes synced to `.claude/skills/`.

**Verification:**
- `pwsh -File scripts/sync-skills.ps1 -Check` returns "OK: in sync" with 22 unchanged files.

### T13 — Smoke tests (10 min)

**Steps:**
1. Verify skill counts consistency across sources:
   ```powershell
   Select-String -Path CLAUDE.md, README.md, COMMANDS.md, OPERATING-GUIDE.md, `
       .cursor/skills/skill-creator/SKILL.md -Pattern "22 skills" `
       -SimpleMatch | Measure-Object
   ```
   Expected: ≥ 4 matches.
2. Verify command count:
   ```powershell
   Select-String -Path COMMANDS.md -Pattern "14 slash commands"
   ```
   Expected: ≥ 1 match.
3. Verify workflow count:
   ```powershell
   Select-String -Path README.md, OPERATING-GUIDE.md -Pattern "7 workflows"
   ```
   Expected: ≥ 2 matches.
4. Verify no old-phase-chain references linger:
   ```powershell
   Select-String -Path . -Pattern "Idea → Discovery → Definition → MVP → Iteration → Launch" -SimpleMatch -Recurse
   ```
   Expected: 0 matches (all updated to include Prototype).
5. Verify mockup-factory file sanity:
   ```powershell
   Get-ChildItem .cursor/skills/mockup-factory/SKILL.md, .claude/skills/mockup-factory/SKILL.md
   ```
   Expected: both exist, comparable sizes.
6. Verify phase-gate-reviewer references new transitions:
   ```powershell
   Select-String -Path .cursor/skills/phase-gate-reviewer/SKILL.md -Pattern "Definition → Prototype|Prototype → MVP"
   ```
   Expected: ≥ 2 matches.

### T14 — Commit + push (5 min)

**Steps:**
1. `git status --short` → verify only expected files changed.
2. `git add -A -- ":!.commit-msg.tmp"` (exclude any tmp).
3. Commit with the structured message (draft in T11 entry; mirror it).
4. `git push origin main`.

**Verification:**
- `git log -1 --oneline` shows the new commit.
- `git status` is clean.
- Push returns success (remote ref updated).

---

## 5. Self-review checklist

Before handing off for execution:

- [x] **Coverage** — all 16 affected files listed in File Map are addressed in tasks T1–T11 ✓
- [x] **Placeholders** — every step has exact file path and concrete content; no `TODO`, no `<fill in>` ✓
- [x] **Types / references** — all cross-references between skills, rules, memory, workflows are explicit and bi-directionally verifiable ✓
- [x] **Error paths** — skip rule for non-UI projects documented (T5); taxonomy change documented so future readers understand 6→7 phases (T1) ✓
- [x] **Test-first where applicable** — for skill-authoring work, "test" = grep/verification command per task; for sync work, sync-skills -Check is the gate ✓
- [x] **Size** — tasks are 5–60 min each; total executable in 3–4h of focused work; safe for one session ✓
- [x] **Dependencies / order** — T1 (taxonomy) is foundation; T2/T3/T4 (new artefacts) depend on T1 being conceptually settled but not on its file being written; T5 depends on T1 conceptually; T8/T9/T10 depend on T2/T3/T4 existing; T12 depends on T2/T5/T8; T13 depends on all prior; T14 is last ✓
- [x] **Non-breaking** — no existing project forced to adopt the new phase; skip rule preserves backward compat ✓

## 6. Execution handoff — pick an option

How do you want me to proceed? Pick A–E.

**A — Full execution now, one commit at the end.** I execute T1 through T14 in sequence, with no intermediate commits. One large `feat(design): add Prototype phase + mockup-factory` commit at the end. Coherent, atomic. **Recommended for taxonomy changes — consistency matters.**

**B — Progressive commits.** I commit after T4 (new files in place but phase-gate-reviewer not yet aware), another commit after T10 (all docs consistent), and a final commit after T14. 3 commits instead of 1; gives you review points. Downside: intermediate states are architecturally inconsistent (skill exists but gate-reviewer doesn't know about it).

**C — Construction only; you commit.** I do T1–T13, you verify locally, you run T14 (git add / commit / push) yourself. I emit the exact command to use. Good if you want final control over the commit moment.

**D — Pause after T4 for review.** I execute T1 through T4 (taxonomy + skill + command + workflow). I show you the skill file for review. If approved, I continue T5–T14 in the same session; otherwise we iterate on the skill first.

**E — Sub-slice first: skill only.** I execute **only T2 + T3 + T4** (skill + command + workflow), no taxonomy changes yet, no phase-gate-reviewer changes. Commit and push. You try the skill in a project; if it works well, we do the taxonomy + gate integration in a separate session. Lower risk, slower rollout, temporarily inconsistent (skill exists but system doesn't yet treat Prototype as a phase).

**My recommendation:** **Option A.** Taxonomy changes belong in one atomic commit. Breaking the integration across commits leaves the repo in inconsistent states that confuse future-you (or your agents) reading git log.

---

## 7. Compatibility note (task-master-ai)

Not installed in this template. If a future project installs `task-master-ai`, the tasks T1–T14 above map cleanly to individual tasks; each task's verification command is a good "done" criterion. No plan-format adjustment needed.

## 8. Decision log reference

After execution, T11 will write the canonical decision entry in `memory/07-decisions-log.md`. This plan file (`.cursor/plans/2026-05-03-add-prototype-phase-and-mockup-factory.md`) should be referenced from that entry for traceability.

## 9. Memory-updater handoff

After T14, memory-updater runs:
- Append session summary to `memory/11-session-summary.md` (not done yet in this session; will be done at end of current conversation).
- Confirm memory/07 entry is present (T11).
- Confirm memory/13 entry is present (T1).
- Flag cross-project lesson candidate: *"For UI-heavy projects, a dedicated Prototype phase with iteration support materially improves design fidelity before MVP build starts."* → candidate for promotion to `~/.mastermind/global/lessons.md` via `continuous-learner`.

---

**STOP HERE. Pick A / B / C / D / E in the chat and I'll execute.**
