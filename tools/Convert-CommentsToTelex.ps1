[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) {
    throw "Input file not found: $InputPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $directory = Split-Path -Parent $InputPath
    $stem = [IO.Path]::GetFileNameWithoutExtension($InputPath)
    $extension = [IO.Path]::GetExtension($InputPath)
    $OutputPath = Join-Path $directory "$stem.telex$extension"
}

function Convert-WordToTelex {
    param([Parameter(Mandatory)][string]$Word)

    $normalized = $Word.Normalize([Text.NormalizationForm]::FormD)
    $chunks = [System.Collections.Generic.List[string]]::new()
    $tone = ''
    $toneIndex = -1
    $lastBase = [char]0
    $index = 0

    while ($index -lt $normalized.Length) {
        $base = $normalized[$index]
        $index++
        $marks = [System.Collections.Generic.List[char]]::new()
        while ($index -lt $normalized.Length -and [Globalization.CharUnicodeInfo]::GetUnicodeCategory($normalized[$index]) -in @('NonSpacingMark', 'SpacingCombiningMark')) {
            $marks.Add($normalized[$index])
            $index++
        }

        if ($base -eq [char]0x0111) { $chunks.Add('dd'); $lastBase = 'd'; continue }
        if ($base -eq [char]0x0110) { $chunks.Add('Dd'); $lastBase = 'D'; continue }

        $chunk = [Text.StringBuilder]::new()
        [void]$chunk.Append($base)
        $lastBase = $base
        foreach ($mark in $marks) {
            switch ([int][char]$mark) {
                0x0306 { [void]$chunk.Append('w'); break } # breve: ă
                0x0302 { [void]$chunk.Append(([char]::ToLowerInvariant($base))); break } # circumflex: â, ê, ô
                0x031B { [void]$chunk.Append('w'); break } # horn: ơ, ư
                0x0301 { $tone = 's'; $toneIndex = $chunks.Count; break }
                0x0300 { $tone = 'f'; $toneIndex = $chunks.Count; break }
                0x0309 { $tone = 'r'; $toneIndex = $chunks.Count; break }
                0x0303 { $tone = 'x'; $toneIndex = $chunks.Count; break }
                0x0323 { $tone = 'j'; $toneIndex = $chunks.Count; break }
            }
        }
        $chunks.Add($chunk.ToString())
    }

    if ($tone -and ([char]::ToLowerInvariant($lastBase) -in @('i', 'y', 'u'))) {
        $chunks[$toneIndex] = $chunks[$toneIndex] + $tone
        return ($chunks -join '')
    }

    return (($chunks -join '') + $tone)
}

function Convert-LineToTelex {
    param([AllowEmptyString()][string]$Line)

    return [regex]::Replace($Line, '[\p{L}\p{M}]+', {
        param($match)
        Convert-WordToTelex -Word $match.Value
    })
}

$lines = [IO.File]::ReadAllLines($InputPath, [Text.Encoding]::UTF8)
$converted = @(foreach ($line in $lines) { Convert-LineToTelex -Line $line })
[IO.File]::WriteAllLines($OutputPath, [string[]]$converted, [Text.UTF8Encoding]::new($false))

Write-Output "Converted $($converted.Count) line(s): $OutputPath"
