#!/bin/bash
# ReiLua Release Build Script
# Works on Windows (w64devkit) and macOS

echo "================================"
echo "ReiLua - Release Build"
echo "================================"
echo ""

# Get the script directory and navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.." || exit 1

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERROR: Cannot find CMakeLists.txt in project root"
    exit 1
fi

# Check for dependencies on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Checking macOS build configuration..."
    
    # Check if static libraries exist
    if [ -f "../lib/macos/libraylib.a" ] && [ -f "../lib/macos/liblua.a" ]; then
        echo "✓ Static libraries found - building for distribution"
        echo "  (Single-file executable, no dependencies)"
        echo ""
    else
        echo "⚠️  Static libraries not found - using Homebrew libraries"
        echo ""
        echo "This build will require raylib/lua at runtime."
        echo ""
        echo "For distribution builds (single executable), run:"
        echo "  ./scripts/macos/build_static_libs.sh"
        echo ""
        
        # Check for Homebrew dependencies
        MISSING_DEPS=()
        
        if ! brew list glfw &>/dev/null; then
            MISSING_DEPS+=("glfw")
        fi
        
        if ! brew list raylib &>/dev/null; then
            MISSING_DEPS+=("raylib")
        fi
        
        if ! brew list lua &>/dev/null; then
            MISSING_DEPS+=("lua")
        fi
        
        if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
            echo "ERROR: Missing Homebrew packages: ${MISSING_DEPS[*]}"
            echo ""
            echo "Install with:"
            echo "  brew install ${MISSING_DEPS[*]} pkg-config"
            echo ""
            exit 1
        fi
        
        echo "✓ Homebrew dependencies found"
        echo ""
    fi
fi

# Create and navigate to build directory
mkdir -p build
cd build || exit 1

# ALWAYS clean build folder for fresh build
echo "Cleaning build directory for fresh build..."
rm -rf ./* 2>/dev/null
echo "✓ Build directory cleaned"
echo ""

# Clean old embedded files
echo "Ready for fresh build..."
rm -f embedded_main.h embedded_assets.h 2>/dev/null

# Auto-copy from game folder if it exists
echo ""
if [ -d "../game" ]; then
    echo "Found game/ folder - auto-copying ALL contents to build..."
    
    # Copy everything from game folder recursively, excluding:
    # - ReiLua_API.lua (LSP only)
    # - .luarc.json (LSP config)
    # - .DS_Store (macOS)
    # - Hidden files starting with . (except .gitkeep if present)
    
    # Use rsync if available for better copying, otherwise use cp
    if command -v rsync &> /dev/null; then
        rsync -av --exclude='ReiLua_API.lua' --exclude='.luarc.json' --exclude='.DS_Store' --exclude='.*' --include='.gitkeep' ../game/ . 2>/dev/null
    else
        # Fallback to find + cp - Copy ALL files and directories
        (cd ../game && find . -type f \
            ! -name 'ReiLua_API.lua' \
            ! -name '.luarc.json' \
            ! -name '.DS_Store' \
            ! -path '*/\.*' -o -name '.gitkeep' \
            -exec sh -c 'mkdir -p "../build/$(dirname "{}")" && cp -p "{}" "../build/{}"' \; 2>/dev/null)
    fi
    
    # Count what was copied
    LUA_COUNT=$(find . -maxdepth 10 -name "*.lua" -type f 2>/dev/null | wc -l)
    ASSET_COUNT=$(find assets -type f 2>/dev/null | wc -l || echo "0")
    TOTAL_FILES=$(find . -type f ! -path './CMakeFiles/*' ! -path './.cmake/*' ! -name 'CMake*' ! -name '*.a' ! -name '*.o' 2>/dev/null | wc -l)
    
    echo "  ✓ Copied ALL game files and folders:"
    echo "    - $LUA_COUNT Lua file(s) (including all subdirectories)"
    echo "    - $ASSET_COUNT Asset file(s) (if assets folder exists)"
    echo "    - $TOTAL_FILES total file(s)"
    echo "    - All folder structures preserved (user-created folders included)"
    echo ""
fi

# Check for Lua files
echo "Checking for Lua files..."
LUA_FILES=$(ls *.lua 2>/dev/null | wc -l)

