$ErrorActionPreference = 'Stop'
[Console]::Title = "DFStartup"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$script:SYM_OK     = [string][char]0x2713
$script:SYM_ERR    = [string][char]0x2717
$script:SYM_WARN   = [string][char]0x26A0
$script:SYM_INFO   = [string][char]0x24D8
$script:SYM_PROMPT = [string][char]0x203A
$script:SYM_BULLET = [string][char]0x00B7
$script:CH_H       = [string][char]0x2500

$script:RuleWidth = 120
$script:RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
$script:RegName = 'HiberbootEnabled'

function Write-SectionHeader {
    param([string]$Label)
    $prefix = "  $Label "
    $dashCount = $script:RuleWidth - $prefix.Length
    if ($dashCount -lt 1) { $dashCount = 1 }
    Write-Host "$prefix$($script:CH_H * $dashCount)"
}

function Write-AppHeader {
    Write-Host "  DFStartup v26.09 $($script:SYM_BULLET) by Sabourifar"
    Write-Host ''
}

function Write-NumberedRow {
    param([string]$Num, [string]$Text)
    Write-Host ("  " + $Num.PadLeft(2) + "   " + $Text)
}

function Write-KeyRow {
    param([string]$Key, [string]$Text)
    Write-Host ("   " + $Key.PadRight(12) + $Text)
}

function Get-Prompt {
    param([string]$Label)
    return "  $Label $($script:SYM_PROMPT) "
}

function Read-Trimmed {
    param([string]$Prompt)
    Write-Host -NoNewline $Prompt
    $val = Read-Host
    return $val.Trim()
}

function Write-ErrorLine {
    param([string]$Text)
    Write-Host "  $($script:SYM_ERR) $Text" -ForegroundColor Red
}

$scriptPath = $PSCommandPath
if (-not $scriptPath) {
    Write-Host ''
    Write-Host "  $($script:SYM_ERR) This script must be downloaded and run as a file, not piped via" -ForegroundColor Red
    Write-Host '          "irm ... | iex" or similar. Save DFStartup.ps1 locally and run it.' -ForegroundColor Red
    Write-Host ''
    exit 1
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $wt = Get-Command wt.exe -ErrorAction SilentlyContinue
    try {
        if ($wt) {
            Start-Process wt.exe -ArgumentList "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        } else {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        }
    } catch {}
    exit
}

function Get-FastStartupDisabled {
    try {
        $prop = Get-ItemProperty -Path $script:RegPath -Name $script:RegName -ErrorAction Stop
        return [bool]($prop.$($script:RegName) -eq 0)
    } catch {
        return $null
    }
}

function Show-StatusMenu {
    Clear-Host
    Write-AppHeader
    Write-SectionHeader 'STATUS'
    Write-Host ''

    $disabled = Get-FastStartupDisabled
    Write-Host -NoNewline '  Fast Startup    '
    if ($null -eq $disabled) {
        Write-Host "$($script:SYM_WARN) Unknown (registry value not found)" -ForegroundColor Yellow
    } elseif ($disabled) {
        Write-Host "$($script:SYM_OK) Disabled" -ForegroundColor Green
    } else {
        Write-Host "$($script:SYM_ERR) Enabled" -ForegroundColor Red
    }
    Write-Host ''

    Write-NumberedRow '1' 'Disable Fast Startup'
    Write-NumberedRow '0' 'Quit'
    Write-Host ''

    while ($true) {
        $choice = Read-Trimmed (Get-Prompt 'Select an option')
        Write-Host ''
        switch ($choice) {
            '1' { Disable-FastStartup; return }
            '0' { exit 0 }
            default { Write-ErrorLine 'Invalid option. Please try again.'; Write-Host '' }
        }
    }
}

function Disable-FastStartup {
    Clear-Host
    Write-SectionHeader 'DISABLE FAST STARTUP'
    Write-Host ''
    Write-Host '  Disabling Fast Startup...'

    try {
        New-ItemProperty -Path $script:RegPath -Name $script:RegName -Value 0 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "  $($script:SYM_OK) Fast Startup disabled successfully." -ForegroundColor Green
        Write-Host ''
        Write-Host "  $($script:SYM_INFO) Restart your computer for the change to take effect."
    } catch {
        Write-Host "  $($script:SYM_ERR) Failed to disable Fast Startup." -ForegroundColor Red
    }

    Write-Host ''
    Write-KeyRow 'Enter' 'Back'
    Write-KeyRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $choice = Read-Trimmed (Get-Prompt 'Select an option')
        Write-Host ''
        if ($choice -eq '') { Show-StatusMenu; return }
        if ($choice -eq '0') { exit 0 }
        Write-ErrorLine 'Invalid option. Please try again.'
        Write-Host ''
    }
}

Show-StatusMenu
