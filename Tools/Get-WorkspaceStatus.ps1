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
.PARAMETER Harness
Adds the harness report (convergence plan step CV-1-09), read from each clone's checked-out commit (HEAD), so
line-ending conversion and uncommitted edits never count as a difference:
- the SHA-256 of every file that must be the same in every repository, and how many different versions exist;
- where each format script takes clang-format from (the engine's Install-CiFormatter, a repository pin, a version
  written into the script, or whatever Visual Studio or PATH provides) and the version that source pins;
- every root PowerShell command with its declared parameters. Commands with the same letter take the same
  parameters.
Scripts are parsed, never run, and nothing is read from the network.
.PARAMETER AsObject
Returns the rows as objects instead of formatted tables. With -Harness, returns one object whose Repositories,
Files, Formatters, and Commands properties hold the rows of each report.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$Hygiene,
    [switch]$Harness,
    [switch]$AsObject
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$redHomeRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
# From a linked worktree (such as .build/worktrees/<name>), the siblings sit beside the main checkout.
$redHomeCommonDir = ([string](& git -C $redHomeRoot rev-parse --path-format=absolute --git-common-dir 2>$null)).Trim()
$redHomeMain = if ($redHomeCommonDir) { Split-Path -Parent $redHomeCommonDir } else { $redHomeRoot }
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $redHomeMain '..'))
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

function Read-ByteLine {
    param([Parameter(Mandatory)][IO.Stream]$Stream)

    $line = [IO.MemoryStream]::new()
    while ($true) {
        $value = $Stream.ReadByte()
        if ($value -lt 0) { throw 'git cat-file stopped answering.' }
        if ($value -eq 10) { break }
        $line.WriteByte([byte]$value)
    }
    return [Text.Encoding]::UTF8.GetString($line.ToArray())
}

function Read-HeadBlobs {
    # Reads files as committed at HEAD through one 'git cat-file --batch' process. Returns a table from path to
    # bytes; paths that HEAD does not have are left out.
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][AllowEmptyCollection()][string[]]$RelativePaths)

    $blobs = @{}
    $wanted = @($RelativePaths | Where-Object { $_ } | Sort-Object -Unique)
    if (-not $wanted.Count) { return $blobs }

    $info = [Diagnostics.ProcessStartInfo]::new('git')
    foreach ($argument in @('-C', $Path, 'cat-file', '--batch')) { $info.ArgumentList.Add($argument) }
    $info.UseShellExecute = $false
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.StandardInputEncoding = [Text.UTF8Encoding]::new($false)
    $process = [Diagnostics.Process]::Start($info)
    try {
        $stderr = $process.StandardError.ReadToEndAsync()
        $output = $process.StandardOutput.BaseStream
        foreach ($relative in $wanted) {
            # One request at a time: git flushes every answer, so neither pipe can fill up and block.
            $process.StandardInput.Write("HEAD:$relative`n")
            $process.StandardInput.Flush()
            $header = [regex]::Match((Read-ByteLine -Stream $output), '^[0-9a-f]+ (\w+) (\d+)$')
            if (-not $header.Success) { continue }
            $bytes = [byte[]]::new([int]$header.Groups[2].Value)
            $offset = 0
            while ($offset -lt $bytes.Length) {
                $read = $output.Read($bytes, $offset, $bytes.Length - $offset)
                if ($read -le 0) { throw "git cat-file stopped answering in $Path." }
                $offset += $read
            }
            $null = $output.ReadByte()
            if ($header.Groups[1].Value -ceq 'blob') { $blobs[$relative] = $bytes }
        }
        $process.StandardInput.Close()
        $process.WaitForExit()
        $null = $stderr.Result
    } finally {
        $process.Dispose()
    }
    return $blobs
}

function ConvertTo-Text {
    param([AllowNull()][byte[]]$Bytes)

    if ($null -eq $Bytes) { return $null }
    return [Text.Encoding]::UTF8.GetString($Bytes).TrimStart([char]0xFEFF)
}

function Get-Sha256Hex {
    param([Parameter(Mandatory)][AllowEmptyCollection()][byte[]]$Bytes)

    $sha = [Security.Cryptography.SHA256]::Create()
    try { return -join ($sha.ComputeHash($Bytes) | ForEach-Object { $_.ToString('x2') }) }
    finally { $sha.Dispose() }
}

