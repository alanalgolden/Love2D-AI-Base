-- State.lua
-- Base state class for game states

local State = {}
State.__index = State

-- Create a new state
function State.new(name)
    local self = setmetatable({}, State)
    
    -- State properties
    self.name = name or "State"
    self.active = false
    
    return self
end

-- Initialize the state
function State:initialize()
    -- Override in derived states
end

-- Enter the state
function State:enter(data)
    self.active = true
    -- Override in derived states
end

-- Exit the state
function State:exit()
    self.active = false
    -- Override in derived states
end

-- Pause the state
function State:pause()
    -- Override in derived states
end

-- Resume the state
function State:resume()
    -- Override in derived states
end

-- Update the state
function State:update(dt)
    -- Override in derived states
end

-- Draw the state
function State:draw()
    -- Override in derived states
end

-- Handle key press
function State:keypressed(key)
    -- Override in derived states
end

-- Handle key release
function State:keyreleased(key)
    -- Override in derived states
end

-- Handle mouse press
function State:mousepressed(x, y, button)
    -- Override in derived states
end

-- Handle mouse release
function State:mousereleased(x, y, button)
    -- Override in derived states
end

-- Handle mouse movement
function State:mousemoved(x, y, dx, dy)
    -- Override in derived states
end

-- Handle gamepad button press
function State:gamepadpressed(joystick, button)
    -- Override in derived states
end

-- Handle gamepad button release
function State:gamepadreleased(joystick, button)
    -- Override in derived states
end

-- Handle touch press
function State:touchpressed(id, x, y, pressure)
    -- Override in derived states
end

-- Handle touch release
function State:touchreleased(id, x, y, pressure)
    -- Override in derived states
end

-- Handle touch movement
function State:touchmoved(id, x, y, pressure)
    -- Override in derived states
end

-- Check if the state is active
function State:isActive()
    return self.active
end

-- Clean up resources
function State:cleanup()
    -- Override in derived states
end

return State 