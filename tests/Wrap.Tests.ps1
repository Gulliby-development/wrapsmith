BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'wrap' {
    It 'matches every row' {
        $failures = @(
            Row @('wrap', '-w', '10') 'the quick brown fox jumps over the lazy dog\n' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n' ''
            Row @('wrap') 'one two three\n\nfour five\n' 0 'one two three\n\nfour five\n' ''
            Row @('wrap', '-w', '5') 'a bb ccc dddd eeeee ffffff\n' 0 'a bb\nccc\ndddd\neeeee\nffffff\n' ''
            Row @('wrap', '-w', '5', '--break') 'a bb ccc dddd eeeee ffffffffffffffff x\n' 0 'a bb\nccc\ndddd\neeeee\nfffff\nfffff\nfffff\nf x\n' ''
            Row @('wrap', '-w', '4', '--break') 'ab cdefghij kl\n' 0 'ab\ncdef\nghij\nkl\n' ''
            Row @('wrap', '-w', '8') '  lead   and   trail  \n' 0 'lead and\ntrail\n' ''
            Row @('wrap', '-w', '1') 'a b\n' 0 'a\nb\n' ''
            Row @('wrap', '-w', '20') '\n\n  \n' 0 '\n\n\n' ''
            Row @('wrap', '-w', '7') 'one two\nthree four five\n' 0 'one two\nthree\nfour\nfive\n' ''
            Row @('wrap', '-w', '12') 'alpha\tbeta gamma\tdelta\n' 0 'alpha beta\ngamma delta\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
