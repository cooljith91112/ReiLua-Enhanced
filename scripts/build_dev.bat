@echo off
REM ReiLua Development Build Script
REM Run this from w64devkit shell or CMD with MinGW in PATH

echo ================================
echo ReiLua - Development Build
echo ================================
echo.

REM Get script directory and navigate to project root
cd /d "%~dp0.."

REM Create and navigate to build directory
if not exist "build" mkdir build
cd build
if errorlevel 1 (
    echo ERROR: Cannot access build directory
    exit /b 1
)

REM Clean old embedded files (important for dev builds!)
echo Cleaning old embedded files...
del /Q embedded_main.h embedded_assets.h 2>nul

REM Warn about Lua files in build directory
dir /b *.lua >nul 2>&1
if not errorlevel 1 (
    echo.
    echo WARNING: Found Lua files in build directory!
    echo Development builds should load from file system, not embed.
    echo.
    dir /b *.lua
    echo.
    set /p REMOVE="Remove these files from build directory? (Y/n): "
    if /i not "%REMOVE%"=="n" (
        del /Q *.lua
        echo Lua files removed.
    )
    echo.
)

REM Warn about assets folder in build directory
if exist "assets" (
    echo.
    echo WARNING: Found assets folder in build directory!
    echo Development builds should load from file system, not embed.
    echo.
    set /p REMOVE="Remove assets folder from build directory? (Y/n): "
    if /i not "%REMOVE%"=="n" (
        rmdir /S /Q assets
        echo Assets folder removed.
    )
    echo.
)

REM Clean old configuration if requested
if "%1"=="clean" (
    echo Cleaning build directory...
    del /Q CMakeCache.txt *.o *.a 2>nul
    rmdir /S /Q CMakeFiles 2>nul
    echo Clean complete!
    echo.
)

REM Configure with MinGW
echo Configuring CMake for development...
cmake -G "MinGW Makefiles" ..

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    exit /b 1
)

echo.
echo Building ReiLua...
mingw32-make

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    exit /b 1
)

echo.
echo ================================
echo Build Complete!
echo ================================
echo.
echo Development build created successfully!
echo.
echo To run your game:
echo   cd \path\to\your\game
echo   \path\to\ReiLua\build\ReiLua.exe
echo.
echo To run with console logging:
echo   \path\to\ReiLua\build\ReiLua.exe --log
echo.
echo Features:
echo   - Lua files load from file system
echo   - Assets load from file system
echo   - Fast iteration - edit and reload
echo.
pause
