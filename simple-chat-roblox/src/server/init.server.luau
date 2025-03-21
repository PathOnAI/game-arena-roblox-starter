local ServerScriptService = game:GetService("ServerScriptService")

print("SERVER: Starting initialization...")

-- Function to safely require a module
local function safeRequire(name)
    local success, result = pcall(function()
        local module = ServerScriptService.Server:FindFirstChild(name)
        if module then
            print("SERVER: Found module:", module:GetFullName())
            return require(module)
        else
            warn("SERVER: Could not find module:", name)
            return nil
        end
    end)
    
    if success then
        print("SERVER: Successfully loaded", name)
        return result
    else
        warn("SERVER: Error loading", name, "-", result)
        return nil
    end
end

-- Initialize all game servers
local NPCChatServer = safeRequire("NPCChatServer")
local TabooGameServer = safeRequire("TabooGameServer")
local AkinatorGameServer = safeRequire("AkinatorGameServer")
local BluffingGameServer = safeRequire("BluffingGameServer")

-- Check if the game servers' RemoteFunctions already exist in ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Function to check if a remote function already exists
local function checkRemoteExists(parentFolder, remoteName)
    if not parentFolder then return false end
    return parentFolder:FindFirstChild(remoteName) ~= nil
end

-- Only create game remotes if they don't already exist from the game servers

-- Check for existing Taboo remotes
local existingTabooRemotes = ReplicatedStorage:FindFirstChild("TabooRemotes")
if not existingTabooRemotes then
    print("SERVER: Creating TabooRemotes as they don't exist")
    local TabooRemotes = Instance.new("Folder")
    TabooRemotes.Name = "TabooRemotes"
    TabooRemotes.Parent = ReplicatedStorage
    
    local TabooStartGame = Instance.new("RemoteFunction")
    TabooStartGame.Name = "TabooStartGame"
    TabooStartGame.Parent = TabooRemotes
    
    local TabooAskQuestion = Instance.new("RemoteFunction")
    TabooAskQuestion.Name = "TabooAskQuestion"
    TabooAskQuestion.Parent = TabooRemotes
    
    print("SERVER: TabooRemotes created successfully")
else
    print("SERVER: TabooRemotes already exist in ReplicatedStorage")
end

-- Check for existing Akinator remotes
local existingAkinatorRemotes = ReplicatedStorage:FindFirstChild("AkinatorRemotes")
if not existingAkinatorRemotes then
    print("SERVER: Creating AkinatorRemotes as they don't exist")
    local AkinatorRemotes = Instance.new("Folder")
    AkinatorRemotes.Name = "AkinatorRemotes"
    AkinatorRemotes.Parent = ReplicatedStorage
    
    local AkinatorStartGame = Instance.new("RemoteFunction")
    AkinatorStartGame.Name = "AkinatorStartGame"
    AkinatorStartGame.Parent = AkinatorRemotes
    
    -- Make sure the name matches what's used in AkinatorGameServer.luau
    local AkinatorAskQuestion = Instance.new("RemoteFunction")
    AkinatorAskQuestion.Name = "AkinatorAskQuestion"
    AkinatorAskQuestion.Parent = AkinatorRemotes
    
    print("SERVER: AkinatorRemotes created successfully")
else
    print("SERVER: AkinatorRemotes already exist in ReplicatedStorage")
end

-- Check for existing Bluffing remotes
local existingBluffingRemotes = ReplicatedStorage:FindFirstChild("BluffingRemotes")
if not existingBluffingRemotes then
    print("SERVER: Creating BluffingRemotes as they don't exist")
    local BluffingRemotes = Instance.new("Folder")
    BluffingRemotes.Name = "BluffingRemotes"
    BluffingRemotes.Parent = ReplicatedStorage
    
    local BluffingStartGame = Instance.new("RemoteFunction")
    BluffingStartGame.Name = "BluffingStartGame"
    BluffingStartGame.Parent = BluffingRemotes
    
    local BluffingMakeMove = Instance.new("RemoteFunction")
    BluffingMakeMove.Name = "BluffingMakeMove"
    BluffingMakeMove.Parent = BluffingRemotes
    
    print("SERVER: BluffingRemotes created successfully")
else
    print("SERVER: BluffingRemotes already exist in ReplicatedStorage")
end

-- Check if all required servers loaded successfully
if not NPCChatServer then
    warn("SERVER: Failed to load NPCChatServer!")
end

if not TabooGameServer then
    warn("SERVER: Failed to load TabooGameServer!")
end

if not AkinatorGameServer then
    warn("SERVER: Failed to load AkinatorGameServer!")
end

if not BluffingGameServer then
    warn("SERVER: Failed to load BluffingGameServer!")
end

print("SERVER: Initialization complete!")