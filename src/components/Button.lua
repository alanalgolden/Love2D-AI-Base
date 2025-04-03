-- Button.lua
-- Base button component that handles all input types

local Button = {}
Button.__index = Button

-- Create a new button
function Button.new(x, y, width, height, text, onClick)
    local self = setmetatable({}, Button)
    
    -- Position and size
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    -- Text
    self.text = text
    
    -- Callbacks
    self.onClick = onClick
    self.onHoverStart = nil
    self.onHoverEnd = nil
    self.onPress = nil
    self.onRelease = nil
    self.onFocusStart = nil
    self.onFocusEnd = nil
    
    -- State
    self.isHovered = false
    self.isPressed = false
    self.isFocused = false
    
    -- Navigation
    self.focusable = true
    self.navigation = {
        up = nil,
        down = nil,
        left = nil,
        right = nil
    }
    
    -- Colors
    self.colors = {
        normal = {0.3, 0.3, 0.3, 1},    -- Gray
        hover = {0.4, 0.4, 0.4, 1},     -- Light gray
        pressed = {0.2, 0.2, 0.2, 1},   -- Dark gray
        focused = {0.5, 0.5, 0.5, 1},   -- Very light gray
        text = {1, 1, 1, 1}             -- White
    }
    
    -- Font
    self.font = love.graphics.newFont(32)
    
    return self
end

-- Update button state
function Button:update(dt)
    -- Add any animation or state updates here
end

-- Draw the button
function Button:draw()
    -- Save current graphics state
    love.graphics.push()
    
    -- Set color based on state
    if self.isPressed then
        love.graphics.setColor(unpack(self.colors.pressed))
    elseif self.isHovered then
        love.graphics.setColor(unpack(self.colors.hover))
    elseif self.isFocused then
        love.graphics.setColor(unpack(self.colors.focused))
    else
        love.graphics.setColor(unpack(self.colors.normal))
    end
    
    -- Draw button background
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw button border
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw focus indicator
    if self.isFocused then
        love.graphics.setColor(1, 1, 0, 0.5)  -- Yellow highlight
        love.graphics.rectangle("line", self.x - 4, self.y - 4, self.width + 8, self.height + 8, 2)
    end
    
    -- Draw text
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.setFont(self.font)
    
    -- Center text
    local textWidth = self.font:getWidth(self.text)
    local textHeight = self.font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.text, textX, textY)
    
    -- Restore graphics state
    love.graphics.pop()
end

-- Check if a point is inside the button
function Button:isPointInside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Event handlers
function Button:onHoverStart()
    self.isHovered = true
end

function Button:onHoverEnd()
    self.isHovered = false
end

function Button:onPress()
    self.isPressed = true
end

function Button:onRelease()
    self.isPressed = false
end

function Button:onFocusStart()
    self.isFocused = true
end

function Button:onFocusEnd()
    self.isFocused = false
end

-- Handle keyboard input
function Button:onKeyPress(key)
    if key == "return" or key == "space" then
        if self.onClick then
            self.onClick()
        end
    end
end

-- Handle gamepad input
function Button:onGamepadPress(button)
    if button == "a" or button == "start" then
        if self.onClick then
            self.onClick()
        end
    end
end

-- Navigation methods
function Button:setNavigation(direction, component)
    self.navigation[direction] = component
end

function Button:getNavigation(direction)
    return self.navigation[direction]
end

function Button:isFocusable()
    return self.focusable
end

function Button:setFocusable(focusable)
    self.focusable = focusable
end

-- Set button colors
function Button:setColors(colors)
    self.colors = colors
end

-- Set button text
function Button:setText(text)
    self.text = text
end

-- Set button position
function Button:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Set button size
function Button:setSize(width, height)
    self.width = width
    self.height = height
end

return Button 