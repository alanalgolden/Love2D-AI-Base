-- StateManager.lua
-- Manages game state transitions and state-specific logic

local StateManager = {}

-- Import dependencies
local Logger = require('src/utils/logger')
local GameEngine = require('src/engine/GameEngine')

-- State manager state
local state = {
    currentState = nil,
    previousState = nil,
    states = {},
    stateStack = {},
    stateData = {}
}

-- Initialize the state manager
function StateManager.initialize()
    Logger.info("Initializing State Manager")
    -- This will be called by the GameEngine
end

-- Register a state
function StateManager.registerState(name, stateObject)
    if state.states[name] then
        Logger.warning("State already registered: " .. name)
        return false
    end
    
    state.states[name] = stateObject
    Logger.info("Registered state: " .. name)
    return true
end

-- Set the current state
function StateManager.setState(name, data)
    if not state.states[name] then
        Logger.error("State not found: " .. name)
        return false
    end
    
    -- Store previous state
    state.previousState = state.currentState
    
    -- Exit current state if it exists
    if state.currentState and state.states[state.currentState].exit then
        state.states[state.currentState]:exit()
    end
    
    -- Set new state
    state.currentState = name
    
    -- Store state data
    state.stateData[name] = data or {}
    
    -- Enter new state
    if state.states[name].enter then
        state.states[name]:enter(state.stateData[name])
    end
    
    Logger.info("Set current state to: " .. name)
    return true
end

-- Push a state onto the stack
function StateManager.pushState(name, data)
    if not state.states[name] then
        Logger.error("State not found: " .. name)
        return false
    end
    
    -- Pause current state if it exists
    if state.currentState and state.states[state.currentState].pause then
        state.states[state.currentState]:pause()
    end
    
    -- Push current state onto stack
    if state.currentState then
        table.insert(state.stateStack, state.currentState)
    end
    
    -- Set new state
    state.currentState = name
    
    -- Store state data
    state.stateData[name] = data or {}
    
    -- Enter new state
    if state.states[name].enter then
        state.states[name]:enter(state.stateData[name])
    end
    
    Logger.info("Pushed state onto stack: " .. name)
    return true
end

-- Pop a state from the stack
function StateManager.popState()
    if #state.stateStack == 0 then
        Logger.warning("State stack is empty")
        return false
    end
    
    -- Exit current state
    if state.currentState and state.states[state.currentState].exit then
        state.states[state.currentState]:exit()
    end
    
    -- Pop previous state from stack
    local previousState = table.remove(state.stateStack)
    state.currentState = previousState
    
    -- Resume previous state
    if state.states[previousState].resume then
        state.states[previousState]:resume()
    end
    
    Logger.info("Popped state from stack, current state: " .. previousState)
    return true
end

-- Get the current state
function StateManager.getCurrentState()
    return state.currentState
end

-- Get the previous state
function StateManager.getPreviousState()
    return state.previousState
end

-- Get state data
function StateManager.getStateData(stateName)
    return state.stateData[stateName]
end

-- Set state data
function StateManager.setStateData(stateName, data)
    state.stateData[stateName] = data
end

-- Update the current state
function StateManager.update(dt)
    if state.currentState and state.states[state.currentState].update then
        state.states[state.currentState]:update(dt)
    end
end

-- Draw the current state
function StateManager.draw()
    if state.currentState and state.states[state.currentState].draw then
        state.states[state.currentState]:draw()
    end
end

-- Handle key press in the current state
function StateManager.keypressed(key)
    if state.currentState and state.states[state.currentState].keypressed then
        state.states[state.currentState]:keypressed(key)
    end
end

-- Handle key release in the current state
function StateManager.keyreleased(key)
    if state.currentState and state.states[state.currentState].keyreleased then
        state.states[state.currentState]:keyreleased(key)
    end
end

-- Handle mouse press in the current state
function StateManager.mousepressed(x, y, button)
    if state.currentState and state.states[state.currentState].mousepressed then
        state.states[state.currentState]:mousepressed(x, y, button)
    end
end

-- Handle mouse release in the current state
function StateManager.mousereleased(x, y, button)
    if state.currentState and state.states[state.currentState].mousereleased then
        state.states[state.currentState]:mousereleased(x, y, button)
    end
end

-- Handle mouse movement in the current state
function StateManager.mousemoved(x, y, dx, dy)
    if state.currentState and state.states[state.currentState].mousemoved then
        state.states[state.currentState]:mousemoved(x, y, dx, dy)
    end
end

-- Handle gamepad button press in the current state
function StateManager.gamepadpressed(joystick, button)
    if state.currentState and state.states[state.currentState].gamepadpressed then
        state.states[state.currentState]:gamepadpressed(joystick, button)
    end
end

-- Handle gamepad button release in the current state
function StateManager.gamepadreleased(joystick, button)
    if state.currentState and state.states[state.currentState].gamepadreleased then
        state.states[state.currentState]:gamepadreleased(joystick, button)
    end
end

-- Handle touch press in the current state
function StateManager.touchpressed(id, x, y, pressure)
    if state.currentState and state.states[state.currentState].touchpressed then
        state.states[state.currentState]:touchpressed(id, x, y, pressure)
    end
end

-- Handle touch release in the current state
function StateManager.touchreleased(id, x, y, pressure)
    if state.currentState and state.states[state.currentState].touchreleased then
        state.states[state.currentState]:touchreleased(id, x, y, pressure)
    end
end

-- Handle touch movement in the current state
function StateManager.touchmoved(id, x, y, pressure)
    if state.currentState and state.states[state.currentState].touchmoved then
        state.states[state.currentState]:touchmoved(id, x, y, pressure)
    end
end

return StateManager 