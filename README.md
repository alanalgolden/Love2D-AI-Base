# LÖVE Game Template

A template for building games with the LÖVE (Love2D) engine, featuring a robust input and UI system.

## Features

### Input System
- Multi-input support:
  - Keyboard
  - Mouse
  - Touch
  - Gamepad (with both D-pad and analog stick support)
- Smart input type detection and switching
- Input timeout system to handle inactive periods
- Joystick deadzone and repeat delay for smooth navigation
- Input type cooldown (1 second) to prevent rapid switching
- Seamless switching between input methods
- Debug overlay (F3) for input type visualization

### UI System
- Component-based architecture
- Responsive button system with:
  - Hover effects
  - Click/tap handling
  - Focus management
  - Keyboard/gamepad navigation
- Cross-platform scaling and resolution handling

### Project Structure
```
game-template/
├── main.lua              # Main game entry point
├── src/
│   ├── components/       # UI components
│   │   ├── Button.lua   # Button component
│   │   └── DebugOverlay.lua  # Debug information display
│   └── managers/        # Game systems
│       ├── InputManager.lua    # Input handling
│       ├── UIManager.lua       # UI management
│       └── WindowManager.lua   # Window and scaling
└── README.md
```

## Technical Details

### Input Management
The game uses a sophisticated input management system that:
- Automatically detects and switches between input types
- Maintains input state with timeout handling
- Provides smooth joystick navigation with configurable deadzone
- Supports both digital (D-pad) and analog (joystick) input
- Prevents rapid input type switching with a 1-second cooldown
- Allows seamless switching between keyboard and gamepad
- Includes a debug overlay (F3) for input type visualization

### UI Components
The UI system is built on a component-based architecture:
- Components are self-contained and reusable
- Support for multiple input types
- Built-in focus and navigation system
- Responsive to different screen sizes

### Window Management
The window system handles:
- Cross-platform resolution scaling
- Aspect ratio maintenance
- Responsive UI positioning

## Development

### Prerequisites
- LÖVE (Love2D) engine
- Lua 5.1 or later

### Building
To create a `.love` file for distribution:
```bash
zip -r game.love main.lua src/ README.md
```

### Testing
The game can be tested on various platforms:
- Desktop (Windows, macOS, Linux)
- Mobile (Android, iOS)
- Different input methods (keyboard, mouse, touch, gamepad)

### Debug Features
- Press F3 to toggle the debug overlay
- Debug overlay shows current input type
- Helps with testing input system behavior

## Future Development
- Additional UI components
- Game-specific features
- Enhanced input handling
- Performance optimizations

## License
[Your chosen license]

## Contributing
[Your contribution guidelines] 