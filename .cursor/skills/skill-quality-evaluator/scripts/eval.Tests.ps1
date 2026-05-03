#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0' }

BeforeAll {
    $script:EvalScript = Join-Path $PSScriptRoot 'eval.ps1'
    $fixturesRel = Join-Path $PSScriptRoot '..\references\fixtures'
    $script:FixturesDir = if (Test-Path $fixturesRel) { (Resolve-Path $fixturesRel).Path } else { $fixturesRel }
}

Describe 'eval.ps1 — basic invocation' {
    It 'exists at the expected path' {
        $script:EvalScript | Should -Exist
    }

    It 'is invokable and produces some output when called with no args' {
        $output = & pwsh -File $script:EvalScript 2>&1
        $LASTEXITCODE | Should -Not -BeNullOrEmpty
        $output | Should -Not -BeNullOrEmpty
    }
}

Describe 'eval.ps1 — frontmatter checks' {
    BeforeAll {
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
description: Has valid description but invalid uppercase name. Use when testing the name validator. Trigger keyword test.
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
description: Skill missing the Process section. Use when testing the section detector. Trigger test.
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
