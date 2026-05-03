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
