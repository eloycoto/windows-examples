Configuration IISStaticSite {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node 'localhost' {

        WindowsFeature WebServer {
            Name   = 'Web-Server'
            Ensure = 'Present'
        }

        WindowsFeature WebMgmtConsole {
            Name      = 'Web-Mgmt-Console'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]WebServer'
        }

        WindowsFeature WebScriptingTools {
            Name      = 'Web-Scripting-Tools'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]WebServer'
        }

        Service W3SVC {
            Name        = 'W3SVC'
            State       = 'Running'
            StartupType = 'Automatic'
            DependsOn   = '[WindowsFeature]WebServer'
        }

        File WebsiteDirectory {
            DestinationPath = 'C:\inetpub\x2a-site'
            Type            = 'Directory'
            Ensure          = 'Present'
        }

        File IndexPage {
            DestinationPath = 'C:\inetpub\x2a-site\index.html'
            SourcePath      = 'C:\dsc-configs\configs\iis-static-site\files\index.html'
            Type            = 'File'
            Ensure          = 'Present'
            Force           = $true
            DependsOn       = '[File]WebsiteDirectory'
        }

        Script DefaultSitePhysicalPath {
            GetScript = {
                $path = (Get-WebSite -Name 'Default Web Site').PhysicalPath
                @{ Result = $path }
            }
            TestScript = {
                $path = (Get-WebSite -Name 'Default Web Site').PhysicalPath
                $path -eq 'C:\inetpub\x2a-site'
            }
            SetScript = {
                Set-ItemProperty 'IIS:\Sites\Default Web Site' `
                    -Name physicalPath -Value 'C:\inetpub\x2a-site'
            }
            DependsOn = @('[WindowsFeature]WebScriptingTools', '[File]IndexPage')
        }
    }
}
