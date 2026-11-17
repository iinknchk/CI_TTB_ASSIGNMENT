@echo off
setlocal enabledelayedexpansion
title CI_TTB_ASSIGNMENT - Setup
rem ============================================================================
rem  Setup.bat : prepare a NEW machine to run this project.
rem    1. find Python 3.10+ (or install it from .\installer\python-3*.exe)
rem    2. install the pip packages (from .\wheelhouse when present = no internet)
rem    3. rfbrowser init - the node side of Browser library (Playwright)
rem    4. check the machine (packages, browser, Appium, network)
rem    5. put "TTB Automation Launcher" on the desktop
rem  Safe to run again at any time.
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
    set "INSTALLER="
    for %%F in ("!HERE!installer\python-3*.exe") do set "INSTALLER=%%F"
    if not defined INSTALLER (
        echo.
        echo  [FAIL] Python not found and no installer in:
        echo         !HERE!installer\
        echo  Put python-3.12.x-amd64.exe ^(from python.org^) there and run Setup.bat again,
        echo  or install Python yourself and tick "Add python.exe to PATH".
        echo.
        pause
        exit /b 1
    )
    echo        Installing !INSTALLER! for this user ^(no admin needed^)...
    "!INSTALLER!" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_doc=0
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if exist "%%D\python.exe" call :try_python "%%D\python.exe"
)
if not defined PY (
    echo  [FAIL] The Python install did not work. Ask IT for Python 3.12 for this user.
    pause
    exit /b 1
)
echo        Using !PY!
> "!PY_FILE!" echo !PY!

rem ---------------------------------------------------------------- 2. pip packages
echo.
echo [2/5] Installing pip packages...
"!PY!" -c "import robot, RequestsLibrary, Browser, AppiumLibrary, requests, openpyxl, yaml" >nul 2>&1
if not errorlevel 1 (
    echo        All packages are already installed - skip.
    goto :node
)
set "REQ=!LAUNCHER!\requirements.txt"
set "PIP_SRC="
if exist "!HERE!wheelhouse\*.whl" (
    set "PIP_SRC=--no-index --find-links "!HERE!wheelhouse""
    echo        Offline install from !HERE!wheelhouse
)
rem short timeout: a machine with no internet should fail fast, not hang
set "PIP_OPT=--timeout 20 --retries 1 --disable-pip-version-check"
"!PY!" -m pip install !PIP_OPT! !PIP_SRC! -r "!REQ!"
if errorlevel 1 (
    echo        Retrying for this user only ^(--user^)...
    "!PY!" -m pip install --user !PIP_OPT! !PIP_SRC! -r "!REQ!"
)
if errorlevel 1 (
    echo.
    echo  [WARN] pip could not install everything ^(no internet / proxy?^).
    echo         Fix: on a machine WITH internet run Make_Wheelhouse.bat, copy the
    echo         wheelhouse folder into !HERE! and run Setup.bat again.
)

:node
rem ---------------------------------------------------------------- 3. rfbrowser
echo.
echo [3/5] Installing the node side of Browser library ^(Playwright^)...
echo        This downloads chromium the first time ^(~150 MB^) and needs internet.
"!PY!" -m Browser.entry init
if errorlevel 1 (
    echo  [WARN] rfbrowser init failed. Q2 ^(web^) cannot run until it succeeds.
    echo         With a chromium already on this machine you can instead run:
    echo         Run_Q2_Web_Login.bat after setting BROWSER_EXECUTABLE in
    echo         Resources\Settings\Settings.robot
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
