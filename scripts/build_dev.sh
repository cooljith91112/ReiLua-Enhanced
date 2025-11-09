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

# ALWAYS clean build folder for fresh build
echo "Cleaning build directory for fresh build..."
rm -rf ./* 2>/dev/null
echo "✓ Build directory cleaned"
echo ""

# Clean old configuration if requested
if [ "$1" == "clean" ]; then
    echo "Extra clean flag detected (already cleaned)"
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
