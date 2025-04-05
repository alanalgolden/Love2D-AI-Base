-- ProfileManager.lua
-- Manages player profiles and their data persistence

local ProfileManager = {}

-- Import dependencies
local Logger = require('src/utils/logger')
local json = require('src/utils/json')

-- State
local state = {
    profiles = {},
    currentProfile = nil,
    savePath = nil,  -- Will be set in initialize
    maxProfiles = 3
}

-- Get the save directory path
local function getSaveDirectory()
    local platform = love.system.getOS()
    if platform == "OS X" then
        -- On macOS, use Application Support
        local home = os.getenv("HOME")
        return home .. "/Library/Application Support/love/game-template/saves"
    elseif platform == "Windows" then
        -- On Windows, use AppData
        local appdata = os.getenv("APPDATA")
        return appdata .. "/love/game-template/saves"
    elseif platform == "Android" or platform == "iOS" then
        -- On mobile platforms, use the app's save directory
        return "saves"  -- This will be relative to love.filesystem.getSaveDirectory()
    else
        -- On Linux and other platforms, use a local saves directory
        return "saves"
    end
end

-- Initialize the profile manager
function ProfileManager.initialize()
    Logger.info("Initializing Profile Manager")
    
    -- Set the save path
    state.savePath = getSaveDirectory() .. "/profiles/"
    Logger.info("Save path set to: " .. state.savePath)
    
    -- Create profiles directory if it doesn't exist
    local platform = love.system.getOS()
    if platform == "Android" or platform == "iOS" then
        -- On mobile, use love.filesystem
        Logger.info("Creating save directory on mobile platform")
        love.filesystem.createDirectory("saves")
        love.filesystem.createDirectory("saves/profiles")
        Logger.info("Save directories created")
    else
        -- On desktop platforms, use os.execute
        local success = os.execute(string.format("mkdir -p '%s'", state.savePath))
        if not success then
            Logger.error("Failed to create save directory: " .. state.savePath)
            return false
        end
    end
    
    -- Load existing profiles
    ProfileManager.loadProfiles()
    
    Logger.info("Profile Manager initialized with save path: " .. state.savePath)
    return true
end

-- Load all profiles from disk
function ProfileManager.loadProfiles()
    -- Clear existing profiles
    state.profiles = {}
    
    -- Try to load each profile
    for i = 1, state.maxProfiles do
        local platform = love.system.getOS()
        local profilePath
        
        if platform == "Android" or platform == "iOS" then
            -- On mobile, use love.filesystem with relative path
            profilePath = "saves/profiles/profile_" .. i .. ".json"
            Logger.info("Attempting to load profile from: " .. profilePath)
            
            if love.filesystem.getInfo(profilePath) then
                local success, data = pcall(function()
                    local jsonData = love.filesystem.read(profilePath)
                    return json.decode(jsonData)
                end)
                
                if success and data then
                    state.profiles[i] = data
                    Logger.info("Successfully loaded profile " .. i)
                else
                    Logger.error("Failed to load profile " .. i .. ": " .. tostring(data))
                end
            else
                Logger.info("Profile " .. i .. " does not exist yet")
            end
        else
            -- On desktop platforms, use standard Lua I/O
            profilePath = state.savePath .. "profile_" .. i .. ".json"
            Logger.info("Attempting to load profile from: " .. profilePath)
            
            local file = io.open(profilePath, "r")
            if file then
                local success, data = pcall(function()
                    local jsonData = file:read("*all")
                    file:close()
                    return json.decode(jsonData)
                end)
                
                if success and data then
                    state.profiles[i] = data
                    Logger.info("Successfully loaded profile " .. i)
                else
                    Logger.error("Failed to load profile " .. i .. ": " .. tostring(data))
                end
            else
                Logger.info("Profile " .. i .. " does not exist yet")
            end
        end
    end
end

