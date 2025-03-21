local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- Load game modules
local TabooGame = require(script.Parent.TabooGameClient)
-- local AkinatorGame = require(script.Parent.AkinatorGameClient)
-- local BluffingGame = require(script.Parent.BluffingGameClient)

print("GameCommandHandler: Module loaded")

-- Command prefixes
local COMMANDS = {
    TABOO = "/taboo",
    AKINATOR = "/akinator",
    BLUFFING = "/bluffing",
    EXIT = "/exit"
}

-- Track which game is currently active
local activeGame = nil

local function handleCommand(message, fromPlayer)
    print("GameCommandHandler: Handling message:", message, "from player:", fromPlayer and fromPlayer.Name or "Unknown")
    local command = message:lower()
    
    -- Handle exit command first
    if command == COMMANDS.EXIT then
        if activeGame and activeGame.isGameActive() then
            local success, response = activeGame.resetGame()
            activeGame = nil
            return true, "Exited game mode. You can now chat normally."
        end
        return false, nil
    end
    
    -- Start new game if requested
    if command == COMMANDS.TABOO then
        if activeGame then
            return false, "Please exit the current game first using /exit"
        end
        activeGame = TabooGame
        return activeGame.startGame()
    end
    
    -- If a game is active, pass the message to it
    if activeGame and activeGame.isGameActive() then
        if activeGame == TabooGame then
            return activeGame.askQuestion(message)
        end
    end
    
    return false, nil
end

-- Connect to chat events
local function init()
    print("GameCommandHandler: Initializing...")
    
    -- Get the TextChannel
    local textChannel = TextChatService.TextChannels:WaitForChild("RBXGeneral")
    print("GameCommandHandler: Found RBXGeneral channel")
    
    -- Connect to the TextChannel's MessageReceived event
    textChannel.MessageReceived:Connect(function(messageObject)
        local fromPlayer = nil
        
        -- Safely get the player who sent the message
        pcall(function()
            if messageObject.TextSource then
                local userId = messageObject.TextSource.UserId
                fromPlayer = Players:GetPlayerByUserId(userId)
            end
        end)
        
        -- Only process if we could identify the player and it's the local player
        if fromPlayer and fromPlayer == Players.LocalPlayer then
            print("GameCommandHandler: Message received from", fromPlayer.Name .. ":", messageObject.Text)
            local message = messageObject.Text
            local success, response = handleCommand(message, fromPlayer)
            
            if success and response then
                print("GameCommandHandler: Displaying response:", response)
                task.wait()  -- Small delay to ensure message appears after player's message
                textChannel:DisplaySystemMessage(response)
            end
        end
    end)
    
    print("GameCommandHandler: Initialization complete!")
end

-- Initialize the command handler
init()

return true 