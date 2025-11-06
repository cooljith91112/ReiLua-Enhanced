# Build Scripts Documentation

ReiLua includes automated build scripts for easy development and release builds.

## Available Scripts

### Development Build Scripts
- **Windows**: `scripts\build_dev.bat`
- **Linux/Unix**: `scripts/build_dev.sh`

### Release Build Scripts  
- **Windows**: `scripts\build_release.bat`
- **Linux/Unix**: `scripts/build_release.sh`

## Development Build

### Purpose
Fast iteration during game development with external Lua files and assets.

### Usage

Windows:
```cmd
scripts\build_dev.bat
```

Linux/Unix:
```bash
chmod +x scripts/build_dev.sh
scripts/build_dev.sh
```

### Features
- No embedding - loads Lua and assets from file system
- Fast build times
- Edit code and assets without rebuilding
- Automatic cleanup of embedded files
- Warns if Lua files or assets are in build directory
- Optional clean build: `scripts\build_dev.bat clean` or `scripts/build_dev.sh clean`

### Output
- Development executable: `build/ReiLua.exe`
- Run your game: `cd your_game && path/to/build/ReiLua.exe`
- Debug mode: `path/to/build/ReiLua.exe --log`

## Release Build

### Purpose
Create a single-file executable for distribution with all code and assets embedded.

### Preparation

Before running the release build, prepare your files:

```bash
cd build

# Copy all Lua files
copy ..\your_game\*.lua .
# Or: cp ../your_game/*.lua .

# Copy assets
mkdir assets
copy ..\your_game\assets\* assets\
# Or: cp -r ../your_game/assets/* assets/
```

### Usage

Windows:
```cmd
scripts\build_release.bat
```

Linux/Unix:
```bash
chmod +x scripts/build_release.sh
scripts/build_release.sh
```

### Features
- Embeds all Lua files from `build/` directory
- Embeds all assets from `build/assets/` folder
- Creates single-file executable
- Release optimization enabled
- Verifies Lua files and assets before building
- Shows summary of embedded files after build
- Interactive confirmation before building

### Output
- Release executable: `build/ReiLua.exe`
- Ready for distribution - no external dependencies
- Can be renamed to your game name

### Build Configuration

The release build automatically configures:
- `EMBED_MAIN=ON` - Embeds all Lua files
- `EMBED_ASSETS=ON` - Embeds all assets (if assets folder exists)
- `CMAKE_BUILD_TYPE=Release` - Optimized build

## Customizing Your Executable

### Adding Custom Icon

1. Replace `icon.ico` with your own icon file
2. Keep the same filename or update `resources.rc`
3. Rebuild

### Changing Executable Properties

Edit `resources.rc` to customize:

```rc
VALUE "CompanyName", "Your Studio Name"
VALUE "FileDescription", "Your Game Description"
VALUE "ProductName", "Your Game Name"
VALUE "LegalCopyright", "Copyright (C) Your Name, 2025"
```

### Renaming the Executable

Edit `CMakeLists.txt`:
```cmake
project( YourGameName )  # Line 6
```

After building, the executable will be named `YourGameName.exe`.

## Workflow Examples

### Development Workflow

```bash
# Initial setup
scripts\build_dev.bat

# Edit your Lua files in your game directory
# ... make changes ...

# Just run - no rebuild needed!
cd your_game
path\to\build\ReiLua.exe

# If you modify C code, rebuild
scripts\build_dev.bat
```

### Release Workflow

```bash
# 1. Prepare files
cd build
copy ..\your_game\*.lua .
mkdir assets
copy ..\your_game\assets\* assets\

# 2. Build release
cd ..
scripts\build_release.bat

# 3. Test
cd build
ReiLua.exe --log

# 4. Distribute
# Copy build\ReiLua.exe to your distribution folder
```

## Troubleshooting

### "CMake configuration failed"
- Ensure CMake is installed and in PATH
- Ensure MinGW is installed and in PATH
- Check `CMakeLists.txt` exists in parent directory

### "No Lua files found"
- Copy your Lua files to `build/` directory before release build
- Ensure `main.lua` exists (required entry point)

### "Build failed"
- Check compiler errors in output
- Ensure all dependencies are installed
- Try clean build: `scripts\build_dev.bat clean`

### Development build embedding warning
- The dev build script warns if it finds Lua files or assets in build/
- These should be removed for development builds
- The script offers to remove them automatically

## Script Features

### Safety Features
- Checks for correct directory before running
- Validates required files exist
- Warns about potential issues
- Interactive confirmations for release builds
- Automatic cleanup of old embedded files

### User Friendly
- Clear progress messages
- Colored output (where supported)
- Helpful error messages
- Pause at end to review results
- Quick reference commands shown after build

## Notes

- Development builds are **much faster** than release builds
- Release builds may take longer due to embedding and optimization
- Always test your release build before distribution
- The scripts work on both Windows (CMD/PowerShell) and Unix shells
- On Unix, make scripts executable: `chmod +x build_*.sh`
