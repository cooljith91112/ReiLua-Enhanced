# Splash Screens

ReiLua includes a built-in splash screen system that displays splash screens before your game loads. This gives your game a polished appearance right from startup.

## Overview

When you run your ReiLua game, it automatically shows two splash screens in sequence:

1. **Custom Text** - Clean, bold text on Raylib red background (similar to Squid Game style)
2. **"Made using"** - Text with Raylib and ReiLua logos displayed side-by-side

Each splash screen:
- Fades in over 0.8 seconds
- Displays for 2.5 seconds
- Fades out over 0.8 seconds
- Total display time: 8.2 seconds for both screens

## Features

### Always Embedded

The logo images are **always embedded** into the executable in both development and release builds. This means:

- ✅ No external logo files needed
- ✅ Consistent splash screens across all builds
- ✅ No risk of missing logo files
- ✅ Clean appearance from the start

### Asset Loading Integration

The splash screens display **before** your game's asset loading begins. This means:

1. User starts your game
2. Splash screens play (~8 seconds)
3. Your `RL.init()` function runs
4. Asset loading with progress indicator (if you use it)
5. Your game starts

This creates a smooth, polished startup experience.

## Skipping Splash Screens (Development)

During development, you often need to test your game repeatedly. Waiting for splash screens every time can slow down your workflow. Use the `--no-logo` flag to skip them:

```bash
# Windows
ReiLua.exe --no-logo

# Linux/Mac
./ReiLua --no-logo

# With other options
ReiLua.exe --log --no-logo
./ReiLua --no-logo path/to/game/
```

**Note:** The `--no-logo` flag only works in development. In release builds, users should see the full splash screen sequence.

## Technical Details

### How It Works

The splash screen system is implemented in C and runs before any Lua code executes:

1. **Logo Embedding**: During build, `embed_logo.py` converts PNG files to C byte arrays
2. **Initialization**: Before calling `RL.init()`, the engine initializes splash screens
3. **Display Loop**: A dedicated loop handles timing, fading, and rendering
4. **Cleanup**: After completion, resources are freed and Lua code begins

### Files

- `src/splash.c` - Splash screen implementation
- `include/splash.h` - Header file
- `embed_logo.py` - Python script to embed logo images
- `logo/raylib_logo.png` - Raylib logo (embedded)
- `logo/reilua_logo.png` - ReiLua logo (embedded)

### Build Integration

The CMakeLists.txt automatically:

1. Runs `embed_logo.py` during build
2. Generates `embedded_logo.h` with logo data
3. Defines `EMBED_LOGO` flag
4. Compiles `splash.c` with the project

No manual steps required - it just works!

## Customization

### Changing Splash Screen Text

To change the default text to your studio name:

1. Open `src/splash.c`
2. Find the splash drawing function
3. Change the text line:
   ```c
   const char* text = "YOUR STUDIO NAME";
   ```
4. Rebuild the project

**Note:** Use ALL CAPS for the Squid Game-style aesthetic.

### Changing Logos

To use different logos:

1. Replace `logo/raylib_logo.png` and/or `logo/reilua_logo.png` with your images
2. Recommended size: 256x256 or smaller (logos are auto-scaled to max 200px)
3. Format: PNG with transparency support
4. Rebuild the project - logos will be automatically embedded

### Changing Timing

To adjust how long each screen displays:

1. Open `src/splash.c`
2. Modify these constants at the top:
   ```c
   #define FADE_IN_TIME 0.8f    // Seconds to fade in
   #define DISPLAY_TIME 2.5f    // Seconds to display fully
   #define FADE_OUT_TIME 0.8f   // Seconds to fade out
   ```
3. Rebuild the project

### Removing Splash Screens Entirely

If you don't want any splash screens:

1. Open `src/main.c`
2. Find this block:
   ```c
   /* Show splash screens if not skipped */
   if ( !skip_splash ) {
       splashInit();
       // ... splash code ...
       splashCleanup();
   }
   ```
3. Comment out or remove the entire block
4. Rebuild the project

## Example: Complete Startup Sequence

Here's what a typical game startup looks like with everything enabled:

```bash
ReiLua.exe MyGame/
```

**User Experience:**

1. **Splash Screen 1** (4.1 seconds)
   - Custom text displayed in bold (default: "YOUR STUDIO NAME")
   - Red background (Raylib color #E62937)
   - Subtle zoom effect

2. **Splash Screen 2** (4.1 seconds)
   - "Made using" text at top
   - Raylib + ReiLua logos side-by-side (max 200px each)
   - Black background

3. **Asset Loading** (varies)
   - Your loading screen with progress bar
   - Shows "Loading texture1.png", "3/10", etc.

4. **Game Start**
   - Your game's main screen appears
   - Player can interact

## Best Practices

1. **Keep --no-logo for Development**: Always use `--no-logo` during active development
2. **Test Without Flag**: Occasionally test without `--no-logo` to ensure splash screens work
3. **Customize for Your Studio**: Change the text and logos to match your branding
4. **Consider Total Time**: Splash (~8s) + Loading (varies) = Total startup time
5. **Optimize Loading**: Keep asset loading fast to maintain a good first impression

## Troubleshooting

### Splash Screens Don't Show

**Problem**: Game starts immediately without splash screens

**Solutions**:
- Check you're not using `--no-logo` flag
- Verify logos exist in `logo/` folder before building
- Check console output for embedding errors
- Rebuild project completely: `cmake .. && make clean && make`

### Logos Appear Corrupted

**Problem**: Logos display incorrectly or not at all

**Solutions**:
- Verify PNG files are valid (open in image viewer)
- Check file sizes aren't too large (keep under 1MB each)
- Ensure PNGs use standard format (not progressive or exotic encoding)
- Rebuild project to regenerate embedded data

### Compilation Errors

**Problem**: Build fails with logo-related errors

**Solutions**:
- Ensure Python 3 is installed and in PATH
- Check `embed_logo.py` has correct paths
- Verify `logo/` folder exists with both PNG files
- Check CMake output for specific error messages

## Command Reference

```bash
# Development (skip splash)
ReiLua --no-logo

# Development with logging
ReiLua --log --no-logo

# Production/testing (full splash)
ReiLua

# Help
ReiLua --help
```

---

The splash screen system adds a polished touch to your ReiLua games with minimal effort. Customize it to match your studio's branding and give players a great first impression!
