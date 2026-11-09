Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot '..' 'src' 'Wrapsmith.psm1') -Force

function ConvertFrom-Escaped {
    param([AllowEmptyString()] [string] $Text)
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator] {
        param($match)
        switch ($match.Groups[1].Value) {
            'n' { return "`n" }
            't' { return "`t" }
            'r' { return "`r" }
            default { return $match.Groups[1].Value }
        }
    }
    return [regex]::Replace($Text, '\\(.)', $evaluator)
}

function Row {
    param(
        [AllowEmptyCollection()] [string[]] $Argv,
        [AllowEmptyString()] [string] $InputText,
        [int] $ExitCode,
        [AllowEmptyString()] [string] $Out,
        [AllowEmptyString()] [string] $Err
    )
    $result = Invoke-Wrapsmith -Argv $Argv -InputText (ConvertFrom-Escaped $InputText)
    $wantOut = ConvertFrom-Escaped $Out
    $wantErr = ConvertFrom-Escaped $Err
    if ($result.ExitCode -ne $ExitCode -or $result.Out -cne $wantOut -or $result.Err -cne $wantErr) {
        $want = [pscustomobject]@{ ExitCode = $ExitCode; Out = $wantOut; Err = $wantErr } | ConvertTo-Json -Compress
        $got = $result | ConvertTo-Json -Compress
        return 'wrapsmith ' + ($Argv -join ' ') + " | expected $want | got $got"
    }
}
