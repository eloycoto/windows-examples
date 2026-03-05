# Deploy-Apps.ps1
# Installs Chocolatey and common development tools.
# This is a plain PowerShell script (not DSC) to exercise the ScriptAnalysisService path.

# -- Install Chocolatey ------------------------------------------------------

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host '[Deploy-Apps] Installing Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host '[Deploy-Apps] Chocolatey version:' (choco --version)

# -- Install packages --------------------------------------------------------

$packages = @('notepadplusplus', '7zip', 'git')

foreach ($pkg in $packages) {
    $installed = choco list --exact $pkg --limit-output 2>$null
    if ($installed) {
        Write-Host "[Deploy-Apps] $pkg is already installed, skipping."
        continue
    }

    Write-Host "[Deploy-Apps] Installing $pkg..."
    choco install $pkg -y --no-progress
}

Write-Host '[Deploy-Apps] Package installation complete.'
Write-Host '[Deploy-Apps] Installed packages:'
choco list
