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
        print("AkinatorGameClient: Error starting game:", response.error)
        return false, "Failed to start game. Error: " .. response.error
    end
    
    if response.session_id then
        currentSession.id = response.session_id
        currentSession.isGameActive = true
        currentSession.round = 0
        print("AkinatorGameClient: Game started successfully with session ID:", response.session_id)
        return true, "Akinator game started! I will try to guess what you're thinking of. Answer my questions with yes/no."
    else
        print("AkinatorGameClient: Invalid response from server")
        return false, "Failed to start game: Invalid response from server"
    end
end

-- Function to answer a question
local function answerQuestion(answer)
    print("AkinatorGameClient: Attempting to send answer:", answer)
    print("AkinatorGameClient: Current session state:", game:GetService("HttpService"):JSONEncode(currentSession))

    if not currentSession.isGameActive or not currentSession.id then
        print("AkinatorGameClient: No active session found")
        return false, "No active game session. Start a new game first!"
    end

    local response = AskQuestionEvent:InvokeServer(answer, currentSession.id)
    print("AkinatorGameClient: Received response:", response)
    
    if response.error then
        print("AkinatorGameClient: Error processing answer:", response.error)
        return false, "Failed to process answer. Error: " .. response.error
    end
    
    currentSession.round = response.round or (currentSession.round + 1)
    
    if response.game_over then
        print("AkinatorGameClient: Game over detected")
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
    
    return true, response.ai_message .. "\n\nRound " .. currentSession.round
end

-- Function to check if game is active
local function isGameActive()
    print("AkinatorGameClient: Checking game state:", currentSession.isGameActive)
    return currentSession.isGameActive
end

-- Function to reset game state
local function resetGame()
    print("AkinatorGameClient: Resetting game state")
    currentSession.id = nil
    currentSession.isGameActive = false
    currentSession.round = 0
    return true, "Game reset. You can start a new game!"
end

print("AkinatorGameClient: Module initialization complete")

-- Export the module
return {
    startGame = startGame,
    answerQuestion = answerQuestion,
    isGameActive = isGameActive,
    resetGame = resetGame
}