#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $snapshotScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\scripts\Get-WindowsPcSnapshot.ps1'
    $policyScript = Join-Path $repositoryRoot 'scripts\Test-LocalOnlyPolicy.ps1'
}

Describe 'Local-only runtime privacy' {
    It 'finds no forbidden network or destructive patterns in runtime code' {
        $result = & $policyScript
        $result.Allowed | Should -BeTrue
        $result.NetworkUsed | Should -BeFalse
        $result.Findings.Count | Should -Be 0
    }

    It 'does not expose prohibited identity fields in the snapshot contract' {
        $json = & $snapshotScript -AsJson
        $json | Should -Not -Match '"ComputerName"\s*:'
        $json | Should -Not -Match '"UserName"\s*:'
        $json | Should -Not -Match '"SerialNumber"\s*:'
        $json | Should -Not -Match '"MACAddress"\s*:'
        $json | Should -Not -Match '"IPAddress"\s*:'
        $json | Should -Not -Match '"ProcessName"\s*:'

        $snapshot = $json | ConvertFrom-Json
        $snapshot.NetworkUsed | Should -BeFalse
        $snapshot.FilesChanged | Should -BeFalse
    }
}
