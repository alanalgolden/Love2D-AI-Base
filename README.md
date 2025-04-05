# Love2D Game Template

A modern, feature-rich template for creating games with LÖVE (Love2D). This template provides a solid foundation with input handling, UI components, and a robust architecture.

## Features

- **Game Engine**
  - Component-based entity system with flexible component management
  - Scene management for different game states
  - Run management for tracking game sessions and history
  - State management for game variables
  - Seed-based randomization for reproducible gameplay
  - Save/load functionality for game progress
  - Debug overlay with F3 toggle
  - Profile management system
  - Window management with proper scaling

- **Input System**
  - Supports multiple input types (keyboard, mouse, gamepad, touch)
  - Automatic input type detection and switching
  - Configurable key bindings
  - Gamepad support with button mapping
  - Joystick direction handling
  - Input type change listeners

- **UI System**
  - Modern, responsive UI components
  - Support for both mouse/touch and gamepad/keyboard navigation
  - Focus management for accessibility
  - Button component with hover, press, and focus states
  - Debug overlay for development
  - Automatic focus management when switching input types
  - Component navigation system (up, down, left, right)
  - Text component with alignment and font size control

- **Asset Management**
  - Robust image loading with multiple fallback layers
  - Automatic fallback to notfound.png when images are missing
  - Text-based fallback when both image and notfound.png are unavailable
  - Organized asset directory structure
  - Font management system

- **Game Systems**
  - Movement system for entity positioning
  - Collision system with circle-based detection
  - Combat system with health and attack management
  - Item system for collectibles and power-ups
  - Entity tagging system
  - Component activation/deactivation
  - System-based architecture for game logic

## Project Structure

```
game-template/
├── assets/
│   ├── images/         # Game images and sprites
│   │   └── notfound.png  # Fallback image for missing assets
│   ├── audio/          # Sound effects and music
│   ├── fonts/          # Custom fonts
│   └── shaders/        # Custom shaders
├── src/
│   ├── components/     # UI and game components
│   ├── engine/         # Core game engine systems
│   ├── managers/       # System managers (input, UI, etc.)
│   ├── scenes/         # Game scenes (menu, game, settings)
│   └── utils/          # Utility functions and helpers
├── main.lua           # Main game entry point
└── README.md          # This file
```

## Game Engine

The template includes a robust game engine with the following features:

### Entity Component System

The engine uses an entity-component system for flexible game object creation:

```lua
local Entity = require('src/engine/Entity')
local Component = require('src/engine/Component')

-- Create an entity
local player = Entity.new("player", "Player")

-- Add components
player:addComponent({
    type = "position",
    x = 100,
    y = 100
})

player:addComponent({
    type = "velocity",
    x = 0,
    y = 0
})

-- Add tags
player:addTag("player")
player:addTag("combatant")

-- Get a component
local position = player:getComponent("position")
position.x = 200

-- Check for tags
if player:hasTag("player") then
    -- Do player-specific logic
end
```

### Scene Management

Scenes manage different game states (menu, gameplay, settings):

```lua
local SceneManager = require('src/engine/SceneManager')

-- Register scenes
SceneManager.registerScene("profile", ProfileScene)
SceneManager.registerScene("menu", MenuScene)
SceneManager.registerScene("game", GameScene)
SceneManager.registerScene("settings", SettingsScene)

-- Set current scene
SceneManager.setScene("profile")

-- Add entities and systems to the current scene
SceneManager.addEntity(player)
SceneManager.addSystem(movementSystem)
```

### Run Management

The RunManager tracks game sessions and progress:

```lua
local RunManager = require('src/engine/RunManager')

-- Start a new run with configuration
RunManager.startNewRun({
    difficulty = "normal",
    seed = 12345
})

-- Get current run information
local currentRun = RunManager.getCurrentRun()
local runHistory = RunManager.getRunHistory()

-- End current run
RunManager.endCurrentRun()
```

### State Management

The StateManager handles game variables and state:

```lua
local StateManager = require('src/engine/StateManager')

-- Set a state variable
StateManager.setState("score", 100)
StateManager.setState("level", 1)

-- Get a state variable
local score = StateManager.getState("score")
local level = StateManager.getState("level")
```

### UI Components

The template includes a robust UI system with various components:

```lua
local Button = require('src/components/Button')
local Text = require('src/components/Text')
local Image = require('src/components/Image')

-- Create a button
local button = Button.new(x, y, width, height, "Click Me", function()
    print("Button clicked!")
end)

-- Set up navigation
button:setNavigation("up", otherButton)
button:setNavigation("down", anotherButton)

-- Create text
local text = Text.new(x, y, width, height, "Hello World", {1, 1, 1, 1})
text:setFontSize(24)
text:setAlignment("center")

-- Create an image with fallback support
local image = Image.new("assets/images/logo.png", x, y, width, height)
image:setRotation(angle)
image:setScale(scaleX, scaleY)
image:setAlpha(0.8)
```

## Asset Handling

The template includes a robust asset handling system with multiple fallback layers:

1. **Primary Asset**: Attempts to load the requested asset
2. **notfound.png**: If the primary asset is missing, falls back to notfound.png
3. **Text Fallback**: If both primary asset and notfound.png are unavailable, displays a text placeholder

### Image Component

The Image component (`src/components/Image.lua`) handles image loading with the following features:

- Automatic fallback handling
- Configurable position, size, rotation, and scale
- Alpha transparency support
- Center-based drawing
- Point collision detection for input handling

Example usage:
```lua
local Image = require('src/components/Image')

-- Create an image with fallback support
local logo = Image.new("assets/images/logo.png", x, y, width, height)

-- Optional: Configure the image
logo:setPosition(newX, newY)
logo:setSize(newWidth, newHeight)
logo:setRotation(angle)
logo:setScale(scaleX, scaleY)
logo:setAlpha(0.8)
```

## Getting Started

1. Clone this repository
2. Install LÖVE (Love2D) from https://love2d.org/
3. Run the game:
   ```bash
   love .
   ```

## Development

### Adding New Assets

1. Place your assets in the appropriate directory under `assets/`
2. Use the provided components to load and display them
3. The fallback system will handle missing assets gracefully

### Adding New Components

1. Create a new component file in `src/components/`
2. Follow the existing component patterns
3. Register the component with the UIManager if it needs input handling

### Creating New Scenes

1. Create a new scene file in `src/scenes/`
2. Inherit from the base Scene class
3. Implement the required methods (initialize, update, draw, cleanup)
4. Register the scene with the SceneManager

### Building the Game

To build the game into a .love file:

```bash
lua build.lua
```

This will create a `game-template.love` file that can be distributed.

## License

This template is available under the MIT License. See the LICENSE file for details. 