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

-- Create a folder in ReplicatedStorage for all game remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameRemotes = Instance.new("Folder")
GameRemotes.Name = "GameRemotes"
GameRemotes.Parent = ReplicatedStorage

-- Create RemoteEvents for each game
local function createRemoteFunction(name)
    local remote = Instance.new("RemoteFunction")
    remote.Name = name
    remote.Parent = GameRemotes
    return remote
end

-- Set up remote functions for each game
local TabooRemotes = Instance.new("Folder")
TabooRemotes.Name = "TabooRemotes"
TabooRemotes.Parent = GameRemotes

local AkinatorRemotes = Instance.new("Folder")
AkinatorRemotes.Name = "AkinatorRemotes"
AkinatorRemotes.Parent = GameRemotes

local BluffingRemotes = Instance.new("Folder")
BluffingRemotes.Name = "BluffingRemotes"
BluffingRemotes.Parent = GameRemotes

-- Create specific remotes for each game
-- Taboo Game Remotes
local TabooStartGame = createRemoteFunction("TabooStartGame")
local TabooAskQuestion = createRemoteFunction("TabooAskQuestion")
TabooStartGame.Parent = TabooRemotes
TabooAskQuestion.Parent = TabooRemotes

-- Akinator Game Remotes
local AkinatorStartGame = createRemoteFunction("AkinatorStartGame")
local AkinatorAnswer = createRemoteFunction("AkinatorAnswer")
AkinatorStartGame.Parent = AkinatorRemotes
AkinatorAnswer.Parent = AkinatorRemotes

-- Bluffing Game Remotes
local BluffingStartGame = createRemoteFunction("BluffingStartGame")
local BluffingMakeMove = createRemoteFunction("BluffingMakeMove")
BluffingStartGame.Parent = BluffingRemotes
BluffingMakeMove.Parent = BluffingRemotes

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