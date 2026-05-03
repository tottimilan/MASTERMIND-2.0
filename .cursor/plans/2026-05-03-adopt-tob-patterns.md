# Adopt Trail of Bits Patterns — Implementation Plan (Plan B)

**Date:** 2026-05-03
**Branch:** `feat/adopt-tob-patterns`
**Author:** User + Claude Opus 4.7 (Cursor)
**Status:** Draft
**Predecessor:** Plan A `build-skill-quality-evaluator` (merged to `main` as `e012a5e`)

## Goal

Absorb 3 cherry-picked patterns from the Trail of Bits skills marketplace into 3 existing MASTERMIND skills (`code-reviewer`, `project-deep-audit`, `security-review`), and fix the 1 real bug surfaced by `skill-quality-evaluator` baseline (`prototype-designer` description >1024 chars). Use the evaluator as the before/after measuring stick; no skill may regress its score.

This is the first dog-food validation of the new evaluator and the first execution of the cherry-pick strategy from `research/03-trail-of-bits-skills.md` §Veredicto.

## Architecture

Pure documentation work on existing `.cursor/skills/<name>/SKILL.md` files. No new skills, no new scripts, no runtime changes. Each absorption is a targeted insertion (new H3 subsection, ~20-50 lines of prose) with explicit source attribution to Trail of Bits and a citation to `research/03-trail-of-bits-skills.md`. Mirror synced after edits via `scripts/sync-skills.ps1`. Re-baseline captured at `.cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt` for diff-vs-Plan-A comparison.

## Tech Stack touched

- **No code.** Pure SKILL.md edits.
- **Verification:** `skill-quality-evaluator` (already merged on `main`).
- **Sync:** `scripts/sync-skills.ps1`.

## Success criteria (observable)

- [ ] `prototype-designer` description ≤1024 chars (was 1199).
- [ ] `prototype-designer` evaluator score = 100/100 (was 75/100, EMPTY_DESCRIPTION resolved).
- [ ] `code-reviewer` Step 3 contains a new H3 "**12. Blast radius**" with definition + example + ToB attribution.
- [ ] `code-reviewer` evaluator score = 100/100 (was 100; no regression).
- [ ] `project-deep-audit` Step 2 has a new subsection "First Principles + 5 Whys (per-angle methodology)" applicable to angles 1 and 7.
- [ ] `project-deep-audit` evaluator score = 100/100 (was 100; no regression).
- [ ] `security-review` has a new H3 between Steps 5 and 6: "Insecure Defaults checklist" + "Rationalizations to Reject" with concrete bullet lists and ToB attribution.
- [ ] `security-review` evaluator score = 100/100 (was 100; no regression).
- [ ] New baseline at `.cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt` shows average ≥ 98.0 (was 97.5; +0.5 expected from prototype-designer fix alone).
- [ ] `pwsh -File scripts/sync-skills.ps1 -Check` exit code 0 after all edits.
- [ ] `memory/07-decisions-log.md` has new entry dated 2026-05-03 attributing the patterns to Trail of Bits with concrete repo URLs.
- [ ] `memory/02-current-state.md` reflects "Plan B complete; Plan B → Plan C TBD".
- [ ] No skill exceeds 500 body lines after insertion (no BLOATED_SKILL introduced).

## Files

| Action | Path | Purpose |
|---|---|---|
| Modify | `.cursor/skills/prototype-designer/SKILL.md` (frontmatter only, lines 1-3) | Trim description from 1199 → ≤900 chars while preserving platform-aware semantics. |
| Modify | `.cursor/skills/code-reviewer/SKILL.md` (Step 3 categories) | Insert "12. Blast radius" as new H3 subsection. |
| Modify | `.cursor/skills/project-deep-audit/SKILL.md` (Step 2 multi-angle table) | Insert "First Principles + 5 Whys (per-angle methodology)" subsection. |
| Modify | `.cursor/skills/security-review/SKILL.md` (between Steps 5 and 6) | Insert "Insecure Defaults checklist + Rationalizations to Reject" as new H3 (Step 5b). |
| Create | `.cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt` | Snapshot of evaluator scores after all 4 edits, for diff vs Plan A baseline. |
| Modify | `memory/07-decisions-log.md` (append) | Decision: pattern attributions, alternatives considered (full ToB install), consequences. |
| Modify | `memory/02-current-state.md` | Plan B → Done; next = heuristic calibration v1.1 or new direction. |

