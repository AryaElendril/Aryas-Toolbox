@echo off

md C:\CBS\Toolbox 2>nul

powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/AryaElendril/Aryas-Toolbox/main/installer-files.manifest -OutFile C:\CBS\Toolbox\manifest.txt"
echo Downloaded manifest

for /f "delims=" %%i in (C:\CBS\Toolbox\manifest.txt) do (
  %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "Invoke-WebRequest %%i -OutFile C:\CBS\Toolbox\%%~nxi"
  
  if exist C:\CBS\Toolbox\%%~nxi (
    echo Updated %%~nxi
  ) else (
    echo Installed %%~nxi
  )
)
del C:\CBS\Toolbox\manifest.txt 
echo Done!
pause