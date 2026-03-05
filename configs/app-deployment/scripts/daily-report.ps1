# daily-report.ps1
# Generates a basic system report and writes it to C:\x2a-reports.

$reportDir  = 'C:\x2a-reports'
$timestamp  = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$reportFile = Join-Path $reportDir "report_$timestamp.txt"

$report = @"
===================================
  x2ansible Daily System Report
  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
===================================

--- Hostname ---
$env:COMPUTERNAME

--- OS Version ---
$((Get-CimInstance Win32_OperatingSystem).Caption)

--- Uptime ---
$((Get-CimInstance Win32_OperatingSystem).LastBootUpTime)

--- CPU Usage ---
$((Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average)% average

--- Memory ---
Total: $([math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 1)) GB
Free:  $([math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)) GB

--- Disk Space (C:) ---
$( $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
   "Total: $([math]::Round($disk.Size / 1GB, 1)) GB"
   "Free:  $([math]::Round($disk.FreeSpace / 1GB, 1)) GB"
)

--- Running Services ---
$(Get-Service | Where-Object { $_.Status -eq 'Running' } | Measure-Object | Select-Object -ExpandProperty Count) services running

--- Installed Chocolatey Packages ---
$(if (Get-Command choco -ErrorAction SilentlyContinue) { choco list --limit-output } else { 'Chocolatey not installed' })

===================================
  End of Report
===================================
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "Report written to $reportFile"
