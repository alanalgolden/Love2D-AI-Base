-- GameEngine.lua
-- Core engine module that manages the game state, runs, and coordinates all subsystems

local GameEngine = {}

-- Import managers
local InputManager = require('src/managers/InputManager')
local WindowManager = require('src/managers/WindowManager')
local UIManager = require('src/managers/UIManager')
local Logger = require('src/utils/logger')

-- Engine state
local state = {
    -- Run management
    currentRun = nil,
    runSeed = nil,
    runHistory = {},
    
    -- Game state
    currentScene = nil,
    scenes = {},
    
    -- Engine configuration
    config = {
        debugMode = false,
        savePath = "saves/",
        maxRunHistory = 10
    },
    
    -- Random number generator
    rng = nil
}

-- Initialize the game engine
function GameEngine.initialize(config)
    Logger.info("Initializing Game Engine")
    
    -- Merge provided config with defaults
    if config then
        for k, v in pairs(config) do
            state.config[k] = v
        end
    end
    
    -- Initialize random number generator with default seed
    GameEngine.setSeed(os.time())
    
    -- Create save directory if it doesn't exist
    love.filesystem.createDirectory(state.config.savePath)
    
    Logger.info("Game Engine initialized")
end

-- Set the random seed for the current run
function GameEngine.setSeed(seed)
    state.runSeed = seed
    state.rng = love.math.newRandomGenerator(seed)
    Logger.info("Set run seed to: " .. tostring(seed))
end

-- Get the current random seed
function GameEngine.getSeed()
    return state.runSeed
end

-- Get a random number using the engine's RNG
function GameEngine.random(min, max)
    if not state.rng then
        Logger.error("Random number generator not initialized")
        return 0
    end
    
    if min and max then
        return state.rng:random(min, max)
    elseif min then
        return state.rng:random(1, min)
    else
        return state.rng:random()
    end
end

-- Start a new run
function GameEngine.startNewRun(runConfig)
    Logger.info("Starting new run")
    
    -- Create a new run object
    local newRun = {
        id = #state.runHistory + 1,
        seed = state.runSeed,
        startTime = os.time(),
        variables = {},
        objects = {},
        events = {},
        config = runConfig or {}
    }
    
    -- Set as current run
    state.currentRun = newRun
    
    -- Add to history
    table.insert(state.runHistory, newRunRun)
    
    -- Trim history if needed
    if #state.runHistory > state.config.maxRunHistory then
        table.remove(state.runHistory, 1)
    end
    
    -- Initialize run-specific systems
    GameEngine.initializeRunSystems(newRun)
    
    Logger.info("New run started with ID: " .. newRun.id)
    return newRun
end

-- Initialize systems for a specific run
function GameEngine.initializeRunSystems(run)
    -- This will be expanded as we add more systems
    -- For now, it's a placeholder for future implementation
end

-- Get the current run
function GameEngine.getCurrentRun()
    return state.currentRun
end

-- Get run history
function GameEngine.getRunHistory()
    return state.runHistory
end

-- Save the current run
function GameEngine.saveCurrentRun()
    if not state.currentRun then
        Logger.error("No active run to save")
        return false
    end
    
    local runId = state.currentRun.id
    local saveData = {
        run = state.currentRun,
        timestamp = os.time()
    }
    
    local success, err = pcall(function()
        local json = require('src/utils/json')
        local jsonData = json.encode(saveData)
        love.filesystem.write(state.config.savePath .. "run_" .. runId .. ".json", jsonData)
    end)
    
    if success then
        Logger.info("Run " .. runId .. " saved successfully")
        return true
    else
        Logger.error("Failed to save run: " .. tostring(err))
        return false
    end
end

-- Load a run from save
function GameEngine.loadRun(runId)
    local success, data = pcall(function()
        local json = require('src/utils/json')
        local jsonData = love.filesystem.read(state.config.savePath .. "run_" .. runId .. ".json")
        return json.decode(jsonData)
    end)
    
    if success and data and data.run then
        state.currentRun = data.run
        GameEngine.setSeed(data.run.seed)
        GameEngine.initializeRunSystems(data.run)
        Logger.info("Run " .. runId .. " loaded successfully")
        return data.run
    else
        Logger.error("Failed to load run " .. runId)
        return nil
    end
end

-- Register a scene
function GameEngine.registerScene(name, scene)
    state.scenes[name] = scene
    Logger.info("Registered scene: " .. name)
end

-- Set the current scene
function GameEngine.setCurrentScene(name)
    if state.scenes[name] then
        state.currentScene = name
        Logger.info("Set current scene to: " .. name)
        return true
    else
        Logger.error("Scene not found: " .. name)
        return false
    end
end

-- Get the current scene
function GameEngine.getCurrentScene()
    return state.currentScene
end

-- Update the game engine
function GameEngine.update(dt)
    -- Update current scene if it exists
    if state.currentScene and state.scenes[state.currentScene] and state.scenes[state.currentScene].update then
        state.scenes[state.currentScene]:update(dt)
    end
end

-- Draw the game engine
function GameEngine.draw()
    -- Draw current scene if it exists
    if state.currentScene and state.scenes[state.currentScene] and state.scenes[state.currentScene].draw then
        state.scenes[state.currentScene]:draw()
    end
end

-- Toggle debug mode
function GameEngine.toggleDebugMode()
    state.config.debugMode = not state.config.debugMode
    Logger.info("Debug mode: " .. (state.config.debugMode and "enabled" or "disabled"))
end

-- Check if debug mode is enabled
function GameEngine.isDebugMode()
    return state.config.debugMode
end

return GameEngine 