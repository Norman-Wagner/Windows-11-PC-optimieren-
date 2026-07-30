#requires -Version 5.1

[CmdletBinding()]
param(
    [string]$OutputPath,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$skillRoot = Join-Path $repositoryRoot 'skills\windows-pc-guru'
$validationScript = Join-Path $PSScriptRoot 'Test-Repository.ps1'

& $validationScript

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repositoryRoot 'dist\windows-pc-guru.zip'
}

$fullOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = Split-Path -Parent $fullOutputPath

if (Test-Path -LiteralPath $fullOutputPath) {
    if (-not $Force) {
        throw 'Das Zielarchiv existiert bereits. Zum Überschreiben -Force verwenden.'
    }

    Remove-Item -LiteralPath $fullOutputPath -Force
}

if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

Compress-Archive -Path (Join-Path $skillRoot '*') `
    -DestinationPath $fullOutputPath -CompressionLevel Optimal

$archive = Get-Item -LiteralPath $fullOutputPath
$hash = Get-FileHash -LiteralPath $fullOutputPath -Algorithm SHA256

[pscustomobject]@{
    OutputPath  = $archive.FullName
    LengthBytes = $archive.Length
    SHA256      = $hash.Hash
}
