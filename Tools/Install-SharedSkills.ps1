<#
.SYNOPSIS
Links the shared RedHome skills into the machine-wide skill folders of Codex, GitHub Copilot, and Antigravity.
.DESCRIPTION
Convergence plan step CV-3-06. Claude Code already loads the shared skills everywhere through the redhome plugin;
the other harnesses read them natively only inside RedHome. This script links each folder of
RedHome/.agents/skills into the folders those harnesses read for every repository on the machine:
- ~/.agents/skills/<name>, read by Codex and GitHub Copilot;
- ~/.gemini/config/skills/<name>, read by Antigravity (App, CLI, and IDE).

It reports by default and writes only with -Apply. It links and never copies, so every skill still exists once, in
RedHome. Links always point at the main RedHome checkout, even when the script runs from a linked worktree, so they
survive the removal of that worktree. An existing entry is replaced only when it is this script's own link (a link
to <a RedHome checkout>/.agents/skills/<name>); real folders, files, and other links are left alone and reported.

The report also lists name collisions between the shared skills and every other skill the harnesses can see at the
same time (the local skills of the sibling repositories and the other skills in the machine-wide folders), because
Codex does not merge two skills with the same name (register A-15).

A harness counts as installed when its profile folder, its install folder, or its command exists.
.PARAMETER Apply
Creates, replaces, or removes the links that the report lists. Without it nothing is written.
.PARAMETER Remove
Plans the removal of this script's own links instead of their creation. Combine with -Apply to remove them. Folders
are never removed.
.PARAMETER LinkType
Junction (the default) or SymbolicLink. A directory junction needs no privilege; a symbolic link needs Developer Mode
or an elevated shell. Codex documents that it follows symbolic links, and Codex and Copilot were both checked to
discover a skill reached through a junction.
.PARAMETER Harness
Links for these harnesses whether or not they are found. By default the script links for the harnesses it finds.
.PARAMETER HomePath
The profile folder to link into. Defaults to the current user's profile.
.PARAMETER AsObject
Returns one object whose Source, Harnesses, Links, and Collisions properties hold the report, instead of tables.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$Remove,
    [ValidateSet('Junction', 'SymbolicLink')]
    [string]$LinkType = 'Junction',
    [ValidateSet('Codex', 'Copilot', 'Antigravity')]
    [string[]]$Harness,
    [string]$HomePath = [Environment]::GetFolderPath('UserProfile'),
    [switch]$AsObject
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $IsWindows) { throw 'Install-SharedSkills.ps1 links skills on Windows only.' }

$scriptRepositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
# From a linked worktree (such as .build/worktrees/<name>), link the main checkout, which outlives the worktree.
$commonDir = ([string](& git -C $scriptRepositoryRoot rev-parse --path-format=absolute --git-common-dir 2>$null)).Trim()
$redHomeRoot = if ($commonDir) { [IO.Path]::GetFullPath((Split-Path -Parent $commonDir)) } else { $scriptRepositoryRoot }
$fromWorktree = -not [string]::Equals($redHomeRoot.TrimEnd('\'), $scriptRepositoryRoot.TrimEnd('\'),
    [StringComparison]::OrdinalIgnoreCase)
$redHomeBranch = ([string](& git -C $redHomeRoot rev-parse --abbrev-ref HEAD 2>$null)).Trim()
$sourceSkillsRoot = Join-Path $redHomeRoot '.agents\skills'
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $redHomeRoot '..'))
$HomePath = [IO.Path]::GetFullPath($HomePath)

if (-not (Test-Path -LiteralPath $sourceSkillsRoot -PathType Container)) {
    throw "No shared skills at '$sourceSkillsRoot'."
}

