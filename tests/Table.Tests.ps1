BeforeAll {
    . (Join-Path $PSScriptRoot 'Harness.ps1')
}

Describe 'table' {
    It 'matches every row' {
        $failures = @(
            Row @('table') 'a,bb,c\nxxx,y,zzzzz\n' 0 'a    bb  c\nxxx  y   zzzzz\n' ''
            Row @('table', '--header') 'name,qty,price\napple,3,1.5\nfig,12,10\n' 0 'name   qty  price\n-----  ---  -----\napple  3    1.5\nfig    12   10\n' ''
            Row @('table', '--align', 'rc') 'a,b,c\nlonger,x,yy\n' 0 '     a  b  c\nlonger  x  yy\n' ''
            Row @('table', '--sep', ';') 'a;b\nccc;dd\n' 0 'a    b\nccc  dd\n' ''
            Row @('table', '--sep', 'tab') 'k\tv\nkey\tvalue\n' 0 'k    v\nkey  value\n' ''
            Row @('table') 'a,b,c\nd\ne,f\n' 0 'a  b  c\nd\ne  f\n' ''
            Row @('table') '  p , qq \n r,  s  \n' 0 'p  qq\nr  s\n' ''
            Row @('table', '--align', 'c') 'abcde,x\nab,y\nabc,z\n' 0 'abcde  x\n ab    y\n abc   z\n' ''
        )
        $failures | Should -BeNullOrEmpty
    }
}
