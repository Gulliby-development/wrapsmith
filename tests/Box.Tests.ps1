BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'box' {
    It 'matches every row' {
        $failures = @(
            Row @('box') 'hello\nhi\n' 0 '+-------+\n| hello |\n| hi    |\n+-------+\n' ''
            Row @('box', '--style', 'star') 'one\n' 0 '*******\n* one *\n*******\n' ''
            Row @('box', '--style', 'hash', '--pad', '0') 'ab\ncd\n' 0 '####\n#ab#\n#cd#\n####\n' ''
            Row @('box', '--pad', '3') 'x\n' 0 '+-------+\n|   x   |\n+-------+\n' ''
            Row @('box', '-w', '12') 'short\nlonger\n' 0 '+--------------+\n| short        |\n| longer       |\n+--------------+\n' ''
            Row @('box', '-w', '4') 'ok\ntoo long\n' 1 '' 'wrapsmith: line 2 is longer than the box width 4\n'
            Row @('box') '' 0 '+--+\n+--+\n' ''
            Row @('box') 'a\n\nb\n' 0 '+---+\n| a |\n|   |\n| b |\n+---+\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
