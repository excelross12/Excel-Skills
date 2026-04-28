@echo off
REM install.bat — Double-click loader for Windows users
REM Routes to load.ps1 with PowerShell

setlocal
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%load.ps1" %*
endlocal
