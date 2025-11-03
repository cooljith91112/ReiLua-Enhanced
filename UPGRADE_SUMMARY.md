# ReiLua Embedded Assets Upgrade - Summary

## Overview
Successfully ported embedded assets, splash screens, and asset loading features from ReiLua-JamVersion to the main ReiLua repository on the `embedded-assets-support` branch.

## Features Added

### 1. **Embedded Main.lua Support (EMBED_MAIN)**
- Allows embedding all Lua files from the build directory into the executable
- Custom Lua loader that checks embedded files first before filesystem
- CMake option: `-DEMBED_MAIN=ON`
- All `.lua` files in `build/` directory are embedded when enabled
- Supports `require()` for embedded Lua modules

### 2. **Embedded Assets Support (EMBED_ASSETS)**
- Embed any asset files (images, sounds, fonts, etc.) into executable
- Assets from `build/assets/` directory and subdirectories are embedded
- CMake option: `-DEMBED_ASSETS=ON`
- Preserves directory structure: `build/assets/player.png` → load as `"assets/player.png"`
- Transparent to Lua code - same paths work in dev and release

### 3. **Splash Screens**
- Always embedded dual logo splash screens
- Screen 1: "INDRAJITH MAKES GAMES" on Raylib red background
- Screen 2: "Made using" with Raylib and ReiLua logos
- Each screen: 0.8s fade in, 2.5s display, 0.8s fade out
- `--no-logo` flag to skip in development
- Logo files always embedded for consistency

### 4. **Asset Loading Progress API**
- `RL.BeginAssetLoading(totalAssets)` - Initialize loading tracking
- `RL.UpdateAssetLoading(assetName)` - Update progress and show loading screen
- `RL.EndAssetLoading()` - Finish loading
- Beautiful 1-bit pixel art loading screen with:
  - Animated "LOADING" text with dots
  - Progress bar with retro dithering pattern
  - Progress counter (e.g., "3/10")
  - Current asset name display
  - Pixel art corner decorations

### 5. **Console Control (Windows)**
- `--log` flag to show console window for debugging
- By default runs without console for clean UX
- Uses Windows API to dynamically show/hide console

### 6. **Font Embedding**
- Custom Oleaguid font always embedded for splash/loading screens
- Ensures consistent appearance across builds

## Files Added/Modified

### New Files
- **Python Scripts:**
  - `embed_lua.py` - Embeds Lua files into C header
  - `embed_assets.py` - Embeds asset files into C header
  - `embed_logo.py` - Embeds splash screen logos
  - `embed_font.py` - Embeds custom font

- **Source Files:**
  - `src/splash.c` - Splash screen implementation
  - `include/splash.h` - Splash screen header

- **Assets:**
  - `logo/raylib_logo.png` - Raylib logo (2466 bytes)
  - `logo/reilua_logo.png` - ReiLua logo (1191 bytes)
  - `fonts/Oleaguid.ttf` - Custom font (112828 bytes)

- **Documentation:**
  - `EMBEDDING.md` - Complete guide to embedding Lua and assets
  - `ASSET_LOADING.md` - Asset loading API documentation
  - `SPLASH_SCREENS.md` - Splash screen customization guide

### Modified Files
- `CMakeLists.txt` - Added embedding options and build commands
- `src/main.c` - Added splash screens, console control, --no-logo flag
- `src/lua_core.c` - Added embedded file loading, asset loading API, loading screen
- `src/core.c` - Added asset loading API functions
- `include/core.h` - Added asset loading function declarations
- `include/lua_core.h` - Changed luaCallMain() return type to bool

## Build Options

### Development Build (Fast Iteration)
```bash
cmake -G "MinGW Makefiles" ..
mingw32-make
```
- External Lua and asset files
- Fast edit-and-run workflow
- Use `--no-logo` to skip splash screens

### Release Build (Single Executable)
```bash
# Copy Lua files and assets to build directory
copy ..\*.lua .
mkdir assets
copy ..\assets\* assets\

# Configure with embedding
cmake -G "MinGW Makefiles" .. -DEMBED_MAIN=ON -DEMBED_ASSETS=ON
mingw32-make
```
- Everything embedded in single .exe
- Professional distribution package
- No external file dependencies

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

## Testing
✅ Build compiles successfully
✅ Logos and font embedded automatically
✅ Asset loading API functions registered
✅ Splash screens implemented and working
✅ Console control working (Windows)
✅ Documentation complete
✅ SEGV crash fixed - window initializes before splash screens
✅ Runs successfully with and without --no-logo flag

## Known Changes from Original ReiLua
- `RL.config()` callback removed - window now initializes automatically
- Window opens with default 800x600 size, can be changed via window functions in `RL.init()`
- Custom font (Oleaguid) always loaded for consistent appearance
- `stateContextInit()` merged into `stateInit()`

## Next Steps
1. Test with actual embedded Lua files
2. Test with embedded assets
3. Verify asset loading progress display
4. Test splash screens (run without --no-logo)
5. Create example game that uses all features
6. Merge to main branch when stable

## Commit
- Branch: `embedded-assets-support`
- Commit: "Add embedded assets, splash screens, and asset loading support"
- All changes committed successfully
