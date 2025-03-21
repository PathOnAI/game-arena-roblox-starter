local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("SERVER: AkinatorGameServer starting initialization")

local API_BASE_URL = "http://ai-space-escape-api.pathon.ai/akinator"

-- Create RemoteEvents for client-server communication
local AkinatorRemotes = Instance.new("Folder")
AkinatorRemotes.Name = "AkinatorRemotes"
AkinatorRemotes.Parent = ReplicatedStorage

local StartGameEvent = Instance.new("RemoteFunction")
StartGameEvent.Name = "AkinatorStartGame"
StartGameEvent.Parent = AkinatorRemotes

local AskQuestionEvent = Instance.new("RemoteFunction")
AskQuestionEvent.Name = "AkinatorAskQuestion"
AskQuestionEvent.Parent = AkinatorRemotes

-- Handle start game requests
local function handleStartGame()
    local success, response = pcall(function()
        local result = HttpService:PostAsync(API_BASE_URL .. "/start", "")
        return HttpService:JSONDecode(result)
    end)

    if success then
        return response
    else
        return {
            error = tostring(response)
        }
    end
end

-- Handle answer requests
local function handleAnswer(answer, sessionId)
    if type(sessionId) ~= "string" or type(answer) ~= "string" then
        return {
            error = "Invalid parameters"
        }
    end
    
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            user_response = answer
        })
        local result = HttpService:PostAsync(
            API_BASE_URL .. "/answer?session_id=" .. sessionId,
            data
        )
        return HttpService:JSONDecode(result)
    end)

    if success then
        return response
    else
        return {
            error = tostring(response)
        }
    end
end

StartGameEvent.OnServerInvoke = handleStartGame
AskQuestionEvent.OnServerInvoke = handleAnswer

print("SERVER: AkinatorGameServer initialization complete")

return true 