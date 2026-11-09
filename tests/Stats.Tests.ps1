BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'stats' {
    It 'matches every row' {
        $failures = @(
            Row @('stats') 'the quick brown fox jumps over the lazy dog\n' 0 'lines 1\nwords 9\nchars 43\nlongest 43\nparagraphs 1\nblank 0\n' ''
            Row @('stats') 'the quick brown fox\njumps over the\nlazy dog again and again\n' 0 'lines 3\nwords 12\nchars 57\nlongest 24\nparagraphs 1\nblank 0\n' ''
            Row @('stats') 'first para\nstill first\n\nsecond para\n\n\n  \nthird\n' 0 'lines 8\nwords 7\nchars 39\nlongest 11\nparagraphs 3\nblank 4\n' ''
            Row @('stats') '   \n\t\n' 0 'lines 2\nwords 0\nchars 4\nlongest 3\nparagraphs 0\nblank 2\n' ''
            Row @('stats') 'a  b\tc\n' 0 'lines 1\nwords 3\nchars 6\nlongest 6\nparagraphs 1\nblank 0\n' ''
            Row @('stats') 'short\na much longer line here\nmid size\n' 0 'lines 3\nwords 8\nchars 36\nlongest 23\nparagraphs 1\nblank 0\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
