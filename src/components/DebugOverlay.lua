-- DebugOverlay.lua
-- A component that displays debug information and can be toggled with F3

local DebugOverlay = {}
DebugOverlay.__index = DebugOverlay

-- State
local state = {
    visible = false,
    padding = 10,
    lineHeight = 20,
    backgroundColor = {0, 0, 0, 0.7},
    textColor = {1, 1, 1, 1},
    width = 200,
    height = 100
}

function DebugOverlay.new()
    local self = setmetatable({}, DebugOverlay)
    return self
end

function DebugOverlay:initialize()
    -- Register F3 key handler
    local InputManager = require('src/managers/InputManager')
    InputManager.setOnKeyPressed(function(key)
        if key == 'f3' then
            state.visible = not state.visible
            return true -- Indicate that we handled this key
        end
        return false -- Let other handlers process the key
    end)
end

function DebugOverlay:update(dt)
    -- Update debug information
end

function DebugOverlay:draw()
    if not state.visible then return end
    
    -- Get debug information
    local InputManager = require('src/managers/InputManager')
    local currentInputType = InputManager.getCurrentInputType()
    
    -- Calculate position
    local x = love.graphics.getWidth() - state.width - state.padding
    local y = state.padding
    
    -- Draw background
    love.graphics.setColor(state.backgroundColor)
    love.graphics.rectangle('fill', x, y, state.width, state.height)
    
    -- Draw text
    love.graphics.setColor(state.textColor)
    local font = love.graphics.getFont()
    local text = string.format("Input Type: %s", currentInputType or "none")
    love.graphics.print(text, x + state.padding, y + state.padding)
end

function DebugOverlay:isPointInside(x, y)
    if not state.visible then return false end
    
    local overlayX = love.graphics.getWidth() - state.width - state.padding
    local overlayY = state.padding
    
    return x >= overlayX and x <= overlayX + state.width and
           y >= overlayY and y <= overlayY + state.height
end

return DebugOverlay 