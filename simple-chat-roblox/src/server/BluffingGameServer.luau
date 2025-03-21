local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("SERVER: BluffingGameServer starting initialization")

local API_BASE_URL = "http://ai-space-escape-api.pathon.ai/bluffing"

-- Create RemoteEvents for client-server communication
local BluffingRemotes = Instance.new("Folder")
BluffingRemotes.Name = "BluffingRemotes"
BluffingRemotes.Parent = ReplicatedStorage

local StartGameEvent = Instance.new("RemoteFunction")
StartGameEvent.Name = "BluffingStartGame"
StartGameEvent.Parent = BluffingRemotes

local MakeMoveEvent = Instance.new("RemoteFunction")
MakeMoveEvent.Name = "BluffingMakeMove"
MakeMoveEvent.Parent = BluffingRemotes

-- Function to handle HTTP errors
local function handleHttpError(err)
    if typeof(err) == "string" and err:match("Http requests are not enabled") then
        return "HTTP Requests are not enabled. Please enable them in Game Settings -> Security."
    end
    return tostring(err)
end

-- Handle start game requests
local function handleStartGame()
    print("SERVER: Attempting to start new Bluffing game...")
    
    local success, response = pcall(function()
        local result = HttpService:PostAsync(API_BASE_URL .. "/start", "")
        print("SERVER: Raw API response:", result)
        return HttpService:JSONDecode(result)
    end)

    if success then
        print("SERVER: Bluffing game started successfully:", HttpService:JSONEncode(response))
        return response
    else
        print("SERVER: Error starting Bluffing game:", response)
        return {
            error = handleHttpError(response)
        }
    end
end

-- Handle move requests
local function handleMove(move, sessionId)
    print("SERVER: Attempting to make move in Bluffing game. Session:", sessionId, "Move:", move)
    
    -- Validate parameters
    if type(sessionId) ~= "string" then
        return {
            error = "Invalid session ID"
        }
    end
    
    if type(move) ~= "string" then
        return {
            error = "Invalid move format"
        }
    end
    
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            user_move = move
        })
        local result = HttpService:PostAsync(
            API_BASE_URL .. "/move?session_id=" .. sessionId,
            data
        )
        print("SERVER: Raw API response:", result)
        return HttpService:JSONDecode(result)
    end)

    if success then
        print("SERVER: Move processed successfully:", HttpService:JSONEncode(response))
        return response
    else
        print("SERVER: Error processing move:", response)
        return {
            error = handleHttpError(response)
        }
    end
end

-- Connect RemoteFunction handlers
StartGameEvent.OnServerInvoke = handleStartGame
MakeMoveEvent.OnServerInvoke = function(player, move, sessionId)
    return handleMove(move, sessionId)
end

print("SERVER: BluffingGameServer initialization complete")

return true 