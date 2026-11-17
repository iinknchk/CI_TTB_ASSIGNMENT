@echo off
setlocal enabledelayedexpansion
title Q4 - Minimal-Todo mobile (Appium)
rem ============================================================================
rem  Q4 - Minimal-Todo mobile (Appium)
rem  Double click and it does everything:
rem    1. starts the emulator if no device is up, and waits for it to finish booting
rem    2. starts the Appium server if it is not answering, and waits for it
rem    3. runs Testcase\Q4_Mobile_Todo.robot
rem    4. writes the report, and stops whatever IT started (a device you opened
rem       yourself keeps running)
rem
rem  Usage: Run_Q4_Mobile_Todo.bat [ENV] [avd name] [tag]
rem    Run_Q4_Mobile_Todo.bat                  everything, AVD ttb_test
rem    Run_Q4_Mobile_Todo.bat PUBLIC ttb_test smoke     only the smoke cases
rem
rem  First time on a new machine: run bat_file\Launcher\Setup_Android.bat
rem  Set TTB_KEEP_EMULATOR=1 to leave the emulator running when it is done.
rem ============================================================================
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"

set "ENV=%~1"
if not defined ENV set "ENV=PUBLIC"
set "ROBOT_ENV=!ENV!"
set "AVD=%~2"
if not defined AVD set "AVD=ttb_test"
set "TAG=%~3"

set PYTHONIOENCODING=utf-8
chcp 65001 >nul
if not defined ANDROID_HOME set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=!PATH!;!ANDROID_HOME!\platform-tools;!ANDROID_HOME!\emulator"

rem ---------------------------------------------------------------- python
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

set "ANDROID_TOOLS=!_UROOT!\Resources\Library\android_tools.py"

echo ==================================================================
echo  Q4 - Minimal-Todo mobile (Appium)
echo  ENV !ENV!   AVD !AVD!
echo ==================================================================
echo.

rem ---------------------------------------------------------------- the apk
if not exist "!_UROOT!\Upload_file\Minimal-Todo.apk" (
    echo  [ERROR] Upload_file\Minimal-Todo.apk is missing.
    echo          Build it from https://github.com/avjinder/Minimal-Todo ^(needs JDK 8^):
    echo              gradlew assembleDebug
    echo          then copy app\build\outputs\apk\debug\app-debug.apk to
    echo              !_UROOT!\Upload_file\Minimal-Todo.apk
    echo.
    pause
    exit /b 1
)

rem ---------------------------------------------------------------- emulator + appium
echo [1/3] Starting the emulator and appium if they are not up yet...
"!PY!" "!ANDROID_TOOLS!" ensure --avd "!AVD!"
if errorlevel 1 (
    echo.
    echo  [ERROR] The Android stack is not ready - the lines above say what is missing.
    echo          On a new machine run: bat_file\Launcher\Setup_Android.bat
    echo.
    pause
    exit /b 1
)

rem ---------------------------------------------------------------- run
echo.
echo [2/3] Running the tests...
set "curr_time=!time: =0!"
set "time_stamp=!curr_time:~0,2!!curr_time:~3,2!!curr_time:~6,2!"
set "RESULT=!_UROOT!\Results\Q4_Mobile_!time_stamp!"
if not exist "!RESULT!" mkdir "!RESULT!"

set "TAG_OPT="
if defined TAG set "TAG_OPT=--include !TAG!"

"!PY!" -m robot -v ENV:!ENV! !TAG_OPT! -d "!RESULT!" -N "Q4_Mobile" "!_UROOT!\Testcase\Q4_Mobile_Todo.robot"
set "RC=!errorlevel!"

rem ---------------------------------------------------------------- report + cleanup
echo.
echo [3/3] Report...
"!PY!" "!_UROOT!\Resources\Launcher\result_parser.py" "!RESULT!\output.xml"

if defined TTB_KEEP_EMULATOR (
    echo.
    echo  Emulator left running ^(TTB_KEEP_EMULATOR is set^).
    echo  Stop it later with bat_file\Launcher\Stop_Android_Stack.bat
) else (
    echo.
    echo  Stopping what this run started...
    "!PY!" "!ANDROID_TOOLS!" stop
)

echo.
if "!RC!"=="0" (echo  [PASS] every test passed) else (echo  [FAIL] open "!RESULT!\report.html")
echo.
pause
exit /b !RC!
