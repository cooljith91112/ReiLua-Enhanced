# Customizing Your ReiLua Executable

This guide explains how to customize the ReiLua executable with your own branding.

## Overview

You can customize:
- Executable name
- Window icon
- File properties (company name, version, description, etc.)
- Splash screen text and logos
- Loading screen appearance

## Quick Customization Checklist

- [ ] Change executable name in CMakeLists.txt
- [ ] Replace icon.ico with your game icon
- [ ] Edit resources.rc with your game information
- [ ] Customize splash screens in src/splash.c
- [ ] Replace logo images in logo/ folder
- [ ] Rebuild the project

## 1. Changing the Executable Name

The easiest customization - change "ReiLua.exe" to "YourGame.exe".

### Steps

1. Open `CMakeLists.txt`
2. Find line 6 (near the top):
   ```cmake
   project( ReiLua )
   ```
3. Change to your game name:
   ```cmake
   project( MyAwesomeGame )
   ```
4. Rebuild:
   ```bash
   cd build
   cmake ..
   cmake --build . --config Release
   ```

Result: Executable is now named `MyAwesomeGame.exe`

## 2. Adding a Custom Icon

Replace the default icon with your game's icon.

### Requirements

- **Format**: .ico file (Windows icon format)
- **Recommended sizes**: 16x16, 32x32, 48x48, 256x256
- **Tools**: Use online converters or tools like IcoFX, GIMP, or Photoshop

### Steps

1. Create or convert your image to .ico format
2. Replace `icon.ico` in the ReiLua root folder with your icon
3. Keep the same filename (`icon.ico`) or update `resources.rc`:
   ```rc
   IDI_ICON1 ICON "your_icon.ico"
   ```
4. Rebuild the project

**Tip**: Many online tools can convert PNG to ICO:
- https://convertio.co/png-ico/
- https://www.icoconverter.com/

## 3. Customizing Executable Properties

When users right-click your .exe and select "Properties", they see file information. Customize this to show your game details.

### Steps

1. Open `resources.rc`
2. Find the `VERSIONINFO` section
3. Modify these values:

```rc
1 VERSIONINFO
FILEVERSION     1,0,0,0      // Change version numbers
PRODUCTVERSION  1,0,0,0      // Change product version
FILEFLAGSMASK   0x3fL
FILEFLAGS       0x0L
FILEOS          VOS_NT_WINDOWS32
FILETYPE        VFT_APP
FILESUBTYPE     VFT2_UNKNOWN
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "CompanyName",      "Your Studio Name"           // Your company/studio
            VALUE "FileDescription",  "Your Game - An awesome game"  // Game description
            VALUE "FileVersion",      "1.0.0.0"                    // File version string
            VALUE "InternalName",     "YourGame"                   // Internal name
            VALUE "LegalCopyright",   "Copyright (C) 2025 Your Name"  // Copyright notice
            VALUE "OriginalFilename", "YourGame.exe"               // Original filename
            VALUE "ProductName",      "Your Game"                  // Product name
            VALUE "ProductVersion",   "1.0.0.0"                    // Product version string
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1200
    END
END
```

### Common Values

**FileVersion / ProductVersion Format**: Major, Minor, Patch, Build
- Example: `1,0,0,0` for version 1.0.0.0
- Example: `2,3,1,5` for version 2.3.1.5

**CompanyName Examples**:
- "Your Studio Name"
- "Independent Developer"
- "Your Name Games"

**FileDescription**:
- Short description users see in file properties
- Example: "Space Adventure Game"
- Example: "Puzzle Game with Physics"

**LegalCopyright**:
- Standard format: "Copyright (C) Year Your Name"
- Example: "Copyright (C) 2025 Indie Studios"

4. Rebuild the project

## 4. Customizing Splash Screens

Change the text and logos that appear when your game starts.

### Changing Splash Screen Text

1. Open `src/splash.c`
2. Find the splash drawing function (around line 150)
3. Change this line:
   ```c
   const char* text = "YOUR STUDIO NAME";
   ```

**Style Tips**:
- Use ALL CAPS for bold impact
- Keep it short (under 30 characters)
- Examples: "INDIE STUDIO GAMES", "MADE BY YOUR NAME", "GAME JAM 2025"

### Changing Splash Screen Logos

1. Create or find your logos:
   - **Recommended size**: 256x256 pixels or smaller
   - **Format**: PNG with transparency
   - **Style**: Simple, recognizable logos work best

2. Replace these files:
   ```
   logo/raylib_logo.png  → Your game logo
   logo/reilua_logo.png  → Your studio logo (or keep ReiLua logo as credit)
   ```

3. Logo sizing:
   - Logos are automatically scaled to max 200px
   - They display side-by-side on second splash screen
   - Maintain aspect ratio

4. Rebuild the project - logos are automatically embedded

### Changing Splash Screen Timing

1. Open `src/splash.c`
2. Modify these constants at the top:
   ```c
   #define FADE_IN_TIME 0.8f    // Seconds to fade in (default: 0.8)
   #define DISPLAY_TIME 2.5f    // Seconds fully visible (default: 2.5)
   #define FADE_OUT_TIME 0.8f   // Seconds to fade out (default: 0.8)
   ```

**Recommendations**:
- Keep fade times between 0.5 - 1.5 seconds
- Display time between 1.5 - 3.5 seconds
- Total splash time ideally under 10 seconds

### Changing Splash Screen Colors

1. Open `src/splash.c`
2. Find color definitions:
   ```c
   // First splash screen background (Raylib red)
   Color bgColor = (Color){ 230, 41, 55, 255 };  // Change these RGB values
   
   // Second splash screen background (Black)
   Color bg = BLACK;  // Change to any color
   ```

