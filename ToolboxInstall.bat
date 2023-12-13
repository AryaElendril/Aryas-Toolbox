@echo off



REM Download installer-files.manifest
curl -L https://raw.githubusercontent.com/AryaElendril/Aryas-Toolbox/main/installer-files.manifest -o installer-files.manifest

for /f "delims=" %%i in (installer-files.manifest) do (
    set "filename=%%~ni%%~xi"
    set "destination=C:\CBS\Toolbox\!filename!"
    if not exist "C:\CBS\Toolbox\" (
        mkdir "C:\CBS\Toolbox\"
    )
    if exist "!destination!" ( 
        echo Updating !filename!
        curl -L %%i -o "!destination!"
    ) else (
        echo Downloading !filename!
        curl -L %%i -o "!destination!"
    )
)

REM Files downloaded and updated

REM Remove installer-files.manifest
del installer-files.manifest