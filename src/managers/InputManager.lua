-- InputManager.lua
-- This module handles all input types (keyboard, mouse, gamepad, touch)
-- and manages switching between them based on the last used input method

local InputManager = {}

-- Input types
local INPUT_TYPES = {
    KEYBOARD = "keyboard",
    MOUSE = "mouse",
    GAMEPAD = "gamepad",
    TOUCH = "touch"
}

-- State
local state = {
    currentInputType = nil,
    lastInputTime = 0,
    inputTimeout = 5, -- seconds before input type is considered inactive
    lastInput = {
        keyboard = 0,
        mouse = 0,
        gamepad = 0,
        touch = 0
    }
}

-- Initialize the input manager
function InputManager.initialize()
    -- Check for connected gamepads
    if love.joystick.getJoystickCount() > 0 then
        state.currentInputType = INPUT_TYPES.GAMEPAD
    end
end

-- Update the input manager state
function InputManager.update(dt)
    local currentTime = love.timer.getTime()
    
    -- Check if current input type has timed out
    if state.currentInputType and (currentTime - state.lastInputTime) > state.inputTimeout then
        state.currentInputType = nil
    end
end

-- Get the current input type
function InputManager.getCurrentInputType()
    return state.currentInputType
end

-- Helper function to update input type
local function updateInputType(inputType)
    state.currentInputType = inputType
    state.lastInputTime = love.timer.getTime()
    state.lastInput[inputType] = state.lastInputTime
end

-- Keyboard input handlers
function InputManager.handleKeyPressed(key)
    updateInputType(INPUT_TYPES.KEYBOARD)
end

function InputManager.handleKeyReleased(key)
    -- Keyboard input type remains active until timeout
end

-- Mouse input handlers
function InputManager.handleMousePressed(x, y, button)
    updateInputType(INPUT_TYPES.MOUSE)
end

function InputManager.handleMouseReleased(x, y, button)
    -- Mouse input type remains active until timeout
end

function InputManager.handleMouseMoved(x, y, dx, dy)
    updateInputType(INPUT_TYPES.MOUSE)
end

-- Gamepad input handlers
function InputManager.handleGamepadPressed(joystick, button)
    updateInputType(INPUT_TYPES.GAMEPAD)
end

function InputManager.handleGamepadReleased(joystick, button)
    -- Gamepad input type remains active until timeout
end

-- Touch input handlers
function InputManager.handleTouchPressed(id, x, y, pressure)
    updateInputType(INPUT_TYPES.TOUCH)
end

function InputManager.handleTouchReleased(id, x, y, pressure)
    -- Touch input type remains active until timeout
end

function InputManager.handleTouchMoved(id, x, y, pressure)
    updateInputType(INPUT_TYPES.TOUCH)
end

-- Helper function to check if a specific input type is active
function InputManager.isInputTypeActive(inputType)
    return state.currentInputType == inputType
end

-- Helper function to get the last time an input type was used
function InputManager.getLastInputTime(inputType)
    return state.lastInput[inputType] or 0
end

return InputManager 