if [ "$LUA_FILES" -eq 0 ]; then
    echo ""
    echo "WARNING: No Lua files found in build directory!"
    echo ""
    if [ -d "../game" ]; then
        echo "No Lua files found in game/ folder either."
        echo "Add your main.lua to game/ folder and try again."
    else
        echo "Tip: Create a game/ folder in project root and add main.lua there."
        echo "Or manually copy files:"
        echo "  cd build"
        echo "  cp ../your_game/*.lua ."
    fi
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "Found $LUA_FILES Lua file(s):"
    ls -1 *.lua
fi

# Check for non-Lua data files (any folder, any file type)
echo ""
echo "Checking for data files to embed..."
NON_LUA_FILES=$(find . -type f ! -name "*.lua" ! -path "./CMakeFiles/*" ! -path "./.cmake/*" ! -name "CMake*" ! -name "Makefile*" ! -name "*.o" ! -name "*.a" 2>/dev/null | wc -l)

if [ "$NON_LUA_FILES" -gt 0 ]; then
    echo "Found $NON_LUA_FILES non-Lua file(s) to embed"
    echo "  (includes: images, sounds, config, data, and any other files)"
    EMBED_ASSETS="ON"
else
    echo "No non-Lua files found (only Lua code will be embedded)"
    EMBED_ASSETS="OFF"
fi

echo ""
echo "================================"
echo "Build Configuration"
echo "================================"
echo "Lua Embedding:    ON"
echo "Data Embedding:   $EMBED_ASSETS"
echo "Build Type:       Release"
echo "================================"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Clean CMake cache to ensure fresh configuration
echo ""
echo "Cleaning CMake cache..."
rm -rf CMakeCache.txt CMakeFiles/

# Detect platform and set appropriate generator
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CMAKE_GENERATOR="Unix Makefiles"
    BUILD_CMD="make"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "mingw"* ]]; then
    # Windows with MinGW
    CMAKE_GENERATOR="MinGW Makefiles"
    BUILD_CMD="make"
else
    # Linux and others
    CMAKE_GENERATOR="Unix Makefiles"
    BUILD_CMD="make"
fi

# Configure with embedding enabled
echo ""
echo "Configuring CMake for release (${OSTYPE})..."
cmake -G "$CMAKE_GENERATOR" .. -DEMBED_MAIN=ON -DEMBED_ASSETS=$EMBED_ASSETS -DCMAKE_BUILD_TYPE=Release

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

# Build
echo ""
echo "Building ReiLua Release..."
$BUILD_CMD

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Build failed!"
    exit 1
fi

# Show embedded file info
echo ""
echo "================================"
echo "Embedded Files Summary"
echo "================================"

if [ -f "embedded_main.h" ]; then
    echo ""
    echo "Embedded Lua files:"
    grep 'Embedded file:' embedded_main.h | sed 's/.*Embedded file: /  - /'
else
    echo "No Lua files embedded"
fi

if [ -f "embedded_assets.h" ]; then
    echo ""
    echo "Embedded assets:"
    grep 'Embedded asset:' embedded_assets.h | sed 's/.*Embedded asset: /  - /' | sed 's/ (.*//'
else
    echo "No assets embedded"
fi

# Get executable size
echo ""
echo "================================"
echo "Build Complete!"
echo "================================"

# Read executable name from project.info
EXE_NAME="ReiLua"
if [ -f "../project.info" ]; then
    EXE_NAME=$(grep "^EXECUTABLE_NAME=" ../project.info | cut -d'=' -f2)
fi

# Detect executable extension based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    EXE_FILE="$EXE_NAME"
else
    EXE_FILE="${EXE_NAME}.exe"
fi

if [ ! -f "$EXE_FILE" ]; then
    echo "Warning: Expected executable not found: $EXE_FILE"
    echo "Falling back to ReiLua..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        EXE_FILE="ReiLua"
    else
        EXE_FILE="ReiLua.exe"
    fi
fi

EXESIZE=$(du -h "$EXE_FILE" | cut -f1)
echo ""
echo "Executable: $EXE_FILE ($EXESIZE)"
echo "Location:   $(pwd)/$EXE_FILE"
echo ""
echo "Your game is ready for distribution!"
echo ""
echo "To test the release build:"
echo "  ./$EXE_FILE --log  (with console)"
echo "  ./$EXE_FILE        (production mode)"
echo ""
echo "To distribute:"
echo "  - Copy $EXE_FILE to your distribution folder"
echo "  - That's it! Single file distribution!"
echo ""
