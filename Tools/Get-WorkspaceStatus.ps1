<#
.SYNOPSIS
Read-only health and pin alignment report across all sibling RedSalamanders checkouts.
.DESCRIPTION
Inspects ../DxUi, ../RedSalamander, ../RedXe, ../RedPrism, ../RedTilde, ../RedMonitor, and
../RedSalamanders/.github relative to RedHome without modifying any checkout.
.PARAMETER Hygiene
Adds clone hygiene facts read from local git data only (no network access): days since the last fetch, local
branches without an upstream, local branches already merged into origin/main, local branches whose upstream was
deleted on the remote, remote-tracking refs, and extra worktree registrations. Run 'git fetch --prune' in a clone
first when the numbers should reflect GitHub.
.PARAMETER AsObject
Returns the rows as objects instead of formatted tables.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$Hygiene,
    [switch]$AsObject
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$redHomeRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $redHomeRoot '..'))
$dxUiRoot = Join-Path $workspaceRoot 'DxUi'
$dxUiHead = if (Test-Path -LiteralPath (Join-Path $dxUiRoot '.git')) {
    (& git -C $dxUiRoot rev-parse HEAD 2>$null).Trim()
} else { '' }

function Get-CloneHygiene {
    param([Parameter(Mandatory)][string]$Path)

    $fetched = '-'
    $commonDir = [string](& git -C $Path rev-parse --path-format=absolute --git-common-dir 2>$null)
    if ($commonDir.Trim()) {
        $fetchHead = Join-Path $commonDir.Trim() 'FETCH_HEAD'
        if (Test-Path -LiteralPath $fetchHead -PathType Leaf) {
            $age = [DateTime]::UtcNow - (Get-Item -LiteralPath $fetchHead -Force).LastWriteTimeUtc
            $fetched = '{0}d ago' -f [int][Math]::Floor($age.TotalDays)
        }
    }

    $localOnly = 0
    $upstreamGone = 0
    $heads = @(& git -C $Path for-each-ref refs/heads '--format=%(refname:short)|%(upstream:short)|%(upstream:track)' 2>$null)
    foreach ($line in $heads) {
        $parts = @(([string]$line) -split '\|', 3)
        if ($parts.Count -lt 3 -or $parts[0] -ceq 'main') { continue }
        if (-not $parts[1]) { $localOnly++ }
        elseif ($parts[2] -match 'gone') { $upstreamGone++ }
    }

    $merged = '-'
    & git -C $Path rev-parse --verify --quiet refs/remotes/origin/main *> $null
    if ($LASTEXITCODE -eq 0) {
        $merged = @(& git -C $Path branch --merged origin/main '--format=%(refname:short)' 2>$null |
            Where-Object { $_ -and $_ -cne 'main' -and $_ -notmatch '^\(' }).Count
    }

    $remoteRefs = @(& git -C $Path for-each-ref refs/remotes/origin '--format=%(refname:short)' 2>$null |
        Where-Object { $_ -and $_ -cne 'origin/HEAD' -and $_ -cne 'origin' }).Count
    $worktrees = @(& git -C $Path worktree list --porcelain 2>$null | Where-Object { $_ -like 'worktree *' }).Count
    $extraWorktrees = [Math]::Max(0, $worktrees - 1)

    return [ordered]@{
        Fetched        = $fetched
        LocalOnly      = $localOnly
        Merged         = $merged
        UpstreamGone   = $upstreamGone
        RemoteRefs     = $remoteRefs
        ExtraWorktrees = $extraWorktrees
    }
}

$absentHygiene = [ordered]@{
    Fetched = '-'; LocalOnly = '-'; Merged = '-'; UpstreamGone = '-'; RemoteRefs = '-'; ExtraWorktrees = '-'
}

$targets = @(
    @{ Name = 'RedHome'; Rel = 'RedHome' },
    @{ Name = 'DxUi'; Rel = 'DxUi' },
    @{ Name = 'RedSalamander'; Rel = 'RedSalamander' },
    @{ Name = 'RedXe'; Rel = 'RedXe' },
    @{ Name = 'RedPrism'; Rel = 'RedPrism' },
    @{ Name = 'RedTilde'; Rel = 'RedTilde' },
    @{ Name = 'RedMonitor'; Rel = 'RedMonitor' },
    @{ Name = 'RedSalamanders/.github'; Rel = 'RedSalamanders/.github' }
)

