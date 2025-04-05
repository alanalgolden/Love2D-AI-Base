-- SettingsScene.lua
-- Settings scene for the game

local Scene = require('src/engine/Scene')
local Button = require('src/components/Button')
local Text = require('src/components/Text')
local UIManager = require('src/managers/UIManager')
local WindowManager = require('src/managers/WindowManager')
local ProfileManager = require('src/managers/ProfileManager')
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
    
    -- Confirmation dialog properties
    self.confirmationDialog = nil
    self.confirmationButtons = {}
    self.confirmationBackground = nil
    
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
    local baseWidth, baseHeight = WindowManager.getBaseDimensions()
    local buttonWidth = 300
    local buttonHeight = 60
    local buttonSpacing = 30
    local startY = baseHeight * 0.4
    
    -- Create title text
    local titleText = Text.new(0, 50, baseWidth, 50, "Settings")
    titleText:setFontSize(32):setAlignment("center")
    table.insert(self.uiComponents, titleText)
    UIManager.addComponent(titleText)
    
    -- Create back button
    local backButton = Button.new(
        (baseWidth - buttonWidth) / 2,
        startY,
        buttonWidth,
        buttonHeight,
        "Back",
        function()
            local SceneManager = require('src/engine/SceneManager')
            SceneManager.setScene("menu")
        end
    )
    backButton:setTextPadding(20, 10)  -- Add proper padding for text
    table.insert(self.buttons, backButton)
    table.insert(self.uiComponents, backButton)
    UIManager.addComponent(backButton)
    
    -- Create fullscreen button (only on PC platforms)
    if self.isPC then
        local fullscreenButton = Button.new(
            (baseWidth - buttonWidth) / 2,
            startY + buttonHeight + buttonSpacing,
            buttonWidth,
            buttonHeight,
            "Fullscreen: " .. (self.settings.fullscreen and "On" or "Off"),
            function()
                self.settings.fullscreen = not self.settings.fullscreen
                self:updateFullscreenButtonText()
                WindowManager.toggleFullscreen()
            end
        )
        fullscreenButton:setTextPadding(20, 10)  -- Add proper padding for text
        table.insert(self.buttons, fullscreenButton)
        table.insert(self.uiComponents, fullscreenButton)
        UIManager.addComponent(fullscreenButton)
    end
    
    -- Create reset progress button
    local resetButton = Button.new(
        (baseWidth - buttonWidth) / 2,
        startY + (self.isPC and 2 or 1) * (buttonHeight + buttonSpacing),
        buttonWidth,
        buttonHeight,
        "Reset Progress",
        function()
            self:showResetConfirmation()
        end
    )
    resetButton:setTextPadding(20, 10)  -- Add proper padding for text
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

