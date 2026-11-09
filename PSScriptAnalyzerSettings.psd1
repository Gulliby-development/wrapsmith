@{
    Severity     = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidUsingCmdletAliases'
        'PSAvoidUsingWriteHost'
        'PSAvoidUsingInvokeExpression'
        'PSAvoidUsingEmptyCatchBlock'
        'PSAvoidSemicolonsAsLineTerminators'
        'PSUseDeclaredVarsMoreThanAssignments'
        'PSUseApprovedVerbs'
        'PSUseCorrectCasing'
        'PSUseConsistentIndentation'
        'PSUseConsistentWhitespace'
        'PSPlaceOpenBrace'
        'PSPlaceCloseBrace'
        'PSPossibleIncorrectComparisonWithNull'
        'PSMisleadingBacktick'
    )
    Rules        = @{
        PSUseConsistentIndentation = @{
            Enable              = $true
            IndentationSize     = 4
            Kind                = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }
        PSUseConsistentWhitespace  = @{
            Enable          = $true
            CheckInnerBrace = $true
            CheckOpenBrace  = $true
            CheckOpenParen  = $true
            CheckOperator   = $true
            CheckPipe       = $true
            CheckSeparator  = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }
    }
}
