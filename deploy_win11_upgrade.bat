@echo off
setlocal EnableDelayedExpansion

:: Windows 11 Migration Wrapper
:: Authors: Leonardo Mejia & Helder Arburola

set "Installer=C:\W11\setup.exe"
set "LogFile=C:\PDQ\Upgrade_W11.log"
set "MaxRetries=3"
set "RetryWait=15"
set "MinSpaceGB=64"

:: 1. Admin Rights Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Admin privileges missing. >> "%LogFile%"
    exit /b 1
)

:: 2. Init Log
if not exist "C:\PDQ" mkdir "C:\PDQ"
echo [%DATE% %TIME%] Init Migration Workflow >> "%LogFile%"

:: 3. Validation: Source & Disk Space
if not exist "%Installer%" (
    echo [FATAL] Source not found: %Installer% >> "%LogFile%"
    exit /b 1
)

for /f "tokens=2" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set "FreeSpace=%%a"
set /a "FreeGB=!FreeSpace:~0,-9!" 2>nul

if !FreeGB! LSS %MinSpaceGB% (
    echo [FATAL] Disk space low (!FreeGB!GB). Need %MinSpaceGB%GB. >> "%LogFile%"
    exit /b 1
)

:: 4. Execution Loop
set "Attempt=0"

:Install
set /a Attempt+=1
echo [INFO] Attempt %Attempt%/%MaxRetries% >> "%LogFile%"

:: Run setup silently. NoReboot allows script to finish logging.
start /wait "" "%Installer%" /Auto Upgrade /Quiet /DynamicUpdate Enable /ShowOOBE None /Compat IgnoreWarning /EULA Accept /NoReboot
set "ExitCode=%ERRORLEVEL%"

echo [INFO] Return Code: %ExitCode% >> "%LogFile%"

:: Handle Success (0) and Reboot Required (3010) as success
if %ExitCode% EQU 0 goto Success
if %ExitCode% EQU 3010 goto Success

:: Retry logic for locks
if %Attempt% LSS %MaxRetries% (
    echo [WARN] Retrying in %RetryWait%s... >> "%LogFile%"
    timeout /t %RetryWait% /nobreak >nul
    goto Install
)

echo [FAIL] Max retries exceeded. >> "%LogFile%"
exit /b %ExitCode%

:Success
echo [SUCCESS] Upgrade applied. Pending Reboot. >> "%LogFile%"
exit /b 0