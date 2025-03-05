local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")


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

-- Function to format message with character name
local function formatChatMessage(npcChar, msg)
	return string.format("<font color=\"rgb(%d,%d,%d)\">%s</font>: %s",
		chatConfig.nameColor.R * 255,
		chatConfig.nameColor.G * 255,
		chatConfig.nameColor.B * 255,
		npcChar.Name,
		msg
	)
end

local function displayStandardMsg(npcChar, msg)
		local player = Players.LocalPlayer
		if not player then return end

		local formattedChatMsg = formatChatMessage(npcChar, msg)

		-- System message in chat
		local textChannel = TextChatService.TextChannels.RBXGeneral
		textChannel:DisplaySystemMessage(formattedChatMsg)

		-- Display bubble chat with filtered message
		TextChatService:DisplayBubble(npcChar.Head, msg)
end

ChatEvent.OnClientEvent:Connect(displayStandardMsg)


-- Create a key detection label
local function createKeyDetectionLabel()
    if playerGui:FindFirstChild("KeyDetector") then
        return playerGui.KeyDetector.Frame.Label
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyDetector"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = gui
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.Text = "Press any key to test"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return label
end

local keyLabel = createKeyDetectionLabel()

-- Create an improved chat GUI
local function createChatGui()
    if playerGui:FindFirstChild("NPCChatGui") then
        return playerGui.NPCChatGui
    end
    
    local chatGui = Instance.new("ScreenGui")
    chatGui.Name = "NPCChatGui"
    chatGui.ResetOnSpawn = false
    chatGui.Parent = playerGui
    
    -- Main frame with better styling
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -225, 0.6, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = chatGui
    
    -- Add rounded corners to main frame
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = mainFrame
    
    -- Add a header with NPC name
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    headerFrame.BackgroundTransparency = 0.1
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    -- Round just the top corners of header
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = headerFrame
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "HeaderTitle"
    headerTitle.Size = UDim2.new(1, -50, 1, 0)
    headerTitle.Position = UDim2.new(0, 15, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerTitle.TextSize = 18
    headerTitle.Font = Enum.Font.GothamMedium
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Text = "Chat with NPC"
    headerTitle.Parent = headerFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.Parent = headerFrame
    
    -- Rounded close button
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Message frame with better styling
    local messageFrame = Instance.new("ScrollingFrame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(1, -20, 1, -110)
    messageFrame.Position = UDim2.new(0, 10, 0, 50)
    messageFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    messageFrame.BackgroundTransparency = 0.5
    messageFrame.BorderSizePixel = 0
    messageFrame.ScrollBarThickness = 6
    messageFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    messageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    messageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    messageFrame.Parent = mainFrame
    
    -- Rounded message frame
    local messageCorner = Instance.new("UICorner")
    messageCorner.CornerRadius = UDim.new(0, 8)
    messageCorner.Parent = messageFrame
    
    -- Message layout for better spacing
    local messageLayout = Instance.new("UIListLayout")
    messageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    messageLayout.Padding = UDim.new(0, 10)
    messageLayout.Parent = messageFrame
    
    local messagePadding = Instance.new("UIPadding")
    messagePadding.PaddingTop = UDim.new(0, 10)
    messagePadding.PaddingBottom = UDim.new(0, 10)
    messagePadding.PaddingLeft = UDim.new(0, 10)
    messagePadding.PaddingRight = UDim.new(0, 10)
    messagePadding.Parent = messageFrame
    
    -- Input frame with better styling
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -20, 0, 50)
    inputFrame.Position = UDim2.new(0, 10, 1, -60)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    inputFrame.BackgroundTransparency = 0.5
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = mainFrame
    
    -- Rounded input frame
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    -- Input text box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -100, 1, -10)
    inputBox.Position = UDim2.new(0, 10, 0, 5)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    inputBox.BackgroundTransparency = 0.2
    inputBox.BorderSizePixel = 0
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextWrapped = true
    inputBox.ClearTextOnFocus = false
    inputBox.PlaceholderText = "Type your message here..."
    inputBox.Parent = inputFrame
    
    -- Rounded input box
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = inputBox
    
    -- Send button
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0, 80, 1, -10)
    sendButton.Position = UDim2.new(1, -90, 0, 5)
    sendButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    sendButton.BorderSizePixel = 0
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 16
    sendButton.Font = Enum.Font.GothamBold
    sendButton.Text = "Send"
    sendButton.Parent = inputFrame
    
    -- Rounded send button
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 6)
    sendCorner.Parent = sendButton
    
    -- Send message function
    local function sendMessage()
        local message = inputBox.Text
        if message and message ~= "" then
            -- Create player message directly
            local playerContainer = Instance.new("Frame")
            playerContainer.Name = "PlayerContainer"
            playerContainer.Size = UDim2.new(1, 0, 0, 0)
            playerContainer.AutomaticSize = Enum.AutomaticSize.Y
            playerContainer.BackgroundTransparency = 1
            playerContainer.LayoutOrder = #messageFrame:GetChildren()
            playerContainer.Parent = messageFrame
            
            local playerLabel = Instance.new("TextLabel")
            playerLabel.Name = "PlayerMessage"
            playerLabel.Size = UDim2.new(1, 0, 0, 0)
            playerLabel.AutomaticSize = Enum.AutomaticSize.Y
            playerLabel.BackgroundColor3 = Color3.fromRGB(50, 80, 140)
            playerLabel.BackgroundTransparency = 0.8
            playerLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
            playerLabel.TextSize = 16
            playerLabel.Font = Enum.Font.SourceSans
            playerLabel.TextWrapped = true
            playerLabel.TextXAlignment = Enum.TextXAlignment.Left
            playerLabel.Text = "You: " .. message
            playerLabel.Parent = playerContainer
            
            local playerPadding = Instance.new("UIPadding")
            playerPadding.PaddingTop = UDim.new(0, 8)
            playerPadding.PaddingBottom = UDim.new(0, 8)
            playerPadding.PaddingLeft = UDim.new(0, 8)
            playerPadding.PaddingRight = UDim.new(0, 8)
            playerPadding.Parent = playerLabel
            
            local playerCorner = Instance.new("UICorner")
            playerCorner.CornerRadius = UDim.new(0, 8)
            playerCorner.Parent = playerLabel
            
            -- Send message to server
            ChatEvent:FireServer(message)
            inputBox.Text = ""
            
            -- Scroll to bottom
            messageFrame.CanvasPosition = Vector2.new(0, messageFrame.CanvasSize.Y.Offset + 1000)
        end
    end
    
    -- Hook up button click and Enter key
    sendButton.MouseButton1Click:Connect(sendMessage)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    return chatGui
