BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'justify' {
    It 'matches every row' {
        $failures = @(
            Row @('justify', '-w', '20') 'the quick brown fox jumps over the lazy dog again and again\n' 0 'the  quick brown fox\njumps  over the lazy\ndog again and again\n' ''
            Row @('justify', '-w', '30') 'one two three four five six\nseven eight nine ten\n\neleven twelve thirteen fourteen fifteen sixteen\n' 0 'one  two  three  four five six\nseven eight nine ten\n\neleven     twelve     thirteen\nfourteen fifteen sixteen\n' ''
            Row @('justify', '-w', '20') 'short\n' 0 'short\n' ''
            Row @('justify', '-w', '6') 'tiny extraordinarily long word\n' 0 'tiny\nextraordinarily\nlong\nword\n' ''
            Row @('justify', '-w', '12') 'aa bb cc dd ee ff gg hh ii\n' 0 'aa  bb cc dd\nee  ff gg hh\nii\n' ''
            Row @('justify', '-w', '15') 'exactly fifteen ab cd\n' 0 'exactly fifteen\nab cd\n' ''
            Row @('justify') '' 0 '' ''
            Row @('justify', '-w', '8') 'a b c d e f g h i j\n' 0 'a  b c d\ne  f g h\ni j\n' ''
            Row @('justify', '-w', '25') 'tabs\tand   many    spaces are first\tcollapsed by the words\n' 0 'tabs  and many spaces are\nfirst  collapsed  by  the\nwords\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
