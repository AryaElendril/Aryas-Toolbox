<#
+---------------------------------------+
�         Arya's Tool Box               �
�      NorthStar Service Checker        �
+---------------------------------------+
#>

# Set source folder paths 
$sourceFolder1 = "C:\Program Files\Custom Business Solutions\NorthStar Order Entry\Database"
$sourceFolder2 = "C:\Program Files\Custom Business Solutions\NorthStar Order Entry\Log"

# Set output path 
$outputPath = "C:\CBS\GatheredOutput"

# Create temp and output paths if needed
If(!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Force -Path $outputPath  | Out-Null
}

$tempPath = Join-Path $outputPath "Temp"
If(!(Test-Path $tempPath)) {
    New-Item -ItemType Directory -Force -Path $tempPath  | Out-Null
}

# Copy source folders into temp folder
Copy-Item -Path $sourceFolder1, $sourceFolder2 -Destination $tempPath -Recurse

# Zip temp folder contents
$timestamp = Get-Date -Format "MM-dd-yyy_HH-mm"
$zipFile = Join-Path $outputPath "GatheredLogs_$timestamp.zip" 
Compress-Archive -Path "$tempPath/*" -DestinationPath $zipFile

# Remove temp folder
Remove-Item -Path $tempPath -Recurse -Force