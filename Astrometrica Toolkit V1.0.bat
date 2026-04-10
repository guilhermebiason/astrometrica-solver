@echo off
setlocal enabledelayedexpansion

:: Path Definitions
set "LOCAL_DIR=%localappdata%\Astrometrica"
set "DATA_DIR=C:\Astrometrica\Data"

:: ANSI Colors
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "CYAN=%ESC%[96m"
set "RESET=%ESC%[0m"

:menu
cls
echo %CYAN%===========================================%RESET%
echo           Astrometrica Toolkit V1.0
echo %CYAN%===========================================%RESET%
echo  [1] Fix Runtime Error 217 (LocalAppData)
echo  [2] Fix I/O Writing Error 3 (C:\Data)
echo  [3] Delete Created Folders (Cleanup)
echo  [4] Search and Launch Astrometrica.exe
echo  [5] Credits
echo  [6] Exit
echo %CYAN%===========================================%RESET%
echo.

choice /c 123456 /n /m "Select an option [1-6]: "

if errorlevel 6 exit
if errorlevel 5 goto credits
if errorlevel 4 goto run
if errorlevel 3 goto delete
if errorlevel 2 goto fix_io
if errorlevel 1 goto fix_runtime

:fix_runtime
cls
echo %YELLOW%Checking LocalAppData...%RESET%
if not exist "%LOCAL_DIR%" (
    mkdir "%LOCAL_DIR%"
    echo %GREEN%[CREATED]%RESET% Runtime folder created successfully at:
    echo "%LOCAL_DIR%"
) else (
    echo [!] Runtime folder already exists. No action needed.
)
goto end

:fix_io
cls
echo %YELLOW%Checking Data Path...%RESET%
if not exist "%DATA_DIR%" (
    mkdir "%DATA_DIR%"
    echo %GREEN%[CREATED]%RESET% I/O Data structure created at:
    echo "%DATA_DIR%"
) else (
    echo [!] I/O Data folder already exists. No action needed.
)
goto end

:delete
cls
set "FOUND_ANY=0"
echo %RED%Starting cleanup process...%RESET%
echo.

:: Check LocalAppData
if exist "%LOCAL_DIR%" (
    rd /s /q "%LOCAL_DIR%"
    echo %GREEN%[REMOVED]%RESET% LocalAppData folder deleted.
    set "FOUND_ANY=1"
)

:: Check C:\Astrometrica
if exist "C:\Astrometrica" (
    rd /s /q "C:\Astrometrica"
    echo %GREEN%[REMOVED]%RESET% C:\Astrometrica structure deleted.
    set "FOUND_ANY=1"
)

:: If nothing was found to delete
if "!FOUND_ANY!"=="0" (
    echo %YELLOW%[NOT FOUND]%RESET% No Astrometrica folders were found to delete.
)
goto end

:run
cls
echo %YELLOW%Searching for Astrometrica.exe...%RESET%
set "FOUND_PATH="
for %%d in (C D E) do (
    if exist "%%d:\" (
        for /f "delims=" %%i in ('dir "%%d:\Astrometrica.exe" /s /b 2^>nul') do (
            set "FOUND_PATH=%%i"
            goto launch
        )
    )
)
if not defined FOUND_PATH (
    echo %RED%[ERROR]%RESET% Astrometrica.exe not found on drives C, D, or E.
    goto end
)

:launch
echo %GREEN%Found at:%RESET% "%FOUND_PATH%"
echo Launching...
start "" "%FOUND_PATH%"
exit

:credits
cls
echo %CYAN%===========================================%RESET%
echo                TOOLKIT CREDITS
echo %CYAN%===========================================%RESET%
echo.
echo   Dev: G. Biason
echo   Purpose: Solving Path-related errors for
echo            Astrometrica software.
echo.
echo   Special thanks to the Starbyte Network 
echo   asteroid hunters community.
echo.
echo %CYAN%===========================================%RESET%
goto end

:end
echo.
echo Press any key to return to menu...
pause > nul
goto menu