function Get-FormatterSource {
    # Classifies where the root format script takes clang-format from, reading the script and the modules it
    # imports. Nothing is run: running a repository's resolver could install a formatter.
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]]$RootFiles,
        [Parameter(Mandatory)][hashtable]$Blobs
    )

    $script = @('format.ps1', 'format-all.ps1') | Where-Object { $RootFiles -contains $_ } | Select-Object -First 1
    if (-not $script) { return [ordered]@{ Script = '-'; Source = '-'; Version = '-' } }

    $text = [string](ConvertTo-Text $Blobs[$script])
    $modules = @([regex]::Matches($text, '[''"]([^''"\r\n]+\.psm1)[''"]') |
        ForEach-Object { $_.Groups[1].Value -replace '\\', '/' })
    $moduleBlobs = Read-HeadBlobs -Path $Path -RelativePaths $modules
    foreach ($module in $moduleBlobs.Keys) { $text += "`n" + (ConvertTo-Text $moduleBlobs[$module]) }

    if ($text -match 'Install-CiFormatter') {
        $policy = Join-Path $Path '.ci-engine/Policy/clang-format.json'
        $version = if (Test-Path -LiteralPath $policy -PathType Leaf) {
            [string](Get-Content -LiteralPath $policy -Raw | ConvertFrom-Json).version
        } else { 'no .ci-engine' }
        return [ordered]@{ Script = $script; Source = 'Engine'; Version = $version }
    }
    $pin = ConvertTo-Text $Blobs['Build/clang-format.json']
    if ($pin -and $text -match 'clang-format\.json') {
        return [ordered]@{ Script = $script; Source = 'Repository pin'; Version = [string]($pin | ConvertFrom-Json).version }
    }
    $literal = [regex]::Match($text, 'clang-format[^\r\n]{0,40}?\b(\d+\.\d+\.\d+)\b')
    if ($literal.Success) {
        return [ordered]@{ Script = $script; Source = 'Written in script'; Version = $literal.Groups[1].Value }
    }
    return [ordered]@{ Script = $script; Source = 'Visual Studio or PATH'; Version = 'unpinned' }
}

function Get-RootCommand {
    # Lists every root PowerShell script at HEAD with its declared parameters, sorted by name.
    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]]$RootFiles, [Parameter(Mandatory)][hashtable]$Blobs)

    foreach ($file in $RootFiles | Where-Object { $_ -like '*.ps1' } | Sort-Object) {
        $text = [string](ConvertTo-Text $Blobs[$file])
        $tokens = $null
        $parseErrors = $null
        $ast = [Management.Automation.Language.Parser]::ParseInput($text, [ref]$tokens, [ref]$parseErrors)
        $names = @()
        if ($ast.ParamBlock) {
            $names = @($ast.ParamBlock.Parameters | ForEach-Object { '-' + $_.Name.VariablePath.UserPath } | Sort-Object)
        }
        $parameters = if ($names.Count) { $names -join ' ' } else { '(none)' }
        if ($parseErrors.Count) { $parameters += ' (does not parse)' }
        [pscustomobject]@{ Command = $file; Parameters = $parameters }
    }
}

$absentHygiene = [ordered]@{
    Fetched = '-'; LocalOnly = '-'; Merged = '-'; UpstreamGone = '-'; RemoteRefs = '-'; ExtraWorktrees = '-'
}

# Short names are the ones the convergence register uses.
$targets = @(
    @{ Name = 'RedHome'; Rel = 'RedHome'; Short = 'Home' },
    @{ Name = 'DxUi'; Rel = 'DxUi'; Short = 'Dx' },
    @{ Name = 'RedSalamander'; Rel = 'RedSalamander'; Short = 'RS' },
    @{ Name = 'RedXe'; Rel = 'RedXe'; Short = 'Xe' },
    @{ Name = 'RedPrism'; Rel = 'RedPrism'; Short = 'Pr' },
    @{ Name = 'RedTilde'; Rel = 'RedTilde'; Short = 'Ti' },
    @{ Name = 'RedMonitor'; Rel = 'RedMonitor'; Short = 'Mo' },
    @{ Name = 'RedSalamanders/.github'; Rel = 'RedSalamanders/.github'; Short = 'Engine' }
)

