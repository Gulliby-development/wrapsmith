BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'tabs' {
    It 'matches every row' {
        $failures = @(
            Row @('expand') 'a\tb\n' 0 'a       b\n' ''
            Row @('expand', '-t', '4') 'a\tb\n\tc\n' 0 'a   b\n    c\n' ''
            Row @('expand', '-t', '3') '\t\tx\n12345\t.\n' 0 '      x\n12345 .\n' ''
            Row @('expand') '\n' 0 '\n' ''
            Row @('unexpand', '-t', '4') '        deep\n' 0 '\t\tdeep\n' ''
            Row @('unexpand', '-t', '4') '      six\n' 0 '\t  six\n' ''
            Row @('unexpand', '-t', '4') '  \t \tmixed\n' 0 '\t\tmixed\n' ''
            Row @('unexpand') '    four and    inner\n' 0 '    four and    inner\n' ''
            Row @('unexpand', '-t', '2') '   \n' 0 '\t \n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
