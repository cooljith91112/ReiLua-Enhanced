# Asset Loading System

ReiLua includes a built-in asset loading system with a nice loading screen UI that automatically shows progress while assets are being loaded.

## 🎨 Features

- **Automatic Progress Tracking** - Tracks how many assets have been loaded
- **Beautiful Loading UI** - Modern, minimal loading screen with:
  - Animated "Loading..." text with dots
  - Smooth progress bar with shimmer effect
  - Progress percentage (e.g., "3 / 10")
  - Current asset name being loaded
  - Dark, professional color scheme
- **Easy to Use** - Just 3 functions to show loading progress
- **Works Everywhere** - Development and release builds

## 📝 API Functions

### RL.BeginAssetLoading(totalAssets)

Initialize asset loading progress tracking and show the loading screen.

**Parameters:**
- `totalAssets` (integer) - Total number of assets to load

**Example:**
```lua
RL.BeginAssetLoading(10)  -- We're loading 10 assets
```

---

### RL.UpdateAssetLoading(assetName)

Update the loading progress and display current asset being loaded.

**Parameters:**
- `assetName` (string) - Name of the asset currently being loaded

**Example:**
```lua
RL.UpdateAssetLoading("player.png")
```

Call this **after** each asset is loaded to update the progress bar.

---

### RL.EndAssetLoading()

Finish asset loading and hide the loading screen.

**Example:**
```lua
RL.EndAssetLoading()
```

## 🚀 Quick Example

```lua
function RL.init()
    -- List of assets to load
    local assetsToLoad = {
        "assets/player.png",
        "assets/enemy.png", 
        "assets/background.png",
        "assets/music.wav",
    }
    
    -- Begin loading
    RL.BeginAssetLoading(#assetsToLoad)
    
    -- Load each asset
    for i, path in ipairs(assetsToLoad) do
        RL.UpdateAssetLoading(path)  -- Update progress
        
        -- Load the actual asset
        if path:match("%.png$") or path:match("%.jpg$") then
            textures[i] = RL.LoadTexture(path)
        elseif path:match("%.wav$") or path:match("%.ogg$") then
            sounds[i] = RL.LoadSound(path)
        end
    end
    
    -- Done!
    RL.EndAssetLoading()
end
```

## 💡 Complete Example

```lua
local assets = {}

local assetsToLoad = {
    {type="texture", name="player", path="assets/player.png"},
    {type="texture", name="enemy", path="assets/enemy.png"},
    {type="texture", name="background", path="assets/background.png"},
    {type="sound", name="music", path="assets/music.wav"},
    {type="sound", name="shoot", path="assets/shoot.wav"},
    {type="font", name="title", path="assets/title.ttf"},
}

function RL.init()
    RL.SetWindowTitle("My Game")
    
    -- Start loading with progress
    RL.BeginAssetLoading(#assetsToLoad)
    
    -- Load all assets
    for i, asset in ipairs(assetsToLoad) do
        -- Show current asset name on loading screen
        RL.UpdateAssetLoading(asset.name)
        
        -- Load based on type
        if asset.type == "texture" then
            assets[asset.name] = RL.LoadTexture(asset.path)
        elseif asset.type == "sound" then
            assets[asset.name] = RL.LoadSound(asset.path)
        elseif asset.type == "font" then
            assets[asset.name] = RL.LoadFont(asset.path)
        end
    end
    
    -- Loading complete!
    RL.EndAssetLoading()
    
    print("Game ready!")
end

function RL.update(delta)
    -- Your game logic
end

function RL.draw()
    RL.ClearBackground(RL.RAYWHITE)
    
    -- Use loaded assets
    if assets.background then
        RL.DrawTexture(assets.background, {0, 0}, RL.WHITE)
    end
    
    if assets.player then
        RL.DrawTexture(assets.player, {100, 100}, RL.WHITE)
    end
end
```