-- Save a profile to disk
function ProfileManager.saveProfile(profileId, profileData)
    if profileId < 1 or profileId > state.maxProfiles then
        Logger.error("Invalid profile ID: " .. profileId)
        return false
    end
    
    Logger.info("Attempting to save profile " .. profileId)
    Logger.info("Profile data: " .. json.encode(profileData))
    
    local success, jsonData = pcall(function()
        return json.encode(profileData)
    end)
    
    if success then
        local platform = love.system.getOS()
        if platform == "Android" or platform == "iOS" then
            -- On mobile, use love.filesystem with relative path
            local profilePath = "saves/profiles/profile_" .. profileId .. ".json"
            Logger.info("Writing profile to: " .. profilePath)
            
            -- Ensure the directory exists
            love.filesystem.createDirectory("saves")
            love.filesystem.createDirectory("saves/profiles")
            
            local success = love.filesystem.write(profilePath, jsonData)
            if success then
                state.profiles[profileId] = profileData
                Logger.info("Successfully saved profile " .. profileId)
                return true
            else
                Logger.error("Failed to write profile " .. profileId .. " to disk")
                return false
            end
        else
            -- On desktop platforms, use standard Lua I/O
            local profilePath = state.savePath .. "profile_" .. profileId .. ".json"
            Logger.info("Writing profile to: " .. profilePath)
            
            -- Ensure the directory exists
            local dirSuccess = os.execute(string.format("mkdir -p '%s'", state.savePath))
            if not dirSuccess then
                Logger.error("Failed to create save directory: " .. state.savePath)
                return false
            end
            
            -- Use standard Lua I/O to write the file
            local file = io.open(profilePath, "w")
            if file then
                file:write(jsonData)
                file:close()
                
                state.profiles[profileId] = profileData
                Logger.info("Successfully saved profile " .. profileId)
                return true
            else
                Logger.error("Failed to write profile " .. profileId .. " to disk")
                return false
            end
        end
    else
        Logger.error("Failed to encode profile " .. profileId .. ": " .. tostring(jsonData))
        return false
    end
end

-- Create a new profile
function ProfileManager.createProfile(profileId)
    if profileId < 1 or profileId > state.maxProfiles then
        Logger.error("Invalid profile ID: " .. profileId)
        return false
    end
    
    if state.profiles[profileId] then
        Logger.error("Profile " .. profileId .. " already exists")
        return false
    end
    
    local newProfile = {
        id = profileId,
        name = "Player " .. profileId,
        created = os.time(),
        lastPlayed = os.time(),
        settings = {
            fullscreen = false,
            musicVolume = 1.0,
            sfxVolume = 1.0
        },
        progress = {
            unlockedLevels = {1},
            highScore = 0,
            totalPlayTime = 0
        }
    }
    
    return ProfileManager.saveProfile(profileId, newProfile)
end

-- Get a profile by ID
function ProfileManager.getProfile(profileId)
    return state.profiles[profileId]
end

-- Get all profiles
function ProfileManager.getAllProfiles()
    return state.profiles
end

-- Set the current profile
function ProfileManager.setCurrentProfile(profileId)
    if not state.profiles[profileId] then
        Logger.error("Profile " .. profileId .. " does not exist")
        return false
    end
    
    state.currentProfile = profileId
    Logger.info("Set current profile to: " .. profileId)
    return true
end

-- Get the current profile
function ProfileManager.getCurrentProfile()
    return state.currentProfile and state.profiles[state.currentProfile]
end

-- Update profile data
function ProfileManager.updateProfile(profileId, data)
    if not state.profiles[profileId] then
        Logger.error("Profile " .. profileId .. " does not exist")
        return false
    end
    
    -- Helper function to merge tables recursively
    local function mergeTables(target, source)
        for k, v in pairs(source) do
            if type(v) == "table" and type(target[k]) == "table" then
                mergeTables(target[k], v)
            else
                target[k] = v
            end
        end
    end
    
    -- Merge new data with existing profile
    mergeTables(state.profiles[profileId], data)
    
    -- Update last played time
    state.profiles[profileId].lastPlayed = os.time()
    
    return ProfileManager.saveProfile(profileId, state.profiles[profileId])
end

-- Delete a profile
function ProfileManager.deleteProfile(profileId)
    if not state.profiles[profileId] then
        Logger.error("Profile " .. profileId .. " does not exist")
        return false
    end
    
    local profilePath = state.savePath .. "profile_" .. profileId .. ".json"
    
    -- Use standard Lua I/O to remove the file
    local success = os.remove(profilePath)
    
    if success then
        state.profiles[profileId] = nil
        if state.currentProfile == profileId then
            state.currentProfile = nil
        end
        Logger.info("Deleted profile " .. profileId)
        return true
    else
        Logger.error("Failed to delete profile " .. profileId)
        return false
    end
end

return ProfileManager 