# Files that must be byte-identical in every repository once the register rows that name them are converged.
$harnessFiles = @(
    '.clang-format',
    '.editorconfig',
    '.gitattributes',
    'Build/NativeBuildPolicy.targets',
    'Build/PinnedDxUiPolicy.targets',
    'CLAUDE.md',
    '.claude/settings.json',
    '.github/copilot-instructions.md',
    '.github/dependabot.yml'
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

if ($Harness) {
    $present = @($targets | Where-Object { Test-Path -LiteralPath (Join-Path (Join-Path $workspaceRoot $_.Rel) '.git') })
    $hashes = @{}
    $formatters = [Collections.Generic.List[object]]::new()
    $commands = [Collections.Generic.List[object]]::new()
    foreach ($t in $present) {
        $path = Join-Path $workspaceRoot $t.Rel
        $rootFiles = @(& git -C $path ls-tree --name-only HEAD 2>$null)
        $wanted = @($harnessFiles) + @($rootFiles | Where-Object { $_ -like '*.ps1' }) +
            @('Build/clang-format.json', 'Policy/clang-format.json')
        $blobs = Read-HeadBlobs -Path $path -RelativePaths $wanted
        $repoHashes = @{}
        foreach ($file in $harnessFiles) {
            if ($blobs.ContainsKey($file)) { $repoHashes[$file] = Get-Sha256Hex -Bytes $blobs[$file] }
        }
        $hashes[$t.Short] = $repoHashes

        $formatter = if ($t.Short -ceq 'Engine') {
            $policy = ConvertTo-Text $blobs['Policy/clang-format.json']
            if ($policy) {
                [ordered]@{ Script = 'Policy/clang-format.json'; Source = 'CI pin'; Version = [string]($policy | ConvertFrom-Json).version }
            } else { [ordered]@{ Script = '-'; Source = '-'; Version = '-' } }
        } else { Get-FormatterSource -Path $path -RootFiles $rootFiles -Blobs $blobs }
        $formatters.Add([pscustomobject]@{
                Repository = $t.Name
                Script     = $formatter.Script
                Source     = $formatter.Source
                Version    = $formatter.Version
            })

        foreach ($command in Get-RootCommand -RootFiles $rootFiles -Blobs $blobs) {
            $commands.Add([pscustomobject]@{ Repository = $t.Name; Short = $t.Short; Command = $command.Command; Parameters = $command.Parameters })
        }
    }

    $fileRows = foreach ($file in $harnessFiles) {
        $full = [ordered]@{ File = $file }
        $short = [ordered]@{ File = $file }
        $seen = [Collections.Generic.HashSet[string]]::new()
        foreach ($t in $targets) {
            $hash = if ($hashes.ContainsKey($t.Short)) { $hashes[$t.Short][$file] } else { $null }
            $full[$t.Short] = if ($hash) { $hash } else { '-' }
            $short[$t.Short] = if ($hash) { $hash.Substring(0, 8) } else { '-' }
            if ($hash) { $null = $seen.Add($hash) }
        }
        $full['Versions'] = $seen.Count
        $short['Versions'] = $seen.Count
        [pscustomobject]@{ Full = [pscustomobject]$full; Short = [pscustomobject]$short }
    }

    # One row per command; the same letter in two repositories means the same parameter list.
    $commandRows = [Collections.Generic.List[object]]::new()
    $setRows = [Collections.Generic.List[object]]::new()
    foreach ($group in $commands | Group-Object Command | Sort-Object Name) {
        $letters = [ordered]@{}
        foreach ($entry in $group.Group) {
            if (-not $letters.Contains($entry.Parameters)) { $letters[$entry.Parameters] = [string][char](65 + $letters.Count) }
        }
        $row = [ordered]@{ Command = $group.Name }
        foreach ($t in $targets) {
            $entry = $group.Group | Where-Object { $_.Short -ceq $t.Short } | Select-Object -First 1
            $row[$t.Short] = if ($entry) { $letters[$entry.Parameters] } else { '-' }
        }
        $row['Sets'] = $letters.Count
        $commandRows.Add([pscustomobject]$row)
        foreach ($parameters in $letters.Keys) {
            $setRows.Add([pscustomobject]@{
                    Command      = $group.Name
                    Set          = $letters[$parameters]
                    Repositories = (@($group.Group | Where-Object { $_.Parameters -eq $parameters } | ForEach-Object Short) -join ' ')
                    Parameters   = $parameters
                })
        }
    }

    if ($AsObject) {
        return [pscustomobject]@{
            Repositories = $rows
            Files        = @($fileRows | ForEach-Object Full)
            Formatters   = $formatters.ToArray()
            Commands     = $commands.ToArray()
        }
    }
}

if ($AsObject) { return $rows }
$rows | Format-Table Repository, Branch, Head, Tree, CiEngine, DxUiLock, MonitorPin -AutoSize
if ($Hygiene) {
    $rows | Format-Table Repository, Fetched, LocalOnly, Merged, UpstreamGone, RemoteRefs, ExtraWorktrees -AutoSize
}
if ($Harness) {
    $columns = @('File') + @($targets | ForEach-Object Short) + @('Versions')
    Write-Output 'Files that must be the same (SHA-256 at HEAD, first 8 hex digits; - means absent):'
    $fileRows | ForEach-Object Short | Format-Table $columns -AutoSize
    Write-Output 'Formatter each format script uses:'
    $formatters | Format-Table Repository, Script, Source, Version -AutoSize
    Write-Output 'Root commands (the same letter means the same parameters; - means absent):'
    $commandRows | Format-Table (@('Command') + @($targets | ForEach-Object Short) + @('Sets')) -AutoSize
    $setRows | Format-Table Command, Set, Repositories, Parameters -AutoSize -Wrap
}
