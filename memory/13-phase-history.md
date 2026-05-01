# Phase History — [PROJECT NAME]

> **Append-only log of phase transitions.** Every time the project moves from one phase to another (Idea → Discovery → Definition → MVP → Iteration → Launch), add a new entry at the top of the *Transitions* section.
>
> This file is the timeline of the project's strategic posture. Consumed by `phase-gate-reviewer` to verify entry/exit criteria and by `project-deep-audit` to understand where the project has been.
>
> **Never** delete an entry. Supersede in place when a transition was reversed (e.g. reverted from Iteration back to Definition after a pivot).

---

## Current phase

**Phase:** Idea | Discovery | Definition | MVP | Iteration | Launch
**Since:** YYYY-MM-DD
**Confidence:** Low | Medium | High
**Next expected phase:** _TBD_

---

## Phase definitions (canonical — do not edit per project)

| Phase | Purpose | Typical artifacts produced |
|---|---|---|
| **Idea** | The thing is a sentence or a paragraph | `memory/00-project-brief.md` skeleton |
| **Discovery** | Validate problem + user + market | `docs/product/executive-summary.md`, `docs/product/personas.md`, `docs/product/competitive-analysis.md`, `memory/08-known-risks.md` |
| **Definition** | Lock the MVP scope | `docs/product/prd.md`, `docs/features/<epic>.md`, `docs/architecture/system-map.md`, first ADRs |
| **MVP** | Build and ship the MVP | Code in `main`, `docs/flows/*.md`, `docs/testing/strategy.md`, feature-map MVP rows all `Shipped` |
| **Iteration** | Learn from users, improve | Updated `memory/08-known-risks.md` with real-world risks, pivots logged in `memory/07-decisions-log.md`, new slices shipped |
| **Launch** | Public release, scale | SLA/SLO docs, `docs/security/*` hardened, observability deployed, `docs/adr/` coverage complete |

Transitions between phases require explicit approval via `phase-gate-reviewer`. Skipping phases is possible but must be logged as a decision.

---

## Transitions

> Newest first. Each transition = one entry. Use the template below.

### Transition template

```markdown
### YYYY-MM-DD — <Previous phase> → <New phase>
- **Decided by:** User + <Model>
- **Trigger:** <what prompted the transition>
- **Entry criteria met:**
  - [x] <criterion>
  - [x] <criterion>
- **Artifacts promoted:**
  - <path> — <summary>
- **Blockers waived (if any):**
  - <blocker> — <reason approved to skip>
- **Confidence at entry:** Low | Medium | High
- **Expected duration in new phase:** <weeks>
- **Success metric for this phase:** <what will tell us the phase is done>
- **Link to gate review:** `docs/adr/XXXX-phase-gate-<slug>.md` (or in-chat transcript reference)
```

### Entries

_No transitions yet. The project starts at `Idea` by default when the template is cloned. The first transition (`Idea → Discovery`) is logged when the user kicks off `doubt-surfacer` + `project-deep-audit` for the first time._

---

## Reverted / superseded transitions

> Transitions that were later reversed (pivot back, scope rollback, etc.). Kept as history.

_None yet._

---

## Maintenance

- `phase-gate-reviewer` writes here when a gate is approved.
- `memory-updater` writes here when a session crosses a phase boundary, even without formal gate review.
- On a clone of the template, leave the "Current phase" as `Idea` and let the first transition populate this file.