Total: **5 modified + 1 created** source files + mirror via sync. Within 8-file budget.

---

## Task 1 — Fix `prototype-designer` description (real bug)

**Files touched:**
- Modify: `.cursor/skills/prototype-designer/SKILL.md` (frontmatter, lines 2-3)

**Justification:** First because it's the only Critical finding in the baseline (-25 points). Surgical, isolated, validates the evaluator before any subjective absorption.

### Steps

- [ ] **Step 1.1** — Verify baseline before edit.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/prototype-designer`
  **Expected:** `Score: 75/100`, finding `EMPTY_DESCRIPTION` (length 1199).

- [ ] **Step 1.2** — Edit the description in frontmatter. Replace the current 1199-char single-line block with a tighter version preserving:
  - Platform-aware semantics (web shadcn/ui vs mobile react-native-reusables).
  - Memory consumption (memory/05, memory/06, memory/14).
  - Output destination (`docs/design/prototypes/<feature>/`).
  - Trigger keywords ("prototype this", "design this feature", "let's mock it up", "mm-design", "use when").
  - Prerequisite (Claude Design + design system installed).

  Target length: **800–900 chars** (margin under 1024 for future minor edits without re-tripping the limit).

  Suggested rewrite (≈850 chars):

  ```yaml
  description: Platform-aware bridge from MASTERMIND memory to Claude Design (claude.ai/design) for interactive prototyping. Branches between web (shadcn/ui + Tailwind) and mobile (react-native-reusables + NativeWind + Expo) based on memory/14-design-system.md §Platform. Consumes memory/05-user-flows, memory/06-feature-map, memory/14-design-system; composes a platform-tuned Claude Design prompt; guides the round-trip (open Claude Design, link repo, iterate, export); saves the bundle under docs/design/prototypes/<feature>/; extracts decisions back into memory/14. Use between product-requirements/flow-analyzer and implementation-planner, or when the user says "prototype this", "design this feature", "let's mock it up", "mm-design". Requires the design system installed via scripts/install-shadcn-mcp and a Claude subscription with Claude Design access.
  ```

  Char count target: 873.

  **Run:** `(Get-Content .cursor/skills/prototype-designer/SKILL.md -Raw -Encoding UTF8) -match '(?s)description:\s*(.+?)\r?\n---' | Out-Null; $matches[1].Trim().Length`
  **Expected:** ≤ 1024 (target ~870).

- [ ] **Step 1.3** — Re-evaluate.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/prototype-designer`
  **Expected:** `Score: 100/100`, no findings.

- [ ] **Step 1.4** — Commit.

  **Run:**
  ```powershell
  git checkout -b feat/adopt-tob-patterns
  git add .cursor/skills/prototype-designer/SKILL.md
  git commit -m "fix(skill:prototype-designer): trim description to fit 1024-char limit (1199 -> ~870)"
  ```
  **Expected:** branch + commit created.

---

## Task 2 — Absorb "Blast radius analysis" into `code-reviewer`

**Files touched:**
- Modify: `.cursor/skills/code-reviewer/SKILL.md` (Step 3 — Review categories)

