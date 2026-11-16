# Validates RedHome pointer parity, wiki/Index.md completeness, and Markdown links.
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

Export-ModuleMember -Function Test-PointerParity, Test-WikiIntegrity
