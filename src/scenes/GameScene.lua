-- GameScene.lua
-- Game scene for the main gameplay

local Scene = require('src/engine/Scene')
local Entity = require('src/engine/Entity')
local Component = require('src/engine/Component')
local System = require('src/engine/System')
local RunManager = require('src/engine/RunManager')
local Logger = require('src/utils/logger')
local Button = require('src/components/Button')
local UIManager = require('src/managers/UIManager')

local GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, Scene)

-- Create a new game scene
function GameScene.new()
    local self = setmetatable(Scene.new("game"), GameScene)
    
    -- Game properties
    self.player = nil
    self.enemies = {}
    self.items = {}
    self.level = 1
    self.score = 0
    
    -- UI components
    self.uiComponents = {}
    self.counter = 0
    self.incrementButton = nil
    self.endGameButton = nil
    self.counterText = nil
    
    return self
end

-- Initialize the game scene
function GameScene:initialize()
    -- Call parent initialize
    Scene.initialize(self)
    
    -- Initialize game systems
    self:initializeSystems()
    
    -- Create game entities
    self:createEntities()
    
    -- Create UI components
    self:createUIComponents()
    
    -- Set initial focus for keyboard/gamepad navigation
    local UIManager = require('src/managers/UIManager')
    UIManager.setFocusedComponent(self.incrementButton)
    
    Logger.info("Game scene initialized")
end

-- Initialize game systems
function GameScene:initializeSystems()
    -- Create and add systems
    local movementSystem = self:createMovementSystem()
    local collisionSystem = self:createCollisionSystem()
    local combatSystem = self:createCombatSystem()
    local itemSystem = self:createItemSystem()
    
    self:addSystem(movementSystem)
    self:addSystem(collisionSystem)
    self:addSystem(combatSystem)
    self:addSystem(itemSystem)
end

-- Create movement system
function GameScene:createMovementSystem()
    local MovementSystem = System.new("movement")
    MovementSystem:addRequiredComponent("position")
    MovementSystem:addRequiredComponent("velocity")
    
    function MovementSystem:update(dt)
        for _, entity in ipairs(self.entities) do
            local position = entity:getComponent("position")
            local velocity = entity:getComponent("velocity")
            
            position.x = position.x + velocity.x * dt
            position.y = position.y + velocity.y * dt
        end
    end
    
    return MovementSystem
end

-- Create collision system
function GameScene:createCollisionSystem()
    local CollisionSystem = System.new("collision")
    CollisionSystem:addRequiredComponent("position")
    CollisionSystem:addRequiredComponent("collider")
    
    function CollisionSystem:update(dt)
        -- Check collisions between entities
        for i, entityA in ipairs(self.entities) do
            local posA = entityA:getComponent("position")
            local colliderA = entityA:getComponent("collider")
            
            for j = i + 1, #self.entities do
                local entityB = self.entities[j]
                local posB = entityB:getComponent("position")
                local colliderB = entityB:getComponent("collider")
                
                -- Simple circle collision detection
                local dx = posA.x - posB.x
                local dy = posA.y - posB.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance < (colliderA.radius + colliderB.radius) then
                    -- Collision detected
                    if entityA.onCollision then
                        entityA:onCollision(entityB)
                    end
                    if entityB.onCollision then
                        entityB:onCollision(entityA)
                    end
                end
            end
        end
    end
    
    return CollisionSystem
end

-- Create combat system
function GameScene:createCombatSystem()
    local CombatSystem = System.new("combat")
    CombatSystem:addRequiredComponent("health")
    CombatSystem:addRequiredComponent("attack")
    
    function CombatSystem:update(dt)
        -- Process combat logic
        for _, entity in ipairs(self.entities) do
            local health = entity:getComponent("health")
            local attack = entity:getComponent("attack")
            
            -- Example: Regenerate health over time
            if health.current < health.max and health.regeneration > 0 then
                health.current = math.min(health.current + health.regeneration * dt, health.max)
            end
            
            -- Example: Cooldown for attacks
            if attack.cooldown > 0 then
                attack.cooldown = math.max(0, attack.cooldown - dt)
            end
        end
    end
    
    return CombatSystem
end

