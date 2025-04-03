-- UIManager.lua
-- Manages UI components and their interactions across different input types

local UIManager = {}

-- State
local state = {
    components = {},
    focusedComponent = nil,
    hoveredComponent = nil,
    activeComponent = nil,
    defaultFont = nil,
    buttonFont = nil,
    navigationEnabled = true,
    currentInputType = nil
}

-- Initialize the UI manager
function UIManager.initialize()
    -- Load fonts
    state.defaultFont = love.graphics.newFont(24)
    state.buttonFont = love.graphics.newFont(32)
    
    -- Set default font
    love.graphics.setFont(state.defaultFont)
    
    -- Set up input type change listener
    local InputManager = require('src/managers/InputManager')
    InputManager.setOnInputTypeChanged(function(inputType)
        UIManager.handleInputTypeChange(inputType)
    end)
    
    -- Set up key press listener
    InputManager.setOnKeyPressed(function(key)
        UIManager.handleKeyPress(key)
    end)
    
    -- Set up gamepad button press listener
    InputManager.setOnGamepadPress(function(button)
        UIManager.handleGamepadPress(button)
    end)
    
    -- Set up joystick direction listener
    InputManager.setOnJoystickDirection(function(direction)
        UIManager.handleJoystickDirection(direction)
    end)
end

-- Handle input type changes
function UIManager.handleInputTypeChange(inputType)
    print("UIManager: Input type changed to:", inputType)
    state.currentInputType = inputType
    
    -- Clear focus when switching to mouse/touch
    if inputType == "mouse" or inputType == "touch" then
        print("UIManager: Switching to mouse/touch, clearing focus")
        UIManager.clearFocus()
        UIManager.setNavigationEnabled(false)
    else
        -- Enable navigation for keyboard/gamepad
        print("UIManager: Switching to keyboard/gamepad, enabling navigation")
        UIManager.setNavigationEnabled(true)
        
        -- Set initial focus if none exists
        if not state.focusedComponent then
            print("UIManager: Setting initial focus")
            for _, component in ipairs(state.components) do
                if component.isFocusable and component:isFocusable() then
                    print("UIManager: Found focusable component for initial focus")
                    UIManager.setFocusedComponent(component)
                    break
                end
            end
        end
    end
end

-- Handle joystick direction
function UIManager.handleJoystickDirection(direction)
    if not state.navigationEnabled then return end
    UIManager.navigate(direction)
end

-- Update UI state
function UIManager.update(dt)
    -- Update all components
    for _, component in ipairs(state.components) do
        if component.update then
            component:update(dt)
        end
    end
end

-- Draw all UI components
function UIManager.draw()
    for _, component in ipairs(state.components) do
        if component.draw then
            component:draw()
        end
    end
end

-- Add a component to the UI manager
function UIManager.addComponent(component)
    table.insert(state.components, component)
    return #state.components
end

-- Remove a component from the UI manager
function UIManager.removeComponent(component)
    for i, comp in ipairs(state.components) do
        if comp == component then
            table.remove(state.components, i)
            break
        end
    end
end

-- Handle mouse/touch movement
function UIManager.handlePointerMove(x, y)
    -- Only handle pointer movement for mouse/touch input
    if state.currentInputType ~= "mouse" and state.currentInputType ~= "touch" then
        return
    end
    
    local foundHover = false
    
    -- Check components in reverse order (top to bottom)
    for i = #state.components, 1, -1 do
        local component = state.components[i]
        if component:isPointInside(x, y) then
            if state.hoveredComponent ~= component then
                if state.hoveredComponent and state.hoveredComponent.onHoverEnd then
                    state.hoveredComponent:onHoverEnd()
                end
                state.hoveredComponent = component
                if component.onHoverStart then
                    component:onHoverStart()
                end
            end
            foundHover = true
            break
        end
    end
    
    -- Handle unhover
    if not foundHover and state.hoveredComponent then
        if state.hoveredComponent.onHoverEnd then
            state.hoveredComponent:onHoverEnd()
        end
        state.hoveredComponent = nil
    end