end

local chatGui = createChatGui()

-- Add a proximity indicator
local function createProximityIndicator()
    local proximityGui = Instance.new("ScreenGui")
    proximityGui.Name = "ProximityGui"
    proximityGui.ResetOnSpawn = false
    proximityGui.Parent = playerGui
    
    local indicator = Instance.new("TextLabel")
    indicator.Size = UDim2.new(0, 300, 0, 50)
    indicator.Position = UDim2.new(0.5, -150, 0.2, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    indicator.BackgroundTransparency = 0.5
    indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
    indicator.TextSize = 20
    indicator.Font = Enum.Font.SourceSansBold
    indicator.Text = "Press E to talk"
    indicator.Visible = false
    indicator.Parent = proximityGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = indicator
    
    return proximityGui, indicator
end

local proximityGui, proximityIndicator = createProximityIndicator()

-- Listen for messages from the server
ChatEvent.OnClientEvent:Connect(function(response)
    local mainFrame = chatGui.MainFrame
    local messageFrame = mainFrame.MessageFrame
    
    -- Make GUI visible when receiving a message
    mainFrame.Visible = true
    
    -- Create message container for better organization
    local messageContainer = Instance.new("Frame")
    messageContainer.Name = "MessageContainer"
    messageContainer.Size = UDim2.new(1, 0, 0, 0) -- Auto-height
    messageContainer.AutomaticSize = Enum.AutomaticSize.Y
    messageContainer.BackgroundTransparency = 1
    messageContainer.LayoutOrder = #messageFrame:GetChildren() -- Ensure proper ordering
    messageContainer.Parent = messageFrame
    
    -- Create the actual message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    messageLabel.BackgroundTransparency = 0.8
    messageLabel.TextColor3 = Color3.fromRGB(220, 255, 220)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Text = "Loader NPC: " .. response
    messageLabel.Parent = messageContainer
    
    -- Add padding to message
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = messageLabel
    
    -- Add rounded corners to message
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = messageLabel
    
    -- Scroll to bottom
    messageFrame.CanvasPosition = Vector2.new(0, messageFrame.CanvasSize.Y.Offset + 1000)
end)

-- Function to check if player is near the NPC
local function findLoaderNPC()
    local workspace = game:GetService("Workspace")
    
    if workspace:FindFirstChild("Roblox") then
        return workspace.Roblox
    end
    
    if workspace:FindFirstChild("Loader") then
        return workspace.Loader
    end
    
    local playerChar = game.Players.LocalPlayer.Character
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= playerChar and obj:FindFirstChild("Humanoid") then
            return obj
        end
    end
    
    return nil
end

local function checkNearNPC()
    local character = player.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local loaderNPC = findLoaderNPC()
    if not loaderNPC then return false end
    
    local npcPart = loaderNPC:FindFirstChild("HumanoidRootPart")
    if not npcPart then 
        for _, part in pairs(loaderNPC:GetDescendants()) do
            if part:IsA("BasePart") then
                npcPart = part
                break
            end
        end
        
        if not npcPart then return false end
    end
    
    local distance = (npcPart.Position - hrp.Position).Magnitude
    local isNear = distance < 10
    
    return isNear, distance, loaderNPC
end

-- Update the proximity indicator
local function updateProximityIndicator()
    local isNear, distance, npc = checkNearNPC()
    proximityIndicator.Visible = isNear
    
    if isNear and npc then
        proximityIndicator.Text = "Press E to talk with " .. npc.Name .. " (" .. math.floor(distance) .. "m)"
    end
end

-- Check proximity every 0.5 seconds
task.spawn(function()
    while true do
        updateProximityIndicator()
        task.wait(0.5)
    end
end)

-- Direct keyboard handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Update key detection display
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        keyLabel.Text = "Key pressed: " .. input.KeyCode.Name
    end
    
    -- E key handler
    if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        local isNear, distance, loaderNPC = checkNearNPC()
        
        if isNear and loaderNPC then
            chatGui.MainFrame.Visible = true
            chatGui.MainFrame.InputFrame.InputBox:CaptureFocus()
            ChatEvent:FireServer("Hello")
        end
    end
    
    -- T key handler for chat toggle
    if input.KeyCode == Enum.KeyCode.T and not gameProcessed then
        local mainFrame = chatGui.MainFrame
        mainFrame.Visible = not mainFrame.Visible
        
        if mainFrame.Visible and mainFrame.InputFrame and mainFrame.InputFrame.InputBox then
            mainFrame.InputFrame.InputBox:CaptureFocus()
        end
    end
    
    -- P key for testing
    if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
        ChatEvent:FireServer("Test message from P key")
    end
end)

-- Add interactions using ContextActionService for better mobile support
ContextActionService:BindAction(
    "NPCChat_Interact", 
    function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            local isNear, distance, loaderNPC = checkNearNPC()
            
            if isNear and loaderNPC then
                chatGui.MainFrame.Visible = true
                chatGui.MainFrame.InputFrame.InputBox:CaptureFocus()
                ChatEvent:FireServer("Hello")
                return Enum.ContextActionResult.Sink
            else
                return Enum.ContextActionResult.Pass
            end
        end
        
        return Enum.ContextActionResult.Pass
    end,
    false,
    Enum.KeyCode.E
)

-- Initial test message
task.wait(2)
ChatEvent:FireServer("Test message from client")

return true