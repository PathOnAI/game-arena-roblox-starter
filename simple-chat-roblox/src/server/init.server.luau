local ServerScriptService = game:GetService("ServerScriptService")

-- Before requiring, make sure we're looking in the right place
local server = script.Parent
local NPCChatServer

-- Try to find the module in different possible locations
if server:FindFirstChild("NPCChatServer") then
    NPCChatServer = server.NPCChatServer
elseif ServerScriptService:FindFirstChild("NPCChatServer") then
    NPCChatServer = ServerScriptService.NPCChatServer
elseif ServerScriptService:FindFirstChild("Server") and ServerScriptService.Server:FindFirstChild("NPCChatServer") then
    NPCChatServer = ServerScriptService.Server.NPCChatServer
end

if NPCChatServer then
    -- Successfully found the server module
    print("Found NPCChatServer module at:", NPCChatServer:GetFullName())
    require(NPCChatServer)
else
    warn("Could not find NPCChatServer module! Please check your file structure.")
    
    -- Output the current structure to help debug
    print("Current ServerScriptService structure:")
    for _, child in pairs(ServerScriptService:GetChildren()) do
        print("- " .. child.Name .. " (" .. child.ClassName .. ")")
        
        if child:IsA("Folder") or child:IsA("Model") then
            for _, subchild in pairs(child:GetChildren()) do
                print("  - " .. subchild.Name .. " (" .. subchild.ClassName .. ")")
            end
        end
    end
end