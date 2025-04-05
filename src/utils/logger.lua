local Logger = {}

-- Log levels
Logger.Levels = {
    DEBUG = "DEBUG",
    INFO = "INFO",
    WARNING = "WARNING",
    ERROR = "ERROR"
}

-- Default configuration
local config = {
    bufferSize = 1000,  -- Increased default buffer size
    flushCooldown = 1.0,  -- Seconds between flushes
    minLevel = "DEBUG",  -- Minimum log level to record
    maxLogSize = 1024 * 1024,  -- 1MB max log size
    maxLogFiles = 3  -- Keep 3 log files
}

-- Buffer state
local lastFlushTime = 0
local messageBuffer = {}

-- Platform-specific paths
local function getLogDirectory()
    local platform = love.system.getOS()
    if platform == "OS X" then
        -- On macOS, use Application Support
        local home = os.getenv("HOME")
        return home .. "/Library/Application Support/love/game-template/logs"
    elseif platform == "Windows" then
        -- On Windows, use AppData
        local appdata = os.getenv("APPDATA")
        return appdata .. "/love/game-template/logs"
    elseif platform == "Android" or platform == "iOS" then
        -- On mobile platforms, use the app's save directory
        return "logs"
    else
        -- On Linux and other platforms, use a local logs directory
        return "logs"
    end
end

-- Create log directory if it doesn't exist
local function ensureLogDirectory()
    local logDir = getLogDirectory()
    local platform = love.system.getOS()
    
    if platform == "Android" or platform == "iOS" then
        -- On mobile, use love.filesystem
        local success, err = pcall(function()
            love.filesystem.createDirectory(logDir)
        end)
        if not success then
            print("Failed to create log directory on mobile: " .. tostring(err))
        end
    else
        -- On desktop platforms, use os.execute
        local success = os.execute(string.format("mkdir -p '%s'", logDir))
        if not success then
            print("Failed to create log directory on desktop: " .. logDir)
        end
    end
    return logDir
end

-- Get current timestamp
local function getTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Format log message
local function formatMessage(level, message)
    return string.format("[%s] [%s] %s\n", getTimestamp(), level, message)
end

-- Check if log file needs rotation
local function checkLogRotation(logFile)
    local platform = love.system.getOS()
    
    if platform == "Android" or platform == "iOS" then
        -- On mobile, use love.filesystem
        if love.filesystem.getInfo(logFile) then
            local size = love.filesystem.getInfo(logFile).size
            return size > config.maxLogSize
        end
    else
        -- On desktop platforms, use standard Lua I/O
        local file = io.open(logFile, "r")
        if file then
            local size = file:seek("end")
            file:close()
            return size > config.maxLogSize
        end
    end
    
    return false
end

-- Rotate log files
local function rotateLogFiles(logDir, logFile)
    local platform = love.system.getOS()
    local baseLogFile = logFile
    
    -- Remove oldest log file if it exists
    local oldestLogFile = baseLogFile .. "." .. config.maxLogFiles
    if platform == "Android" or platform == "iOS" then
        if love.filesystem.getInfo(oldestLogFile) then
            love.filesystem.remove(oldestLogFile)
        end
    else
        os.remove(oldestLogFile)
    end
    
    -- Rotate existing log files
    for i = config.maxLogFiles - 1, 1, -1 do
        local oldFile = baseLogFile .. "." .. i
        local newFile = baseLogFile .. "." .. (i + 1)
        
        if platform == "Android" or platform == "iOS" then
            if love.filesystem.getInfo(oldFile) then
                if love.filesystem.getInfo(newFile) then
                    love.filesystem.remove(newFile)
                end
                love.filesystem.rename(oldFile, newFile)
            end
        else
            if os.rename(oldFile, newFile) then
                -- Successfully rotated
            end
        end
    end
    
    -- Rename current log file to .1
    if platform == "Android" or platform == "iOS" then
        if love.filesystem.getInfo(baseLogFile) then
            if love.filesystem.getInfo(baseLogFile .. ".1") then
                love.filesystem.remove(baseLogFile .. ".1")
            end
            love.filesystem.rename(baseLogFile, baseLogFile .. ".1")
        end
    else
        if os.rename(baseLogFile, baseLogFile .. ".1") then
            -- Successfully rotated
        end
    end
