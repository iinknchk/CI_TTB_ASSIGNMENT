@echo off
setlocal enabledelayedexpansion
rem Started by the launcher page (one window per run). Usage: Run_Batch.bat <run_id>
set "HERE=%~dp0"
set "_UROOT=!HERE:\bat_file\=|!"
for /f "tokens=1 delims=|" %%a in ("!_UROOT!") do set "_UROOT=%%a"
call "!_UROOT!\bat_file\load_credentials.bat" "!_UROOT!"
set "RUN_ID=%~1"
title TTB Run !RUN_ID!
set PYTHONIOENCODING=utf-8
chcp 65001 >nul

set "PY=%LAUNCHER_PY%"
if not defined PY set "PY=python"
"!PY!" "!_UROOT!\Resources\Launcher\run_from_json.py" "!RUN_ID!"

echo.
echo ============================================================
echo  Run finished. The summary is on the launcher page.
echo  This window closes by itself in 60 seconds.
echo ============================================================
timeout /t 60
