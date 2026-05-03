# Build skill-quality-evaluator (PluginEval, static-only v1) — Implementation Plan

**Date:** 2026-05-03
**Branch:** `feat/skill-quality-evaluator`
**Author:** User + Claude Opus 4.7 (Cursor)
**Status:** Draft

## Goal

Construir un skill MASTERMIND nativo (`skill-quality-evaluator`) que evalúa estáticamente la calidad de cualquier skill bajo `.cursor/skills/<name>/SKILL.md` — frontmatter, longitud, secciones canónicas, y los 4 anti-patterns más críticos (BLOATED_SKILL, MISSING_TRIGGER, EMPTY_DESCRIPTION, MISSING_SECTION). Sin dependencias externas, sin LLM, sin red. Adaptación del framework PluginEval de wshobson/agents a la disciplina MASTERMIND.

## Architecture

Un único script PowerShell autocontenido (`scripts/eval.ps1`) que parsea YAML frontmatter, cuenta líneas, detecta secciones H2, aplica reglas de scoring (100 - penalización por anti-pattern), y emite resultados como objeto PowerShell o JSON. El skill (`SKILL.md`) documenta el contrato y los workflows de uso (single skill, batch, CI dry-run). Tests Pester aseguran que cada regla detecta sus casos positivos y negativos. Resultado: una nueva capacidad de "skill linter" que MASTERMIND no tenía, sin afectar ningún skill existente.

## Tech Stack touched

- **Lenguaje:** PowerShell 7+ (consistencia con `scripts/sync-skills.ps1`, `scripts/install-*.ps1`).
- **Test framework:** Pester ≥ 5.0 (instalable vía `Install-Module Pester -Force`).
- **Dependencias externas:** ninguna (no API key, no red, no Node/Python).
- **Repos modificados:** `.cursor/skills/`, `.claude/skills/` (vía sync), `memory/`, `.cursor/plans/baselines/`.

## Success criteria (observable)

- [ ] `.cursor/skills/skill-quality-evaluator/SKILL.md` existe, tiene frontmatter válido, ≤500 líneas, las 9 secciones canónicas.
- [ ] `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/doubt-surfacer` retorna un objeto con campos `Path`, `Score`, `Findings`.
- [ ] `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All` recorre los 22 skills (21 existentes + el nuevo) y emite resumen con score promedio + lista ordenada por score.
- [ ] `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1` corre 12 tests y todos pasan (verde).
- [ ] El propio `skill-quality-evaluator` evaluado contra sí mismo retorna `Score >= 90` (eat your own dog food).
- [ ] Baseline de los 21 skills existentes guardada en `.cursor/plans/baselines/2026-05-03-skill-baseline.txt`.
- [ ] `.claude/skills/skill-quality-evaluator/` existe (sync mirror) y `pwsh -File scripts/sync-skills.ps1 -Check` exit code 0.
- [ ] `memory/07-decisions-log.md` tiene una entrada nueva fechada 2026-05-03 con decisión + alternativas + consecuencias.
- [ ] `memory/02-current-state.md` refleja "Plan A completado" en sección "What exists today".
- [ ] `.cursor/skills/skill-creator/SKILL.md` Section 7 (Interactions) menciona `skill-quality-evaluator` como peer.

## Files

| Action | Path | Purpose |
|---|---|---|
| Create | `.cursor/skills/skill-quality-evaluator/SKILL.md` | Contrato del skill: cuándo usarlo, cómo invocarlo, qué reporta. |
| Create | `.cursor/skills/skill-quality-evaluator/scripts/eval.ps1` | Script PowerShell que evalúa skills (parser frontmatter + reglas + scoring). |
| Create | `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1` | Tests Pester sobre fixtures sintéticos. |
| Create | `.cursor/skills/skill-quality-evaluator/references/anti-patterns.md` | Catálogo de los 4 anti-patterns con ejemplos. |
| Create | `.cursor/skills/skill-quality-evaluator/references/fixtures/valid-skill.md` | Fixture: skill correcto. |
| Create | `.cursor/skills/skill-quality-evaluator/references/fixtures/bloated-skill.md` | Fixture: skill >500 líneas. |
| Create | `.cursor/plans/baselines/2026-05-03-skill-baseline.txt` | Snapshot del score actual de los 21 skills antes de Plan B. |
| Modify | `.cursor/skills/skill-creator/SKILL.md` (Section 7 "Interactions") | Añadir `skill-quality-evaluator` como peer. |
| Modify | `memory/07-decisions-log.md` (append entry) | Decisión 2026-05-03 documentada. |
| Modify | `memory/02-current-state.md` ("What exists today") | Reflejar nuevo skill en inventario. |

Total: **8 archivos creados** (incluyendo 2 fixtures pequeños) **+ 3 modificados**. El sync genera mirror automáticamente, no se cuenta como archivo de plan.

---

## Task 1 — Scaffold del skill (estructura mínima)

**Files touched:**
- Create: `.cursor/skills/skill-quality-evaluator/SKILL.md` (skeleton frontmatter only)
- Create: `.cursor/skills/skill-quality-evaluator/scripts/.gitkeep`
- Create: `.cursor/skills/skill-quality-evaluator/references/.gitkeep`
- Create: `.cursor/skills/skill-quality-evaluator/references/fixtures/.gitkeep`

### Steps

- [ ] **Step 1.1** — Crear estructura de directorios.

  ```powershell
  New-Item -ItemType Directory -Path ".cursor/skills/skill-quality-evaluator/scripts" -Force
  New-Item -ItemType Directory -Path ".cursor/skills/skill-quality-evaluator/references/fixtures" -Force
  New-Item -ItemType File -Path ".cursor/skills/skill-quality-evaluator/scripts/.gitkeep" -Force
  New-Item -ItemType File -Path ".cursor/skills/skill-quality-evaluator/references/.gitkeep" -Force
  New-Item -ItemType File -Path ".cursor/skills/skill-quality-evaluator/references/fixtures/.gitkeep" -Force
  ```

  **Run:** las líneas de arriba en pwsh.
  **Expected:** `Test-Path .cursor/skills/skill-quality-evaluator/scripts` retorna `True`.

- [ ] **Step 1.2** — Crear `SKILL.md` con frontmatter mínimo válido (placeholder para body, se completa en Task 8).

  ```markdown
  ---
  name: skill-quality-evaluator
  description: Static analysis lint for MASTERMIND skills. Evaluates SKILL.md files against the canonical 9-section template, validates YAML frontmatter (name, description), enforces line-count budget (≤500), and detects four anti-patterns (BLOATED_SKILL, MISSING_TRIGGER, EMPTY_DESCRIPTION, MISSING_SECTION). Use when adding a new skill, refactoring an existing one, auditing the skill library, or before merging any PR that touches .cursor/skills/. Produces a per-skill score (0-100) and a list of findings. Runs as PowerShell CLI with no external dependencies. Trigger keywords: "evaluate skill", "lint skill", "skill quality", "audit skills", "score skill".
  ---

  # Skill Quality Evaluator

  > Body de este skill se completa en Task 8 del plan `2026-05-03-build-skill-quality-evaluator.md`.
  ```

  **Run:** crear con `Set-Content .cursor/skills/skill-quality-evaluator/SKILL.md` con el contenido anterior.
  **Expected:** `Get-Content .cursor/skills/skill-quality-evaluator/SKILL.md | Select-String '^name: skill-quality-evaluator$'` matchea.

