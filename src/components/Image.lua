-- Image.lua
-- Component for displaying images in the game

local Image = {}
Image.__index = Image

-- Fallback image for when requested images can't be loaded
local fallbackImage = nil
local fallbackFont = nil

function Image.new(path, x, y, width, height)
    local self = setmetatable({}, Image)
    
    -- Load the image with fallback
    local success, image = pcall(function()
        return love.graphics.newImage(path)
    end)
    
    if success then
        self.image = image
        self.useTextFallback = false
    else
        -- Try to load the notfound image
        local notFoundSuccess, notFoundImg = pcall(function()
            return love.graphics.newImage("assets/images/notfound.png")
        end)
        
        if notFoundSuccess then
            if not fallbackImage then
                fallbackImage = notFoundImg
            end
            self.image = fallbackImage
            self.useTextFallback = false
        else
            -- If both image loads fail, use text fallback
            self.image = nil
            self.useTextFallback = true
            if not fallbackFont then
                fallbackFont = love.graphics.newFont(24)
            end
            self.fallbackText = "Image not found"
        end
        -- Log the error for debugging
        print(string.format("Failed to load image: %s", path))
    end
    
    -- Position and dimensions
    self.x = x or 0
    self.y = y or 0
    self.width = width or (self.image and self.image:getWidth() or 200)
    self.height = height or (self.image and self.image:getHeight() or 100)
    
    -- Optional properties
    self.rotation = 0
    self.scaleX = 1
    self.scaleY = 1
    self.alpha = 1
    
    return self
end

-- Check if a point is inside the image
function Image:isPointInside(x, y)
    return x >= self.x - self.width/2 and x <= self.x + self.width/2 and
           y >= self.y - self.height/2 and y <= self.y + self.height/2
end

function Image:draw()
    -- Save the current graphics state
    love.graphics.push()
    
    -- Set color with alpha
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, self.alpha)
    
    if self.useTextFallback then
        -- Draw text fallback
        love.graphics.setFont(fallbackFont)
        local textWidth = fallbackFont:getWidth(self.fallbackText)
        local textHeight = fallbackFont:getHeight()
        local textX = self.x - textWidth/2
        local textY = self.y - textHeight/2
        
        -- Draw background rectangle
        love.graphics.setColor(0.2, 0.2, 0.2, self.alpha)
        love.graphics.rectangle("fill", 
            self.x - self.width/2, 
            self.y - self.height/2, 
            self.width, 
            self.height
        )
        
        -- Draw text
        love.graphics.setColor(1, 1, 1, self.alpha)
        love.graphics.print(self.fallbackText, textX, textY)
    else
        -- Draw the image
        love.graphics.draw(
            self.image,
            self.x,
            self.y,
            self.rotation,
            self.scaleX,
            self.scaleY,
            self.width / 2,
            self.height / 2
        )
    end
    
    -- Restore the graphics state
    love.graphics.pop()
end

function Image:setPosition(x, y)
    self.x = x
    self.y = y
end

function Image:setSize(width, height)
    self.width = width
    self.height = height
end

function Image:setRotation(rotation)
    self.rotation = rotation
end

function Image:setScale(scaleX, scaleY)
    self.scaleX = scaleX
    self.scaleY = scaleY or scaleX
end

function Image:setAlpha(alpha)
    self.alpha = alpha
end

return Image 