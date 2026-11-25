<#
.SYNOPSIS
Validates RedHome skills, thin instruction pointers, wiki and plan index coverage, and Markdown links.
.DESCRIPTION
The agent guidance (skill grammar, skill index, instruction pointers, scoped-guidance inventory, plan indexes, and
references; rules G1 to G13) is checked by the shared CI engine that .ci/project.json pins, through
Tools/Test-AgentGuidance.ps1 with -Kind Documentation. It needs that engine checked out at .ci-engine; the shim says
how when it is missing. The same pin supplies the documentation project manifest schema. The shared-skill shape,
pointer parity, wiki, and sibling-pointer checks are RedHome's own.
.PARAMETER CheckSiblings
Also verifies relative links into sibling repositories (../../RedSalamander, ../../RedXe, etc.) and the shared-skill
pointer sentence in each sibling AGENTS.md. Requires every sibling to be checked out beside RedHome.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$CheckSiblings
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Tools/WikiValidation.psm1') -Force

& (Join-Path $PSScriptRoot 'Tools/Test-AgentGuidance.ps1') -Root $PSScriptRoot -Kind Documentation -CheckSiblings:$CheckSiblings
$manifest = [IO.File]::ReadAllText((Join-Path $PSScriptRoot '.ci/project.json'), [Text.UTF8Encoding]::new($false, $true))
$schema = Join-Path $PSScriptRoot '.ci-engine/Schemas/project.schema.json'
if (-not (Test-Json -Json $manifest -SchemaFile $schema -ErrorAction Stop)) {
    throw '.ci/project.json does not match the pinned project schema.'
}
$skillCount = @(Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot '.agents/skills') -Directory -Force).Count
Test-SharedSkillShape -Root $PSScriptRoot
Test-PointerParity -Root $PSScriptRoot
$wikiCount = Test-WikiIntegrity -Root $PSScriptRoot -CheckSiblings:$CheckSiblings
if ($CheckSiblings) { Test-SiblingSkillPointer -Root $PSScriptRoot }

Write-Host ("RedHome validation passed ({0} skills, {1} wiki pages{2})." -f `
    $skillCount, $wikiCount, $(if ($CheckSiblings) { ', sibling links and pointers verified' } else { '' })) -ForegroundColor Green