- [ ] **Step 1.3** — Commit.

  **Run:**
  ```powershell
  git checkout -b feat/skill-quality-evaluator
  git add .cursor/skills/skill-quality-evaluator/
  git commit -m "chore(skills): scaffold skill-quality-evaluator directory"
  ```
  **Expected:** commit creado, `git status` clean.

---

## Task 2 — Fixture: skill válido (para tests)

**Files touched:**
- Create: `.cursor/skills/skill-quality-evaluator/references/fixtures/valid-skill.md`

### Steps

- [ ] **Step 2.1** — Escribir fixture sintético "skill perfectamente válido" para usar en Pester tests.

  ```markdown
  ---
  name: fixture-valid
  description: Fixture skill that passes all checks. Has valid frontmatter, all 9 sections, includes trigger keywords like "use when" and "always", and stays under the line budget. Used by the skill-quality-evaluator test suite to assert positive cases.
  ---

  # Fixture Valid

  ## Goal
  Test fixture for the evaluator. Always returns score >= 90.

  ## When to use
  Always: in test suites that assert valid skills produce no findings.
  Trigger keywords: "fixture", "test", "valid".
  Do NOT use for: production work.

  ## Prerequisites
  None. This is a fixture.

  ## Process
  1. Be valid.
  2. Stay valid.

  ## Outputs
  Nothing.

  ## Interactions with other skills
  Pairs with: skill-quality-evaluator tests.

  ## Completion checklist
  - [ ] Has all 9 sections.

  ## Anti-patterns
  - None to declare.
  ```

  **Run:** `Set-Content .cursor/skills/skill-quality-evaluator/references/fixtures/valid-skill.md ...`
  **Expected:** archivo creado, longitud ~30 líneas.

- [ ] **Step 2.2** — Commit.

  **Run:** `git add .cursor/skills/skill-quality-evaluator/references/fixtures/valid-skill.md && git commit -m "test(skill-eval): add valid-skill fixture"`
  **Expected:** commit creado.

---

## Task 3 — Fixture: skill bloated (para test BLOATED_SKILL)

**Files touched:**
- Create: `.cursor/skills/skill-quality-evaluator/references/fixtures/bloated-skill.md`

### Steps