function Get-DisplayPath {
    param([Parameter(Mandatory)][string]$Path)
    $homePrefix = $HomePath.TrimEnd('\') + '\'
    if ($Path.StartsWith($homePrefix, [StringComparison]::OrdinalIgnoreCase)) { return '~\' + $Path.Substring($homePrefix.Length) }
    $workspacePrefix = $workspaceRoot.TrimEnd('\') + '\'
    if ($Path.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) { return '..\' + $Path.Substring($workspacePrefix.Length) }
    return $Path
}

function Test-SamePath {
    param([string]$Left, [string]$Right)
    return [string]::Equals([IO.Path]::GetFullPath($Left).TrimEnd('\'), [IO.Path]::GetFullPath($Right).TrimEnd('\'),
        [StringComparison]::OrdinalIgnoreCase)
}

# The entry at a path without following links: $null when nothing is there.
function Get-PathEntry {
    param([Parameter(Mandatory)][string]$Path)
    try { $attributes = [IO.File]::GetAttributes($Path) }
    catch [IO.FileNotFoundException], [IO.DirectoryNotFoundException] { return $null }

    $isLink = $attributes.HasFlag([IO.FileAttributes]::ReparsePoint)
    $linkType = ''
    $target = ''
    if ($isLink) {
        $item = Get-Item -LiteralPath $Path -Force
        $linkType = [string]$item.LinkType
        $target = [string]$item.LinkTarget
        if ($target) {
            $target = $target -replace '^\\\\\?\\', '' -replace '^\\\?\?\\', ''
            $target = [IO.Path]::GetFullPath($target, (Split-Path -Parent $Path))
        }
    }
    return [pscustomobject]@{
        IsLink      = $isLink
        IsDirectory = $attributes.HasFlag([IO.FileAttributes]::Directory)
        LinkType    = $linkType
        Target      = $target
        TargetFound = [bool]($target -and (Test-Path -LiteralPath $target -PathType Container))
    }
}

# The RedHome checkout a link target belongs to when it is <checkout>/.agents/skills/<Name>, else ''.
function Get-LinkOwner {
    param([Parameter(Mandatory)][pscustomobject]$Entry, [Parameter(Mandatory)][string]$Name)
    if (-not $Entry.IsLink -or -not $Entry.Target -or $Entry.LinkType -notin @('Junction', 'SymbolicLink')) { return '' }
    $skills = Split-Path -Parent $Entry.Target
    $agents = Split-Path -Parent $skills
    if ((Split-Path -Leaf $Entry.Target) -ine $Name -or (Split-Path -Leaf $skills) -ine 'skills' -or
        (Split-Path -Leaf $agents) -ine '.agents') { return '' }
    $root = Split-Path -Parent $agents
    if (Test-SamePath $root $redHomeRoot) { return $redHomeRoot }
    $pluginPath = Join-Path $root '.claude-plugin\plugin.json'
    if (Test-Path -LiteralPath $pluginPath -PathType Leaf) {
        try {
            if ([string](Get-Content -LiteralPath $pluginPath -Raw | ConvertFrom-Json).name -ceq 'redhome') { return $root }
        } catch { return '' }
    }
    return ''
}

function Format-EntryDetail {
    param([Parameter(Mandatory)][pscustomobject]$Entry)
    if (-not $Entry.IsLink) { return $(if ($Entry.IsDirectory) { 'a real folder' } else { 'a file' }) }
    if (-not $Entry.LinkType) { return 'a reparse point that is not a link' }
    $kind = if ($Entry.LinkType -ceq 'Junction') { 'junction' } else { 'symbolic link' }
    $missing = if ($Entry.TargetFound) { '' } else { ' (target missing)' }
    return "$kind to $(Get-DisplayPath $Entry.Target)$missing"
}

# The skill name a harness sees: the front-matter name, or the folder name when there is none.
function Get-SkillName {
    param([Parameter(Mandatory)][string]$Folder)
    $name = Split-Path -Leaf $Folder
    try {
        $text = [IO.File]::ReadAllText((Join-Path $Folder 'SKILL.md'))
        $frontMatter = [regex]::Match($text, '\A---\r?\n(?<body>.*?)\r?\n---', 'Singleline')
        if ($frontMatter.Success) {
            $declared = [regex]::Match($frontMatter.Groups['body'].Value, '(?m)^name:[ \t]*(?<value>[^\r\n#]+?)[ \t]*\r?$')
            if ($declared.Success) { $name = $declared.Groups['value'].Value.Trim().Trim('"', "'") }
        }
    } catch [IO.IOException], [UnauthorizedAccessException] { }
    return $name
}

function Get-SkillFolder {
    param([Parameter(Mandatory)][string]$Root)
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return @() }
    return @(Get-ChildItem -LiteralPath $Root -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -cne '.system' -and (Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf) })
}

function Test-SymbolicLinkPrivilege {
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { return $true }
    $unlock = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
        -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
    return [bool]($unlock -and $unlock.AllowDevelopmentWithoutDevLicense -eq 1)
}

$sharedSkills = @(Get-SkillFolder -Root $sourceSkillsRoot | Sort-Object Name | ForEach-Object {
        [pscustomobject]@{ Folder = $_.Name; Name = Get-SkillName -Folder $_.FullName; Path = $_.FullName }
    })
if ($sharedSkills.Count -eq 0) { throw "No shared skills at '$sourceSkillsRoot'." }

# Harness detection. Folder is where the harness reads skills for every repository on the machine.
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
$harnessDefinitions = @(
    @{ Name = 'Codex'; Folder = '.agents\skills'; Profile = @('.codex'); Install = @('OpenAI\Codex'); Commands = @('codex') },
    @{ Name = 'Copilot'; Folder = '.agents\skills'; Profile = @('.copilot'); Install = @(); Commands = @('copilot') },
    @{ Name = 'Antigravity'; Folder = '.gemini\config\skills'; Profile = @('.gemini\antigravity')
        Install = @('Programs\Antigravity'); Commands = @('agy', 'antigravity') }
)

$harnessRows = foreach ($definition in $harnessDefinitions) {
    $evidence = [Collections.Generic.List[string]]::new()
    foreach ($relative in $definition.Profile) {
        if (Test-Path -LiteralPath (Join-Path $HomePath $relative) -PathType Container) { $evidence.Add("~\$relative") }
    }
    foreach ($relative in $definition.Install) {
        if (Test-Path -LiteralPath (Join-Path $localAppData $relative) -PathType Container) { $evidence.Add("%LOCALAPPDATA%\$relative") }
    }
    foreach ($command in $definition.Commands) {
        if (Get-Command -Name $command -CommandType Application -ErrorAction SilentlyContinue) { $evidence.Add("$command on PATH") }
    }
    $named = [bool]($Harness -and $definition.Name -in $Harness)
    $found = $evidence.Count -gt 0
    [pscustomobject]@{
        Harness  = $definition.Name
        Found    = $found
        Selected = if ($Harness) { $named } else { $found }
        Evidence = if ($found) { $evidence -join ', ' } else { '-' }
        Folder   = "~\$($definition.Folder)"
        Path     = Join-Path $HomePath $definition.Folder
    }
}

$targetFolders = @($harnessRows | Where-Object Selected | Group-Object Path | ForEach-Object {
        [pscustomobject]@{ Path = $_.Name; Harnesses = @($_.Group.Harness) }
    })

$canSymlink = Test-SymbolicLinkPrivilege
if ($Apply -and -not $Remove -and $LinkType -ceq 'SymbolicLink' -and -not $canSymlink) {
    throw 'A symbolic link needs Developer Mode or an elevated shell. Run without -LinkType to use directory junctions.'
}

$linkRows = [Collections.Generic.List[pscustomobject]]::new()
$sharedNames = @($sharedSkills.Folder)
foreach ($folder in $targetFolders) {
    # A machine-wide folder that is itself a link would put these links somewhere else (often another harness's
    # folder), so the script leaves it alone.
    $blockedBy = ''
    $probe = $folder.Path
    while ($probe -and -not (Test-SamePath $probe $HomePath) -and $probe.Length -gt $HomePath.Length) {
        $entry = Get-PathEntry -Path $probe
        if ($entry -and $entry.IsLink) { $blockedBy = "$(Get-DisplayPath $probe) is $(Format-EntryDetail $entry)"; break }
        if ($entry -and -not $entry.IsDirectory) { $blockedBy = "$(Get-DisplayPath $probe) is a file"; break }
        $probe = Split-Path -Parent $probe
    }
    if ($blockedBy) {
        $linkRows.Add([pscustomobject][ordered]@{
                Folder = Get-DisplayPath $folder.Path; Skill = "(all $($sharedSkills.Count))"; State = 'Blocked'
                Action = 'leave'; Detail = $blockedBy; LinkPath = $folder.Path; Source = ''
            })
        continue
    }

    foreach ($skill in $sharedSkills) {
        $linkPath = Join-Path $folder.Path $skill.Folder
        $row = [ordered]@{
            Folder = Get-DisplayPath $folder.Path; Skill = $skill.Folder; State = ''; Action = ''; Detail = ''
            LinkPath = $linkPath; Source = $skill.Path
        }
        $entry = Get-PathEntry -Path $linkPath
        $owner = if ($entry) { Get-LinkOwner -Entry $entry -Name $skill.Folder } else { '' }
        if (-not $entry) {
            $row.State = 'Missing'; $row.Action = if ($Remove) { '-' } else { 'create' }
        } elseif (-not $owner) {
            $row.State = 'Blocked'; $row.Action = 'leave'; $row.Detail = Format-EntryDetail $entry
        } elseif ($Remove) {
            $row.State = 'Linked'; $row.Action = 'remove'; $row.Detail = Format-EntryDetail $entry
        } elseif (-not (Test-SamePath $owner $redHomeRoot)) {
            $row.State = 'Stale'; $row.Action = 'relink'; $row.Detail = Format-EntryDetail $entry
        } elseif ($entry.LinkType -cne $LinkType) {
            $row.State = 'Stale'; $row.Action = 'relink'; $row.Detail = "$(Format-EntryDetail $entry); -LinkType is $LinkType"
        } else {
            $row.State = 'Linked'; $row.Action = '-'; $row.Detail = Format-EntryDetail $entry
        }
        $linkRows.Add([pscustomobject]$row)
    }

    # This script's links to skills that RedHome no longer has.
    if (Test-Path -LiteralPath $folder.Path -PathType Container) {
        foreach ($child in @(Get-ChildItem -LiteralPath $folder.Path -Force -ErrorAction SilentlyContinue)) {
            if ($child.Name -in $sharedNames) { continue }
            $entry = Get-PathEntry -Path $child.FullName
            if (-not $entry -or -not $entry.IsLink) { continue }
            $owner = Get-LinkOwner -Entry $entry -Name $child.Name
            if (-not $owner -or -not (Test-SamePath $owner $redHomeRoot)) { continue }
            $linkRows.Add([pscustomobject][ordered]@{
                    Folder = Get-DisplayPath $folder.Path; Skill = $child.Name; State = 'Orphan'; Action = 'remove'
                    Detail = "$(Format-EntryDetail $entry); RedHome has no such skill"; LinkPath = $child.FullName; Source = ''
                })
        }
    }
}

if ($Apply) {
    foreach ($row in $linkRows) {
        if ($row.Action -notin @('create', 'relink', 'remove')) { continue }
        try {
            if ($row.Action -in @('relink', 'remove')) {
                # Re-check right before deleting: only a link is ever removed, and never what it points to.
                $entry = Get-PathEntry -Path $row.LinkPath
                if (-not $entry -or -not $entry.IsLink -or -not (Get-LinkOwner -Entry $entry -Name $row.Skill)) {
                    throw 'the entry changed since the report and is no longer this script''s link'
                }
                [IO.Directory]::Delete($row.LinkPath, $false)
            }
            if ($row.Action -in @('create', 'relink')) {
                [void][IO.Directory]::CreateDirectory((Split-Path -Parent $row.LinkPath))
                New-Item -ItemType $LinkType -Path $row.LinkPath -Target $row.Source | Out-Null
            }
            $row.Action = switch ($row.Action) { 'create' { 'created' } 'relink' { 'relinked' } 'remove' { 'removed' } }
        } catch {
            $row.Action = 'failed'
            $row.Detail = $_.Exception.Message
        }
    }
}

# Name collisions (register A-15): every other skill a harness can load beside the shared ones.
$otherRoots = [Collections.Generic.List[string]]::new()
foreach ($repository in @('DxUi', 'RedSalamander', 'RedXe', 'RedPrism', 'RedTilde', 'RedMonitor', 'RedSalamanders\.github')) {
    foreach ($relative in @('.agents\skills', '.github\skills', '.claude\skills')) {
        $otherRoots.Add((Join-Path $workspaceRoot (Join-Path $repository $relative)))
    }
}
foreach ($relative in @('.agents\skills', '.copilot\skills', '.codex\skills', '.gemini\config\skills', '.gemini\antigravity\skills')) {
    $otherRoots.Add((Join-Path $HomePath $relative))
}
$sharedByName = @{}
foreach ($skill in $sharedSkills) { $sharedByName[$skill.Name] = $skill.Folder }
$otherSkillCount = 0
$collisionRows = foreach ($root in $otherRoots) {
    foreach ($folder in Get-SkillFolder -Root $root) {
        $entry = Get-PathEntry -Path $folder.FullName
        if ($entry -and $entry.IsLink -and (Get-LinkOwner -Entry $entry -Name $folder.Name)) { continue }
        $otherSkillCount++
        $name = Get-SkillName -Folder $folder.FullName
        if ($sharedByName.ContainsKey($name)) {
            [pscustomobject]@{ Name = $name; Shared = $sharedByName[$name]; Other = Get-DisplayPath $folder.FullName }
        }
    }
}
$collisionRows = @($collisionRows)

$source = [pscustomobject]@{
    Root         = $redHomeRoot
    Branch       = $redHomeBranch
    FromWorktree = $fromWorktree
    Skills       = $sharedSkills.Count
    LinkType     = $LinkType
    CanSymlink   = $canSymlink
    Applied      = [bool]$Apply
    Mode         = if ($Remove) { 'Remove' } else { 'Install' }
}

if ($AsObject) {
    return [pscustomobject]@{
        Source     = $source
        Harnesses  = @($harnessRows | Select-Object Harness, Found, Selected, Evidence, Folder)
        Links      = @($linkRows)
        Collisions = $collisionRows
    }
}

$branchNote = if ($redHomeBranch -and $redHomeBranch -cne 'main') { " (on branch '$redHomeBranch', not main)" } else { '' }
Write-Host "Source: $sourceSkillsRoot, $($sharedSkills.Count) shared skills$branchNote."
if ($fromWorktree) { Write-Host "Run from the worktree $scriptRepositoryRoot; links point at the main checkout above." }
$harnessRows | Format-Table Harness, Found, Selected, Evidence, Folder -AutoSize | Out-Host

if ($targetFolders.Count -eq 0) {
    Write-Host 'No Codex, Copilot, or Antigravity installation found, so there is nothing to link. Name one with -Harness to link anyway.'
} else {
    $linkRows | Format-Table Folder, Skill, State, Action, Detail -AutoSize | Out-Host
    $count = { param([string[]]$Actions) @($linkRows | Where-Object { $_.Action -in $Actions }).Count }
    $kind = if ($LinkType -ceq 'Junction') { 'directory junctions' } else { 'symbolic links' }
    if ($Apply) {
        Write-Host ("Created {0}, relinked {1}, removed {2}, failed {3}; left {4} entries alone." -f `
            (& $count 'created'), (& $count 'relinked'), (& $count 'removed'), (& $count 'failed'), (& $count 'leave'))
        if ((& $count 'created', 'relinked') -gt 0) {
            Write-Host 'Start a new session in each harness to load the skills (in Copilot CLI, /skills reload).'
        }
    } else {
        Write-Host ("Report only. -Apply would create {0} and relink {1} {2}, remove {3}, and leave {4} entries alone." -f `
            (& $count 'create'), (& $count 'relink'), $kind, (& $count 'remove'), (& $count 'leave'))
        if (-not $Remove -and $LinkType -ceq 'SymbolicLink' -and -not $canSymlink) {
            Write-Host 'A symbolic link needs Developer Mode or an elevated shell, and neither is available, so -Apply would stop.'
        }
    }
}

if ($collisionRows.Count -eq 0) {
    Write-Host "Name collisions (register A-15): none between the shared skills and $otherSkillCount other skills."
} else {
    Write-Host "Name collisions (register A-15): Codex lists both skills of a pair and merges neither. Rename one of each pair."
    $collisionRows | Format-Table Name, Shared, Other -AutoSize | Out-Host
}
