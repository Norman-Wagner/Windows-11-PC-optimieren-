#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $skillRoot = Join-Path $repositoryRoot 'skills\windows-pc-guru'
    $snapshotScript = Join-Path $skillRoot 'scripts\Get-WindowsPcSnapshot.ps1'
    $rulesScript = Join-Path $skillRoot 'engine\Diagnostics\Invoke-DiagnosticRules.ps1'
    $schemaPath = Join-Path $skillRoot 'schemas\windows-pc-snapshot.schema.json'
}

Describe 'Windows PC Snapshot 2.0' {
    It 'produces schema version 2.0 and required diagnostic groups' {
        $json = & $snapshotScript -AsJson
        $snapshot = $json | ConvertFrom-Json

        $snapshot.SchemaVersion | Should -Be '2.0'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Performance'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Storage'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Startup'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Security'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Power'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Updates'
        $snapshot.PSObject.Properties.Name | Should -Contain 'Reliability'
    }

    It 'validates against the repository JSON schema' {
        if ($null -eq (Get-Command Test-Json -ErrorAction SilentlyContinue)) {
            Set-ItResult -Skipped -Because 'Test-Json ist in dieser PowerShell-Version nicht verfügbar.'
            return
        }

        $json = & $snapshotScript -AsJson
        ($json | Test-Json -SchemaFile $schemaPath) | Should -BeTrue
    }

    It 'can be evaluated by the findings engine without changing files or using network' {
        $snapshot = & $snapshotScript -AsJson | ConvertFrom-Json
        $result = & $rulesScript -Snapshot $snapshot

        $result.SnapshotSchemaVersion | Should -Be '2.0'
        $result.NetworkUsed | Should -BeFalse
        $result.FilesChanged | Should -BeFalse
        @($result.Findings | Where-Object { $_.IsConfirmedCause }).Count | Should -Be 0
    }
}
