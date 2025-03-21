local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

print("CLIENT: NPCChatClient starting initialization")

-- Create or get the ChatEvent RemoteEvent
local function getChatEvent()
	local chatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")

	if not chatEvent then
		chatEvent = Instance.new("RemoteEvent")
		chatEvent.Name = "ChatEvent"
		chatEvent.Parent = ReplicatedStorage
	elseif not chatEvent:IsA("RemoteEvent") then
		chatEvent:Destroy()
		chatEvent = Instance.new("RemoteEvent")
		chatEvent.Name = "ChatEvent"
		chatEvent.Parent = ReplicatedStorage
	end

	return chatEvent
end

local ChatEvent = getChatEvent()
local playerGui = player:WaitForChild("PlayerGui")

-- Add these variables
local INTERACTION_DISTANCE = 10
local isInChat = false

-- Add at the top level
local CHAT_COOLDOWN = 1 -- 1 second cooldown between messages
local lastChatTime = 0

-- Simplified NPC detection
local function findNearestNPC()
    print("CLIENT: Searching for nearest NPC...")
    
    local character = player.Character
    if not character then 
        print("CLIENT: No character found")
        return nil 
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        print("CLIENT: No HumanoidRootPart found")
        return nil 
    end
    
    -- Look for NPCs with a specific tag or in a specific folder
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then 
        print("CLIENT: No NPCs folder found in workspace")
        return nil 
    end
    
    print("CLIENT: Found NPCs folder with", #npcs:GetChildren(), "children")
    
    local nearestNPC = nil
    local shortestDistance = INTERACTION_DISTANCE
    
    for _, npc in ipairs(npcs:GetChildren()) do
        local npcRoot = npc:FindFirstChild("HumanoidRootPart")
        if npcRoot then
            local distance = (humanoidRootPart.Position - npcRoot.Position).Magnitude
            print("CLIENT: Found NPC", npc.Name, "at distance", distance)
            if distance < shortestDistance then
                shortestDistance = distance
                nearestNPC = npc
                print("CLIENT: New nearest NPC:", npc.Name)
            end
        else
            print("CLIENT: NPC", npc.Name, "has no HumanoidRootPart")
        end
    end
    
    return nearestNPC
end

local function openTextChat()
    local StarterGui = game:GetService("StarterGui")
    
    -- Try both methods to ensure chat opens
    pcall(function()
        -- Enable chat UI
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        
        -- Try to focus chat
        StarterGui:SetCore("ChatActive", true)
        
        print("CLIENT: Attempted to open chat window")
    end)
end

local function displayStandardMsg(npcChar, msg)
    -- Check cooldown
    local currentTime = tick()
    if currentTime - lastChatTime < CHAT_COOLDOWN then
        print("CLIENT: Chat message blocked by cooldown")
        return
    end
    lastChatTime = currentTime
    
    print("CLIENT: Attempting to display message")
    if not player then 
        print("CLIENT: No player found for displaying message")
        return 
    end
    
    print("CLIENT: Displaying message from", npcChar.name, ":", msg)
    local formattedChatMsg = "[" .. npcChar.name .. "] " .. msg
    
    -- System message in chat
    local textChannel = TextChatService.TextChannels.RBXGeneral
    textChannel:DisplaySystemMessage(formattedChatMsg)
    
    -- Open chat window
    openTextChat()
end

ChatEvent.OnClientEvent:Connect(function(npcChar, msg)
    print("CLIENT: Received chat event from server")
    print("CLIENT: NPC:", npcChar and npcChar.name or "nil")
    print("CLIENT: Message:", msg or "nil")
    
    displayStandardMsg(npcChar, msg)
    -- Reset chat state after receiving a message
    isInChat = false
    print("CLIENT: Chat state reset")
end)

-- Handle key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then 
        print("CLIENT: Input was processed by game")
        return 
    end
    
    print("CLIENT: Input detected:", input.KeyCode.Name)
    
    if input.KeyCode == Enum.KeyCode.E then
        -- Check cooldown
        local currentTime = tick()
        if currentTime - lastChatTime < CHAT_COOLDOWN then
            print("CLIENT: Chat interaction blocked by cooldown")
            return
        end
        
        print("CLIENT: E key pressed")
        local nearestNPC = findNearestNPC()
        if nearestNPC and not isInChat then
            print("CLIENT: Found nearby NPC and not in chat, attempting to start chat")
            isInChat = true
            lastChatTime = currentTime
            
            -- Open chat window before sending event
            openTextChat()
            -- Trigger chat with the NPC
            ChatEvent:FireServer(nearestNPC)
            print("CLIENT: Fired ChatEvent to server for NPC:", nearestNPC.Name)
        else
            print("CLIENT: No valid NPC found or already in chat")
            print("nearestNPC:", nearestNPC and nearestNPC.Name or "nil")
            print("isInChat:", isInChat)
        end
    end
end)

print("CLIENT: NPCChatClient initialization complete")

return true