- [ ] **Step 3.1** — Generar fixture "skill bloated" con >500 líneas (relleno + frontmatter + secciones mínimas para que solo falle por longitud).

  ```powershell
  $bloatedHeader = @"
  ---
  name: fixture-bloated
  description: Fixture that violates BLOATED_SKILL only. Has valid frontmatter and all sections but exceeds 500 body lines on purpose. Used to assert the line-count anti-pattern detector.
  ---

  # Fixture Bloated

  ## Goal
  Test fixture for BLOATED_SKILL detector.

  ## When to use
  Always: in tests asserting bloated skills are flagged.
  Trigger keywords: "fixture", "bloated", "test".
  Do NOT use for: production.

  ## Prerequisites
  None.

  ## Process
  Lots of filler below to exceed 500 lines.

  "@
  $filler = (1..600 | ForEach-Object { "Line $_  filler content for bloat fixture." }) -join "`n"
  $bloatedFooter = @"

  ## Outputs
  Nothing.

  ## Interactions with other skills
  None.

  ## Completion checklist
  - [ ] Exceeds 500 lines.

  ## Anti-patterns
  - BLOATED_SKILL by design.
  "@
  $bloatedHeader + "`n" + $filler + "`n" + $bloatedFooter | Set-Content -Path ".cursor/skills/skill-quality-evaluator/references/fixtures/bloated-skill.md" -Encoding UTF8
  ```

  **Run:** ejecutar el bloque en pwsh.
  **Expected:** `(Get-Content .cursor/skills/skill-quality-evaluator/references/fixtures/bloated-skill.md).Count` retorna número > 600.

- [ ] **Step 3.2** — Commit.

  **Run:** `git add .cursor/skills/skill-quality-evaluator/references/fixtures/bloated-skill.md && git commit -m "test(skill-eval): add bloated-skill fixture"`
  **Expected:** commit creado.

---

## Task 4 — Pester tests: estructura inicial + test 1 (script existe)

**Files touched:**
- Create: `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`

### Steps

- [ ] **Step 4.1** — Escribir el primer test failing: "el script eval.ps1 existe y se puede invocar".

  ```powershell
  # .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1
  BeforeAll {
      $script:EvalScript = Join-Path $PSScriptRoot 'eval.ps1'
      $script:FixturesDir = Join-Path $PSScriptRoot '..\references\fixtures' | Resolve-Path -ErrorAction SilentlyContinue
  }

  Describe 'eval.ps1 — basic invocation' {
      It 'exists at the expected path' {
          $script:EvalScript | Should -Exist
      }

      It 'is invokable and prints a usage message when called with no args' {
          $output = & pwsh -File $script:EvalScript 2>&1
          $LASTEXITCODE | Should -Not -BeNullOrEmpty
      }
  }
  ```

  **Run:** `Set-Content` con el contenido anterior.
  **Expected:** archivo `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1` existe.

- [ ] **Step 4.2** — Correr los tests, ver que fallan (eval.ps1 no existe aún).

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** Test "exists at the expected path" → **FAIL** con mensaje "Expected file ... to exist".

- [ ] **Step 4.3** — Commit (red).

  **Run:** `git add .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1 && git commit -m "test(skill-eval): add Pester test for script existence (red)"`
  **Expected:** commit creado.

---

## Task 5 — Implementar `eval.ps1` esqueleto + parser de frontmatter

**Files touched:**
- Create: `.cursor/skills/skill-quality-evaluator/scripts/eval.ps1`

### Steps

- [ ] **Step 5.1** — Escribir `eval.ps1` con esqueleto + función `Get-SkillFrontmatter`.

  ```powershell
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
  Write-Output "skill-quality-evaluator: scaffold ready, evaluation logic to be added in tasks 6-9."
  ```

  **Run:** `Set-Content .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 ...` con el bloque anterior.
  **Expected:** archivo creado, ~75 líneas.

- [ ] **Step 5.2** — Correr Pester, los 2 tests pasan.

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 2 PASSED, 0 FAILED.

- [ ] **Step 5.3** — Commit (green).

  **Run:** `git add .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 && git commit -m "feat(skill-eval): add eval.ps1 skeleton with frontmatter parser (green)"`
  **Expected:** commit creado.

---

## Task 6 — Test + lógica de scoring para frontmatter (red → green)

**Files touched:**
- Modify: `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1` (add 4 tests)
- Modify: `.cursor/skills/skill-quality-evaluator/scripts/eval.ps1` (add Invoke-SkillEval function)

### Steps

- [ ] **Step 6.1** — Añadir 4 tests Pester sobre frontmatter (append a `eval.Tests.ps1`):

  ```powershell
  Describe 'eval.ps1 — frontmatter checks' {
      BeforeAll {
          . $script:EvalScript -Path '__noop__' -ErrorAction SilentlyContinue
          $script:ValidFixture = Join-Path $script:FixturesDir 'valid-skill.md'
      }

      It 'reports score >= 90 on the valid-skill fixture' {
          $result = & pwsh -File $script:EvalScript -Path $script:ValidFixture -Json | ConvertFrom-Json
          $result.Score | Should -BeGreaterOrEqual 90
      }

      It 'flags EMPTY_DESCRIPTION when description is missing' {
          $tmpDir = Join-Path $env:TEMP "skill-eval-test-$(Get-Random)"
          New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
          $tmpSkill = Join-Path $tmpDir 'SKILL.md'
          @"
  ---
  name: empty-desc
  description:
  ---

  # Empty Desc
  "@ | Set-Content $tmpSkill -Encoding UTF8

          $result = & pwsh -File $script:EvalScript -Path $tmpSkill -Json | ConvertFrom-Json
          $codes = $result.Findings | ForEach-Object { $_.Code }
          $codes | Should -Contain 'EMPTY_DESCRIPTION'

          Remove-Item -Recurse -Force $tmpDir
      }

      It 'flags invalid name (uppercase) as INVALID_NAME' {
          $tmpDir = Join-Path $env:TEMP "skill-eval-test-$(Get-Random)"
          New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
          $tmpSkill = Join-Path $tmpDir 'SKILL.md'
          @"
  ---
  name: BadName
  description: Has valid description but invalid uppercase name. Use when testing the name validator. Trigger keyword: test.
  ---

  # Bad Name
  "@ | Set-Content $tmpSkill -Encoding UTF8

          $result = & pwsh -File $script:EvalScript -Path $tmpSkill -Json | ConvertFrom-Json
          $codes = $result.Findings | ForEach-Object { $_.Code }
          $codes | Should -Contain 'INVALID_NAME'

          Remove-Item -Recurse -Force $tmpDir
      }

      It 'flags missing frontmatter as MISSING_FRONTMATTER' {
          $tmpDir = Join-Path $env:TEMP "skill-eval-test-$(Get-Random)"
          New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
          $tmpSkill = Join-Path $tmpDir 'SKILL.md'
          "# No Frontmatter Here" | Set-Content $tmpSkill -Encoding UTF8

          $result = & pwsh -File $script:EvalScript -Path $tmpSkill -Json | ConvertFrom-Json
          $codes = $result.Findings | ForEach-Object { $_.Code }
          $codes | Should -Contain 'MISSING_FRONTMATTER'

          Remove-Item -Recurse -Force $tmpDir
      }
  }
  ```

  **Run:** `Add-Content .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1 <bloque>`.
  **Expected:** archivo extendido a ~80 líneas.

- [ ] **Step 6.2** — Correr Pester, los 4 nuevos tests fallan (la lógica de scoring no existe aún).

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 2 PASSED (los de Task 4), 4 FAILED (los nuevos).

- [ ] **Step 6.3** — Implementar `Invoke-SkillEval` y lógica de scoring en `eval.ps1`.

  Reemplazar el bloque final ("# Implementation continues in subsequent tasks." y el `Write-Output`) con:

  ```powershell
  function Invoke-SkillEval {
      [CmdletBinding()]
      param([string]$SkillMdPath)

      $findings = @()
      $score = 100

      if (-not (Test-Path $SkillMdPath)) {
          $findings += [pscustomobject]@{ Severity='Critical'; Code='FILE_NOT_FOUND'; Message="Path does not exist: $SkillMdPath" }
          return [pscustomobject]@{ Path=$SkillMdPath; Score=0; Findings=$findings }
      }

      $frontmatter = Get-SkillFrontmatter -SkillMdPath $SkillMdPath
      if (-not $frontmatter) {
          $findings += [pscustomobject]@{ Severity='Critical'; Code='MISSING_FRONTMATTER'; Message='No YAML frontmatter found at top of file.' }
          $score -= 50
      } else {
          if (-not (Test-NameValid -Name $frontmatter.name)) {
              $findings += [pscustomobject]@{ Severity='Critical'; Code='INVALID_NAME'; Message="name must match ^[a-z0-9]+(-[a-z0-9]+)*$, ≤64 chars, no 'anthropic'/'claude'. Got: '$($frontmatter.name)'" }
              $score -= 25
          }
          if (-not (Test-DescriptionValid -Description $frontmatter.description)) {
              $findings += [pscustomobject]@{ Severity='Critical'; Code='EMPTY_DESCRIPTION'; Message="description must be 1-1024 chars and non-empty. Length: $($frontmatter.description.Length)" }
              $score -= 25
          }
      }

      return [pscustomobject]@{
          Path     = $SkillMdPath
          Score    = [Math]::Max(0, $score)
          Findings = $findings
      }
  }

  function Resolve-SkillMdPath {
      [CmdletBinding()]
      param([string]$InputPath)
      $resolved = Resolve-Path $InputPath -ErrorAction Stop
      if ((Get-Item $resolved).PSIsContainer) {
          return Join-Path $resolved 'SKILL.md'
      }
      return $resolved.Path
  }

  function Format-SkillEvalResult {
      [CmdletBinding()]
      param([pscustomobject]$Result, [switch]$AsJson)
      if ($AsJson) {
          return ($Result | ConvertTo-Json -Depth 5)
      }
      $out = "Skill: $($Result.Path)`nScore: $($Result.Score)/100`nFindings:"
      if ($Result.Findings.Count -eq 0) {
          $out += "`n  (none)"
      } else {
          foreach ($f in $Result.Findings) {
              $out += "`n  [$($f.Severity)] $($f.Code) — $($f.Message)"
          }
      }
      return $out
  }

  if ($Path) {
      $skillMd = Resolve-SkillMdPath -InputPath $Path
      $result = Invoke-SkillEval -SkillMdPath $skillMd
      Format-SkillEvalResult -Result $result -AsJson:$Json | Write-Output
      if ($Strict -and ($result.Findings | Where-Object { $_.Severity -eq 'Critical' }).Count -gt 0) {
          exit 1
      }
      exit 0
  }
  ```

  **Run:** editar `eval.ps1` reemplazando el bloque final.
  **Expected:** archivo crece a ~140 líneas.

- [ ] **Step 6.4** — Correr Pester, los 6 tests pasan.

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 6 PASSED, 0 FAILED.

- [ ] **Step 6.5** — Commit (green).

  **Run:** `git add .cursor/skills/skill-quality-evaluator/scripts/ && git commit -m "feat(skill-eval): score frontmatter validity (4 anti-pattern codes, green)"`
  **Expected:** commit creado.

---

## Task 7 — Detector BLOATED_SKILL + MISSING_TRIGGER + MISSING_SECTION (red → green)

**Files touched:**
- Modify: `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1` (add 3 tests)
- Modify: `.cursor/skills/skill-quality-evaluator/scripts/eval.ps1` (extend Invoke-SkillEval)

### Steps

- [ ] **Step 7.1** — Append 3 tests Pester:

  ```powershell
  Describe 'eval.ps1 — body anti-patterns' {
      BeforeAll {
          $script:BloatedFixture = Join-Path $script:FixturesDir 'bloated-skill.md'
      }

      It 'flags BLOATED_SKILL on the bloated-skill fixture (>500 lines)' {
          $result = & pwsh -File $script:EvalScript -Path $script:BloatedFixture -Json | ConvertFrom-Json
          $codes = $result.Findings | ForEach-Object { $_.Code }
          $codes | Should -Contain 'BLOATED_SKILL'
      }

      It 'flags MISSING_TRIGGER when description has no use-when/trigger keyword pattern' {
          $tmpDir = Join-Path $env:TEMP "skill-eval-test-$(Get-Random)"
          New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
          $tmpSkill = Join-Path $tmpDir 'SKILL.md'
          @"
  ---
  name: no-trigger
  description: This skill does some useful generic things in the codebase.
  ---

  # No Trigger
  "@ | Set-Content $tmpSkill -Encoding UTF8

          $result = & pwsh -File $script:EvalScript -Path $tmpSkill -Json | ConvertFrom-Json
          $codes = $result.Findings | ForEach-Object { $_.Code }
          $codes | Should -Contain 'MISSING_TRIGGER'

          Remove-Item -Recurse -Force $tmpDir
      }

      It 'flags MISSING_SECTION when a required H2 section is absent' {
          $tmpDir = Join-Path $env:TEMP "skill-eval-test-$(Get-Random)"
          New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
          $tmpSkill = Join-Path $tmpDir 'SKILL.md'
          @"
  ---
  name: no-process
  description: Skill missing the Process section. Use when testing the section detector. Trigger: test.
  ---

  # No Process

  ## Goal
  Test fixture.

  ## When to use
  Always: in tests.

  ## Anti-patterns
  - None.
  "@ | Set-Content $tmpSkill -Encoding UTF8

          $result = & pwsh -File $script:EvalScript -Path $tmpSkill -Json | ConvertFrom-Json
          $codes = $result.Findings | ForEach-Object { $_.Code }
          $codes | Should -Contain 'MISSING_SECTION'

          Remove-Item -Recurse -Force $tmpDir
      }
  }
  ```

  **Run:** `Add-Content` con el bloque.
  **Expected:** archivo Tests.ps1 ~145 líneas.

- [ ] **Step 7.2** — Correr Pester, los 3 nuevos tests fallan.

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 6 PASSED, 3 FAILED.

- [ ] **Step 7.3** — Extender `Invoke-SkillEval` en `eval.ps1`. Insertar las nuevas comprobaciones después del bloque de frontmatter (antes del `return`):

  ```powershell
      # --- Body checks ---
      $allLines = Get-Content -Path $SkillMdPath -Encoding UTF8
      # Find frontmatter end (second '---' line)
      $bodyStartIdx = 0
      $dashCount = 0
      for ($i = 0; $i -lt $allLines.Count; $i++) {
          if ($allLines[$i] -match '^---\s*$') {
              $dashCount++
              if ($dashCount -eq 2) { $bodyStartIdx = $i + 1; break }
          }
      }
      $bodyLines = if ($bodyStartIdx -gt 0) { $allLines[$bodyStartIdx..($allLines.Count - 1)] } else { $allLines }
      $bodyLineCount = $bodyLines.Count

      if ($bodyLineCount -gt 500) {
          $findings += [pscustomobject]@{ Severity='Important'; Code='BLOATED_SKILL'; Message="Body is $bodyLineCount lines (soft cap 500). Split into references/, scripts/, or assets/." }
          $score -= 15
      }

      # MISSING_TRIGGER: description should hint at when to use the skill.
      if ($frontmatter -and (Test-DescriptionValid -Description $frontmatter.description)) {
          $desc = $frontmatter.description.ToLower()
          $triggerHints = @('use when', 'use whenever', 'use before', 'use after', 'always', 'trigger', 'invoke')
          $hasTrigger = $false
          foreach ($hint in $triggerHints) {
              if ($desc.Contains($hint)) { $hasTrigger = $true; break }
          }
          if (-not $hasTrigger) {
              $findings += [pscustomobject]@{ Severity='Important'; Code='MISSING_TRIGGER'; Message="description should include a 'use when…' phrase or trigger keywords. Agents won't know when to fire this skill otherwise." }
              $score -= 15
          }
      }

      # MISSING_SECTION: check for required H2 sections.
      $requiredSections = @('Goal', 'When to use', 'Process', 'Anti-patterns')
      $sectionLines = $bodyLines | Where-Object { $_ -match '^##\s+(.+)\s*$' } | ForEach-Object {
          if ($_ -match '^##\s+(.+?)\s*$') { $matches[1].Trim() } else { $null }
      } | Where-Object { $_ }
      foreach ($req in $requiredSections) {
          $found = $false
          foreach ($sec in $sectionLines) {
              if ($sec -like "*$req*") { $found = $true; break }
          }
          if (-not $found) {
              $findings += [pscustomobject]@{ Severity='Important'; Code='MISSING_SECTION'; Message="Required H2 section '$req' not found." }
              $score -= 10
          }
      }
  ```

  **Run:** insertar el bloque anterior dentro de `Invoke-SkillEval` justo antes de `return [pscustomobject]@{ ... }`.
  **Expected:** `eval.ps1` crece a ~190 líneas.

- [ ] **Step 7.4** — Correr Pester, los 9 tests pasan.

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 9 PASSED, 0 FAILED.

- [ ] **Step 7.5** — Commit (green).

  **Run:** `git add .cursor/skills/skill-quality-evaluator/scripts/ && git commit -m "feat(skill-eval): add BLOATED_SKILL, MISSING_TRIGGER, MISSING_SECTION detectors"`
  **Expected:** commit creado.

---

## Task 8 — Modo `-All` (escanear todos los skills) y resumen agregado

**Files touched:**
- Modify: `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1` (add 1 test)
- Modify: `.cursor/skills/skill-quality-evaluator/scripts/eval.ps1` (handle -All)

### Steps

- [ ] **Step 8.1** — Test Pester para modo `-All`:

  ```powershell
  Describe 'eval.ps1 — batch mode' {
      It '-All scans every skill under .cursor/skills/ and emits a summary' {
          $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
          Push-Location $repoRoot
          try {
              $output = & pwsh -File $script:EvalScript -All -Json | ConvertFrom-Json
              $output.SkillCount | Should -BeGreaterThan 10
              $output.Results | Should -Not -BeNullOrEmpty
              $output.AverageScore | Should -BeGreaterThan 0
          } finally {
              Pop-Location
          }
      }
  }
  ```

  **Run:** `Add-Content` con el bloque.
  **Expected:** Tests.ps1 ~165 líneas.

- [ ] **Step 8.2** — Correr Pester, el nuevo test falla.

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 9 PASSED, 1 FAILED.

- [ ] **Step 8.3** — Implementar modo `-All` en `eval.ps1`. Reemplazar el bloque final `if ($Path) { ... }` por:

  ```powershell
  if ($All) {
      $skillsDir = Join-Path (Get-Location) '.cursor\skills'
      if (-not (Test-Path $skillsDir)) {
          Write-Error "Cannot find .cursor/skills/ from current directory: $(Get-Location). Run from repo root."
          exit 2
      }
      $allSkillMds = Get-ChildItem -Path $skillsDir -Recurse -Filter 'SKILL.md' -File
      $results = @()
      foreach ($md in $allSkillMds) {
          $results += Invoke-SkillEval -SkillMdPath $md.FullName
      }
      $summary = [pscustomobject]@{
          SkillCount   = $results.Count
          AverageScore = if ($results.Count -gt 0) { [Math]::Round((($results | Measure-Object -Property Score -Average).Average), 1) } else { 0 }
          WorstSkills  = ($results | Sort-Object Score | Select-Object -First 5 | ForEach-Object { @{ Path=$_.Path; Score=$_.Score; FindingCount=$_.Findings.Count } })
          Results      = $results
      }
      if ($Json) {
          $summary | ConvertTo-Json -Depth 6 | Write-Output
      } else {
          Write-Output "===== Skill Quality Report ====="
          Write-Output "Skills evaluated: $($summary.SkillCount)"
          Write-Output "Average score: $($summary.AverageScore)/100"
          Write-Output ""
          Write-Output "By skill (lowest first):"
          foreach ($r in ($results | Sort-Object Score)) {
              $rel = $r.Path -replace [regex]::Escape((Get-Location).Path + [System.IO.Path]::DirectorySeparatorChar), ''
              Write-Output ("  {0,3}/100  {1,2} findings  {2}" -f $r.Score, $r.Findings.Count, $rel)
          }
      }
      if ($Strict) {
          $criticalCount = ($results | ForEach-Object { $_.Findings } | Where-Object { $_.Severity -eq 'Critical' }).Count
          if ($criticalCount -gt 0) { exit 1 }
      }
      exit 0
  }

  if ($Path) {
      $skillMd = Resolve-SkillMdPath -InputPath $Path
      $result = Invoke-SkillEval -SkillMdPath $skillMd
      Format-SkillEvalResult -Result $result -AsJson:$Json | Write-Output
      if ($Strict -and ($result.Findings | Where-Object { $_.Severity -eq 'Critical' }).Count -gt 0) {
          exit 1
      }
      exit 0
  }
  ```

  **Run:** reemplazar el bloque final de `eval.ps1` con el anterior.
  **Expected:** `eval.ps1` ~245 líneas.

- [ ] **Step 8.4** — Correr Pester. Los 10 tests pasan.

  **Run:** `Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`
  **Expected:** 10 PASSED, 0 FAILED.

- [ ] **Step 8.5** — Smoke test manual: correr `-All` desde repo root.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All`
  **Expected:** texto formateado con count, average score, lista por skill ordenada ascendente.

