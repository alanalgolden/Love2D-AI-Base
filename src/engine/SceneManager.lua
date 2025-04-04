-- SceneManager.lua
-- Manages scene transitions and scene-specific logic

local SceneManager = {}

-- Import dependencies
local Logger = require('src/utils/logger')
local GameEngine = require('src/engine/GameEngine')
local Scene = require('src/engine/Scene')

-- Scene manager state
local state = {
    currentScene = nil,
    previousScene = nil,
    scenes = {},
    sceneStack = {},
    sceneData = {}
}

-- Initialize the scene manager
function SceneManager.initialize()
    Logger.info("Initializing Scene Manager")
    -- This will be called by the GameEngine
end

-- Register a scene
function SceneManager.registerScene(name, sceneClass)
    if state.scenes[name] then
        Logger.warning("Scene already registered: " .. name)
        return false
    end
    
    state.scenes[name] = sceneClass
    Logger.info("Registered scene: " .. name)
    return true
end

-- Create a scene instance
function SceneManager.createScene(name)
    if not state.scenes[name] then
        Logger.error("Scene not found: " .. name)
        return nil
    end
    
    local sceneClass = state.scenes[name]
    local scene = sceneClass.new()
    scene:initialize()
    
    return scene
end

-- Set the current scene
function SceneManager.setScene(name, data)
    if not state.scenes[name] then
        Logger.error("Scene not found: " .. name)
        return false
    end
    
    -- Store previous scene
    state.previousScene = state.currentScene
    
    -- Clean up current scene if it exists
    if state.currentScene then
        state.currentScene:cleanup()
    end
    
    -- Create and set new scene
    local newScene = SceneManager.createScene(name)
    if not newScene then
        Logger.error("Failed to create scene: " .. name)
        return false
    end
    
    state.currentScene = newScene
    
    -- Store scene data
    state.sceneData[name] = data or {}
    
    Logger.info("Set current scene to: " .. name)
    return true
end

-- Push a scene onto the stack
function SceneManager.pushScene(name, data)
    if not state.scenes[name] then
        Logger.error("Scene not found: " .. name)
        return false
    end
    
    -- Pause current scene if it exists
    if state.currentScene then
        state.currentScene:deactivate()
        table.insert(state.sceneStack, state.currentScene)
    end
    
    -- Create and set new scene
    local newScene = SceneManager.createScene(name)
    if not newScene then
        Logger.error("Failed to create scene: " .. name)
        return false
    end
    
    state.currentScene = newScene
    state.currentScene:activate()
    
    -- Store scene data
    state.sceneData[name] = data or {}
    
    Logger.info("Pushed scene onto stack: " .. name)
    return true
end

-- Pop a scene from the stack
function SceneManager.popScene()
    if #state.sceneStack == 0 then
        Logger.warning("Scene stack is empty")
        return false
    end
    
    -- Clean up current scene
    if state.currentScene then
        state.currentScene:cleanup()
    end
    
    -- Pop previous scene from stack
    state.currentScene = table.remove(state.sceneStack)
    state.currentScene:activate()
    
    Logger.info("Popped scene from stack, current scene: " .. state.currentScene.name)
    return true
end

-- Get the current scene
function SceneManager.getCurrentScene()
    return state.currentScene
end

-- Get the previous scene
function SceneManager.getPreviousScene()
    return state.previousScene
end

-- Get scene data
function SceneManager.getSceneData(sceneName)
    return state.sceneData[sceneName]
end

-- Set scene data
function SceneManager.setSceneData(sceneName, data)
    state.sceneData[sceneName] = data
end

-- Update the current scene
function SceneManager.update(dt)
    if state.currentScene then
        state.currentScene:update(dt)
    end
end

-- Draw the current scene
function SceneManager.draw()
    if state.currentScene then
        state.currentScene:draw()
    end
end

-- Add an entity to the current scene
function SceneManager.addEntity(entity)
    if state.currentScene then
        return state.currentScene:addEntity(entity)
    end
    return false
end

-- Remove an entity from the current scene
function SceneManager.removeEntity(entity)
    if state.currentScene then
        return state.currentScene:removeEntity(entity)
    end
    return false
end

-- Add a system to the current scene
function SceneManager.addSystem(system)
    if state.currentScene then
        return state.currentScene:addSystem(system)
    end
    return false
end

-- Remove a system from the current scene
function SceneManager.removeSystem(system)
    if state.currentScene then
        return state.currentScene:removeSystem(system)
    end
    return false
end

return SceneManager 