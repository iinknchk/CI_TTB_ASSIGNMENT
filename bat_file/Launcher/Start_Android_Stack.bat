@echo off
setlocal enabledelayedexpansion
title Start Android stack (emulator + appium)
rem Starts the emulator and the Appium server, then waits until BOTH are ready.
rem Already running = nothing happens. Usage: Start_Android_Stack.bat [avd name]
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"
set PYTHONIOENCODING=utf-8
chcp 65001 >nul
if not defined ANDROID_HOME set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=!PATH!;!ANDROID_HOME!\platform-tools;!ANDROID_HOME!\emulator"

set "AVD=%~1"
if not defined AVD set "AVD=ttb_test"

set "PY="
if exist "!_UROOT!\Resources\Launcher\launcher_python.txt" set /p PY=<"!_UROOT!\Resources\Launcher\launcher_python.txt"
if defined PY if not exist "!PY!" set "PY="
if not defined PY for /f "usebackq delims=" %%P in (`call py -3 -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY set "PY=python"

"!PY!" "!_UROOT!\Resources\Library\android_tools.py" ensure --avd "!AVD!"
exit /b !errorlevel!
