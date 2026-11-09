Set-StrictMode -Version Latest

class WrapsmithFailure : System.Exception {
    [int] $Code

    WrapsmithFailure([int] $code, [string] $message) : base($message) {
        $this.Code = $code
    }
}

foreach ($name in 'Registry', 'Text', 'Cli', 'Wrap', 'Align', 'Number', 'Tabs', 'Layout') {
    . (Join-Path $PSScriptRoot "$name.ps1")
}

function Invoke-Wrapsmith {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()] [string[]] $Argv = @(),
        [AllowEmptyString()] [string] $InputText = ''
    )
    try {
        return Invoke-WrapsmithCli -Argv $Argv -InputText $InputText
    }
    catch [WrapsmithFailure] {
        return [pscustomobject]@{
            ExitCode = $_.Exception.Code
            Out      = ''
            Err      = 'wrapsmith: ' + $_.Exception.Message + "`n"
        }
    }
}

Export-ModuleMember -Function Invoke-Wrapsmith
