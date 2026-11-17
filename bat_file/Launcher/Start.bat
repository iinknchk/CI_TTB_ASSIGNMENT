@echo off
setlocal enabledelayedexpansion
title TTB Automation Launcher
rem Opens the launcher page in the browser. Keep this window open while using the page.
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"
set "LAUNCHER=!_UROOT!\Resources\Launcher"
set PYTHONIOENCODING=utf-8
chcp 65001 >nul

set "PY="
if exist "!LAUNCHER!\launcher_python.txt" set /p PY=<"!LAUNCHER!\launcher_python.txt"
if defined PY if not exist "!PY!" set "PY="
if not defined PY for /f "usebackq delims=" %%P in (`call py -3 -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY for /f "usebackq delims=" %%P in (`call python -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY (
    echo Python not found. Run Setup.bat first.
    pause
    exit /b 1
)

"!PY!" "!LAUNCHER!\server.py"
if errorlevel 1 (
    echo.
    echo The launcher stopped with an error. Run Setup.bat again, or send this window
    echo to the automation team.
    pause
)
