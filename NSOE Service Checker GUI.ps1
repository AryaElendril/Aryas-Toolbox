# Check if running as admin and prompt for elevation if needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb runAs -ArgumentList "-File", "`"$PSCommandPath`""    
    exit
}

Add-Type -AssemblyName System.Windows.Forms

$script:jobs = New-Object System.Collections.ArrayList

$form = New-Object Windows.Forms.Form
$form.Text = "NorthStar Service Checker"
$form.Size = New-Object Drawing.Size @(800, 600)  
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false   

$titleLabel = New-Object Windows.Forms.Label
$titleLabel.Text = "NorthStar Service Checker"
$titleLabel.Font = New-Object Drawing.Font -ArgumentList @(
    $titleLabel.Font.FontFamily,
    14,
    [Drawing.FontStyle]::Bold
)

$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object Drawing.Point(280, 20)

$form.Controls.Add($titleLabel)

$listView = New-Object Windows.Forms.ListView    
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.Font = New-Object Drawing.Font -ArgumentList @(
    $listView.Font.FontFamily,
    12,
    [Drawing.FontStyle]::Regular  
)

$listView.Columns.Add("Service", 2) | Out-Null      
$listView.Columns.Add("Status", 1) | Out-Null    
$listView.Columns[0].Width = 400  
$listView.Columns[1].Width = 400

$listView.Left = 50
$listView.Top = 80 
$listView.Width = $form.ClientSize.Width - 100   
$listView.Height = $form.ClientSize.Height - 150   

$services = Get-Service | Where-Object {$_.Name -like "*NorthStar*"}   

foreach ($service in $services) {

    $listViewItem = New-Object Windows.Forms.ListViewItem($service.ServiceName)
    $listViewItem.UseItemStyleForSubItems = $false

    if ($service.Status -eq "Running") {

        $listViewItem.SubItems.Add("Running") | Out-Null
        $listViewItem.SubItems[1].BackColor = [Drawing.Color]::LightGreen  

    } else {

        $listViewItem.SubItems.Add("Stopped") | Out-Null  
        $listViewItem.SubItems[1].BackColor = [Drawing.Color]::Salmon  

    }

    $listView.Items.Add($listViewItem) | Out-Null   

}

$panel = New-Object Windows.Forms.Panel       
$panel.Dock = "Bottom"
$panel.Height = 70  
$panel.Padding = New-Object System.Windows.Forms.Padding(10)   

$startButton = New-Object Windows.Forms.Button  
$startButton.Text = "Start All Services"  

$restartButton = New-Object Windows.Forms.Button         
$restartButton.Text = "Restart All Services"

$panel.Controls.Add($startButton)    
$panel.Controls.Add($restartButton)  

$startButton.Location = New-Object System.Drawing.Point(10, 10)   
$startButton.Size = New-Object System.Drawing.Size(150, 50)

$restartButton.Location = New-Object Drawing.Point(620, 10)   
$restartButton.Size = New-Object System.Drawing.Size(150, 50)   

$startButton.Add_Click({
    $startButton.Enabled = $false
    $restartButton.Enabled = $false

    $stoppedServices = $services | Where-Object { $_.Status -eq "Stopped" }

    foreach ($service in $stoppedServices) {
        $listViewItem = $listView.Items | Where-Object { $_.Text -eq $service.ServiceName }

        $listViewItem.SubItems[1].Text = "Starting..."
        $listViewItem.SubItems[1].BackColor = [Drawing.Color]::Yellow

        $job = Start-Job -ScriptBlock {
            Param($serviceName)
            Start-Service -Name $serviceName -ErrorAction SilentlyContinue > $null
            Get-Service -Name $serviceName -ErrorAction SilentlyContinue > $null
        } -ArgumentList $service.Name

        $job | Wait-Job

        $status = Receive-Job -Job $job
        Remove-Job -Job $job

        $listViewItem = $listView.Items | Where-Object { $_.Text -eq $status.ServiceName }

        if ($status.Status -eq "Running") {
            $listViewItem.SubItems[1].Text = "Running"
            $listViewItem.SubItems[1].BackColor = [Drawing.Color]::LightGreen
        }
    }

    $startButton.Enabled = $true
    $restartButton.Enabled = $true

    # Refresh the ListView to update the UI
    $listView.Refresh()
})



