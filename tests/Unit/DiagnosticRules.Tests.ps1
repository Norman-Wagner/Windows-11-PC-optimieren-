#requires -Version 5.1

BeforeAll {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $rulesScript = Join-Path $repositoryRoot 'engine\Diagnostics\Invoke-DiagnosticRules.ps1'

    function New-TestSnapshot {
        param([switch]$Healthy)

        if ($Healthy) {
            return [pscustomobject]@{
                SchemaVersion = '2.0'
                Storage = [pscustomobject]@{
                    Volumes = @([pscustomobject]@{ DriveLetter = 'C'; FreePercent = 42.0; HealthStatus = 'Healthy' })
                    PhysicalDisks = @([pscustomobject]@{ HealthStatus = 'Healthy' })
                }
                Startup = [pscustomobject]@{ Summary = @([pscustomobject]@{ StartupCommandCount = 8 }) }
                Security = [pscustomobject]@{
                    Defender = @([pscustomobject]@{ AntivirusEnabled = $true; RealTimeProtectionEnabled = $true })
                    FirewallProfiles = @([pscustomobject]@{ Name = 'Domain'; Enabled = $true }, [pscustomobject]@{ Name = 'Private'; Enabled = $true })
                }
                Updates = [pscustomobject]@{ Reboot = @([pscustomobject]@{ RebootPending = $false }) }
                ProblemDevices = @()
                Performance = [pscustomobject]@{
                    Processor = @([pscustomobject]@{ PercentProcessorTime = 3 })
                    Memory = [pscustomobject]@{ FreePhysicalMemoryPercent = 45 }
                }
                Reliability = [pscustomobject]@{ CriticalOrErrorCount = 0; EventWindowHours = 24 }
            }
        }

        return [pscustomobject]@{
            SchemaVersion = '2.0'
            Storage = [pscustomobject]@{
                Volumes = @([pscustomobject]@{ DriveLetter = 'C'; FreePercent = 4.0; HealthStatus = 'Warning' })
                PhysicalDisks = @([pscustomobject]@{ HealthStatus = 'Warning' })
            }
            Startup = [pscustomobject]@{ Summary = @([pscustomobject]@{ StartupCommandCount = 35 }) }
            Security = [pscustomobject]@{
                Defender = @([pscustomobject]@{ AntivirusEnabled = $true; RealTimeProtectionEnabled = $false })
                FirewallProfiles = @([pscustomobject]@{ Name = 'Private'; Enabled = $false })
            }
            Updates = [pscustomobject]@{ Reboot = @([pscustomobject]@{ RebootPending = $true }) }
            ProblemDevices = @([pscustomobject]@{ ConfigManagerErrorCode = 10 })
            Performance = [pscustomobject]@{
                Processor = @([pscustomobject]@{ PercentProcessorTime = 25 })
                Memory = [pscustomobject]@{ FreePhysicalMemoryPercent = 8 }
            }
            Reliability = [pscustomobject]@{ CriticalOrErrorCount = 12; EventWindowHours = 24 }
        }
    }
}

Describe 'Invoke-DiagnosticRules' {
    It 'emits expected findings for an intentionally unhealthy fixture' {
        $result = & $rulesScript -Snapshot (New-TestSnapshot)
        $ids = @($result.Findings.Id)

        $ids | Should -Contain 'storage.system-critical-space'
        $ids | Should -Contain 'storage.volume-health-warning'
        $ids | Should -Contain 'storage.physical-disk-health-warning'
        $ids | Should -Contain 'startup.high-count'
        $ids | Should -Contain 'security.realtime-protection-disabled'
        $ids | Should -Contain 'security.firewall-profile-disabled'
        $ids | Should -Contain 'updates.reboot-pending'
        $ids | Should -Contain 'devices.problem-detected'
        $ids | Should -Contain 'performance.high-processor-sample'
        $ids | Should -Contain 'performance.low-free-memory-sample'
        $ids | Should -Contain 'reliability.system-error-burst'
        @($result.Findings | Where-Object IsConfirmedCause).Count | Should -Be 0
    }

    It 'emits no findings for a healthy fixture' {
        $result = & $rulesScript -Snapshot (New-TestSnapshot -Healthy)
        $result.FindingCount | Should -Be 0
        @($result.Findings).Count | Should -Be 0
    }

    It 'rejects snapshots from an incompatible schema version' {
        $snapshot = New-TestSnapshot -Healthy
        $snapshot.SchemaVersion = '1.0'
        { & $rulesScript -Snapshot $snapshot } | Should -Throw '*SchemaVersion 2.0*'
    }
}
