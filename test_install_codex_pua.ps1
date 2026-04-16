Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'install-codex-pua.ps1' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot 'install-codex-pua.ps1'
        $repoRoot = $PSScriptRoot
        $sourceSkill = Join-Path $repoRoot 'codex\pua\SKILL.md'
        $sourcePrompt = Join-Path $repoRoot 'commands\pua.md'
    }

    BeforeEach {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
        $codexHome = Join-Path $tempRoot '.codex'
        New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    }

    AfterEach {
        if (Test-Path $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }

    It 'installs the local Codex skill and prompt into a custom Codex home' {
        & $scriptPath -CodexHome $codexHome

        $installedSkill = Join-Path $codexHome 'skills\pua\SKILL.md'
        $installedPrompt = Join-Path $codexHome 'prompts\pua.md'

        Test-Path $installedSkill | Should Be $true
        Test-Path $installedPrompt | Should Be $true
        (Get-Content -Raw $installedSkill) | Should Be (Get-Content -Raw $sourceSkill)
        (Get-Content -Raw $installedPrompt) | Should Be (Get-Content -Raw $sourcePrompt)
    }

    It 'replaces an existing install when -Force is used' {
        & $scriptPath -CodexHome $codexHome

        $installedPrompt = Join-Path $codexHome 'prompts\pua.md'
        Set-Content -LiteralPath $installedPrompt -Value 'stale prompt'

        & $scriptPath -CodexHome $codexHome -Force

        (Get-Content -Raw $installedPrompt) | Should Be (Get-Content -Raw $sourcePrompt)
    }
}
