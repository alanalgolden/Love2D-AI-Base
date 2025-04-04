-- Scene.lua
-- Base scene class for managing different game states

local Scene = {}
Scene.__index = Scene

-- Create a new scene
function Scene.new(name)
    local self = setmetatable({}, Scene)
    
    -- Scene properties
    self.name = name
    self.active = false
    self.entities = {}
    self.systems = {}
    
    return self
end

-- Initialize the scene
function Scene:initialize()
    -- Override in derived scenes
end

-- Update the scene
function Scene:update(dt)
    -- Update all systems
    for _, system in ipairs(self.systems) do
        if system.update then
            system:update(dt)
        end
    end
    
    -- Update all entities
    for _, entity in ipairs(self.entities) do
        if entity.update then
            entity:update(dt)
        end
    end
end

-- Draw the scene
function Scene:draw()
    -- Draw all entities
    for _, entity in ipairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end

-- Add an entity to the scene
function Scene:addEntity(entity)
    table.insert(self.entities, entity)
    return #self.entities
end

-- Remove an entity from the scene
function Scene:removeEntity(entity)
    for i, ent in ipairs(self.entities) do
        if ent == entity then
            table.remove(self.entities, i)
            break
        end
    end
end

-- Add a system to the scene
function Scene:addSystem(system)
    table.insert(self.systems, system)
    return #self.systems
end

-- Remove a system from the scene
function Scene:removeSystem(system)
    for i, sys in ipairs(self.systems) do
        if sys == system then
            table.remove(self.systems, i)
            break
        end
    end
end

-- Activate the scene
function Scene:activate()
    self.active = true
end

-- Deactivate the scene
function Scene:deactivate()
    self.active = false
end

-- Check if the scene is active
function Scene:isActive()
    return self.active
end

-- Clean up resources
function Scene:cleanup()
    -- Override in derived scenes
end

return Scene 