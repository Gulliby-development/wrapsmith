BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'cli' {
    It 'matches every row' {
        $failures = @(
            Row @() '' 2 '' 'usage: wrapsmith wrap [-w N] [--break]\n       wrapsmith fill [-w N] [--sentence]\n       wrapsmith justify [-w N]\n       wrapsmith center [-w N]\n       wrapsmith right [-w N]\n       wrapsmith indent N [--hang M]\n       wrapsmith dedent\n       wrapsmith number [--start N] [--width W] [--skip-blank]\n       wrapsmith trunc N [--mark S]\n       wrapsmith expand [-t N]\n       wrapsmith unexpand [-t N]\n       wrapsmith trim [--leading]\n       wrapsmith squeeze [--blank]\n       wrapsmith cols N [-w W] [--gap G]\n       wrapsmith box [-w N] [--style ascii|star|hash] [--pad P]\n       wrapsmith table [--sep C] [--align SPEC] [--header]\n       wrapsmith stats\n'
            Row @('help') '' 0 'usage: wrapsmith wrap [-w N] [--break]\n       wrapsmith fill [-w N] [--sentence]\n       wrapsmith justify [-w N]\n       wrapsmith center [-w N]\n       wrapsmith right [-w N]\n       wrapsmith indent N [--hang M]\n       wrapsmith dedent\n       wrapsmith number [--start N] [--width W] [--skip-blank]\n       wrapsmith trunc N [--mark S]\n       wrapsmith expand [-t N]\n       wrapsmith unexpand [-t N]\n       wrapsmith trim [--leading]\n       wrapsmith squeeze [--blank]\n       wrapsmith cols N [-w W] [--gap G]\n       wrapsmith box [-w N] [--style ascii|star|hash] [--pad P]\n       wrapsmith table [--sep C] [--align SPEC] [--header]\n       wrapsmith stats\n' ''
            Row @('-h', 'wrap', '-w', 'x') '' 0 'usage: wrapsmith wrap [-w N] [--break]\n       wrapsmith fill [-w N] [--sentence]\n       wrapsmith justify [-w N]\n       wrapsmith center [-w N]\n       wrapsmith right [-w N]\n       wrapsmith indent N [--hang M]\n       wrapsmith dedent\n       wrapsmith number [--start N] [--width W] [--skip-blank]\n       wrapsmith trunc N [--mark S]\n       wrapsmith expand [-t N]\n       wrapsmith unexpand [-t N]\n       wrapsmith trim [--leading]\n       wrapsmith squeeze [--blank]\n       wrapsmith cols N [-w W] [--gap G]\n       wrapsmith box [-w N] [--style ascii|star|hash] [--pad P]\n       wrapsmith table [--sep C] [--align SPEC] [--header]\n       wrapsmith stats\n' ''
            Row @('--version') '' 0 'wrapsmith 0.1.0\n' ''
            Row @('--version', 'x') '' 0 'wrapsmith 0.1.0\n' ''
            Row @('frob') '' 2 '' 'wrapsmith: unknown command frob\n'
            Row @('') '' 2 '' 'wrapsmith: unknown command \n'
            Row @('Wrap') '' 2 '' 'wrapsmith: unknown command Wrap\n'
        )
        $failures | Should -BeNullOrEmpty
    }
}