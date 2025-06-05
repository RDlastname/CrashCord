@echo off
title CrashCord - Discord Crash Fix Tool
color 0B
setlocal enabledelayedexpansion

set "ver=1.1"
echo Version: %ver% > "%~dp0version.txt"
set "logfile=%~dp0CrashCord_Log.txt"

:main
:main
cls
echo   ,----..                                   ,---,      ,----..                              
echo  /   /   \                                ,--.' ^|     /   /   \                       ,---, 
echo ^|   :     :  __  ,-.                      ^|  ^|  :    ^|   :     :  ,---.    __  ,-.  ,---.'^| 
echo .   ^|  ;. /,' ,'/ /^|             .--.--.  :  :  :    .   ^|  ;. / '   ,'\ ,' ,'/ /^|  ^|   ^| : 
echo .   ; /--` '  ^| ^|' ^| ,--.--.    /  /    ' :  ^|  ^|,--..   ; /--` /   /   ^|'  ^| ^|' ^|  ^|   ^| ^| 
echo ;   ^| ;    ^|  ^|   ,'/       \  ^|  :  /`./ ^|  :  '   ^|;   ^| ;   .   ; ,. :^|  ^|   ,',--.__^| ^| 
echo ^|   : ^|    '  :  / .--.  .-. ^| ^|  :  ;_   ^|  ^|   /' :^|   : ^|   '   ^| ^|: :'  :  / /   ,'   ^| 
echo .   ^| '___ ^|  ^| '   \__\/: . .  \  \    `.'  :  ^| ^| ^|.   ^| '___'   ^| .; :^|  ^| ' .   '  /  ^| 
echo '   ; : .'^|;  : ^|   ," .--.; ^|   `----.   \  ^|  ' ^| :'   ; : .'^|   :    ^|;  : ^| '   ;   
echo '   ^| '/  :^|  , ;  /  /  ,.  ^|  /  /`--'  /  :  :_:,''   ^| '/  :\   \  / ^|  , ; ^|   ^| '/  ' 
echo ^|   :    /  ---'  ;  :   .'   \'--'.     /^|  ^| ,'    ^|   :    /  `----'   ---'  ^|   :    :^| 
echo  \   \ .'         ^|  ,     .-./  `--'---' `--''       \   \ .'                   \   \  /   
echo   `---`            `--`---'                            `---`                      `----'    
echo.
echo Version: %ver%
echo.
echo 1. Check for Broken Shortcuts
echo 2. Check and Update Installer
echo 3. Self-Update CrashCord Tool
echo 4. Launch Discord in Safe Mode
echo 5. Custom Launch Options
echo 6. Choose Theme
echo 7. Reload CrashCord
echo 8. Exit
echo.

set /p choice=Choose an option [1-8]: 

if "%choice%"=="1" goto shortcuts
if "%choice%"=="2" goto installer
if "%choice%"=="3" goto selfupdate
if "%choice%"=="4" goto safemode
if "%choice%"=="5" goto launchopts
if "%choice%"=="6" goto theme
if "%choice%"=="7" goto reload
if "%choice%"=="8" exit

echo Invalid input. Try again.
pause
goto main

:shortcuts
echo [*] Scanning desktop for broken Discord shortcuts...
set "desktop=%USERPROFILE%\Desktop"
set "count=0"

for %%f in ("%desktop%\Discord*.lnk") do (
    call :checkShortcut "%%~f"
)

if "!count!"=="0" (
    echo No broken Discord shortcuts found.
) else (
    echo Removed !count! broken shortcuts.
)
pause
goto main

:checkShortcut
set "shortcut=%~1"
if exist "%shortcut%" (
    echo Shortcut OK: %shortcut%
) else (
    echo Broken shortcut: %shortcut%
    del /f /q "%shortcut%"
    set /a count+=1
)
goto :eof

:installer
echo [*] Checking Downloads for old Discord installers...
set "downloads=%USERPROFILE%\Downloads"
set "found=0"

for %%f in ("%downloads%\DiscordSetup*.exe") do (
    echo Deleting old installer: %%~nxf
    del /f /q "%%~f"
    set "found=1"
)

echo [*] Downloading latest Discord installer...
powershell -Command "Invoke-WebRequest 'https://discord.com/api/download?platform=win' -OutFile '%downloads%\DiscordSetup.exe'"

echo [✔] Downloaded to: %downloads%\DiscordSetup.exe
pause
goto main

:selfupdate
echo [*] Checking for updates...
set "update_url=https://github.com/RDlastname/CrashCord/blob/main/CrashCord.bat"
powershell -Command "Invoke-WebRequest '%update_url%' -OutFile '%~f0.tmp'"
if exist "%~f0.tmp" (
    move /Y "%~f0.tmp" "%~f0" >nul
    echo [✔] CrashCord updated. Restarting...
    timeout /t 2 >nul
    call "%~f0"
    exit
) else (
    echo [!] Failed to download update.
)
pause
goto main

:safemode
echo [*] Closing Discord...
taskkill /f /im Discord.exe >nul 2>&1
echo [*] Clearing Discord cache...
rd /s /q "%AppData%\discord\Cache"
rd /s /q "%AppData%\discord\Code Cache"
rd /s /q "%AppData%\discord\GPUCache"
echo [*] Launching Discord...
start "" "%LocalAppData%\Discord\Update.exe" --processStart Discord.exe
echo [%DATE% %TIME%] Discord launched (Safe Mode) >> "%logfile%"
pause
goto main

:launchopts
echo [*] Choose Launch Option:
echo 1. Normal Launch
echo 2. Launch with Debug Logs
echo 3. Launch Minimized
set /p launchopt=Select option [1-3]: 
if "%launchopt%"=="1" start "" "%LocalAppData%\Discord\Update.exe" --processStart Discord.exe
if "%launchopt%"=="2" start "" "%LocalAppData%\Discord\Update.exe" --processStart Discord.exe --log-level=debug
if "%launchopt%"=="3" start "" "%LocalAppData%\Discord\Update.exe" --processStart Discord.exe --start-minimized
echo [%DATE% %TIME%] Discord launched with option %launchopt% >> "%logfile%"
pause
goto main

:theme
echo [*] Choose a Theme:
echo 1. Dark Green (Bright green text on black)
echo 2. Blue Text Only (Blue text on black)
echo 3. Retro (Green text on dark green background)
set /p theme=Theme [1-3]: 
if "%theme%"=="1" color 0A
if "%theme%"=="2" color 09
if "%theme%"=="3" color 2A
echo [*] Theme applied.
pause
goto main

:reload
echo [*] Reloading CrashCord...
timeout /t 1 >nul
call "%~f0"
exit /b
