# Love2D Input Manager Project

This is a base project for building games with Love2D, featuring a robust input management system that handles keyboard, mouse, gamepad, and touch inputs.

## Project Structure

```
.
├── main.lua              # Main entry point
├── src/
│   └── managers/
│       └── InputManager.lua  # Input management system
└── README.md            # This file
```

## Features

- Automatic input type detection and switching
- Support for all Love2D input methods:
  - Keyboard
  - Mouse
  - Gamepad/Controller
  - Touch
- Input type timeout system (5 seconds of inactivity)
- Visual feedback of current input type
- Clean, modular code structure

## Requirements

- Love2D 11.0 or higher
- Lua 5.1 or higher

## Running the Project

1. Install Love2D from https://love2d.org/
2. Clone this repository
3. Run the project using one of these methods:
   - Drag the project folder onto the Love2D executable
   - Run `love .` from the project directory
   - Use your IDE's Love2D integration

## Testing Input Methods

The project includes a test window that displays the current input type and instructions for testing each input method:

1. Press any key to test keyboard input
2. Move the mouse to test mouse input
3. Connect a controller to test gamepad input
4. Touch the screen to test touch input

## Development Notes

- The input manager automatically switches between input types based on the last used method
- Input types remain active for 5 seconds after the last input
- The project structure is designed to be easily extensible for adding new features

## Future Improvements

- Add input mapping system
- Implement input recording and playback
- Add support for multiple simultaneous input types
- Create input visualization tools 