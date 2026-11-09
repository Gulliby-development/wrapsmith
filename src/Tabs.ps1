function Invoke-WsExpand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines,
        [Parameter(Mandatory)]
        [hashtable] $Options,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()] [int[]] $Positional
    )

    $tabSize = 8
    if ($Options.ContainsKey('-t')) {
        $tabSize = [int] $Options['-t']
    }

    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        $builder = [System.Text.StringBuilder]::new()
        $column = 0
        foreach ($character in $line.ToCharArray()) {
            if ([int] $character -eq 9) {
                $spaces = $tabSize - ($column % $tabSize)
                [void] $builder.Append(' ', $spaces)
                $column += $spaces
            }
            else {
                [void] $builder.Append($character)
                $column++
            }
        }
        $output.Add($builder.ToString())
    }

    return , $output.ToArray()
}

function Invoke-WsUnexpand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines,
        [Parameter(Mandatory)]
        [hashtable] $Options,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()] [int[]] $Positional
    )

    $tabSize = 8
    if ($Options.ContainsKey('-t')) {
        $tabSize = [int] $Options['-t']
    }

    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        $index = 0
        $columns = 0
        while ($index -lt $line.Length) {
            $character = $line[$index]
            if ($character -eq ' ') {
                $columns++
            }
            elseif ([int] $character -eq 9) {
                $columns += $tabSize - ($columns % $tabSize)
            }
            else {
                break
            }
            $index++
        }

        $builder = [System.Text.StringBuilder]::new()
        $tabCount = [int] [Math]::Floor($columns / $tabSize)
        $spaceCount = $columns % $tabSize
        if ($tabCount -gt 0) {
            [void] $builder.Append(([char] 9), $tabCount)
        }
        if ($spaceCount -gt 0) {
            [void] $builder.Append(' ', $spaceCount)
        }
        if ($index -lt $line.Length) {
            [void] $builder.Append($line.Substring($index))
        }
        $output.Add($builder.ToString())
    }

    return , $output.ToArray()
}

function Invoke-WsTrim {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines,
        [Parameter(Mandatory)]
        [hashtable] $Options,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()] [int[]] $Positional
    )

    $trimLeading = $Options.ContainsKey('--leading')
    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        $start = 0
        $end = $line.Length
        while ($end -gt $start -and
            ($line[$end - 1] -eq ' ' -or [int] $line[$end - 1] -eq 9)) {
            $end--
        }
        if ($trimLeading) {
            while ($start -lt $end -and ($line[$start] -eq ' ' -or [int] $line[$start] -eq 9)) {
                $start++
            }
        }
        $output.Add($line.Substring($start, $end - $start))
    }

    return , $output.ToArray()
}

function Invoke-WsSqueeze {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines,
        [Parameter(Mandatory)]
        [hashtable] $Options,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()] [int[]] $Positional
    )

    $collapseBlanks = $Options.ContainsKey('--blank')
    $output = [System.Collections.Generic.List[string]]::new()
    $pendingBlank = $false
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            if ($collapseBlanks) {
                if ($output.Count -gt 0) {
                    $pendingBlank = $true
                }
                continue
            }
            $output.Add('')
            continue
        }

        if ($pendingBlank) {
            $output.Add('')
            $pendingBlank = $false
        }
        $words = Get-WsWords -Line $line
        $output.Add($words -join ' ')
    }

    return , $output.ToArray()
}
