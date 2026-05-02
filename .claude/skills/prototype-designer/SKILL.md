---
name: prototype-designer
description: Bridge MASTERMIND's memory and requirements to Claude Design (claude.ai/design) for interactive prototyping on top of the project's shadcn/ui install. Reads memory/05-user-flows, memory/06-feature-map, and memory/14-design-system; composes the optimal prompt for Claude Design (goal + layout + content + audience + token constraints); guides the user through opening the Claude Design project, linking the repo, iterating, and exporting the handoff bundle; stores the bundle under docs/design/prototypes/<feature>/; extracts decisions back into memory/14-design-system.md; recommends implementation-planner as the next step. Use between product-requirements/flow-analyzer and implementation-planner, or whenever the user says "prototype this", "design this feature", "let's mock it up", "mm-design". Requires shadcn/ui installed (via scripts/install-shadcn-mcp) and a Claude subscription with Claude Design access.
---

# Prototype Designer

## Goal

Make the round-trip **spec → interactive prototype → decisions recorded → ready-to-implement plan** predictable, grounded, and compact. Claude Design is a great tool, but used without context it produces beautiful generic IA output that doesn't match your other projects. This skill forces the context in — your memory, your tokens, your shadcn components — so the prototype is production-relevant from the first frame.

## When to use

**Always:**
- Right after `product-requirements` + `flow-analyzer` have produced a feature spec and user flow, and before `implementation-planner` locks the build plan.
- When the user asks to "prototype", "mock up", "design", or invokes `/mm-design`.
- For features where visual feedback from a stakeholder is faster than a text spec.
- When a feature touches multiple screens and the team benefits from seeing the journey, not just per-screen mocks.

**Trigger keywords:** "prototype", "prototipo", "mockup", "mock up", "design", "diseña", "let's sketch", "claude design", "mm-design".

**Do NOT use for:**
- Static components in isolation (`<Button variant="destructive">`). The shadcn MCP already handles that directly.
- Production-level fidelity. The output is a prototype; implementation lives in `implementation-planner` + Claude Code.
- Brand design, logo, marketing imagery. Use a designer or a specialized tool.
- Re-skinning the entire app at once. That's a design system project, not a feature prototype.

## Prerequisites

Read:

1. `CLAUDE.md` (kernel)
2. `.cursor/rules/08-design-system.mdc` (DS conventions)
3. `memory/05-user-flows.md` — which flow are we prototyping?
4. `memory/06-feature-map.md` — what's the feature status, priority, dependencies?
5. `memory/14-design-system.md` — tokens, installed components, likes/anti-patterns, patterns we reuse
6. `~/.mastermind/global/design-patterns.md` (if exists) — cross-project visual lessons

Check the environment:

- `components.json` exists → shadcn is initialized.
- `.cursor/mcp.json` or `.mcp.json` references the shadcn MCP server → agents have live registry access.
- If either is missing, STOP and tell the user to run `scripts/install-shadcn-mcp.ps1` (or `.sh`) first.
- Access to Claude Design: the user's Claude plan (Pro/Max/Team/Enterprise) must have it enabled. If the user says they don't, fall back to a text-based spec and skip Claude Design; still produce the handoff to `implementation-planner`.

## Process

### Step 1 — Identify the prototype target

Ask the user (or infer from recent chat context):

- Which feature / flow are we prototyping? (name it, pick the row in `memory/06-feature-map.md`)
- Fidelity: **wireframe** (low-fi, focus on layout + content) or **hi-fi** (tokens applied, interactive)?
- Scope: single screen, multi-screen flow, or full-feature journey?
- Audience: stakeholder review, user testing, or handoff to Claude Code?

If any of those is unclear, use `doubt-surfacer` and stop here. Do NOT guess.

### Step 2 — Compose the Claude Design prompt

