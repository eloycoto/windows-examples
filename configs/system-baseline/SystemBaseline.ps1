Configuration SystemBaseline {
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]$DemoUserCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName NetworkingDsc

    Node $AllNodes.NodeName {

        # -- Timezone --------------------------------------------------------

        TimeZone SetTimezone {
            IsSingleInstance = 'Yes'
            TimeZone         = $Node.Timezone
        }

        # -- Local user ------------------------------------------------------

        User DemoUser {
            UserName                 = $Node.DemoUsername
            Ensure                   = 'Present'
            FullName                 = 'x2ansible Demo User'
            Description              = 'Demo account created by SystemBaseline DSC'
            Password                 = $DemoUserCredential
            PasswordNeverExpires     = $true
            PasswordChangeNotAllowed = $true
        }

        # -- Optional feature ------------------------------------------------

        WindowsFeature TelnetClient {
            Name   = 'Telnet-Client'
            Ensure = 'Present'
        }

        # -- Firewall rules --------------------------------------------------

        Firewall AllowHTTP {
            Name        = 'X2A-Allow-HTTP'
            DisplayName = 'Allow HTTP Inbound'
            Ensure      = 'Present'
            Enabled     = 'True'
            Direction   = 'Inbound'
            Protocol    = 'TCP'
            LocalPort   = '80'
            Action      = 'Allow'
            Profile     = 'Any'
        }

        Firewall AllowHTTPS {
            Name        = 'X2A-Allow-HTTPS'
            DisplayName = 'Allow HTTPS Inbound'
            Ensure      = 'Present'
            Enabled     = 'True'
            Direction   = 'Inbound'
            Protocol    = 'TCP'
            LocalPort   = '443'
            Action      = 'Allow'
            Profile     = 'Any'
        }

        Firewall AllowRDP {
            Name        = 'X2A-Allow-RDP'
            DisplayName = 'Allow RDP Inbound'
            Ensure      = 'Present'
            Enabled     = 'True'
            Direction   = 'Inbound'
            Protocol    = 'TCP'
            LocalPort   = '3389'
            Action      = 'Allow'
            Profile     = 'Any'
        }

        # -- Disable IE Enhanced Security ------------------------------------

        Registry DisableIEESCAdmin {
            Key       = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
            ValueName = 'IsInstalled'
            ValueType = 'DWord'
            ValueData = '0'
            Ensure    = 'Present'
        }

        Registry DisableIEESCUser {
            Key       = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
            ValueName = 'IsInstalled'
            ValueType = 'DWord'
            ValueData = '0'
            Ensure    = 'Present'
        }
    }
}
