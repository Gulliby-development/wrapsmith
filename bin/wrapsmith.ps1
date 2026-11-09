#!/usr/bin/env pwsh
# Reads standard input only when it is redirected; writes the result to the standard streams with LF line ends.
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)] [string[]] $Words
)
Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot '..' 'src' 'Wrapsmith.psm1') -Force

$text = ''
if ([Console]::IsInputRedirected) {
    $text = [Console]::In.ReadToEnd()
}
$result = Invoke-Wrapsmith -Argv @($Words) -InputText $text
[Console]::Out.Write($result.Out)
[Console]::Error.Write($result.Err)
exit $result.ExitCode
