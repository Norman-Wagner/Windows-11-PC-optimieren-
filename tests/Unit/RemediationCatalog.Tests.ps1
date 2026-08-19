#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $catalogPath = Join-Path $repositoryRoot 'skills\windows-pc-guru\remediations\catalog.json'
    $schemaPath = Join-Path $repositoryRoot 'skills\windows-pc-guru\schemas\remediation.schema.json'
    $lookupScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Remediation\Get-RemediationOptions.ps1'
    $catalogText = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath
    $catalog = $catalogText | ConvertFrom-Json
    $schemaText = Get-Content -Raw -Encoding UTF8 -LiteralPath $schemaPath
    $compatibleContext = [pscustomobject]@{
        SchemaVersion = '1.0'
        OperatingSystem = [pscustomobject]@{
            Family = 'Windows11'
            Edition = 'Pro'
            BuildNumber = 26100
            Architecture = 'x64'
        }
        DeviceType = 'Desktop'
        Capabilities = @(
            'Storage.VolumeInventory',
            'Storage.PhysicalDiskInventory',
            'Security.DefenderStatus',
            'Security.FirewallProfiles',
            'Reliability.SystemEventLog',
            'System.CimInventory',
            'Devices.PnpInventory'
        )
    }
}

Describe 'Remediation catalog' {
    It 'uses schema version 2.0 and validates against the repository schema' {
        $catalog.SchemaVersion | Should -Be '2.0'
        { $catalogText | Test-Json -Schema $schemaText -ErrorAction Stop } | Should -Not -Throw
        ($catalogText | Test-Json -Schema $schemaText) | Should -BeTrue
    }

    It 'contains exactly ten initial guided remediations' {
        @($catalog.Remediations).Count | Should -Be 10
        @($catalog.Remediations | Where-Object ExecutionMode -ne 'ManualGuided').Count | Should -Be 0
    }

    It 'gives every recipe the required safety and compatibility metadata' {
        foreach ($recipe in $catalog.Remediations) {
            $recipe.Id | Should -Match '^[a-z0-9]+(?:[.-][a-z0-9]+)*$'
            $recipe.Risk | Should -Match '^G[0-4]$'
            $recipe.Reversibility | Should -Match '^R[0-3]$'
            @($recipe.FindingIds).Count | Should -BeGreaterThan 0
            $recipe.ExpectedBenefit | Should -Not -BeNullOrEmpty
            $recipe.Validation | Should -Not -BeNullOrEmpty
            @($recipe.Compatibility.OsFamilies).Count | Should -BeGreaterThan 0
            @($recipe.Compatibility.Editions).Count | Should -BeGreaterThan 0
            @($recipe.Compatibility.Architectures).Count | Should -BeGreaterThan 0
            @($recipe.Compatibility.DeviceTypes).Count | Should -BeGreaterThan 0
            $recipe.Compatibility.MinBuild | Should -BeGreaterOrEqual 22000
        }
    }

    It 'maps a finding to the expected compatible remediation option' {
        $result = & $lookupScript -FindingId 'startup.high-count' -CompatibilityContext $compatibleContext
        $result.SchemaVersion | Should -Be '2.0'
        $result.OptionCount | Should -Be 1
        $result.CompatibleOptionCount | Should -Be 1
        $result.Options[0].Id | Should -Be 'startup.review-entries'
        $result.Options[0].CompatibilityResult.Status | Should -Be 'Compatible'
        $result.FilesChanged | Should -BeFalse
        $result.NetworkUsed | Should -BeFalse
    }
}
