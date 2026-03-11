# MIGRATION FROM POWERSHELL DSC TO ANSIBLE

## Executive Summary

This repository contains Windows Server configuration management using PowerShell Desired State Configuration (DSC) and PowerShell scripts. The migration to Ansible will involve converting DSC configurations and PowerShell scripts to Ansible roles and playbooks. The repository is of moderate complexity with three main configuration modules focused on Windows Server 2022 environments.

**Estimated Timeline:** 2-3 weeks for complete migration
**Complexity:** Moderate
**Primary Technology:** PowerShell DSC and PowerShell scripts

## Module Migration Plan

This repository contains PowerShell DSC configurations and scripts that need individual migration planning:

### MODULE INVENTORY

- **system-baseline**:
    - Description: Windows Server baseline configuration including timezone settings, local user creation, Windows features installation, firewall rules, and IE Enhanced Security Configuration
    - Path: configs/system-baseline
    - Technology: PowerShell DSC
    - Key Features: TimeZone configuration, local user management, Windows feature installation, firewall rules management, registry modifications

- **iis-static-site**:
    - Description: IIS web server installation and configuration with static website deployment
    - Path: configs/iis-static-site
    - Technology: PowerShell DSC
    - Key Features: IIS feature installation, website directory creation, content deployment, website configuration

- **app-deployment**:
    - Description: Application deployment scripts for installing Chocolatey packages and configuring scheduled tasks
    - Path: configs/app-deployment
    - Technology: PowerShell scripts
    - Key Features: Chocolatey package installation, scheduled task creation, system reporting script

### Infrastructure Files

- `Vagrantfile`: Defines a Windows Server 2022 VM for development and testing. Migration considerations include creating equivalent Ansible-managed Vagrant configuration or converting to use Ansible as the provisioner.
- `vagrant-provision.ps1`: Main provisioning script that installs prerequisites and applies DSC configurations. Will be replaced by Ansible playbooks.
- `Makefile`: Contains convenience commands for Vagrant operations and verification. Can be adapted to run Ansible commands.

### Target Details

- **Operating System**: Windows Server 2022 Standard (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be for local development/testing

## Migration Approach

### Key Dependencies to Address

- **PowerShell DSC Modules**:
  - **ComputerManagementDsc**: Replace with Ansible win_timezone, win_user, and win_feature modules
  - **NetworkingDsc**: Replace with Ansible win_firewall_rule module
  - **PSDesiredStateConfiguration**: Core DSC module, replace with native Ansible Windows modules

- **Chocolatey**: Use Ansible win_chocolatey module to manage package installations

### Security Considerations

- **Local User Credentials**: The DSC configuration uses plaintext passwords in memory (with PSDscAllowPlainTextPassword). Migrate to Ansible vault for secure credential storage.
- **WinRM Communication**: The Vagrant setup uses plaintext WinRM. Ensure Ansible uses encrypted WinRM or SSH for Windows management in production.
- **Firewall Rules**: Maintain the same firewall configurations during migration to ensure security posture is preserved.

### Technical Challenges

- **DSC-specific constructs**: DSC uses declarative configuration with dependencies. Ensure Ansible tasks maintain the same dependency order.
- **Script conversion**: PowerShell scripts like Deploy-Apps.ps1 and ScheduledTask.ps1 need to be converted to idempotent Ansible tasks.
- **Windows-specific features**: Ensure all Windows features (IIS, registry settings, etc.) are properly implemented using Ansible's Windows modules.
- **Testing**: Create comprehensive testing to verify the migrated Ansible roles function identically to the original DSC configurations.

### Migration Order

1. **system-baseline** (moderate complexity, foundational)
   - Create role for timezone, user, features, firewall rules
   - Implement registry modifications

2. **iis-static-site** (low complexity, independent)
   - Create role for IIS installation and configuration
   - Implement static content deployment

3. **app-deployment** (moderate complexity)
   - Create role for Chocolatey package management
   - Implement scheduled task configuration

### Assumptions

1. The target environment will continue to be Windows Server 2022.
2. WinRM will remain the primary communication protocol for Ansible to manage Windows hosts.
3. The same verification methods in the Makefile will be used to validate the Ansible implementation.
4. No external dependencies or services beyond what's visible in the repository are required.
5. The password 'P@ssw0rd2024!' used in the DSC configuration is for demo purposes only and will be replaced with a secure method in Ansible.
6. The migration will maintain the same functionality and configuration as the original DSC implementation.
7. The Vagrant development environment will be preserved or enhanced during migration.