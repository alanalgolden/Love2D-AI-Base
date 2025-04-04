-- SettingsScene.lua
-- Settings scene for the game

local Scene = require('src/engine/Scene')
local Button = require('src/components/Button')
local UIManager = require('src/managers/UIManager')
local Logger = require('src/utils/logger')

local SettingsScene = {}
SettingsScene.__index = SettingsScene
setmetatable(SettingsScene, Scene)

-- Create a new settings scene
function SettingsScene.new()
    local self = setmetatable(Scene.new("settings"), SettingsScene)
    
    -- Settings properties
    self.buttons = {}
    self.uiComponents = {}
    self.settings = {
        fullscreen = false
    }
    
    -- Check if we're on a PC platform
    self.isPC = love.system.getOS() == "Windows" or 
                love.system.getOS() == "OS X" or 
                love.system.getOS() == "Linux"
    
    return self
end

-- Initialize the settings scene
function SettingsScene:initialize()
    -- Call parent initialize
    Scene.initialize(self)
    
    -- Create settings UI elements
    self:createUI()
    
    Logger.info("Settings scene initialized")
end

-- Create UI elements
function SettingsScene:createUI()
    -- Create back button
    local backButton = Button.new(
        810, 100, 200, 50, "Back",
        function()
            -- Return to menu
            local SceneManager = require('src/engine/SceneManager')
            SceneManager.setScene("menu")
        end
    )
    table.insert(self.buttons, backButton)
    table.insert(self.uiComponents, backButton)
    UIManager.addComponent(backButton)
    
    -- Create fullscreen button (only on PC platforms)
    if self.isPC then
        local fullscreenButton = Button.new(
            810, 200, 200, 50, "Fullscreen: " .. (self.settings.fullscreen and "On" or "Off"),
            function()
                -- Toggle fullscreen
                self.settings.fullscreen = not self.settings.fullscreen
                self:updateFullscreenButtonText()
                
                -- Apply fullscreen setting
                local WindowManager = require('src/managers/WindowManager')
                WindowManager.toggleFullscreen()
            end
        )
        table.insert(self.buttons, fullscreenButton)
        table.insert(self.uiComponents, fullscreenButton)
        UIManager.addComponent(fullscreenButton)
    end
    
    -- Create reset progress button
    local resetButton = Button.new(
        810, self.isPC and 300 or 200, 200, 50, "Reset Progress",
        function()
            -- This will be implemented later
            Logger.info("Reset progress requested")
            -- Show confirmation dialog or implement reset logic here
        end
    )
    table.insert(self.buttons, resetButton)
    table.insert(self.uiComponents, resetButton)
    UIManager.addComponent(resetButton)
    
    -- Set up navigation
    if self.isPC then
        backButton:setNavigation("down", self.buttons[2]) -- fullscreen button
        self.buttons[2]:setNavigation("up", backButton)
        self.buttons[2]:setNavigation("down", resetButton)
        resetButton:setNavigation("up", self.buttons[2])
    else
        backButton:setNavigation("down", resetButton)
        resetButton:setNavigation("up", backButton)
    end
    
    -- Set initial focus
    UIManager.setFocusedComponent(backButton)
end

-- Update fullscreen button text
function SettingsScene:updateFullscreenButtonText()
    for _, button in ipairs(self.buttons) do
        if button.text and button.text:find("Fullscreen:") then
            button:setText("Fullscreen: " .. (self.settings.fullscreen and "On" or "Off"))
            break
        end
    end
end

-- Update the settings scene
function SettingsScene:update(dt)
    -- Call parent update
    Scene.update(self, dt)
    
    -- Update all UI components
    for _, component in ipairs(self.uiComponents) do
        if component.update then
            component:update(dt)
        end
    end
end

-- Draw the settings scene
function SettingsScene:draw()
    -- Call parent draw
    Scene.draw(self)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Settings", 0, 50, love.graphics.getWidth(), "center")
    
    -- Draw all UI components
    for _, component in ipairs(self.uiComponents) do
        if component.draw then
            component:draw()
        end
    end
end

-- Handle key press
function SettingsScene:keypressed(key)
    -- Handle escape key to go back to menu
    if key == "escape" then
        local SceneManager = require('src/engine/SceneManager')
        SceneManager.setScene("menu")
        return
    end
    
    -- We don't need to handle navigation keys here as they're already handled by UIManager
    -- We only need to handle special keys that aren't part of the UI navigation
end

-- Handle mouse press
function SettingsScene:mousepressed(x, y, button)
    -- Check if any button was clicked
    for _, button in ipairs(self.buttons) do
        if button:isPointInside(x, y) then
            if button.onPress then
                button:onPress()
            end
            break
        end
    end
end

-- Clean up resources
function SettingsScene:cleanup()
    -- Call parent cleanup
    Scene.cleanup(self)
    
    -- Remove all UI components from UIManager
    for _, component in ipairs(self.uiComponents) do
        UIManager.removeComponent(component)
    end
    
    -- Clear UI components
    self.buttons = {}
    self.uiComponents = {}
end

return SettingsScene 