**Color Examples**:
- White: `(Color){ 255, 255, 255, 255 }`
- Blue: `(Color){ 0, 120, 215, 255 }`
- Dark Gray: `(Color){ 32, 32, 32, 255 }`
- Your brand color: `(Color){ R, G, B, 255 }`

## 5. Customizing the Loading Screen

Change the appearance of the asset loading screen.

### Steps

1. Open `src/lua_core.c`
2. Find the `drawLoadingScreen()` function
3. Modify colors and style:

```c
// Background color
Color bgColor = BLACK;  // Change background

// Text color
Color textColor = WHITE;  // Change text color

// Progress bar fill color
Color fillColor = WHITE;  // Change bar fill

// Border color
Color borderColor = WHITE;  // Change borders
```

### Customizing Loading Text

```c
// In drawLoadingScreen() function
const char* loadingText = "LOADING";  // Change to "LOADING GAME", etc.
```

### Changing Progress Bar Size

```c
int barWidth = 200;   // Default 200px, change as needed
int barHeight = 16;   // Default 16px, change as needed
int borderThick = 2;  // Border thickness
```

## 6. Complete Rebranding Example

Here's a complete example of rebranding ReiLua as "Space Quest":

### 1. CMakeLists.txt
```cmake
project( SpaceQuest )
```

### 2. resources.rc
```rc
VALUE "CompanyName",      "Cosmic Games Studio"
VALUE "FileDescription",  "Space Quest - Explore the Galaxy"
VALUE "FileVersion",      "1.0.0.0"
VALUE "InternalName",     "SpaceQuest"
VALUE "LegalCopyright",   "Copyright (C) 2025 Cosmic Games"
VALUE "OriginalFilename", "SpaceQuest.exe"
VALUE "ProductName",      "Space Quest"
VALUE "ProductVersion",   "1.0.0.0"
```

### 3. icon.ico
Replace with your space-themed icon

### 4. src/splash.c
```c
const char* text = "COSMIC GAMES STUDIO";
```

### 5. logo/ folder
```
logo/raylib_logo.png  → Your game logo (space ship, planet, etc.)
logo/reilua_logo.png  → Studio logo (keep ReiLua logo for credit)
```

### 6. Build
```bash
cd build
cmake ..
cmake --build . --config Release
```

Result: `SpaceQuest.exe` with all your custom branding!

## 7. Advanced: Removing ReiLua Branding

If you want to completely remove ReiLua references:

### Remove "Made with ReiLua" Logo

1. Open `src/splash.c`
2. Find `drawMadeWithSplash()` function
3. Comment out or modify the function to only show your logo

### Remove Second Splash Screen

1. Open `src/main.c`
2. Find the splash screen loop
3. Modify to only call your custom splash

**Note**: Please keep attribution to Raylib and ReiLua in your game's credits or about screen as a courtesy!

## 8. Build and Test

After making any customizations:

```bash
# Clean build (recommended after customizations)
cd build
rm -rf *  # Or: rmdir /s /q * on Windows
cmake ..
cmake --build . --config Release

# Test with console
YourGame.exe --log

# Test production mode
YourGame.exe
```

Verify:
- ✅ Executable has correct name
- ✅ Icon appears in file explorer
- ✅ Right-click → Properties shows correct info
- ✅ Splash screens display correctly
- ✅ Loading screen appears as expected

## Checklist: Release-Ready Customization

Before releasing your game:

- [ ] Executable name matches your game
- [ ] Custom icon is recognizable at small sizes
- [ ] File properties are complete and accurate
- [ ] Splash screens show correct studio name
- [ ] Logos are high quality and appropriate size
- [ ] Loading screen matches your game's aesthetic
- [ ] Copyright and legal information is correct
- [ ] Version numbers are accurate
- [ ] Tested on target platforms
- [ ] Credits mention Raylib and ReiLua

## Tips for Polish

1. **Consistent Branding**: Use the same colors, fonts, and style across splash screens, loading screen, and in-game UI

2. **Icon Quality**: Invest time in a good icon - it's the first thing users see

3. **Version Management**: Update version numbers for each release

4. **Legal Info**: Always include proper copyright and attribution

5. **Test Everything**: Test your branded executable on a clean system

6. **Keep Credits**: Mention Raylib and ReiLua in your game's credits screen

## Troubleshooting

**Icon doesn't change:**
- Ensure .ico file is valid
- Rebuild completely (clean build)
- Clear icon cache (Windows): Delete `IconCache.db`

**Properties don't update:**
- Verify `resources.rc` syntax is correct
- Rebuild completely
- Check that resource compiler ran (check build output)

**Splash screens don't show changes:**
- Rebuild with clean build
- Check `embed_logo.py` ran successfully
- Verify logo files exist in `logo/` folder

**Executable name unchanged:**
- Check `CMakeLists.txt` project name
- Do a clean rebuild
- Verify cmake configuration step succeeded

## Additional Resources

### Icon Creation Tools
- **IcoFX**: Icon editor (paid)
- **GIMP**: Free, supports ICO export
- **Online**: convertio.co, icoconverter.com

### Image Editing
- **GIMP**: Free, powerful image editor
- **Paint.NET**: Simple, free Windows editor
- **Photoshop**: Industry standard (paid)

### Color Picking
- **ColorPicker**: Use system color picker
- **HTML Color Codes**: htmlcolorcodes.com
- **Adobe Color**: color.adobe.com

---

Now your ReiLua executable is fully branded and ready to represent your game!
