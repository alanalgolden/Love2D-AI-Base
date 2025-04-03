# Love2D Game Template

A modern, feature-rich template for creating games with LÖVE (Love2D). This template provides a solid foundation with input handling, UI components, and a robust architecture.

## Features

- **Input System**
  - Supports multiple input types (keyboard, mouse, gamepad, touch)
  - Automatic input type detection and switching
  - Configurable key bindings
  - Gamepad support with button mapping

- **UI System**
  - Modern, responsive UI components
  - Support for both mouse/touch and gamepad/keyboard navigation
  - Focus management for accessibility
  - Button component with hover, press, and focus states
  - Debug overlay for development

- **Asset Management**
  - Robust image loading with multiple fallback layers
  - Automatic fallback to notfound.png when images are missing
  - Text-based fallback when both image and notfound.png are unavailable
  - Organized asset directory structure

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
│   ├── managers/       # System managers (input, UI, etc.)
│   └── utils/          # Utility functions and helpers
├── main.lua           # Main game entry point
└── README.md          # This file
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

## License

This template is available under the MIT License. See the LICENSE file for details. 