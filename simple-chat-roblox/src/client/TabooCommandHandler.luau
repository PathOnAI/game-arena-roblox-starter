local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local TabooGame = require(script.Parent.TabooGameClient)

print("TabooCommandHandler: Module loaded")

-- Command prefixes
local COMMANDS = {
    START_GAME = "/taboo",
    EXIT_GAME = "/exit"
}

local function handleCommand(message, fromPlayer)
    print("TabooCommandHandler: Handling message:", message, "from player:", fromPlayer and fromPlayer.Name or "Unknown")
    local command = message:lower()
    
    if command == COMMANDS.START_GAME then
        print("TabooCommandHandler: Start game command detected")
        local success, response = TabooGame.startGame()
        print("TabooCommandHandler: Start game result:", success, response)
        return success, response
    elseif command == COMMANDS.EXIT_GAME then
        print("TabooCommandHandler: Exit game command detected")
        if TabooGame.isGameActive() then
            local success, response = TabooGame.resetGame()
            print("TabooCommandHandler: Game exited")
            return true, "Exited game mode. You can now chat normally."
        end
        return false, nil
    end
    
    -- If game is active, treat any non-command message as a question
    if TabooGame.isGameActive() then
        print("TabooCommandHandler: Game is active, treating as question")
        return TabooGame.askQuestion(message)
    end
    
    print("TabooCommandHandler: Message ignored - no active game and not a command")
    return false, nil  -- Not a command and no active game
end

-- Connect to chat events
local function init()
    print("TabooCommandHandler: Initializing...")
    
    -- Get the TextChannel
    local textChannel = TextChatService.TextChannels:WaitForChild("RBXGeneral")
    print("TabooCommandHandler: Found RBXGeneral channel")
    
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
            print("TabooCommandHandler: Message received from", fromPlayer.Name .. ":", messageObject.Text)
            local message = messageObject.Text
            local success, response = handleCommand(message, fromPlayer)
            
            if success and response then
                print("TabooCommandHandler: Displaying response:", response)
                task.wait()  -- Small delay to ensure message appears after player's message
                textChannel:DisplaySystemMessage(response)
            end
        end
    end)
    
    print("TabooCommandHandler: Initialization complete!")
end

-- Initialize the command handler
init()

return true 