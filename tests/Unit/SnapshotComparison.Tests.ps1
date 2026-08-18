#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $compareScript = Join-Path $repositoryRoot 'skills\windows-pc-guru\engine\Measurement\Compare-WindowsPcSnapshot.ps1'

    function New-ComparisonSnapshot {
        param(
            [double]$FreePercent = 10,
            [int]$StartupCount = 20,
            [int]$ProblemCount = 1,
            [bool]$RebootPending = $true,
            [double]$Cpu = 20,
            [double]$FreeMemory = 20
        )

        $problems = @()
        for ($i = 0; $i -lt $ProblemCount; $i++) { $problems += [pscustomobject]@{ ConfigManagerErrorCode = 10 } }

        [pscustomobject]@{
            SchemaVersion = '2.0'
            Storage = [pscustomobject]@{ Volumes = @([pscustomobject]@{ DriveLetter = 'C'; FreePercent = $FreePercent }) }
            Startup = [pscustomobject]@{ Summary = [pscustomobject]@{ StartupCommandCount = $StartupCount } }
            ProblemDevices = $problems
            Updates = [pscustomobject]@{ Reboot = [pscustomobject]@{ RebootPending = $RebootPending } }
            Performance = [pscustomobject]@{
                Processor = [pscustomobject]@{ PercentProcessorTime = $Cpu }
                Memory = [pscustomobject]@{ FreePhysicalMemoryPercent = $FreeMemory }
            }
            Reliability = [pscustomobject]@{ CriticalOrErrorCount = 4 }
        }
    }
}

Describe 'Compare-WindowsPcSnapshot' {
    It 'detects improvement from directional signals' {
        $before = New-ComparisonSnapshot
        $after = New-ComparisonSnapshot -FreePercent 25 -StartupCount 10 -ProblemCount 0 -RebootPending $false -Cpu 5 -FreeMemory 40
        $result = & $compareScript -Before $before -After $after

        $result.OverallStatus | Should -Be 'ImprovementDetected'
        ($result.Comparisons | Where-Object Id -eq 'storage.system-free-percent').Status | Should -Be 'Improved'
        ($result.Comparisons | Where-Object Id -eq 'startup.count').Status | Should -Be 'Improved'
        ($result.Comparisons | Where-Object Id -eq 'updates.reboot-pending').Status | Should -Be 'Improved'
        ($result.Comparisons | Where-Object Id -eq 'performance.cpu-sample').Status | Should -Be 'Inconclusive'
    }

    It 'gives regression precedence in the overall status' {
        $before = New-ComparisonSnapshot -FreePercent 20 -StartupCount 10 -ProblemCount 0 -RebootPending $false
        $after = New-ComparisonSnapshot -FreePercent 5 -StartupCount 30 -ProblemCount 2 -RebootPending $true
        $result = & $compareScript -Before $before -After $after

        $result.OverallStatus | Should -Be 'RegressionDetected'
    }

    It 'rejects incompatible snapshot versions' {
        $before = New-ComparisonSnapshot
        $after = New-ComparisonSnapshot
        $after.SchemaVersion = '1.0'
        { & $compareScript -Before $before -After $after } | Should -Throw '*SchemaVersion 2.0*'
    }
}
