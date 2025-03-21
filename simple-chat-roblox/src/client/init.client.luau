-- This script ensures all client scripts are properly loaded
local script = script
local StarterPlayerScripts = script.Parent

-- Print startup message
print("Client initialization starting...")

-- Require NPCChatClient
local function safeRequire(moduleName)
    local success, result = pcall(function()
        local module = StarterPlayerScripts:FindFirstChild(moduleName) or 
                      StarterPlayerScripts.Client:FindFirstChild(moduleName)
        
        if module then
            print("Found module:", module:GetFullName())
            return require(module)
        else
            warn("Could not find module:", moduleName)
            return nil
        end
    end)
    
    if success then
        print("Successfully required:", moduleName)
        return result
    else
        warn("Error requiring", moduleName, ":", result)
        return nil
    end
end

-- Require the main client scripts
safeRequire("NPCChatClient")
safeRequire("TabooGameClient")
safeRequire("GameCommandHandler")

-- Also load the test script if it exists
-- safeRequire("TestChatScript")

print("Client initialization completed!")