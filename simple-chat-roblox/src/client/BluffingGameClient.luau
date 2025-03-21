local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

print("BluffingGameClient: Module loaded")

-- Wait for RemoteFunctions to be created
local BluffingRemotes = ReplicatedStorage:WaitForChild("BluffingRemotes")
local StartGameEvent = BluffingRemotes:WaitForChild("BluffingStartGame")
local MakeMoveEvent = BluffingRemotes:WaitForChild("BluffingMakeMove")

local currentSession = {
    id = nil,
    isGameActive = false,
    round = 0
}

-- Function to start a new Bluffing game
local function startGame()
    print("BluffingGameClient: Attempting to start new game...")
    
    local response = StartGameEvent:InvokeServer()
    print("BluffingGameClient: Received response:", response)
    
    if response.error then
        print("BluffingGameClient: Error starting game:", response.error)
        return false, "Failed to start game. Error: " .. response.error
    end
    
    if response.session_id then
        currentSession.id = response.session_id
        currentSession.isGameActive = true
        currentSession.round = 0
        print("BluffingGameClient: Game started successfully with session ID:", response.session_id)
        return true, "Bluffing game started! I'll make statements and you have to determine if I'm bluffing or telling the truth."
    else
        print("BluffingGameClient: Invalid response from server")
        return false, "Failed to start game: Invalid response from server"
    end
end

-- Function to make a move in the bluffing game
local function makeMove(move)
    print("BluffingGameClient: Attempting to make move:", move)
    print("BluffingGameClient: Current session state:", game:GetService("HttpService"):JSONEncode(currentSession))

    if not currentSession.isGameActive or not currentSession.id then
        print("BluffingGameClient: No active session found")
        return false, "No active game session. Start a new game first!"
    end

    local response = MakeMoveEvent:InvokeServer(move, currentSession.id)
    print("BluffingGameClient: Received response:", response)
    
    if response.error then
        print("BluffingGameClient: Error processing move:", response.error)
        return false, "Failed to process move. Error: " .. response.error
    end
    
    currentSession.round = response.round or (currentSession.round + 1)
    
    if response.game_over then
        print("BluffingGameClient: Game over detected")
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
    
    return true, response.ai_message .. "\n\nRound " .. currentSession.round .. "/5"
end

-- Function to check if game is active
local function isGameActive()
    print("BluffingGameClient: Checking game state:", currentSession.isGameActive)
    return currentSession.isGameActive
end

-- Function to reset game state
local function resetGame()
    print("BluffingGameClient: Resetting game state")
    currentSession.id = nil
    currentSession.isGameActive = false
    currentSession.round = 0
    return true, "Game reset. You can start a new game!"
end

print("BluffingGameClient: Module initialization complete")

-- Export the module
return {
    startGame = startGame,
    makeMove = makeMove,
    isGameActive = isGameActive,
    resetGame = resetGame
}