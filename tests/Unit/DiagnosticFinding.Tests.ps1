#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    . (Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Diagnostics\New-DiagnosticFinding.ps1')
}

Describe 'New-DiagnosticFinding' {
    It 'creates a finding that is never a confirmed cause by default' {
        $finding = New-DiagnosticFinding `
            -Id 'storage.system-low-space' `
            -Severity 'Warning' `
            -Confidence 'High' `
            -Summary 'Test finding' `
            -Evidence @{ FreePercent = 9.0 }

        $finding.Id | Should -Be 'storage.system-low-space'
        $finding.Severity | Should -Be 'Warning'
        $finding.Confidence | Should -Be 'High'
        $finding.IsConfirmedCause | Should -BeFalse
        $finding.Evidence.FreePercent | Should -Be 9.0
    }

    It 'rejects an invalid severity' {
        { New-DiagnosticFinding -Id 'test.rule' -Severity 'Extreme' -Confidence 'High' -Summary 'x' -Evidence @{} } |
            Should -Throw
    }

    It 'rejects unstable finding identifiers' {
        { New-DiagnosticFinding -Id 'Bad Finding ID' -Severity 'Info' -Confidence 'Low' -Summary 'x' -Evidence @{} } |
            Should -Throw
    }
}
