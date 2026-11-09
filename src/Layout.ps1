function Invoke-WsCols {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $columnCount = $Positional[0]
    $gap = 2
    if ($Options.ContainsKey('--gap')) {
        $gap = [int] $Options['--gap']
    }
    $width = 0
    if ($Options.ContainsKey('-w')) {
        $width = [int] $Options['-w']
    }
    else {
        foreach ($line in $Lines) {
            $width = [Math]::Max($width, $line.Length)
        }
    }

    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].Length -gt $width) {
            throw [WrapsmithFailure]::new(1, "line $($index + 1) is longer than the column width $width")
        }
    }
    if ($Lines.Count -eq 0) {
        return , ([string[]]@())
    }

    $rowCount = [int][Math]::Ceiling($Lines.Count / [double]$columnCount)
    $output = [System.Collections.Generic.List[string]]::new()
    for ($row = 0; $row -lt $rowCount; $row++) {
        $cells = [System.Collections.Generic.List[string]]::new()
        for ($column = 0; $column -lt $columnCount; $column++) {
            $lineIndex = ($column * $rowCount) + $row
            if ($lineIndex -lt $Lines.Count) {
                $cells.Add($Lines[$lineIndex].PadRight($width))
            }
        }
        $output.Add(($cells -join (' ' * $gap)).TrimEnd(' '))
    }
    return , ([string[]]$output.ToArray())
}

function Invoke-WsBox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $padding = 1
    if ($Options.ContainsKey('--pad')) {
        $padding = [int] $Options['--pad']
    }
    $style = 'ascii'
    if ($Options.ContainsKey('--style')) {
        $style = [string] $Options['--style']
    }
    $width = 0
    if ($Options.ContainsKey('-w')) {
        $width = [int] $Options['-w']
    }
    else {
        foreach ($line in $Lines) {
            $width = [Math]::Max($width, $line.Length)
        }
    }

    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].Length -gt $width) {
            throw [WrapsmithFailure]::new(1, "line $($index + 1) is longer than the box width $width")
        }
    }

    $corner = '+'
    $edge = '-'
    $vertical = '|'
    if ([string]::Equals($style, 'star', [System.StringComparison]::Ordinal)) {
        $corner = '*'
        $edge = '*'
        $vertical = '*'
    }
    elseif ([string]::Equals($style, 'hash', [System.StringComparison]::Ordinal)) {
        $corner = '#'
        $edge = '#'
        $vertical = '#'
    }

    $horizontal = $edge * ($width + (2 * $padding))
    $output = [System.Collections.Generic.List[string]]::new()
    $output.Add($corner + $horizontal + $corner)
    foreach ($line in $Lines) {
        $output.Add($vertical + (' ' * $padding) + $line.PadRight($width) + (' ' * $padding) + $vertical)
    }
    $output.Add($corner + $horizontal + $corner)
    return , ([string[]]$output.ToArray())
}

function Invoke-WsTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $separator = ','
    if ($Options.ContainsKey('--sep')) {
        $separator = [string] $Options['--sep']
    }
    $align = ''
    if ($Options.ContainsKey('--align')) {
        $align = [string] $Options['--align']
    }

    $rows = [System.Collections.Generic.List[object]]::new()
    $widths = [System.Collections.Generic.List[int]]::new()
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            $rows.Add($null)
            continue
        }
        $cells = [System.Collections.Generic.List[string]]::new()
        foreach ($cell in $line.Split([char]$separator)) {
            $cells.Add($cell.Trim([char[]]@(' ', [char]9)))
        }
        for ($column = 0; $column -lt $cells.Count; $column++) {
            while ($widths.Count -le $column) {
                $widths.Add(0)
            }
            $widths[$column] = [Math]::Max($widths[$column], $cells[$column].Length)
        }
        $rows.Add($cells.ToArray())
    }

    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($row in $rows) {
        if ($null -eq $row) {
            $output.Add('')
            continue
        }
        $padded = [System.Collections.Generic.List[string]]::new()
        for ($column = 0; $column -lt $row.Count; $column++) {
            $cell = [string]$row[$column]
            $free = $widths[$column] - $cell.Length
            $direction = 'l'
            if ($column -lt $align.Length) {
                $direction = $align.Substring($column, 1)
            }
            if ([string]::Equals($direction, 'r', [System.StringComparison]::Ordinal)) {
                $cell = (' ' * $free) + $cell
            }
            elseif ([string]::Equals($direction, 'c', [System.StringComparison]::Ordinal)) {
                $left = [int][Math]::Floor($free / 2.0)
                $cell = (' ' * $left) + $cell + (' ' * ($free - $left))
            }
            else {
                $cell = $cell + (' ' * $free)
            }
            $padded.Add($cell)
        }
        $output.Add(($padded -join '  ').TrimEnd(' '))
    }

    if ($Options.ContainsKey('--header') -and $output.Count -gt 0) {
        $rules = [System.Collections.Generic.List[string]]::new()
        foreach ($width in $widths) {
            $rules.Add('-' * $width)
        }
        $output.Insert(1, ($rules -join '  '))
    }
    return , ([string[]]$output.ToArray())
}
