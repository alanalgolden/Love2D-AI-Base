-- Main entry point for the game
-- This file initializes the game and sets up the main game loop

local InputManager = require('src/managers/InputManager')
local WindowManager = require('src/managers/WindowManager')

-- Game state
local gameState = {
    inputType = nil,
    baseWidth = 1920,
    baseHeight = 1080
}

function love.load()
    -- Initialize window manager first
    WindowManager.initialize()
    
    -- Initialize input manager
    InputManager.initialize()
end

function love.update(dt)
    -- Update input manager
    InputManager.update(dt)
    
    -- Get current input type
    gameState.inputType = InputManager.getCurrentInputType()
end

function love.draw()
    -- Begin drawing with proper scaling
    WindowManager.beginDraw()
    
    -- Clear the screen
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    
    -- Draw current input type
    love.graphics.setColor(1, 1, 1)
    local inputText = "Current Input Type: " .. (gameState.inputType or "None")
    love.graphics.print(inputText, 10, 10, 0, 1.5)
    
    -- Draw instructions
    local instructions = {
        "Press any key to test keyboard input",
        "Move mouse to test mouse input",
        "Connect a controller to test gamepad input",
        "Touch the screen to test touch input"
    }
    
    for i, text in ipairs(instructions) do
        love.graphics.print(text, 10, 50 + (i-1) * 30, 0, 1)
    end
    
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
end

function love.keyreleased(key)
    InputManager.handleKeyReleased(key)
end

function love.mousepressed(x, y, button)
    -- Convert screen coordinates to game coordinates
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMousePressed(gameX, gameY, button)
end

function love.mousereleased(x, y, button)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleMouseReleased(gameX, gameY, button)
end

function love.mousemoved(x, y, dx, dy)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    local gameDx = dx / WindowManager.getScale()
    local gameDy = dy / WindowManager.getScale()
    InputManager.handleMouseMoved(gameX, gameY, gameDx, gameDy)
end

function love.gamepadpressed(joystick, button)
    InputManager.handleGamepadPressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    InputManager.handleGamepadReleased(joystick, button)
end

function love.touchpressed(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchPressed(id, gameX, gameY, pressure)
end

function love.touchreleased(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchReleased(id, gameX, gameY, pressure)
end

function love.touchmoved(id, x, y, pressure)
    local gameX, gameY = WindowManager.screenToGame(x, y)
    InputManager.handleTouchMoved(id, gameX, gameY, pressure)
end 