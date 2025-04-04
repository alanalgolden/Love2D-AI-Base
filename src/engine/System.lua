-- System.lua
-- Base system class for processing entities

local System = {}
System.__index = System

-- Create a new system
function System.new(name)
    local self = setmetatable({}, System)
    
    -- System properties
    self.name = name or "System"
    self.active = true
    self.requiredComponents = {}
    self.entities = {}
    
    return self
end

-- Initialize the system
function System:initialize()
    -- Override in derived systems
end

-- Update the system
function System:update(dt)
    -- Override in derived systems
end

-- Draw the system
function System:draw()
    -- Override in derived systems
end

-- Add an entity to the system
function System:addEntity(entity)
    -- Check if entity has all required components
    if self:isEntityValid(entity) then
        table.insert(self.entities, entity)
        return true
    end
    return false
end

-- Remove an entity from the system
function System:removeEntity(entity)
    for i, ent in ipairs(self.entities) do
        if ent == entity then
            table.remove(self.entities, i)
            return true
        end
    end
    return false
end

-- Check if an entity is valid for this system
function System:isEntityValid(entity)
    for _, componentType in ipairs(self.requiredComponents) do
        if not entity:hasComponent(componentType) then
            return false
        end
    end
    return true
end

-- Add a required component type
function System:addRequiredComponent(componentType)
    table.insert(self.requiredComponents, componentType)
end

-- Remove a required component type
function System:removeRequiredComponent(componentType)
    for i, type in ipairs(self.requiredComponents) do
        if type == componentType then
            table.remove(self.requiredComponents, i)
            return true
        end
    end
    return false
end

-- Get all required component types
function System:getRequiredComponents()
    return self.requiredComponents
end

-- Activate the system
function System:activate()
    self.active = true
end

-- Deactivate the system
function System:deactivate()
    self.active = false
end

-- Check if the system is active
function System:isActive()
    return self.active
end

-- Clean up resources
function System:cleanup()
    -- Override in derived systems
end

return System 