#!/bin/bash
# ReiLua Release Build Script
# Run this from w64devkit shell

echo "================================"
echo "ReiLua - Release Build"
echo "================================"
echo ""

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERROR: Please run this script from the ReiLua root directory"
    exit 1
fi

# Navigate to build directory
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

# Configure with embedding enabled
echo ""
echo "Configuring CMake for release..."
cmake -G "MinGW Makefiles" .. -DEMBED_MAIN=ON -DEMBED_ASSETS=$EMBED_ASSETS -DCMAKE_BUILD_TYPE=Release

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

# Build
echo ""
echo "Building ReiLua Release..."
make

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
EXESIZE=$(du -h ReiLua.exe | cut -f1)
echo ""
echo "Executable: ReiLua.exe ($EXESIZE)"
echo "Location:   $(pwd)/ReiLua.exe"
echo ""
echo "Your game is ready for distribution!"
echo ""
echo "To test the release build:"
echo "  ./ReiLua.exe --log  (with console)"
echo "  ./ReiLua.exe        (production mode)"
echo ""
echo "To distribute:"
echo "  - Copy ReiLua.exe to your distribution folder"
echo "  - Rename it to your game name (optional)"
echo "  - That's it! Single file distribution!"
echo ""
