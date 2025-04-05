-- RunManager.lua
-- Manages roguelike runs, including variables, objects, and events

local RunManager = {}

-- Import dependencies
local Logger = require('src/utils/logger')
local GameEngine = require('src/engine/GameEngine')

-- Run state
local state = {
    currentRun = nil,
    runVariables = {},
    runObjects = {},
    runEvents = {},
    runConfig = {},
    runHistory = {}
}

-- Initialize the run manager
function RunManager.initialize()
    Logger.info("Initializing Run Manager")
    -- This will be called by the GameEngine
end

-- Start a new run
function RunManager.startNewRun(config)
    -- Get a new run from the GameEngine
    local newRun = GameEngine.startNewRun(config)
    
    -- Initialize run state
    state.currentRun = newRun
    state.runVariables = newRun.variables or {}
    state.runObjects = newRun.objects or {}
    state.runEvents = newRun.events or {}
    state.runConfig = newRun.config or {}
    
    -- Add to history
    table.insert(state.runHistory, newRun)
    
    Logger.info("New run started with ID: " .. newRun.id)
    return newRun
end

-- End the current run
function RunManager.endCurrentRun()
    if not state.currentRun then
        Logger.warning("No active run to end")
        return false
    end
    
    -- Update run end time
    state.currentRun.endTime = os.time()
    
    -- Save the run
    GameEngine.saveCurrentRun()
    
    -- Clear current run
    state.currentRun = nil
    state.runVariables = {}
    state.runObjects = {}
    state.runEvents = {}
    state.runConfig = {}
    
    Logger.info("Run ended")
    return true
end

-- Get the current run
function RunManager.getCurrentRun()
    return state.currentRun
end

-- Get run history
function RunManager.getRunHistory()
    return state.runHistory
end

-- Set a run variable
function RunManager.setVariable(key, value)
    if not state.currentRun then
        Logger.error("No active run to set variable")
        return false
    end
    
    state.runVariables[key] = value
    state.currentRun.variables = state.runVariables
    
    return true
end

-- Get a run variable
function RunManager.getVariable(key, defaultValue)
    if not state.currentRun then
        Logger.error("No active run to get variable")
        return defaultValue
    end
    
    return state.runVariables[key] or defaultValue
end

-- Add a run object
function RunManager.addObject(object)
    if not state.currentRun then
        Logger.error("No active run to add object")
        return false
    end
    
    table.insert(state.runObjects, object)
    state.currentRun.objects = state.runObjects
    
    return #state.runObjects
end

-- Remove a run object
function RunManager.removeObject(object)
    if not state.currentRun then
        Logger.error("No active run to remove object")
        return false
    end
    
    for i, obj in ipairs(state.runObjects) do
        if obj == object then
            table.remove(state.runObjects, i)
            state.currentRun.objects = state.runObjects
            return true
        end
    end
    
    return false
end

-- Get all run objects
function RunManager.getObjects()
    return state.runObjects
end

-- Add a run event
function RunManager.addEvent(event)
    if not state.currentRun then
        Logger.error("No active run to add event")
        return false
    end
    
    table.insert(state.runEvents, event)
    state.currentRun.events = state.runEvents
    
    return #state.runEvents
end

-- Get all run events
function RunManager.getEvents()
    return state.runEvents
end

-- Set run configuration
function RunManager.setConfig(key, value)
    if not state.currentRun then
        Logger.error("No active run to set config")
        return false
    end
    
    state.runConfig[key] = value
    state.currentRun.config = state.runConfig
    
    return true
end

-- Get run configuration
function RunManager.getConfig(key, defaultValue)
    if not state.currentRun then
        Logger.error("No active run to get config")
        return defaultValue
    end
    
    return state.runConfig[key] or defaultValue
end

-- Get a random number for the current run
function RunManager.random(min, max)
    return GameEngine.random(min, max)
end

-- Save the current run
function RunManager.saveCurrentRun()
    return GameEngine.saveCurrentRun()
end

-- Load a run
function RunManager.loadRun(runId)
    local run = GameEngine.loadRun(runId)
    
    if run then
        state.currentRun = run
        state.runVariables = run.variables or {}
        state.runObjects = run.objects or {}
        state.runEvents = run.events or {}
        state.runConfig = run.config or {}
        
        return true
    end
    
    return false
end

return RunManager 