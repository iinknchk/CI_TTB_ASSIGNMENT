@echo off
setlocal enabledelayedexpansion
title Q2 - the-internet login (Browser / Playwright)
rem ============================================================================
rem  Q2 - the-internet login (Browser / Playwright)
rem  Usage: Run_Q2_Web_Login.bat [ENV]        ENV defaults to PUBLIC
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
set "RESULT=!_UROOT!\Results\Q2_Web_Login_!time_stamp!"
if not exist "!RESULT!" mkdir "!RESULT!"

echo ==================================================================
echo  Q2 - the-internet login (Browser / Playwright)
echo  ENV     : !ENV!
echo  Results : !RESULT!
echo ==================================================================

"!PY!" -m robot -v ENV:!ENV!  -d "!RESULT!" -N "Q2_Web_Login" "!_UROOT!\Testcase\Q2_Web_Login.robot"
set "RC=!errorlevel!"

echo.
if "!RC!"=="0" (echo  [PASS] every test passed) else (echo  [FAIL] !RC! test^(s^) failed - open "!RESULT!\report.html")
"!PY!" "!_UROOT!\Resources\Launcher\result_parser.py" "!RESULT!\output.xml"
echo.
pause
exit /b !RC!
