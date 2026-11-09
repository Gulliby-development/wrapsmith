function Get-WsFlowLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Words,
        [Parameter(Mandatory)]
        [int] $Width,
        [switch] $BreakLongWords,
        [switch] $SentenceSpacing
    )

    $result = [System.Collections.Generic.List[string]]::new()
    $current = ''
    for ($index = 0; $index -lt $Words.Count; $index++) {
        $word = $Words[$index]
        if ($BreakLongWords -and $word.Length -gt $Width) {
            if ($current.Length -gt 0) {
                $result.Add($current)
                $current = ''
            }
            $offset = 0
            while (($word.Length - $offset) -gt $Width) {
                $result.Add($word.Substring($offset, $Width))
                $offset += $Width
            }
            $current = $word.Substring($offset)
            continue
        }

        if ($current.Length -eq 0) {
            $current = $word
            continue
        }

        $separator = ' '
        if ($SentenceSpacing -and $current -match '[.!?]\z') {
            $separator = '  '
        }
        if (($current.Length + $separator.Length + $word.Length) -le $Width) {
            $current += $separator + $word
        }
        else {
            $result.Add($current)
            $current = $word
        }
    }

    if ($current.Length -gt 0) {
        $result.Add($current)
    }
    return , $result.ToArray()
}

function Get-WsWordsFromLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $words = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        $lineWords = Get-WsWords -Line $line
        foreach ($word in $lineWords) {
            $words.Add($word)
        }
    }
    return , $words.ToArray()
}

function Invoke-WsWrap {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $width = 72
    if ($Options.ContainsKey('-w')) {
        $width = [int] $Options['-w']
    }
    $output = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            $output.Add('')
            continue
        }
        $words = Get-WsWords -Line $line
        $flow = Get-WsFlowLines -Words $words -Width $width -BreakLongWords:$Options.ContainsKey('--break')
        foreach ($wrappedLine in $flow) {
            $output.Add($wrappedLine)
        }
    }
    return , $output.ToArray()
}

function Invoke-WsFill {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $width = 72
    if ($Options.ContainsKey('-w')) {
        $width = [int] $Options['-w']
    }
    $sentence = $Options.ContainsKey('--sentence')
    $output = [System.Collections.Generic.List[string]]::new()
    $paragraphs = Get-WsParagraphs -Lines $Lines
    for ($index = 0; $index -lt $paragraphs.Count; $index++) {
        if ($index -gt 0) {
            $output.Add('')
        }
        $words = Get-WsWordsFromLines -Lines $paragraphs[$index].Lines
        $flow = Get-WsFlowLines -Words $words -Width $width -SentenceSpacing:$sentence
        foreach ($flowLine in $flow) {
            $output.Add($flowLine)
        }
    }
    return , $output.ToArray()
}

function Invoke-WsJustify {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Lines,
        [Parameter(Mandatory)] [hashtable] $Options,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]] $Positional
    )

    $width = 72
    if ($Options.ContainsKey('-w')) {
        $width = [int] $Options['-w']
    }
    $output = [System.Collections.Generic.List[string]]::new()
    $paragraphs = Get-WsParagraphs -Lines $Lines
    for ($paragraphIndex = 0; $paragraphIndex -lt $paragraphs.Count; $paragraphIndex++) {
        if ($paragraphIndex -gt 0) {
            $output.Add('')
        }
        $words = Get-WsWordsFromLines -Lines $paragraphs[$paragraphIndex].Lines
        $flow = Get-WsFlowLines -Words $words -Width $width
        for ($lineIndex = 0; $lineIndex -lt $flow.Count; $lineIndex++) {
            $line = $flow[$lineIndex]
            $lineWords = Get-WsWords -Line $line
            if ($lineIndex -lt ($flow.Count - 1) -and $lineWords.Count -gt 1) {
                $letters = 0
                foreach ($word in $lineWords) {
                    $letters += $word.Length
                }
                $spaces = $width - $letters
                $gapCount = $lineWords.Count - 1
                $quotient = [int] [math]::Floor($spaces / $gapCount)
                $remainder = $spaces % $gapCount
                $builder = [System.Text.StringBuilder]::new()
                for ($wordIndex = 0; $wordIndex -lt $lineWords.Count; $wordIndex++) {
                    if ($wordIndex -gt 0) {
                        $gapWidth = $quotient
                        if (($wordIndex - 1) -lt $remainder) {
                            $gapWidth++
                        }
                        [void] $builder.Append((' ' * $gapWidth))
                    }
                    [void] $builder.Append($lineWords[$wordIndex])
                }
                $line = $builder.ToString()
            }
            $output.Add($line)
        }
    }
    return , $output.ToArray()
}