$restartButton.Add_Click({
    $script:jobs.Clear()

    $startButton.Enabled = $false
    $restartButton.Enabled = $false

    $services = Get-Service | Where-Object { $_.Name -like "*NorthStar*" }

    foreach ($service in $services | Where-Object { $_.Status -ne "Stopped" }) {
        $listViewItem = $listView.Items |
            Where-Object {$_.Text -eq $service.ServiceName}

        $listViewItem.SubItems[1].Text = "Restarting..."
        $listViewItem.SubItems[1].BackColor = [Drawing.Color]::Yellow

        $job = Start-Job -ScriptBlock {
            Param($serviceName)
            $service = Restart-Service -Name $serviceName -ErrorAction SilentlyContinue > $null
            $status = Get-Service -Name $serviceName -ErrorAction SilentlyContinue > $null
            [PSCustomObject]@{
                Service = $status
            }
        } -ArgumentList $service.Name

        $script:jobs.Add($job) | Out-Null
    }

    $script:jobs | ForEach-Object {
        $output = Receive-Job -Job $_ -Wait
        $status = $output.Service

        $listViewItem = $listView.Items | Where-Object {$_.Text -eq $status.ServiceName}

        if ($status.Status -eq "Running") {
            $listViewItem.SubItems[1].Text = "Running"
            $listViewItem.SubItems[1].BackColor = [Drawing.Color]::LightGreen
        }

        Remove-Job -Job $_
    }

    $script:jobs.Clear()

    $startButton.Enabled = $true
    $restartButton.Enabled = $true

    # Refresh the ListView to update the UI
    $listView.Refresh()
})


function Refresh-Services {
    $script:jobs.Clear()

    $startButton.Enabled = $false
    $restartButton.Enabled = $false
    $refreshButton.Enabled = $false

    $services = Get-Service | Where-Object {$_.Name -like "*NorthStar*"}

    foreach ($service in $services) {
        $listViewItem = $listView.Items | Where-Object {$_.Text -eq $service.ServiceName}

        $listViewItem.SubItems[1].Text = "Refreshing..."
        $listViewItem.SubItems[1].BackColor = [Drawing.Color]::Yellow

        $job = Start-Job -ScriptBlock {
            Param($serviceName)
            $status = Get-Service -Name $serviceName
            [PSCustomObject]@{
                Service = $status
            }
        } -ArgumentList $service.Name

        $script:jobs.Add($job) | Out-Null
    }

    $script:jobs | ForEach-Object {
        $output = Receive-Job -Job $_ -Wait
        $status = $output.Service

        $listViewItem = $listView.Items | Where-Object {$_.Text -eq $status.ServiceName}

        if ($status.Status -eq "Running") {
            $listViewItem.SubItems[1].Text = "Running"
            $listViewItem.SubItems[1].BackColor = [Drawing.Color]::LightGreen
        } elseif ($status.Status -eq "Stopped") {
            $listViewItem.SubItems[1].Text = "Stopped"
            $listViewItem.SubItems[1].BackColor = [Drawing.Color]::Salmon
        }

        Remove-Job -Job $_
    }

    $script:jobs.Clear()

    $startButton.Enabled = $true
    $restartButton.Enabled = $true
    $refreshButton.Enabled = $true
}

# Add a refresh button
$refreshButton = New-Object Windows.Forms.Button
$refreshButton.Text = "Refresh Status"
$refreshButton.Location = New-Object Drawing.Point(325, 500)
$refreshButton.Size = New-Object System.Drawing.Size(150, 50)
$form.Controls.Add($refreshButton)

# Wire up the click event for the refresh button
$refreshButton.Add_Click({
    Refresh-Services
})


$form.Controls.Add($listView)          
$form.Controls.Add($panel)      

$form.ShowDialog() | Out-Null