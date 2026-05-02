<#
.SYNOPSIS
    Install the shadcn/ui ecosystem into a MASTERMIND project: CLI init, MCP server registration, and official Skill. One command covers what would otherwise be three manual steps.

.DESCRIPTION
    Run this INSIDE a target project (one that was born from MASTERMIND or onboarded via
    scripts/onboard-existing-project). It:

    1. Verifies this is a MASTERMIND project (memory/ + .cursor/rules/ present).
    2. Verifies the project is a JS/TS project (package.json exists, Next.js/React detected).
    3. Runs `npx shadcn@latest init` (interactive unless -Defaults is passed).
    4. Registers the shadcn MCP server in .cursor/mcp.json AND .mcp.json (Claude Code).
    5. Runs `npx skills add shadcn/ui` to install the official project-aware Skill.
    6. Prints next-step guidance: fill memory/14-design-system.md, then run /mm-design.

    Safe by design:
      - Dry-run by default; pass -Apply to execute.
      - Never modifies src/ or existing components.
      - Merges into existing .cursor/mcp.json rather than overwriting (preserves other MCP servers).
      - Skips step 1 if components.json already exists (idempotent).

.PARAMETER Apply
    Actually run the install. Without -Apply it only prints what it would do.

.PARAMETER Defaults
    Pass --defaults to `shadcn init`, skipping its interactive prompts. Uses shadcn's sensible defaults (Tailwind + TypeScript + New York style + Slate base color + CSS variables + Lucide icons). If you want a different style or base color, omit -Defaults and answer the prompts.

.PARAMETER SkipSkill
    Skip `npx skills add shadcn/ui` (the official project-aware Skill). Default: install it.

.EXAMPLE
    pwsh -File scripts/install-shadcn-mcp.ps1
    # Dry-run inside the current project.

.EXAMPLE
    pwsh -File scripts/install-shadcn-mcp.ps1 -Apply -Defaults
    # Non-interactive install, fastest path.

.EXAMPLE
    pwsh -File scripts/install-shadcn-mcp.ps1 -Apply
    # Interactive (lets you pick style, base color, etc.).

.NOTES
    Requires: Node.js >= 18, npm/pnpm/bun in PATH. Optionally: Claude Code or Cursor installed
    to consume the MCP.
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$Defaults,
    [switch]$SkipSkill
)

$ErrorActionPreference = 'Stop'

$root = (Get-Location).Path

function Write-Section([string]$title) {
    Write-Host ""
    Write-Host "=== $title ===" -ForegroundColor Cyan
}

# --- Preconditions -----------------------------------------------------------
Write-Section "Preconditions"

$issues = @()
if (-not (Test-Path (Join-Path $root 'package.json'))) { $issues += "package.json not found. This script is for JS/TS projects." }
if (-not (Test-Path (Join-Path $root 'memory'))) { $issues += "memory/ not found. This does not look like a MASTERMIND project. Run /mm-bootstrap (new) or scripts/onboard-existing-project (existing) first." }
if (-not (Test-Path (Join-Path $root '.cursor\rules'))) { $issues += ".cursor/rules/ not found. MASTERMIND shell missing." }

$hasNode = Get-Command node -ErrorAction SilentlyContinue
if (-not $hasNode) { $issues += "Node.js not found in PATH." }

if ($issues.Count -gt 0) {
    Write-Host "BLOCKED:" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 2
}
Write-Host "  OK: MASTERMIND project, package.json present, Node.js available."

# Detect stack
try {
    $pkgJson = Get-Content (Join-Path $root 'package.json') -Raw | ConvertFrom-Json
    $deps = @{}
    if ($pkgJson.dependencies) { $pkgJson.dependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value } }
    if ($pkgJson.devDependencies) { $pkgJson.devDependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value } }
    $hasNext = $deps.ContainsKey('next')
    $hasReact = $deps.ContainsKey('react')
    $hasTS = $deps.ContainsKey('typescript')
    Write-Host "  Stack: Next.js=$hasNext, React=$hasReact, TypeScript=$hasTS"
    if (-not $hasReact -and -not $hasNext) {
        Write-Host "  WARN: no React or Next.js detected. shadcn/ui may not fit this project." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARN: could not parse package.json ($($_.Exception.Message))" -ForegroundColor Yellow
}

# --- Plan --------------------------------------------------------------------
Write-Section "Plan"

$steps = @()
if (Test-Path (Join-Path $root 'components.json')) {
    Write-Host "  [SKIP] shadcn already initialized (components.json exists)."
} else {
    if ($Defaults) { $steps += "1. npx shadcn@latest init --defaults  (non-interactive, sensible defaults)" }
    else { $steps += "1. npx shadcn@latest init  (interactive: you pick style/base color/aliases)" }
}

