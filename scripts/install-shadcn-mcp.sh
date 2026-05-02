#!/usr/bin/env bash
# install-shadcn-mcp.sh - install shadcn/ui + its MCP server + its official Skill
# into a MASTERMIND project. Run from the target project's root.
#
# Usage:
#   bash scripts/install-shadcn-mcp.sh              # dry-run
#   bash scripts/install-shadcn-mcp.sh --apply      # interactive install
#   bash scripts/install-shadcn-mcp.sh --apply --defaults   # non-interactive (fastest)
#   bash scripts/install-shadcn-mcp.sh --apply --skip-skill # skip 'npx skills add shadcn/ui'
#
# Safe by design: merges into existing .cursor/mcp.json / .mcp.json (never overwrites
# other MCP servers); idempotent (skips shadcn init if components.json exists).

set -euo pipefail

APPLY=0; DEFAULTS=0; SKIP_SKILL=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)       APPLY=1; shift ;;
    --defaults)    DEFAULTS=1; shift ;;
    --skip-skill)  SKIP_SKILL=1; shift ;;
    -h|--help)     sed -n '2,16p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

ROOT="$(pwd)"

section() { echo ""; echo "=== $1 ==="; }

section "Preconditions"
issues=()
[[ ! -f "$ROOT/package.json" ]] && issues+=("package.json not found. JS/TS project required.")
[[ ! -d "$ROOT/memory" ]] && issues+=("memory/ not found. Not a MASTERMIND project; run /mm-bootstrap or scripts/onboard-existing-project first.")
[[ ! -d "$ROOT/.cursor/rules" ]] && issues+=(".cursor/rules/ not found. MASTERMIND shell missing.")
command -v node >/dev/null 2>&1 || issues+=("Node.js not found in PATH.")
if [[ ${#issues[@]} -gt 0 ]]; then
  echo "BLOCKED:"
  for i in "${issues[@]}"; do echo "  - $i"; done
  exit 2
fi
echo "  OK: MASTERMIND project, package.json present, Node.js available."

# stack detect
if grep -q '"next"' "$ROOT/package.json"; then echo "  Stack: Next.js detected."
elif grep -q '"react"' "$ROOT/package.json"; then echo "  Stack: React detected."
else echo "  WARN: no React/Next.js in package.json; shadcn/ui may not fit."; fi

section "Plan"
steps=()
if [[ -f "$ROOT/components.json" ]]; then
  echo "  [SKIP] shadcn already initialized (components.json exists)."
else
  if [[ $DEFAULTS -eq 1 ]]; then steps+=("1. npx shadcn@latest init --defaults  (non-interactive)")
  else steps+=("1. npx shadcn@latest init  (interactive)"); fi
fi

CURSOR_MCP="$ROOT/.cursor/mcp.json"; CLAUDE_MCP="$ROOT/.mcp.json"
has_shadcn_in() {
  local f="$1"
  [[ -f "$f" ]] && grep -q '"shadcn"' "$f" 2>/dev/null
}
cursor_has_shadcn=0; claude_has_shadcn=0
has_shadcn_in "$CURSOR_MCP" && cursor_has_shadcn=1
has_shadcn_in "$CLAUDE_MCP" && claude_has_shadcn=1
if [[ $cursor_has_shadcn -eq 1 && $claude_has_shadcn -eq 1 ]]; then
  echo "  [SKIP] shadcn MCP already registered in both .cursor/mcp.json and .mcp.json."
else
  steps+=("2. Register shadcn MCP in .cursor/mcp.json + .mcp.json (merges; preserves other servers).")
fi

if [[ $SKIP_SKILL -eq 0 ]]; then
  steps+=("3. npx skills add shadcn/ui  (official project-aware Skill)")
else
  echo "  [SKIP] official shadcn Skill (--skip-skill given)."
fi

if [[ ${#steps[@]} -eq 0 ]]; then
  echo "  Everything already installed. Nothing to do."
  exit 0
fi
for s in "${steps[@]}"; do echo "  $s"; done

if [[ $APPLY -eq 0 ]]; then
  echo ""
  echo "DRY-RUN. Re-run with --apply to execute."
  exit 1
fi

section "Executing"

# 1. shadcn init
if [[ ! -f "$ROOT/components.json" ]]; then
  echo "-> shadcn init..."
  if [[ $DEFAULTS -eq 1 ]]; then
    npx shadcn@latest init --defaults
  else
    npx shadcn@latest init
  fi
fi

# 2. MCP registration (merge-safe, no jq dependency — minimal JSON writer)
register_mcp() {
  local file="$1"
  if has_shadcn_in "$file"; then echo "  [skip] shadcn already in $file"; return; fi
  local dir; dir="$(dirname "$file")"
  mkdir -p "$dir"
  if [[ ! -f "$file" ]]; then
    cat > "$file" <<'JSON'
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
JSON
    echo "  + $file"
    return
  fi
  # Existing file: try jq merge if available; else append via naive patch.
  if command -v jq >/dev/null 2>&1; then
    local tmp; tmp="$(mktemp)"
    jq '.mcpServers = (.mcpServers // {}) | .mcpServers.shadcn = {"command":"npx","args":["shadcn@latest","mcp"]}' "$file" > "$tmp" && mv "$tmp" "$file"
    echo "  + $file (merged via jq)"
  else
    echo "  WARN: jq not found; please add the shadcn entry manually to $file:"
    echo '    "shadcn": { "command": "npx", "args": ["shadcn@latest", "mcp"] }'
  fi
}

echo "-> Registering shadcn MCP..."
register_mcp "$CURSOR_MCP"
register_mcp "$CLAUDE_MCP"

# 3. skill
if [[ $SKIP_SKILL -eq 0 ]]; then
  echo "-> Installing official shadcn Skill..."
  npx skills add shadcn/ui || echo "  WARN: 'npx skills add shadcn/ui' failed. Install later by hand."
fi

section "Done"
echo "  shadcn/ui installed, MCP registered, Skill installed."
echo ""
echo "NEXT STEPS:"
echo "  1. Reload Cursor / restart Claude Code so the MCP server attaches."
echo "     In Cursor settings: green dot on shadcn MCP. In Claude Code: /mcp -> 'shadcn' Connected."
echo "  2. Open memory/14-design-system.md and fill Project identity + Tokens."
echo "  3. Add base components: in chat say 'Add button, card, input from shadcn.'"
echo "  4. When prototyping a feature: /mm-design <feature-name>"
echo ""
