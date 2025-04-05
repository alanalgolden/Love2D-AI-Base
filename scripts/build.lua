-- build.lua
-- Script to build the game into a .love file

local function buildLoveFile()
    print("Building .love file...")
    
    -- Get the current directory name as the game name
    local gameName = "game-template"
    local loveFile = gameName .. ".love"
    
    -- Create a temporary directory for the build
    os.execute("mkdir -p ../build")
    
    -- Copy all necessary files to the build directory from parent directory
    os.execute("cp -r ../main.lua ../src ../assets ../build/")
    
    -- Remove any .git directories from the build
    os.execute("find ../build -name '.git' -type d -exec rm -rf {} +")
    
    -- Remove any .DS_Store files from the build
    os.execute("find ../build -name '.DS_Store' -type f -delete")
    
    -- Create the .love file
    os.execute("cd ../build && zip -9 -r ../" .. loveFile .. " .")
    
    -- Clean up the build directory
    os.execute("rm -rf ../build")
    
    print("Build complete! Created " .. loveFile)
    print("You can run the game with: love " .. loveFile)
end

-- Run the build function
buildLoveFile() 