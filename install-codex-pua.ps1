param(
    [string]$CodexHome = (Join-Path $env:USERPROFILE '.codex'),
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
$SourceSkillDir = Join-Path $RepoRoot 'codex\pua'
$SourceSkillFile = Join-Path $SourceSkillDir 'SKILL.md'
$SourcePromptFile = Join-Path $RepoRoot 'commands\pua.md'

$SkillsDir = Join-Path $CodexHome 'skills'
$PromptsDir = Join-Path $CodexHome 'prompts'
$InstalledSkillDir = Join-Path $SkillsDir 'pua'
$InstalledPromptFile = Join-Path $PromptsDir 'pua.md'

function Assert-PathExists([string]$Path, [string]$Description) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Description not found: $Path"
    }
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Remove-InstallTarget([string]$Path, [string]$Description) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    if (-not $Force) {
        throw "$Description already exists: $Path`nRe-run with -Force to replace it."
    }

    Remove-Item -LiteralPath $Path -Recurse -Force
}

function New-Junction([string]$LinkPath, [string]$TargetPath) {
    $command = 'mklink /J "{0}" "{1}"' -f $LinkPath, $TargetPath
    cmd /c $command | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create junction: $LinkPath -> $TargetPath"
    }
}

function New-HardLink([string]$LinkPath, [string]$TargetPath) {
    $command = 'mklink /H "{0}" "{1}"' -f $LinkPath, $TargetPath
    cmd /c $command | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create hard link: $LinkPath -> $TargetPath"
    }
}

Assert-PathExists -Path $SourceSkillFile -Description 'Codex skill file'
Assert-PathExists -Path $SourcePromptFile -Description 'Prompt file'

Ensure-Directory -Path $CodexHome
Ensure-Directory -Path $SkillsDir
Ensure-Directory -Path $PromptsDir

Remove-InstallTarget -Path $InstalledSkillDir -Description 'Installed skill target'
Remove-InstallTarget -Path $InstalledPromptFile -Description 'Installed prompt file'

New-Junction -LinkPath $InstalledSkillDir -TargetPath $SourceSkillDir

$promptInstallMode = 'copy'
$sourcePromptRoot = [System.IO.Path]::GetPathRoot($SourcePromptFile)
$installedPromptRoot = [System.IO.Path]::GetPathRoot($InstalledPromptFile)
if ($sourcePromptRoot -eq $installedPromptRoot) {
    try {
        New-HardLink -LinkPath $InstalledPromptFile -TargetPath $SourcePromptFile
        $promptInstallMode = 'hard_link'
    } catch {
        Copy-Item -LiteralPath $SourcePromptFile -Destination $InstalledPromptFile -Force
    }
} else {
    # Windows hard links cannot span volumes, so fall back to copying when the
    # repo checkout and the user's Codex home live on different drives.
    Copy-Item -LiteralPath $SourcePromptFile -Destination $InstalledPromptFile -Force
}

$result = [pscustomobject][ordered]@{
    repo_root = $RepoRoot
    codex_home = $CodexHome
    installed_skill_dir = $InstalledSkillDir
    installed_skill_file = (Join-Path $InstalledSkillDir 'SKILL.md')
    installed_prompt_file = $InstalledPromptFile
    prompt_install_mode = $promptInstallMode
    verification = @(
        ('Test-Path "{0}"' -f (Join-Path $InstalledSkillDir 'SKILL.md')),
        ('Test-Path "{0}"' -f $InstalledPromptFile),
        'Type `$pua` or `/prompts:pua` in Codex after restarting it.'
    )
}

$result | ConvertTo-Json -Depth 4
