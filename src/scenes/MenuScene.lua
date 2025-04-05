-- MenuScene.lua
-- Menu scene for the game

local Scene = require('src/engine/Scene')
local Button = require('src/components/Button')
local Image = require('src/components/Image')
local UIManager = require('src/managers/UIManager')
local ProfileManager = require('src/managers/ProfileManager')
local Logger = require('src/utils/logger')
local SceneManager = require('src/managers/SceneManager')
local RunManager = require('src/managers/RunManager')

local MenuScene = {}
MenuScene.__index = MenuScene
setmetatable(MenuScene, Scene)

-- Create a new menu scene
function MenuScene.new()
    local self = setmetatable(Scene.new("menu"), MenuScene)
    
    -- Menu properties
    self.buttons = {}
    self.logo = nil
    self.uiComponents = {}
    
    return self
end

-- Initialize the menu scene
function MenuScene:initialize()
    -- Check if a profile is selected
    if not ProfileManager.getCurrentProfile() then
        Logger.warning("No profile selected, returning to profile selection")
        local SceneManager = require('src/managers/SceneManager')
        SceneManager.setScene("profile")
        return
    end
    
    -- Call parent initialize
    Scene.initialize(self)
    
    -- Create menu UI elements
    self:createUI()
    
    Logger.info("Menu scene initialized")
end

-- Create UI elements
function MenuScene:createUI()
    -- Create logo
    self.logo = Image.new("assets/images/logo.png", 960, 200, 400, 200)
    table.insert(self.uiComponents, self.logo)
    UIManager.addComponent(self.logo)
    
    -- Create menu buttons
    local buttonWidth = 300
    local buttonHeight = 60
    local buttonSpacing = 20
    local startY = 540
    
    -- Start Game button
    local startButton = Button.new(
        810, startY, buttonWidth, buttonHeight, "Start Game",
        function()
            -- Start a new run
            local runConfig = {
                difficulty = "normal",
                characterClass = "warrior"
            }
            local RunManager = require('src/managers/RunManager')
            RunManager.startNewRun(runConfig)
            
            -- Set the game scene
            local SceneManager = require('src/managers/SceneManager')
            SceneManager.setScene("game")
        end
    )
    table.insert(self.buttons, startButton)
    table.insert(self.uiComponents, startButton)
    UIManager.addComponent(startButton)
    
    -- Settings button
    local settingsButton = Button.new(
        810, startY + buttonHeight + buttonSpacing, buttonWidth, buttonHeight, "Settings",
        function()
            -- Set the settings scene
            local SceneManager = require('src/managers/SceneManager')
            SceneManager.setScene("settings")
        end
    )
    table.insert(self.buttons, settingsButton)
    table.insert(self.uiComponents, settingsButton)
    UIManager.addComponent(settingsButton)
    
    -- Change Profile button
    local changeProfileButton = Button.new(
        810, startY + (buttonHeight + buttonSpacing) * 2, buttonWidth, buttonHeight, "Change Profile",
        function()
            -- Return to profile selection
            local SceneManager = require('src/managers/SceneManager')
            SceneManager.setScene("profile")
        end
    )
    table.insert(self.buttons, changeProfileButton)
    table.insert(self.uiComponents, changeProfileButton)
    UIManager.addComponent(changeProfileButton)
    
    -- Quit button
    local quitButton = Button.new(
        810, startY + (buttonHeight + buttonSpacing) * 3, buttonWidth, buttonHeight, "Quit",
        function()
            Logger.info("Quitting game")
            -- Clean up current scene
            self:cleanup()
            -- Ensure all logs are written
            Logger.flush()
            -- Quit the game
            love.event.quit(0)
        end
    )
    table.insert(self.buttons, quitButton)
    table.insert(self.uiComponents, quitButton)
    UIManager.addComponent(quitButton)
    
    -- Set up navigation
    startButton:setNavigation("down", settingsButton)
    settingsButton:setNavigation("up", startButton)
    settingsButton:setNavigation("down", changeProfileButton)
    changeProfileButton:setNavigation("up", settingsButton)
    changeProfileButton:setNavigation("down", quitButton)
    quitButton:setNavigation("up", changeProfileButton)
    
    -- Set initial focus
    UIManager.setFocusedComponent(startButton)
end

-- Update the menu scene
function MenuScene:update(dt)
    -- Call parent update
    Scene.update(self, dt)
    
    -- Update all UI components
    for _, component in ipairs(self.uiComponents) do
        if component.update then
            component:update(dt)
        end
    end
end

-- Draw the menu scene
function MenuScene:draw()
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
function MenuScene:keypressed(key)
    -- Handle escape key to quit
    if key == "escape" then
        love.event.quit()
        return
    end
    
    -- We don't need to handle navigation keys here as they're already handled by UIManager
    -- We only need to handle special keys that aren't part of the UI navigation
end

-- Handle mouse press
function MenuScene:mousepressed(x, y, button)
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
function MenuScene:cleanup()
    -- Call parent cleanup
    Scene.cleanup(self)
    
    -- Remove all UI components from UIManager
    for _, component in ipairs(self.uiComponents) do
        UIManager.removeComponent(component)
    end
    
    -- Clear UI components
    self.buttons = {}
    self.uiComponents = {}
    self.logo = nil
end

return MenuScene 