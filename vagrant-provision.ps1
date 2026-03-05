# vagrant-provision.ps1
# Provisions a Windows Server 2022 VM with DSC configurations and scripts.

$ErrorActionPreference = 'Stop'

Write-Host '============================================'
Write-Host '  x2ansible Windows Examples - Provisioning'
Write-Host '============================================'

# -- Prerequisites -----------------------------------------------------------

Write-Host "`n[1/6] Installing NuGet package provider..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null

Write-Host '[2/6] Installing DSC modules from PSGallery...'
Install-Module -Name ComputerManagementDsc -Force -AllowClobber
Install-Module -Name NetworkingDsc -Force -AllowClobber

Write-Host '[3/6] Setting execution policy...'
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
} catch [System.Security.SecurityException] {
    Write-Host '  (LocalMachine policy set, but overridden by a more specific scope -- continuing)'
}

# -- IIS Static Site (DSC) --------------------------------------------------

Write-Host "`n[4/6] Applying IIS Static Site DSC configuration..."
$iisConfigPath = 'C:\dsc-configs\configs\iis-static-site\IISStaticSite.ps1'
. $iisConfigPath
IISStaticSite -OutputPath 'C:\dsc-output\IISStaticSite' | Out-Null
Start-DscConfiguration -Path 'C:\dsc-output\IISStaticSite' -Wait -Verbose -Force

# -- System Baseline (DSC) --------------------------------------------------

Write-Host "`n[5/6] Applying System Baseline DSC configuration..."
$baselineConfigPath = 'C:\dsc-configs\configs\system-baseline\SystemBaseline.ps1'
$configDataPath     = 'C:\dsc-configs\configs\system-baseline\ConfigData.psd1'

. $baselineConfigPath

$configData = Import-PowerShellDataFile -Path $configDataPath

# Demo-only password -- do not use in production
$password   = ConvertTo-SecureString 'P@ssw0rd2024!' -AsPlainText -Force
$credential = New-Object PSCredential('x2a-demo', $password)

SystemBaseline `
    -ConfigurationData $configData `
    -DemoUserCredential $credential `
    -OutputPath 'C:\dsc-output\SystemBaseline' | Out-Null
Start-DscConfiguration -Path 'C:\dsc-output\SystemBaseline' -Wait -Verbose -Force

# -- App Deployment (Scripts) ------------------------------------------------

Write-Host "`n[6/6] Running app deployment scripts..."
& 'C:\dsc-configs\configs\app-deployment\Deploy-Apps.ps1'
& 'C:\dsc-configs\configs\app-deployment\ScheduledTask.ps1'

# -- Verification Summary ----------------------------------------------------

Write-Host "`n============================================"
Write-Host '  Verification Summary'
Write-Host '============================================'

Write-Host "`n--- IIS ---"
Get-WindowsFeature Web-Server | Format-Table Name, InstallState -AutoSize

Write-Host '--- Timezone ---'
Get-TimeZone | Select-Object Id, DisplayName

Write-Host '--- Demo User ---'
Get-LocalUser -Name 'x2a-demo' | Format-Table Name, Enabled, FullName -AutoSize

Write-Host '--- Telnet Client ---'
Get-WindowsFeature Telnet-Client | Format-Table Name, InstallState -AutoSize

Write-Host '--- Firewall Rules ---'
Get-NetFirewallRule -Name 'X2A-*' | Format-Table DisplayName, Enabled, Direction, Action -AutoSize

Write-Host '--- Chocolatey Packages ---'
choco list

Write-Host '--- Scheduled Task ---'
Get-ScheduledTask -TaskName 'X2A-DailyReport' | Format-Table TaskName, State -AutoSize

Write-Host "`n============================================"
Write-Host '  Provisioning complete!'
Write-Host '============================================'
