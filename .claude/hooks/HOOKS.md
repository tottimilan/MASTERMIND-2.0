# Claude Desktop Hooks

> **Extension point — Claude Desktop side.** This folder mirrors `.cursor/hooks/` for Claude Desktop events.
> Keep both sides consistent. The **canonical documentation** lives at [`.cursor/hooks/HOOKS.md`](../../.cursor/hooks/HOOKS.md); this file exists so Claude Desktop can discover its own hooks without cross-referencing.

---

## Scope

Hooks placed here run in response to Claude Desktop events (session start/end, MCP tool calls, user turns, etc.). For Cursor-specific hooks, use `.cursor/hooks/`. For git or CI hooks, use their native locations.

---

## Rules

All rules from [`.cursor/hooks/HOOKS.md`](../../.cursor/hooks/HOOKS.md) apply:

1. Introduce a hook only when the action has repeated ≥ 3 times, is deterministic, and cannot silently corrupt state.
2. Every hook has a kill switch.
3. Every hook is reviewed with `code-reviewer` (and `security-review` if sensitive) before first live run.
4. Every hook is logged in `memory/07-decisions-log.md`.
5. Never duplicate a hook between `.cursor/hooks/` and `.claude/hooks/` — pick the canonical side.

---

## Naming

Follow the same pattern as `.cursor/hooks/`: `<event>.<tool>.<ext>`.
