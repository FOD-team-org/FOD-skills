<#
FOD-skills installer (Windows PowerShell 5.1+).
Copies skills\*\ into Claude Code (%USERPROFILE%\.claude\skills) and/or Codex
($env:CODEX_HOME\skills, default %USERPROFILE%\.codex\skills). No network, no config edits.

Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1 [-Target claude|codex|both] [-Only a,b] [-DryRun] [-Project DIR]

  -Target   where to install skills (default: both)
  -Only     comma-separated skill names to install (default: all)
  -DryRun   print what would be done, change nothing
  -Project  install the codex-dev playbook (AGENTS.md, DECISIONS.md, ASSUMPTIONS.md)
            into DIR. With -Project, skills are installed only when -Target is also given.

Existing skill folders are skipped unless they contain a .fod-skills marker
(installed earlier by this script), in which case they are replaced.
#>
[CmdletBinding()]
param(
    [ValidateSet('claude', 'codex', 'both')]
    [string]$Target = 'both',
    [string[]]$Only = @(),
    [switch]$DryRun,
    [string]$Project = ''
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$MarkerFile = '.fod-skills'
$AgentsMarker = '<!-- fod-skills:codex-dev -->'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if ($DryRun) { Write-Host 'dry-run: no files will be changed' }

# ---- commit hash ---------------------------------------------------------
$Commit = 'unknown'
if (Get-Command git -ErrorAction SilentlyContinue) {
    $out = cmd /c "git -C `"$Root`" rev-parse HEAD 2>nul"
    if ($LASTEXITCODE -eq 0 -and $out) { $Commit = ([string]$out).Trim() }
}

# ---- user home -----------------------------------------------------------
$UserHome = $env:USERPROFILE
if (-not $UserHome) { $UserHome = $HOME }

# ---- skill list ----------------------------------------------------------
$AllSkills = @(Get-ChildItem -LiteralPath (Join-Path $Root 'skills') -Directory | ForEach-Object { $_.Name })

$Skills = @()
$wanted = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($wanted.Count -gt 0) {
    $missing = $false
    foreach ($w in $wanted) {
        if (Test-Path -LiteralPath (Join-Path (Join-Path $Root 'skills') $w) -PathType Container) {
            $Skills += $w
        } else {
            Write-Host "error: no such skill: $w"
            $missing = $true
        }
    }
    if ($missing) { exit 2 }
} else {
    $Skills = $AllSkills
}

function Write-Marker([string]$Dir) {
    [System.IO.File]::WriteAllText((Join-Path $Dir $MarkerFile), "$Commit`n", $Utf8NoBom)
}

function Install-Skills([string]$Dest) {
    $installed = 0; $updated = 0; $skipped = 0
    Write-Host "== skills -> $Dest"
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }
    foreach ($n in $Skills) {
        $src = Join-Path (Join-Path $Root 'skills') $n
        $dst = Join-Path $Dest $n
        if (Test-Path -LiteralPath $dst) {
            if (Test-Path -LiteralPath (Join-Path $dst $MarkerFile) -PathType Leaf) {
                if ($DryRun) { Write-Host "would update: $n" }
                else {
                    Remove-Item -LiteralPath $dst -Recurse -Force -Confirm:$false
                    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
                    Write-Marker $dst
                    Write-Host "update: $n"
                }
                $updated++
            } else {
                Write-Host "skip: $n"
                $skipped++
            }
        } else {
            if ($DryRun) { Write-Host "would install: $n" }
            else {
                Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
                Write-Marker $dst
                Write-Host "install: $n"
            }
            $installed++
        }
    }
    $prefix = ''; if ($DryRun) { $prefix = 'dry-run: ' }
    Write-Host "${prefix}installed $installed, updated $updated, skipped $skipped ($Dest)"
}

function Install-Project([string]$Dir) {
    $installed = 0; $updated = 0; $skipped = 0
    $pb = Join-Path (Join-Path $Root 'playbooks') 'codex-dev'
    Write-Host "== codex-dev playbook -> $Dir"
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) {
        Write-Host "error: project folder not found: $Dir"
        exit 2
    }
    $Dir = (Resolve-Path -LiteralPath $Dir).Path
    $agentsSrc = [System.IO.File]::ReadAllText((Join-Path $pb 'AGENTS.md'), $Utf8NoBom)
    $agentsDst = Join-Path $Dir 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $agentsDst -PathType Leaf)) {
        if ($DryRun) { Write-Host 'would create: AGENTS.md' }
        else {
            [System.IO.File]::WriteAllText($agentsDst, "$AgentsMarker`n`n$agentsSrc", $Utf8NoBom)
            Write-Host 'create: AGENTS.md'
        }
        $installed++
    } elseif ([System.IO.File]::ReadAllText($agentsDst).Contains($AgentsMarker)) {
        Write-Host 'skip: AGENTS.md (already appended)'
        $skipped++
    } else {
        if ($DryRun) { Write-Host 'would append: AGENTS.md' }
        else {
            [System.IO.File]::AppendAllText($agentsDst, "`n`n$AgentsMarker`n`n$agentsSrc", $Utf8NoBom)
            Write-Host 'append: AGENTS.md'
        }
        $updated++
    }
    foreach ($f in @('DECISIONS.md', 'ASSUMPTIONS.md')) {
        $dst = Join-Path $Dir $f
        if (Test-Path -LiteralPath $dst) {
            Write-Host "skip: $f"
            $skipped++
        } else {
            if ($DryRun) { Write-Host "would copy: $f" }
            else {
                Copy-Item -LiteralPath (Join-Path (Join-Path $pb 'templates') $f) -Destination $dst
                Write-Host "copy: $f"
            }
            $installed++
        }
    }
    $prefix = ''; if ($DryRun) { $prefix = 'dry-run: ' }
    Write-Host "${prefix}installed $installed, updated $updated, skipped $skipped ($Dir)"
}

$doSkills = $true
if ($Project -and -not $PSBoundParameters.ContainsKey('Target')) { $doSkills = $false }

if ($doSkills) {
    if ($Target -eq 'claude' -or $Target -eq 'both') {
        Install-Skills (Join-Path (Join-Path $UserHome '.claude') 'skills')
    }
    if ($Target -eq 'codex' -or $Target -eq 'both') {
        $codexHome = $env:CODEX_HOME
        if (-not $codexHome) { $codexHome = Join-Path $UserHome '.codex' }
        Install-Skills (Join-Path $codexHome 'skills')
    }
}

if ($Project) { Install-Project $Project }

if (-not $DryRun) { Write-Host 'done. Restart Claude Code / Codex to load new skills.' }
