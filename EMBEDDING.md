# Embedding main.lua into Executable

When you're ready to ship your game, you can embed all Lua files and asset files directly into the executable.

## Development vs Release Workflow

### 🔧 Development Build (Fast Iteration)

During development, use external files for quick iteration:

**Setup:**
```
GameFolder/
├── ReiLua.exe
├── main.lua
├── player.lua
└── assets/
    ├── player.png
    └── music.wav
```

**Build:**
```bash
cd build
cmake ..
cmake --build .
```

**Benefits:**
- ✅ Edit Lua files and re-run immediately
- ✅ Edit assets and reload
- ✅ Fast development cycle
- ✅ Debug with `--log` flag

### 📦 Release Build (Single Executable)

For distribution, embed everything into one file:

**Setup:**
```bash
cd build

# Copy Lua files to build directory
copy ..\main.lua .
copy ..\player.lua .

# Create assets folder and copy files
mkdir assets
copy ..\player.png assets\
copy ..\music.wav assets\
```

**Build:**
```bash
# Configure with embedding
cmake .. -DEMBED_MAIN=ON -DEMBED_ASSETS=ON

# Build release
cmake --build . --config Release
```

**Result:**
```
Distribution/
└── YourGame.exe  (Everything embedded!)
```

**Benefits:**
- ✅ Single executable file
- ✅ No external dependencies
- ✅ Users can't modify game files
- ✅ Smaller download (no separate files)

## Quick Start

### Embedding Lua Files

1. **Copy your Lua files to the build directory**:
   ```bash
   copy main.lua build\main.lua
   copy player.lua build\player.lua
   ```

2. **Build with EMBED_MAIN option**:
   ```bash
   cd build
   cmake .. -DEMBED_MAIN=ON
   cmake --build . --config Release
   ```

## Command Line Options

ReiLua supports several command-line options:

```bash
ReiLua [Options] [Directory to main.lua or main]

Options:
  -h, --help       Show help message
  -v, --version    Show ReiLua version
  -i, --interpret  Interpret mode [File name]
  --log            Show console window for logging (Windows only)
```

### Console/Logging

By default, ReiLua runs **without a console window** for a clean user experience. To enable console output for debugging:

```bash
# Run with console for debugging
ReiLua.exe --log

# You can also combine with other options
ReiLua.exe --log path/to/game

# Or with interpret mode
ReiLua.exe --log -i script.lua
```

This is useful during development to see:
- TraceLog output
- Print statements
- Lua errors
- Debug information

## Complete Release Workflow

Here's a complete step-by-step guide to prepare your game for release:

### Step 1: Organize Your Project

Ensure your project has this structure:
```
MyGame/
├── main.lua
├── player.lua
├── enemy.lua
├── player.png
├── enemy.png
├── music.wav
└── icon.ico (optional)
```

### Step 2: Customize Branding (Optional)

**Change executable icon:**
```bash
# Replace ReiLua's icon with yours
copy MyGame\icon.ico ReiLua\icon.ico
```

**Edit executable properties:**
Open `ReiLua\resources.rc` and modify:
```rc
VALUE "CompanyName", "Your Studio Name"
VALUE "FileDescription", "Your Game Description"
VALUE "ProductName", "Your Game Name"
VALUE "LegalCopyright", "Copyright (C) Your Name, 2025"
```

**Change executable name:**
Edit `ReiLua\CMakeLists.txt`:
```cmake
project( YourGameName )  # Change from "ReiLua"
```

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for full details.

### Important: Asset Paths

**Keep your paths consistent!** The embedding system now preserves the `assets/` prefix, so use the same paths in both development and release:

```lua
-- ✅ Correct - works in both dev and release
playerImage = RL.LoadTexture("assets/player.png")
backgroundImg = RL.LoadTexture("assets/background.png")
musicSound = RL.LoadSound("assets/music.wav")
```

Your Lua code doesn't need to change between development and release builds!

### Step 3: Prepare Build Directory

```bash
cd ReiLua\build

# Copy all Lua files
copy ..\MyGame\*.lua .

# Create assets folder
mkdir assets

# Copy all asset files (images, sounds, etc.)
copy ..\MyGame\*.png assets\
copy ..\MyGame\*.wav assets\
copy ..\MyGame\*.ogg assets\
# Or copy entire folders
xcopy /E /I ..\MyGame\images assets\images
xcopy /E /I ..\MyGame\sounds assets\sounds
```

### Step 4: Build Release

```bash
# Configure with embedding enabled
cmake .. -DEMBED_MAIN=ON -DEMBED_ASSETS=ON

# Build in release mode
cmake --build . --config Release
```

### Step 5: Test Release Build

```bash
# Test with console to verify everything loaded
YourGameName.exe --log

# Test production mode (no console)
YourGameName.exe
```

Check console output for:
- ✅ "ReiLua x.x.x" version info
- ✅ No file loading errors
- ✅ Game runs correctly

### Step 6: Package for Distribution

```bash
# Create distribution folder
mkdir ..\Distribution
copy YourGameName.exe ..\Distribution\

# Optional: Add README, LICENSE, etc.
copy ..\README.txt ..\Distribution\
```

Your game is now ready to distribute as a single executable!

### Workflow Summary

| Stage | Build Command | Files Needed | Result |
|-------|--------------|--------------|--------|
| **Development** | `cmake .. && cmake --build .` | Lua + assets external | Fast iteration |
| **Testing** | `cmake .. -DEMBED_MAIN=ON && cmake --build .` | Lua in build/ | Test embedding |
| **Release** | `cmake .. -DEMBED_MAIN=ON -DEMBED_ASSETS=ON && cmake --build . --config Release` | Lua + assets in build/ | Single .exe |

### Troubleshooting

**Problem: "No .lua files found in build directory"**
```bash
# Solution: Copy Lua files to build directory
copy ..\*.lua .
```

**Problem: "No files found in assets folder"**
```bash
# Solution: Create assets folder and copy files
mkdir assets
copy ..\*.png assets\
```

**Problem: Game crashes on startup**
```bash
# Solution: Run with --log to see error messages
YourGameName.exe --log
```

**Problem: Assets not loading**
- Verify assets are in `build/assets/` before building
- Check asset filenames match in your Lua code
- Use `--log` to see loading errors

### Notes

- `.lua` files in the **build directory root** are embedded when using `EMBED_MAIN=ON`
- Asset files in **build/assets/** folder (and subfolders) are embedded when using `EMBED_ASSETS=ON`
- `main.lua` must exist and is always the entry point
- Asset embedding works with subdirectories: `assets/images/player.png` → Load with `LoadImage("player.png")`
- Both Lua and asset embedding can be used independently or together
- The system falls back to file system if embedded file is not found
- No code changes needed - all raylib functions work automatically with embedded assets

## Customizing Your Executable

Want to add your own icon and version info to the executable? See [CUSTOMIZATION.md](CUSTOMIZATION.md) for details on:
- Adding a custom icon
- Setting exe properties (company name, version, description)
- Renaming the executable