end

-- Write buffer to file
local function writeBufferToFile()
    if #messageBuffer == 0 then return end
    
    local logDir = ensureLogDirectory()
    local platform = love.system.getOS()
    local logFile = logDir .. "/game.log"
    
    -- Check if log rotation is needed
    if checkLogRotation(logFile) then
        rotateLogFiles(logDir, logFile)
    end
    
    -- Extract text from message objects
    local messages = {}
    for _, msg in ipairs(messageBuffer) do
        table.insert(messages, msg.text)
    end
    
    local success = false
    if platform == "Android" or platform == "iOS" then
        -- On mobile, use love.filesystem
        success, err = pcall(function()
            local existingContent = ""
            if love.filesystem.getInfo(logFile) then
                existingContent = love.filesystem.read(logFile) or ""
            end
            
            local newContent = existingContent .. table.concat(messages)
            love.filesystem.write(logFile, newContent)
        end)
        if not success then
            print("Failed to write to log file on mobile: " .. tostring(err))
        end
    else
        -- On desktop platforms, use standard Lua I/O
        success, err = pcall(function()
            local file = io.open(logFile, "a")
            if file then
                file:write(table.concat(messages))
                file:close()
            else
                error("Failed to open log file for writing: " .. logFile)
            end
        end)
        if not success then
            print("Failed to write to log file on desktop: " .. tostring(err))
        end
    end
    
    -- Clear the buffer
    messageBuffer = {}
    lastFlushTime = love.timer.getTime()
end

-- Check if we should flush the buffer
local function shouldFlush()
    local currentTime = love.timer.getTime()
    return #messageBuffer >= config.bufferSize or (currentTime - lastFlushTime) >= config.flushCooldown
end

-- Configure logger settings
function Logger.configure(newConfig)
    if newConfig.bufferSize then
        config.bufferSize = newConfig.bufferSize
    end
    if newConfig.flushCooldown then
        config.flushCooldown = newConfig.flushCooldown
    end
    if newConfig.minLevel then
        config.minLevel = newConfig.minLevel
    end
    if newConfig.maxLogSize then
        config.maxLogSize = newConfig.maxLogSize
    end
    if newConfig.maxLogFiles then
        config.maxLogFiles = newConfig.maxLogFiles
    end
end

-- Get log level priority
local function getLevelPriority(level)
    local priorities = {
        [Logger.Levels.DEBUG] = 1,
        [Logger.Levels.INFO] = 2,
        [Logger.Levels.WARNING] = 3,
        [Logger.Levels.ERROR] = 4
    }
    return priorities[level] or 0
end

-- Check if message should be logged based on minimum level
local function shouldLog(level)
    return getLevelPriority(level) >= getLevelPriority(config.minLevel)
end

-- Write to buffer
local function writeToBuffer(message)
    if not shouldLog(message.level) then return end
    
    table.insert(messageBuffer, message)
    
    -- Flush if needed
    if shouldFlush() then
        writeBufferToFile()
    end
end

-- Main logging function
function Logger.log(level, message)
    local formattedMessage = formatMessage(level, message)
    writeToBuffer({text = formattedMessage, level = level})
    
    -- Also print to console if available
    if love.window.isOpen() then
        print(formattedMessage)
    end
end

-- Convenience methods for different log levels
function Logger.debug(message)
    Logger.log(Logger.Levels.DEBUG, message)
end

function Logger.info(message)
    Logger.log(Logger.Levels.INFO, message)
end

function Logger.warning(message)
    Logger.log(Logger.Levels.WARNING, message)
end

function Logger.error(message)
    Logger.log(Logger.Levels.ERROR, message)
end

-- Force flush the buffer (call this when the game is closing)
function Logger.flush()
    writeBufferToFile()
end

return Logger 