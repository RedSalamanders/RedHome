# Validates RedHome pointer parity, wiki/Index.md completeness, Markdown links (root docs, skills, wiki, Specs),
# plan indexes, the closing sections of folded shared skills, and the shared-skill pointer in sibling repositories.
#Requires -Version 7.0
Set-StrictMode -Version Latest

function Remove-MarkdownCode {
    param([string]$Text)
    $normalized = $Text.Replace("`r`n", "`n")
    $out = [Collections.Generic.List[string]]::new()
    $fence = $null
    foreach ($line in $normalized -split "`n") {
        $marker = [regex]::Match($line, '^ {0,3}(?:(?:[-+*]|\d+[.)])[ \t]+)?(?<fence>`{3,}|~{3,})(?<rest>.*)$')
        if ($marker.Success -and ($null -ne $fence -or $marker.Groups['fence'].Value[0] -cne '`' -or
            -not $marker.Groups['rest'].Value.Contains('`'))) {
            $token = $marker.Groups['fence'].Value
            if ($null -eq $fence) { $fence = $token; continue }
            elseif ($token[0] -ceq $fence[0] -and $token.Length -ge $fence.Length -and -not $marker.Groups['rest'].Value.Trim()) { $fence = $null; continue }
        }
        if ($null -eq $fence) {
            $stripped = [regex]::Replace($line, '(`+)[^`]*?\1', '')
            $out.Add($stripped)
        }
    }
    if ($null -ne $fence) { throw 'Unclosed Markdown code fence.' }
    return ($out -join "`n")
}

function Test-PointerParity {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Root)
    $claudePath = Join-Path $Root 'CLAUDE.md'
    $copilotPath = Join-Path $Root '.github/copilot-instructions.md'
    foreach ($p in @($claudePath, $copilotPath)) {
        if (-not [IO.File]::Exists($p)) { throw "Missing thin instruction pointer: $p" }
        $lines = @([IO.File]::ReadAllLines($p, [Text.UTF8Encoding]::new($false, $true)) | Where-Object { $_.Trim() })
        if ($lines.Count -gt 6) { throw "Pointer file '$p' must remain a thin pointer to AGENTS.md (found $($lines.Count) non-empty lines)." }
    }
    $claudeText = [IO.File]::ReadAllText($claudePath)
    $copilotText = [IO.File]::ReadAllText($copilotPath)
    if ($claudeText -notmatch '\[AGENTS\.md\]\(AGENTS\.md\)') { throw 'CLAUDE.md must link directly to [AGENTS.md](AGENTS.md).' }
    if ($copilotText -notmatch '\[\.\./AGENTS\.md\]\(\.\./AGENTS\.md\)') { throw '.github/copilot-instructions.md must link directly to [../AGENTS.md](../AGENTS.md).' }
}

function Test-WikiIntegrity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Root,
        [switch]$CheckSiblings
    )
    $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $rootPrefix = $rootFull + [IO.Path]::DirectorySeparatorChar
    $comparison = if ([OperatingSystem]::IsWindows()) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }

    $wikiDir = Join-Path $rootFull 'wiki'
    $indexPath = Join-Path $wikiDir 'Index.md'
    if (-not [IO.File]::Exists($indexPath)) { throw 'Missing wiki/Index.md' }

    $wikiFiles = @(Get-ChildItem -LiteralPath $wikiDir -Filter '*.md' -File -Force | Sort-Object Name)
    $subDirs = @(Get-ChildItem -LiteralPath $wikiDir -Directory -Force)
    if ($subDirs.Count) {
        throw "wiki/ must remain flat-first; unexpected subdirectories: $($subDirs.Name -join ', ')"
    }

    $indexProse = Remove-MarkdownCode ([IO.File]::ReadAllText($indexPath, [Text.UTF8Encoding]::new($false, $true)))
    $indexed = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($indexProse, '\[[^\]]+\]\((?<target>[^)#?\s]+\.md)(?:#[^)]*)?\)')) {
        $target = $m.Groups['target'].Value
        if (-not $target.Contains('/')) { [void]$indexed.Add($target) }
    }
    foreach ($wf in $wikiFiles) {
        if ($wf.Name -ceq 'Index.md') { continue }
        if (-not $indexed.Contains($wf.Name)) {
            throw "Orphan wiki page '$($wf.Name)' is not linked from wiki/Index.md."
        }
    }

    $markdownFiles = [Collections.Generic.List[IO.FileInfo]]::new()
    foreach ($rel in @('README.md', 'AGENTS.md', 'CLAUDE.md', '.github/copilot-instructions.md')) {
        $markdownFiles.Add([IO.FileInfo]::new((Join-Path $rootFull $rel)))
    }
    foreach ($sf in @(Get-ChildItem -LiteralPath (Join-Path $rootFull '.agents/skills') -Recurse -Filter '*.md' -File -Force)) {
        $markdownFiles.Add($sf)
    }
    foreach ($wf in $wikiFiles) {
        $markdownFiles.Add($wf)
    }
    $specsDir = Join-Path $rootFull 'Specs'
    if ([IO.Directory]::Exists($specsDir)) {
        foreach ($pf in @(Get-ChildItem -LiteralPath $specsDir -Recurse -Filter '*.md' -File -Force)) {
            $markdownFiles.Add($pf)
        }
    }

    $failures = [Collections.Generic.List[string]]::new()
    foreach ($file in $markdownFiles) {
        $raw = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true))
        $prose = try { Remove-MarkdownCode $raw } catch { $failures.Add("$($file.FullName): $($_.Exception.Message)"); continue }
        if ($prose -cmatch '\[TODO:') {
            $failures.Add("$($file.FullName): contains unfinished [TODO:...] marker")
        }
        $baseDir = $file.DirectoryName
        foreach ($m in [regex]::Matches($prose, '!?\[[^\]]*\]\((?<raw>[^)]+)\)')) {
            $target = $m.Groups['raw'].Value.Trim()
            if ($target -match '^(?:https?|mailto|file|conversation):' -or $target.StartsWith('#')) { continue }
            $pathPart = ($target -split '#', 2)[0]
            if (-not $pathPart) { continue }
            $resolved = [IO.Path]::GetFullPath((Join-Path $baseDir $pathPart))
            $insideRepo = $resolved.Equals($rootFull, $comparison) -or $resolved.StartsWith($rootPrefix, $comparison)
            if ($insideRepo) {
                if (-not (Test-Path -LiteralPath $resolved)) {
                    $failures.Add("$($file.FullName): broken internal link '$target'")
                }
            } elseif ($CheckSiblings) {
                if (-not (Test-Path -LiteralPath $resolved)) {
                    $failures.Add("$($file.FullName): broken sibling link '$target' (expected '$resolved')")
                }
            }
        }
    }

    if ($failures.Count) { throw ($failures -join "`n") }
    return $wikiFiles.Count
}

