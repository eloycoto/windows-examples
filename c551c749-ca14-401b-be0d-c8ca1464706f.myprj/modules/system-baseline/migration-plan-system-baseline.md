# Migration Plan: SystemBaseline

**TLDR**: This PowerShell DSC configuration establishes a baseline system configuration including timezone settings, a demo user account, enabling the Telnet client feature, configuring firewall rules for HTTP/HTTPS/RDP, and disabling Internet Explorer Enhanced Security Configuration for both administrators and users.

## Service Type and Configuration

**Service Type**: System Configuration (Baseline)

**Key Operations**:
- Set system timezone
- Create a demo user account
- Install Telnet Client Windows feature
- Configure firewall rules for HTTP (80), HTTPS (443), and RDP (3389)
- Disable Internet Explorer Enhanced Security Configuration

## File Structure

**DSC Configurations:**
- configs/system-baseline/SystemBaseline.ps1

## Module Explanation

The scripts perform operations in this order:

1. **SystemBaseline.ps1** (`configs/system-baseline/SystemBaseline.ps1`):
   - Defines a DSC configuration named "SystemBaseline"
   - Requires a mandatory parameter `$DemoUserCredential` for user creation
   - Imports required DSC resources from modules:
     - PSDesiredStateConfiguration (built-in)
     - ComputerManagementDsc (for TimeZone resource)
     - NetworkingDsc (for Firewall resource)
   - Sets the timezone based on node configuration
   - Creates a demo user with specified credentials
   - Installs the Telnet Client Windows feature
   - Creates three firewall rules for HTTP, HTTPS, and RDP
   - Disables IE Enhanced Security Configuration for both admins and users via registry settings
   - Ansible equivalent: Multiple Ansible modules in a playbook

## PowerShell to Ansible Mapping

| PowerShell Operation | Ansible Module | Notes |
|---|---|---|
| TimeZone resource | community.windows.win_timezone | Sets the system timezone |
| User resource | ansible.windows.win_user | Creates and manages local user accounts |
| WindowsFeature resource | ansible.windows.win_feature | Installs/uninstalls Windows features |
| Firewall resource | community.windows.win_firewall_rule | Manages Windows firewall rules |
| Registry resource | ansible.windows.win_regedit | Manages Windows registry entries |

## Dependencies

**PowerShell Module dependencies**: 
- PSDesiredStateConfiguration
- ComputerManagementDsc
- NetworkingDsc

**Windows Features**: 
- Telnet-Client

**External packages**: None

**Service dependencies**: None

## Checks for the Migration

**Files to verify**: None (no files are created or modified)

**Registry keys**: 
- HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}
- HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}

**Services to check**: None

**Firewall rules**: 
- X2A-Allow-HTTP (TCP port 80)
- X2A-Allow-HTTPS (TCP port 443)
- X2A-Allow-RDP (TCP port 3389)

## Pre-flight checks:
- Verify timezone: `Get-TimeZone`
- Check if user exists: `Get-LocalUser -Name "DemoUsername"`
- Verify Telnet Client feature: `Get-WindowsFeature -Name Telnet-Client`
- Check firewall rules: `Get-NetFirewallRule -DisplayName "Allow HTTP Inbound", "Allow HTTPS Inbound", "Allow RDP Inbound"`
- Verify IE ESC settings: 
  ```powershell
  Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled"
  Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled"
  ```