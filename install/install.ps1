# FOD-skills 설치 스크립트 (Windows PowerShell 5.1 이상)
#
# 사용법:
#   powershell -NoProfile -ExecutionPolicy Bypass -File install\install.ps1 [claude|codex|both] [--dry-run] [--home <dir>] [--project <dir>]
#
#   claude|codex|both  스킬을 복사할 대상. 기본 both
#   --dry-run          무엇을 할지만 출력하고 아무것도 쓰지 않는다
#   --home <dir>       홈 경로 대신 쓸 폴더(테스트용). 주면 CODEX_HOME은 무시하고 <dir>\.codex를 쓴다
#   --project <dir>    그 폴더에 codex-dev 묶음(AGENTS.md, DECISIONS.md, ASSUMPTIONS.md)도 설치한다
#
# 스킬은 ~\.claude\skills\<name>, $env:CODEX_HOME(없으면 ~\.codex)\skills\<name>에 복사한다.
# 같은 이름 폴더가 이미 있으면 덮어쓰지 않고 건너뛴다. 그 밖의 파일(설정·인증)은 건드리지 않는다.
# 이 파일은 PowerShell 5.1이 한글을 읽을 수 있게 UTF-8(BOM 포함)으로 저장한다.

$ErrorActionPreference = 'Stop'

function Fail([string]$msg) {
    [Console]::Error.WriteLine("오류: $msg")
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$SkillsSrc = Join-Path $RepoDir 'skills'
$PackSrc = Join-Path $RepoDir 'packs\codex-dev'
$Marker = '<!-- FOD-skills:codex-dev AGENTS.md -->'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

$Target = 'both'
$DryRun = $false
$HomeDir = ''
$ProjectDir = ''

$i = 0
while ($i -lt $args.Count) {
    $a = [string]$args[$i]
    switch -CaseSensitive ($a) {
        { $_ -in @('claude', 'codex', 'both') } { $Target = $a; break }
        { $_ -in @('--target', '-Target') } {
            if ($i + 1 -ge $args.Count) { Fail '--target 뒤에 claude|codex|both 가 필요하다' }
            $i++
            $t = [string]$args[$i]
            if ($t -notin @('claude', 'codex', 'both')) { Fail "알 수 없는 대상: $t" }
            $Target = $t
            break
        }
        { $_ -in @('--dry-run', '-DryRun') } { $DryRun = $true; break }
        { $_ -in @('--home', '-HomeDir') } {
            if ($i + 1 -ge $args.Count) { Fail '--home 뒤에 폴더가 필요하다' }
            $i++
            $HomeDir = [string]$args[$i]
            break
        }
        { $_ -in @('--project', '-Project') } {
            if ($i + 1 -ge $args.Count) { Fail '--project 뒤에 폴더가 필요하다' }
            $i++
            $ProjectDir = [string]$args[$i]
            break
        }
        { $_ -in @('-h', '--help') } {
            Get-Content -LiteralPath $MyInvocation.MyCommand.Path -Encoding UTF8 -TotalCount 13 |
                ForEach-Object { $_ -replace '^# ?', '' }
            exit 0
        }
        default { Fail "알 수 없는 인자: $a (--help 참고)" }
    }
    $i++
}

if (-not (Test-Path -LiteralPath $SkillsSrc -PathType Container)) { Fail "skills 폴더가 없다: $SkillsSrc" }

if ($HomeDir -ne '') {
    if (-not (Test-Path -LiteralPath $HomeDir -PathType Container)) { Fail "--home 폴더가 없다: $HomeDir" }
    $HomeDir = (Resolve-Path -LiteralPath $HomeDir).ProviderPath
    $CodexDir = Join-Path $HomeDir '.codex'
} else {
    $HomeDir = $env:USERPROFILE
    if (-not $HomeDir) { $HomeDir = $HOME }
    if ($env:CODEX_HOME) { $CodexDir = $env:CODEX_HOME } else { $CodexDir = Join-Path $HomeDir '.codex' }
}

if ($ProjectDir -ne '') {
    if (-not (Test-Path -LiteralPath $ProjectDir -PathType Container)) { Fail "--project 폴더가 없다: $ProjectDir" }
    if (-not (Test-Path -LiteralPath $PackSrc -PathType Container)) { Fail "묶음 폴더가 없다: $PackSrc" }
    $ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).ProviderPath
}

$ClaudeSkills = Join-Path (Join-Path $HomeDir '.claude') 'skills'
$CodexSkills = Join-Path $CodexDir 'skills'
switch ($Target) {
    'claude' { $Dests = @($ClaudeSkills) }
    'codex' { $Dests = @($CodexSkills) }
    default { $Dests = @($ClaudeSkills, $CodexSkills) }
}

$script:Installed = 0
$script:Skipped = 0
$Prefix = ''
if ($DryRun) { $Prefix = '[미리보기] ' }

function Note-Install([string]$what) {
    $script:Installed++
    Write-Output "${Prefix}설치: $what"
}

function Note-Skip([string]$what) {
    $script:Skipped++
    Write-Output "${Prefix}건너뜀(이미 있음): $what"
}

# 스킬 복사
$Skills = Get-ChildItem -LiteralPath $SkillsSrc -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
    Sort-Object Name

foreach ($dest in $Dests) {
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
    }
    foreach ($s in $Skills) {
        $to = Join-Path $dest $s.Name
        if (Test-Path -LiteralPath $to) {
            Note-Skip $to
            continue
        }
        if (-not $DryRun) {
            Copy-Item -LiteralPath $s.FullName -Destination $to -Recurse
        }
        Note-Install $to
    }
}

# 프로젝트 묶음
if ($ProjectDir -ne '') {
    $agents = Join-Path $ProjectDir 'AGENTS.md'
    $packAgents = [System.IO.File]::ReadAllText((Join-Path $PackSrc 'AGENTS.md'), [System.Text.Encoding]::UTF8)
    if (Test-Path -LiteralPath $agents -PathType Leaf) {
        $existing = [System.IO.File]::ReadAllText($agents, [System.Text.Encoding]::UTF8)
        if ($existing.Contains($Marker)) {
            Note-Skip "$agents (codex-dev 규칙이 이미 붙어 있음)"
        } else {
            if (-not $DryRun) {
                [System.IO.File]::AppendAllText($agents, "`n$Marker`n$packAgents", $Utf8NoBom)
            }
            Note-Install "$agents (기존 파일 끝에 이어 붙임)"
        }
    } else {
        if (-not $DryRun) {
            [System.IO.File]::WriteAllText($agents, "$Marker`n$packAgents", $Utf8NoBom)
        }
        Note-Install "$agents (새로 만듦)"
    }

    foreach ($tpl in @('DECISIONS.md', 'ASSUMPTIONS.md')) {
        $to = Join-Path $ProjectDir $tpl
        if (Test-Path -LiteralPath $to) {
            Note-Skip $to
            continue
        }
        if (-not $DryRun) {
            Copy-Item -LiteralPath (Join-Path (Join-Path $PackSrc 'templates') $tpl) -Destination $to
        }
        Note-Install $to
    }
}

if ($DryRun) { Write-Output '[미리보기] 아무것도 쓰지 않았다. 아래 수는 실제로 돌렸을 때의 예상이다.' }
Write-Output ("설치 {0} / 건너뜀 {1} / 전체 {2}" -f $script:Installed, $script:Skipped, ($script:Installed + $script:Skipped))