function Test-PlanIndex {
    <#
    .SYNOPSIS
    Every plan file directly under Specs/Plans/WIP and Specs/Plans/Done is linked from that folder's README.md.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Root)
    $failures = [Collections.Generic.List[string]]::new()
    foreach ($state in @('WIP', 'Done')) {
        $relative = 'Specs/Plans/{0}' -f $state
        $dir = Join-Path $Root $relative
        if (-not [IO.Directory]::Exists($dir)) { continue }
        $indexPath = Join-Path $dir 'README.md'
        if (-not [IO.File]::Exists($indexPath)) {
            $failures.Add(('{0}: missing README.md index' -f $relative))
            continue
        }
        $prose = Remove-MarkdownCode ([IO.File]::ReadAllText($indexPath, [Text.UTF8Encoding]::new($false, $true)))
        $indexed = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($m in [regex]::Matches($prose, '\[[^\]]+\]\((?<target>[^)#?\s]+\.md)(?:#[^)]*)?\)')) {
            $target = $m.Groups['target'].Value
            if (-not $target.Contains('/')) { [void]$indexed.Add($target) }
        }
        foreach ($plan in @(Get-ChildItem -LiteralPath $dir -Filter '*.md' -File -Force | Sort-Object Name)) {
            if ($plan.Name -ceq 'README.md') { continue }
            if (-not $indexed.Contains($plan.Name)) {
                $failures.Add(('{0}/{1}: plan is not linked from {0}/README.md' -f $relative, $plan.Name))
            }
        }
    }
    if ($failures.Count) { throw ($failures -join "`n") }
}

function Test-SharedSkillShape {
    <#
    .SYNOPSIS
    A shared skill that carries references/repository-facts.md ends with the two closing sections every folded
    skill shares, in this order: "## Repository Facts", then "## Differences To Converge".
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Root)
    $failures = [Collections.Generic.List[string]]::new()
    $skillRoot = Join-Path $Root '.agents/skills'
    foreach ($folder in @(Get-ChildItem -LiteralPath $skillRoot -Directory -Force | Sort-Object Name)) {
        $factsPath = Join-Path $folder.FullName 'references/repository-facts.md'
        if (-not [IO.File]::Exists($factsPath)) { continue }
        $skillPath = Join-Path $folder.FullName 'SKILL.md'
        if (-not [IO.File]::Exists($skillPath)) { continue }
        $prose = Remove-MarkdownCode ([IO.File]::ReadAllText($skillPath, [Text.UTF8Encoding]::new($false, $true)))
        $headings = @([regex]::Matches($prose, '(?m)^## +(?<title>.+?) *$') | ForEach-Object { $_.Groups['title'].Value })
        $count = $headings.Count
        if ($count -lt 2 -or $headings[$count - 2] -cne 'Repository Facts' -or $headings[$count - 1] -cne 'Differences To Converge') {
            $failures.Add(('.agents/skills/{0}/SKILL.md: must end with "## Repository Facts" then "## Differences To Converge" because the skill has references/repository-facts.md' -f $folder.Name))
        }
    }
    if ($failures.Count) { throw ($failures -join "`n") }
}

function Test-SiblingSkillPointer {
    <#
    .SYNOPSIS
    Each sibling product repository's AGENTS.md carries the identical sentence that points to the RedHome skills.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Root)
    $sentence = 'Shared skill index: `../RedHome/AGENTS.md`; packages: `../RedHome/.agents/skills/`.'
    $workspace = [IO.Path]::GetFullPath((Join-Path $Root '..'))
    $failures = [Collections.Generic.List[string]]::new()
    foreach ($name in @('DxUi', 'RedSalamander', 'RedXe', 'RedPrism', 'RedTilde', 'RedMonitor')) {
        $agentsPath = Join-Path (Join-Path $workspace $name) 'AGENTS.md'
        if (-not [IO.File]::Exists($agentsPath)) {
            $failures.Add(('{0}: AGENTS.md not found beside RedHome (expected {1})' -f $name, $agentsPath))
            continue
        }
        $text = [IO.File]::ReadAllText($agentsPath, [Text.UTF8Encoding]::new($false, $true))
        if (-not $text.Contains($sentence)) {
            $failures.Add(('{0}/AGENTS.md: missing the shared-skill pointer sentence: {1}' -f $name, $sentence))
        }
    }
    if ($failures.Count) { throw ($failures -join "`n") }
}

Export-ModuleMember -Function Test-PointerParity, Test-WikiIntegrity, Test-PlanIndex, Test-SharedSkillShape, Test-SiblingSkillPointer
