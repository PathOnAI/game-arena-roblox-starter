local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("SERVER: TabooGameServer starting initialization")

local API_BASE_URL = "http://ai-space-escape-api.pathon.ai/taboo"

-- Create RemoteEvents for client-server communication
local TabooRemotes = Instance.new("Folder")
TabooRemotes.Name = "TabooRemotes"
TabooRemotes.Parent = ReplicatedStorage

local StartGameEvent = Instance.new("RemoteFunction")
StartGameEvent.Name = "TabooStartGame"
StartGameEvent.Parent = TabooRemotes

local AskQuestionEvent = Instance.new("RemoteFunction")
AskQuestionEvent.Name = "TabooAskQuestion"
AskQuestionEvent.Parent = TabooRemotes

-- Function to handle HTTP errors
local function handleHttpError(err)
    if typeof(err) == "string" and err:match("Http requests are not enabled") then
        return "HTTP Requests are not enabled. Please enable them in Game Settings -> Security."
    end
    return tostring(err)
end

-- Handle start game requests
local function handleStartGame()
    print("SERVER: Attempting to start new Taboo game...")
    
    local success, response = pcall(function()
        local result = HttpService:PostAsync(API_BASE_URL .. "/start", "")
        print("SERVER: Raw API response:", result)
        return HttpService:JSONDecode(result)
    end)

    if success then
        print("SERVER: Taboo game started successfully:", HttpService:JSONEncode(response))
        return response
    else
        print("SERVER: Error starting Taboo game:", response)
        return {
            error = handleHttpError(response)
        }
    end
end

-- Handle ask question requests
local function handleAskQuestion(sessionId, question)
    print("SERVER: Attempting to send question to Taboo game. Session:", sessionId, "Question:", question)
    
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
-- Swap parameters for AskQuestionEvent handler
AskQuestionEvent.OnServerInvoke = function(player, question, sessionId)
    return handleAskQuestion(sessionId, question)
end

print("SERVER: TabooGameServer initialization complete")

return true 