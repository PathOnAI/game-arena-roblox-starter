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

-- Handle ask question requests
local function handleAskQuestion(sessionId, question)
    print("SERVER: Attempting to send question to Bluffing game. Session:", sessionId, "Question:", question)
    
    -- Validate parameters
    if type(sessionId) ~= "string" then
        return {
            error = "Invalid session ID"
        }
    end
    
    if type(question) ~= "string" then
        return {
            error = "Invalid question format"
        }
    end
    
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            user_response = question
        })
        local result = HttpService:PostAsync(
            API_BASE_URL .. "/ask_question?session_id=" .. sessionId,
            data
        )
        print("SERVER: Raw API response:", result)
        return HttpService:JSONDecode(result)
    end)

    if success then
        print("SERVER: Question processed successfully:", HttpService:JSONEncode(response))
        return response
    else
        print("SERVER: Error processing question:", response)
        return {
            error = handleHttpError(response)
        }
    end
end

-- Connect RemoteFunction handlers
StartGameEvent.OnServerInvoke = handleStartGame
-- Fixed parameter order for MakeMoveEvent handler to match TabooGameServer
MakeMoveEvent.OnServerInvoke = function(player, question, sessionId)
    return handleAskQuestion(sessionId, question)
end

print("SERVER: BluffingGameServer initialization complete")

return true