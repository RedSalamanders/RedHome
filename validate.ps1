<#
.SYNOPSIS
Validates RedHome skills, thin instruction pointers, wiki index coverage, and Markdown links.
.PARAMETER CheckSiblings
Also verifies relative links into sibling repositories (../../RedSalamander, ../../RedXe, etc.) when present locally.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$CheckSiblings
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Tools/SkillValidation.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'Tools/WikiValidation.psm1') -Force

$skillCount = Test-RepositorySkills -Root $PSScriptRoot
Test-AgentSkillIndex -Root $PSScriptRoot
Test-PointerParity -Root $PSScriptRoot
$wikiCount = Test-WikiIntegrity -Root $PSScriptRoot -CheckSiblings:$CheckSiblings

Write-Host ("RedHome validation passed ({0} skills, {1} wiki pages{2})." -f `
    $skillCount, $wikiCount, $(if ($CheckSiblings) { ', sibling links verified' } else { '' })) -ForegroundColor Green
