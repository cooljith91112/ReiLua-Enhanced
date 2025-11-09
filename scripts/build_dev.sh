#!/bin/bash
# ReiLua Development Build Script
# Works on Windows (w64devkit) and macOS

echo "================================"
echo "ReiLua - Development Build"
echo "================================"
echo ""

# Get the script directory and navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.." || exit 1

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

# Configure
echo "Configuring CMake for development (${OSTYPE})..."
cmake -G "$CMAKE_GENERATOR" ..

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

echo ""
echo "Building ReiLua..."
$BUILD_CMD

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

# Detect executable name based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    EXE_NAME="ReiLua"
else
    EXE_NAME="ReiLua.exe"
fi

echo "To run your game:"
echo "  cd /path/to/your/game"
echo "  /path/to/ReiLua/build/$EXE_NAME"
echo ""
echo "To run with console logging:"
echo "  /path/to/ReiLua/build/$EXE_NAME --log"
echo ""
echo "Features:"
echo "  - Lua files load from file system"
echo "  - Assets load from file system"
echo "  - Fast iteration - edit and reload"
echo ""
