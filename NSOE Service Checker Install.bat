@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM Set debug mode
set DEBUG=1

REM Check if the script is already installed
if not "%DEBUG%"=="1" (
    if exist "%USERPROFILE%\Documents\NSOE Service Checker.ps1" (
        echo Script is already installed.
        goto :end
    )
)

if not exist "C:/CBS" (
    mkdir "C:/CBS"
)  else (
    echo CBS folder already exists.
)

REM
curl -o "C:/CBS/nose_service_checker.ps1" -L "https://raw.githubusercontent.com/AryaElendril/Aryas-Toolbox/main/NSOE%20Service%20Checker.ps1"

REM Check if the download was successful
if exist "%USERPROFILE%\Documents\NSOE Service Checker.ps1" (
    echo Script installed successfully.
) else (
    echo Failed to install the script.
)

:end
pause