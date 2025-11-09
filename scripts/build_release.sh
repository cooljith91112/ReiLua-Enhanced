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

# Clean old embedded files
echo "Cleaning old embedded files..."
rm -f embedded_main.h embedded_assets.h

# Check for Lua files
echo ""
echo "Checking for Lua files..."
LUA_FILES=$(ls *.lua 2>/dev/null | wc -l)

if [ "$LUA_FILES" -eq 0 ]; then
    echo ""
    echo "WARNING: No Lua files found in build directory!"
    echo ""
    echo "Please copy your Lua files:"
    echo "  cd build"
    echo "  cp ../your_game/*.lua ."
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

# Check for assets folder
echo ""
echo "Checking for assets..."
if [ ! -d "assets" ]; then
    echo ""
    echo "WARNING: No assets folder found!"
    echo ""
    echo "To embed assets, create the folder and copy files:"
    echo "  cd build"
    echo "  mkdir assets"
    echo "  cp ../your_game/assets/* assets/"
    echo ""
    read -p "Do you want to continue without assets? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    EMBED_ASSETS="OFF"
else
    ASSET_FILES=$(find assets -type f 2>/dev/null | wc -l)
    echo "Found $ASSET_FILES asset file(s) in assets folder"
    EMBED_ASSETS="ON"
fi

echo ""
echo "================================"
echo "Build Configuration"
echo "================================"
echo "Lua Embedding:    ON"
echo "Asset Embedding:  $EMBED_ASSETS"
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

# Detect executable name based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    EXE_NAME="ReiLua"
else
    EXE_NAME="ReiLua.exe"
fi

EXESIZE=$(du -h "$EXE_NAME" | cut -f1)
echo ""
echo "Executable: $EXE_NAME ($EXESIZE)"
echo "Location:   $(pwd)/$EXE_NAME"
echo ""
echo "Your game is ready for distribution!"
echo ""
echo "To test the release build:"
echo "  ./$EXE_NAME --log  (with console)"
echo "  ./$EXE_NAME        (production mode)"
echo ""
echo "To distribute:"
echo "  - Copy $EXE_NAME to your distribution folder"
echo "  - Rename it to your game name (optional)"
echo "  - That's it! Single file distribution!"
echo ""
