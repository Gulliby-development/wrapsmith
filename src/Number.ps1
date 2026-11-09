function Invoke-WsNumber {
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

    $start = 1
    if ($Options.ContainsKey('--start')) {
        $start = [int] $Options['--start']
    }

    $skipBlank = $Options.ContainsKey('--skip-blank') -and [bool] $Options['--skip-blank']
    $numberedCount = 0
    foreach ($line in $Lines) {
        if (-not ($skipBlank -and (Test-WsBlank -Line $line))) {
            $numberedCount++
        }
    }

    $width = 0
    if ($Options.ContainsKey('--width')) {
        $width = [int] $Options['--width']
    }
    elseif ($numberedCount -gt 0) {
        $lastNumber = $start + $numberedCount - 1
        $width = $lastNumber.ToString([System.Globalization.CultureInfo]::InvariantCulture).Length
    }

    $output = [System.Collections.Generic.List[string]]::new()
    $number = $start
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            if ($skipBlank) {
                $output.Add('')
                continue
            }

            $numberText = $number.ToString([System.Globalization.CultureInfo]::InvariantCulture).PadLeft($width)
            $output.Add($numberText + ':')
        }
        else {
            $numberText = $number.ToString([System.Globalization.CultureInfo]::InvariantCulture).PadLeft($width)
            $output.Add($numberText + ': ' + $line)
        }

        $number++
    }

    return , $output.ToArray()
}

function Invoke-WsStats {
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

    $wordCount = 0
    $characterCount = 0
    $longest = 0
    $blankCount = 0
    foreach ($line in $Lines) {
        $words = Get-WsWords -Line $line
        $wordCount += $words.Count
        $characterCount += $line.Length
        if ($line.Length -gt $longest) {
            $longest = $line.Length
        }
        if (Test-WsBlank -Line $line) {
            $blankCount++
        }
    }

    $paragraphs = Get-WsParagraphs -Lines $Lines
    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $output = @(
        'lines ' + $Lines.Count.ToString($culture)
        'words ' + $wordCount.ToString($culture)
        'chars ' + $characterCount.ToString($culture)
        'longest ' + $longest.ToString($culture)
        'paragraphs ' + $paragraphs.Count.ToString($culture)
        'blank ' + $blankCount.ToString($culture)
    )

    return , $output
}
