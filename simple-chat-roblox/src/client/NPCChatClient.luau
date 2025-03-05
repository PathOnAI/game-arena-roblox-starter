local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
print("NPC Chat Client loading for", player.Name)

-- Create or get the ChatEvent RemoteEvent
local function getChatEvent()
    local chatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
    
    if not chatEvent then
        -- If it doesn't exist, create it
        chatEvent = Instance.new("RemoteEvent")
        chatEvent.Name = "ChatEvent"
        chatEvent.Parent = ReplicatedStorage
        print("CLIENT: Created new ChatEvent RemoteEvent in ReplicatedStorage")
    elseif not chatEvent:IsA("RemoteEvent") then
        -- If it exists but is not a RemoteEvent, replace it
        print("CLIENT: Warning: Found ChatEvent but it's a " .. chatEvent.ClassName .. ", replacing with RemoteEvent")
        chatEvent:Destroy()
        
        chatEvent = Instance.new("RemoteEvent")
        chatEvent.Name = "ChatEvent"
        chatEvent.Parent = ReplicatedStorage
        print("CLIENT: Replaced with proper RemoteEvent")
    end
    
    print("CLIENT: Using ChatEvent:", chatEvent:GetFullName())
    return chatEvent
end

-- Get the proper ChatEvent RemoteEvent
local ChatEvent = getChatEvent()

local playerGui = player:WaitForChild("PlayerGui")

-- Create a key detection label to debug keyboard input
local function createKeyDetectionLabel()
    -- Check if it already exists
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
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return label
end

local keyLabel = createKeyDetectionLabel()

-- Create a simple chat GUI
local function createChatGui()
    -- Check if it already exists
    if playerGui:FindFirstChild("NPCChatGui") then
        return playerGui.NPCChatGui
    end
    
    local chatGui = Instance.new("ScreenGui")
    chatGui.Name = "NPCChatGui"
    chatGui.ResetOnSpawn = false
    chatGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.7, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = chatGui
    
    local messageFrame = Instance.new("ScrollingFrame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(1, -20, 0.8, -20)
    messageFrame.Position = UDim2.new(0, 10, 0, 10)
    messageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    messageFrame.BackgroundTransparency = 0.5
    messageFrame.BorderSizePixel = 0
    messageFrame.ScrollBarThickness = 6
    messageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    messageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    messageFrame.Parent = mainFrame
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -20, 0.2, -10)
    inputFrame.Position = UDim2.new(0, 10, 0.8, 0)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = mainFrame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(0.8, -10, 1, 0)
    inputBox.Position = UDim2.new(0, 0, 0, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    inputBox.BackgroundTransparency = 0.3
    inputBox.BorderSizePixel = 0
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 18
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextWrapped = true
    inputBox.ClearTextOnFocus = false
    inputBox.PlaceholderText = "Type your message here..."
    inputBox.Parent = inputFrame
    
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0.2, 0, 1, 0)
    sendButton.Position = UDim2.new(0.8, 0, 0, 0)
    sendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    sendButton.BorderSizePixel = 0
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 18
    sendButton.Text = "Send"
    sendButton.Parent = inputFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Text = "X"
    closeButton.Parent = mainFrame
    
    -- Make UI elements rounded
    local function makeRounded(guiObject, radius)
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, radius or 8)
        uiCorner.Parent = guiObject
    end
    
    makeRounded(mainFrame, 10)
    makeRounded(messageFrame, 8)
    makeRounded(inputBox, 8)
    makeRounded(sendButton, 8)
    makeRounded(closeButton, 15)
    
    -- Helper function to add message
    local function addMessage(sender, message, color)
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "Message"
        messageLabel.Size = UDim2.new(1, -16, 0, 0)
        messageLabel.AutomaticSize = Enum.AutomaticSize.Y
        messageLabel.BackgroundTransparency = 1
        messageLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        messageLabel.TextSize = 16
        messageLabel.Font = Enum.Font.SourceSans
        messageLabel.TextWrapped = true
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.Text = sender .. ": " .. message
        messageLabel.Parent = messageFrame
        
        -- Add padding between messages
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingBottom = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = messageLabel
        
        -- Scroll to bottom
        messageFrame.CanvasPosition = Vector2.new(0, messageFrame.CanvasSize.Y.Offset)
    end
    
    -- Send message when button clicked or Enter pressed
    local function sendMessage()
        local message = inputBox.Text
        if message and message ~= "" then
            addMessage("You", message, Color3.fromRGB(100, 200, 255))
            print("CLIENT: Sending message to server:", message)
            ChatEvent:FireServer(message)
            inputBox.Text = ""
        end
    end
    
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
    
    print("CLIENT: Chat GUI created")
    return chatGui
end

-- Create the chat GUI
local chatGui = createChatGui()

