@echo off
setlocal enabledelayedexpansion
title Make wheelhouse (offline packages)
rem Run on a machine WITH internet and the SAME Python version as the target machines.
rem Creates bat_file\Launcher\wheelhouse. Copy the whole project (with that folder) to
rem the new machine; Setup.bat then installs everything without internet.
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
set "LAUNCHER=!_UROOT!\Resources\Launcher"
set "REQ=!LAUNCHER!\requirements.txt"
set "PY="
if exist "!LAUNCHER!\launcher_python.txt" set /p PY=<"!LAUNCHER!\launcher_python.txt"
if not defined PY set "PY=python"
"!PY!" -m pip download -r "!REQ!" -d "!HERE!wheelhouse"
echo.
echo Done: !HERE!wheelhouse
echo NOTE: the node/chromium side of Browser library is NOT in the wheelhouse.
echo       A machine with no internet at all also needs PLAYWRIGHT_BROWSERS_PATH
echo       pointed at a copied browser folder, or BROWSER_EXECUTABLE set to a
echo       chromium that is already installed.
pause
