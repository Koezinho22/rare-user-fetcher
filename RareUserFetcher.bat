@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion
title Rare User Fetcher v3.3
color 0A

set "RESULTS_FILE=%~dp0rare_available.txt"
set "ENGINE=%~dp0_ruf_engine.ps1"

if not exist "!ENGINE!" (
    echo.
    echo   ERROR: _ruf_engine.ps1 not found!
    echo   Make sure it is in the same folder as this .bat file.
    echo.
    pause
    exit
)

if not exist "!RESULTS_FILE!" (
    echo # Rare Available Usernames > "!RESULTS_FILE!"
)

goto MENU

:MENU
cls
echo.
echo   ========================================================
echo         RARE USER FETCHER v3.3
echo         Roblox + Discord Username Hunter
echo   ========================================================
echo.
echo    [1]  Check Rare Usernames
echo    [2]  See What's Available Right Now
echo    [3]  Exit
echo.
set "CHOICE="
set /p "CHOICE=   Select: "
if "!CHOICE!"=="1" goto CHECK
if "!CHOICE!"=="2" goto VIEW
if "!CHOICE!"=="3" goto QUIT
goto MENU

:CHECK
cls
echo.
echo   ========================================================
echo                   USERNAME CHECKER
echo   ========================================================
echo.
echo    [A]  Hunt 3-letter names   (OG tier)
echo    [B]  Hunt 4-letter names   (very rare)
echo    [C]  Hunt 5-letter names   (rare)
echo    [D]  Custom length
echo    [E]  Check one specific name
echo    [F]  Check names from a .txt file
echo    [G]  Back
echo.
echo    NOTE: Discord free API only works for 5+ letters.
echo.
set "SUB="
set /p "SUB=   Select: "
if /i "!SUB!"=="A" ( set "HUNT_LEN=3" & goto HUNT_SETUP )
if /i "!SUB!"=="B" ( set "HUNT_LEN=4" & goto HUNT_SETUP )
if /i "!SUB!"=="C" ( set "HUNT_LEN=5" & goto HUNT_SETUP )
if /i "!SUB!"=="D" goto CUSTOM_LEN
if /i "!SUB!"=="E" goto SINGLE
if /i "!SUB!"=="F" goto FROM_FILE
if /i "!SUB!"=="G" goto MENU
goto CHECK

:CUSTOM_LEN
set "HUNT_LEN="
set /p "HUNT_LEN=   Enter length: "
if "!HUNT_LEN!"=="" goto CHECK
goto HUNT_SETUP

:HUNT_SETUP
cls
echo.
echo   ========================================================
echo         HUNTING !HUNT_LEN!-LETTER USERNAMES
echo   ========================================================
echo.
echo    Character set:
echo      [1]  Letters only           (abc)
echo      [2]  Numbers only           (123)
echo      [3]  Letters + numbers      (a1b2)
echo      [4]  Letters + underscore   (a_b)
echo      [5]  All mixed              (a1_b)
echo.
set "CP="
set /p "CP=   Select: "
if "!CP!"=="" set "CP=1"
echo.
echo    Platform:
echo      [1]  Roblox only
echo      [2]  Discord only
echo      [3]  Both
echo.
set "PLAT="
set /p "PLAT=   Select: "
if "!PLAT!"=="" set "PLAT=3"
echo.
set "AMOUNT="
set /p "AMOUNT=   How many to check? "
if "!AMOUNT!"=="" set "AMOUNT=25"
echo.
echo    Speed:
echo      [1]  Slow     (2s between checks)
echo      [2]  Normal   (1s between checks)
echo      [3]  Fast     (0.3s between checks)
echo      [4]  Instant  (no delay)
echo.
set "SPICK="
set /p "SPICK=   Select: "
if "!SPICK!"=="1" ( set "DELAY=2000" )
if "!SPICK!"=="2" ( set "DELAY=1000" )
if "!SPICK!"=="3" ( set "DELAY=300" )
if "!SPICK!"=="4" ( set "DELAY=0" )
if not defined DELAY set "DELAY=1000"

echo.
echo   Starting hunt...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "!ENGINE!" -Mode hunt -Len !HUNT_LEN! -Count !AMOUNT! -CharsetPick "!CP!" -Platform "!PLAT!" -DelayMs !DELAY! -ResultsFile "!RESULTS_FILE!"

echo.
echo   Press any key to go back...
pause >nul
goto CHECK

:SINGLE
cls
echo.
set "UNAME="
set /p "UNAME=   Enter username to check: "
if "!UNAME!"=="" goto CHECK
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "!ENGINE!" -Mode single -SingleName "!UNAME!" -ResultsFile "!RESULTS_FILE!"

echo.
echo   Press any key to go back...
pause >nul
goto CHECK

:FROM_FILE
cls
echo.
echo   Enter path to a .txt file (one username per line):
set "FPATH="
set /p "FPATH=   Path: "
if "!FPATH!"=="" goto CHECK
if not exist "!FPATH!" (
    echo   File not found.
    pause >nul
    goto CHECK
)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "!ENGINE!" -Mode file -ListFile "!FPATH!" -ResultsFile "!RESULTS_FILE!"

echo.
echo   Press any key to go back...
pause >nul
goto CHECK

:VIEW
cls
echo.
echo   ========================================================
echo          AVAILABLE RARE USERNAMES
echo   ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "!ENGINE!" -Mode view -ResultsFile "!RESULTS_FILE!"

echo.
echo   File: !RESULTS_FILE!
echo.
echo   Press any key to go back...
pause >nul
goto MENU

:QUIT
cls
echo.
echo   Closed.
timeout /t 1 /nobreak >nul
exit
