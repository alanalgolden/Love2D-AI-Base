-- Entity.lua
-- Base entity class for game objects

local Entity = {}
Entity.__index = Entity

-- Create a new entity
function Entity.new(id, name)
    local self = setmetatable({}, Entity)
    
    -- Entity properties
    self.id = id or tostring(os.time()) .. "_" .. math.random(1000, 9999)
    self.name = name or "Entity"
    self.active = true
    self.components = {}
    self.tags = {}
    
    return self
end

-- Initialize the entity
function Entity:initialize()
    -- Override in derived entities
end

-- Update the entity
function Entity:update(dt)
    -- Update all components
    for _, component in pairs(self.components) do
        if component.update then
            component:update(dt)
        end
    end
end

-- Draw the entity
function Entity:draw()
    -- Draw all components
    for _, component in pairs(self.components) do
        if component.draw then
            component:draw()
        end
    end
end

-- Add a component to the entity
function Entity:addComponent(component)
    local componentType = component.type or "unknown"
    self.components[componentType] = component
    component.entity = self
    return component
end

-- Remove a component from the entity
function Entity:removeComponent(componentType)
    if self.components[componentType] then
        self.components[componentType] = nil
        return true
    end
    return false
end

-- Get a component by type
function Entity:getComponent(componentType)
    return self.components[componentType]
end

-- Check if the entity has a component
function Entity:hasComponent(componentType)
    return self.components[componentType] ~= nil
end

-- Add a tag to the entity
function Entity:addTag(tag)
    self.tags[tag] = true
end

-- Remove a tag from the entity
function Entity:removeTag(tag)
    self.tags[tag] = nil
end

-- Check if the entity has a tag
function Entity:hasTag(tag)
    return self.tags[tag] == true
end

-- Activate the entity
function Entity:activate()
    self.active = true
end

-- Deactivate the entity
function Entity:deactivate()
    self.active = false
end

-- Check if the entity is active
function Entity:isActive()
    return self.active
end

-- Clean up resources
function Entity:cleanup()
    -- Override in derived entities
end

return Entity 