-- Main entry point for the game
-- This file initializes the game and sets up the main game loop

local InputManager = require('src/managers/InputManager')
local WindowManager = require('src/managers/WindowManager')
local UIManager = require('src/managers/UIManager')
local ProfileManager = require('src/managers/ProfileManager')
local DebugOverlay = require('src/components/DebugOverlay')
local Logger = require('src/utils/logger')
local Audio = require('src/components/Audio')

-- Import Game Engine
local GameEngine = require('src/engine/GameEngine')
local RunManager = require('src/managers/RunManager')
local StateManager = require('src/managers/StateManager')
local SceneManager = require('src/managers/SceneManager')

-- Import Scenes
local ProfileScene = require('src/scenes/ProfileScene')
local MenuScene = require('src/scenes/MenuScene')
local GameScene = require('src/scenes/GameScene')
local SettingsScene = require('src/scenes/SettingsScene')

-- Game state
local gameState = {
    inputType = nil,
    baseWidth = 1920,
    baseHeight = 1080,
    debugOverlay = nil
}

function love.load()
    -- Configure logger
    Logger.configure({
        bufferSize = 10000,  -- Much larger buffer size to reduce disk writes
        flushCooldown = 10.0,  -- Much longer flush cooldown to reduce disk writes
        minLevel = "ERROR",  -- Only log ERROR by default
        maxLogSize = 512 * 1024,  -- 512KB max log size
        maxLogFiles = 2  -- Keep only 2 log files
    })
    
    Logger.info("Initializing game")
    
    -- Initialize managers
    WindowManager.initialize()
    InputManager.initialize()
    UIManager.initialize()
    ProfileManager.initialize()
    Audio.load()  -- Initialize audio system
    
    -- Initialize Game Engine
    GameEngine.initialize({
        debugMode = true,
        savePath = "saves/",
        maxRunHistory = 10
    })
    
    -- Initialize Run Manager
    RunManager.initialize()
    
    -- Initialize State Manager
    StateManager.initialize()
    
    -- Initialize Scene Manager
    SceneManager.initialize()
    
    -- Register scenes
    SceneManager.registerScene("profile", ProfileScene)
    SceneManager.registerScene("menu", MenuScene)
    SceneManager.registerScene("game", GameScene)
    SceneManager.registerScene("settings", SettingsScene)
    
    -- Create debug overlay
    gameState.debugOverlay = DebugOverlay.new()
    gameState.debugOverlay:initialize()
    UIManager.addComponent(gameState.debugOverlay)
    
    -- Set initial scene to profile selection
    SceneManager.setScene("profile")
    
    Logger.info("Game initialization complete")
end

function love.update(dt)
    -- Update input manager
    InputManager.update(dt)
    
    -- Update UI manager
    UIManager.update(dt)
    
    -- Update Game Engine
    GameEngine.update(dt)
    
    -- Update Scene Manager
    SceneManager.update(dt)
    
    -- Update State Manager
    StateManager.update(dt)
    
    -- Get current input type
    gameState.inputType = InputManager.getCurrentInputType()
end

function love.draw()
    -- Begin drawing with proper scaling
    WindowManager.beginDraw()
    
    -- Clear the screen
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    
    -- Draw Scene Manager
    SceneManager.draw()
    
    -- Draw State Manager
    StateManager.draw()
    
    -- Draw UI components
    UIManager.draw()
    
    -- End drawing
    WindowManager.endDraw()
end

-- Handle window resize
function love.resize(w, h)
    WindowManager.resize(w, h)
    Logger.debug(string.format("Window resized to %dx%d", w, h))
end

-- Input callbacks with coordinate conversion
function love.keypressed(key)
    InputManager.handleKeyPressed(key)
    StateManager.keypressed(key)
    
    -- Pass key press to current scene
    local currentScene = SceneManager.getCurrentScene()
    if currentScene and currentScene.keypressed then
        currentScene:keypressed(key)
    end
    
    Logger.debug(string.format("Key pressed: %s", key))
end

function love.keyreleased(key)
    InputManager.handleKeyReleased(key)
    StateManager.keyreleased(key)
    
    -- Pass key release to current scene
    local currentScene = SceneManager.getCurrentScene()
    if currentScene and currentScene.keyreleased then
        currentScene:keyreleased(key)
    end
    
    Logger.debug(string.format("Key released: %s", key))
end

