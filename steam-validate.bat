@echo off
setlocal enabledelayedexpansion

REM Path to Steam libraryfolders.vdf (adjust for your system)
set "LIBRARY_FILE=D:\SteamLibrary\libraryfolder.vdf"
set "EXTERNAL_LIB_PATH=D:\SteamLibrary\steamapps\"

REM Check if libraryfolders.vdf exists
if not exist "%LIBRARY_FILE%" (
    echo Error: Steam libraryfolder.vdf not found at %LIBRARY_FILE%
    exit /b 1
)

REM Create temporary file for app IDs
set "TEMP_FILE=%TEMP%\steam_apps.txt"
if exist "%TEMP_FILE%" del "%TEMP_FILE%"

REM Extract library paths from libraryfolders.vdf
echo Scanning Steam libraries for installed games...
for /f "tokens=2 delims=^" %%a in ('findstr /r "\"path\"" "%LIBRARY_FILE%"') do (
    set "path=%%a"
    set "path=!path:*"=!"
    set "path=!path:"=!"
    call :ProcessLibrary "!path!"
)

REM Also check external library
call :ProcessLibrary "%EXTERNAL_LIB_PATH%"

REM Check if any games were found
if not exist "%TEMP_FILE%" (
    echo No installed Steam games found.
    exit /b 0
)

REM Display found games
echo.
echo Found installed games:
type "%TEMP_FILE%"
echo.
echo Starting validation process...
echo.

REM Validate each game
for /f %%i in (%TEMP_FILE%) do (
    echo Validating game with App ID: %%i
    start steam://validate/%%i
    timeout /t 5 /nobreak >nul
)

echo.
echo Validation process completed for all installed games.

REM Cleanup
del "%TEMP_FILE%"
exit /b 0

:ProcessLibrary
REM Function to process a library directory
set "lib_path=%~1"
if exist "%lib_path%" (
    for %%f in ("%lib_path%\appmanifest_*.acf") do (
        set "filename=%%~nf"
        set "appid=!filename:appmanifest_=!"
        echo !appid! >> "%TEMP_FILE%"
    )
)
exit /b
