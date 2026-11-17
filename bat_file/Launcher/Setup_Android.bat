@echo off
setlocal enabledelayedexpansion
title CI_TTB_ASSIGNMENT - Setup Android (for Q4 mobile)
rem ============================================================================
rem  Setup_Android.bat : prepare this machine to run the Q4 mobile suite.
rem    1. Node.js          (winget)
rem    2. appium + the uiautomator2 driver   (npm -g)
rem    3. Android command line tools + platform-tools + emulator + a system image
rem    4. create the AVD "ttb_test"
rem    5. show the result of android_tools.py status
rem  Safe to run again: every step is skipped when it is already there.
rem
rem  Downloads about 2 GB the first time. Needs internet.
rem  Run bat_file\Launcher\Setup.bat FIRST (this one only adds the Android part).
rem ============================================================================
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"
set PYTHONIOENCODING=utf-8
chcp 65001 >nul

if not defined ANDROID_HOME set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "SDK=!ANDROID_HOME!"
set "AVD_NAME=ttb_test"
set "IMAGE=system-images;android-33;google_apis;x86_64"

echo ==================================================================
echo  SETUP ANDROID  (question 4 - Minimal-Todo)
echo  SDK folder : !SDK!
echo  AVD        : !AVD_NAME!
echo ==================================================================
echo.

rem ---------------------------------------------------------------- 1. Node.js
echo [1/5] Node.js...
where node >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%V in ('node -v') do echo        already installed %%V
    goto :appium
)
where winget >nul 2>&1
if errorlevel 1 (
    echo  [FAIL] Node.js not found and winget is not available.
    echo         Install Node LTS from https://nodejs.org then run this file again.
    pause
    exit /b 1
)
echo        Installing with winget ^(accept the prompts if any^)...
winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
rem winget / msiexec change PATH only for NEW windows
set "PATH=%ProgramFiles%\nodejs;%APPDATA%\npm;!PATH!"
where node >nul 2>&1
if errorlevel 1 (
    echo  [WARN] Node is installed but not on PATH in this window.
    echo         Close this window, open a new one and run Setup_Android.bat again.
    pause
    exit /b 1
)

:appium
rem ---------------------------------------------------------------- 2. appium
echo.
echo [2/5] Appium + uiautomator2 driver...
where appium >nul 2>&1
if errorlevel 1 (
    echo        npm install -g appium ...
    call npm install -g appium
    set "PATH=%APPDATA%\npm;!PATH!"
) else (
    for /f "delims=" %%V in ('appium --version 2^>nul') do echo        appium %%V already installed
)
call appium driver list --installed 2>nul | findstr /i uiautomator2 >nul
if errorlevel 1 (
    echo        appium driver install uiautomator2 ...
    call appium driver install uiautomator2
) else (
    echo        uiautomator2 driver already installed
)

rem ---------------------------------------------------------------- 3. Android SDK
echo.
echo [3/5] Android SDK...
set "SDKMGR=!SDK!\cmdline-tools\latest\bin\sdkmanager.bat"
if exist "!SDKMGR!" goto :sdk_packages

echo        Command line tools not found - downloading...
set "ZIP=%TEMP%\android-cmdline-tools.zip"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop'; Invoke-WebRequest -UseBasicParsing 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip' -OutFile '!ZIP!'"
if errorlevel 1 (
    echo  [FAIL] Could not download the Android command line tools.
    echo         Install Android Studio instead ^(it brings the SDK^), then run this file again.
    pause
    exit /b 1
)
if not exist "!SDK!\cmdline-tools" mkdir "!SDK!\cmdline-tools"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -Force '!ZIP!' '!SDK!\cmdline-tools\_tmp'"
if exist "!SDK!\cmdline-tools\latest" rmdir /s /q "!SDK!\cmdline-tools\latest"
move "!SDK!\cmdline-tools\_tmp\cmdline-tools" "!SDK!\cmdline-tools\latest" >nul
rmdir /s /q "!SDK!\cmdline-tools\_tmp" 2>nul
del "!ZIP!" 2>nul
if not exist "!SDKMGR!" (
    echo  [FAIL] sdkmanager is still missing after the download.
    pause
    exit /b 1
)
echo        Command line tools installed.

:sdk_packages
echo        Accepting licences...
rem `yes` for every licence prompt
(for /l %%i in (1,1,30) do @echo y) | call "!SDKMGR!" --licenses >nul 2>&1
echo        Installing platform-tools, emulator and the system image ^(large download^)...
call "!SDKMGR!" "platform-tools" "emulator" "platforms;android-33" "!IMAGE!"
if errorlevel 1 (
    echo  [FAIL] sdkmanager could not install the packages. Check the proxy / disk space.
    pause
    exit /b 1
)

rem ---------------------------------------------------------------- 4. AVD
echo.
echo [4/5] Virtual device "!AVD_NAME!"...
set "AVDMGR=!SDK!\cmdline-tools\latest\bin\avdmanager.bat"
"!SDK!\emulator\emulator.exe" -list-avds 2>nul | findstr /x /i "!AVD_NAME!" >nul
if not errorlevel 1 (
    echo        already exists
) else (
    echo        creating...
    echo no | call "!AVDMGR!" create avd -n "!AVD_NAME!" -k "!IMAGE!" -d pixel_5 --force
    if errorlevel 1 (
        echo  [WARN] Could not create the AVD. Make one in Android Studio ^> Device Manager;
        echo         Start_Android_Stack.bat uses the first AVD it finds.
    )
)

rem ---------------------------------------------------------------- 5. persist + check
echo.
echo [5/5] Saving ANDROID_HOME for future windows and checking...
setx ANDROID_HOME "!SDK!" >nul
setx PATH "%PATH%;!SDK!\platform-tools;!SDK!\emulator" >nul 2>&1
set "PATH=!PATH!;!SDK!\platform-tools;!SDK!\emulator"

set "PY="
if exist "!_UROOT!\Resources\Launcher\launcher_python.txt" set /p PY=<"!_UROOT!\Resources\Launcher\launcher_python.txt"
if not defined PY set "PY=python"
"!PY!" "!_UROOT!\Resources\Library\android_tools.py" status

echo.
echo ==================================================================
echo  ANDROID SETUP DONE
echo  Next: bat_file\TTB_ASSIGNMENT\Run_Q4_Mobile_Todo.bat
echo        ^(it starts the emulator and appium by itself^)
echo  NOTE: you still need Upload_file\Minimal-Todo.apk - see README.md
echo ==================================================================
pause
