@echo off
echo ==========================================
echo   TaskManagement - Build APK with Emulator
echo ==========================================
echo.

:: Set paths
set FLUTTER_PATH=D:\App\Task_Management\flutter\bin\flutter.bat
set ANDROID_SDK=C:\Users\CPM-26\AppData\Local\Android\Sdk
set ADB_PATH=%ANDROID_SDK%\platform-tools\adb.exe
set EMULATOR_PATH=%ANDROID_SDK%\emulator\emulator.exe

echo [INFO] Checking prerequisites...

:: Check if Flutter exists
if not exist "%FLUTTER_PATH%" (
    echo [ERROR] Flutter not found in PATH
    pause
    exit /b 1
)

:: Check if Android SDK exists
if not exist "%ANDROID_SDK%" (
    echo [ERROR] Android SDK not found at C:\Users\CPM-26\AppData\Local\Android\Sdk
    pause
    exit /b 1
)

echo [INFO] Checking for connected devices...
"%FLUTTER_PATH%" devices

echo.
echo ==========================================
echo   OPTIONS:
echo ==========================================
echo.
echo 1. Start Emulator + Build APK (Debug)
echo 2. Start Emulator + Build APK (Release)
echo 3. Build APK Only (No Emulator)
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto :debug_apk
if "%choice%"=="2" goto :release_apk
if "%choice%"=="3" goto :build_only
if "%choice%"=="4" goto :exit
goto :exit

:debug_apk
echo.
echo [INFO] Starting emulator and building DEBUG APK...
call :start_emulator
echo [INFO] Building Debug APK...
"%FLUTTER_PATH%" build apk --debug
goto :finish

:release_apk
echo.
echo [INFO] Starting emulator and building RELEASE APK...
call :start_emulator
echo [INFO] Building Release APK...
"%FLUTTER_PATH%" build apk --release
goto :finish

:build_only
echo.
echo [INFO] Building APK without starting emulator...
echo [INFO] Building Release APK...
"%FLUTTER_PATH%" build apk --release
goto :finish

:start_emulator
echo [INFO] Checking if emulator is running...
"%ADB_PATH%" devices | findstr "emulator" >nul
if %errorlevel% == 0 (
    echo [INFO] Emulator already running!
) else (
    echo [INFO] No emulator running. Starting Pixel 9 Pro...
    start "Android Emulator" "%EMULATOR_PATH%" -avd Pixel_9_Pro -no-snapshot-load -gpu host
    echo.
    echo [INFO] Waiting for emulator to boot (45 seconds)...
    timeout /t 45 /nobreak >nul
    echo [INFO] Checking connection...
    "%ADB_PATH%" devices
)
exit /b 0

:finish
echo.
echo ==========================================
echo   BUILD COMPLETE
echo ==========================================
echo.
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo [SUCCESS] Debug APK location:
    echo   build\app\outputs\flutter-apk\app-debug.apk
)
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo [SUCCESS] Release APK location:
    echo   build\app\outputs\flutter-apk\app-release.apk
)
echo.
pause

:exit
echo.
echo [INFO] Done.
