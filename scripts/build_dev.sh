#!/bin/bash
# ReiLua Development Build Script
# Run this from w64devkit shell

echo "================================"
echo "ReiLua - Development Build"
echo "================================"
echo ""

# Get the script directory and navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.." || exit 1

# Create and navigate to build directory
mkdir -p build
cd build || exit 1

# Clean old embedded files (important for dev builds!)
echo "Cleaning old embedded files..."
rm -f embedded_main.h embedded_assets.h

# Warn about Lua files in build directory
LUA_COUNT=$(ls *.lua 2>/dev/null | wc -l)
if [ "$LUA_COUNT" -gt 0 ]; then
    echo ""
    echo "WARNING: Found Lua files in build directory!"
    echo "Development builds should load from file system, not embed."
    echo ""
    ls -1 *.lua
    echo ""
    read -p "Remove these files from build directory? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        rm -f *.lua
        echo "Lua files removed."
    fi
    echo ""
fi

# Warn about assets folder in build directory
if [ -d "assets" ]; then
    echo ""
    echo "WARNING: Found assets folder in build directory!"
    echo "Development builds should load from file system, not embed."
    echo ""
    read -p "Remove assets folder from build directory? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        rm -rf assets
        echo "Assets folder removed."
    fi
    echo ""
fi

# Clean old configuration if requested
if [ "$1" == "clean" ]; then
    echo "Cleaning build directory..."
    rm -rf CMakeCache.txt CMakeFiles/ *.o *.a
    echo "Clean complete!"
    echo ""
fi

# Configure with MinGW
echo "Configuring CMake for development..."
cmake -G "MinGW Makefiles" ..

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

echo ""
echo "Building ReiLua..."
make

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Build failed!"
    exit 1
fi

echo ""
echo "================================"
echo "Build Complete!"
echo "================================"
echo ""
echo "Development build created successfully!"
echo ""
echo "To run your game:"
echo "  cd /path/to/your/game"
echo "  /path/to/ReiLua/build/ReiLua.exe"
echo ""
echo "To run with console logging:"
echo "  /path/to/ReiLua/build/ReiLua.exe --log"
echo ""
echo "Features:"
echo "  - Lua files load from file system"
echo "  - Assets load from file system"
echo "  - Fast iteration - edit and reload"
echo ""
