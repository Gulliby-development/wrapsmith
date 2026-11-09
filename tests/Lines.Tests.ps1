BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'lines' {
    It 'matches every row' {
        $failures = @(
            Row @('indent', '4') 'the quick brown fox jumps over the lazy dog\n' 0 '    the quick brown fox jumps over the lazy dog\n' ''
            Row @('indent', '2', '--hang', '6') 'one\ntwo\nthree\n\nfour\nfive\n' 0 '  one\n      two\n      three\n\n  four\n      five\n' ''
            Row @('indent', '3') 'a\n  \n\n b\n' 0 '   a\n\n\n    b\n' ''
            Row @('dedent') '    four\n      six\n\n    four again\n' 0 'four\n  six\n\nfour again\n' ''
            Row @('dedent') '  two\n\tTab\n  two\n' 0 '  two\n\tTab\n  two\n' ''
            Row @('dedent') '\n   \n' 0 '\n\n' ''
            Row @('number') 'alpha\nbeta\ngamma\n' 0 '1: alpha\n2: beta\n3: gamma\n' ''
            Row @('number') '1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n' 0 ' 1: 1\n 2: 2\n 3: 3\n 4: 4\n 5: 5\n 6: 6\n 7: 7\n 8: 8\n 9: 9\n10: 10\n11: 11\n' ''
            Row @('number', '--start', '98') 'a\nb\nc\n' 0 ' 98: a\n 99: b\n100: c\n' ''
            Row @('number', '--width', '4') 'a\n\n  \nb\n' 0 '   1: a\n   2:\n   3:\n   4: b\n' ''
            Row @('number', '--skip-blank') 'a\n\nb\n  \nc\n' 0 '1: a\n\n2: b\n\n3: c\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
