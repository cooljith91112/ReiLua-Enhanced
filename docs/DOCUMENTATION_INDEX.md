# Documentation Overview

This document provides a quick reference to all available documentation for ReiLua Enhanced Edition.

## Core Documentation

**README.md** - START HERE

The main documentation covering: what is ReiLua Enhanced Edition, complete attributions (Raylib, ReiLua, enhancements), quick start guide, all enhanced features overview, command line options, building from source (Windows, Linux, Mac, Raspberry Pi, Web), complete release workflow, and troubleshooting.

Read this first!

---

## Feature-Specific Guides

**SPLASH_SCREENS.md** - Everything about splash screens

How the dual splash screen system works, custom text splash screen details, "Made using Raylib + ReiLua" screen details, skipping splashes with `--no-logo` flag, customizing text, logos, timing, and colors, technical implementation details, and troubleshooting.

**EMBEDDING.md** - Complete guide to embedding

Development vs release workflows, embedding Lua files (`EMBED_MAIN=ON`), embedding assets (`EMBED_ASSETS=ON`), console control with `--log` flag, complete release build workflow, asset path consistency, and troubleshooting.

**ASSET_LOADING.md** - Asset loading system documentation

API functions (`BeginAssetLoading`, `UpdateAssetLoading`, `EndAssetLoading`), beautiful 1-bit pixel art loading screen, complete examples, loading patterns, progress tracking, when to use the loading system, and customization options.

**BUILD_SCRIPTS.md** - Build automation documentation

`scripts\build_dev.bat` / `scripts/build_dev.sh` for development builds, `scripts\build_release.bat` / `scripts/build_release.sh` for release builds, features of each build type, workflow examples, customizing executable name, icon, and properties, and troubleshooting.

**CUSTOMIZATION.md** - Complete rebranding guide

Changing executable name, adding custom icon, customizing file properties (company name, version, etc.), customizing splash screens, customizing loading screen, complete rebranding example, and removing ReiLua branding (with attribution notes).

**ZED_EDITOR_SETUP.md** - Complete Zed editor setup

Why Zed for ReiLua development, installation guide, Lua Language Server configuration, project setup with `.zed/settings.json`, task configuration for quick testing, essential keyboard shortcuts, multi-cursor editing, split views, Vim mode, troubleshooting LSP issues, and workflow tips.

---

## Technical Documentation

**API.md** - Complete API reference

1000+ functions, all ReiLua/Raylib bindings, function signatures, Raygui, Raymath, Lights, Easings, and RLGL modules.

**tools/ReiLua_API.lua** - Lua annotations file

Provides autocomplete in LSP-enabled editors, function documentation. Copy to your project for IDE support.

**UPGRADE_SUMMARY.md** - Technical implementation details

Features added in this enhanced version, files modified and added, build options explained, testing checklist, and known changes from original ReiLua

---

## Quick Reference by Task

I want to start making a game

1. Read README.md - Quick Start section
2. Look at examples in `examples/` folder
3. Use `ReiLua.exe --log --no-logo` for development

I want to embed my game into a single .exe

1. Read EMBEDDING.md
2. Use `scripts\build_release.bat` / `scripts/build_release.sh`
3. Follow the complete release workflow in README.md

I want to add a loading screen

1. Read ASSET_LOADING.md
2. Use `RL.BeginAssetLoading()`, `RL.UpdateAssetLoading()`, `RL.EndAssetLoading()`
3. See complete examples in the guide

I want to customize splash screens

1. Read SPLASH_SCREENS.md
2. Edit `src/splash.c` for text changes
3. Replace logo files in `logo/` folder
4. Rebuild project

I want to rebrand the executable

1. Read CUSTOMIZATION.md
2. Change project name in `CMakeLists.txt`
3. Replace `icon.ico`
4. Edit `resources.rc`
5. Customize splash screens
6. Rebuild

I want to setup my code editor

1. Read ZED_EDITOR_SETUP.md
2. Install Zed and Lua Language Server
3. Copy `tools/ReiLua_API.lua` to your project
4. Create `.zed/settings.json` configuration
5. Set up tasks for quick testing

I want to build ReiLua from source

1. Read README.md - Building from Source section
2. Install prerequisites (CMake, compiler, Raylib, Lua)
3. Use `scripts\build_dev.bat` for development
4. Use `scripts\build_release.bat` for release

I need API reference

1. Open API.md
2. Search for function name
3. See function signature and description
4. Or copy tools/ReiLua_API.lua for autocomplete

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
- Clear headings and structure
- Code examples for all features
- Troubleshooting sections
- Cross-references to related docs
- Platform-specific notes where needed
- Complete but concise

---

## Quick Links

- Original ReiLua: https://github.com/Gamerfiend/ReiLua
- Raylib: https://github.com/raysan5/raylib
- Lua: https://www.lua.org/
- Zed Editor: https://zed.dev/

---

**Last Updated**: 2025-01-03
**Documentation Version**: 1.0 (Enhanced Edition)
