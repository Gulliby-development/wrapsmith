BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'options' {
    It 'matches every row' {
        $failures = @(
            Row @('wrap', '-x') '' 2 '' 'wrapsmith: unknown option -x\n'
            Row @('wrap', '-W', '5') '' 2 '' 'wrapsmith: unknown option -W\n'
            Row @('wrap', '-w', '5', '-w', '6') '' 2 '' 'wrapsmith: -w given twice\n'
            Row @('wrap', '-w') '' 2 '' 'wrapsmith: -w needs an integer from 1 to 200\n'
            Row @('wrap', '-w', '0') '' 2 '' 'wrapsmith: -w needs an integer from 1 to 200\n'
            Row @('wrap', '-w', '201') '' 2 '' 'wrapsmith: -w needs an integer from 1 to 200\n'
            Row @('wrap', '-w', '--break') '' 2 '' 'wrapsmith: -w needs an integer from 1 to 200\n'
            Row @('wrap', '-') '' 2 '' 'wrapsmith: unexpected argument -\n'
            Row @('stats', 'extra') '' 2 '' 'wrapsmith: unexpected argument extra\n'
            Row @('indent') '' 2 '' 'wrapsmith: indent needs N\n'
            Row @('indent', '81') '' 2 '' 'wrapsmith: indent needs an integer from 0 to 80\n'
            Row @('trunc', '2', '--mark', 'abc') '' 2 '' 'wrapsmith: trunc needs an integer of at least the length of the mark\n'
            Row @('table', '--align', 'lx') '' 2 '' 'wrapsmith: --align needs 1 to 20 letters l, r or c\n'
            Row @('table', '--sep', 'ab') '' 2 '' 'wrapsmith: --sep needs one printable character or tab\n'
            Row @('box', '--style', 'Star') '' 2 '' 'wrapsmith: --style needs one of ascii, star, hash\n'
        )
        $failures | Should -BeNullOrEmpty
    }
}
