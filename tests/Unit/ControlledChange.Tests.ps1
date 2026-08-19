#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $changeScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Change\Invoke-ControlledChange.ps1'
    $compatibleContext = [pscustomobject]@{
        SchemaVersion = '1.0'
        OperatingSystem = [pscustomobject]@{
            Family = 'Windows11'
            Edition = 'Pro'
            BuildNumber = 26100
            Architecture = 'x64'
        }
        DeviceType = 'Desktop'
        Capabilities = @('System.CimInventory')
    }
    $blockedContext = [pscustomobject]@{
        SchemaVersion = '1.0'
        OperatingSystem = [pscustomobject]@{
            Family = 'WindowsServer'
            Edition = 'Unknown'
            BuildNumber = 26100
            Architecture = 'x64'
        }
        DeviceType = 'Server'
        Capabilities = @('System.CimInventory')
    }
}

Describe 'Invoke-ControlledChange' {
    It 'blocks an incompatible context before preview' {
        $result = & $changeScript -RecipeId 'startup.review-entries' -CompatibilityContext $blockedContext

        $result.Status | Should -Be 'CompatibilityBlocked'
        $result.Approved | Should -BeFalse
        $result.Plan | Should -BeNullOrEmpty
        $result.Compatibility.Allowed | Should -BeFalse
        $result.Applied | Should -BeFalse
    }

    It 'returns preview only for a compatible context without explicit approval' {
        $result = & $changeScript -RecipeId 'startup.review-entries' -CompatibilityContext $compatibleContext

        $result.Status | Should -Be 'PreviewOnly'
        $result.Approved | Should -BeFalse
        $result.Applied | Should -BeFalse
        $result.Plan.RequiresApproval | Should -BeTrue
        $result.Plan.CompatibilityStatus | Should -Be 'Compatible'
    }

    It 'does not automate ManualGuided production recipes even after approval' {
        $result = & $changeScript -RecipeId 'startup.review-entries' -CompatibilityContext $compatibleContext -Approve

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
        { & $changeScript -RecipeId 'unknown.recipe' -CompatibilityContext $compatibleContext } | Should -Throw '*Unbekannte Remediation-ID*'
    }
}
