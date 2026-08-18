#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $changeScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Change\Invoke-ControlledChange.ps1'
}

Describe 'Invoke-ControlledChange' {
    It 'returns preview only without explicit approval' {
        $result = & $changeScript -RecipeId 'startup.review-entries'

        $result.Status | Should -Be 'PreviewOnly'
        $result.Approved | Should -BeFalse
        $result.Applied | Should -BeFalse
        $result.Plan.RequiresApproval | Should -BeTrue
    }

    It 'does not automate ManualGuided production recipes even after approval' {
        $result = & $changeScript -RecipeId 'startup.review-entries' -Approve

        $result.Status | Should -Be 'ManualExecutionRequired'
        $result.Approved | Should -BeTrue
        $result.Applied | Should -BeFalse
        $result.FilesChanged | Should -BeFalse
        $result.NetworkUsed | Should -BeFalse
    }

    It 'proves backup apply and verify in the in-memory test harness' {
        $result = & $changeScript -RecipeId 'internal.test-noop' -TestHarness -Approve

        $result.Status | Should -Be 'AppliedAndVerified'
        $result.BackupCreated | Should -BeTrue
        $result.Applied | Should -BeTrue
        $result.Verified | Should -BeTrue
        $result.RolledBack | Should -BeFalse
        $result.Backup.OriginalState | Should -Be 'Before'
        $result.FinalState | Should -Be 'After'
        $result.FilesChanged | Should -BeFalse
    }

    It 'rolls back when verification fails in the in-memory test harness' {
        $result = & $changeScript -RecipeId 'internal.test-noop' -TestHarness -Approve -SimulateVerifyFailure

        $result.Status | Should -Be 'VerificationFailedRolledBack'
        $result.Applied | Should -BeTrue
        $result.Verified | Should -BeFalse
        $result.RolledBack | Should -BeTrue
        $result.FinalState | Should -Be 'Before'
    }

    It 'rejects unknown production recipes' {
        { & $changeScript -RecipeId 'unknown.recipe' } | Should -Throw '*Unbekannte Remediation-ID*'
    }
}
