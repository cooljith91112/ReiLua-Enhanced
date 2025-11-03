@echo off
REM ReiLua Release Build Script
REM Run this from w64devkit shell or CMD with MinGW in PATH

echo ================================
echo ReiLua - Release Build
echo ================================
echo.

REM Get script directory and navigate to project root
cd /d "%~dp0.."

REM Check if we're in the right directory
if not exist "CMakeLists.txt" (
    echo ERROR: Cannot find CMakeLists.txt in project root
    exit /b 1
)

REM Create and navigate to build directory
if not exist "build" mkdir build
cd build
if errorlevel 1 (
    echo ERROR: Cannot access build directory
    exit /b 1
)

REM Clean old embedded files
echo Cleaning old embedded files...
del /Q embedded_main.h embedded_assets.h 2>nul

REM Check for Lua files
echo.
echo Checking for Lua files...
dir /b *.lua >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: No Lua files found in build directory!
    echo.
    echo Please copy your Lua files:
    echo   cd build
    echo   copy ..\your_game\*.lua .
    echo.
    set /p CONTINUE="Do you want to continue anyway? (y/N): "
    if /i not "%CONTINUE%"=="y" exit /b 1
) else (
    echo Found Lua files:
    dir /b *.lua
)

REM Check for assets folder
echo.
echo Checking for assets...
if not exist "assets" (
    echo.
    echo WARNING: No assets folder found!
    echo.
    echo To embed assets, create the folder and copy files:
    echo   cd build
    echo   mkdir assets
    echo   copy ..\your_game\assets\* assets\
    echo.
    set /p CONTINUE="Do you want to continue without assets? (y/N): "
    if /i not "%CONTINUE%"=="y" exit /b 1
    set EMBED_ASSETS=OFF
) else (
    echo Found assets folder
    set EMBED_ASSETS=ON
)

echo.
echo ================================
echo Build Configuration
echo ================================
echo Lua Embedding:    ON
echo Asset Embedding:  %EMBED_ASSETS%
echo Build Type:       Release
echo ================================
echo.
pause

REM Clean CMake cache
echo.
echo Cleaning CMake cache...
del /Q CMakeCache.txt 2>nul
rmdir /S /Q CMakeFiles 2>nul

REM Configure with embedding enabled
echo.
echo Configuring CMake for release...
cmake -G "MinGW Makefiles" .. -DEMBED_MAIN=ON -DEMBED_ASSETS=%EMBED_ASSETS% -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    pause
    exit /b 1
)

REM Build
echo.
echo Building ReiLua Release...
mingw32-make

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

REM Show summary
echo.
echo ================================
echo Embedded Files Summary
echo ================================

if exist "embedded_main.h" (
    echo.
    echo Embedded Lua files:
    findstr /C:"Embedded file:" embedded_main.h
)

if exist "embedded_assets.h" (
    echo.
    echo Embedded assets:
    findstr /C:"Embedded asset:" embedded_assets.h
)

echo.
echo ================================
echo Build Complete!
echo ================================
echo.
echo Executable: ReiLua.exe
echo Location:   %CD%\ReiLua.exe
echo.
echo Your game is ready for distribution!
echo.
echo To test the release build:
echo   ReiLua.exe --log  (with console)
echo   ReiLua.exe        (production mode)
echo.
echo To distribute:
echo   - Copy ReiLua.exe to your distribution folder
echo   - Rename it to your game name (optional)
echo   - That's it! Single file distribution!
echo.
pause
