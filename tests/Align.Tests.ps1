BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'align' {
    It 'matches every row' {
        $failures = @(
            Row @('center', '-w', '20') 'hi\n' 0 '         hi\n' ''
            Row @('center', '-w', '21') 'hi\n' 0 '         hi\n' ''
            Row @('center', '-w', '3') 'toolong\n' 0 'toolong\n' ''
            Row @('center', '-w', '10') '  \t pad  \n\n   \nx\n' 0 '   pad\n\n\n    x\n' ''
            Row @('right', '-w', '10') 'abc\nabcdefghij\nabcdefghijkl\n' 0 '       abc\nabcdefghij\nabcdefghijkl\n' ''
            Row @('right') 'x\n' 0 '                                                                       x\n' ''
            Row @('trunc', '8') 'hello world long text\n' 0 'hello...\n' ''
            Row @('trunc', '11') 'hello world\nexactly 11!\nexactly 12!!\n' 0 'hello world\nexactly 11!\nexactly ...\n' ''
            Row @('trunc', '3') 'abcdef\nabc\n' 0 '...\nabc\n' ''
            Row @('trunc', '5', '--mark', '>') 'abcdefgh\nabcde\n' 0 'abcd>\nabcde\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
