@echo off
rem ============================================================================
rem  load_credentials.bat "<project root>"
rem  Loads Resources\Settings\credentials.env (KEY=VALUE per line, # = comment)
rem  into the calling window. credentials.env is a local file - do not commit it.
rem  Template: Resources\Settings\credentials.env.example
rem ============================================================================
set "_CRED_ROOT=%~1"
if "%_CRED_ROOT%"=="" for %%I in ("%~dp0..") do set "_CRED_ROOT=%%~fI"
set "_CRED_FILE=%_CRED_ROOT%\Resources\Settings\credentials.env"
if not exist "%_CRED_FILE%" (
    echo [credentials] not found: %_CRED_FILE%
    echo [credentials] copy credentials.env.example to credentials.env if you need
    echo [credentials] your own values - the defaults in env_config.py work as they are
    set "_CRED_ROOT=" & set "_CRED_FILE="
    exit /b 0
)
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%_CRED_FILE%") do if not "%%B"=="" set "%%A=%%B"
set "_CRED_ROOT=" & set "_CRED_FILE="
exit /b 0
