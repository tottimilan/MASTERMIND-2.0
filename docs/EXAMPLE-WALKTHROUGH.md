# End-to-end worked example: "Notas-AI"

> Referenced from `OPERATING-GUIDE.md §9`. A fictional project used as a through-line to show the whole MASTERMIND arc (Idea → Launch) in practice. Everything below is realistic but illustrative — do not copy-paste paths and content literally, adapt to your real context.

### The idea

**Notas-AI.** A note-taking SaaS for freelancers that auto-categorizes notes using an LLM and surfaces the three notes most relevant to the current calendar block. Monetization: 12 €/month per user, freemium with 100 notes cap.

### Day 0 — Clone + bootstrap

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

### Day 1–5 — Discovery iteration

You use `/mm-audit risks` and `/mm-doubt` multiple times to sharpen specific angles:

- Deep dive on the calendar integration space (Google Calendar + Apple iCloud via CalDAV + Outlook).
- Validation interviews with 5 freelancer writers (external to the tool; you summarize in `memory/11-session-summary.md`).
- Research note on semantic search approaches (pgvector, Pinecone, Upstash Vector). Written to `docs/architecture/research/vector-search-2026-05.md`.

At end of week 1:

```
You → /mm-gate Definition
```

Agent runs `phase-gate-check`: PASS. Runs `phase-gate-reviewer Definition`. Verdict: PROCEED. You approve. Phase transitions to `Definition`.

### Day 6–12 — Definition

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

### Day 13–55 — MVP execution

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

### Day 44 onward — Iteration

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

### Day 120 — Launch gate

Two months of iteration. Metrics: **42% focus-block note-click rate** (above the 40% target). Paying users: **18** (above the 10-user MVP exit bar). Observability deployed. Incident runbook for DB failure, OpenAI outage, Stripe webhook loss.

```
You → /mm-gate Launch
```

`phase-gate-reviewer`: **PROCEED WITH CAVEATS**. The caveat: SLA is declared 99% but the DB is single-region. A multi-region plan exists in `docs/adr/0004-multi-region-plan.md`, scheduled for Q3.

Launch approved. `memory/13` gains `Iteration → Launch` entry.

### The journey in commits (simplified)

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

### What the memory looks like at Launch

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
