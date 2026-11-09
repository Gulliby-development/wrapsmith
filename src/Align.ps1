function Get-WsAlignmentWidth {
    param(
        [hashtable] $Options
    )

    if ($Options.ContainsKey('-w')) {
        return [int] $Options['-w']
    }

    return 72
}

function Remove-WsLineEdges {
    param(
        [AllowEmptyString()] [string] $Line
    )

    $start = 0
    $end = $Line.Length
    while ($start -lt $end -and ($Line[$start] -eq ' ' -or [int] $Line[$start] -eq 9)) {
        $start++
    }
    while ($end -gt $start -and ($Line[$end - 1] -eq ' ' -or [int] $Line[$end - 1] -eq 9)) {
        $end--
    }

    return $Line.Substring($start, $end - $start)
}

function Invoke-WsCenter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $width = Get-WsAlignmentWidth -Options $Options
    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        $trimmed = Remove-WsLineEdges -Line $line
        if ($trimmed.Length -eq 0 -or $trimmed.Length -ge $width) {
            $output.Add($trimmed)
        }
        else {
            $left = [int] [math]::Floor(($width - $trimmed.Length) / 2)
            $output.Add((' ' * $left) + $trimmed)
        }
    }

    return , $output.ToArray()
}

function Invoke-WsRight {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $width = Get-WsAlignmentWidth -Options $Options
    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        $trimmed = Remove-WsLineEdges -Line $line
        if ($trimmed.Length -eq 0 -or $trimmed.Length -ge $width) {
            $output.Add($trimmed)
        }
        else {
            $output.Add((' ' * ($width - $trimmed.Length)) + $trimmed)
        }
    }

    return , $output.ToArray()
}

function Invoke-WsIndent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $firstIndent = [int] $Positional[0]
    $hangingIndent = $firstIndent
    if ($Options.ContainsKey('--hang')) {
        $hangingIndent = [int] $Options['--hang']
    }

    $output = [System.Collections.Generic.List[string]]::new()
    $paragraphStart = $true
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            $output.Add('')
            $paragraphStart = $true
            continue
        }

        if ($paragraphStart) {
            $output.Add((' ' * $firstIndent) + $line)
            $paragraphStart = $false
        }
        else {
            $output.Add((' ' * $hangingIndent) + $line)
        }
    }

    return , $output.ToArray()
}

function Invoke-WsDedent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $minimum = [int]::MaxValue
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            continue
        }

        $leadingSpaces = 0
        while ($leadingSpaces -lt $line.Length -and $line[$leadingSpaces] -eq ' ') {
            $leadingSpaces++
        }
        if ($leadingSpaces -lt $minimum) {
            $minimum = $leadingSpaces
        }
    }
    if ($minimum -eq [int]::MaxValue) {
        $minimum = 0
    }

    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            $output.Add('')
        }
        else {
            $output.Add($line.Substring($minimum))
        }
    }

    return , $output.ToArray()
}

function Invoke-WsTrunc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $width = [int] $Positional[0]
    $mark = '...'
    if ($Options.ContainsKey('--mark')) {
        $mark = [string] $Options['--mark']
    }

    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        if ($line.Length -gt $width) {
            $output.Add($line.Substring(0, $width - $mark.Length) + $mark)
        }
        else {
            $output.Add($line)
        }
    }

    return , $output.ToArray()
}
