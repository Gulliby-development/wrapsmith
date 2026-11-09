function Test-WsCliToken {
    param(
        [AllowEmptyString()] [string] $Value,
        [string] $Pattern
    )
    return [regex]::IsMatch($Value, $Pattern, [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
}

function Get-WsOptionKind {
    param(
        [hashtable] $Command,
        [string] $Word
    )
    foreach ($name in $Command.Flags) {
        if ([string]::Equals([string]$name, $Word, [System.StringComparison]::Ordinal)) {
            return 'flag'
        }
    }
    foreach ($name in $Command.Values.Keys) {
        if ([string]::Equals([string]$name, $Word, [System.StringComparison]::Ordinal)) {
            return [string]$Command.Values[$name]
        }
    }
    return $null
}

function ConvertFrom-WsOptionValue {
    param(
        [string] $Option,
        [AllowEmptyString()] [string] $Value,
        [hashtable] $Kind
    )
    $message = $null
    switch ($Kind.Type) {
        'int' {
            if (-not (Test-WsCliToken -Value $Value -Pattern '\A[0-9]{1,5}\z')) {
                $message = "$Option needs an integer from $($Kind.Low) to $($Kind.High)"
            }
            else {
                $number = [int]::Parse($Value, [System.Globalization.CultureInfo]::InvariantCulture)
                if ($number -lt $Kind.Low -or $number -gt $Kind.High) {
                    $message = "$Option needs an integer from $($Kind.Low) to $($Kind.High)"
                }
                else {
                    return $number
                }
            }
        }
        'mark' {
            if (-not (Test-WsCliToken -Value $Value -Pattern '\A[\x20-\x7E]{1,10}\z')) {
                $message = '--mark needs 1 to 10 printable characters'
            }
            else {
                return $Value
            }
        }
        'style' {
            if ([string]::Equals($Value, 'ascii', [System.StringComparison]::Ordinal) -or
                [string]::Equals($Value, 'star', [System.StringComparison]::Ordinal) -or
                [string]::Equals($Value, 'hash', [System.StringComparison]::Ordinal)) {
                return $Value
            }
            $message = '--style needs one of ascii, star, hash'
        }
        'sep' {
            if ([string]::Equals($Value, 'tab', [System.StringComparison]::Ordinal)) {
                return "`t"
            }
            if (Test-WsCliToken -Value $Value -Pattern '\A[\x21-\x7E]\z') {
                return $Value
            }
            $message = '--sep needs one printable character or tab'
        }
        'align' {
            if (Test-WsCliToken -Value $Value -Pattern '\A[lrc]{1,20}\z') {
                return $Value
            }
            $message = '--align needs 1 to 20 letters l, r or c'
        }
    }
    throw [WrapsmithFailure]::new(2, $message)
}

# Parse in phases: bypass help/version first, scan argv left to right so token errors win,
# validate positional arity and values, then validate text and dispatch. PowerShell handlers
# may emit lines individually or preserve a string array as one pipeline object; normalize
# either representation into the same flat line sequence before LF serialization.
function Invoke-WrapsmithCli {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()] [string[]] $Argv = @(),
        [AllowEmptyString()] [string] $InputText = ''
    )

    if ($Argv.Count -eq 0) {
        return [pscustomobject]@{ ExitCode = 2; Out = ''; Err = Get-WsUsage }
    }

    $first = $Argv[0]
    foreach ($helpWord in @('help', '-h', '--help')) {
        if ([string]::Equals($first, $helpWord, [System.StringComparison]::Ordinal)) {
            return [pscustomobject]@{ ExitCode = 0; Out = Get-WsUsage; Err = '' }
        }
    }
    if ([string]::Equals($first, '--version', [System.StringComparison]::Ordinal)) {
        return [pscustomobject]@{ ExitCode = 0; Out = "wrapsmith 0.1.0`n"; Err = '' }
    }

    $commands = Get-WsCommandTable
    $commandName = $null
    $command = $null
    foreach ($name in $commands.Keys) {
        if ([string]::Equals([string]$name, $first, [System.StringComparison]::Ordinal)) {
            $commandName = [string]$name
            $command = $commands[$name]
            break
        }
    }
    if ($null -eq $command) {
        throw [WrapsmithFailure]::new(2, "unknown command $first")
    }

    $options = @{}
    $positionals = [System.Collections.Generic.List[string]]::new()
    $index = 1
    while ($index -lt $Argv.Count) {
        $word = $Argv[$index]
        if ($word.Length -gt 1 -and $word.StartsWith('-', [System.StringComparison]::Ordinal)) {
            $kindName = Get-WsOptionKind -Command $command -Word $word
            if ($null -eq $kindName) {
                throw [WrapsmithFailure]::new(2, "unknown option $word")
            }
            if ($options.ContainsKey($word)) {
                throw [WrapsmithFailure]::new(2, "$word given twice")
            }
            if ($kindName -ceq 'flag') {
                $options[$word] = $true
                $index++
                continue
            }

            $index++
            $value = ''
            if ($index -lt $Argv.Count) {
                $value = $Argv[$index]
            }
            $kindTable = Get-WsKindTable
            $kind = $kindTable[$kindName]
            $options[$word] = ConvertFrom-WsOptionValue -Option $word -Value $value -Kind $kind
            if ($index -lt $Argv.Count) {
                $index++
            }
            continue
        }

        if ($positionals.Count -ge $command.Names.Count) {
            throw [WrapsmithFailure]::new(2, "unexpected argument $word")
        }
        $positionals.Add($word)
        $index++
    }

    if ($positionals.Count -lt $command.Names.Count) {
        throw [WrapsmithFailure]::new(2, "$commandName needs $($command.Names[0])")
    }

    $positionalValues = [System.Collections.Generic.List[int]]::new()
    for ($positionIndex = 0; $positionIndex -lt $positionals.Count; $positionIndex++) {
        $value = $positionals[$positionIndex]
        $range = $command.Ranges[$positionIndex]
        if (-not (Test-WsCliToken -Value $value -Pattern '\A[0-9]{1,5}\z')) {
            throw [WrapsmithFailure]::new(2, "$commandName needs an integer from $($range[0]) to $($range[1])")
        }
        $number = [int]::Parse($value, [System.Globalization.CultureInfo]::InvariantCulture)
        if ($number -lt $range[0] -or $number -gt $range[1]) {
            throw [WrapsmithFailure]::new(2, "$commandName needs an integer from $($range[0]) to $($range[1])")
        }
        $positionalValues.Add($number)
    }

    if ([string]::Equals($commandName, 'trunc', [System.StringComparison]::Ordinal)) {
        $mark = '...'
        if ($options.ContainsKey('--mark')) {
            $mark = $options['--mark']
        }
        if ($positionalValues[0] -lt $mark.Length) {
            throw [WrapsmithFailure]::new(2, 'trunc needs an integer of at least the length of the mark')
        }
    }

    $lines = @(Read-WsLines -Text $InputText)
    $handler = $command.Handler
    $handlerResult = & $handler -Lines $lines -Options $options -Positional @($positionalValues.ToArray())
    $outputLines = [System.Collections.Generic.List[string]]::new()
    foreach ($item in @($handlerResult)) {
        if ($null -eq $item) {
            continue
        }
        if ($item -is [string]) {
            $outputLines.Add($item)
            continue
        }
        if ($item -is [System.Collections.IEnumerable]) {
            foreach ($line in $item) {
                if ($null -eq $line) {
                    $outputLines.Add('')
                }
                else {
                    $outputLines.Add([string] $line)
                }
            }
        }
    }

    $output = ConvertTo-WsText -Lines $outputLines.ToArray()
    return [pscustomobject]@{ ExitCode = 0; Out = $output; Err = '' }
}
