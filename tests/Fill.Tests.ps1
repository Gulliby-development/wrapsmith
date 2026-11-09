BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'fill' {
    It 'matches every row' {
        $failures = @(
            Row @('fill', '-w', '20') 'the quick brown fox\njumps over the\nlazy dog again and again\n' 0 'the quick brown fox\njumps over the lazy\ndog again and again\n' ''
            Row @('fill', '-w', '30') 'first para\nstill first\n\n\n\nsecond para\n' 0 'first para still first\n\nsecond para\n' ''
            Row @('fill', '-w', '30') '\n\nonly para\n\n\n' 0 'only para\n' ''
            Row @('fill', '-w', '20', '--sentence') 'Hello there. How are you? Fine! Thanks.\n' 0 'Hello there.  How\nare you?  Fine!\nThanks.\n' ''
            Row @('fill', '-w', '6') 'ab. cd ef\n' 0 'ab. cd\nef\n' ''
            Row @('fill', '-w', '6', '--sentence') 'ab. cd ef\n' 0 'ab.\ncd ef\n' ''
            Row @('fill', '-w', '10') 'tiny extraordinarily long word\n' 0 'tiny\nextraordinarily\nlong word\n' ''
            Row @('fill') '\n  \n\n' 0 '' ''
            Row @('fill', '-w', '30', '--sentence') 'Use e.g. tabs. Not spaces.\n' 0 'Use e.g.  tabs.  Not spaces.\n' ''
            Row @('fill') 'The default width is seventy-two characters, so this paragraph of two\nlines is joined and wrapped again at that width.\n' 0 'The default width is seventy-two characters, so this paragraph of two\nlines is joined and wrapped again at that width.\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
