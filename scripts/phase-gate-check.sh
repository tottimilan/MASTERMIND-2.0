#!/usr/bin/env bash
# phase-gate-check.sh — dry-run phase gate verification.
# Reads memory/02-current-state.md and memory/13-phase-history.md, checks expected
# artifacts for the current phase, reports gaps. Does NOT transition the phase.
#
# Usage:
#   bash scripts/phase-gate-check.sh                  # check current phase only
#   bash scripts/phase-gate-check.sh --next MVP       # also check entry criteria of target phase
#
# Exit codes:
#   0 — PASS
#   1 — GAPS
#   2 — BLOCK (can't determine phase)

set -euo pipefail

NEXT_PHASE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --next)
      NEXT_PHASE="${2:-}"
      shift 2
      ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
STATE_FILE="$REPO_ROOT/memory/02-current-state.md"
HISTORY_FILE="$REPO_ROOT/memory/13-phase-history.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "BLOCK: memory/02-current-state.md is missing." >&2
  exit 2
fi
if [[ ! -f "$HISTORY_FILE" ]]; then
  echo "BLOCK: memory/13-phase-history.md is missing." >&2
  exit 2
fi

CURRENT_PHASE="$(grep -Ei '^\*\*Phase:\*\*' "$STATE_FILE" | head -n1 | sed -E 's/.*\*\*Phase:\*\*[[:space:]]+([A-Za-z]+).*/\1/')"
case "$CURRENT_PHASE" in
  Idea|Discovery|Definition|MVP|Iteration|Launch) ;;
  *)
    echo "BLOCK: Could not detect a concrete current phase in memory/02-current-state.md."
    echo "       Expected a line like '**Phase:** MVP' with one phase name."
    exit 2
    ;;
esac

echo ""
echo "=== phase-gate-check ==="
echo "Repo:          $REPO_ROOT"
echo "Current phase: $CURRENT_PHASE"
[[ -n "$NEXT_PHASE" ]] && echo "Checking target: $NEXT_PHASE"
echo ""

# Expected artifacts per phase
artifacts_for() {
  case "$1" in
    Idea)
      printf '%s\n' 'memory/00-project-brief.md'
      ;;
    Discovery)
      printf '%s\n' \
        'memory/00-project-brief.md' \
        'docs/product/executive-summary.md' \
        'docs/product/personas.md' \
        'docs/product/competitive-analysis.md' \
        'memory/08-known-risks.md'
      ;;
    Definition)
      printf '%s\n' \
        'docs/product/prd.md' \
        'docs/architecture/system-map.md' \
        'memory/06-feature-map.md' \
        'memory/03-architecture.md'
      ;;
    MVP)
      printf '%s\n' \
        'docs/testing/strategy.md' \
        'docs/flows'
      ;;
    Iteration)
      printf '%s\n' 'memory/11-session-summary.md'
      ;;
    Launch)
      printf '%s\n' \
        'docs/security/security-risk-map.md' \
        'docs/adr'
      ;;
  esac
}

check_artifact() {
  local rel="$1" full="$REPO_ROOT/$1"
  if [[ ! -e "$full" ]]; then
    echo " GAP  $rel  ->  Missing"
    return 1
  fi
  if [[ -d "$full" ]]; then
    local count
    count=$(find "$full" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -eq 0 ]]; then
      echo " GAP  $rel  ->  Empty directory"
      return 1
    fi
    echo "  OK  $rel  ->  directory with $count file(s)"
    return 0
  fi
  local size
  size=$(wc -c < "$full" | tr -d ' ')
  if [[ "$size" -lt 40 ]]; then
    echo " GAP  $rel  ->  Stub (size $size B)"
    return 1
  fi
  echo "  OK  $rel  ->  ok ($size B)"
  return 0
}

check_phase() {
  local phase="$1" heading="$2"
  echo "$heading"
  local gaps=0
  while IFS= read -r rel; do
    if ! check_artifact "$rel"; then
      gaps=$((gaps+1))
    fi
  done < <(artifacts_for "$phase")
  return $gaps
}

CURRENT_GAPS=0
set +e
check_phase "$CURRENT_PHASE" "Current phase exit criteria ($CURRENT_PHASE):"
CURRENT_GAPS=$?
set -e
echo ""

NEXT_GAPS=0
if [[ -n "$NEXT_PHASE" ]]; then
  set +e
  check_phase "$NEXT_PHASE" "Next phase entry criteria ($NEXT_PHASE):"
  NEXT_GAPS=$?
  set -e
  echo ""
fi

TOTAL_GAPS=$((CURRENT_GAPS + NEXT_GAPS))
if [[ $TOTAL_GAPS -eq 0 ]]; then
  echo "PASS: all expected artifacts are present. Safe to run phase-gate-reviewer skill."
  exit 0
else
  echo "GAPS ($TOTAL_GAPS) — run phase-gate-reviewer skill to analyze and propose remediation."
  exit 1
fi