## 🎨 Loading Screen Appearance

The loading screen features a clean 1-bit pixel art style:

**Design:**
- Pure black and white aesthetic
- Retro pixel art styling
- Minimal and clean design

**Elements:**
- **Title**: "LOADING" in bold white pixel text
- **Animated Dots**: White pixelated dots (4x4 squares) that cycle
- **Progress Bar**: 
  - 200px wide, 16px tall
  - Thick 2px white border (pixel art style)
  - White fill with black dithering pattern
  - Retro/Classic terminal aesthetic
- **Progress Text**: "3/10" in white pixel font style
- **Asset Name**: Current loading asset in small white text
- **Corner Decorations**: White pixel art L-shaped corners in all 4 corners

**Background:**
- Pure black background (#000000)
- High contrast for maximum clarity

**Color Palette:**
- White text and UI (#FFFFFF)
- Black background (#000000)
- Pure 1-bit aesthetic (inverted terminal style)

**Visual Layout:**
```
[Black Background]

┌─┐                                                               ┌─┐
│ │                         LOADING  □ □                          │ │
│ │                                                               │ │
│ │                      ┌──────────────────┐                    │ │
│ │                      │████████░░░░░░░░░░│    3/10            │ │
│ │                      └──────────────────┘                    │ │
│ │                                                               │ │
│ │                        player.png                            │ │
│ │                                                               │ │
└─┘                                                               └─┘

[All text and UI elements in WHITE]
```

**Style Inspiration:**
- Classic terminal / console aesthetic
- MS-DOS loading screens
- 1-bit dithering patterns
- Chunky pixel borders
- Retro computing / CRT monitor style

## 🔧 Customization

If you want to customize the loading screen appearance, you can modify the colors and sizes in `src/lua_core.c` in the `drawLoadingScreen()` function.

## ⚡ Performance Tips

1. **Call UpdateAssetLoading AFTER loading** - This ensures the progress updates at the right time
2. **Load assets in order of importance** - Load critical assets first
3. **Group similar assets** - Load all textures, then sounds, etc.
4. **Use descriptive names** - Shows better feedback to users

## 📋 Example Asset Loading Patterns

### Pattern 1: Simple List
```lua
local files = {"player.png", "enemy.png", "music.wav"}
RL.BeginAssetLoading(#files)
for i, file in ipairs(files) do
    RL.UpdateAssetLoading(file)
    -- load file
end
RL.EndAssetLoading()
```

### Pattern 2: With Types
```lua
local assets = {
    textures = {"player.png", "enemy.png"},
    sounds = {"music.wav", "shoot.wav"},
}
local total = #assets.textures + #assets.sounds

RL.BeginAssetLoading(total)
for _, file in ipairs(assets.textures) do
    RL.UpdateAssetLoading(file)
    -- load texture
end
for _, file in ipairs(assets.sounds) do
    RL.UpdateAssetLoading(file)
    -- load sound
end
RL.EndAssetLoading()
```

### Pattern 3: Error Handling
```lua
RL.BeginAssetLoading(#files)
for i, file in ipairs(files) do
    RL.UpdateAssetLoading(file)
    
    if RL.FileExists(file) then
        -- load file
    else
        print("Warning: " .. file .. " not found")
    end
end
RL.EndAssetLoading()
```

## 🎮 When to Use

**Use the loading system when:**
- You have more than 5-10 assets to load
- Assets are large (images, sounds, fonts)
- Loading might take more than 1 second
- You want professional loading feedback

**You can skip it when:**
- You have very few, small assets
- Loading is nearly instant
- You prefer immediate game start

## ✨ Benefits

- ✅ Professional user experience
- ✅ User knows the game is loading, not frozen
- ✅ Shows progress for large asset sets
- ✅ Works with embedded assets
- ✅ Minimal code required
- ✅ Beautiful default UI

The loading system makes your game feel polished and professional with just a few lines of code!
