-- Image.lua
-- Component for displaying images in the game

local Image = {}
Image.__index = Image

-- Fallback image for when requested images can't be loaded
local fallbackImage = nil

function Image.new(path, x, y, width, height)
    local self = setmetatable({}, Image)
    
    -- Load the image with fallback
    local success, image = pcall(function()
        return love.graphics.newImage(path)
    end)
    
    if success then
        self.image = image
    else
        -- If fallback image hasn't been created yet, create it
        if not fallbackImage then
            fallbackImage = love.graphics.newImage("assets/images/notfound.png")
        end
        self.image = fallbackImage
        -- Log the error for debugging
        print(string.format("Failed to load image: %s", path))
    end
    
    -- Position and dimensions
    self.x = x or 0
    self.y = y or 0
    self.width = width or self.image:getWidth()
    self.height = height or self.image:getHeight()
    
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