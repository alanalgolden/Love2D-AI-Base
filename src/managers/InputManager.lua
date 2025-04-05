-- InputManager.lua
-- Manages input types and their state

local InputManager = {}

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
    },
    onInputTypeChanged = nil, -- Callback for input type changes
    keyPressCallbacks = {},   -- List of key press callbacks
    joystickDeadzone = 0.5,   -- Minimum value for joystick movement
    lastJoystickDirection = nil,
    joystickRepeatDelay = 0.2, -- Delay between joystick navigation events
    lastJoystickTime = 0,
    lastInputTypeChange = 0,  -- Time of last input type change
    inputTypeCooldown = 1.0,  -- Cooldown in seconds before allowing input type change
    onGamepadPress = nil      -- Callback for gamepad button press events
}

-- Input types
local INPUT_TYPES = {
    KEYBOARD = "keyboard",
    MOUSE = "mouse",
    GAMEPAD = "gamepad",
    TOUCH = "touch"
}

-- Helper function to update input type
function InputManager.updateInputType(inputType)
    InputManager.setInputType(inputType)
    state.lastInputTime = love.timer.getTime()
    state.lastInput[inputType] = state.lastInputTime
end

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
        InputManager.setInputType(nil)
    end
    
    -- Always check for joystick movement
    InputManager.handleJoystickMovement(dt)
end

-- Handle joystick movement
function InputManager.handleJoystickMovement(dt)
    local currentTime = love.timer.getTime()
    
    -- Get the first connected joystick
    local joystick = love.joystick.getJoysticks()[1]
    if not joystick then return end
    
    -- Get left stick values
    local axisX = joystick:getAxis(1)
    local axisY = joystick:getAxis(2)
    
    -- Check if joystick is moved beyond deadzone
    if math.abs(axisX) > state.joystickDeadzone or math.abs(axisY) > state.joystickDeadzone then
        -- Update input type to gamepad
        InputManager.updateInputType(INPUT_TYPES.GAMEPAD)
        
        -- Determine direction based on axis values
        local direction = nil
        if math.abs(axisX) > state.joystickDeadzone then
            direction = axisX > 0 and "right" or "left"
        elseif math.abs(axisY) > state.joystickDeadzone then
            direction = axisY > 0 and "down" or "up"
        end
        
        -- Handle direction change or repeat
        if direction then
            if direction ~= state.lastJoystickDirection then
                -- New direction, trigger immediately
                state.lastJoystickDirection = direction
                state.lastJoystickTime = currentTime
                if state.onJoystickDirection then
                    state.onJoystickDirection(direction)
                end
            elseif currentTime - state.lastJoystickTime > state.joystickRepeatDelay then
                -- Same direction, repeat after delay
                state.lastJoystickTime = currentTime
                if state.onJoystickDirection then
                    state.onJoystickDirection(direction)
                end
            end
        end
    else
        state.lastJoystickDirection = nil
    end
end

-- Get the current input type
function InputManager.getCurrentInputType()
    return state.currentInputType
end

-- Set the current input type and notify listeners
function InputManager.setInputType(inputType)
    local currentTime = love.timer.getTime()
    
    -- Check cooldown
    if state.currentInputType ~= inputType and 
       (currentTime - state.lastInputTypeChange) < state.inputTypeCooldown then
        return
    end
    
    if state.currentInputType ~= inputType then
        state.currentInputType = inputType
        state.lastInputTypeChange = currentTime
        if state.onInputTypeChanged then
            state.onInputTypeChanged(inputType)
        end
    end
end

-- Set callback for input type changes
function InputManager.setOnInputTypeChanged(callback)
    state.onInputTypeChanged = callback
end

-- Set callback for joystick direction changes
function InputManager.setOnJoystickDirection(callback)
    state.onJoystickDirection = callback
end

-- Set key press callback
function InputManager.setOnKeyPressed(callback)
    table.insert(state.keyPressCallbacks, callback)
end

-- Handle key press
function InputManager.handleKeyPress(key)
    -- Update input type to keyboard
    InputManager.updateInputType(INPUT_TYPES.KEYBOARD)
    
    -- Reset the last input time for keyboard
    state.lastInputTime = love.timer.getTime()
    
    -- Call all key press callbacks
    for _, callback in ipairs(state.keyPressCallbacks) do
        if callback(key) then
            -- If a callback returns true, it handled the key
            return
        end
    end
end

-- Keyboard input handlers
function InputManager.handleKeyPressed(key)
    InputManager.handleKeyPress(key)
end

function InputManager.handleKeyReleased(key)
    -- Keyboard input type remains active until timeout
end

-- Mouse input handlers
function InputManager.handleMousePressed(x, y, button)
    InputManager.updateInputType(INPUT_TYPES.MOUSE)
end

function InputManager.handleMouseReleased(x, y, button)
    -- Mouse input type remains active until timeout
end

function InputManager.handleMouseMoved(x, y, dx, dy)
    InputManager.updateInputType(INPUT_TYPES.MOUSE)
end

-- Gamepad input handlers
function InputManager.handleGamepadPressed(joystick, button)
    InputManager.updateInputType(INPUT_TYPES.GAMEPAD)
end

function InputManager.handleGamepadReleased(joystick, button)
    -- Gamepad input type remains active until timeout
end

-- Touch input handlers
function InputManager.handleTouchPressed(id, x, y, pressure)
    InputManager.updateInputType(INPUT_TYPES.TOUCH)
end

function InputManager.handleTouchReleased(id, x, y, pressure)
    -- Touch input type remains active until timeout
end

function InputManager.handleTouchMoved(id, x, y, pressure)
    InputManager.updateInputType(INPUT_TYPES.TOUCH)
end

-- Helper function to check if a specific input type is active
function InputManager.isInputTypeActive(inputType)
    return state.currentInputType == inputType
end

-- Helper function to get the last time an input type was used
function InputManager.getLastInputTime(inputType)
    return state.lastInput[inputType] or 0
end

-- Set callback for gamepad button press
function InputManager.setOnGamepadPress(callback)
    state.onGamepadPress = callback
end

-- Handle gamepad input
function InputManager.handleGamepadPress(joystick, button)
    InputManager.updateInputType(INPUT_TYPES.GAMEPAD)
    if state.onGamepadPress then
        state.onGamepadPress(button)
    end
end

-- Reset input state
function InputManager.reset()
    -- Reset input type
    state.currentInputType = nil
    
    -- Reset last input times
    state.lastInputTime = 0
    for inputType, _ in pairs(state.lastInput) do
        state.lastInput[inputType] = 0
    end
    
    -- Reset joystick state
    state.lastJoystickDirection = nil
    state.lastJoystickTime = 0
    
    -- Reset input type change cooldown
    state.lastInputTypeChange = 0
end

return InputManager 