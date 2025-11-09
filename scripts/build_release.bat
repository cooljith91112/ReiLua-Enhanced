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

REM ALWAYS clean build folder for fresh build
echo Cleaning build directory for fresh build...
del /Q /S * >nul 2>&1
for /d %%p in (*) do rmdir "%%p" /s /q >nul 2>&1
echo * Build directory cleaned
echo.

REM Clean old embedded files
echo Ready for fresh build...
del /Q embedded_main.h embedded_assets.h 2>nul

REM Auto-copy from game folder if it exists
echo.
if exist "..\game" (
    echo Found game/ folder - auto-copying ALL contents to build...
    
    REM Copy all files from game folder recursively, excluding LSP files
    xcopy /E /I /Y /EXCLUDE:..\game\ReiLua_API.lua+..\game\.luarc.json "..\game\*" . >nul 2>&1
    if exist "..\game\ReiLua_API.lua" del /Q "ReiLua_API.lua" 2>nul
    if exist "..\game\.luarc.json" del /Q ".luarc.json" 2>nul
    
    echo   * Copied ALL game files and folders
    echo   * All folder structures preserved ^(user-created folders included^)
    echo.
)

REM Check for Lua files
echo Checking for Lua files...
dir /b *.lua >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: No Lua files found in build directory!
    echo.
    if exist "..\game" (
        echo No Lua files found in game/ folder.
        echo Add your main.lua to game/ folder and try again.
    ) else (
        echo Tip: Create a game/ folder in project root and add main.lua there.
        echo Or manually copy files:
        echo   cd build
        echo   copy ..\your_game\*.lua .
    )
    echo.
    set /p CONTINUE="Do you want to continue anyway? (y/N): "
    if /i not "%CONTINUE%"=="y" exit /b 1
) else (
    echo Found Lua files:
    dir /b *.lua
)

REM Check for non-Lua data files (any folder, any file type)
echo.
echo Checking for data files to embed...
set DATA_COUNT=0
for /r %%f in (*) do (
    echo %%~nxf | findstr /i /v ".lua .exe .o .a CMake Makefile" >nul
    if not errorlevel 1 set /a DATA_COUNT+=1
)

if %DATA_COUNT% GTR 0 (
    echo Found data files to embed
    echo   ^(includes: images, sounds, config, data, and any other files^)
    set EMBED_ASSETS=ON
) else (
    echo No non-Lua files found ^(only Lua code will be embedded^)
    set EMBED_ASSETS=OFF
)

echo.
echo ================================
echo Build Configuration
echo ================================
echo Lua Embedding:    ON
echo Data Embedding:   %EMBED_ASSETS%
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
