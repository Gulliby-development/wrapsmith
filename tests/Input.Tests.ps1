BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'input' {
    It 'matches every row' {
        $failures = @(
            Row @('stats') '' 0 'lines 0\nwords 0\nchars 0\nlongest 0\nparagraphs 0\nblank 0\n' ''
            Row @('stats') '\n' 0 'lines 1\nwords 0\nchars 0\nlongest 0\nparagraphs 0\nblank 1\n' ''
            Row @('stats') 'one' 0 'lines 1\nwords 1\nchars 3\nlongest 3\nparagraphs 1\nblank 0\n' ''
            Row @('stats') 'one\n\n' 0 'lines 2\nwords 1\nchars 3\nlongest 3\nparagraphs 1\nblank 1\n' ''
            Row @('stats') 'a\tb\n' 0 'lines 1\nwords 2\nchars 3\nlongest 3\nparagraphs 1\nblank 0\n' ''
            Row @('stats') 'ab\r\ncd\n' 1 '' 'wrapsmith: line 1 has an unsupported character\n'
            Row @('trim') 'ok\nbad\rline\nlast\n' 1 '' 'wrapsmith: line 2 has an unsupported character\n'
            Row @('trim') 'no newline at end' 0 'no newline at end\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
