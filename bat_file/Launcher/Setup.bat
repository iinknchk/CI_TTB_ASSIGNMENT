@echo off
setlocal enabledelayedexpansion
title CI_TTB_ASSIGNMENT - Setup
rem ============================================================================
rem  Setup.bat : prepare this machine to run the test suites.
rem    1. find Python 3.10+ (installs it with winget when it is missing)
rem    2. pip install -r Resources\Launcher\requirements.txt
rem    3. rfbrowser init - the node side of Browser library (Playwright)
rem    4. check the machine
rem    5. put "TTB Automation Launcher" on the desktop
rem  Safe to run again at any time - every step is skipped when already done.
rem
rem  Needs an internet connection.
rem  For question 4 (mobile) run Setup_Android.bat afterwards.
rem ============================================================================
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"
set "LAUNCHER=!_UROOT!\Resources\Launcher"
set "PY_FILE=!LAUNCHER!\launcher_python.txt"
set PIP_DISABLE_PIP_VERSION_CHECK=1
set PYTHONIOENCODING=utf-8
chcp 65001 >nul

echo ==================================================================
echo  CI_TTB_ASSIGNMENT - SETUP
echo  Project : !_UROOT!
echo ==================================================================
echo.

rem ---------------------------------------------------------------- 1. Python
echo [1/5] Looking for Python 3.10 or newer...
set "PY="
call :try_python py -3
if not defined PY call :try_python python
if not defined PY (
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if exist "%%D\python.exe" call :try_python "%%D\python.exe"
)
if not defined PY (
    where winget >nul 2>&1
    if errorlevel 1 (
        echo.
        echo  [FAIL] Python 3.10+ not found and winget is not available.
        echo         Install Python from https://www.python.org/downloads/windows/
        echo         and tick "Add python.exe to PATH", then run Setup.bat again.
        echo.
        pause
        exit /b 1
    )
    echo        Not found - installing with winget...
    winget install -e --id Python.Python.3.12 --scope user --accept-source-agreements --accept-package-agreements
    rem winget updates PATH only for NEW windows, so look in the install folder
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if exist "%%D\python.exe" call :try_python "%%D\python.exe"
)
if not defined PY (
    echo.
    echo  [WARN] Python was installed but is not visible in this window.
    echo         Close this window, open a new one and run Setup.bat again.
    echo.
    pause
    exit /b 1
)
echo        Using !PY!
> "!PY_FILE!" echo !PY!

rem ---------------------------------------------------------------- 2. packages
echo.
echo [2/5] Installing pip packages...
"!PY!" -c "import robot, RequestsLibrary, Browser, AppiumLibrary, requests, openpyxl, yaml" >nul 2>&1
if not errorlevel 1 (
    echo        All packages are already installed - skip.
    goto :node
)
"!PY!" -m pip install --disable-pip-version-check -r "!LAUNCHER!\requirements.txt"
if errorlevel 1 (
    echo        Retrying for this user only ^(--user^)...
    "!PY!" -m pip install --user --disable-pip-version-check -r "!LAUNCHER!\requirements.txt"
)
if errorlevel 1 (
    echo.
    echo  [WARN] pip could not install everything. Check the internet connection
    echo         ^(or the proxy^) and run Setup.bat again. The check below shows
    echo         exactly which packages are still missing.
)

:node
rem ---------------------------------------------------------------- 3. rfbrowser
echo.
echo [3/5] Installing the node side of Browser library ^(Playwright^)...
echo        Downloads chromium the first time ^(~150 MB^).
"!PY!" -m Browser.entry init
if errorlevel 1 (
    echo  [WARN] rfbrowser init failed - question 2 ^(web^) cannot run until it works.
    echo         With a chromium already on this machine you can instead pass
    echo         -v BROWSER_EXECUTABLE:^<path to chrome.exe^> when running robot.
)

rem ---------------------------------------------------------------- 4. check
echo.
echo [4/5] Checking this machine...
"!PY!" "!LAUNCHER!\setup_check.py"
set "CHECK_RC=!errorlevel!"

rem ---------------------------------------------------------------- 5. shortcut
echo.
echo [5/5] Creating the desktop shortcut...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$d=[Environment]::GetFolderPath('Desktop'); $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d 'TTB Automation Launcher.lnk')); $s.TargetPath='!HERE!Start.bat'; $s.WorkingDirectory='!HERE!'; $s.IconLocation='%SystemRoot%\System32\shell32.dll,137'; $s.Save()" >nul 2>&1
if errorlevel 1 (echo        Could not create the shortcut. Open bat_file\Launcher\Start.bat directly.) else (echo        Desktop: "TTB Automation Launcher")

echo.
echo ==================================================================
if "!CHECK_RC!"=="0" (
    echo  SETUP DONE - ready to use. Double click "TTB Automation Launcher"
) else (
    echo  SETUP DONE WITH WARNINGS - see the [FAIL] lines above.
    echo  Full report: Results\Launcher\setup_check_%COMPUTERNAME%.txt
)
echo  For question 4 ^(mobile^) run bat_file\Launcher\Setup_Android.bat next.
echo ==================================================================
pause
exit /b 0

rem ---------------------------------------------------------------- helpers
:try_python
if defined PY exit /b 0
set "CAND="
for /f "usebackq delims=" %%P in (`call %* -c "import sys;v=sys.version_info[:2];max(v,(3,10))==v and print(sys.executable)" 2^>nul`) do set "CAND=%%P"
if defined CAND if exist "!CAND!" set "PY=!CAND!"
exit /b 0