-- Add a proximity indicator to show when you're close enough to interact
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
    print("CLIENT: Received message from server:", response)
    
    local mainFrame = chatGui.MainFrame
    local messageFrame = mainFrame.MessageFrame
    
    -- Make GUI visible when receiving a message
    mainFrame.Visible = true
    
    -- Add the response message
    local function addMessage(sender, message, color)
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "Message"
        messageLabel.Size = UDim2.new(1, -16, 0, 0)
        messageLabel.AutomaticSize = Enum.AutomaticSize.Y
        messageLabel.BackgroundTransparency = 1
        messageLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        messageLabel.TextSize = 16
        messageLabel.Font = Enum.Font.SourceSans
        messageLabel.TextWrapped = true
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.Text = sender .. ": " .. message
        messageLabel.Parent = messageFrame
        
        -- Add padding between messages
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingBottom = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = messageLabel
        
        -- Scroll to bottom
        messageFrame.CanvasPosition = Vector2.new(0, messageFrame.CanvasSize.Y.Offset)
    end
    
    addMessage("Loader NPC", response, Color3.fromRGB(120, 255, 120))
end)

-- Function to check if player is near the NPC
local function checkNearNPC()
    local character = player.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Replace the findLoaderNPC function in NPCChatClient.luau with this improved version
    local function findLoaderNPC()
        local workspace = game:GetService("Workspace")
        
        -- In Studio, the NPC is named "Loader"
        -- But when playing, it becomes "Roblox"
        if workspace:FindFirstChild("Roblox") then
            print("CLIENT: Found NPC as Roblox model")
            return workspace.Roblox
        end
        
        -- Fallback to original name
        if workspace:FindFirstChild("Loader") then
            print("CLIENT: Found NPC as Loader model")
            return workspace.Loader
        end
        
        -- Last fallback - find any character model that isn't the player
        local playerChar = game.Players.LocalPlayer.Character
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= playerChar and obj:FindFirstChild("Humanoid") then
                print("CLIENT: Found fallback NPC:", obj.Name)
                return obj
            end
        end
        
        print("CLIENT: Could not find NPC model")
        return nil
    end
    
    local loaderNPC = findLoaderNPC()
    if not loaderNPC then 
        print("CLIENT: Could not find Loader NPC")
        return false 
    end
    
    local npcPart = loaderNPC:FindFirstChild("HumanoidRootPart")
    if not npcPart then 
        -- Try to find any BasePart to use as a reference
        for _, part in pairs(loaderNPC:GetDescendants()) do
            if part:IsA("BasePart") then
                npcPart = part
                break
            end
        end
        
        if not npcPart then
            print("CLIENT: Loader NPC has no HumanoidRootPart or BaseParts")
            return false
        end
    end
    
    -- Check distance
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
    
    -- E key handler - only if not processed by something else
    if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        print("CLIENT: E key pressed directly")
        local isNear, distance, loaderNPC = checkNearNPC()
        
        if isNear and loaderNPC then
            print("CLIENT: Interacting with NPC at distance:", distance)
            -- Show chat GUI and send initial message
            chatGui.MainFrame.Visible = true
            chatGui.MainFrame.InputFrame.InputBox:CaptureFocus()
            
            -- Send initial greeting
            print("CLIENT: Sending initial Hello message")
            ChatEvent:FireServer("Hello")
        else
            print("CLIENT: Not near NPC, distance:", distance or "unknown")
        end
    end
    
    -- T key handler for chat toggle
    if input.KeyCode == Enum.KeyCode.T and not gameProcessed then
        print("CLIENT: T key pressed to toggle chat")
        local mainFrame = chatGui.MainFrame
        mainFrame.Visible = not mainFrame.Visible
        
        if mainFrame.Visible and mainFrame.InputFrame and mainFrame.InputFrame.InputBox then
            mainFrame.InputFrame.InputBox:CaptureFocus()
        end
    end
    
    -- P key for testing
    if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
        print("CLIENT: P key pressed for testing")
        ChatEvent:FireServer("Test message from P key")
    end
end)

-- Add interactions using ContextActionService for better mobile support
ContextActionService:BindAction(
    "NPCChat_Interact", 
    function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            print("CLIENT: E key pressed through ContextActionService")
            
            local isNear, distance, loaderNPC = checkNearNPC()
            
            if isNear and loaderNPC then
                print("CLIENT: Interacting with NPC at distance:", distance)
                -- Show chat GUI and send initial message
                chatGui.MainFrame.Visible = true
                chatGui.MainFrame.InputFrame.InputBox:CaptureFocus()
                
                -- Send initial greeting
                print("CLIENT: Sending initial Hello message through CAS")
                ChatEvent:FireServer("Hello")
                
                return Enum.ContextActionResult.Sink  -- Consume the input
            else
                print("CLIENT: Not near NPC, distance:", distance or "unknown")
                return Enum.ContextActionResult.Pass  -- Allow the input to continue
            end
        end
        
        return Enum.ContextActionResult.Pass
    end,
    false,  -- Don't create touch button
    Enum.KeyCode.E  -- Bind to E key
)

-- Simple direct test to confirm communication works
-- Wait a moment to ensure everything is loaded
task.wait(2)
print("CLIENT: Testing direct server communication...")
ChatEvent:FireServer("Test message from client")
print("CLIENT: NPC Chat Client initialized")

-- Return true to avoid "did not return exactly one value" error
return true