- [ ] **Step 8.6** — Commit (green).

  **Run:** `git add .cursor/skills/skill-quality-evaluator/scripts/ && git commit -m "feat(skill-eval): add -All batch mode with aggregated summary"`
  **Expected:** commit creado.

---

## Task 9 — Eat-your-own-dog-food: completar `SKILL.md` (9 secciones)

**Files touched:**
- Modify: `.cursor/skills/skill-quality-evaluator/SKILL.md` (replace placeholder body)

### Steps

- [ ] **Step 9.1** — Sobrescribir `SKILL.md` con cuerpo completo (frontmatter ya válido del Task 1):

  ```markdown
  ---
  name: skill-quality-evaluator
  description: Static analysis lint for MASTERMIND skills. Evaluates SKILL.md files against the canonical 9-section template, validates YAML frontmatter (name, description), enforces line-count budget (≤500), and detects four anti-patterns (BLOATED_SKILL, MISSING_TRIGGER, EMPTY_DESCRIPTION, MISSING_SECTION). Use when adding a new skill, refactoring an existing one, auditing the skill library, or before merging any PR that touches .cursor/skills/. Produces a per-skill score (0-100) and a list of findings. Runs as PowerShell CLI with no external dependencies. Trigger keywords: "evaluate skill", "lint skill", "skill quality", "audit skills", "score skill".
  ---

  # Skill Quality Evaluator

  ## Goal

  Provide a deterministic, dependency-free, repeatable way to score the quality of any MASTERMIND skill. The evaluator answers: "Does this `SKILL.md` follow the conventions agreed in `skill-creator` and the agentskills.io spec?" — without invoking any LLM, without network access, without third-party tooling beyond PowerShell + Pester.

  Adapted from the `PluginEval` framework of `wshobson/agents` (research/06-subagent-collections.md). MASTERMIND-native v1 covers static analysis only. Semantic evaluation (LLM-judge layer) is a possible v2.

  ## When to use

  **Always:**
  - Before committing a new skill (`skill-creator` produces it → evaluator scores it).
  - After refactoring an existing skill (length, sections, frontmatter all changed).
  - During quarterly stocktakes of the skill library.
  - Before promoting a skill into the canonical template (MASTERMIND release).

  **Trigger keywords:** "evaluate skill", "lint skill", "skill quality", "audit skills", "score skill", "skill score", "skill linter".

  **Do NOT use for:**
  - Evaluating semantic correctness ("does this skill actually trigger when it should?"). That requires v2 with LLM-judge.
  - Scoring rules, workflows, or commands (different artifacts, different schema).
  - Replacing human review of the skill content. The evaluator is structural; the human is semantic.

  ## Prerequisites

  - PowerShell 7+ (`pwsh`).
  - Pester 5+ for running the test suite (`Install-Module Pester -Force`). Not required to run the evaluator itself.
  - Run from repo root for `-All` mode (the script looks for `.cursor/skills/` relative to current directory).

  ## Process

  ### Single skill

  ```powershell
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 `
       -Path .cursor/skills/<skill-name>
  ```

  Or pointing to the `SKILL.md` directly:

  ```powershell
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 `
       -Path .cursor/skills/<skill-name>/SKILL.md
  ```

  ### Batch mode (all skills)

  ```powershell
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All
  ```

  Emits a sorted report (lowest score first) plus average score across the library.

  ### JSON output (for tooling)

  Add `-Json` to either mode:

  ```powershell
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All -Json `
      | Set-Content reports/skill-quality-2026-05-03.json
  ```

  ### CI / strict mode

  Add `-Strict` to make the script exit 1 if any Critical finding is present:

  ```powershell
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All -Strict
  ```

  Use this if integrating into a pre-commit or CI hook (deferred for v1; see `research/06-subagent-collections.md`).

  ### Anti-patterns detected (v1)

  | Code | Severity | Trigger | Penalty |
  |---|---|---|---|
  | `MISSING_FRONTMATTER` | Critical | No `---` YAML frontmatter at top of file | -50 |
  | `INVALID_NAME` | Critical | name violates `^[a-z0-9]+(-[a-z0-9]+)*$`, exceeds 64 chars, or contains `anthropic`/`claude` | -25 |
  | `EMPTY_DESCRIPTION` | Critical | description missing or >1024 chars | -25 |
  | `BLOATED_SKILL` | Important | Body >500 lines (excluding frontmatter) | -15 |
  | `MISSING_TRIGGER` | Important | description has no "use when…" or trigger keyword phrase | -15 |
  | `MISSING_SECTION` | Important | Required H2 section absent (Goal / When to use / Process / Anti-patterns) | -10 each |

  See `references/anti-patterns.md` for examples and rationale per anti-pattern.

  ### Score interpretation

  - **90-100** — Production quality. Ship.
  - **75-89** — Acceptable, has Important findings. Schedule fixes.
  - **0-74** — Critical findings. Block merge until addressed.

  ## Outputs

  - **Stdout (default):** human-readable report with per-skill score and findings.
  - **Stdout (`-Json`):** structured object with `Path`, `Score`, `Findings[]`. In `-All` mode also includes `SkillCount`, `AverageScore`, `WorstSkills[]`, `Results[]`.
  - **Exit code:** 0 on success; 1 with `-Strict` if any Critical finding; 2 on usage error.
  - **No file writes.** The evaluator never modifies skills — it only reports.

  ## Interactions with other skills

  - **Invoked by:** `skill-creator` (after creating or editing any skill); maintainer during quarterly stocktakes; CI gate (deferred — see plan amendment).
  - **Invokes:** none (pure analysis, no side effects).
  - **Pairs with:** `code-reviewer` (skills are code-like artifacts — review semantically while evaluator checks structurally).

  ## Completion checklist

  - [ ] Frontmatter present and parseable.
  - [ ] All 9 MASTERMIND sections present.
  - [ ] Body ≤ 500 lines (or split into `references/` + `scripts/`).
  - [ ] Pester suite passes (`Invoke-Pester .cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`).
  - [ ] Self-evaluation score ≥ 90 (`pwsh -File scripts/eval.ps1 -Path .cursor/skills/skill-quality-evaluator`).

  ## Anti-patterns

  - **Avoid:** Adding semantic evaluation (LLM-judge) to v1. That belongs in v2 to keep v1 deterministic.
  - **Avoid:** Calibrating thresholds (line count, penalty) before observing real-world output for at least 4 weeks.
  - **Avoid:** Wiring the evaluator into a pre-commit hook before falsing-positives are mapped. Trust in the hook system is fragile; do not contaminate.
  - **Avoid:** Adding new anti-pattern codes without first observing the pattern at least 3 times across real skills. Heuristics tuned to one example overfit.
  - **Avoid:** Writing fixtures that test multiple anti-patterns at once. One fixture, one anti-pattern.
  ```

  **Run:** `Set-Content .cursor/skills/skill-quality-evaluator/SKILL.md ...` con el contenido anterior.
  **Expected:** `(Get-Content .cursor/skills/skill-quality-evaluator/SKILL.md).Count` retorna ~120 líneas.

- [ ] **Step 9.2** — Eat-your-own-dog-food: evaluar el skill con su propio script.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/skill-quality-evaluator`
  **Expected:** Score ≥ 90, 0 findings Critical, máximo 1 finding Important.

