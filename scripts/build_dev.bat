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

REM ALWAYS clean build folder for fresh build
echo Cleaning build directory for fresh build...
del /Q /S * >nul 2>&1
for /d %%p in (*) do rmdir "%%p" /s /q >nul 2>&1
echo * Build directory cleaned
echo.

REM Configure
echo Configuring CMake for development...
cmake -G "MinGW Makefiles" ..

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    pause
    exit /b 1
)

REM Build
echo.
echo Building ReiLua...
mingw32-make

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
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
