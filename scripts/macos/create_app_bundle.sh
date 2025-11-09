#!/bin/bash
# Create macOS App Bundle with Icon
# This creates a proper .app bundle for distribution on macOS

set -e

echo "========================================"
echo "Creating macOS App Bundle"
echo "========================================"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."
cd "$PROJECT_ROOT"

# Check if executable exists
if [ ! -f "build/ReiLua" ]; then
    echo "ERROR: ReiLua executable not found!"
    echo "Please run ./scripts/build_dev.sh or ./scripts/build_release.sh first"
    exit 1
fi

# App name (can be customized)
APP_NAME="${1:-ReiLua}"
APP_BUNDLE="${APP_NAME}.app"

echo "Creating app bundle: $APP_BUNDLE"
echo ""

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
echo "Copying executable..."
cp build/ReiLua "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Convert icon.ico to .icns if needed
ICNS_FILE="$APP_BUNDLE/Contents/Resources/icon.icns"

if [ -f "icon.ico" ]; then
    echo "Converting icon..."
    
    # Create temporary iconset directory
    mkdir -p icon.iconset
    
    # Use sips to convert and resize (macOS built-in tool)
    # Extract from .ico and create different sizes
    sips -s format png icon.ico --out icon.iconset/icon_512x512.png -z 512 512 2>/dev/null || {
        echo "Note: sips conversion had warnings, using ImageMagick if available..."
        if command -v convert &> /dev/null; then
            convert icon.ico -resize 512x512 icon.iconset/icon_512x512.png
        else
            echo "WARNING: Could not convert icon. Install ImageMagick with: brew install imagemagick"
            echo "         Or provide an icon.png file at 512x512 resolution"
        fi
    }
    
    # Create other required sizes if we have the 512x512 version
    if [ -f "icon.iconset/icon_512x512.png" ]; then
        sips -z 256 256 icon.iconset/icon_512x512.png --out icon.iconset/icon_256x256.png
        sips -z 128 128 icon.iconset/icon_512x512.png --out icon.iconset/icon_128x128.png
        sips -z 64 64   icon.iconset/icon_512x512.png --out icon.iconset/icon_64x64.png
        sips -z 32 32   icon.iconset/icon_512x512.png --out icon.iconset/icon_32x32.png
        sips -z 16 16   icon.iconset/icon_512x512.png --out icon.iconset/icon_16x16.png
        
        # Create @2x versions (retina)
        cp icon.iconset/icon_512x512.png icon.iconset/icon_256x256@2x.png
        cp icon.iconset/icon_256x256.png icon.iconset/icon_128x128@2x.png
        cp icon.iconset/icon_128x128.png icon.iconset/icon_64x64@2x.png
        cp icon.iconset/icon_64x64.png   icon.iconset/icon_32x32@2x.png
        cp icon.iconset/icon_32x32.png   icon.iconset/icon_16x16@2x.png
        
        # Convert to .icns
        iconutil -c icns icon.iconset -o "$ICNS_FILE"
        echo "✓ Icon created: $ICNS_FILE"
    fi
    
    # Clean up
    rm -rf icon.iconset
else
    echo "WARNING: icon.ico not found, app will have no icon"
fi

# Create Info.plist
echo "Creating Info.plist..."
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
    <string>com.reilua.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

echo "✓ Info.plist created"
echo ""

# Get app size
APP_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)

echo "========================================"
echo "App Bundle Created!"
echo "========================================"
echo ""
echo "App:      $APP_BUNDLE"
echo "Size:     $APP_SIZE"
echo "Location: $(pwd)/$APP_BUNDLE"
echo ""
echo "To test:"
echo "  open $APP_BUNDLE"
echo ""
echo "To distribute:"
echo "  1. Zip the .app bundle:"
echo "     zip -r ${APP_NAME}.zip $APP_BUNDLE"
echo ""
echo "  2. Or create a DMG (requires hdiutil):"
echo "     hdiutil create -volname '$APP_NAME' -srcfolder '$APP_BUNDLE' -ov -format UDZO ${APP_NAME}.dmg"
echo ""
echo "The app bundle includes:"
echo "  - Executable: $APP_BUNDLE/Contents/MacOS/$APP_NAME"
if [ -f "$ICNS_FILE" ]; then
echo "  - Icon: $APP_BUNDLE/Contents/Resources/icon.icns"
else
echo "  - Icon: (not available, provide icon.ico or icon.png)"
fi
echo "  - Info.plist with app metadata"
echo ""
