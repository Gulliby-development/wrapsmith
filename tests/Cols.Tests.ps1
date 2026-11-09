BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'cols' {
    It 'matches every prescribed row' {
        $failures = @(
            Row @('cols', '2') 'one\ntwo\nthree\nfour\nfive\n' 0 'one    four\ntwo    five\nthree\n' ''
            Row @('cols', '3') 'a\nb\nc\nd\ne\nf\ng\n' 0 'a  d  g\nb  e\nc  f\n' ''
            Row @('cols', '2', '-w', '6') 'ab\ncd\nef\ngh\n' 0 'ab      ef\ncd      gh\n' ''
            Row @('cols', '2', '--gap', '4') 'aa\nb\ncc\nd\n' 0 'aa    cc\nb     d\n' ''
            Row @('cols', '2', '--gap', '0') 'aa\nbb\ncc\n' 0 'aacc\nbb\n' ''
            Row @('cols', '2', '-w', '3') 'ok\ntoolong\n' 1 '' 'wrapsmith: line 2 is longer than the column width 3\n'
            Row @('cols', '4') 'only\n' 0 'only\n' ''
            Row @('cols', '2') '' 0 '' ''
            Row @('cols', '3') 'x\n\ny\n\nz\n' 0 'x  y  z\n\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
