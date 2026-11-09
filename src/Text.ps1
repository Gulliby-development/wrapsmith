function Read-WsLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Text
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    if ($Text.Length -gt 0) {
        $start = 0
        while ($start -lt $Text.Length) {
            $newline = $Text.IndexOf([char]10, $start)
            if ($newline -lt 0) {
                $lines.Add($Text.Substring($start))
                break
            }

            $lines.Add($Text.Substring($start, $newline - $start))
            $start = $newline + 1
        }
    }

    for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
        foreach ($character in $lines[$lineIndex].ToCharArray()) {
            $codePoint = [int] $character
            if ($codePoint -ne 9 -and ($codePoint -lt 32 -or $codePoint -gt 126)) {
                throw [WrapsmithFailure]::new(1, "line $($lineIndex + 1) has an unsupported character")
            }
        }
    }

    return $lines.ToArray()
}

function ConvertTo-WsText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $builder = [System.Text.StringBuilder]::new()
    foreach ($line in $Lines) {
        [void] $builder.Append($line)
        [void] $builder.Append([char]10)
    }

    return $builder.ToString()
}

function Test-WsBlank {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Line
    )

    foreach ($character in $Line.ToCharArray()) {
        if ($character -ne ' ' -and [int] $character -ne 9) {
            return $false
        }
    }

    return $true
}

function Get-WsWords {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Line
    )

    $words = [System.Collections.Generic.List[string]]::new()
    $start = -1
    for ($index = 0; $index -lt $Line.Length; $index++) {
        $character = $Line[$index]
        if ($character -eq ' ' -or [int] $character -eq 9) {
            if ($start -ge 0) {
                $words.Add($Line.Substring($start, $index - $start))
                $start = -1
            }
        }
        elseif ($start -lt 0) {
            $start = $index
        }
    }

    if ($start -ge 0) {
        $words.Add($Line.Substring($start))
    }

    return , $words.ToArray()
}

function Get-WsParagraphs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $paragraphs = [System.Collections.Generic.List[object]]::new()
    $current = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Lines) {
        if (Test-WsBlank -Line $line) {
            if ($current.Count -gt 0) {
                $paragraphs.Add([pscustomobject]@{
                        Lines = [string[]] $current.ToArray()
                    })
                $current.Clear()
            }
        }
        else {
            $current.Add($line)
        }
    }

    if ($current.Count -gt 0) {
        $paragraphs.Add([pscustomobject]@{
                Lines = [string[]] $current.ToArray()
            })
    }

    return , $paragraphs.ToArray()
}
