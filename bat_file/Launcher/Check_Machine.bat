@echo off
setlocal enabledelayedexpansion
title TTB Automation Launcher - Check machine
rem Re-check packages, browser and Appium at any time (installs nothing).
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"
set "LAUNCHER=!_UROOT!\Resources\Launcher"
set PYTHONIOENCODING=utf-8
chcp 65001 >nul
set "PY="
if exist "!LAUNCHER!\launcher_python.txt" set /p PY=<"!LAUNCHER!\launcher_python.txt"
rem the saved path came from the machine where Setup.bat ran: check it exists here
if defined PY if not exist "!PY!" set "PY="
if not defined PY for /f "usebackq delims=" %%P in (`call py -3 -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY for /f "usebackq delims=" %%P in (`call python -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY (
    echo [ERROR] Python not found on this machine. Run bat_file\Launcher\Setup.bat first.
    pause
    exit /b 1
)
echo  Python: !PY!
"!PY!" "!LAUNCHER!\setup_check.py"
pause
