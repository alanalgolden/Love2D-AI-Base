-- Component.lua
-- Base component class for entity behaviors

local Component = {}
Component.__index = Component

-- Create a new component
function Component.new(type)
    local self = setmetatable({}, Component)
    
    -- Component properties
    self.type = type or "unknown"
    self.entity = nil
    self.active = true
    
    return self
end

-- Initialize the component
function Component:initialize()
    -- Override in derived components
end

-- Update the component
function Component:update(dt)
    -- Override in derived components
end

-- Draw the component
function Component:draw()
    -- Override in derived components
end

-- Activate the component
function Component:activate()
    self.active = true
end

-- Deactivate the component
function Component:deactivate()
    self.active = false
end

-- Check if the component is active
function Component:isActive()
    return self.active
end

-- Clean up resources
function Component:cleanup()
    -- Override in derived components
end

-- Get the entity this component belongs to
function Component:getEntity()
    return self.entity
end

-- Set the entity this component belongs to
function Component:setEntity(entity)
    self.entity = entity
end

return Component 