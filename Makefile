.PHONY: up down destroy provision verify x2a-init x2a-analyze

up:
	vagrant up

down:
	vagrant halt

destroy:
	vagrant destroy -f

provision:
	vagrant provision

verify:
	@echo "--- IIS Feature ---"
	vagrant winrm -c "Get-WindowsFeature Web-Server | Format-Table Name, InstallState"
	@echo ""
	@echo "--- IIS Page ---"
	curl -s http://localhost:8080 | head -5
	@echo ""
	@echo "--- Timezone ---"
	vagrant winrm -c "Get-TimeZone | Select-Object Id"
	@echo ""
	@echo "--- Demo User ---"
	vagrant winrm -c "Get-LocalUser -Name x2a-demo | Format-Table Name, Enabled"
	@echo ""
	@echo "--- Telnet Client ---"
	vagrant winrm -c "Get-WindowsFeature Telnet-Client | Format-Table Name, InstallState"
	@echo ""
	@echo "--- Firewall Rules ---"
	vagrant winrm -c "Get-NetFirewallRule -Name 'X2A-*' | Format-Table DisplayName, Enabled"
	@echo ""
	@echo "--- Chocolatey Packages ---"
	vagrant winrm -c "choco list"
	@echo ""
	@echo "--- Scheduled Task ---"
	vagrant winrm -c "Get-ScheduledTask -TaskName X2A-DailyReport | Format-Table TaskName, State"
