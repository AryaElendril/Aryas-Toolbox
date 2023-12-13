@echo off

:: Verify admin rights
openfiles >nul 2>&1
if %errorlevel% neq 0 (
   echo This script requires administrator rights. Please re-run as admin.
   pause
   exit
)

:: Create folder if needed
if not exist "C:\CBS\Scripts" md "C:\CBS\Scripts"

:: Download PS script
curl "https://raw.githubusercontent.com/AryaElendril/Aryas-Toolbox/main/NSOEServiceChecker.ps1" -o "C:\CBS\Scripts\NSOE-Service-Checker.ps1"
if %errorlevel% neq 0 (
   echo Failed to download PowerShell script. 
   pause 
   exit /b 1
)

:: Set execution policy
powershell -command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
if %errorlevel% neq 0 (
   echo Failed to set execution policy.
   pause
   exit /b 1 
)

:: Run script
powershell -File "C:\CBS\Scripts\NSOE-Service-Checker.ps1"
if %errorlevel% neq 0 (
   echo PowerShell script failed.
   pause
   exit /b 1
)

exit /b 0