$cursorMcp = Join-Path $root '.cursor\mcp.json'
$claudeMcp = Join-Path $root '.mcp.json'
$cursorHasShadcn = $false; $claudeHasShadcn = $false
if (Test-Path $cursorMcp) {
    try { $c = Get-Content $cursorMcp -Raw | ConvertFrom-Json; if ($c.mcpServers.shadcn) { $cursorHasShadcn = $true } } catch {}
}
if (Test-Path $claudeMcp) {
    try { $c = Get-Content $claudeMcp -Raw | ConvertFrom-Json; if ($c.mcpServers.shadcn) { $claudeHasShadcn = $true } } catch {}
}
if ($cursorHasShadcn -and $claudeHasShadcn) {
    Write-Host "  [SKIP] shadcn MCP already registered in both .cursor/mcp.json and .mcp.json."
} else {
    $steps += "2. Register shadcn MCP server in .cursor/mcp.json (Cursor) and .mcp.json (Claude Code). Merges; does not overwrite other servers."
}

if (-not $SkipSkill) {
    $steps += "3. npx skills add shadcn/ui  (official project-aware Skill for AI assistants)"
} else {
    Write-Host "  [SKIP] official shadcn Skill (-SkipSkill given)."
}

if ($steps.Count -eq 0) {
    Write-Host "  Everything already installed. Nothing to do." -ForegroundColor Green
    exit 0
}

$steps | ForEach-Object { Write-Host "  $_" }

if (-not $Apply) {
    Write-Host ""
    Write-Host "DRY-RUN. Re-run with -Apply to execute." -ForegroundColor Yellow
    exit 1
}

# --- Execute -----------------------------------------------------------------
Write-Section "Executing"

if (-not (Test-Path (Join-Path $root 'components.json'))) {
    Write-Host "-> shadcn init..."
    $args = @('shadcn@latest','init')
    if ($Defaults) { $args += '--defaults' }
    & npx @args
    if ($LASTEXITCODE -ne 0) { Write-Host "shadcn init failed." -ForegroundColor Red; exit 1 }
}

# Register MCP in .cursor/mcp.json and .mcp.json (merge-safe)
function Add-ShadcnMcpServer([string]$Path) {
    $obj = [ordered]@{ mcpServers = [ordered]@{} }
    if (Test-Path $Path) {
        try {
            $raw = Get-Content $Path -Raw
            $existing = $raw | ConvertFrom-Json -AsHashtable
            if ($existing) {
                $obj = [ordered]@{}
                foreach ($k in $existing.Keys) { $obj[$k] = $existing[$k] }
                if (-not $obj.mcpServers) { $obj.mcpServers = [ordered]@{} }
            }
        } catch {
            Write-Host "  WARN: $Path exists but is not valid JSON; will write fresh." -ForegroundColor Yellow
            $obj = [ordered]@{ mcpServers = [ordered]@{} }
        }
    }
    if (-not $obj.mcpServers.shadcn) {
        $obj.mcpServers.shadcn = [ordered]@{
            command = 'npx'
            args = @('shadcn@latest','mcp')
        }
        $dir = Split-Path -Parent $Path
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        ($obj | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $Path -Encoding UTF8
        Write-Host "  + $Path"
    } else {
        Write-Host "  [skip] shadcn already in $Path"
    }
}

Write-Host "-> Registering shadcn MCP..."
Add-ShadcnMcpServer -Path $cursorMcp
Add-ShadcnMcpServer -Path $claudeMcp

if (-not $SkipSkill) {
    Write-Host "-> Installing official shadcn Skill..."
    & npx skills add shadcn/ui
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  WARN: `npx skills add shadcn/ui` failed. Install later by hand if needed." -ForegroundColor Yellow
    }
}

# --- Done --------------------------------------------------------------------
Write-Section "Done"
Write-Host "  shadcn/ui installed, MCP registered, Skill installed." -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Reload Cursor / restart Claude Code so the MCP server attaches."
Write-Host "     Sanity: in Cursor settings, shadcn MCP should show a green dot. In Claude Code: /mcp -> 'shadcn' Connected."
Write-Host "  2. Open memory/14-design-system.md and fill the Project identity + Tokens sections."
Write-Host "     (Empty placeholders = generic-IA-flavored prototypes. Fill 10 lines and you reclaim the per-project coherence.)"
Write-Host "  3. Add a couple of base components (button, card, input) so `components.json` has real entries:"
Write-Host "     In chat: 'Add button, card, and input components from shadcn.'"
Write-Host "  4. When you have a feature to prototype, run: /mm-design <feature-name>"
Write-Host ""
exit 0
