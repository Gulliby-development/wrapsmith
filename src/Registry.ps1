# The command table, the option value kinds and the usage text (fixed; the command bodies are in the other files).
# The stubs at the end are replaced by the real functions: Wrapsmith.psm1 loads the files that follow this one later, and a later definition wins.

$script:WsUsage = @(
    'usage: wrapsmith wrap [-w N] [--break]'
    '       wrapsmith fill [-w N] [--sentence]'
    '       wrapsmith justify [-w N]'
    '       wrapsmith center [-w N]'
    '       wrapsmith right [-w N]'
    '       wrapsmith indent N [--hang M]'
    '       wrapsmith dedent'
    '       wrapsmith number [--start N] [--width W] [--skip-blank]'
    '       wrapsmith trunc N [--mark S]'
    '       wrapsmith expand [-t N]'
    '       wrapsmith unexpand [-t N]'
    '       wrapsmith trim [--leading]'
    '       wrapsmith squeeze [--blank]'
    '       wrapsmith cols N [-w W] [--gap G]'
    '       wrapsmith box [-w N] [--style ascii|star|hash] [--pad P]'
    '       wrapsmith table [--sep C] [--align SPEC] [--header]'
    '       wrapsmith stats'
) -join "`n"
$script:WsUsage += "`n"

# Flags are boolean options; Values maps an option that takes the next word to its kind; Names are the positional arguments and Ranges their integer bounds.
$script:WsCommands = [ordered]@{
    wrap     = @{ Handler = 'Invoke-WsWrap'; Flags = @('--break'); Values = @{ '-w' = 'width' }; Names = @(); Ranges = @() }
    fill     = @{ Handler = 'Invoke-WsFill'; Flags = @('--sentence'); Values = @{ '-w' = 'width' }; Names = @(); Ranges = @() }
    justify  = @{ Handler = 'Invoke-WsJustify'; Flags = @(); Values = @{ '-w' = 'width' }; Names = @(); Ranges = @() }
    center   = @{ Handler = 'Invoke-WsCenter'; Flags = @(); Values = @{ '-w' = 'width' }; Names = @(); Ranges = @() }
    right    = @{ Handler = 'Invoke-WsRight'; Flags = @(); Values = @{ '-w' = 'width' }; Names = @(); Ranges = @() }
    indent   = @{ Handler = 'Invoke-WsIndent'; Flags = @(); Values = @{ '--hang' = 'hang' }; Names = @('N'); Ranges = @(, @(0, 80)) }
    dedent   = @{ Handler = 'Invoke-WsDedent'; Flags = @(); Values = @{}; Names = @(); Ranges = @() }
    number   = @{ Handler = 'Invoke-WsNumber'; Flags = @('--skip-blank'); Values = @{ '--start' = 'start'; '--width' = 'numwidth' }; Names = @(); Ranges = @() }
    trunc    = @{ Handler = 'Invoke-WsTrunc'; Flags = @(); Values = @{ '--mark' = 'mark' }; Names = @('N'); Ranges = @(, @(1, 200)) }
    expand   = @{ Handler = 'Invoke-WsExpand'; Flags = @(); Values = @{ '-t' = 'tab' }; Names = @(); Ranges = @() }
    unexpand = @{ Handler = 'Invoke-WsUnexpand'; Flags = @(); Values = @{ '-t' = 'tab' }; Names = @(); Ranges = @() }
    trim     = @{ Handler = 'Invoke-WsTrim'; Flags = @('--leading'); Values = @{}; Names = @(); Ranges = @() }
    squeeze  = @{ Handler = 'Invoke-WsSqueeze'; Flags = @('--blank'); Values = @{}; Names = @(); Ranges = @() }
    cols     = @{ Handler = 'Invoke-WsCols'; Flags = @(); Values = @{ '-w' = 'colwidth'; '--gap' = 'gap' }; Names = @('N'); Ranges = @(, @(2, 8)) }
    box      = @{ Handler = 'Invoke-WsBox'; Flags = @(); Values = @{ '-w' = 'boxwidth'; '--style' = 'style'; '--pad' = 'pad' }; Names = @(); Ranges = @() }
    table    = @{ Handler = 'Invoke-WsTable'; Flags = @('--header'); Values = @{ '--sep' = 'sep'; '--align' = 'align' }; Names = @(); Ranges = @() }
    stats    = @{ Handler = 'Invoke-WsStats'; Flags = @(); Values = @{}; Names = @(); Ranges = @() }
}

# An integer kind takes one to five decimal digits (leading zeros allowed) with a value from Low to High; the message of every kind is in the spec.
$script:WsKinds = @{
    width    = @{ Type = 'int'; Low = 1; High = 200 }
    hang     = @{ Type = 'int'; Low = 0; High = 80 }
    start    = @{ Type = 'int'; Low = 0; High = 99999 }
    numwidth = @{ Type = 'int'; Low = 1; High = 9 }
    tab      = @{ Type = 'int'; Low = 1; High = 16 }
    colwidth = @{ Type = 'int'; Low = 1; High = 200 }
    gap      = @{ Type = 'int'; Low = 0; High = 20 }
    boxwidth = @{ Type = 'int'; Low = 1; High = 200 }
    pad      = @{ Type = 'int'; Low = 0; High = 8 }
    mark     = @{ Type = 'mark' }
    style    = @{ Type = 'style' }
    sep      = @{ Type = 'sep' }
    align    = @{ Type = 'align' }
}

function Get-WsUsage { $script:WsUsage }
function Get-WsCommandTable { $script:WsCommands }
function Get-WsKindTable { $script:WsKinds }

# Every command has a stub until its file defines the handler again (a handler takes the input lines, the parsed options and the positional values, and returns the output lines).
$stub = { param($Lines, $Options, $Positional) throw [WrapsmithFailure]::new(1, 'not implemented') }
foreach ($command in $script:WsCommands.Values) {
    Set-Item -Path ('function:script:' + $command.Handler) -Value $stub
}