$rows = foreach ($t in $targets) {
    $path = Join-Path $workspaceRoot $t.Rel
    if (-not (Test-Path -LiteralPath (Join-Path $path '.git'))) {
        $absent = [ordered]@{
            Repository = $t.Name
            Branch     = '<absent>'
            Head       = '-'
            Tree       = '-'
            CiEngine   = '-'
            DxUiLock   = '-'
            MonitorPin = '-'
        }
        if ($Hygiene) { foreach ($key in $absentHygiene.Keys) { $absent[$key] = $absentHygiene[$key] } }
        [pscustomobject]$absent
        continue
    }

    $branch = (& git -C $path rev-parse --abbrev-ref HEAD 2>$null).Trim()
    $head = (& git -C $path rev-parse HEAD 2>$null).Trim()
    $dirty = [bool](& git -C $path status --porcelain --untracked-files=normal 2>$null)

    $ciStatus = '-'
    $ciProjectPath = Join-Path $path '.ci/project.json'
    if (Test-Path -LiteralPath $ciProjectPath -PathType Leaf) {
        $proj = Get-Content -LiteralPath $ciProjectPath -Raw | ConvertFrom-Json
        $pin = [string]$proj.engine.ref
        $engineDir = Join-Path $path '.ci-engine'
        if (-not (Test-Path -LiteralPath (Join-Path $engineDir '.git'))) {
            $ciStatus = "MISSING (pin $($pin.Substring(0, 8)))"
        } else {
            $eHead = (& git -C $engineDir rev-parse HEAD 2>$null).Trim()
            $eDirty = [bool](& git -C $engineDir status --porcelain --untracked-files=all 2>$null)
            if ($eDirty) { $ciStatus = "DIRTY ($($eHead.Substring(0, 8)))" }
            elseif ($eHead -cne $pin) { $ciStatus = "MISMATCH ($($eHead.Substring(0, 8)) != $($pin.Substring(0, 8)))" }
            else { $ciStatus = "OK ($($pin.Substring(0, 8)))" }
        }
    }

    $dxUiStatus = '-'
    $dxUiLockPath = Join-Path $path 'Dependencies/DxUi.lock.json'
    if (Test-Path -LiteralPath $dxUiLockPath -PathType Leaf) {
        $lock = Get-Content -LiteralPath $dxUiLockPath -Raw | ConvertFrom-Json
        $shortLock = ([string]$lock.commit).Substring(0, 8)
        $atMain = if ($dxUiHead -and $dxUiHead -ceq [string]$lock.commit) { '=main' } else { '' }
        $dxUiStatus = "API$($lock.apiRevision)@$shortLock$atMain"
    } elseif ($t.Name -ceq 'DxUi') {
        $capPath = Join-Path $path 'capabilities.json'
        if (Test-Path -LiteralPath $capPath -PathType Leaf) {
            $cap = Get-Content -LiteralPath $capPath -Raw | ConvertFrom-Json
            $dxUiStatus = "Producer(API$($cap.apiRevision))"
        }
    }

    $rmStatus = '-'
    $rmLockPath = Join-Path $path 'Dependencies/RedMonitor.lock.json'
    if (Test-Path -LiteralPath $rmLockPath -PathType Leaf) {
        $rm = Get-Content -LiteralPath $rmLockPath -Raw | ConvertFrom-Json
        $rmStatus = "API$($rm.apiRevision)@$(([string]$rm.commit).Substring(0, 8))"
    } elseif ($t.Name -ceq 'RedMonitor') {
        $rmStatus = 'Producer(API1)'
    }

    $row = [ordered]@{
        Repository = $t.Name
        Branch     = $branch
        Head       = if ($head.Length -ge 8) { $head.Substring(0, 8) } else { $head }
        Tree       = if ($dirty) { 'Dirty' } else { 'Clean' }
        CiEngine   = $ciStatus
        DxUiLock   = $dxUiStatus
        MonitorPin = $rmStatus
    }
    if ($Hygiene) {
        $facts = Get-CloneHygiene -Path $path
        foreach ($key in $facts.Keys) { $row[$key] = $facts[$key] }
    }
    [pscustomobject]$row
}

if ($AsObject) { return $rows }
$rows | Format-Table Repository, Branch, Head, Tree, CiEngine, DxUiLock, MonitorPin -AutoSize
if ($Hygiene) {
    $rows | Format-Table Repository, Fetched, LocalOnly, Merged, UpstreamGone, RemoteRefs, ExtraWorktrees -AutoSize
}
