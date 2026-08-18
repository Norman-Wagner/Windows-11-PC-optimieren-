#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $catalogPath = Join-Path $repositoryRoot 'skills\windows-pc-guru\remediations\catalog.json'
    $lookupScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Remediation\Get-RemediationOptions.ps1'
    $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
}

Describe 'Remediation catalog' {
    It 'contains exactly ten initial guided remediations' {
        $catalog.SchemaVersion | Should -Be '1.0'
        @($catalog.Remediations).Count | Should -Be 10
        @($catalog.Remediations | Where-Object ExecutionMode -ne 'ManualGuided').Count | Should -Be 0
    }

    It 'gives every recipe the required safety metadata' {
        foreach ($recipe in $catalog.Remediations) {
            $recipe.Id | Should -Match '^[a-z0-9]+(?:[.-][a-z0-9]+)*$'
            $recipe.Risk | Should -Match '^G[0-4]$'
            $recipe.Reversibility | Should -Match '^R[0-3]$'
            @($recipe.FindingIds).Count | Should -BeGreaterThan 0
            $recipe.ExpectedBenefit | Should -Not -BeNullOrEmpty
            $recipe.Validation | Should -Not -BeNullOrEmpty
        }
    }

    It 'maps a finding to the expected remediation option' {
        $result = & $lookupScript -FindingId 'startup.high-count'
        $result.OptionCount | Should -Be 1
        $result.Options[0].Id | Should -Be 'startup.review-entries'
        $result.FilesChanged | Should -BeFalse
        $result.NetworkUsed | Should -BeFalse
    }
}
