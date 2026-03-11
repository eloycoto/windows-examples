# Migration Plan: App Deployment Module

**TLDR**: This PowerShell module installs Chocolatey package manager and common development tools (Notepad++, 7zip, Git), creates a scheduled task that runs daily at 6:00 AM to generate a system report, and includes a script that collects system information and writes it to a report file.

## Service Type and Configuration

**Service Type**: Other (Application Deployment and Monitoring)

**Key Operations**:
- Install Chocolatey package manager if not already installed
- Install common development tools (Notepad++, 7zip, Git) using Chocolatey
- Create a directory for system reports
- Create a scheduled task that runs daily at 6:00 AM
- Generate system reports with information about hostname, OS version, uptime, CPU usage, memory, disk space, running services, and installed Chocolatey packages

## File Structure

**Scripts:**
- configs/app-deployment/Deploy-Apps.ps1
- configs/app-deployment/ScheduledTask.ps1
- configs/app-deployment/scripts/daily-report.ps1

**Modules:**
- None

**DSC Configurations:**
- None

**Data Files:**
- None

## Module Explanation

The scripts perform operations in this order:

1. **Deploy-Apps.ps1** (`configs/app-deployment/Deploy-Apps.ps1`):
   - Checks if Chocolatey is installed, and installs it if not
   - Displays the Chocolatey version
   - Defines a list of packages to install: notepadplusplus, 7zip, git
   - Loops through each package, checks if it's already installed, and installs it if not
   - Displays the list of installed packages
   - Ansible equivalent: Use `chocolatey.chocolatey.win_chocolatey` module to install Chocolatey and packages

2. **ScheduledTask.ps1** (`configs/app-deployment/ScheduledTask.ps1`):
   - Sets variables for task name, script path, and report directory
   - Creates the report directory if it doesn't exist
   - Removes the scheduled task if it already exists
   - Creates a new scheduled task that runs daily at 6:00 AM
   - Runs the scheduled task immediately for verification
   - Ansible equivalent: Use `ansible.windows.win_file` to create directory and `community.windows.win_scheduled_task` to manage the scheduled task

3. **daily-report.ps1** (`configs/app-deployment/scripts/daily-report.ps1`):
   - Sets variables for report directory, timestamp, and report file path
   - Creates a report with system information (hostname, OS version, uptime, CPU usage, memory, disk space, running services, installed Chocolatey packages)
   - Writes the report to a file
   - Ansible equivalent: Use `ansible.windows.win_copy` with content parameter to create the script file

## PowerShell to Ansible Mapping

| PowerShell Operation | Ansible Module | Notes |
|---|---|---|
| Get-Command (check if command exists) | ansible.windows.win_shell | Use `register` and check `rc` value |
| Invoke-Expression (download and run script) | chocolatey.chocolatey.win_chocolatey | Use `state: present` to install Chocolatey |
| choco install | chocolatey.chocolatey.win_chocolatey | Use `state: present` to install packages |
| New-Item (Directory) | ansible.windows.win_file | Use `state: directory` |
| Test-Path | ansible.windows.win_stat | Use `register` to check if path exists |
| Get-ScheduledTask | community.windows.win_scheduled_task | Use `name` parameter to check if task exists |
| Unregister-ScheduledTask | community.windows.win_scheduled_task | Use `state: absent` to remove task |
| Register-ScheduledTask | community.windows.win_scheduled_task | Use `state: present` to create task |
| Start-ScheduledTask | community.windows.win_scheduled_task | Use `enabled: yes` and `actions` parameter |
| Out-File | ansible.windows.win_copy | Use `content` parameter to write file content |

## Dependencies

**PowerShell Module dependencies**: None
**Windows Features**: None
**External packages**: Chocolatey, Notepad++, 7zip, Git
**Service dependencies**: None

## Checks for the Migration

**Files to verify**:
- C:\x2a-reports (directory)
- C:\x2a-reports\report_*.txt (report files)
- C:\dsc-configs\configs\app-deployment\scripts\daily-report.ps1 (script file)

**Registry keys**: None explicitly modified
**Services to check**: None explicitly managed
**Firewall rules**: None created

## Pre-flight checks:

1. Verify Chocolatey installation:
```
ansible windows -m ansible.windows.win_shell -a "choco --version"
```

2. Verify installed packages:
```
ansible windows -m ansible.windows.win_shell -a "choco list --local-only"
```

3. Verify scheduled task:
```
ansible windows -m ansible.windows.win_shell -a "Get-ScheduledTask -TaskName 'X2A-DailyReport'"
```

4. Verify report directory:
```
ansible windows -m ansible.windows.win_stat -a "path=C:\\x2a-reports"
```

5. Verify report files:
```
ansible windows -m ansible.windows.win_shell -a "Get-ChildItem -Path 'C:\\x2a-reports' -Filter 'report_*.txt'"
```