function love.mousepressed(x, y, button)
    -- Convert screen coordinates to game coordinates
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMousePressed(gameX, gameY, button)
    UIManager.handlePointerPress(gameX, gameY)
    StateManager.mousepressed(gameX, gameY, button)
    
    -- Pass mouse press to current scene
    local currentScene = SceneManager.getCurrentScene()
    if currentScene and currentScene.mousepressed then
        currentScene:mousepressed(gameX, gameY, button)
    end
    
    Logger.debug(string.format("Mouse pressed at (%d, %d) with button %d", gameX, gameY, button))
end

function love.mousereleased(x, y, button)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMouseReleased(gameX, gameY, button)
    UIManager.handlePointerRelease(gameX, gameY)
    StateManager.mousereleased(gameX, gameY, button)
    
    -- Pass mouse release to current scene
    local currentScene = SceneManager.getCurrentScene()
    if currentScene and currentScene.mousereleased then
        currentScene:mousereleased(gameX, gameY, button)
    end
    
    Logger.debug(string.format("Mouse released at (%d, %d) with button %d", gameX, gameY, button))
end

function love.mousemoved(x, y, dx, dy)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    local gameDx = dx / WindowManager.getScale()
    local gameDy = dy / WindowManager.getScale()
    InputManager.handleMouseMoved(gameX, gameY, gameDx, gameDy)
    UIManager.handlePointerMove(gameX, gameY)
    StateManager.mousemoved(gameX, gameY, gameDx, gameDy)
    
    -- Pass mouse movement to current scene
    local currentScene = SceneManager.getCurrentScene()
    if currentScene and currentScene.mousemoved then
        currentScene:mousemoved(gameX, gameY, gameDx, gameDy)
    end
    
    Logger.debug(string.format("Mouse moved to (%d, %d) with delta (%d, %d)", gameX, gameY, gameDx, gameDy))
end

function love.gamepadpressed(joystick, button)
    InputManager.handleGamepadPressed(joystick, button)
    UIManager.handleGamepadPress(button)
    StateManager.gamepadpressed(joystick, button)
    Logger.debug(string.format("Gamepad button pressed: %s", button))
end

function love.gamepadreleased(joystick, button)
    InputManager.handleGamepadReleased(joystick, button)
    StateManager.gamepadreleased(joystick, button)
    Logger.debug(string.format("Gamepad button released: %s", button))
end

function love.touchpressed(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchPressed(id, gameX, gameY, pressure)
    UIManager.handlePointerPress(gameX, gameY)
    StateManager.touchpressed(id, gameX, gameY, pressure)
    Logger.debug(string.format("Touch pressed at (%d, %d) with pressure %.2f", gameX, gameY, pressure))
end

function love.touchreleased(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchReleased(id, gameX, gameY, pressure)
    UIManager.handlePointerRelease(gameX, gameY)
    StateManager.touchreleased(id, gameX, gameY, pressure)
    Logger.debug(string.format("Touch released at (%d, %d) with pressure %.2f", gameX, gameY, pressure))
end

function love.touchmoved(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchMoved(id, gameX, gameY, pressure)
    UIManager.handlePointerMove(gameX, gameY)
    StateManager.touchmoved(id, gameX, gameY, pressure)
    Logger.debug(string.format("Touch moved to (%d, %d) with pressure %.2f", gameX, gameY, pressure))
end

-- Handle window focus
function love.focus(focused)
    -- Get current scene
    local success, err = pcall(function()
        local SceneManager = require('src/managers/SceneManager')
        local currentScene = SceneManager.getCurrentScene()
        
        if currentScene then
            if focused then
                -- Check if focus method exists before calling it
                if type(currentScene.focus) == "function" then
                    currentScene:focus()
                else
                    local Logger = require('src/utils/logger')
                    Logger.warning("Scene does not have focus method")
                end
            else
                -- Check if unfocus method exists before calling it
                if type(currentScene.unfocus) == "function" then
                    currentScene:unfocus()
                else
                    local Logger = require('src/utils/logger')
                    Logger.warning("Scene does not have unfocus method")
                end
            end
        end
        
        local Logger = require('src/utils/logger')
        Logger.debug("Window focus changed: " .. tostring(focused))
    end)
    
    if not success then
        print("Error in love.focus: " .. tostring(err))
    end
end

-- Ensure logger is flushed when the game is closing
function love.quit()
    local Logger = require('src/utils/logger')
    Logger.flush()
    return false
end 