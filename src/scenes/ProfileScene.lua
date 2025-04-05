-- ProfileScene.lua
-- Scene for managing player profiles

local Scene = require('src/engine/Scene')
local Button = require('src/components/Button')
local UIManager = require('src/managers/UIManager')
local ProfileManager = require('src/managers/ProfileManager')
local Logger = require('src/utils/logger')
local Text = require('src/components/Text')

local ProfileScene = {}
ProfileScene.__index = ProfileScene
setmetatable(ProfileScene, Scene)

-- Create a new profile scene
function ProfileScene.new()
    local self = setmetatable(Scene.new("profile"), ProfileScene)
    
    -- Profile properties
    self.profileSlots = {}
    self.uiComponents = {}
    self.logo = nil
    self.heading = nil
    
    return self
end

-- Initialize the profile scene
function ProfileScene:initialize()
    -- Call parent initialize
    Scene.initialize(self)
    
    -- Create profile UI elements
    self:createUI()
    
    Logger.info("Profile scene initialized")
end

-- Create UI elements
function ProfileScene:createUI()
    -- Create logo
    table.insert(self.uiComponents, self.logo)
    UIManager.addComponent(self.logo)
    
    -- Create "Select Profile" heading
    self.heading = Text.new(760, 100, 400, 40, "Select Profile", {1, 1, 1, 1})
    self.heading:setFontSize(24)
    self.heading:setAlignment("center")
    table.insert(self.uiComponents, self.heading)
    UIManager.addComponent(self.heading)
    
    -- Create profile slots
    local slotWidth = 400
    local slotHeight = 180  -- Increased height to fit content
    local slotSpacing = 40  -- Increased spacing between slots
    local startY = 160
    
    for i = 1, 3 do
        local slot = self:createProfileSlot(i, 760, startY + (i-1) * (slotHeight + slotSpacing), slotWidth, slotHeight)
        table.insert(self.profileSlots, slot)
        table.insert(self.uiComponents, slot)
        UIManager.addComponent(slot)
    end
    
    -- Set up navigation between profile slots
    for i = 1, #self.profileSlots do
        local slot = self.profileSlots[i]
        if i > 1 then
            slot:setNavigation("up", self.profileSlots[i-1])
        end
        if i < #self.profileSlots then
            slot:setNavigation("down", self.profileSlots[i+1])
        end
    end
    
    -- Set initial focus
    UIManager.setFocusedComponent(self.profileSlots[1])
end

-- Create a profile slot
function ProfileScene:createProfileSlot(id, x, y, width, height)
    local profile = ProfileManager.getProfile(id)
    local slot = Button.new(x, y, width, height, "", function()
        if profile then
            -- Select existing profile
            ProfileManager.setCurrentProfile(id)
            local SceneManager = require('src/engine/SceneManager')
            SceneManager.setScene("menu")
        else
            -- Create new profile
            if ProfileManager.createProfile(id) then
                ProfileManager.setCurrentProfile(id)
                local SceneManager = require('src/engine/SceneManager')
                SceneManager.setScene("menu")
            else
                Logger.error("Failed to create profile " .. id)
            end
        end
    end)
    
    -- Customize slot appearance based on profile state
    if profile then
        -- Ensure progress table exists
        if not profile.progress then
            profile.progress = { highScore = 0 }
        end
        
        -- Ensure highScore field exists
        if profile.progress.highScore == nil then
            profile.progress.highScore = 0
        end
        
        -- Format the profile text with proper spacing and line breaks
        local profileText = string.format(
            "Profile %d\n%s\nLast: %s\nScore: %d", 
            id, 
            profile.name,
            os.date("%Y-%m-%d", profile.lastPlayed),
            profile.progress.highScore
        )
        slot:setText(profileText)
        
        -- Adjust text position to prevent overlapping
        slot:setTextPadding(20, 30)  -- Increased padding to better center the text
        
        slot:setColors({
            normal = {0.3, 0.3, 0.3, 1},    -- Gray
            hover = {0.4, 0.4, 0.4, 1},     -- Light gray
            pressed = {0.2, 0.2, 0.2, 1},   -- Dark gray
            focused = {0.5, 0.5, 0.5, 1},   -- Very light gray
            text = {1, 1, 1, 1}             -- White
        })
    else
        -- Empty slot appearance
        slot:setText(string.format("Empty Slot %d\nClick to create new profile", id))
        slot:setTextPadding(20, 30)  -- Increased padding to better center the text
        
        slot:setColors({
            normal = {0.2, 0.2, 0.2, 1},    -- Dark gray
            hover = {0.3, 0.3, 0.3, 1},     -- Gray
            pressed = {0.1, 0.1, 0.1, 1},   -- Very dark gray
            focused = {0.4, 0.4, 0.4, 1},   -- Light gray
            text = {0.7, 0.7, 0.7, 1}       -- Light gray
        })
    end
    
    return slot
end

-- Update the profile scene
function ProfileScene:update(dt)
    -- Call parent update
    Scene.update(self, dt)
    
    -- Update all UI components
    for _, component in ipairs(self.uiComponents) do
        if component.update then
            component:update(dt)
        end
    end
end

-- Draw the profile scene
function ProfileScene:draw()
    -- Call parent draw
    Scene.draw(self)
    
    -- Draw all UI components
    for _, component in ipairs(self.uiComponents) do
        if component.draw then
            component:draw()
        end
    end
end

-- Handle key press
function ProfileScene:keypressed(key)
    -- Handle escape key to quit
    if key == "escape" then
        love.event.quit()
        return
    end
    
    -- We don't need to handle navigation keys here as they're already handled by UIManager
    -- We only need to handle special keys that aren't part of the UI navigation
end

-- Handle mouse press
function ProfileScene:mousepressed(x, y, button)
    -- Check if any button was clicked
    for _, component in ipairs(self.uiComponents) do
        if component:isPointInside(x, y) then
            if component.onPress then
                component:onPress()
            end
            break
        end
    end
end

-- Clean up resources
function ProfileScene:cleanup()
    -- Call parent cleanup
    Scene.cleanup(self)
    
    -- Remove all UI components from UIManager
    for _, component in ipairs(self.uiComponents) do
        UIManager.removeComponent(component)
    end
    
    -- Clear UI components
    self.profileSlots = {}
    self.uiComponents = {}
    self.logo = nil
    self.heading = nil
end

return ProfileScene 