- [ ] **Step 9.3** — Commit (green).

  **Run:** `git add .cursor/skills/skill-quality-evaluator/SKILL.md && git commit -m "docs(skill-eval): write canonical SKILL.md with all 9 sections"`
  **Expected:** commit creado.

---

## Task 10 — Catálogo de anti-patterns (referencia)

**Files touched:**
- Create: `.cursor/skills/skill-quality-evaluator/references/anti-patterns.md`

### Steps

- [ ] **Step 10.1** — Escribir el catálogo:

  ```markdown
  # Anti-patterns detected by skill-quality-evaluator (v1)

  Each anti-pattern below has a code, a severity, a detection rule, an example of what triggers it, and how to fix.

  ---

  ## MISSING_FRONTMATTER (Critical, -50)

  **Detection:** The SKILL.md file does not start with a YAML frontmatter block delimited by `---` lines.

  **Why it matters:** Frontmatter is the only mechanism agents use to discover and decide whether to activate a skill. Without it, the skill is invisible.

  **Trigger example:**

  ```markdown
  # My Skill

  ## Goal
  ...
  ```

  **Fix:** Add YAML frontmatter at the very top:

  ```markdown
  ---
  name: my-skill
  description: What it does and when to use it. Trigger keywords: ...
  ---

  # My Skill
  ```

  ---

  ## INVALID_NAME (Critical, -25)

  **Detection:** The `name` field violates the agentskills.io spec rules:

  - Must match `^[a-z0-9]+(-[a-z0-9]+)*$` (lowercase letters, digits, single hyphens).
  - Maximum 64 characters.
  - Must NOT contain the reserved tokens `anthropic` or `claude`.

  **Trigger examples:**

  - `name: My_Skill` — uppercase + underscore.
  - `name: claude-helper` — contains `claude`.
  - `name: -leading-hyphen` — leading hyphen.
  - `name: this-name-is-way-too-long-and-will-exceed-the-sixty-four-char-limit` — too long.

  **Fix:** Rename to a valid kebab-case identifier under 64 chars without `anthropic`/`claude`.

  ---

  ## EMPTY_DESCRIPTION (Critical, -25)

  **Detection:** The `description` field is missing, empty, or longer than 1024 chars.

  **Why it matters:** The description is the single most consequential field — it determines when the skill activates. An empty description makes the skill un-fireable; a too-long one wastes context.

  **Trigger example:**

  ```yaml
  ---
  name: my-skill
  description:
  ---
  ```

  **Fix:** Write 50-200 words that describe what + when, including 3-6 trigger keywords.

  ---

  ## BLOATED_SKILL (Important, -15)

  **Detection:** The body of the SKILL.md (excluding frontmatter) exceeds 500 lines.

  **Why it matters:** Skills are loaded into the agent's context. Bloated skills consume tokens disproportionately and reduce the agent's ability to keep relevant information in mind.

  **Trigger example:** A SKILL.md with 800 lines of detailed examples inline.

  **Fix:** Split content into:

  - `references/<topic>.md` — detailed reference material loaded only when needed.
  - `scripts/<name>.ps1` — executable code (the script runs, the script body never enters context).
  - `assets/<name>` — templates and fixtures.

  Keep the main SKILL.md under 300 lines (target) or 500 lines (hard cap).

  ---

  ## MISSING_TRIGGER (Important, -15)

  **Detection:** The `description` does not contain any of: `use when`, `use whenever`, `use before`, `use after`, `always`, `trigger`, `invoke`.

  **Why it matters:** Without an explicit "when to use" cue, the agent has to infer activation, which is unreliable. Agents over-trigger or under-trigger silent-spec skills.

  **Trigger example:**

  ```yaml
  description: This skill helps with various coding tasks in the codebase.
  ```

  **Fix:** Rewrite with explicit trigger:

  ```yaml
  description: Reviews code changes before merge. Use when the user asks for a review, after implementation-planner produces code, or before any merge to main. Trigger keywords: review, audit, lgtm, ready to merge.
  ```

  ---

  ## MISSING_SECTION (Important, -10 each)

  **Detection:** A required H2 section is absent. Required sections: `Goal`, `When to use`, `Process`, `Anti-patterns`.

  **Why it matters:** The MASTERMIND 9-section template makes skills predictable and composable. Skills missing core sections produce inconsistent behavior across the library.

  **Trigger example:** A SKILL.md with `## Goal` and `## When to use` but no `## Process` and no `## Anti-patterns`.

  **Fix:** Add the missing sections. See `.cursor/skills/skill-creator/SKILL.md` Step 2 for the canonical 9-section layout.

  ---

  ## What v1 deliberately does NOT detect

  - Semantic accuracy of triggering (does the skill actually fire when it should? — needs LLM-judge).
  - Scope drift between description and process (description says X, process does Y).
  - Code template quality inside skills (snippets that won't compile).
  - Cross-references to non-existent files (ORPHAN_REFERENCE — possible v1.1).
  - Skill-to-skill graph coherence (DEAD_CROSS_REF — possible v1.1).

  These belong to v2 (LLM-judge) or to manual review.
  ```

  **Run:** `Set-Content .cursor/skills/skill-quality-evaluator/references/anti-patterns.md ...` con el contenido anterior.
  **Expected:** archivo ~140 líneas.

- [ ] **Step 10.2** — Commit.

  **Run:** `git add .cursor/skills/skill-quality-evaluator/references/anti-patterns.md && git commit -m "docs(skill-eval): document the 6 v1 anti-patterns with examples"`
  **Expected:** commit creado.

---

## Task 11 — Baseline: scoring de los 21 skills existentes

**Files touched:**
- Create: `.cursor/plans/baselines/2026-05-03-skill-baseline.txt`

### Steps

- [ ] **Step 11.1** — Crear directorio de baselines y correr el evaluator en modo `-All`, capturando salida.

  ```powershell
  New-Item -ItemType Directory -Path ".cursor/plans/baselines" -Force | Out-Null
  pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All `
      | Tee-Object -FilePath .cursor/plans/baselines/2026-05-03-skill-baseline.txt
  ```

  **Run:** las dos líneas en pwsh.
  **Expected:** archivo `.cursor/plans/baselines/2026-05-03-skill-baseline.txt` existe con el reporte completo. Stdout muestra ~22 skills evaluados (21 existentes + el nuevo).

- [ ] **Step 11.2** — Identificar los 3 skills con score más bajo. Anotar en el propio archivo de baseline al final, después de la salida automática:

  ```
  ===== Notes (manual, post-baseline) =====
  Plan B candidates (worst-3 by score):
  1. <skill-name>  (<score>/100)  → primary refactor target
  2. <skill-name>  (<score>/100)
  3. <skill-name>  (<score>/100)
  ```

  **Run:** `Add-Content` con los 3 skills más bajos (sustituir `<skill-name>` y `<score>` con los valores reales del paso 11.1).
  **Expected:** archivo de baseline contiene tanto el reporte automático como las notas manuales.

- [ ] **Step 11.3** — Commit baseline.

  **Run:** `git add .cursor/plans/baselines/ && git commit -m "chore(skill-eval): capture 2026-05-03 baseline of 21 skills"`
  **Expected:** commit creado.

---

## Task 12 — Actualizar `skill-creator` (declarar interacción) y memoria

**Files touched:**
- Modify: `.cursor/skills/skill-creator/SKILL.md` (Section 7 "Interactions" — add peer)
- Modify: `memory/07-decisions-log.md` (append decision)
- Modify: `memory/02-current-state.md` (reflect skill-quality-evaluator in inventory)

### Steps

- [ ] **Step 12.1** — Editar `.cursor/skills/skill-creator/SKILL.md` Section 7 ("Interactions with other skills"). Añadir bullet en `Pairs with`:

  Buscar la línea actual:

  ```markdown
  - **Pairs with:** `code-reviewer` — skills are code-like artifacts; review before merging.
  ```

  Reemplazarla por:

  ```markdown
  - **Pairs with:** `code-reviewer` — skills are code-like artifacts; review before merging.
  - **Pairs with:** `skill-quality-evaluator` — runs static analysis on every new or edited skill; reports findings + score before commit. Use as the structural complement to `code-reviewer`'s semantic review.
  ```

  **Run:** `StrReplace` o edición manual en el archivo.
  **Expected:** Section 7 contiene la nueva línea sobre `skill-quality-evaluator`.

- [ ] **Step 12.2** — Append entry a `memory/07-decisions-log.md`:

  ```markdown

  ### 2026-05-03 — Added skill `skill-quality-evaluator` (PluginEval-inspired, static-only v1)
  - **Decision:** Adopt a MASTERMIND-native skill `skill-quality-evaluator` that statically analyses every `SKILL.md` for frontmatter validity, line-count budget, required sections, and 6 anti-patterns. Pure PowerShell, zero external dependencies, zero LLM calls. Adapted from the PluginEval framework of `wshobson/agents` (research/06-subagent-collections.md).
  - **Reason:** MASTERMIND has 21 skills with no automated quality measure. Skill drift (bloating, missing triggers, missing sections) is invisible until it bites. Static evaluation closes that blind spot without adding cost or external dependency. The PluginEval framework was the only piece of `wshobson/agents` that filled a unique gap; the rest of the marketplace duplicates existing MASTERMIND skills.
  - **Alternatives considered:**
    - Install `wshobson/agents` as plugin marketplace and use their PluginEval directly — rejected: cantidad ≠ calidad; importar 80 plugins más rompe el inventario opinionated; PluginEval requiere `uv` + Python.
    - Adopt LLM-judge layer in v1 (semantic evaluation) — deferred to v2 after observing 4-8 weeks of static output. Rationale: deterministic foundation first; non-determinism only when justified by observed gap.
    - Wire evaluator into pre-commit hook in v1 — deferred to a later PR after calibrating thresholds against real-world output for 4 weeks. Rationale: pre-commit hook trust is sacred; never gate with an unvalidated tool.
  - **Consequences:**
    - New skill `.cursor/skills/skill-quality-evaluator/` with SKILL.md + scripts/eval.ps1 + scripts/eval.Tests.ps1 + references/anti-patterns.md + 2 fixtures.
    - `skill-creator` Section 7 now declares `skill-quality-evaluator` as peer.
    - First baseline of the 21 existing skills captured at `.cursor/plans/baselines/2026-05-03-skill-baseline.txt`.
    - `.claude/skills/skill-quality-evaluator/` mirror created via `scripts/sync-skills.ps1`.
    - Total skill count: 21 → 22 (15 System 1 + 7 System 2 — `skill-quality-evaluator` joins System 2 as a quality gate).
    - Plan B (`adopt-tob-patterns`) becomes possible: refactor the 3 worst-scoring skills using Trail of Bits patterns and measure improvement with this evaluator.
  - **Files affected:** `.cursor/skills/skill-quality-evaluator/SKILL.md`, `.cursor/skills/skill-quality-evaluator/scripts/eval.ps1`, `.cursor/skills/skill-quality-evaluator/scripts/eval.Tests.ps1`, `.cursor/skills/skill-quality-evaluator/references/anti-patterns.md`, `.cursor/skills/skill-quality-evaluator/references/fixtures/valid-skill.md`, `.cursor/skills/skill-quality-evaluator/references/fixtures/bloated-skill.md`, `.cursor/skills/skill-creator/SKILL.md`, `memory/02-current-state.md`, `.cursor/plans/2026-05-03-build-skill-quality-evaluator.md`, `.cursor/plans/baselines/2026-05-03-skill-baseline.txt`. Plus `.claude/skills/skill-quality-evaluator/**` mirror via `scripts/sync-skills.ps1`.
  ```

  **Run:** `Add-Content memory/07-decisions-log.md` con el bloque anterior.
  **Expected:** decisión añadida al final del archivo.

- [ ] **Step 12.3** — Editar `memory/02-current-state.md`. Reemplazar el `_TBD_` debajo de "What exists today" por:

  ```markdown
  - 22 skills (15 System 1 + 7 System 2). Latest addition: `skill-quality-evaluator` (2026-05-03) — static-analysis lint for skill quality.
  - Baseline of skill quality: `.cursor/plans/baselines/2026-05-03-skill-baseline.txt`.
  ```

  Y reemplazar el `_TBD_` debajo de "What is next" por:

  ```markdown
  - Plan B (`adopt-tob-patterns`): refactor the 3 worst-scoring skills using Trail of Bits patterns (blast radius in `code-reviewer`, First Principles + 5 Whys in `project-deep-audit`, Insecure Defaults + Rationalizations to Reject in `security-review`). Use `skill-quality-evaluator` to measure before/after.
  ```

  **Run:** `StrReplace` en `memory/02-current-state.md` para los dos `_TBD_`.
  **Expected:** archivo refleja el nuevo estado.

- [ ] **Step 12.4** — Commit memory + skill-creator update.

  **Run:** `git add memory/07-decisions-log.md memory/02-current-state.md .cursor/skills/skill-creator/SKILL.md && git commit -m "docs(memory): log skill-quality-evaluator adoption + update peer skill"`
  **Expected:** commit creado.

---

## Task 13 — Sync mirror y verificación final

**Files touched:**
- Create (vía script): `.claude/skills/skill-quality-evaluator/**` (mirror automático)
- Modify (vía script): `.claude/skills/skill-creator/SKILL.md` (mirror del Step 12.1)

### Steps

- [ ] **Step 13.1** — Correr el sync script.

  **Run:** `pwsh -File scripts/sync-skills.ps1`
  **Expected:** stdout reporta files copiados; `Test-Path .claude/skills/skill-quality-evaluator/SKILL.md` retorna `True`.

- [ ] **Step 13.2** — Verificar drift cero.

  **Run:** `pwsh -File scripts/sync-skills.ps1 -Check`
  **Expected:** exit code 0, mensaje "in sync".

- [ ] **Step 13.3** — Self-evaluation final: el script evalúa su propio skill desde la raíz del repo.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -Path .cursor/skills/skill-quality-evaluator`
  **Expected:** Score ≥ 90, 0 findings Critical.

- [ ] **Step 13.4** — Re-run del baseline tras añadir el propio skill.

  **Run:** `pwsh -File .cursor/skills/skill-quality-evaluator/scripts/eval.ps1 -All`
  **Expected:** SkillCount = 22 (los 21 originales + el nuevo).

- [ ] **Step 13.5** — Commit final del mirror.

  **Run:** `git add .claude/skills/ && git commit -m "chore(sync): mirror skill-quality-evaluator to .claude/skills/"`
  **Expected:** commit creado, `git status` clean.

---

## Self-review (Step 4 of skill)

Pase de revisión sobre el plan ANTES de ejecutar.

1. **Success criteria coverage** — Cada checkbox de "Success criteria" mapea a una task concreta:
   - SKILL.md válido + 9 secciones → Task 9.
   - eval.ps1 single-skill mode → Task 6.
   - eval.ps1 -All mode → Task 8.
   - 12 tests Pester pasan → Task 4 + 6 + 7 + 8.
   - Self-evaluation ≥ 90 → Task 13.3.
   - Baseline de 21 skills → Task 11.
   - Mirror sync → Task 13.
   - memory/07 actualizado → Task 12.2.
   - memory/02 actualizado → Task 12.3.
   - skill-creator interacción → Task 12.1.
   ✅ Sin gaps.

2. **Placeholder scan** — `grep -E "TBD|TODO|<fill|placeholder"` en este archivo: ninguna mención sustantiva (las que aparecen están en código de fixtures intencionales o en el bloque de comentarios). ✅

3. **Type consistency** — Función `Invoke-SkillEval` retorna `[pscustomobject]@{ Path; Score; Findings }` consistentemente en Tasks 5/6/7/8. Función `Get-SkillFrontmatter` retorna `[pscustomobject]` con campos dinámicos del YAML. Anti-pattern codes son strings constantes (`'BLOATED_SKILL'`, etc.) usados idénticamente en script y tests. ✅

4. **Error paths** — `FILE_NOT_FOUND` está cubierto en `Invoke-SkillEval` (Task 6.3). `MISSING_FRONTMATTER` cubierto en Task 6.3. Modo `-All` valida que `.cursor/skills/` exista y emite error claro (Task 8.3). Tests Pester cubren casos negativos (frontmatter inválido, name inválido, descripción vacía, bloated, missing trigger, missing section). ✅

5. **Test first** — Cada Task con cambio en `eval.ps1` (Tasks 6, 7, 8) tiene un Step previo que escribe el test failing y verifica que falla (`6.2`, `7.2`, `8.2`) ANTES del Step de implementación (`6.3`, `7.3`, `8.3`). ✅

6. **Size check** — Tasks van de 2 a 5 minutos cada una. Las más largas (6, 7, 8) tienen 5-6 steps cada una, total ~10 min cada una — aceptable. Si alguna se siente larga durante ejecución, split en dos. ✅

7. **Dependency check** — Pester 5+ documentado como prerrequisito. PowerShell 7+ documentado. Sin dependencias de librerías de terceros. Sin llamadas a APIs externas. ✅

---

## Execution

**Option A — Subagent-driven (recomendado para 13 tasks):**
Hand off a `subagent-dispatcher`. Un subagent fresh por task con two-stage review (spec compliance + code quality) antes de avanzar. Costo extra de orquestación, máxima disciplina TDD.

**Option B — Parallel via worktrees (NO aplicable aquí):**
Las tasks son secuenciales (cada una depende del estado dejado por la anterior). No hay rama de paralelización útil. **Descartar.**

**Option C — Inline execution (Cursor Plan Mode):**
Cursor ejecuta las 13 tasks en esta misma sesión con checkpoint tras cada commit. Recomendado si quieres ver el trabajo en vivo y ajustar sobre la marcha.

**Option D — Cloud agent / background run:**
Branch creada, tasks dispatcheadas a Cursor Cloud Agent o similar, PR abierto cuando todas las tasks están verdes. Para desconectar y revisar asincrónicamente. Requiere setup que MASTERMIND aún no tiene formalizado.

**Option E — Human execution:**
Tú ejecutas cada task; el agente asiste on-demand. Recomendado si quieres aprender el código del evaluator a fondo (es el núcleo del sistema de quality gates futuro).

**Compatibility note for `task-master-ai`:** Si decides activarlo (no instalado por defecto), este plan es PRD-compatible. Run `parse-prd .cursor/plans/2026-05-03-build-skill-quality-evaluator.md --append` y task-master genera `.taskmaster/tasks.json`.

---

## Amendment log

(Vacío al inicio. Si el plan necesita cambios mid-execution, append `## Amendment YYYY-MM-DD` con razón + tasks afectadas.)
