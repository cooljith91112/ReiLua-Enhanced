#!/bin/bash
# ReiLua-Enhanced Project Setup Script
# Creates a new game project with custom metadata

set -e

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║              ReiLua-Enhanced - Project Setup Wizard               ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Get script directory (ReiLua-Enhanced root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Function to validate alphanumeric input
validate_alphanumeric() {
    if [[ ! "$1" =~ ^[a-zA-Z0-9]+$ ]]; then
        return 1
    fi
    return 0
}

# Get project information
echo "Please provide your project information:"
echo "=========================================="
echo ""

# Project Name
while true; do
    read -p "Project Name (alphanumeric only, e.g., MyAwesomeGame): " PROJECT_NAME
    if validate_alphanumeric "$PROJECT_NAME"; then
        break
    else
        echo "❌ Invalid! Use only letters and numbers (no spaces or symbols)."
    fi
done

# Executable Name
read -p "Executable Name (default: $PROJECT_NAME): " EXECUTABLE_NAME
EXECUTABLE_NAME=${EXECUTABLE_NAME:-$PROJECT_NAME}

# Author Name
read -p "Author Name: " AUTHOR_NAME
if [ -z "$AUTHOR_NAME" ]; then
    AUTHOR_NAME="Unknown Author"
fi

# Author Email
read -p "Author Email: " AUTHOR_EMAIL
if [ -z "$AUTHOR_EMAIL" ]; then
    AUTHOR_EMAIL="author@example.com"
fi

# Description
read -p "Project Description: " DESCRIPTION
if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION="A game made with ReiLua"
fi

# Company/Organization (for bundle identifier)
read -p "Company/Organization (for bundle ID, default: reilua): " COMPANY
COMPANY=${COMPANY:-reilua}

# Convert to lowercase and remove spaces for bundle ID
BUNDLE_ID=$(echo "${COMPANY}.${PROJECT_NAME}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

# Version
read -p "Version (default: 1.0.0): " VERSION
VERSION=${VERSION:-1.0.0}

echo ""
echo "=========================================="
echo "Project Summary:"
echo "=========================================="
echo "Project Name:     $PROJECT_NAME"
echo "Executable:       $EXECUTABLE_NAME"
echo "Author:           $AUTHOR_NAME"
echo "Email:            $AUTHOR_EMAIL"
echo "Description:      $DESCRIPTION"
echo "Bundle ID:        $BUNDLE_ID"
echo "Version:          $VERSION"
echo "=========================================="
echo ""

read -p "Create project with these settings? (Y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Create project directory
PROJECTS_ROOT="$SCRIPT_DIR/../projects"
mkdir -p "$PROJECTS_ROOT"

PROJECT_DIR="$PROJECTS_ROOT/${PROJECT_NAME}"

if [ -d "$PROJECT_DIR" ]; then
    echo ""
    echo "❌ ERROR: Directory 'projects/$PROJECT_NAME' already exists!"
    read -p "Delete it and continue? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
    else
        echo "Setup cancelled."
        exit 1
    fi
fi

echo ""
echo "Creating project directory: projects/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"

# Copy ReiLua structure
echo "Copying ReiLua-Enhanced files..."

# Create directory structure first
mkdir -p "$PROJECT_DIR"/{src,include,lib,scripts/macos,fonts,logo,cmake,game}

# Copy files using find to preserve structure, excluding unnecessary files
(cd "$SCRIPT_DIR/.." && \
 find . -type f \
    ! -path './build/*' \
    ! -path './deps/*' \
    ! -path './.git/*' \
    ! -path './projects/*' \
    ! -path './docs/*' \
    ! -path './docs_md/*' \
    ! -path './examples/*' \
    ! -path './template/*' \
    ! -path './tools/*' \
    ! -name '*.app' \
    ! -name '*.dmg' \
    ! -name '*.zip' \
    ! -name '*.o' \
    ! -name '*.md' \
    ! -name 'changelog' \
    ! -name 'devnotes' \
    ! -name 'logo.png' \
    ! -name 'LICENSE' \
    ! -name 'zed.sample.settings.json' \
    ! -name 'create_project.sh' \
    -exec sh -c 'mkdir -p "$0/$(dirname "{}")" && cp "{}" "$0/{}"' "$PROJECT_DIR" \;)

echo "✓ Files copied (essentials only: src, lib, scripts, assets)"
echo ""
echo "Setting up project files..."

# Get absolute paths for lua and raylib (sibling to ReiLua-Enhanced)
LUA_PATH="$(cd "$SCRIPT_DIR/.." && pwd)/lua"
RAYLIB_PATH="$(cd "$SCRIPT_DIR/.." && pwd)/raylib"

# Update build_static_libs.sh with correct paths
if [ -f "$PROJECT_DIR/scripts/macos/build_static_libs.sh" ]; then
    cat > "$PROJECT_DIR/scripts/macos/build_static_libs.sh" << 'EOFSCRIPT'
#!/bin/bash
# Build static raylib and lua libraries for macOS

set -e

echo "========================================"
echo "Building Static Libraries for macOS"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."
cd "$PROJECT_ROOT"

# Look for lua and raylib as siblings to this project
LUA_SRC="$(cd "$PROJECT_ROOT/.." && pwd)/lua"
RAYLIB_SRC="$(cd "$PROJECT_ROOT/.." && pwd)/raylib"

if [ ! -d "$LUA_SRC" ]; then
    echo "ERROR: Lua source not found at: $LUA_SRC"
    echo ""
    echo "Expected: ../lua relative to project"
    exit 1
fi

if [ ! -d "$RAYLIB_SRC" ]; then
    echo "ERROR: Raylib source not found at: $RAYLIB_SRC"
    echo ""
    echo "Expected: ../raylib relative to project"
    exit 1
fi

echo "Using sources:"
echo "  Lua:    $LUA_SRC"
echo "  Raylib: $RAYLIB_SRC"
echo ""

mkdir -p "$PROJECT_ROOT/lib/macos"

# Build Lua
echo "========================================"
echo "Building Lua 5.4 (static)"
echo "========================================"
cd "$LUA_SRC"
make clean || true

CFLAGS="-O2 -Wall -DLUA_USE_MACOSX -DLUA_USE_DLOPEN"
OBJS=""
for file in lapi lcode lctype ldebug ldo ldump lfunc lgc llex lmem lobject lopcodes lparser lstate lstring ltable ltm lundump lvm lzio lauxlib lbaselib ldblib liolib lmathlib loslib ltablib lstrlib lutf8lib loadlib lcorolib linit; do
    cc $CFLAGS -c ${file}.c -o ${file}.o
    OBJS="$OBJS ${file}.o"
done
ar rcs liblua.a $OBJS
cp liblua.a "$PROJECT_ROOT/lib/macos/"
LUASIZE=$(du -h "$PROJECT_ROOT/lib/macos/liblua.a" | cut -f1)
echo "✓ Lua: $LUASIZE"

# Build Raylib
echo ""
echo "========================================"
echo "Building Raylib 5.5 (static)"
echo "========================================"
cd "$RAYLIB_SRC"
rm -rf build_static
mkdir -p build_static && cd build_static
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_EXAMPLES=OFF -DUSE_EXTERNAL_GLFW=OFF -DCUSTOMIZE_BUILD=ON
make -j$(sysctl -n hw.ncpu)
cp raylib/libraylib.a "$PROJECT_ROOT/lib/macos/"
RAYLIBSIZE=$(du -h "$PROJECT_ROOT/lib/macos/libraylib.a" | cut -f1)
echo "✓ Raylib: $RAYLIBSIZE"

echo ""
echo "Static libraries ready in lib/macos/"
EOFSCRIPT
    chmod +x "$PROJECT_DIR/scripts/macos/build_static_libs.sh"
fi

# Create custom resources.rc for Windows
cat > "$PROJECT_DIR/resources.rc" << EOFRC
IDI_ICON1 ICON "icon.ico"

1 VERSIONINFO
FILEVERSION ${VERSION//./,},0
PRODUCTVERSION ${VERSION//./,},0
FILEFLAGSMASK 0x3fL
FILEFLAGS 0x0L
FILEOS 0x40004L
FILETYPE 0x1L
FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "CompanyName", "$AUTHOR_NAME"
            VALUE "FileDescription", "$DESCRIPTION"
            VALUE "FileVersion", "$VERSION"
            VALUE "InternalName", "$EXECUTABLE_NAME"
            VALUE "LegalCopyright", "Copyright (C) $AUTHOR_NAME, $(date +%Y)"
            VALUE "OriginalFilename", "${EXECUTABLE_NAME}.exe"
            VALUE "ProductName", "$PROJECT_NAME"
            VALUE "ProductVersion", "$VERSION"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1200
    END
END
EOFRC

# Create updated create_app_bundle.sh for macOS
cat > "$PROJECT_DIR/scripts/macos/create_app_bundle.sh" << 'EOFBUNDLE'
#!/bin/bash
# Create macOS App Bundle with Icon and Metadata

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."
cd "$PROJECT_ROOT"

# Read project metadata
PROJECT_NAME="__PROJECT_NAME__"
EXECUTABLE_NAME="__EXECUTABLE_NAME__"
BUNDLE_ID="__BUNDLE_ID__"
VERSION="__VERSION__"
AUTHOR_NAME="__AUTHOR_NAME__"
DESCRIPTION="__DESCRIPTION__"

if [ ! -f "build/$EXECUTABLE_NAME" ]; then
    echo "ERROR: Game executable not found! Build first."
    exit 1
fi

APP_NAME="${1:-$EXECUTABLE_NAME}"
APP_BUNDLE="${APP_NAME}.app"

echo "Creating $APP_BUNDLE..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp build/$EXECUTABLE_NAME "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Convert icon
ICNS_FILE="$APP_BUNDLE/Contents/Resources/icon.icns"
if [ -f "icon.ico" ]; then
    mkdir -p icon.iconset
    sips -s format png icon.ico --out icon.iconset/icon_512x512.png -z 512 512 2>/dev/null || true
    if [ -f "icon.iconset/icon_512x512.png" ]; then
        sips -z 256 256 icon.iconset/icon_512x512.png --out icon.iconset/icon_256x256.png
        sips -z 128 128 icon.iconset/icon_512x512.png --out icon.iconset/icon_128x128.png
        sips -z 64 64   icon.iconset/icon_512x512.png --out icon.iconset/icon_64x64.png
        sips -z 32 32   icon.iconset/icon_512x512.png --out icon.iconset/icon_32x32.png
        sips -z 16 16   icon.iconset/icon_512x512.png --out icon.iconset/icon_16x16.png
        cp icon.iconset/icon_512x512.png icon.iconset/icon_256x256@2x.png
        cp icon.iconset/icon_256x256.png icon.iconset/icon_128x128@2x.png
        cp icon.iconset/icon_128x128.png icon.iconset/icon_64x64@2x.png
        cp icon.iconset/icon_64x64.png   icon.iconset/icon_32x32@2x.png
        cp icon.iconset/icon_32x32.png   icon.iconset/icon_16x16@2x.png
        iconutil -c icns icon.iconset -o "$ICNS_FILE"
    fi
    rm -rf icon.iconset
fi

# Create Info.plist with project metadata
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$PROJECT_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$PROJECT_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © $(date +%Y) $AUTHOR_NAME. All rights reserved.</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✓ $APP_BUNDLE created!"
echo "  open $APP_BUNDLE"
EOFBUNDLE

# Replace placeholders in create_app_bundle.sh
if [ -f "$PROJECT_DIR/scripts/macos/create_app_bundle.sh" ]; then
    # Use direct sed replacement for macOS (creates backup with different approach)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i '' "s/__EXECUTABLE_NAME__/$EXECUTABLE_NAME/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i '' "s/__BUNDLE_ID__/$BUNDLE_ID/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i '' "s/__VERSION__/$VERSION/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i '' "s/__AUTHOR_NAME__/$AUTHOR_NAME/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i '' "s/__DESCRIPTION__/$DESCRIPTION/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
    else
        # Linux/Windows Git Bash
        sed -i "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i "s/__EXECUTABLE_NAME__/$EXECUTABLE_NAME/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i "s/__BUNDLE_ID__/$BUNDLE_ID/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i "s/__VERSION__/$VERSION/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i "s/__AUTHOR_NAME__/$AUTHOR_NAME/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
        sed -i "s/__DESCRIPTION__/$DESCRIPTION/g" "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
    fi
    chmod +x "$PROJECT_DIR/scripts/macos/create_app_bundle.sh"
fi

# Create project metadata file
cat > "$PROJECT_DIR/project.info" << EOFINFO
# Project Information
PROJECT_NAME=$PROJECT_NAME
EXECUTABLE_NAME=$EXECUTABLE_NAME
AUTHOR_NAME=$AUTHOR_NAME
AUTHOR_EMAIL=$AUTHOR_EMAIL
DESCRIPTION=$DESCRIPTION
BUNDLE_ID=$BUNDLE_ID
VERSION=$VERSION
COMPANY=$COMPANY
CREATED=$(date +%Y-%m-%d)
EOFINFO

# Create README for the project
cat > "$PROJECT_DIR/README.md" << EOFREADME
# $PROJECT_NAME

$DESCRIPTION

## Project Information

- **Author:** $AUTHOR_NAME <$AUTHOR_EMAIL>
- **Version:** $VERSION
- **Created:** $(date +%Y-%m-%d)
- **Built with:** ReiLua-Enhanced

## Project Structure

\`\`\`
$PROJECT_NAME/
├── game/              # Your game files (edit here!)
│   ├── main.lua       # Game entry point
│   └── assets/        # Game assets
├── build/             # Build output (auto-generated)
├── scripts/           # Build scripts
├── src/               # ReiLua C source
├── include/           # Headers
└── lib/               # Static libraries
\`\`\`

**Important:** All your game development happens in the \`game/\` folder!

## Development Workflow

### 1. Edit Your Game

All your game files go in the \`game/\` folder:

\`\`\`
game/
├── main.lua           # Your game code
├── player.lua         # Game modules
├── enemy.lua
└── assets/
    ├── sprites/
    │   ├── player.png
    │   └── enemy.png
    └── sounds/
        └── music.wav
\`\`\`

### 2. Build for Development

\`\`\`bash
./scripts/build_dev.sh
\`\`\`

### 3. Run Your Game

From project root, ReiLua will automatically load from \`game/\` folder:

\`\`\`bash
./build/ReiLua --no-logo --log
\`\`\`

The engine checks paths in this order:
1. \`game/main.lua\` (if game folder exists)
2. \`main.lua\` (current directory)
3. Embedded files (release builds)

### 4. Release Build

Release build automatically copies from \`game/\` folder:

\`\`\`bash
./scripts/build_release.sh
\`\`\`

This will:
- Copy all \`.lua\` files from \`game/\` to \`build/\`
- Copy \`game/assets/\` to \`build/assets/\`
- Embed everything into the executable

## Game Development

Edit \`game/main.lua\`:

\`\`\`lua
function RL.init()
    -- Load your assets
    player = RL.LoadTexture("assets/sprites/player.png")
end

function RL.update(delta)
    -- Update game logic
end

function RL.draw()
    -- Draw your game
    RL.ClearBackground(RL.RAYWHITE)
    RL.DrawTexture(player, 100, 100, RL.WHITE)
end
\`\`\`

## Distribution

### Windows
\`\`\`bash
# After build_release.sh
# The executable is: build/${EXECUTABLE_NAME}.exe
\`\`\`

### macOS
\`\`\`bash
# Create app bundle
./scripts/macos/create_app_bundle.sh

# Create DMG for distribution
hdiutil create -volname '$PROJECT_NAME' \\
    -srcfolder '${EXECUTABLE_NAME}.app' \\
    -ov -format UDZO ${EXECUTABLE_NAME}.dmg
\`\`\`

### Linux
\`\`\`bash
# After build_release.sh
# The executable is: build/ReiLua (rename to ${EXECUTABLE_NAME})
\`\`\`

## Why the game/ Folder?

The \`game/\` folder keeps your work organized and safe:

- **Separation:** Your game files stay separate from build artifacts
- **Safety:** Rebuilding won't delete your game files
- **Clarity:** Anyone can see where the game code lives
- **Automation:** Release builds auto-copy from game/ folder

## Editor Setup

This project includes configurations for:
- **Lua Language Server** (\`.luarc.json\`) - Autocomplete and type checking
- **Zed Editor** (\`.zed/settings.json\`) - LSP configuration
- **Zed Tasks** (\`.zed/tasks.json\`) - Build and run commands

Open the project in Zed and use \`Cmd+Shift+P\` → "Run Task" to build and run.

## License

Add your license information here.

---

Built with [ReiLua-Enhanced](https://github.com/nullstare/ReiLua)
EOFREADME

# Create example main.lua
cat > "$PROJECT_DIR/game/main.lua" << EOFLUA
-- $PROJECT_NAME
-- $DESCRIPTION
-- Author: $AUTHOR_NAME

function RL.init()
    RL.SetWindowTitle( "$PROJECT_NAME" )
    RL.SetWindowState( RL.FLAG_VSYNC_HINT )

    print("$PROJECT_NAME initialized!")
    print("Version: $VERSION")
    print("Author: $AUTHOR_NAME")
end

function RL.update( delta )
    -- Game logic goes here
    -- delta is time since last frame in seconds

    if RL.IsKeyPressed( RL.KEY_ESCAPE ) then
        RL.CloseWindow()
    end
end

function RL.draw()
    RL.ClearBackground( RL.RAYWHITE )

    RL.DrawText( "$PROJECT_NAME", { 10, 10 }, 40, RL.BLACK )
    RL.DrawText( "Press ESC to exit", { 10, 60 }, 20, RL.DARKGRAY )
end
EOFLUA

# Create assets directory in game folder
mkdir -p "$PROJECT_DIR/game/assets"
cat > "$PROJECT_DIR/game/assets/.gitkeep" << EOFKEEP
# Game assets folder
# Place your game assets here:
# - Images (.png, .jpg)
# - Sounds (.wav, .ogg, .mp3)
# - Fonts (.ttf)
# - Other resources
EOFKEEP

# Copy ReiLua API definitions for LSP to game folder
echo "Setting up game folder for development..."
if [ -f "$SCRIPT_DIR/../tools/ReiLua_API.lua" ]; then
    cp "$SCRIPT_DIR/../tools/ReiLua_API.lua" "$PROJECT_DIR/game/"
    echo "  ✓ game/ReiLua_API.lua"
fi

# Create .luarc.json for Lua Language Server in game folder
cat > "$PROJECT_DIR/game/.luarc.json" << EOFLUARC
{
  "runtime.version": "Lua 5.4",
  "completion.enable": true,
  "completion.callSnippet": "Replace",
  "completion.displayContext": 3,
  "diagnostics.globals": ["RL"],
  "diagnostics.disable": [
    "lowercase-global",
    "unused-local",
    "duplicate-set-field",
    "missing-fields",
    "undefined-field"
  ],
  "workspace.checkThirdParty": false,
  "workspace.library": ["ReiLua_API.lua"],
  "hint.enable": true,
  "hint.paramName": "All",
  "hint.setType": true,
  "hint.paramType": true
}
EOFLUARC

echo "  ✓ game/.luarc.json"

# Create Zed editor configuration in project root
echo "Setting up Zed editor configuration..."
mkdir -p "$PROJECT_DIR/.zed"
mkdir -p "$PROJECT_DIR/scripts/run"

# Create run scripts for tasks (cross-platform)
cat > "$PROJECT_DIR/scripts/run/run_dev.sh" << 'EOFRUNDEV'
#!/bin/bash
cd "$(dirname "$0")/../.."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    EXE=$(grep EXECUTABLE_NAME= project.info | cut -d= -f2)
    ./build/${EXE}.exe --no-logo --log
else
    EXE=$(grep EXECUTABLE_NAME= project.info | cut -d= -f2)
    ./build/$EXE --no-logo --log
fi
EOFRUNDEV
chmod +x "$PROJECT_DIR/scripts/run/run_dev.sh"

cat > "$PROJECT_DIR/scripts/run/run_no_splash.sh" << 'EOFRUNNOSPLASH'
#!/bin/bash
cd "$(dirname "$0")/../.."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    EXE=$(grep EXECUTABLE_NAME= project.info | cut -d= -f2)
    ./build/${EXE}.exe --no-logo
else
    EXE=$(grep EXECUTABLE_NAME= project.info | cut -d= -f2)
    ./build/$EXE --no-logo
fi
EOFRUNNOSPLASH
chmod +x "$PROJECT_DIR/scripts/run/run_no_splash.sh"

cat > "$PROJECT_DIR/scripts/run/run_release.sh" << 'EOFRUNRELEASE'
#!/bin/bash
cd "$(dirname "$0")/../.."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    EXE=$(grep EXECUTABLE_NAME= project.info | cut -d= -f2)
    ./build/${EXE}.exe
else
    EXE=$(grep EXECUTABLE_NAME= project.info | cut -d= -f2)
    ./build/$EXE
fi
EOFRUNRELEASE
chmod +x "$PROJECT_DIR/scripts/run/run_release.sh"

cat > "$PROJECT_DIR/.zed/settings.json" << EOFZED
{
  "inlay_hints": {
    "enabled": true
  },
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.runtime.version": "Lua 5.4",
        "Lua.workspace.library": [
          "game/ReiLua_API.lua"
        ],
        "Lua.completion.enable": true,
        "Lua.completion.callSnippet": "Replace",
        "Lua.completion.displayContext": 3,
        "Lua.diagnostics.globals": [
          "RL"
        ],
        "Lua.hint.enable": true,
        "Lua.hint.paramName": "All",
        "Lua.hint.setType": true,
        "Lua.hint.paramType": true,
        "Lua.diagnostics.disable": [
          "lowercase-global",
          "unused-local",
          "duplicate-set-field",
          "missing-fields",
          "undefined-field"
        ]
      }
    }
  }
}
EOFZED

cat > "$PROJECT_DIR/.zed/tasks.json" << EOFTASKS
[
  {
    "label": "Run Game (Dev)",
    "command": "./scripts/run/run_dev.sh",
    "args": [],
    "use_new_terminal": true
  },
  {
    "label": "Run Game (No Splash)",
    "command": "./scripts/run/run_no_splash.sh",
    "args": [],
    "use_new_terminal": true
  },
  {
    "label": "Run Game (Release)",
    "command": "./scripts/run/run_release.sh",
    "args": [],
    "use_new_terminal": true
  },
  {
    "label": "Build Dev",
    "command": "./scripts/build_dev.sh",
    "args": [],
    "use_new_terminal": true
  },
  {
    "label": "Build Release",
    "command": "./scripts/build_release.sh",
    "args": [],
    "use_new_terminal": true
  }
]
EOFTASKS

echo "  ✓ .zed/settings.json"
echo "  ✓ .zed/tasks.json"

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║                    ✅ Project Setup Complete! ✅                  ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Project Details:"
echo "  Name:       $PROJECT_NAME"
echo "  Location:   projects/$PROJECT_NAME"
echo "  Executable: $EXECUTABLE_NAME"
echo "  Author:     $AUTHOR_NAME"
echo ""
echo "Next Steps:"
echo "  1. cd projects/$PROJECT_NAME"
echo "  2. Edit game/main.lua (your game code)"
echo "  3. Add assets to game/assets/ folder"
echo "  4. Build: ./scripts/build_dev.sh"
echo "  5. Run: ./build/ReiLua"
echo ""
echo "Files Created:"
echo "  ✓ game/main.lua - Game entry point"
echo "  ✓ game/assets/ - Asset directory"
echo "  ✓ game/ReiLua_API.lua - API definitions for LSP"
echo "  ✓ game/.luarc.json - Lua Language Server config"
echo "  ✓ .zed/settings.json - Zed editor config"
echo "  ✓ .zed/tasks.json - Build and run tasks"
echo "  ✓ project.info - Project metadata"
echo "  ✓ README.md - Project documentation"
echo "  ✓ resources.rc - Windows metadata (embedded in .exe)"
echo "  ✓ scripts/macos/create_app_bundle.sh - macOS bundle with metadata"
echo ""
echo "Build Scripts Updated:"
echo "  ✓ Lua path:    ../lua (sibling directory)"
echo "  ✓ Raylib path: ../raylib (sibling directory)"
echo ""
echo "All projects are in: projects/ folder"
echo "Happy game development! 🎮"
echo ""
