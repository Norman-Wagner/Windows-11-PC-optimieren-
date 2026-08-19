#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $catalogPath = Join-Path $repositoryRoot 'skills\windows-pc-guru\remediations\catalog.json'
    $compatibilityScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Compatibility\Test-RemediationCompatibility.ps1'
    $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
    $recipe = @($catalog.Remediations | Where-Object Id -eq 'startup.review-entries')[0]

    function New-TestContext {
        param(
            [string]$Family = 'Windows11',
            [string]$Edition = 'Pro',
            [Nullable[int]]$BuildNumber = 26100,
            [string]$Architecture = 'x64',
            [string]$DeviceType = 'Desktop',
            [string[]]$Capabilities = @('System.CimInventory')
        )
        [pscustomobject]@{
            SchemaVersion = '1.0'
            OperatingSystem = [pscustomobject]@{
                Family = $Family
                Edition = $Edition
                BuildNumber = $BuildNumber
                Architecture = $Architecture
            }
            DeviceType = $DeviceType
            Capabilities = @($Capabilities)
        }
    }
}

Describe 'Test-RemediationCompatibility' {
    It 'allows a supported Windows 11 context' {
        $result = & $compatibilityScript -Recipe $recipe -Context (New-TestContext)
        $result.Status | Should -Be 'Compatible'
        $result.Allowed | Should -BeTrue
    }

    It 'blocks Windows Server' {
        $result = & $compatibilityScript -Recipe $recipe -Context (New-TestContext -Family 'WindowsServer')
        $result.Status | Should -Be 'Blocked'
        $result.Allowed | Should -BeFalse
        ($result.BlockReasons -join ' ') | Should -Match 'nicht unterstuetzt'
    }

    It 'blocks a Windows build below the declared minimum' {
        $result = & $compatibilityScript -Recipe $recipe -Context (New-TestContext -BuildNumber 19045)
        $result.Status | Should -Be 'Blocked'
        $result.Allowed | Should -BeFalse
        ($result.BlockReasons -join ' ') | Should -Match 'MinBuild'
    }

    It 'blocks a missing required capability' {
        $result = & $compatibilityScript -Recipe $recipe -Context (New-TestContext -Capabilities @())
        $result.Status | Should -Be 'Blocked'
        $result.Allowed | Should -BeFalse
        ($result.BlockReasons -join ' ') | Should -Match 'Faehigkeiten fehlen'
    }

    It 'requires review instead of guessing when edition is unknown' {
        $result = & $compatibilityScript -Recipe $recipe -Context (New-TestContext -Edition 'Unknown')
        $result.Status | Should -Be 'ReviewRequired'
        $result.Allowed | Should -BeFalse
        @($result.ReviewReasons).Count | Should -BeGreaterThan 0
    }
}
