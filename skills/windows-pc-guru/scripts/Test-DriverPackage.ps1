#requires -Version 5.1

<#
.SYNOPSIS
Prüft Hash und Authenticode-Signatur einer lokalen Paketdatei.

.DESCRIPTION
Das Skript lädt und installiert nichts. Eine gültige Signatur bestätigt nicht,
dass das Paket für das konkrete Gerät geeignet ist. Katalogsignaturen eines
vollständigen Treiberpakets können eine gesonderte Prüfung erfordern.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LiteralPath,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedPath = (Resolve-Path -LiteralPath $LiteralPath).ProviderPath
$file = Get-Item -LiteralPath $resolvedPath

if ($file.PSIsContainer) {
    throw 'Es muss eine einzelne Paketdatei angegeben werden.'
}

$hash = Get-FileHash -LiteralPath $resolvedPath -Algorithm SHA256
$signature = Get-AuthenticodeSignature -LiteralPath $resolvedPath
$signer = $null

if ($null -ne $signature.SignerCertificate) {
    $signer = $signature.SignerCertificate.Subject
}

$result = [pscustomobject][ordered]@{
    FileName          = $file.Name
    LengthBytes       = $file.Length
    LastWriteTimeUtc  = $file.LastWriteTimeUtc.ToString('o')
    SHA256            = $hash.Hash
    SignatureStatus   = $signature.Status.ToString()
    SignatureValid    = $signature.Status -eq
        [System.Management.Automation.SignatureStatus]::Valid
    SignerSubject     = $signer
    NetworkUsed       = $false
    InstalledAnything = $false
    Limitation        = 'Signatur und Hash beweisen weder Gerätekompatibilität noch die Vertrauenswürdigkeit der Bezugsquelle.'
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 4
}
else {
    $result
}
