local Logger = {}

-- Log levels
Logger.Levels = {
    DEBUG = "DEBUG",
    INFO = "INFO",
    WARNING = "WARNING",
    ERROR = "ERROR"
}

-- Buffer configuration
local BUFFER_SIZE = 100  -- Maximum number of messages to buffer
local FLUSH_COOLDOWN = 1.0  -- Seconds between flushes
local lastFlushTime = 0
local messageBuffer = {}

-- Platform-specific paths
local function getLogDirectory()
    local platform = love.system.getOS()
    if platform == "OS X" then
        -- On macOS, use Application Support
        local home = os.getenv("HOME")
        return home .. "/Library/Application Support/lovegames/game-template/logs"
    elseif platform == "Windows" then
        -- On Windows, use AppData
        local appdata = os.getenv("APPDATA")
        return appdata .. "/lovegames/game-template/logs"
    else
        -- On Linux and other platforms, use a local logs directory
        return "logs"
    end
end

-- Create log directory if it doesn't exist
local function ensureLogDirectory()
    local logDir = getLogDirectory()
    -- Use os.execute to create the directory and its parents
    os.execute(string.format("mkdir -p '%s'", logDir))
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

-- Write buffer to file
local function flushBuffer()
    if #messageBuffer == 0 then return end
    
    local logDir = ensureLogDirectory()
    local logFile = logDir .. "/game.log"
    
    -- Try to write to file
    local success, err = pcall(function()
        local file = io.open(logFile, "a")
        if file then
            for _, message in ipairs(messageBuffer) do
                file:write(message)
            end
            file:close()
        end
    end)
    
    if not success then
        -- If file writing fails, try to print to console
        print("Failed to write to log file: " .. tostring(err))
        for _, message in ipairs(messageBuffer) do
            print(message)
        end
    end
    
    -- Clear the buffer
    messageBuffer = {}
    lastFlushTime = love.timer.getTime()
end

-- Check if we should flush the buffer
local function shouldFlush()
    local currentTime = love.timer.getTime()
    return #messageBuffer >= BUFFER_SIZE or (currentTime - lastFlushTime) >= FLUSH_COOLDOWN
end

-- Write to buffer
local function writeToBuffer(message)
    table.insert(messageBuffer, message)
    
    -- Flush if needed
    if shouldFlush() then
        flushBuffer()
    end
end

-- Main logging function
function Logger.log(level, message)
    local formattedMessage = formatMessage(level, message)
    writeToBuffer(formattedMessage)
    
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
    flushBuffer()
end

return Logger 