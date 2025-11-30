@echo off
setlocal enabledelayedexpansion

echo Steam Game Validator
echo ====================
echo.

REM Create temporary file
set "TEMP_APPS=%TEMP%\steam_apps.txt"
if exist "%TEMP_APPS%" del "%TEMP_APPS%"

echo Scanning drives D, E, F, G, H for Steam libraries...
echo.

REM Scan drives D through H for SteamLibrary folders
for %%d in (D E F G H) do (
    if exist "%%d:\SteamLibrary\steamapps" (
        echo Found: %%d:\SteamLibrary\steamapps
        call :ScanLibrary "%%d:\SteamLibrary\steamapps"
    )
)

REM Check if any games were found
if not exist "%TEMP_APPS%" (
    echo.
    echo No installed Steam games found.
    echo.
    pause
    exit /b 0
)

REM Remove duplicates
echo.
echo Processing game list...
sort "%TEMP_APPS%" /unique > "%TEMP_APPS%.sorted"
move /y "%TEMP_APPS%.sorted" "%TEMP_APPS%" >nul 2>&1

echo.
echo ============================================
echo Found installed game App IDs:
echo ============================================
type "%TEMP_APPS%"
echo ============================================
echo.

REM Count games
for /f %%c in ('type "%TEMP_APPS%" ^| find /c /v ""') do set "game_count=%%c"
echo Total games found: %game_count%
echo.

REM Ask for confirmation
set /p "confirm=Start validation for all %game_count% games? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Validation cancelled.
    goto cleanup
)

echo.
echo Starting validation process...
echo Please keep Steam running.
echo.

REM Validate each game
set "counter=0"
for /f "delims=" %%i in (%TEMP_APPS%) do (
    set /a counter+=1
    echo [!counter!/%game_count%] Validating App ID: %%i
    start "" "steam://validate/%%i"
    timeout /t 3 /nobreak >nul 2>&1
)

echo.
echo ============================================
echo Validation initiated for all games!
echo ============================================
echo Check Steam Downloads page to monitor progress.
echo.
pause

:cleanup
if exist "%TEMP_APPS%" del "%TEMP_APPS%" 2>nul
exit /b 0

:ScanLibrary
set "lib=%~1"
if exist "%lib%" (
    pushd "%lib%" 2>nul
    if not errorlevel 1 (
        for %%f in (appmanifest_*.acf) do (
            set "fname=%%~nf"
            for /f "tokens=2 delims=_." %%n in ("!fname!") do (
                echo %%n>> "%TEMP_APPS%"
            )
        )
        popd
    )
)
exit /b