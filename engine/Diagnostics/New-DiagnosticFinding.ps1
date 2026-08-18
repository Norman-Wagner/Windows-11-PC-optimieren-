#requires -Version 5.1

function New-DiagnosticFinding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[a-z0-9]+(?:[.-][a-z0-9]+)*$')]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Info', 'Warning', 'Critical')]
        [string]$Severity,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Low', 'Medium', 'High')]
        [string]$Confidence,

        [Parameter(Mandatory = $true)]
        [string]$Summary,

        [Parameter(Mandatory = $true)]
        [hashtable]$Evidence,

        [string]$SuggestedProbe
    )

    [pscustomobject][ordered]@{
        Id = $Id
        Severity = $Severity
        Confidence = $Confidence
        Summary = $Summary
        Evidence = [pscustomobject]$Evidence
        SuggestedProbe = $SuggestedProbe
        IsConfirmedCause = $false
    }
}
