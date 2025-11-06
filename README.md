![ReiLua logo](logo.png)

# ReiLua - Enhanced Edition

> **A modified version of ReiLua with embedded main.lua, embedded assets, splash screens, and asset loading system**

## About This Version

This is an enhanced version of ReiLua featuring:
- **Embedded Lua Support** - Bundle all your Lua code into a single executable
- **Embedded Assets** - Package images, sounds, and other assets into your game
- **Splash Screens** - Customizable startup screens featuring Raylib and ReiLua
- **Asset Loading System** - Loading screen with progress tracking
- **Automated Build Scripts** - One-command development and release builds
- **Console Control** - Debug logging system for development

## What is ReiLua?

ReiLua brings the power and simplicity of Raylib to the beginner-friendly Lua language in a straightforward manner. It is a loose binding to Raylib - some functions are excluded and some are added. The concept of pointing to a "main.lua" file and accessing functions "init", "update", and "draw" is borrowed from the Löve game framework.

**Note:** ReiLua is lovingly  handcrafted and will likely contain bugs and documentation errors, so it would be much appreciated if you would report any such findings.

**Reilua** means "fair" in Finnish.

## Attributions

This enhanced version is built upon:

### Core Framework
- **[Raylib](https://github.com/raysan5/raylib)** (v5.5) - A simple and easy-to-use library to enjoy videogames programming
  - Created by Ray(Ramon Santamaria) ([@raysan5](https://github.com/raysan5))
  - Licensed under the zlib/libpng license
- **[ReiLua](https://github.com/nullstare/ReiLua)** - The original Lua bindings for Raylib
  - Created by Jussi Viitala
  - Licensed under the MIT license
- **[Lua](https://www.lua.org/)** (v5.4) - Powerful, efficient, lightweight, embeddable scripting language

### Enhancements Added
- Embedded Lua and asset support system
- Splash screen implementation
- Asset loading progress API with retro UI
- Build automation scripts
- Console control system
- Comprehensive documentation

### Additional Components
- **Raygui** - Immediate mode GUI library
- **Raymath** - Math utilities for game development
- **Lights** - 3D lighting system
- **Easings** - Easing functions for smooth animations
- **RLGL** - OpenGL abstraction layer

### Font
- **Oleaguid** - Custom pixel art font for splash and loading screens

## Status

ReiLua is WIP and some planned raylib functionality is still missing, but it already has over 1000 functions. Current Raylib version is 5.5.

### Included Submodules
* Raygui
* Raymath
* Lights
* Easings
* RLGL

### Missing Features
List of some MISSING features that are planned to be included:
* Core
	* VR stereo config functions for VR simulator

## Roadmap

* v0.9
	* Stability improvements
	* Additional raylib bindings
* v1.0
	* raylib 6.0 support

## Quick Start

### For Game Developers

Development Mode (Fast Iteration):

```bash
# 1. Create your game files
GameFolder/
├── main.lua
├── assets/
│   ├── player.png
│   └── music.wav

# 2. Run ReiLua pointing to your game folder
ReiLua.exe GameFolder/

# Or from your game folder
cd GameFolder
path/to/ReiLua.exe

# Skip splash screens during development
ReiLua.exe --no-logo

# Enable console for debugging
ReiLua.exe --log --no-logo
```

Release Mode (Single Executable):

```bash
# See "Building for Release" section below
```

### Basic Example

Create a `main.lua` file:

```lua
local textColor = RL.BLACK
local textPos = { 192, 200 }
local textSize = 20
local text = "Congrats! You created your first window!"

function RL.init()
	RL.SetWindowTitle( "First window" )
	RL.SetWindowState( RL.FLAG_VSYNC_HINT )
end

function RL.update( delta )
	if RL.IsKeyPressed( RL.KEY_ENTER ) then
		local winSize = RL.GetScreenSize()
		local measuredSize = RL.MeasureTextEx( RL.GetFontDefault(), text, textSize, 2 )

		textColor = RL.BLUE
		textPos = { winSize[1] / 2 - measuredSize[1] / 2, winSize[2] / 2 - measuredSize[2] / 2 }
	end

	if RL.IsKeyPressed( RL.KEY_SPACE ) then
		textColor = RL.RED
		textPos = { 192, 200 }
	end
end

function RL.draw()
	RL.ClearBackground( RL.RAYWHITE )
	RL.DrawText( text, textPos, textSize, textColor )
end
```

Run it:
```bash
ReiLua.exe --no-logo
```

## Framework Functions

ReiLua looks for a 'main.lua' or 'main' file as the entry point. There are seven Lua functions that the framework will call:

- **`RL.init()`** - Called once at startup for initialization
- **`RL.update(delta)`** - Called every frame before draw, receives delta time
- **`RL.draw()`** - Called every frame for rendering
- **`RL.event(event)`** - Called when events occur
- **`RL.log(logLevel, message)`** - Called for logging
- **`RL.exit()`** - Called when the application is closing
- **`RL.config()`** - ⚠️ Deprecated in this version

All functionality can be found in "API.md".

## Enhanced Features

### 1. Splash Screens

This version includes customizable splash screens that display at startup:

**Screen 1:** Custom text - Bold text on Raylib red background (customizable)
**Screen 2:** "Made using" - Displays Raylib and ReiLua logos side-by-side

Each screen fades in (0.8s), displays (2.5s), and fades out (0.8s) for a total of ~8 seconds.

Skip During Development:
```bash
ReiLua.exe --no-logo
```

Customize:
- Change text in `src/splash.c`
- Replace logos in `logo/` folder
- Adjust timing with constants in `src/splash.c`

See [SPLASH_SCREENS.md](SPLASH_SCREENS.md) for full documentation.

### 2. Asset Loading System

Beautiful loading screen with progress tracking:

```lua
function RL.init()
    -- List your assets
    local assets = {
        "assets/player.png",
        "assets/enemy.png",
        "assets/background.png",
        "assets/music.wav",
    }

    -- Start loading with progress
    RL.BeginAssetLoading(#assets)

    -- Load each asset
    for i, path in ipairs(assets) do
        RL.UpdateAssetLoading(path)

        -- Your loading code
        if path:match("%.png$") then
            textures[i] = RL.LoadTexture(path)
        elseif path:match("%.wav$") then
            sounds[i] = RL.LoadSound(path)
        end
    end

    -- Finish loading
    RL.EndAssetLoading()
end
```

Features:
- Retro 1-bit pixel art aesthetic
- Animated loading text with dots
- Progress bar with dithering pattern
- Shows current asset name
- Progress counter (e.g., "3/10")
- Corner decorations

See [ASSET_LOADING.md](ASSET_LOADING.md) for full documentation.

### 3. Embedded Lua Files

Bundle all your Lua code into the executable for easy distribution:

```bash
# Copy Lua files to build directory
cd build
copy ..\your_game\*.lua .

# Build with embedding
cmake .. -DEMBED_MAIN=ON
cmake --build . --config Release
```

Result: Single executable with all Lua code embedded!

### 4. Embedded Assets

Package images, sounds, fonts, and other assets into your executable:

```bash
# Create assets folder and copy files
cd build
mkdir assets
copy ..\your_game\assets\* assets\

# Build with embedding
cmake .. -DEMBED_ASSETS=ON
cmake --build . --config Release
```

**Your Lua code doesn't change!** Use the same paths:
```lua
-- Works in both development and release
playerImg = RL.LoadTexture("assets/player.png")
music = RL.LoadSound("assets/music.wav")
```

See [EMBEDDING.md](EMBEDDING.md) for full documentation.

### 5. Console Control (Windows)

By default, ReiLua runs without a console window for a clean user experience. Enable it for debugging:

```bash
# Show console for debugging
ReiLua.exe --log

# Combine with other options
ReiLua.exe --log --no-logo
ReiLua.exe --log path/to/game
```

This shows:
- TraceLog output
- Print statements
- Lua errors
- Debug information

### 6. Automated Build Scripts

One-command builds for development and release:

Development Build (Fast Iteration):
```bash
# Windows
scripts\build_dev.bat

# Linux/Unix
chmod +x scripts/build_dev.sh
scripts/build_dev.sh
```
- No embedding
- Fast build times
- Edit code without rebuilding

Release Build (Distribution):
```bash
# Prepare files first
cd build
copy ..\your_game\*.lua .
mkdir assets
copy ..\your_game\assets\* assets\

# Build release
cd ..

# Windows
scripts\build_release.bat

# Linux/Unix
scripts/build_release.sh
```
- Embeds all Lua files
- Embeds all assets
- Creates single executable
- Release optimizations

See [BUILD_SCRIPTS.md](BUILD_SCRIPTS.md) for full documentation.

## Command Line Options

```
ReiLua [Options] [Directory to main.lua or main]

Options:
  -h, --help       Show help message
  -v, --version    Show ReiLua version
  -i, --interpret  Interpret mode [File name]
  --log            Show console window for logging (Windows only)
  --no-logo        Skip splash screens (development)
```

### Examples

```bash
# Run game in current directory
ReiLua.exe

# Run game in specific folder
ReiLua.exe path/to/game/

# Development mode (no splash, with console)
ReiLua.exe --log --no-logo

# Interpreter mode (run single script)
ReiLua.exe -i script.lua

# Show help
ReiLua.exe --help

# Show version
ReiLua.exe --version
```

## Object Unloading

Some objects allocate memory that needs to be freed when no longer needed. By default, objects like Textures are unloaded by the Lua garbage collector. However, it's generally recommended to handle this manually in more complex projects:

```lua
RL.SetGCUnload()
```

## Interpreter Mode

ReiLua can run single Lua files using interpreter mode:

```bash
ReiLua -i hello.lua
```

The given file will be called with `dofile`.

## Generate API Documentation

Generate API.md and ReiLua_API.lua from the build folder:

```bash
ReiLua -i ../tools/docgen.lua
```

**Tip:** Use tools/ReiLua_API.lua in your project folder to provide annotations when using "Lua Language Server".

## Building from Source

### Prerequisites

You'll need to statically link Raylib and Lua to create the executable. This simplifies distribution, especially on Linux where different distros use different library versions.

- **Raylib**: https://github.com/raysan5/raylib
- **Lua**: https://github.com/lua/lua or https://github.com/LuaJIT/LuaJIT
- **CMake**: https://cmake.org/download/
- **Build tools**: MinGW (Windows), GCC/Make (Linux)

**Note:** Lua header files are from Lua 5.4.0. If using a different version, replace them.

### Windows

#### 1. Install Tools

- Download **w64devkit** from https://github.com/skeeto/w64devkit
- Download **CMake** from https://cmake.org/download/ (install with PATH environment variables set)

#### 2. Build Raylib

```bash
# Download Raylib source
# Run w64devkit.exe and navigate to raylib/src
cd raylib/src
mingw32-make

# Copy libraylib.a to ReiLua/lib folder
copy libraylib.a path\to\ReiLua\lib\
```

#### 3. Build Lua

Download Lua source from https://github.com/lua/lua

Modify Lua's makefile:

```makefile
# Change this:
MYCFLAGS= $(LOCAL) -std=c99 -DLUA_USE_LINUX -DLUA_USE_READLINE
# To this:
MYCFLAGS= $(LOCAL) -std=c99

# Comment out or remove:
MYLIBS= -ldl -lreadline
```

Build:
```bash
# In w64devkit, navigate to Lua folder
mingw32-make

# Copy liblua.a to ReiLua/lib folder
copy liblua.a path\to\ReiLua\lib\
```

#### 4. Build ReiLua

Quick Method (Recommended):
```bash
cd ReiLua
scripts\build_dev.bat
```

Manual Method:
```bash
cd ReiLua\build
cmake -G "MinGW Makefiles" ..
mingw32-make
```

#### 5. Test

```bash
cd build
ReiLua.exe ..\examples\snake\
```

If you see a low-res snake racing off the window, success! Press Enter to reset.

### Linux

#### 1. Install Dependencies

```bash
sudo apt install build-essential cmake
```

#### 2. Build Raylib and Lua

Compile Raylib and Lua by following their instructions. They will compile to `libraylib.a` and `liblua.a` by default.

Move both `.a` files to the `ReiLua/lib` folder.

#### 3. Build ReiLua

Quick Method (Recommended):
```bash
cd ReiLua
chmod +x scripts/build_dev.sh
scripts/build_dev.sh
```

Manual Method:
```bash
cd ReiLua/build
cmake ..
make
```

#### 4. Test

```bash
./ReiLua ../examples/snake/
```

### MacOS

Not tested, but should work similarly to Linux.

### Raspberry Pi

Works best when Raylib is compiled using `PLATFORM=DRM`. See Raylib build instructions for Raspberry Pi.

Compile ReiLua with:
```bash
cmake .. -DDRM=ON
```

**Note:** DRM should be launched from CLI, not in X.

### Web (Emscripten)

Compile Raylib for web following its instructions: https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5)

#### 1. Compile Lua for Web

Modify Lua's makefile:

```makefile
# Change:
MYCFLAGS= $(LOCAL) -std=c99 -DLUA_USE_LINUX -DLUA_USE_READLINE
# To:
MYCFLAGS= $(LOCAL) -std=c99

# Change:
MYLIBS= -ldl -lreadline
# To:
MYLIBS= -ldl

# Change:
CC= gcc
# To:
CC= emcc

# Change:
CFLAGS= -Wall -O2 $(MYCFLAGS) -fno-stack-protector -fno-common -march=native
# To:
CFLAGS= -Wall -O2 $(MYCFLAGS) -fno-stack-protector -fno-common

# Change:
AR= ar rc
# To:
AR= emar

# Change:
$(AR) $@ $?
# To:
$(AR) rcs $@ $?
```

Build with `make` if emsdk environmental variables are correct.

#### 2. Prepare Libraries

Put `libraylib.a` and `liblua.a` into `ReiLua/lib/web/`.

#### 3. Create Resources Folder

```bash
cd ReiLua/build
mkdir resources
# Copy main.lua to resources/
# Copy assets to resources/
```

Structure:
```
ReiLua/
└── build/
    └── resources/
        ├── main.lua
        └── assets/
```

#### 4. Build

```bash
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=<YOUR_PATH>/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DPLATFORM=Web
make
```

#### 5. Test

```bash
python -m http.server 8080
```

Access in browser: `localhost:8080/ReiLua.html`

## Complete Release Workflow

### Step 1: Prepare Your Game

```
MyGame/
├── main.lua
├── player.lua
├── enemy.lua
├── assets/
│   ├── player.png
│   ├── enemy.png
│   └── music.wav
```

### Step 2: Copy Files to Build Directory

```bash
cd ReiLua/build

# Copy all Lua files
copy ..\MyGame\*.lua .

# Copy assets
mkdir assets
copy ..\MyGame\assets\* assets\
# Or: xcopy /E /I ..\MyGame\assets assets
```

### Step 3: Build Release

```bash
cd ..
scripts\build_release.bat
# Or: scripts/build_release.sh on Linux
```

### Step 4: Test

```bash
cd build
ReiLua.exe --log
```

Verify:
- No file loading errors
- Game runs correctly
- All assets load properly

### Step 5: Distribute

```bash
mkdir Distribution
copy ReiLua.exe Distribution\YourGameName.exe
```

Your game is now a single executable ready for distribution!

## Customizing Your Executable

### Change Executable Name

Edit `CMakeLists.txt`:
```cmake
project( YourGameName )  # Change from "ReiLua"
```

### Add Custom Icon

Replace `icon.ico` with your own icon file, then rebuild.

### Edit Executable Properties

Edit `resources.rc`:
```rc
VALUE "CompanyName", "Your Studio Name"
VALUE "FileDescription", "Your Game Description"
VALUE "ProductName", "Your Game Name"
VALUE "LegalCopyright", "Copyright (C) Your Name, 2025"
```

### Customize Splash Screens

Edit `src/splash.c`:
```c
const char* text = "YOUR STUDIO NAME";  // Change this
```

Replace logos:
```bash
# Replace these files before building
logo/raylib_logo.png
logo/reilua_logo.png
```

## Setting Up Zed Editor

Zed is a modern, high-performance code editor. Here's how to set it up for ReiLua development:

### Install Zed

Download from: https://zed.dev/

### Setup Lua Language Support

1. Open Zed
2. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
3. Type "install language server" and select Lua
4. Zed will automatically install the Lua Language Server

### Configure for ReiLua

Create `.zed/settings.json` in your project root:

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua": {
          "runtime": {
            "version": "Lua 5.4"
          },
          "diagnostics": {
            "globals": ["RL"]
          },
          "workspace": {
            "library": ["ReiLua_API.lua"]
          }
        }
      }
    }
  },
  "languages": {
    "Lua": {
      "format_on_save": "on",
      "formatter": "language_server"
    }
  }
}
```

### Copy ReiLua API Definitions

Copy `tools/ReiLua_API.lua` to your project folder. This provides autocomplete and documentation for all ReiLua functions.

```bash
copy path\to\ReiLua\tools\ReiLua_API.lua your_game\
```

### Keyboard Shortcuts

Useful Zed shortcuts for Lua development:

- `Ctrl+P` / `Cmd+P` - Quick file search
- `Ctrl+Shift+F` / `Cmd+Shift+F` - Search in files
- `Ctrl+.` / `Cmd+.` - Code actions
- `F12` - Go to definition
- `Shift+F12` - Find references
- `Ctrl+Space` - Trigger autocomplete

### Extensions

Install useful extensions:
1. Press `Ctrl+Shift+X` / `Cmd+Shift+X`
2. Search and install:
   - **Lua** - Syntax highlighting and language support
   - **Better Comments** - Enhanced comment highlighting
   - **Error Lens** - Inline error display

### Workspace Setup

Create a workspace for ReiLua projects:

1. Open your game folder in Zed
2. File → Add Folder to Workspace
3. Add the ReiLua source folder (for reference)
4. File → Save Workspace As...

This lets you easily reference ReiLua source while developing your game.

### Debugging

For debugging Lua code with Zed:

1. Use `print()` statements liberally
2. Run ReiLua with `--log` flag to see output
3. Use `RL.TraceLog()` for more detailed logging:

```lua
RL.TraceLog(RL.LOG_INFO, "Player position: " .. x .. ", " .. y)
RL.TraceLog(RL.LOG_WARNING, "Low health!")
RL.TraceLog(RL.LOG_ERROR, "Failed to load asset!")
```

### Terminal Integration

Run ReiLua directly from Zed's terminal:

1. Press `` Ctrl+` `` / `` Cmd+` `` to open terminal
2. Run your game:
```bash
path\to\ReiLua.exe --log --no-logo
```

### Tips for ReiLua Development in Zed

1. **Use Multiple Cursors**: `Alt+Click` to add cursors, great for batch edits
2. **Split Views**: `Ctrl+\` to split editor for side-by-side editing
3. **Symbol Search**: `Ctrl+T` / `Cmd+T` to search for functions
4. **Zen Mode**: `Ctrl+K Z` for distraction-free coding
5. **Live Grep**: `Ctrl+Shift+F` to search across all files

## Documentation

### Comprehensive Guides

- **[EMBEDDING.md](EMBEDDING.md)** - Complete guide to embedding Lua and assets
- **[ASSET_LOADING.md](ASSET_LOADING.md)** - Asset loading API and loading screen documentation
- **[SPLASH_SCREENS.md](SPLASH_SCREENS.md)** - Splash screen customization guide
- **[BUILD_SCRIPTS.md](BUILD_SCRIPTS.md)** - Build scripts documentation
- **[API.md](API.md)** - Complete API reference (1000+ functions)
- **[UPGRADE_SUMMARY.md](UPGRADE_SUMMARY.md)** - Technical details of enhancements

### Quick References

- **docs/API.md** - All ReiLua/Raylib functions
- **tools/ReiLua_API.lua** - Lua annotations for IDE autocomplete
- **examples/** - Example games and demos

## Troubleshooting

### Common Issues

Game doesn't start:
- Run with `--log` to see error messages
- Check that `main.lua` exists
- Verify all required assets exist

Assets not loading:
- Check file paths (use forward slashes or escaped backslashes)
- Verify files exist in the correct location
- Use `--log` to see loading errors

Splash screens don't show:
- Check you're not using `--no-logo` flag
- Verify build completed successfully
- Rebuild project: `cmake --build . --config Release`

Lua files not embedded:
- Ensure Lua files are in `build/` directory before building
- Check `main.lua` exists
- Verify `-DEMBED_MAIN=ON` was used

Assets not embedded:
- Create `build/assets/` folder
- Copy assets before building
- Verify `-DEMBED_ASSETS=ON` was used

Build fails:
- Check CMake and compiler are installed and in PATH
- Verify `libraylib.a` and `liblua.a` are in `lib/` folder
- Try clean build: `scripts\build_dev.bat clean`

### Getting Help

1. Check documentation files listed above
2. Review the examples in `examples/` folder
3. Use `--log` flag to see detailed error messages
4. Check your file paths and directory structure

## Contributing

Contributions are welcome! This is an enhanced version with additional features. When contributing:

1. Test thoroughly with both development and release builds
2. Update documentation if adding features
3. Follow existing code style
4. Test on multiple platforms if possible

## License

ReiLua is licensed under the zlib/libpng license. See LICENSE file for details.

### Third-Party Licenses

- **Raylib** - zlib/libpng license
- **Lua** - MIT license
- **Oleaguid Font** - Check font documentation for licensing

## Contact & Links

- **Original ReiLua**: https://github.com/Gamerfiend/ReiLua
- **Raylib**: https://github.com/raysan5/raylib
- **Lua**: https://www.lua.org/

## Version Information

- **ReiLua Version**: Based on original ReiLua with enhancements
- **Raylib Version**: 5.5
- **Lua Version**: 5.4

---

Happy Game Development!
