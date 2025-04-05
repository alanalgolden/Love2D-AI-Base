-- Text.lua
-- A simple text component for displaying text in the UI

local Text = {}
Text.__index = Text

-- Create a new text component
function Text.new(x, y, width, height, text, color)
    local self = setmetatable({}, Text)
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text or ""
    self.color = color or {1, 1, 1, 1}
    self.fontSize = 16
    self.alignment = "left"
    
    return self
end

-- Set the font size
function Text:setFontSize(size)
    self.fontSize = size
    return self
end

-- Set the text alignment
function Text:setAlignment(alignment)
    self.alignment = alignment
    return self
end

-- Update the text
function Text:setText(text)
    self.text = text
    return self
end

-- Draw the text
function Text:draw()
    -- Set the color
    love.graphics.setColor(self.color)
    
    -- Set the font
    local font = love.graphics.newFont(self.fontSize)
    love.graphics.setFont(font)
    
    -- Draw the text
    if self.alignment == "center" then
        love.graphics.printf(self.text, self.x, self.y, self.width, "center")
    elseif self.alignment == "right" then
        love.graphics.printf(self.text, self.x, self.y, self.width, "right")
    else
        love.graphics.printf(self.text, self.x, self.y, self.width, "left")
    end
end

-- Check if a point is inside the text area
function Text:isPointInside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

return Text 