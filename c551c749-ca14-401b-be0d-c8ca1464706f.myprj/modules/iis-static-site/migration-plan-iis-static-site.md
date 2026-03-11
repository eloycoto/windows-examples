# Migration Plan: IIS Static Site Configuration

**TLDR**: This PowerShell DSC configuration sets up a basic IIS web server with a static website. It installs the required Windows features, ensures the W3SVC service is running, creates a website directory, copies an index.html file, and configures the Default Web Site to point to the new directory.

## Service Type and Configuration

**Service Type**: Web Server (IIS)

**Key Operations**:
- Install IIS Web Server feature (Web-Server)
- Install IIS Management Console (Web-Mgmt-Console)
- Install IIS Scripting Tools (Web-Scripting-Tools)
- Ensure W3SVC service is running and set to automatic startup
- Create website directory at C:\inetpub\x2a-site
- Copy index.html file to the website directory
- Configure Default Web Site to use the new directory as its physical path

## File Structure

**Scripts:**
None (uses DSC configuration only)

**Modules:**
None

**DSC Configurations:**
configs/iis-static-site/IISStaticSite.ps1

**Data Files:**
configs/iis-static-site/files/index.html

## Module Explanation

The scripts perform operations in this order:

1. **IISStaticSite.ps1** (`configs/iis-static-site/IISStaticSite.ps1`):
   - Defines a DSC configuration named IISStaticSite
   - Installs Windows features: Web-Server, Web-Mgmt-Console, Web-Scripting-Tools
   - Configures W3SVC service to be running and automatic
   - Creates website directory at C:\inetpub\x2a-site
   - Copies index.html file from source to the website directory
   - Uses a Script resource to modify the Default Web Site's physical path
   - Ansible equivalent: Use win_feature, win_service, win_file, win_copy, and win_shell modules

## PowerShell to Ansible Mapping

| PowerShell Operation | Ansible Module | Notes |
|---|---|---|
| WindowsFeature[WebServer] | ansible.windows.win_feature | Installs Web-Server feature |
| WindowsFeature[WebMgmtConsole] | ansible.windows.win_feature | Installs Web-Mgmt-Console feature |
| WindowsFeature[WebScriptingTools] | ansible.windows.win_feature | Installs Web-Scripting-Tools feature |
| Service[W3SVC] | ansible.windows.win_service | Configures W3SVC service |
| File[WebsiteDirectory] | ansible.windows.win_file | Creates website directory |
| File[IndexPage] | ansible.windows.win_copy | Copies index.html file |
| Script[DefaultSitePhysicalPath] | community.windows.win_iis_website | Updates Default Web Site physical path |

## Dependencies

**PowerShell Module dependencies**: PSDesiredStateConfiguration
**Windows Features**: Web-Server, Web-Mgmt-Console, Web-Scripting-Tools
**External packages**: None
**Service dependencies**: W3SVC (IIS Web Server service)

## Checks for the Migration

**Files to verify**:
- C:\inetpub\x2a-site (directory)
- C:\inetpub\x2a-site\index.html

**Registry keys**: None explicitly modified

**Services to check**:
- W3SVC (should be running and set to automatic)

**Firewall rules**: None explicitly created (IIS may create its own)

## Pre-flight checks:
```powershell
# Check if IIS features are installed
Get-WindowsFeature -Name Web-Server, Web-Mgmt-Console, Web-Scripting-Tools

# Check if W3SVC service is running
Get-Service -Name W3SVC

# Check if website directory exists
Test-Path -Path 'C:\inetpub\x2a-site'

# Check if index.html exists
Test-Path -Path 'C:\inetpub\x2a-site\index.html'

# Check Default Web Site physical path
(Get-WebSite -Name 'Default Web Site').PhysicalPath
```