Produce a prompt in the shape Claude Design rewards (it's documented: **goal + layout + content + audience + constraints**). Draft it:

```markdown
### Claude Design prompt for: <feature name>

**Goal:** <1–2 sentences from memory/05-user-flows / memory/06-feature-map>
**Screens / flow:** <numbered list from memory/05-user-flows>
**Primary actions per screen:** <bullet list>
**Content examples:** <realistic sample text/data; pull from memory/03-architecture entities where possible>
**Audience:** <who uses this; from memory/00-project-brief>

**Design constraints (from memory/14-design-system):**
- Tokens: primary <color>, radius <value>, fonts <display + sans>, dark mode <yes/no>.
- Installed components to compose from: <list from memory/14 §Installed components>
- Patterns we reuse: <from memory/14 §Patterns>
- Likes: <bullet list from memory/14 §What I like>
- Anti-patterns — DO NOT: <bullet list from memory/14 §What I don't like>

**References (make it feel like):** <URLs from memory/14 §References>

**Fidelity:** <wireframe | hi-fi>

**Deliverable:** interactive prototype I can click through; export as handoff bundle for Claude Code.
```

Present this to the user. Get `approve` / `edit <changes>` / `abort` before proceeding.

### Step 3 — Guide the Claude Design session

Instruct the user:

1. Open `claude.ai/design`.
2. Create a new project named `<project-name> / <feature>`.
3. Import → link this GitHub repo (the shadcn install lets Claude Design infer tokens and components automatically; it uses the real `components.json`).
4. Paste the prompt from Step 2.
5. Iterate:
   - Use **chat** for structural changes ("split this into 2 screens", "add an empty state").
   - Use **inline comments** for local tweaks ("soften this shadow", "use our Primary Button here").
   - If a direction goes sideways: *"Save what we have and try a completely different approach"* → Claude Design keeps both.
6. When the prototype is stable, export: **Export → Hand off to Claude Code** → copy the URL of the handoff bundle.

Do NOT automate this — Claude Design is a web UI, not a scriptable API (yet). The skill's job is to drive the loop, not click for the user.

### Step 4 — Capture the handoff

Once the user returns with the bundle URL (or a downloaded zip):

1. Create `docs/design/prototypes/<feature>/` if missing.
2. Write `docs/design/prototypes/<feature>/README.md` with:
   - Feature name + link to `memory/06-feature-map.md` row.
   - Claude Design project URL (for returning to iterate).
   - Handoff bundle URL or path.
   - Date and the prompt used (for reproducibility).
   - Screenshots (optional; the user uploads them if useful).
3. If the bundle was downloaded as a folder, place it under `docs/design/prototypes/<feature>/bundle/`.

Never commit the prototype's HTML/JSX to `src/`. It's reference material, not production code.

### Step 5 — Extract decisions to memory/14

Scan the prototype and the conversation for:

- **New tokens used** — did we land on a specific radius, font, shadow? Propose an update to `memory/14-design-system.md §Tokens` with before/after.
- **Components discovered** — did the prototype introduce a shadcn component we haven't installed yet (e.g. `Command`, `Sheet`)? Add a row to `memory/14 §Installed components` with status "to install during implementation".
- **Patterns emerged** — does this feature use a composition we'll reuse? Name it and add a row to `memory/14 §Patterns we use repeatedly`.
- **Visual likes confirmed** — if something in the prototype crystallized a preference, append to `§What I like`.
- **Anti-patterns confirmed** — if an iteration was rejected, note it under `§What I don't like` with context.

Present each proposed update to the user one by one (approve / edit / skip), the same per-entry approval pattern as `continuous-learner` and `retroactive-documenter`.

### Step 6 — Handoff to implementation-planner

Emit a HIGH Command Recommendation pointing to `implementation-planner`. The planner will:

- Read the prototype bundle from `docs/design/prototypes/<feature>/`.
- Combine with `memory/06-feature-map.md` and the current `src/` layout.
- Produce an implementation plan that reuses the prototype's component choices and design intent — because both sit on the same shadcn foundation.

### Step 7 — Close + memory updater

- Invoke `memory-updater` to append a session entry to `memory/11-session-summary.md` summarizing: feature prototyped, fidelity, decisions captured, components discovered.
- Add a decision entry in `memory/07-decisions-log.md` if any token or pattern changed:
  ```markdown
  ### YYYY-MM-DD - Prototyped <feature> via Claude Design
  - Decision: <what was decided about tokens / components / patterns>
  - Reason: emerged during prototyping; validates or refines memory/14.
  - Alternatives considered: <ones that were rejected in the session>
  - Consequences: memory/14 updated; implementation-planner consumes the bundle next.
  - Files affected: memory/14-design-system.md, docs/design/prototypes/<feature>/**
  ```

### Step 8 — Closing recommendation

```markdown
"Prototype for <feature> captured. <N> decisions logged to memory/14, <K> components queued for install, bundle saved under docs/design/prototypes/<feature>/.

---
**Next recommended command:** `/mm-plan <feature>`
**Why:** the prototype + the updated memory/14 + the existing shadcn foundation give implementation-planner everything it needs to produce a code plan that matches the design intent. Delay is wasted context.
**Go ahead:** type `go` and I'll invoke implementation-planner now.
**Skip if:** you want to present the prototype to a stakeholder first, or you're not yet ready to commit to implementation."
```

## Outputs

- `docs/design/prototypes/<feature>/README.md` with prompt, URLs, date.
- `docs/design/prototypes/<feature>/bundle/` (optional; if downloaded locally).
- Updates to `memory/14-design-system.md` (approved per entry).
- Optional entry in `memory/07-decisions-log.md`.
- Session entry appended to `memory/11-session-summary.md`.

## Interactions with other skills

- **Invoked by:** user via `/mm-design`; workflow `02-feature-lifecycle` (phase "prototype"); or natural language.
- **Consumes outputs of:** `product-requirements`, `flow-analyzer`, `feature-breakdown`.
- **Feeds into:** `implementation-planner` (the next step).
- **Closes with:** `memory-updater`.
- **Independent of:** the shadcn MCP's own skill — that one handles discovering and installing components; this one handles the *whole* prototyping cycle.

## Completion checklist

- [ ] Target feature identified; fidelity and scope explicit.
- [ ] `components.json` and shadcn MCP verified present (else stopped and redirected user).
- [ ] Prompt for Claude Design composed, approved by user.
- [ ] User opened Claude Design, linked repo, iterated to stable prototype.
- [ ] Handoff bundle captured under `docs/design/prototypes/<feature>/`.
- [ ] Per-entry update of `memory/14-design-system.md`; user approved each.
- [ ] Decision logged to `memory/07-decisions-log.md` if tokens/patterns changed.
- [ ] `memory-updater` ran.
- [ ] Closing HIGH recommendation emitted pointing to `implementation-planner`.

## Anti-patterns

- **NEVER:** Skip memory/14 and dump a generic prompt to Claude Design. The output will be visually off-brand and useless in 2 weeks.
- **NEVER:** Commit the prototype's HTML/JSX to `src/`. It's an artifact, not code. Claude Code (via `implementation-planner`) produces the real implementation using the project's shadcn + conventions.
- **NEVER:** Batch-approve memory/14 updates. Each entry is a small decision that may echo into other projects via `continuous-learner`; treat it with the respect that implies.
- **NEVER:** Auto-install components that appeared in the prototype without the user confirming. Installation is `implementation-planner`'s move, not this skill's.
- **NEVER:** Run this skill if `components.json` is missing. Tell the user to run `scripts/install-shadcn-mcp` first and stop. Prototyping on top of an uninitialized DS is the "generic IA aesthetic" trap.
- **NEVER:** Replace the user's judgement. If Claude Design produces something cleaner than what's in memory/14, surface the delta and let the user decide — do not silently "upgrade" the system.
