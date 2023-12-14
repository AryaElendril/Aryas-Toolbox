<#
+---------------------------------------+
�         Arya's Tool Box               �
�      NorthStar Service Checker        �
+---------------------------------------+
#>

# Check if running as admin and prompt for elevation if needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb runAs -ArgumentList "-File", "`"$PSCommandPath`""    
    exit
}

function Start-ServiceWithUpdates {
    param($service)

    Write-Host "Stopping $($service.ServiceName)..."
    Stop-Service $service.ServiceName -Force
    Write-Host "Waiting for $($service.ServiceName) to stop..." 
    $service.WaitForStatus("Stopped")

    Write-Host "Starting $($service.ServiceName)..."
    Start-Service $service.ServiceName
    Write-Host "Waiting for $($service.ServiceName) to start..." 
    $service.WaitForStatus("Running")
}

function Write-ServiceStatus {
    param ($service)
    if ($service.Status -eq "Running") {
        Write-Host ("{0}: {1}" -f $service.ServiceName, $service.Status) -ForegroundColor Green
    }
    else {
        Write-Host ("{0}: {1}" -f $service.ServiceName, $service.Status) -ForegroundColor Red
    }
}

Write-Host "Searching for NorthStar services...`n"

$services = Get-Service | Where-Object {$_.Name -like "*NorthStar*"} 
Write-Host ""
foreach ($service in $services) {
    Write-ServiceStatus $service
}
Write-Host ""
$start = Read-Host "Start stopped services? (y/n)"
$start = $start.ToLower()

while ($start -ne "y" -and $start -ne "n") {
    Write-Host "Please enter 'y' or 'n'."
    $start = Read-Host "Start stopped services? (y/n)"
    $start = $start.ToLower()  
}

if ($start -eq "y") {
    $stoppedServices = $services | Where-Object {$_.Status -eq "Stopped"}
    if ($stoppedServices) {
        foreach ($service in $stoppedServices) {
            Start-ServiceWithUpdates $service
        }
    }
}
   
Write-Host ""
foreach ($service in $services) {
    Write-ServiceStatus $service
}
Write-Host ""
$restart = Read-Host "Restart running services? (y/n)" 
$restart = $restart.ToLower()

while ($restart -ne "y" -and $restart -ne "n") {
    Write-Host "Please enter 'y' or 'n'."
    $restart = Read-Host "Restart running services? (y/n)"
    $restart = $restart.ToLower()   
}

if ($restart -eq "y") {
    Write-Host "Restarting services...`n"
    $runningServices = $services | Where-Object {$_.Status -ne "Stopped"}
    if ($runningServices) {
        foreach ($service in $runningServices) {
            Restart-Service $service.ServiceName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue > $null

        }   
    }
}
Write-Host ""    
foreach ($service in $services) {
    Write-ServiceStatus $service  
}

Write-Host "Script complete!"
pause