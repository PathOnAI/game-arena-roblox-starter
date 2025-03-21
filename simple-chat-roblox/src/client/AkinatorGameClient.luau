local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

print("AkinatorGameClient: Module loaded")

-- Wait for RemoteFunctions to be created
local AkinatorRemotes = ReplicatedStorage:WaitForChild("AkinatorRemotes")
local StartGameEvent = AkinatorRemotes:WaitForChild("AkinatorStartGame")
local AskQuestionEvent = AkinatorRemotes:WaitForChild("AkinatorAskQuestion")

local currentSession = {
    id = nil,
    isGameActive = false,
    round = 0
}

-- Function to start a new Akinator game
local function startGame()
    print("AkinatorGameClient: Attempting to start new game...")
    
    local response = StartGameEvent:InvokeServer()
    print("AkinatorGameClient: Received response:", response)
    
    if response.error then
        return false, "Failed to start game. Error: " .. response.error
    end
    
    if response.session_id then
        currentSession.id = response.session_id
        currentSession.isGameActive = true
        currentSession.round = 0
        return true, "Akinator game started! I will try to guess what you're thinking of. Answer my questions with yes/no."
    end
    
    return false, "Failed to start game: Invalid response from server"
end

-- Function to answer a question
local function answerQuestion(answer)
    if not currentSession.isGameActive or not currentSession.id then
        return false, "No active game session. Start a new game first!"
    end

    local response = AskQuestionEvent:InvokeServer(answer, currentSession.id)
    
    if response.error then
        return false, "Failed to process answer. Error: " .. response.error
    end
    
    currentSession.round = response.round or (currentSession.round + 1)
    
    if response.game_over then
        currentSession.isGameActive = false
        
        -- Get the ChatEvent for NPC reaction
        local ChatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
        if ChatEvent then
            if response.game_status == "PLAYER_WIN" then
                ChatEvent:FireServer("GAME_WIN")
            elseif response.game_status == "PLAYER_LOSE" then
                ChatEvent:FireServer("GAME_LOSE")
            end
        end
        
        return true, response.ai_message .. "\n\nGame Over!"
    end
    
    return true, response.ai_message
end

local function isGameActive()
    return currentSession.isGameActive
end

local function resetGame()
    currentSession.id = nil
    currentSession.isGameActive = false
    currentSession.round = 0
    return true, "Game reset. You can start a new game!"
end

return {
    startGame = startGame,
    answerQuestion = answerQuestion,
    isGameActive = isGameActive,
    resetGame = resetGame
} 