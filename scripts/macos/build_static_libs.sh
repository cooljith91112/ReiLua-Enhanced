#!/bin/bash
# Build static raylib and lua libraries for macOS
# This creates static libraries that can be linked into ReiLua for distribution

set -e  # Exit on error

echo "========================================"
echo "Building Static Libraries for macOS"
echo "========================================"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."
cd "$PROJECT_ROOT"

# Use source directories relative to project root (one level up, then into folders)
LUA_SRC="$(cd "$PROJECT_ROOT/.." && pwd)/lua"
RAYLIB_SRC="$(cd "$PROJECT_ROOT/.." && pwd)/raylib"

# Check for required tools
if ! command -v cmake &> /dev/null; then
    echo "ERROR: cmake is required but not installed."
    echo "Install with: brew install cmake"
    exit 1
fi

# Check that source directories exist
if [ ! -d "$LUA_SRC" ]; then
    echo "ERROR: Lua source not found at: $LUA_SRC"
    echo ""
    echo "Expected directory structure:"
    echo "  /path/to/tools/"
    echo "    ├── ReiLua-Enhanced/  (this project)"
    echo "    ├── lua/              (Lua source)"
    echo "    └── raylib/           (Raylib source)"
    echo ""
    exit 1
fi

if [ ! -d "$RAYLIB_SRC" ]; then
    echo "ERROR: Raylib source not found at: $RAYLIB_SRC"
    echo ""
    echo "Expected directory structure:"
    echo "  /path/to/tools/"
    echo "    ├── ReiLua-Enhanced/  (this project)"
    echo "    ├── lua/              (Lua source)"
    echo "    └── raylib/           (Raylib source)"
    echo ""
    exit 1
fi

echo "Using existing sources:"
echo "  Lua:    $LUA_SRC"
echo "  Raylib: $RAYLIB_SRC"
echo ""

# Create lib/macos directory
mkdir -p "$PROJECT_ROOT/lib/macos"

# Build Lua
echo "========================================"
echo "Building Lua 5.4 (static)"
echo "========================================"
echo ""

cd "$LUA_SRC"
echo "Compiling Lua..."

# Clean previous build
make clean || true

# Compile Lua core files
CFLAGS="-O2 -Wall -DLUA_USE_MACOSX -DLUA_USE_DLOPEN"
OBJS=""

for file in lapi lcode lctype ldebug ldo ldump lfunc lgc llex lmem lobject lopcodes lparser lstate lstring ltable ltm lundump lvm lzio lauxlib lbaselib ldblib liolib lmathlib loslib ltablib lstrlib lutf8lib loadlib lcorolib linit; do
    echo "  Compiling ${file}.c..."
    cc $CFLAGS -c ${file}.c -o ${file}.o
    OBJS="$OBJS ${file}.o"
done

# Create static library
echo "Creating static library..."
ar rcs liblua.a $OBJS

# Copy to lib directory
echo "Installing Lua static library..."
cp liblua.a "$PROJECT_ROOT/lib/macos/"
LUASIZE=$(du -h "$PROJECT_ROOT/lib/macos/liblua.a" | cut -f1)
echo "✓ Lua static library: lib/macos/liblua.a ($LUASIZE)"
echo ""

# Build Raylib
echo "========================================"
echo "Building Raylib 5.5 (static)"
echo "========================================"
echo ""

cd "$RAYLIB_SRC"
rm -rf build_static
mkdir -p build_static
cd build_static

echo "Configuring Raylib..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DUSE_EXTERNAL_GLFW=OFF \
    -DCUSTOMIZE_BUILD=ON

echo "Compiling Raylib..."
make -j$(sysctl -n hw.ncpu)

# Copy to lib directory
echo "Installing Raylib static library..."
cp raylib/libraylib.a "$PROJECT_ROOT/lib/macos/"
RAYLIBSIZE=$(du -h "$PROJECT_ROOT/lib/macos/libraylib.a" | cut -f1)
echo "✓ Raylib static library: lib/macos/libraylib.a ($RAYLIBSIZE)"
echo ""

cd "$PROJECT_ROOT"

# Verify libraries
echo "========================================"
echo "Verification"
echo "========================================"
echo ""
ls -lh lib/macos/*.a
echo ""
file lib/macos/liblua.a
file lib/macos/libraylib.a
echo ""

echo "========================================"
echo "Success! Static libraries built."
echo "========================================"
echo ""
echo "Libraries created in: lib/macos/"
echo "  - liblua.a ($LUASIZE)"
echo "  - libraylib.a ($RAYLIBSIZE)"
echo ""
echo "You can now build ReiLua with static linking."
echo "Run: ./scripts/build_dev.sh"
echo ""
echo "This will create a single-file executable that"
echo "doesn't require users to install raylib or lua!"
echo ""
