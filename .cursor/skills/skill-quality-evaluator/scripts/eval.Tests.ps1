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
