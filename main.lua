-- Main entry point for the game
-- This file initializes the game and sets up the main game loop

local InputManager = require('src/managers/InputManager')
local WindowManager = require('src/managers/WindowManager')
local UIManager = require('src/managers/UIManager')
local Button = require('src/components/Button')
local Image = require('src/components/Image')
local DebugOverlay = require('src/components/DebugOverlay')
local Logger = require('src/utils/logger')

-- Game state
local gameState = {
    inputType = nil,
    baseWidth = 1920,
    baseHeight = 1080,
    currentScreen = "menu", -- menu, game, settings
    buttons = {},
    debugOverlay = nil,
    logo = nil
}

-- Button callbacks
local function onStartGame()
    Logger.info("Starting new game")
    gameState.currentScreen = "game"
end

local function onSettings()
    Logger.info("Opening settings menu")
    gameState.currentScreen = "settings"
end

local function onQuit()
    Logger.info("Quitting game")
    Logger.flush() -- Ensure all logs are written before quitting
    love.event.quit()
end

function love.load()
    Logger.info("Initializing game")
    
    -- Initialize managers
    WindowManager.initialize()
    InputManager.initialize()
    UIManager.initialize()
    
    -- Create debug overlay
    gameState.debugOverlay = DebugOverlay.new()
    gameState.debugOverlay:initialize()
    UIManager.addComponent(gameState.debugOverlay)
    
    -- Create logo
    gameState.logo = Image.new("assets/images/logo.png", gameState.baseWidth / 2, 200, 400, 200)
    UIManager.addComponent(gameState.logo)
    
    -- Create menu buttons
    local buttonWidth = 300
    local buttonHeight = 60
    local buttonSpacing = 20
    local startY = gameState.baseHeight / 2
    
    -- Start Game button
    local startButton = Button.new(
        gameState.baseWidth / 2 - buttonWidth / 2,
        startY,
        buttonWidth,
        buttonHeight,
        "Start Game",
        onStartGame
    )
    table.insert(gameState.buttons, startButton)
    UIManager.addComponent(startButton)
    
    -- Settings button
    local settingsButton = Button.new(
        gameState.baseWidth / 2 - buttonWidth / 2,
        startY + buttonHeight + buttonSpacing,
        buttonWidth,
        buttonHeight,
        "Settings",
        onSettings
    )
    table.insert(gameState.buttons, settingsButton)
    UIManager.addComponent(settingsButton)
    
    -- Quit button
    local quitButton = Button.new(
        gameState.baseWidth / 2 - buttonWidth / 2,
        startY + (buttonHeight + buttonSpacing) * 2,
        buttonWidth,
        buttonHeight,
        "Quit",
        onQuit
    )
    table.insert(gameState.buttons, quitButton)
    UIManager.addComponent(quitButton)
    
    -- Set up navigation
    startButton:setNavigation("down", settingsButton)
    settingsButton:setNavigation("up", startButton)
    settingsButton:setNavigation("down", quitButton)
    quitButton:setNavigation("up", settingsButton)
    
    -- Set initial focus
    UIManager.setFocusedComponent(startButton)
    
    Logger.info("Game initialization complete")
end

function love.update(dt)
    -- Update input manager
    InputManager.update(dt)
    
    -- Update UI manager
    UIManager.update(dt)
    
    -- Get current input type
    gameState.inputType = InputManager.getCurrentInputType()
end

function love.draw()
    -- Begin drawing with proper scaling
    WindowManager.beginDraw()
    
    -- Clear the screen
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    
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
    Logger.debug(string.format("Key pressed: %s", key))
end

function love.keyreleased(key)
    InputManager.handleKeyReleased(key)
    Logger.debug(string.format("Key released: %s", key))
end

function love.mousepressed(x, y, button)
    -- Convert screen coordinates to game coordinates
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMousePressed(gameX, gameY, button)
    UIManager.handlePointerPress(gameX, gameY)
    Logger.debug(string.format("Mouse pressed at (%d, %d) with button %d", gameX, gameY, button))
end

function love.mousereleased(x, y, button)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMouseReleased(gameX, gameY, button)
    UIManager.handlePointerRelease(gameX, gameY)
    Logger.debug(string.format("Mouse released at (%d, %d) with button %d", gameX, gameY, button))
end

function love.mousemoved(x, y, dx, dy)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    local gameDx = dx / WindowManager.getScale()
    local gameDy = dy / WindowManager.getScale()
    InputManager.handleMouseMoved(gameX, gameY, gameDx, gameDy)
    UIManager.handlePointerMove(gameX, gameY)
    Logger.debug(string.format("Mouse moved to (%d, %d) with delta (%d, %d)", gameX, gameY, gameDx, gameDy))
end

function love.gamepadpressed(joystick, button)
    InputManager.handleGamepadPressed(joystick, button)
    UIManager.handleGamepadPress(button)
    Logger.debug(string.format("Gamepad button pressed: %s", button))
end

function love.gamepadreleased(joystick, button)
    InputManager.handleGamepadReleased(joystick, button)
    Logger.debug(string.format("Gamepad button released: %s", button))
end

function love.touchpressed(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchPressed(id, gameX, gameY, pressure)
    UIManager.handlePointerPress(gameX, gameY)
    Logger.debug(string.format("Touch pressed at (%d, %d) with pressure %.2f", gameX, gameY, pressure))
end

function love.touchreleased(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchReleased(id, gameX, gameY, pressure)
    UIManager.handlePointerRelease(gameX, gameY)
    Logger.debug(string.format("Touch released at (%d, %d) with pressure %.2f", gameX, gameY, pressure))
end

function love.touchmoved(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchMoved(id, gameX, gameY, pressure)
    UIManager.handlePointerMove(gameX, gameY)
    Logger.debug(string.format("Touch moved to (%d, %d) with pressure %.2f", gameX, gameY, pressure))
end 