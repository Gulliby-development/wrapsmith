BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'space' {
    It 'matches every row' {
        $failures = @(
            Row @('trim') '  keep leading   \n\ttab trailing\t\t\n' 0 '  keep leading\n\ttab trailing\n' ''
            Row @('trim', '--leading') '  both sides  \n\tand\ttabs\t\n' 0 'both sides\nand\ttabs\n' ''
            Row @('trim') '   \n\t\n' 0 '\n\n' ''
            Row @('squeeze') 'a    b \t c\n  lead and trail  \n' 0 'a b c\nlead and trail\n' ''
            Row @('squeeze') 'x\n\n\ny\n' 0 'x\n\n\ny\n' ''
            Row @('squeeze', '--blank') '\n\nx\n\n\n  \ny\n\n\n' 0 'x\n\ny\n' ''
            Row @('squeeze', '--blank') '\n \n' 0 '' ''
            Row @('squeeze', '--blank') 'a\nb\n' 0 'a\nb\n' ''
            Row @('squeeze') 'one\ttwo   three\n' 0 'one two three\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
