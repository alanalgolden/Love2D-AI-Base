-- WindowManager.lua
-- Handles window scaling, resolution management, and device-specific settings

local WindowManager = {}

-- Constants
local BASE_WIDTH = 1920  -- Base resolution width
local BASE_HEIGHT = 1080 -- Base resolution height
local MIN_WIDTH = 800    -- Minimum window width
local MIN_HEIGHT = 600   -- Minimum window height

-- State
local state = {
    windowWidth = BASE_WIDTH,
    windowHeight = BASE_HEIGHT,
    scale = 1,
    offsetX = 0,
    offsetY = 0,
    isFullscreen = false,
    isMobile = false,
    isSwitch = false
}

-- Initialize the window manager
function WindowManager.initialize()
    -- Detect platform
    state.isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    state.isSwitch = love.system.getOS() == "Switch"
    
    -- Set initial window mode based on platform
    if state.isMobile or state.isSwitch then
        -- On mobile/Switch, use fullscreen
        state.isFullscreen = true
        love.window.setFullscreen(true)
    else
        -- On desktop, use windowed mode with minimum size
        love.window.setMode(MIN_WIDTH, MIN_HEIGHT, {
            resizable = true,
            minwidth = MIN_WIDTH,
            minheight = MIN_HEIGHT
        })
    end
    
    -- Set window title
    love.window.setTitle("Elemental Transmutation")
    
    -- Initial resize
    WindowManager.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

-- Handle window resize
function WindowManager.resize(w, h)
    state.windowWidth = w
    state.windowHeight = h
    
    -- Calculate scale to fit the window while maintaining aspect ratio
    local scaleX = w / BASE_WIDTH
    local scaleY = h / BASE_HEIGHT
    state.scale = math.min(scaleX, scaleY)
    
    -- Calculate offsets to center the game
    state.offsetX = (w - (BASE_WIDTH * state.scale)) / 2
    state.offsetY = (h - (BASE_HEIGHT * state.scale)) / 2
end

-- Begin drawing with proper scaling
function WindowManager.beginDraw()
    love.graphics.push()
    love.graphics.translate(state.offsetX, state.offsetY)
    love.graphics.scale(state.scale, state.scale)
end

-- End drawing
function WindowManager.endDraw()
    love.graphics.pop()
end

-- Convert screen coordinates to game coordinates
function WindowManager.screenToGame(x, y)
    local gameX = (x - state.offsetX) / state.scale
    local gameY = (y - state.offsetY) / state.scale
    return gameX, gameY
end

-- Convert game coordinates to screen coordinates
function WindowManager.gameToScreen(x, y)
    local screenX = (x * state.scale) + state.offsetX
    local screenY = (y * state.scale) + state.offsetY
    return screenX, screenY
end

-- Get current scale
function WindowManager.getScale()
    return state.scale
end

-- Get current window dimensions
function WindowManager.getWindowDimensions()
    return state.windowWidth, state.windowHeight
end

-- Get base dimensions
function WindowManager.getBaseDimensions()
    return BASE_WIDTH, BASE_HEIGHT
end

-- Check if running on mobile
function WindowManager.isMobile()
    return state.isMobile
end

-- Check if running on Switch
function WindowManager.isSwitch()
    return state.isSwitch
end

-- Toggle fullscreen (desktop only)
function WindowManager.toggleFullscreen()
    if not state.isMobile and not state.isSwitch then
        state.isFullscreen = not state.isFullscreen
        love.window.setFullscreen(state.isFullscreen)
    end
end

return WindowManager 