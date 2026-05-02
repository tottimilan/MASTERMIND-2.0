# Design system — this project

> **What this file is.** The text source of truth for every visual and UI decision in this repository. It lives in `memory/` because it's read by agents and humans alike, evolves with the project, and survives restarts. Not a duplicate of Figma. Not a screenshot in Slack. The canonical record.
>
> **Default stack.** shadcn/ui (via [official MCP](https://ui.shadcn.com/docs/mcp) + [official Skill](https://ui.shadcn.com/docs/skills)) + Tailwind + Radix. Prototyping via [Claude Design](https://claude.ai/design). If this project uses anything else, the reason is in `memory/07-decisions-log.md`.

---

## Project identity

- **Name:** _TBD_
- **Personality (3–5 adjectives):** _TBD_  (e.g. "calm, trustworthy, dense, data-first, serif")
- **Target feel vs competitors:** _TBD_  (e.g. "closer to Linear than to Notion; avoid the Stripe-dashboard overload")
- **Dark mode:** _TBD_  (default / opt-in / not supported)
- **Reference products I admire for this project:** _TBD_
  - _product A_ — _reason_
  - _product B_ — _reason_

---

## Tokens

> Edit these values and the whole UI follows. Derived from `globals.css` / `tailwind.config.ts` / `components.json`. If anything here diverges from the code, the code wins and you update the doc. Never the other way around.

### Colors

| Token | Light | Dark | Notes |
|---|---|---|---|
| `primary` | _TBD_ | _TBD_ | Main brand color; buttons, links |
| `secondary` | _TBD_ | _TBD_ | Supporting actions |
| `accent` | _TBD_ | _TBD_ | Highlights, focus |
| `destructive` | _TBD_ | _TBD_ | Delete, error |
| `muted` | _TBD_ | _TBD_ | Backgrounds of inactive regions |
| `background` | _TBD_ | _TBD_ | Page background |
| `foreground` | _TBD_ | _TBD_ | Default text |
| `border` | _TBD_ | _TBD_ | Dividers |

### Typography

- **Display font:** _TBD_  (e.g. "Fraunces, serif")
- **Sans font:** _TBD_  (e.g. "Inter, system-ui, sans-serif")
- **Mono font:** _TBD_  (e.g. "JetBrains Mono, ui-monospace, monospace")
- **Scale:** _TBD_  (typographic scale; default shadcn is fine unless overridden)

### Spacing & geometry

- **Base unit:** _TBD_  (default: 4px; Tailwind's 1 = 4px)
- **Radius base:** _TBD_  (shadcn default: 0.5rem; common customizations: 0.25rem tight, 0.75rem soft, 1rem rounded)
- **Container max-width:** _TBD_

### Motion

- **Default easing:** _TBD_  (e.g. `cubic-bezier(0.4, 0, 0.2, 1)` — Tailwind's `ease-in-out`)
- **Default duration:** _TBD_  (e.g. `150ms` subtle, `300ms` primary)
- **Reduced motion policy:** _TBD_  (respect `prefers-reduced-motion` → yes / no / partial)

---

## Installed components

> Every component copied into the repo via `npx shadcn add` (or the shadcn MCP). When the agent adds one, append a row here. Drift between this table and `src/components/ui/` is a bug — `project-deep-audit` flags it.

| Component | Installed at | Customizations? | Used where |
|---|---|---|---|
| _(empty until first install)_ | | | |

---

## Custom components

> Not from shadcn. Live in `src/components/custom/`. Each one needs a reason.

| Component | Reason not shadcn | Composes | Stability |
|---|---|---|---|
| _(empty)_ | | | |

---

## What I like (visual preferences)

> Your aesthetic axioms. Agents honor these when proposing designs in `prototype-designer` or Claude Design.

- _TBD_  (e.g. "Generous whitespace over dense grids.")
- _TBD_  (e.g. "Serif display for hero, sans for the rest.")
- _TBD_  (e.g. "Soft radius (0.75rem+) — never sharp corners.")
- _TBD_  (e.g. "One accent color max per screen.")
- _TBD_  (e.g. "Data tables compact, forms spacious.")

## What I don't like (anti-patterns)

> Equally important. Agents must not propose these.

- _TBD_  (e.g. "No neon gradients.")
- _TBD_  (e.g. "No more than 2 font weights per view.")
- _TBD_  (e.g. "No sticky headers on content pages.")
- _TBD_  (e.g. "No modal-stacking three deep.")

---

## Patterns we use repeatedly

> Reusable compositions, not components. Named in prose so you can reference them in prompts.

| Pattern | Used for | Composition | First used in |
|---|---|---|---|
| _(empty)_ | | | |

Examples (delete if not applicable):
- **"Hero + three-column feature grid"** — marketing landings. shadcn `Card` × 3 inside a flex container with `gap-6`.
- **"Sidebar dashboard with stats row"** — app dashboards. `Sidebar` + `StatCard` × N in a `grid grid-cols-4`.
- **"Progressive form"** — multi-step forms. `Tabs` vertical + `Form` per step + shadcn `Progress` at top.

---

## References / inspiration

> Links, not screenshots (those rot). Internal reference for prompts to Claude Design: *"make it feel like X"*.

- _URL — why it's a reference_
- _URL — why it's a reference_

## Changelog

> Append-only. One entry per visual decision that materially changes the look.

### YYYY-MM-DD — _what changed_
- Before: _brief_
- After: _brief_
- Reason: _brief_
- Files affected: _list_
- Linked decision: `memory/07-decisions-log.md#YYYY-MM-DD-title`

---

## Integration with tooling

- **shadcn MCP** installed at `.cursor/mcp.json` (+ `.mcp.json` for Claude Code). Status: _TBD_ (active / not yet).
- **shadcn Skill** (`npx skills add shadcn/ui`). Status: _TBD_.
- **Claude Design** project linked: _TBD_ (URL to the design project on `claude.ai/design`).
- **MASTERMIND skill** that writes here: `prototype-designer` (via `/mm-design`), plus `memory-updater` at session close.

---

## Open questions about design (for next session)

- _TBD_

(empty is OK — it means you have no pending visual questions right now.)