-- Create item system
function GameScene:createItemSystem()
    local ItemSystem = System.new("item")
    ItemSystem:addRequiredComponent("item")
    
    function ItemSystem:update(dt)
        -- Process item effects
        for _, entity in ipairs(self.entities) do
            local item = entity:getComponent("item")
            
            -- Example: Apply item effects over time
            if item.duration > 0 then
                item.duration = item.duration - dt
                if item.duration <= 0 then
                    -- Item effect expired
                    if entity.onItemExpired then
                        entity:onItemExpired()
                    end
                end
            end
        end
    end
    
    return ItemSystem
end

-- Create game entities
function GameScene:createEntities()
    -- Create player
    self.player = self:createPlayer()
    self:addEntity(self.player)
    
    -- Create initial enemies
    for i = 1, 5 do
        local enemy = self:createEnemy()
        self:addEntity(enemy)
        table.insert(self.enemies, enemy)
    end
    
    -- Create initial items
    for i = 1, 3 do
        local item = self:createItem()
        self:addEntity(item)
        table.insert(self.items, item)
    end
end

-- Create player entity
function GameScene:createPlayer()
    local player = Entity.new("player", "Player")
    
    -- Add components
    player:addComponent({
        type = "position",
        x = 500,
        y = 500
    })
    
    player:addComponent({
        type = "velocity",
        x = 0,
        y = 0
    })
    
    player:addComponent({
        type = "collider",
        radius = 20
    })
    
    player:addComponent({
        type = "health",
        current = 100,
        max = 100
    })
    
    player:addComponent({
        type = "attack",
        damage = 10,
        range = 50
    })
    
    -- Add player-specific methods
    function player:onCollision(other)
        -- Handle player collision
    end
    
    return player
end

-- Create enemy entity
function GameScene:createEnemy()
    local enemy = Entity.new("enemy", "Enemy")
    
    -- Random position
    local x = math.random(100, 900)
    local y = math.random(100, 900)
    
    -- Add components
    enemy:addComponent({
        type = "position",
        x = x,
        y = y
    })
    
    enemy:addComponent({
        type = "velocity",
        x = 0,
        y = 0
    })
    
    enemy:addComponent({
        type = "collider",
        radius = 15
    })
    
    enemy:addComponent({
        type = "health",
        current = 50,
        max = 50
    })
    
    enemy:addComponent({
        type = "attack",
        damage = 5,
        range = 30
    })
    
    -- Add enemy-specific methods
    function enemy:onCollision(other)
        -- Handle enemy collision
    end
    
    return enemy
end

-- Create item entity
function GameScene:createItem()
    local item = Entity.new("item", "Item")
    
    -- Random position
    local x = math.random(100, 900)
    local y = math.random(100, 900)
    
    -- Add components
    item:addComponent({
        type = "position",
        x = x,
        y = y
    })
    
    item:addComponent({
        type = "collider",
        radius = 10
    })
    
    item:addComponent({
        type = "item",
        type = "health_potion",
        value = 20
    })
    
    -- Add item-specific methods
    function item:onCollision(other)
        -- Handle item collision
        if other.id == "player" then
            -- Apply item effect
            local health = other:getComponent("health")
            if health then
                health.current = math.min(health.current + self:getComponent("item").value, health.max)
            end
            
            -- Remove item
            self:deactivate()
        end
    end
    
    return item
end

