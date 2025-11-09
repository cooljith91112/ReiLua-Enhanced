# ReiLua-Enhanced - macOS Setup

## Quick Start

### 1. Install Dependencies
```bash
brew install glfw raylib lua pkg-config
```

### 2. Build Static Libraries (One Time)
```bash
./scripts/macos/build_static_libs.sh
```

This creates `lib/macos/libraylib.a` and `lib/macos/liblua.a` for distribution builds.

### 3. Build Your Project
```bash
./scripts/build_dev.sh        # Development
./scripts/build_release.sh    # Release with embedded assets
```

### 4. Create App Bundle (macOS Distribution)
```bash
./scripts/macos/create_app_bundle.sh
```

## Build Modes

### Static Libraries (Recommended)
- Creates single executable with no external dependencies
- Required for distribution
- Run `build_static_libs.sh` once to set up

### Homebrew Libraries (Development)
- Faster builds during development
- Automatically used if static libs not found
- Requires users to have Homebrew packages installed

## Icon Support

Windows: Icon embedded via `resources.rc`
macOS: Icon requires .app bundle via `create_app_bundle.sh`

## Directory Structure

```
/your/dev/folder/
├── ReiLua-Enhanced/
├── lua/          (Lua 5.4 source)
└── raylib/       (Raylib 5.5 source)
```

Build scripts automatically find lua and raylib as sibling directories.

## Troubleshooting

**Missing static libraries:**
Run `./scripts/macos/build_static_libs.sh`

**Missing Homebrew packages:**
```bash
brew install glfw raylib lua pkg-config
```

**GLFW duplicate warnings:**
Harmless. Raylib includes its own GLFW.
