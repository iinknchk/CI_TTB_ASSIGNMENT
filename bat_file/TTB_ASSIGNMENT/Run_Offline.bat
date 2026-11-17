@echo off
setlocal enabledelayedexpansion
title Q1 + Q6 only - no network needed
rem ============================================================================
rem  Q1 + Q6 only - no network needed
rem  Usage: Run_Offline.bat [ENV]        ENV defaults to PUBLIC
rem ============================================================================
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"

set "ENV=%~1"
if not defined ENV set "ENV=PUBLIC"
set "ROBOT_ENV=!ENV!"

set PYTHONIOENCODING=utf-8
chcp 65001 >nul

set "PY="
if exist "!_UROOT!\Resources\Launcher\launcher_python.txt" set /p PY=<"!_UROOT!\Resources\Launcher\launcher_python.txt"
if defined PY if not exist "!PY!" set "PY="
if not defined PY for /f "usebackq delims=" %%P in (`call py -3 -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY for /f "usebackq delims=" %%P in (`call python -c "import sys;print(sys.executable)" 2^>nul`) do set "PY=%%P"
if not defined PY (
    echo [ERROR] Python not found. Run bat_file\Launcher\Setup.bat first.
    pause
    exit /b 1
)

set "curr_time=!time: =0!"
set "time_stamp=!curr_time:~0,2!!curr_time:~3,2!!curr_time:~6,2!"
set "RESULT=!_UROOT!\Results\Offline_!time_stamp!"
if not exist "!RESULT!" mkdir "!RESULT!"

echo ==================================================================
echo  Q1 + Q6 only - no network needed
echo  ENV     : !ENV!
echo  Results : !RESULT!
echo ==================================================================

"!PY!" -m robot -v ENV:!ENV! --include offline -d "!RESULT!" -N "Offline" "!_UROOT!\Testcase"
set "RC=!errorlevel!"

echo.
if "!RC!"=="0" (echo  [PASS] every test passed) else (echo  [FAIL] !RC! test^(s^) failed - open "!RESULT!\report.html")
"!PY!" "!_UROOT!\Resources\Launcher\result_parser.py" "!RESULT!\output.xml"
echo.
pause
exit /b !RC!
