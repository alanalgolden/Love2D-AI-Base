# Elemental Transmutation 2

A game built with LÖVE (Love2D) engine, focusing on elemental manipulation and puzzle-solving.

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
elementaltransmutation2/
├── main.lua              # Main game entry point
├── src/
│   ├── components/       # UI components
│   │   └── Button.lua   # Button component
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

## Future Development
- Additional UI components
- Game-specific features
- Enhanced input handling
- Performance optimizations

## License
[Your chosen license]

## Contributing
[Your contribution guidelines] 