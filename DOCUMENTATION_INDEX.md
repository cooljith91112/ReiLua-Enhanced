# Documentation Overview

This document provides a quick reference to all available documentation for ReiLua Enhanced Edition.

## Core Documentation

### 📘 [README.md](README.md) - **START HERE**
The main documentation covering:
- What is ReiLua Enhanced Edition
- Complete attributions (Raylib, ReiLua, enhancements)
- Quick start guide
- All enhanced features overview
- Command line options
- Building from source (Windows, Linux, Mac, Raspberry Pi, Web)
- Complete release workflow
- Troubleshooting

**Read this first!**

---

## Feature-Specific Guides

### 🎨 [SPLASH_SCREENS.md](SPLASH_SCREENS.md)
Everything about splash screens:
- How the dual splash screen system works
- Custom text splash screen details
- "Made using Raylib + ReiLua" screen details
- Skipping splashes with `--no-logo` flag
- Customizing text, logos, timing, and colors
- Technical implementation details
- Troubleshooting splash screen issues

### 📦 [EMBEDDING.md](EMBEDDING.md)
Complete guide to embedding:
- Development vs release workflows
- Embedding Lua files (`EMBED_MAIN=ON`)
- Embedding assets (`EMBED_ASSETS=ON`)
- Console control with `--log` flag
- Complete release build workflow
- Asset path consistency
- Troubleshooting embedding issues

### 📊 [ASSET_LOADING.md](ASSET_LOADING.md)
Asset loading system documentation:
- API functions (`BeginAssetLoading`, `UpdateAssetLoading`, `EndAssetLoading`)
- Beautiful 1-bit pixel art loading screen
- Complete examples
- Loading patterns
- Progress tracking
- When to use the loading system
- Customization options

### 🔧 [BUILD_SCRIPTS.md](BUILD_SCRIPTS.md)
Build automation documentation:
- `build_dev.bat` / `build_dev.sh` - Development builds
- `build_release.bat` / `build_release.sh` - Release builds
- Features of each build type
- Workflow examples
- Customizing executable name, icon, and properties
- Troubleshooting build issues

### 🎨 [CUSTOMIZATION.md](CUSTOMIZATION.md)
Complete rebranding guide:
- Changing executable name
- Adding custom icon
- Customizing file properties (company name, version, etc.)
- Customizing splash screens
- Customizing loading screen
- Complete rebranding example
- Removing ReiLua branding (with attribution notes)

### 💻 [ZED_EDITOR_SETUP.md](ZED_EDITOR_SETUP.md)
Complete Zed editor setup:
- Why Zed for ReiLua development
- Installation guide
- Lua Language Server configuration
- Project setup with `.zed/settings.json`
- Task configuration for quick testing
- Essential keyboard shortcuts
- Multi-cursor editing, split views, Vim mode
- Troubleshooting LSP issues
- Workflow tips and best practices

---

## Technical Documentation

### 📚 [API.md](API.md)
Complete API reference:
- 1000+ functions
- All ReiLua/Raylib bindings
- Function signatures
- Raygui, Raymath, Lights, Easings, RLGL modules

### 📝 [ReiLua_API.lua](ReiLua_API.lua)
Lua annotations file:
- Provides autocomplete in LSP-enabled editors
- Function documentation
- Copy to your project for IDE support

### 🔄 [UPGRADE_SUMMARY.md](UPGRADE_SUMMARY.md)
Technical implementation details:
- Features added in this enhanced version
- Files modified and added
- Build options explained
- Testing checklist
- Known changes from original ReiLua

---

## Quick Reference by Task

### "I want to start making a game"
1. Read [README.md](README.md) - Quick Start section
2. Look at examples in `examples/` folder
3. Use `ReiLua.exe --log --no-logo` for development

### "I want to embed my game into a single .exe"
1. Read [EMBEDDING.md](EMBEDDING.md)
2. Use `build_release.bat` / `build_release.sh`
3. Follow the complete release workflow in [README.md](README.md)

### "I want to add a loading screen"
1. Read [ASSET_LOADING.md](ASSET_LOADING.md)
2. Use `RL.BeginAssetLoading()`, `RL.UpdateAssetLoading()`, `RL.EndAssetLoading()`
3. See complete examples in the guide

### "I want to customize splash screens"
1. Read [SPLASH_SCREENS.md](SPLASH_SCREENS.md)
2. Edit `src/splash.c` for text changes
3. Replace logo files in `logo/` folder
4. Rebuild project

### "I want to rebrand the executable"
1. Read [CUSTOMIZATION.md](CUSTOMIZATION.md)
2. Change project name in `CMakeLists.txt`
3. Replace `icon.ico`
4. Edit `resources.rc`
5. Customize splash screens
6. Rebuild

### "I want to setup my code editor"
1. Read [ZED_EDITOR_SETUP.md](ZED_EDITOR_SETUP.md)
2. Install Zed and Lua Language Server
3. Copy `ReiLua_API.lua` to your project
4. Create `.zed/settings.json` configuration
5. Set up tasks for quick testing

### "I want to build ReiLua from source"
1. Read [README.md](README.md) - Building from Source section
2. Install prerequisites (CMake, compiler, Raylib, Lua)
3. Use `build_dev.bat` for development
4. Use `build_release.bat` for release

### "I need API reference"
1. Open [API.md](API.md)
2. Search for function name
3. See function signature and description
4. Or copy [ReiLua_API.lua](ReiLua_API.lua) for autocomplete

---

## Documentation File Sizes

| File | Size | Purpose |
|------|------|---------|
| README.md | 21 KB | Main documentation (START HERE) |
| ZED_EDITOR_SETUP.md | 13 KB | Editor setup guide |
| CUSTOMIZATION.md | 11 KB | Rebranding guide |
| ASSET_LOADING.md | 8 KB | Loading system guide |
| EMBEDDING.md | 7 KB | Embedding guide |
| SPLASH_SCREENS.md | 7 KB | Splash screen guide |
| UPGRADE_SUMMARY.md | 6 KB | Technical details |
| BUILD_SCRIPTS.md | 5 KB | Build automation guide |
| API.md | 207 KB | Complete API reference |

---

## Contribution

When adding new features, please:
1. Update relevant documentation
2. Add examples where appropriate
3. Update this overview if adding new docs
4. Test documentation accuracy

---

## Documentation Standards

All documentation follows these standards:
- ✅ Clear headings and structure
- ✅ Code examples for all features
- ✅ Troubleshooting sections
- ✅ Cross-references to related docs
- ✅ Platform-specific notes where needed
- ✅ Emoji icons for visual scanning
- ✅ Complete but concise

---

## Quick Links

- **Original ReiLua**: https://github.com/Gamerfiend/ReiLua
- **Raylib**: https://github.com/raysan5/raylib
- **Lua**: https://www.lua.org/
- **Zed Editor**: https://zed.dev/

---

**Last Updated**: 2025-01-03
**Documentation Version**: 1.0 (Enhanced Edition)
