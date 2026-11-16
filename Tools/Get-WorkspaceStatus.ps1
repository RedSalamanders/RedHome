<#
.SYNOPSIS
Read-only health and pin alignment report across all sibling RedSalamanders checkouts.
.DESCRIPTION
Inspects ../DxUi, ../RedSalamander, ../RedXe, ../RedPrism, ../RedTilde, ../RedMonitor, and
../RedSalamanders/.github relative to RedHome without modifying any checkout.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
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
        [pscustomobject]@{
            Repository = $t.Name
            Branch     = '<absent>'
            Head       = '-'
            Tree       = '-'
            CiEngine   = '-'
            DxUiLock   = '-'
            MonitorPin = '-'
        }
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

    [pscustomobject]@{
        Repository = $t.Name
        Branch     = $branch
        Head       = if ($head.Length -ge 8) { $head.Substring(0, 8) } else { $head }
        Tree       = if ($dirty) { 'Dirty' } else { 'Clean' }
        CiEngine   = $ciStatus
        DxUiLock   = $dxUiStatus
        MonitorPin = $rmStatus
    }
}

if ($AsObject) { return $rows }
$rows | Format-Table -AutoSize
