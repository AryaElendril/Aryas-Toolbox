@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM Set debug mode
set DEBUG=0

set "filePath=C:\CBS\Scripts\NSOEServiceChecker.ps1"

REM Check if the script is already installed
if not "%DEBUG%"=="1" (
    if exist "%filePath%" (
        echo Script is already installed. Updating the script...
        goto :update_script
    )
)

if not exist "C:/CBS" (
    mkdir "C:/CBS"
)

if not exist "C:/CBS/Scripts" (
    mkdir "C:/CBS/Scripts"
) else (
    echo CBS folder already exists.
)

REM Download the script file
curl -o "%filePath%" -L "https://raw.githubusercontent.com/AryaElendril/Aryas-Toolbox/main/NSOEServiceChecker.ps1"

REM Check if the download was successful
if exist "%filePath%" (
    echo Script installed successfully.
) else (
    echo Failed to install the script.
)

:end
pause

:update_script
REM Download the updated script file
curl -o "%filePath%" -L "https://raw.githubusercontent.com/AryaElendril/Aryas-Toolbox/main/NSOEServiceChecker.ps1"

REM Check if the download was successful
if exist "%filePath%" (
    echo Script updated successfully.
) else (
    echo Failed to update the script.
)
