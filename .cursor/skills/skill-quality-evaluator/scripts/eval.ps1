<#
.SYNOPSIS
    Static-analysis quality evaluator for MASTERMIND skills.
.DESCRIPTION
    Evaluates a SKILL.md file against frontmatter validity, line-count budget,
    required sections, and anti-pattern detection. Returns a score (0-100) and
    a list of findings.
.PARAMETER Path
    Path to a skill directory (containing SKILL.md) or to a SKILL.md file.
.PARAMETER All
    Scan every skill under .cursor/skills/.
.PARAMETER Json
    Emit JSON output instead of human-readable.
.PARAMETER Strict
    Exit 1 if any finding has severity Critical (for CI gating).
#>
[CmdletBinding()]
param(
    [string]$Path,
    [switch]$All,
    [switch]$Json,
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'

function Get-SkillFrontmatter {
    [CmdletBinding()]
    param([string]$SkillMdPath)

    $content = Get-Content -Path $SkillMdPath -Raw -Encoding UTF8
    $pattern = '(?s)\A---\s*\r?\n(.*?)\r?\n---\s*\r?\n'
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) {
        return $null
    }
    $yamlText = $match.Groups[1].Value
    $result = [ordered]@{}
    foreach ($line in ($yamlText -split "`r?`n")) {
        if ($line -match '^([a-zA-Z_][\w-]*)\s*:\s*(.*)$') {
            $result[$matches[1]] = $matches[2].Trim()
        }
    }
    return [pscustomobject]$result
}

function Test-NameValid {
    [CmdletBinding()]
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
    if ($Name.Length -gt 64) { return $false }
    if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { return $false }
    if ($Name -match '(anthropic|claude)') { return $false }
    return $true
}

function Test-DescriptionValid {
    [CmdletBinding()]
    param([string]$Description)
    if ([string]::IsNullOrWhiteSpace($Description)) { return $false }
    if ($Description.Length -lt 1 -or $Description.Length -gt 1024) { return $false }
    return $true
}

if (-not $Path -and -not $All) {
    Write-Output "Usage: pwsh -File eval.ps1 -Path <skill-dir-or-skill-md> [-Json] [-Strict]"
    Write-Output "       pwsh -File eval.ps1 -All [-Json] [-Strict]"
    exit 0
}

# Implementation continues in subsequent tasks.
Write-Output "skill-quality-evaluator: scaffold ready, evaluation logic to be added in tasks 6-8."
