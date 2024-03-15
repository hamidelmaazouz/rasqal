# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

<#
    .SYNOPSIS
        Build: Bootstraps psake and invokes the build.
#>
[cmdletbinding()]
param(
    [Parameter(Position = 0, Mandatory = 0)]
    [string[]]$taskList = @(),
    [Parameter(Position = 1, Mandatory = 0)]
    [switch]$manyLinux = $false,
    [Parameter(Position = 2, Mandatory = 0)]
    [switch]$docs = $false,
    [Parameter(Position = 3, Mandatory = $false)]
    [switch]$buildFromSource = $false
)

if ($buildFromSource -eq $false) {
    $env:RSQL_DOWNLOAD_LLVM = $true
} else {
    $env:RSQL_DOWNLOAD_LLVM = $false
}

# TODO: Should just be argument, setting as env variable for now for ease of passing.
if ($manyLinux -eq $true) {
    $env:RSQL_MANYLINUX = $true
} else {
    $env:RSQL_MANYLINUX = $false
}

# PS 7.3 introduced exec alias which breaks the build.
Remove-Item alias:exec -ErrorAction SilentlyContinue

if ($null -eq (Import-Module -Name psake -PassThru -ErrorAction SilentlyContinue)) {    
    Install-Module -Name Psake -Scope CurrentUser -Repository PSGallery -Force -Verbose
}

$scriptPath = $(Split-Path -Path $MyInvocation.MyCommand.path -Parent)

# '[p]sake' is the same as 'psake' but $Error is not polluted
Remove-Module -Name [p]sake -Verbose:$false
Import-Module -Name psake -Verbose:$false
if ($help) {
    Get-Help -Name Invoke-psake -Full
    return
}

$buildFile = "$(Join-Path $PSScriptRoot psakefile.ps1)"
if ($buildFile -and (-not (Test-Path -Path $buildFile))) {
    $absoluteBuildFile = (Join-Path -Path $scriptPath -ChildPath $buildFile)
    if (Test-path -Path $absoluteBuildFile) {
        $buildFile = $absoluteBuildFile
    }
}

$nologo = $true
$framework = $null
$initialization = {}
Invoke-psake $buildFile $taskList $framework $docs $parameters $properties $initialization $nologo $detailedDocs $notr

if (!$psake.build_success) {
    exit 1
}