**Source:** Trail of Bits `differential-review` skill (https://github.com/trailofbits/skills/tree/main/differential-review). Pattern documented in `research/03-trail-of-bits-skills.md` §Code Auditing.

**What it adds:** A 12th review category that asks "if this change ships and breaks, what else breaks with it?" — explicitly mapping the change's blast radius (callers, dependents, downstream services, persisted data, cached state, external integrations). Currently `code-reviewer` has 11 categories (Plan compliance, Scope discipline, Correctness, Tests, Architecture fit, Quality, Performance, Readability, Simplicity, Documentation, Git hygiene). Blast radius is the 12th.

### Steps

- [ ] **Step 2.1** — Verify baseline.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/code-reviewer`
  **Expected:** `Score: 100/100`, no findings.

- [ ] **Step 2.2** — Insert new H3 after the existing "11. Git hygiene" line in Step 3, before "### Step 4 — Categorize every issue by severity". Use this exact prose (~30 lines):

  ```markdown
  12. **Blast radius (adapted from Trail of Bits `differential-review`)** — if this change ships and a regression appears, what else breaks? Map the dependency graph for the changed lines:

      - **Direct callers** — every function, route, job, or test that imports / invokes the changed code. List them or flag if too many to enumerate (signal of high blast radius).
      - **Persisted state touched** — DB columns written, cache keys invalidated, files in storage, queue messages emitted. Each is a new failure surface.
      - **External integrations affected** — third-party APIs called with new parameters, webhooks emitted with new payload shapes, SDK upgrades that change wire format.
      - **Data already in production** — does the change require migration of existing rows / files / cache entries? If yes, the change is implicitly a 2-step deploy (migration first, then code).
      - **Reversibility** — can this change be reverted with a single `git revert` in <5 minutes if it breaks production? If no, what's the rollback procedure?

      Write the blast radius as 3-6 bullets. A change with one-bullet blast radius is low-risk; six bullets is "open follow-up issue, schedule monitoring".

      Source: pattern adapted from [trailofbits/skills `differential-review`](https://github.com/trailofbits/skills/tree/main/differential-review). See `research/03-trail-of-bits-skills.md` for evaluation context.
  ```

- [ ] **Step 2.3** — Re-evaluate.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/code-reviewer`
  **Expected:** `Score: 100/100`, no findings (no regression). If `BLOATED_SKILL` appears (>500 body lines), refactor: move blast-radius detail into `references/blast-radius.md` and keep a 3-line pointer in the SKILL.md.

- [ ] **Step 2.4** — Commit.

  **Run:**
  ```powershell
  git add .cursor/skills/code-reviewer/SKILL.md
  git commit -m "feat(skill:code-reviewer): absorb 'blast radius' pattern from ToB differential-review"
  ```

---

## Task 3 — Absorb "First Principles + 5 Whys" into `project-deep-audit`

**Files touched:**
- Modify: `.cursor/skills/project-deep-audit/SKILL.md` (Step 2 — Multi-angle analysis)

**Source:** Trail of Bits `audit-context-building` skill (https://github.com/trailofbits/skills/tree/main/audit-context-building). Pattern: structured line-by-line analysis using First Principles ("what is the irreducible problem?") + 5 Whys ("why does this exist? why this way? why now?") to build deep understanding of unfamiliar code/systems before forming an opinion.

**What it adds:** A per-angle methodology block under Step 2 that applies specifically to angles 1 (First principles) and 7 (Technical architecture) — the two angles most prone to "I scanned it, now I have an opinion" failure mode.

### Steps

- [ ] **Step 3.1** — Verify baseline.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/project-deep-audit`
  **Expected:** `Score: 100/100`, no findings.

- [ ] **Step 3.2** — Insert a new subsection at the end of Step 2 (after the 12-angle table, before "### Step 3 — Synthesize the executive summary"). Use this exact prose (~35 lines):

  ```markdown
  ### Per-angle methodology — First Principles + 5 Whys

  Required for **angles 1 (First principles)** and **7 (Technical architecture)**. Recommended for **angles 5 (Business model)** and **10 (Risks)**. Adapted from Trail of Bits `audit-context-building`.

  For each angle in scope:

  1. **State the system as you currently understand it** in 1-3 sentences. No hedging, no caveats — your honest current model.
  2. **First principles pass** — what's the irreducible problem this system solves? Strip every implementation detail and write the problem in 1 sentence as if explaining to someone who has never seen software. If the irreducible problem isn't crisp, the rest of the audit will be vague.
  3. **5 Whys** — ask "why?" five times in sequence:
     - Why does the system work the way it does today? (mechanism)
     - Why was it built that way and not another way? (history / constraint)
     - Why is the original constraint still valid? (or: when did it stop being valid?)
     - Why hasn't anyone changed it? (organizational / cost / risk)
     - Why might that need to change in the next 6-12 months? (forward pressure)
  4. **Output** — 5 bullets per angle, each one a finding tagged "current model | irreducible problem | why-N | forward pressure". Add to the angle's destination file under a "## First-principles trace" subsection.

  This methodology is intentionally slower than scanning. Use it only when the angle is high-stakes (architecture decisions, pivots, risks). For inventory-style angles (8 Feature inventory, 11 Security surface), a scan + table is sufficient.

  Source: pattern adapted from [trailofbits/skills `audit-context-building`](https://github.com/trailofbits/skills/tree/main/audit-context-building). See `research/03-trail-of-bits-skills.md` for evaluation context.
  ```

- [ ] **Step 3.3** — Re-evaluate.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/project-deep-audit`
  **Expected:** `Score: 100/100`, no findings.

- [ ] **Step 3.4** — Commit.

  **Run:**
  ```powershell
  git add .cursor/skills/project-deep-audit/SKILL.md
  git commit -m "feat(skill:project-deep-audit): absorb 'First Principles + 5 Whys' from ToB audit-context-building"
  ```

---

## Task 4 — Absorb "Insecure Defaults checklist + Rationalizations to Reject" into `security-review`

**Files touched:**
- Modify: `.cursor/skills/security-review/SKILL.md` (between Steps 5 and 6)

**Source:**
- Insecure Defaults checklist → Trail of Bits `insecure-defaults` skill (https://github.com/trailofbits/skills/tree/main/insecure-defaults).
- Rationalizations to Reject → from Trail of Bits' own SKILL.md authoring CLAUDE.md (`Rationalizations to Reject` is a documented section pattern in their security-skill template).

**What it adds:** Two new artifacts in `security-review`:
1. A concrete checklist of 12-15 insecure-default patterns to scan for during every review (currently `security-review` has OWASP-informed checks at Step 3 but no explicit "common insecure defaults" list).
2. A "Rationalizations to Reject" section listing the most common shortcuts a developer (or AI) uses to dismiss a security finding — with a script of how to push back.

### Steps

- [ ] **Step 4.1** — Verify baseline.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/security-review`
  **Expected:** `Score: 100/100`, no findings.

- [ ] **Step 4.2** — Insert new H3 "Step 5b" between current Step 5 (Findings with severity) and Step 6 (Accepted risks). Use this exact prose (~50 lines):

  ```markdown
  ### Step 5b — Insecure defaults checklist + Rationalizations to Reject

  Two artifacts adapted from Trail of Bits security skills (`insecure-defaults` + their security-skill authoring template).

  #### Insecure defaults — scan every review for these

  Patterns where the framework / language / library default is unsafe and a deliberate override is required:

  - **Auth & sessions** — session cookies without `Secure` / `HttpOnly` / `SameSite=Lax`+; JWT with `alg: none` permitted; refresh tokens stored in localStorage; password reset tokens without expiry.
  - **CORS** — `Access-Control-Allow-Origin: *` on any authenticated endpoint; `Access-Control-Allow-Credentials: true` paired with reflected origin.
  - **CSRF** — state-changing endpoints without CSRF tokens or SameSite cookie protection.
  - **Database** — connection strings with passwords in URL (vs env / secret manager); ORM defaults that disable prepared statements; soft-delete that leaves PII in disk forever.
  - **HTTP client defaults** — `verify=False` / `rejectUnauthorized: false`; no timeout (unbounded hang); follow-redirects without scheme validation (HTTP→file://).
  - **File handling** — temp files with default umask; uploads stored under web root; filename used as path without sanitization.
  - **Logging** — request bodies / cookies / Authorization headers logged in full; PII written to stdout in production.
  - **Secrets** — credentials checked into `.env.example`; CI secrets exposed to PR builds from forks; `.env` not in `.gitignore`.
  - **Dev hooks left on** — debug routes (`/debug`, `/admin/dev`) reachable in production; `DEBUG=True` in framework; verbose stack traces returned to clients.
  - **Crypto** — random number generation via `Math.random()` / `random.random()` for security-sensitive values; MD5 / SHA1 for passwords or token derivation; hardcoded IVs.
  - **Container / deploy** — running as root; `latest` tag in production manifests; secrets baked into image layers.
  - **Dependencies** — direct deps without lockfile pinning; transitive deps not audited; `npm install` instead of `npm ci` in CI.
  - **Fail-open** — auth middleware that returns 200 on internal error; rate limit that opens on cache miss; feature flag that defaults to "enabled if check fails".

  Each match in the diff is at least an Important finding. Multiple matches together are usually Critical (defense-in-depth has been bypassed).

  #### Rationalizations to Reject

  When a developer (or AI agent) tries to dismiss a security finding with one of these phrases, the reviewer must push back rather than accept:

  | Rationalization | Reality |
  |---|---|
  | *"This endpoint is internal-only."* | Internal services get exposed accidentally; tunnels, port-forwards, and misconfigured ingresses happen. Defense in depth applies. |
  | *"Only admins use it."* | Admin accounts get phished; insider threats exist; admin tooling is the highest-value target for an attacker. |
  | *"We trust our users."* | Trust is not a security control. It's also not transitive (a trusted user's account can be compromised). |
  | *"Nobody knows the URL."* | Security through obscurity is not security. URLs leak via referer headers, error pages, browser history, screen shares. |
  | *"It's behind a firewall."* | Lateral movement is the norm in 2026. Once one machine is in, the firewall stops mattering. |
  | *"The framework handles that."* | Maybe. Verify with the docs of the version you actually deploy. Versions matter. |
  | *"We'll fix it in v2."* | v2 ships when it ships. The vulnerability ships now. Choose: fix or accept the risk in `memory/08-known-risks.md` with expiry. |
  | *"Adding rate-limit / validation / encryption would slow things down."* | Quantify the slowdown. If the answer is hand-wavy, the trade-off has not been thought through. |
  | *"This is just a prototype."* | Prototypes leak. Prototypes get deployed by mistake. Either keep it on a kill-switched route, or harden it. |
  | *"It's the same as how X does it."* | X may also be vulnerable. Independent justification required. |

  Output: when the developer's response to a finding matches one of the above, document both (the finding, the rationalization) in the review verdict; the response template lives in this table.

  Source: `insecure defaults` checklist adapted from [trailofbits/skills `insecure-defaults`](https://github.com/trailofbits/skills/tree/main/insecure-defaults); `Rationalizations to Reject` table adapted from Trail of Bits skill-authoring conventions (`trailofbits/skills/CLAUDE.md` §Security Skills). See `research/03-trail-of-bits-skills.md` for evaluation context.
  ```

- [ ] **Step 4.3** — Re-evaluate.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/security-review`
  **Expected:** `Score: 100/100`, no findings. If `BLOATED_SKILL` appears, move the Insecure Defaults checklist into `.cursor/skills/security-review/references/insecure-defaults-checklist.md` and keep a pointer.

- [ ] **Step 4.4** — Commit.

  **Run:**
  ```powershell
  git add .cursor/skills/security-review/SKILL.md
  git commit -m "feat(skill:security-review): absorb 'insecure defaults' + 'rationalizations to reject' from ToB"
  ```

---

## Task 5 — Re-baseline + memory + sync

**Files touched:**
- Create: `.cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt`
- Modify: `memory/07-decisions-log.md` (append)
- Modify: `memory/02-current-state.md`
- Modify (via sync): `.claude/skills/**` mirror

### Steps

- [ ] **Step 5.1** — Capture post-Plan-B baseline.

  **Run:**
  ```powershell
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All `
      | Tee-Object -FilePath .cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt
  ```
  **Expected:** `Skills evaluated: 22`, `Average score: ≥ 98.0` (was 97.5; +0.5 expected from prototype-designer fix alone, possibly +0.7 if no skills regress).

- [ ] **Step 5.2** — Append delta notes to the new baseline file:

  ```
  ===== Notes (manual, post-Plan-B baseline) =====

  Plan A baseline (2026-05-03):
    Average: 97.5/100
    Worst: prototype-designer 75/100 (EMPTY_DESCRIPTION)
           retroactive-documenter 85/100 (MISSING_TRIGGER false positive)
           phase-gate-reviewer    85/100 (MISSING_TRIGGER false positive)

  Plan B baseline (2026-05-03 after ToB absorption):
    Average: <FROM Step 5.1>
    Delta: <+0.X>
    Resolved: prototype-designer EMPTY_DESCRIPTION fixed (75 -> 100)
    Unchanged (intentional, calibration-deferred):
      retroactive-documenter MISSING_TRIGGER false positive
      phase-gate-reviewer    MISSING_TRIGGER false positive

  Plan B absorptions (no regression):
    code-reviewer:        100/100 (Blast radius added)
    project-deep-audit:   100/100 (First Principles + 5 Whys added)
    security-review:      100/100 (Insecure Defaults + Rationalizations added)
  ```

  **Run:** `Add-Content .cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt -Value <bloque arriba>` con valores reales sustituidos.

- [ ] **Step 5.3** — Append entry to `memory/07-decisions-log.md`:

  ```markdown

  ### 2026-05-03 — Plan B `adopt-tob-patterns` executed (3 ToB patterns absorbed + 1 real bug fixed)
  - **Decision:** Absorb 3 cherry-picked patterns from Trail of Bits skills marketplace into 3 existing MASTERMIND skills, and fix the real bug surfaced by `skill-quality-evaluator` baseline. Source attribution: each absorbed pattern explicitly cites its origin in `trailofbits/skills` and links to `research/03-trail-of-bits-skills.md`.
  - **Reason:** Plan A's `skill-quality-evaluator` immediately surfaced 1 real bug (prototype-designer description >1024 chars) and validated the cherry-pick strategy from `research/03-trail-of-bits-skills.md`. The 3 patterns chosen (Blast radius, First Principles + 5 Whys, Insecure Defaults + Rationalizations to Reject) are the highest-leverage and lowest-cost subset of the 5+ candidates identified in research.
  - **Alternatives considered:**
    - Install `trailofbits/skills` as plugin marketplace — rejected (research §Veredicto): 30 plugins violate MASTERMIND's opinionated 22-skill inventory and most are blockchain/security-specialist scope.
    - Add a 4th absorption ("Persona-driven skills" → `skill-creator`) — rejected (Plan A planning swap): too abstract, hard to validate, low ROI for v1.
    - Create new skills (e.g. `differential-reviewer`) instead of absorbing into existing ones — rejected: would fragment the inventory; existing skills already declare the right scope, the patterns just enrich them.
  - **Consequences:**
    - 4 skills modified: `prototype-designer` (description fix), `code-reviewer` (Blast radius), `project-deep-audit` (First Principles + 5 Whys), `security-review` (Insecure Defaults + Rationalizations to Reject).
    - 22 skills total unchanged. No new skills, no new scripts.
    - New baseline at `.cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt` documents before/after deltas.
    - `prototype-designer` recovered from 75 → 100. `code-reviewer`, `project-deep-audit`, `security-review` stayed at 100 (no bloat introduced).
    - 2 false-positive findings (retroactive-documenter, phase-gate-reviewer MISSING_TRIGGER) intentionally left unaddressed for v1.1 calibration after 4-8 weeks of observation.
    - Trail of Bits credited explicitly in 4 places (one per absorption); `research/03-trail-of-bits-skills.md` referenced as evaluation context.
  - **Files affected:** `.cursor/skills/prototype-designer/SKILL.md`, `.cursor/skills/code-reviewer/SKILL.md`, `.cursor/skills/project-deep-audit/SKILL.md`, `.cursor/skills/security-review/SKILL.md`, `.cursor/plans/baselines/2026-05-03-skill-baseline-after-tob.txt`, `memory/02-current-state.md`, `memory/07-decisions-log.md` (this entry). Plus `.claude/skills/**` mirror via `scripts/sync-skills.ps1`.
  ```

- [ ] **Step 5.4** — Update `memory/02-current-state.md`:

  Replace the current `## What is in progress` block with:

  ```markdown
  ## What is in progress
  - **Plan B — `adopt-tob-patterns`**: ✅ executed on branch `feat/adopt-tob-patterns`, awaiting merge to `main`. 4 skills updated, no regressions, prototype-designer real bug fixed.
  ```

  Replace the current `## What is next` block with:

  ```markdown
  ## What is next
  - **Plan B merge** to `main` (--no-ff strategy, same as Plan A).
  - **Heuristic calibration v1.1** of `skill-quality-evaluator` after 4-8 weeks observing real-world false positives (currently 2/22 skills have false-positive MISSING_TRIGGER findings; calibration backlog in baselines).
  - **Cross-project promotion** via `/mm-learn`: 4 lesson candidates accumulated from Plan A + Plan B sessions.
  - **Optional Plan C ideas:** (a) Adapt `skill-improver` review-loop pattern from Trail of Bits into `skill-creator`. (b) Investigate `claude-mem` in pilot project APP ARMARIO. (c) Onboard `tdd-guard` when APP ARMARIO has its first real test suite.
  ```

- [ ] **Step 5.5** — Sync mirror.

  **Run:** `pwsh -File scripts/sync-skills.ps1`
  **Expected:** stdout reports CHANGED files (4 skills + maybe baseline file is not synced because it's outside .cursor/skills/).

  **Then:** `pwsh -File scripts/sync-skills.ps1 -Check`
  **Expected:** exit code 0, "in sync".

- [ ] **Step 5.6** — Commit memory + baseline + mirror.

  **Run:**
  ```powershell
  git add .cursor/plans/baselines/ memory/07-decisions-log.md memory/02-current-state.md .claude/skills/
  git commit -m "docs(memory): log Plan B execution + capture post-ToB baseline + sync mirror"
  ```

- [ ] **Step 5.7** — Final whole-branch verification.

  **Run:**
  ```powershell
  pwsh -File scripts/sync-skills.ps1 -Check
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All
  git log --oneline main..HEAD
  ```
  **Expected:**
  - sync exit 0.
  - Average score ≥ 98.0, no Critical findings.
  - 5 commits on the branch (1 per Task 1-4 + 1 final memory/sync commit).

---

## Self-review (Step 4 of skill)

1. **Success criteria coverage** — Each checkbox in Success criteria maps to a Task:
   - prototype-designer fix (≤1024 chars + score 100) → Task 1.
   - code-reviewer "12. Blast radius" → Task 2.
   - project-deep-audit "First Principles + 5 Whys" → Task 3.
   - security-review "Insecure Defaults + Rationalizations" → Task 4.
   - New baseline + memory + sync → Task 5.
   ✅ Sin gaps.

2. **Placeholder scan** — `grep -E "TBD|TODO|<fill|placeholder"`: zero substantive matches. Some `<…>` references are intentional (citation URLs, value substitutions in baseline notes).

3. **Type consistency** — N/A: no code changes. Documentation prose.

4. **Error paths** — Each task has a re-eval step that flags regression. If any task introduces BLOATED_SKILL, the recovery is documented inline (move the new content to `references/`).

5. **Test first** — TDD doesn't apply directly to documentation. The "test" surrogate is **the evaluator score** captured before each edit (Step X.1) and verified after (Step X.3). This is observable verification.

6. **Size check** — All tasks ≤ 10 minutes (the prose is mostly written in this plan; execution is "paste + verify"). Task 4 is the largest (~50 lines of insertion); split if it grows past 8 minutes.

7. **Dependency check** — No external libraries introduced. Only dependency: `skill-quality-evaluator` (merged on main). Source attribution to Trail of Bits documented per absorption.

---

## Execution

**Option A — Subagent-driven (NOT recommended for this plan):**
The plan is heavy on documentation prose with explicit text already in the plan. Dispatching a subagent for "paste this prose + run eval" is overhead without value. **Skip.**

**Option B — Parallel via worktrees:**
Tasks 2, 3, 4 are independent (touch different skills). Could parallelize. But the gain is small (~30 min wall-clock) and the merge order is trivial. **Skip unless you want to test parallel-executor as a side effect.**

**Option C — Inline execution (Cursor Plan Mode) — RECOMMENDED:**
I execute all 5 tasks in this session with checkpoint between Task 1 (real bug fix, validates the methodology) and Tasks 2-4 (subjective absorptions, may need user review). Estimated 1.5-2.5h.

**Option D — Cloud agent / background run:**
Plan is small enough that cloud overhead isn't worth it. **Skip.**

**Option E — Human execution:**
You paste the prose blocks yourself, run eval after each. Useful if you want to read each absorbed pattern carefully and tweak phrasing. ~2-3h with reading time.

**Compatibility note for `task-master-ai`:** Not installed. Plan walked directly.

---

## Amendment log

(Empty.)
