# Place your game assets here

## Recommended Structure

```
assets/
├── images/
│   ├── player.png
│   ├── enemy.png
│   └── background.png
├── sounds/
│   ├── jump.wav
│   └── shoot.wav
├── music/
│   └── theme.ogg
└── fonts/
    └── game_font.ttf
```

## Sprite Sheet Guidelines

### Grid-Based Animations
- Use equal-sized frames arranged in a grid
- Frames are read left-to-right, top-to-bottom
- Example: 32x32 pixel frames

### Example Layout
```
Frame 1  Frame 2  Frame 3  Frame 4
Frame 5  Frame 6  Frame 7  Frame 8
```

### Recommended Sizes
- Player: 32x32 or 64x64
- Enemies: 32x32
- Effects: 16x16, 32x32, or 64x64
- Backgrounds: Match your game resolution

## Audio Guidelines

### Sound Effects
- Format: WAV (uncompressed) or OGG (compressed)
- Short sounds (< 2 seconds): Use WAV
- Length: Keep under 5 seconds for quick loading

### Music
- Format: OGG (recommended for size)
- Use streaming (LoadMusicStream) for music
- Sample rate: 44100 Hz recommended

## Loading Assets

### In Lua
```lua
-- Images
local playerImg = RL.LoadTexture("assets/images/player.png")

-- Sounds
local jumpSound = RL.LoadSound("assets/sounds/jump.wav")

-- Music (streaming)
local music = RL.LoadMusicStream("assets/music/theme.ogg")

-- Fonts
local font = RL.LoadFont("assets/fonts/game_font.ttf")
```

### With Loading Screen
```lua
local assetsToLoad = {
  "assets/images/player.png",
  "assets/sounds/jump.wav",
  "assets/music/theme.ogg"
}

RL.BeginAssetLoading(#assetsToLoad)
for _, asset in ipairs(assetsToLoad) do
  RL.UpdateAssetLoading(asset)
  -- Load the asset...
end
RL.EndAssetLoading()
```

## Tips

- Keep asset sizes reasonable (< 2MB per file for quick loading)
- Use PNG for images with transparency
- Use JPG for photos/backgrounds (smaller size)
- Optimize images before adding to game
- Test loading times during development
