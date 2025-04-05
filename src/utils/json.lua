-- json.lua
-- A simple JSON encoder and decoder for LÖVE

local json = {}

-- Helper function to escape special characters in strings
local function escapeString(str)
    local escaped = str:gsub("([\"\\])", "\\%1")
    escaped = escaped:gsub("\n", "\\n")
    escaped = escaped:gsub("\r", "\\r")
    escaped = escaped:gsub("\t", "\\t")
    return escaped
end

-- Encode a Lua value to JSON
function json.encode(value)
    local t = type(value)
    
    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return value and "true" or "false"
    elseif t == "number" then
        return tostring(value)
    elseif t == "string" then
        return "\"" .. escapeString(value) .. "\""
    elseif t == "table" then
        -- Check if it's an array (sequential numeric keys)
        local isArray = true
        local maxIndex = 0
        local count = 0
        
        for k, v in pairs(value) do
            if type(k) ~= "number" then
                isArray = false
                break
            end
            if k > maxIndex then
                maxIndex = k
            end
            count = count + 1
        end
        
        -- If it's an array and has no gaps, treat it as an array
        if isArray and count == maxIndex then
            local result = "["
            for i = 1, maxIndex do
                if i > 1 then
                    result = result .. ","
                end
                result = result .. json.encode(value[i])
            end
            return result .. "]"
        else
            -- Treat as an object
            local result = "{"
            local first = true
            for k, v in pairs(value) do
                if not first then
                    result = result .. ","
                end
                first = false
                result = result .. "\"" .. tostring(k) .. "\":" .. json.encode(v)
            end
            return result .. "}"
        end
    else
        error("Unsupported type: " .. t)
    end
end

-- Decode a JSON string to a Lua value
function json.decode(str)
    -- This is a simplified decoder that only handles basic JSON
    -- For a production environment, you might want to use a more robust JSON library
    
    -- Remove whitespace
    str = str:gsub("%s+", "")
    
    -- Handle null
    if str == "null" then
        return nil
    end
    
    -- Handle booleans
    if str == "true" then
        return true
    elseif str == "false" then
        return false
    end
    
    -- Handle numbers
    if str:match("^-?%d+%.?%d*$") then
        return tonumber(str)
    end
    
    -- Handle strings
    if str:match("^\"") then
        local content = str:match("^\"(.-)\"$")
        if not content then
            error("Invalid JSON string")
        end
        -- Unescape special characters
        content = content:gsub("\\n", "\n")
        content = content:gsub("\\r", "\r")
        content = content:gsub("\\t", "\t")
        content = content:gsub("\\(.)", "%1")
        return content
    end
    
    -- Handle arrays
    if str:match("^%[") then
        local content = str:match("^%[(.-)%]$")
        if not content then
            error("Invalid JSON array")
        end
        local result = {}
        local index = 1
        
        -- Simple parsing for array elements
        local pos = 1
        local depth = 0
        local start = 1
        
        while pos <= #content do
            local char = content:sub(pos, pos)
            
            if char == "{" or char == "[" then
                depth = depth + 1
            elseif char == "}" or char == "]" then
                depth = depth - 1
            elseif char == "," and depth == 0 then
                local element = content:sub(start, pos - 1)
                result[index] = json.decode(element)
                index = index + 1
                start = pos + 1
            end
            
            pos = pos + 1
        end
        
        -- Add the last element
        if start <= #content then
            local element = content:sub(start)
            result[index] = json.decode(element)
        end
        
        return result
    end
    
    -- Handle objects
    if str:match("^{") then
        local content = str:match("^{(.-)}$")
        if not content then
            error("Invalid JSON object")
        end
        local result = {}
        
        -- Simple parsing for object key-value pairs
        local pos = 1
        local depth = 0
        local start = 1
        local key = nil
        
        while pos <= #content do
            local char = content:sub(pos, pos)
            
            if char == "{" or char == "[" then
                depth = depth + 1
            elseif char == "}" or char == "]" then
                depth = depth - 1
            elseif char == ":" and depth == 0 and not key then
                key = json.decode(content:sub(start, pos - 1))
                start = pos + 1
            elseif char == "," and depth == 0 then
                local value = content:sub(start, pos - 1)
                result[key] = json.decode(value)
                start = pos + 1
                key = nil
            end
            
            pos = pos + 1
        end
        
        -- Add the last key-value pair
        if start <= #content and key then
            local value = content:sub(start)
            result[key] = json.decode(value)
        end
        
        return result
    end
    
    error("Invalid JSON: " .. str)
end

return json 