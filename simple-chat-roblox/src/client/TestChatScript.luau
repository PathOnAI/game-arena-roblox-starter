local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
print("TEST: TestChatScript loading for", player.Name)

-- Create or get the ChatEvent RemoteEvent
local ChatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
if not ChatEvent then
    ChatEvent = Instance.new("RemoteEvent")
    ChatEvent.Name = "ChatEvent"
    ChatEvent.Parent = ReplicatedStorage
    print("TEST: Created ChatEvent")
else
    print("TEST: Found existing ChatEvent:", ChatEvent:GetFullName())
end

-- Create a simple test GUI
local function createTestGui()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Check if it already exists
    if playerGui:FindFirstChild("TestChatGui") then
        print("TEST: TestChatGui already exists")
        return playerGui.TestChatGui
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "TestChatGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0.85, -100, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = gui
    
    -- Add rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "NPC Chat Tester"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 0.7
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 100)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = frame
    
    -- Add rounded corners to title
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Test button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 40)
    button.Text = "Test Chat"
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Parent = frame
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- E key button
    local eButton = Instance.new("TextButton")
    eButton.Size = UDim2.new(0.48, 0, 0, 30)
    eButton.Position = UDim2.new(0, 10, 0, 80)
    eButton.Text = "Press E"
    eButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    eButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    eButton.BorderSizePixel = 0
    eButton.Font = Enum.Font.SourceSansBold
    eButton.TextSize = 14
    eButton.Parent = frame
    
    -- Add rounded corners to E button
    local eButtonCorner = Instance.new("UICorner")
    eButtonCorner.CornerRadius = UDim.new(0, 6)
    eButtonCorner.Parent = eButton
    
    -- P key button
    local pButton = Instance.new("TextButton")
    pButton.Size = UDim2.new(0.48, 0, 0, 30)
    pButton.Position = UDim2.new(0.52, 0, 0, 80)
    pButton.Text = "Press P"
    pButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    pButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    pButton.BorderSizePixel = 0
    pButton.Font = Enum.Font.SourceSansBold
    pButton.TextSize = 14
    pButton.Parent = frame
    
    -- Add rounded corners to P button
    local pButtonCorner = Instance.new("UICorner")
    pButtonCorner.CornerRadius = UDim.new(0, 6)
    pButtonCorner.Parent = pButton
    
    -- Response label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 120)
    label.Text = "Press a button to test"
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextWrapped = true
    label.Parent = frame
    
    -- Button click events
    button.MouseButton1Click:Connect(function()
        print("TEST: Sending test message from button")
        label.Text = "Sent: Test message"
        ChatEvent:FireServer("Test message from button")
    end)
    
    eButton.MouseButton1Click:Connect(function()
        -- Simulate pressing E key
        print("TEST: Simulating E key press")
        label.Text = "Simulated E key press"
        
        -- Try to find the InputBegan connection in the NPCChatClient
        local success = pcall(function()
            -- This is a "fake" keypress event that mimics pressing E
            UserInputService.InputBegan:Fire({
                KeyCode = Enum.KeyCode.E,
                UserInputType = Enum.UserInputType.Keyboard,
                IsModifierKeyDown = function() return false end
            })
        end)
        
        if not success then
            -- If simulation fails, try sending a direct message
            ChatEvent:FireServer("Hello (from E button)")
        end
    end)
    
    pButton.MouseButton1Click:Connect(function()
        print("TEST: Sending test message from P button")
        label.Text = "Sent: Test from P button"
        ChatEvent:FireServer("Test message from P button")
    end)
    
    return gui, label
end

local gui, responseLabel = createTestGui()

-- Listen for test message responses
ChatEvent.OnClientEvent:Connect(function(message)
    print("TEST: Received response:", message)
    if responseLabel then
        responseLabel.Text = "Response: " .. (message:sub(1, 20) .. (message:len() > 20 and "..." or ""))
    end
end)

-- Add P key for testing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        print("TEST: P key pressed, sending test")
        ChatEvent:FireServer("Test message from P key")
        if responseLabel then
            responseLabel.Text = "Sent: Test from P key"
        end
    end
end)

-- Send an automatic test after 3 seconds
task.delay(3, function()
    print("TEST: Sending automatic test")
    ChatEvent:FireServer("Automatic test message")
end)

print("TEST: Chat test script loaded")

-- Return true to fix the "Module code did not return exactly one value" error
return true