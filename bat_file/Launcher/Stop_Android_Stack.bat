@echo off
setlocal enabledelayedexpansion
title Stop Android stack
rem Stops ONLY the emulator and appium that Start_Android_Stack.bat started.
rem A device or an appium you opened yourself is left alone.
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
set PYTHONIOENCODING=utf-8
if not defined ANDROID_HOME set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=!PATH!;!ANDROID_HOME!\platform-tools;!ANDROID_HOME!\emulator"
set "PY="
if exist "!_UROOT!\Resources\Launcher\launcher_python.txt" set /p PY=<"!_UROOT!\Resources\Launcher\launcher_python.txt"
if not defined PY set "PY=python"
"!PY!" "!_UROOT!\Resources\Library\android_tools.py" stop
pause
