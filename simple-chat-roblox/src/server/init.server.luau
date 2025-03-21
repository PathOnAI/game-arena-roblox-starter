local ServerScriptService = game:GetService("ServerScriptService")

-- Before requiring, make sure we're looking in the right place
local server = script.Parent
local NPCChatServer, TabooGameServer

-- Try to find the modules in different possible locations
if server:FindFirstChild("NPCChatServer") then
    NPCChatServer = server.NPCChatServer
    TabooGameServer = server.TabooGameServer
elseif ServerScriptService:FindFirstChild("NPCChatServer") then
    NPCChatServer = ServerScriptService.NPCChatServer
    TabooGameServer = ServerScriptService.TabooGameServer
elseif ServerScriptService:FindFirstChild("Server") and ServerScriptService.Server:FindFirstChild("NPCChatServer") then
    NPCChatServer = ServerScriptService.Server.NPCChatServer
    TabooGameServer = ServerScriptService.Server.TabooGameServer
end

if NPCChatServer then
    -- Successfully found the server module
    print("Found NPCChatServer module at:", NPCChatServer:GetFullName())
    require(NPCChatServer)
else
    warn("Could not find NPCChatServer module! Please check your file structure.")
end

if TabooGameServer then
    -- Successfully found the Taboo server module
    print("Found TabooGameServer module at:", TabooGameServer:GetFullName())
    require(TabooGameServer)
else
    warn("Could not find TabooGameServer module! Please check your file structure.")
    
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