-- Create UI components
function GameScene:createUIComponents()
    -- Get window dimensions for centering
    local WindowManager = require('src/managers/WindowManager')
    local baseWidth, baseHeight = WindowManager.getBaseDimensions()
    
    -- Get the current run seed
    local GameEngine = require('src/engine/GameEngine')
    local runSeed = GameEngine.getSeed()
    
    -- Create counter text
    self.counterText = {
        draw = function()
            love.graphics.setColor(1, 1, 1)
            -- Center the counter text
            local text = "Counter: " .. self.counter
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(text) * 2 -- Scale factor of 2
            local textX = (baseWidth - textWidth) / 2
            love.graphics.print(text, textX, 50, 0, 2, 2)
        end
    }
    table.insert(self.uiComponents, self.counterText)
    
    -- Create increment button (centered)
    local buttonWidth = 200
    local buttonHeight = 50
    local buttonX = (baseWidth - buttonWidth) / 2
    local buttonY = 150
    
    self.incrementButton = Button.new(buttonX, buttonY, buttonWidth, buttonHeight, "Increment Counter", function()
        self.counter = self.counter + 1
        Logger.info("Counter incremented to: " .. self.counter)
    end)
    UIManager.addComponent(self.incrementButton)
    table.insert(self.uiComponents, self.incrementButton)
    
    -- Create end game button (centered)
    buttonY = buttonY + buttonHeight + 20
    
    self.endGameButton = Button.new(buttonX, buttonY, buttonWidth, buttonHeight, "End Game", function()
        self:gameOver()
    end)
    UIManager.addComponent(self.endGameButton)
    table.insert(self.uiComponents, self.endGameButton)
    
    -- Create seed text (centered under End Game button)
    buttonY = buttonY + buttonHeight + 20
    
    self.seedText = {
        draw = function()
            love.graphics.setColor(0.7, 0.7, 0.7)
            -- Center the seed text
            local text = "Seed: " .. runSeed
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(text)
            local textX = (baseWidth - textWidth) / 2
            love.graphics.print(text, textX, buttonY)
        end
    }
    table.insert(self.uiComponents, self.seedText)
    
    -- Set up navigation between buttons
    self.incrementButton:setNavigation("down", self.endGameButton)
    self.endGameButton:setNavigation("up", self.incrementButton)
end

-- Update the game scene
function GameScene:update(dt)
    -- Call parent update
    Scene.update(self, dt)
    
    -- Update UI components
    for _, component in ipairs(self.uiComponents) do
        if component.update then
            component:update(dt)
        end
    end
    
    -- Add game-specific update logic here
    
    -- Check for game over
    if self.player:getComponent("health").current <= 0 then
        self:gameOver()
    end
end

-- Draw the game scene
function GameScene:draw()
    -- Call parent draw
    Scene.draw(self)
    
    -- Draw UI components
    for _, component in ipairs(self.uiComponents) do
        if component.draw then
            component:draw()
        end
    end
    
    -- Add game-specific draw logic here
end

-- Handle key press
function GameScene:keypressed(key)
    -- Handle player movement
    local velocity = self.player:getComponent("velocity")
    
    if key == "w" or key == "up" then
        velocity.y = -200
    elseif key == "s" or key == "down" then
        velocity.y = 200
    elseif key == "a" or key == "left" then
        velocity.x = -200
    elseif key == "d" or key == "right" then
        velocity.x = 200
    elseif key == "space" then
        self:playerAttack()
    end
end

-- Handle key release
function GameScene:keyreleased(key)
    -- Handle player movement stop
    local velocity = self.player:getComponent("velocity")
    
    if key == "w" or key == "up" then
        velocity.y = 0
    elseif key == "s" or key == "down" then
        velocity.y = 0
    elseif key == "a" or key == "left" then
        velocity.x = 0
    elseif key == "d" or key == "right" then
        velocity.x = 0
    end
end

-- Player attack
function GameScene:playerAttack()
    local playerPos = self.player:getComponent("position")
    local attack = self.player:getComponent("attack")
    
    -- Check for enemies in range
    for _, enemy in ipairs(self.enemies) do
        if enemy:isActive() then
            local enemyPos = enemy:getComponent("position")
            
            -- Calculate distance
            local dx = playerPos.x - enemyPos.x
            local dy = playerPos.y - enemyPos.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- If enemy is in range, damage it
            if distance <= attack.range then
                local enemyHealth = enemy:getComponent("health")
                enemyHealth.current = enemyHealth.current - attack.damage
                
                -- Check if enemy is dead
                if enemyHealth.current <= 0 then
                    enemy:deactivate()
                    self.score = self.score + 10
                end
            end
        end
    end
end

-- Game over
function GameScene:gameOver()
    Logger.info("Game Over! Score: " .. self.score)
    
    -- Clean up UI components before ending the run
    self:cleanup()
    
    -- End the current run
    RunManager.endCurrentRun()
    
    -- Return to menu
    local SceneManager = require('src/engine/SceneManager')
    SceneManager.setScene("menu")
end

-- Clean up resources
function GameScene:cleanup()
    -- Remove UI components first
    for _, component in ipairs(self.uiComponents) do
        -- Use UIManager's removeComponent method directly
        UIManager.removeComponent(component)
    end
    self.uiComponents = {}
    
    -- Call parent cleanup
    Scene.cleanup(self)
    
    -- Add game-specific cleanup logic here
end

return GameScene 