end

-- Handle pointer press (mouse click or touch)
function UIManager.handlePointerPress(x, y)
    -- Only handle pointer press for mouse/touch input
    if state.currentInputType ~= "mouse" and state.currentInputType ~= "touch" then
        return
    end
    
    if state.hoveredComponent then
        state.activeComponent = state.hoveredComponent
        if state.hoveredComponent.onPress then
            state.hoveredComponent:onPress()
        end
    end
end

-- Handle pointer release
function UIManager.handlePointerRelease(x, y)
    -- Only handle pointer release for mouse/touch input
    if state.currentInputType ~= "mouse" and state.currentInputType ~= "touch" then
        return
    end
    
    if state.activeComponent then
        if state.activeComponent == state.hoveredComponent then
            if state.activeComponent.onClick then
                state.activeComponent:onClick()
            end
        end
        if state.activeComponent.onRelease then
            state.activeComponent:onRelease()
        end
        state.activeComponent = nil
    end
end

-- Handle keyboard input
function UIManager.handleKeyPress(key)
    -- Debug print
    print("UIManager: Received key press:", key)
    print("UIManager: Current input type:", state.currentInputType)
    print("UIManager: Navigation enabled:", state.navigationEnabled)
    print("UIManager: Focused component:", state.focusedComponent and "yes" or "no")
    
    -- Only handle navigation if enabled
    if not state.navigationEnabled then
        print("UIManager: Navigation is disabled")
        return
    end
    
    -- Handle navigation keys
    if key == "up" or key == "down" or key == "left" or key == "right" then
        -- Ensure we have a focused component before navigating
        if not state.focusedComponent then
            print("UIManager: No focused component, finding first focusable")
            -- Find first focusable component
            for _, component in ipairs(state.components) do
                if component.isFocusable and component:isFocusable() then
                    print("UIManager: Found focusable component")
                    UIManager.setFocusedComponent(component)
                    break
                end
            end
        end
        
        if state.focusedComponent then
            print("UIManager: Navigating in direction:", key)
            UIManager.navigate(key)
        else
            print("UIManager: No focusable components found")
        end
    else
        -- Handle other keys for focused component
        if state.focusedComponent and state.focusedComponent.onKeyPress then
            state.focusedComponent:onKeyPress(key)
        end
    end
end

-- Handle gamepad input
function UIManager.handleGamepadPress(button)
    if state.focusedComponent and state.focusedComponent.onGamepadPress then
        state.focusedComponent:onGamepadPress(button)
    end
end

-- Navigate to next component
function UIManager.navigate(direction)
    if not state.focusedComponent then
        -- Find first focusable component
        for _, component in ipairs(state.components) do
            if component.isFocusable and component:isFocusable() then
                UIManager.setFocusedComponent(component)
                break
            end
        end
        return
    end
    
    -- Get next component in direction
    local nextComponent = state.focusedComponent:getNavigation(direction)
    if nextComponent and nextComponent:isFocusable() then
        UIManager.setFocusedComponent(nextComponent)
    end
end

-- Set focused component
function UIManager.setFocusedComponent(component)
    if state.focusedComponent ~= component then
        if state.focusedComponent and state.focusedComponent.onFocusEnd then
            state.focusedComponent:onFocusEnd()
        end
        state.focusedComponent = component
        if component and component.onFocusStart then
            component:onFocusStart()
        end
    end
end

-- Get focused component
function UIManager.getFocusedComponent()
    return state.focusedComponent
end

-- Get hovered component
function UIManager.getHoveredComponent()
    return state.hoveredComponent
end

-- Get active component
function UIManager.getActiveComponent()
    return state.activeComponent
end

-- Enable/disable navigation
function UIManager.setNavigationEnabled(enabled)
    state.navigationEnabled = enabled
end

-- Clear focus
function UIManager.clearFocus()
    if state.focusedComponent then
        if state.focusedComponent.onFocusEnd then
            state.focusedComponent:onFocusEnd()
        end
        state.focusedComponent = nil
    end
end

return UIManager 