-- Show reset confirmation dialog
function SettingsScene:showResetConfirmation()
    local baseWidth, baseHeight = WindowManager.getBaseDimensions()
    local dialogWidth = 400
    local dialogHeight = 200
    local buttonWidth = 120
    local buttonHeight = 50
    
    -- Create confirmation background
    self.confirmationBackground = Button.new(
        (baseWidth - dialogWidth) / 2,
        (baseHeight - dialogHeight) / 2,
        dialogWidth,
        dialogHeight,
        "",  -- No text
        function() end  -- No action
    )
    self.confirmationBackground:setColors({
        normal = {0.1, 0.1, 0.1, 0.9},    -- Dark gray with high opacity
        hover = {0.1, 0.1, 0.1, 0.9},     -- Same as normal
        pressed = {0.1, 0.1, 0.1, 0.9},   -- Same as normal
        focused = {0.1, 0.1, 0.1, 0.9},   -- Same as normal
        text = {1, 1, 1, 1}               -- White (not used)
    })
    table.insert(self.uiComponents, self.confirmationBackground)
    UIManager.addComponent(self.confirmationBackground)
    
    -- Create confirmation text
    self.confirmationDialog = Text.new(
        (baseWidth - dialogWidth) / 2,
        (baseHeight - dialogHeight) / 2 + 30,
        dialogWidth,
        50,
        "Reset progress, are you sure?"
    )
    self.confirmationDialog:setFontSize(24):setAlignment("center")
    table.insert(self.uiComponents, self.confirmationDialog)
    UIManager.addComponent(self.confirmationDialog)
    
    -- Create Yes button
    local yesButton = Button.new(
        (baseWidth - dialogWidth) / 2 + (dialogWidth - buttonWidth * 2 - 20) / 2,
        (baseHeight - dialogHeight) / 2 + dialogHeight - buttonHeight - 20,
        buttonWidth,
        buttonHeight,
        "Yes",
        function()
            self:resetProgress()
            -- Return to profile menu after reset
            local SceneManager = require('src/engine/SceneManager')
            -- Clean up this scene first
            self:cleanup()
            -- Then set the new scene
            SceneManager.setScene("profile")
        end
    )
    yesButton:setTextPadding(20, 10)
    table.insert(self.confirmationButtons, yesButton)
    table.insert(self.uiComponents, yesButton)
    UIManager.addComponent(yesButton)
    
    -- Create No button
    local noButton = Button.new(
        (baseWidth - dialogWidth) / 2 + dialogWidth - (dialogWidth - buttonWidth * 2 - 20) / 2 - buttonWidth,
        (baseHeight - dialogHeight) / 2 + dialogHeight - buttonHeight - 20,
        buttonWidth,
        buttonHeight,
        "No",
        function()
            self:hideResetConfirmation()
        end
    )
    noButton:setTextPadding(20, 10)
    table.insert(self.confirmationButtons, noButton)
    table.insert(self.uiComponents, noButton)
    UIManager.addComponent(noButton)
    
    -- Set up navigation between confirmation buttons
    yesButton:setNavigation("right", noButton)
    noButton:setNavigation("left", yesButton)
    
    -- Set initial focus to Yes button
    UIManager.setFocusedComponent(yesButton)
    
    -- Disable main menu buttons while dialog is open
    for _, button in ipairs(self.buttons) do
        button:setFocusable(false)
    end
end

-- Hide reset confirmation dialog
function SettingsScene:hideResetConfirmation()
    -- Remove confirmation background
    if self.confirmationBackground then
        UIManager.removeComponent(self.confirmationBackground)
        table.remove(self.uiComponents, 1)  -- Remove background
        self.confirmationBackground = nil
    end
    
    -- Remove confirmation dialog and buttons
    if self.confirmationDialog then
        UIManager.removeComponent(self.confirmationDialog)
        table.remove(self.uiComponents, 1)  -- Remove dialog text
        self.confirmationDialog = nil
    end
    
    for _, button in ipairs(self.confirmationButtons) do
        UIManager.removeComponent(button)
        table.remove(self.uiComponents, 1)  -- Remove buttons
    end
    self.confirmationButtons = {}
    
    -- Re-enable main menu buttons
    for _, button in ipairs(self.buttons) do
        button:setFocusable(true)
    end
    
    -- Set focus back to reset button
    UIManager.setFocusedComponent(self.buttons[#self.buttons])
end

-- Reset progress
function SettingsScene:resetProgress()
    local currentProfile = ProfileManager.getCurrentProfile()
    if currentProfile then
        -- Reset progress data
        currentProfile.progress = {
            unlockedLevels = {1},
            highScore = 0,
            totalPlayTime = 0
        }
        
        -- Save the updated profile
        ProfileManager.updateProfile(currentProfile.id, currentProfile)
        Logger.info("Progress reset for profile " .. currentProfile.id)
    else
        Logger.error("No current profile to reset")
    end
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
    
    -- Draw all UI components
    for _, component in ipairs(self.uiComponents) do
        if component.draw then
            component:draw()
        end
    end
end

-- Handle key press
function SettingsScene:keypressed(key)
    if key == "escape" then
        if self.confirmationDialog then
            self:hideResetConfirmation()
        else
            local SceneManager = require('src/engine/SceneManager')
            SceneManager.setScene("menu")
        end
        return
    end
end

-- Handle mouse press
function SettingsScene:mousepressed(x, y, button)
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
    self.confirmationDialog = nil
    self.confirmationButtons = {}
    self.confirmationBackground = nil
end

return SettingsScene 