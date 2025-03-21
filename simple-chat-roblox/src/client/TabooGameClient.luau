local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

print("TabooGameClient: Module loaded")

-- Wait for RemoteFunctions to be created
local TabooRemotes = ReplicatedStorage:WaitForChild("TabooRemotes")
local StartGameEvent = TabooRemotes:WaitForChild("TabooStartGame")
local AskQuestionEvent = TabooRemotes:WaitForChild("TabooAskQuestion")

local currentSession = {
    id = nil,
    isGameActive = false,
    round = 0
}

-- Function to start a new Taboo game
local function startGame()
    print("TabooGameClient: Attempting to start new game...")
    
    local response = StartGameEvent:InvokeServer()
    print("TabooGameClient: Received response:", response)
    
    if response.error then
        print("TabooGameClient: Error starting game:", response.error)
        return false, "Failed to start game. Error: " .. response.error
    end
    
    if response.session_id then
        currentSession.id = response.session_id
        currentSession.isGameActive = true
        currentSession.round = 0
        print("TabooGameClient: Game started successfully with session ID:", response.session_id)
        return true, "Taboo game started! Ask me questions to guess the word. You have 5 questions total."
    else
        print("TabooGameClient: Invalid response from server")
        return false, "Failed to start game: Invalid response from server"
    end
end

-- Function to ask a question in the game
local function askQuestion(question)
    print("TabooGameClient: Attempting to ask question:", question)
    print("TabooGameClient: Current session state:", game:GetService("HttpService"):JSONEncode(currentSession))

    if not currentSession.isGameActive or not currentSession.id then
        print("TabooGameClient: No active session found")
        return false, "No active game session. Start a new game first!"
    end

    -- Pass question first, then session ID
    local response = AskQuestionEvent:InvokeServer(question, currentSession.id)
    print("TabooGameClient: Received response:", response)
    
    if response.error then
        print("TabooGameClient: Error processing question:", response.error)
        return false, "Failed to process question. Error: " .. response.error
    end
    
    currentSession.round = response.round or (currentSession.round + 1)
    
    if response.game_over then
        print("TabooGameClient: Game over detected")
        currentSession.isGameActive = false
        return true, response.ai_message .. "\n\nGame Over! " .. (response.game_status or "")
    end
    
    return true, response.ai_message .. "\n\nRound " .. currentSession.round .. "/5"
end

-- Function to check if game is active
local function isGameActive()
    print("TabooGameClient: Checking game state:", currentSession.isGameActive)
    return currentSession.isGameActive
end

-- Function to reset game state
local function resetGame()
    print("TabooGameClient: Resetting game state")
    currentSession.id = nil
    currentSession.isGameActive = false
    currentSession.round = 0
    return true, "Game reset. You can start a new game!"
end

print("TabooGameClient: Module initialization complete")

-- Export the module
return {
    startGame = startGame,
    askQuestion = askQuestion,
    isGameActive = isGameActive,
    resetGame = resetGame
} 