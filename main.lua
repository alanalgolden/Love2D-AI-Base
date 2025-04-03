-- Main entry point for the game
-- This file initializes the game and sets up the main game loop

local InputManager = require('src/managers/InputManager')
local WindowManager = require('src/managers/WindowManager')
local UIManager = require('src/managers/UIManager')
local Button = require('src/components/Button')

-- Game state
local gameState = {
    inputType = nil,
    baseWidth = 1920,
    baseHeight = 1080,
    currentScreen = "menu", -- menu, game, settings
    buttons = {}
}

-- Button callbacks
local function onStartGame()
    gameState.currentScreen = "game"
end

local function onSettings()
    gameState.currentScreen = "settings"
end

local function onQuit()
    love.event.quit()
end

function love.load()
    -- Initialize managers
    WindowManager.initialize()
    InputManager.initialize()
    UIManager.initialize()
    
    -- Create menu buttons
    local buttonWidth = 300
    local buttonHeight = 60
    local buttonSpacing = 20
    local startY = gameState.baseHeight / 2 - (buttonHeight * 3 + buttonSpacing * 2) / 2
    
    -- Start Game button
    gameState.buttons.startGame = Button.new(
        gameState.baseWidth / 2 - buttonWidth / 2,
        startY,
        buttonWidth,
        buttonHeight,
        "Start Game",
        onStartGame
    )
    
    -- Settings button
    gameState.buttons.settings = Button.new(
        gameState.baseWidth / 2 - buttonWidth / 2,
        startY + buttonHeight + buttonSpacing,
        buttonWidth,
        buttonHeight,
        "Settings",
        onSettings
    )
    
    -- Quit button
    gameState.buttons.quit = Button.new(
        gameState.baseWidth / 2 - buttonWidth / 2,
        startY + (buttonHeight + buttonSpacing) * 2,
        buttonWidth,
        buttonHeight,
        "Quit",
        onQuit
    )
    
    -- Set up navigation
    gameState.buttons.startGame:setNavigation("down", gameState.buttons.settings)
    gameState.buttons.settings:setNavigation("up", gameState.buttons.startGame)
    gameState.buttons.settings:setNavigation("down", gameState.buttons.quit)
    gameState.buttons.quit:setNavigation("up", gameState.buttons.settings)
    
    -- Add buttons to UI manager
    UIManager.addComponent(gameState.buttons.startGame)
    UIManager.addComponent(gameState.buttons.settings)
    UIManager.addComponent(gameState.buttons.quit)
    
    -- Set initial focus
    UIManager.setFocusedComponent(gameState.buttons.startGame)
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
    
    -- Draw current input type (for testing)
    love.graphics.setColor(1, 1, 1)
    local inputText = "Current Input Type: " .. (gameState.inputType or "None")
    love.graphics.print(inputText, 10, 10, 0, 1.5)
    
    -- End drawing
    WindowManager.endDraw()
end

-- Handle window resize
function love.resize(w, h)
    WindowManager.resize(w, h)
end

-- Input callbacks with coordinate conversion
function love.keypressed(key)
    InputManager.handleKeyPressed(key)
    UIManager.handleKeyPress(key)
end

function love.keyreleased(key)
    InputManager.handleKeyReleased(key)
end

function love.mousepressed(x, y, button)
    -- Convert screen coordinates to game coordinates
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMousePressed(gameX, gameY, button)
    UIManager.handlePointerPress(gameX, gameY)
end

function love.mousereleased(x, y, button)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMouseReleased(gameX, gameY, button)
    UIManager.handlePointerRelease(gameX, gameY)
end

function love.mousemoved(x, y, dx, dy)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    local gameDx = dx / WindowManager.getScale()
    local gameDy = dy / WindowManager.getScale()
    InputManager.handleMouseMoved(gameX, gameY, gameDx, gameDy)
    UIManager.handlePointerMove(gameX, gameY)
end

function love.gamepadpressed(joystick, button)
    InputManager.handleGamepadPressed(joystick, button)
    UIManager.handleGamepadPress(button)
end

function love.gamepadreleased(joystick, button)
    InputManager.handleGamepadReleased(joystick, button)
end

function love.touchpressed(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchPressed(id, gameX, gameY, pressure)
    UIManager.handlePointerPress(gameX, gameY)
end

function love.touchreleased(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchReleased(id, gameX, gameY, pressure)
    UIManager.handlePointerRelease(gameX, gameY)
end

function love.touchmoved(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchMoved(id, gameX, gameY, pressure)
    UIManager.handlePointerMove(gameX, gameY)
end 