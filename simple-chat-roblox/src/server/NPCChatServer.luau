local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

print("SERVER: NPCChatServer script starting")

-- Create or get the ChatEvent RemoteEvent
local function getChatEvent()
    local chatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
    
    if not chatEvent then
        -- If it doesn't exist, create it
        chatEvent = Instance.new("RemoteEvent")
        chatEvent.Name = "ChatEvent"
        chatEvent.Parent = ReplicatedStorage
        print("SERVER: Created new ChatEvent RemoteEvent in ReplicatedStorage")
    elseif not chatEvent:IsA("RemoteEvent") then
        -- If it exists but is not a RemoteEvent (e.g., it's a ModuleScript from Rojo), replace it
        print("SERVER: Warning: Found ChatEvent but it's a " .. chatEvent.ClassName .. ", replacing with RemoteEvent")
        chatEvent:Destroy()
        
        chatEvent = Instance.new("RemoteEvent")
        chatEvent.Name = "ChatEvent"
        chatEvent.Parent = ReplicatedStorage
        print("SERVER: Replaced with proper RemoteEvent")
    end
    
    print("SERVER: Using ChatEvent:", chatEvent:GetFullName())
    return chatEvent
end

-- Get the proper ChatEvent RemoteEvent
local ChatEvent = getChatEvent()

-- Function to find the loader NPC in workspace
local function findLoaderNPC()
    -- First check if there's a folder called "npc" with loader inside
    if Workspace:FindFirstChild("npc") and Workspace.npc:FindFirstChild("loader") then
        return Workspace.npc.loader
    end
    
    -- Check for "Loader" (case-sensitive)
    if Workspace:FindFirstChild("Loader") then
        return Workspace.Loader
    end
    
    -- Check for "loader" (lowercase)
    if Workspace:FindFirstChild("loader") then
        return Workspace.loader
    end
    
    -- Finally, search for any model named "loader" recursively
    local loaderModels = {}
    local function searchForLoader(parent)
        for _, child in pairs(parent:GetChildren()) do
            if (child.Name:lower() == "loader" or child.Name == "Loader") and child:IsA("Model") then
                table.insert(loaderModels, child)
            end
            
            if #child:GetChildren() > 0 then
                searchForLoader(child)
            end
        end
    end
    
    searchForLoader(Workspace)
    
    if #loaderModels > 0 then
        return loaderModels[1] -- Return the first loader found
    end
    
    return nil
end

-- Wait for the NPC to appear in the workspace
local loaderNPC = nil
local maxAttempts = 10
local attempts = 0

while not loaderNPC and attempts < maxAttempts do
    loaderNPC = findLoaderNPC()
    if not loaderNPC then
        attempts = attempts + 1
        print("SERVER: Attempt", attempts, "to find Loader NPC")
        task.wait(1) -- Wait a second before trying again
    end
end

if loaderNPC then
    print("SERVER: Found loader NPC:", loaderNPC:GetFullName())
else
    warn("SERVER: Could not find loader NPC in workspace after", maxAttempts, "attempts!")
end

-- Add a test message function to verify the system works
local function testMessageSystem()
    for _, player in ipairs(Players:GetPlayers()) do
        print("SERVER: Sending test message to", player.Name)
        ChatEvent:FireClient(player, "System test message - NPC chat system is working")
    end
end

-- Run the test after a short delay
task.delay(3, testMessageSystem)

-- Add a billboard GUI to the NPC to make it more obvious
local function addNPCLabel()
    if not loaderNPC then return end
    
    -- Look for an existing billboard
    for _, child in pairs(loaderNPC:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name == "NPCLabel" then
            return -- Already has a label
        end
    end
    
    -- Create a new billboard
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NPCLabel"
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Adornee = loaderNPC:FindFirstChild("HumanoidRootPart") or 
                           loaderNPC:FindFirstChild("Head") or
                           loaderNPC:FindFirstChildWhichIsA("BasePart")
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 20
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = "Loader NPC\nPress E to chat"
    nameLabel.Parent = billboardGui
    
    billboardGui.Parent = loaderNPC
    print("SERVER: Added label to NPC")
end

task.spawn(addNPCLabel)

-- Handle chat messages
ChatEvent.OnServerEvent:Connect(function(player, userMessage)
    print("SERVER: Received message from", player.Name, ":", userMessage)
    
    if not loaderNPC then
        loaderNPC = findLoaderNPC() -- Try to find it again
        if loaderNPC then
            print("SERVER: Found loader NPC on retry:", loaderNPC:GetFullName())
        else
            print("SERVER: Still couldn't find loader NPC")
        end
    end
    
    local npcName = loaderNPC and loaderNPC.Name or "Loader"
    local response = "Hello, " .. player.Name .. "! I'm " .. npcName .. ". You said: " .. userMessage
    
    -- If we found the NPC, make it look at the player
    if loaderNPC then
        local humanoid = loaderNPC:FindFirstChild("Humanoid")
        local hrp = loaderNPC:FindFirstChild("HumanoidRootPart")
        local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and hrp and playerHRP then
            -- Make the NPC face the player when talking
            humanoid:MoveTo(hrp.Position) -- Stop any movement
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(playerHRP.Position.X, hrp.Position.Y, playerHRP.Position.Z))
            print("SERVER: Made NPC face player")
        end
    end
    
    print("SERVER: Sending response to", player.Name, ":", response)
    ChatEvent:FireClient(player, response)
end)

-- Listen for new players joining to send them a welcome message
Players.PlayerAdded:Connect(function(player)
    task.wait(5) -- Wait for player to fully load
    print("SERVER: New player joined:", player.Name)
    ChatEvent:FireClient(player, "Welcome to the game! I'm the Loader NPC. Press E near me to chat!")

    -- Handle chat messages
    player.Chatted:Connect(function(message)
        print("SERVER: Received message from", player.Name, ":", userMessage)
        
        if not loaderNPC then
            loaderNPC = findLoaderNPC() -- Try to find it again
            if loaderNPC then
                print("SERVER: Found loader NPC on retry:", loaderNPC:GetFullName())
            else
                print("SERVER: Still couldn't find loader NPC")
            end
        end
        
        local npcName = loaderNPC and loaderNPC.Name or "Loader"
        local response = "Hello, " .. player.Name .. "! I'm " .. npcName .. ". You said: " .. userMessage
        
        -- If we found the NPC, make it look at the player
        if loaderNPC then
            local humanoid = loaderNPC:FindFirstChild("Humanoid")
            local hrp = loaderNPC:FindFirstChild("HumanoidRootPart")
            local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and playerHRP then
                -- Make the NPC face the player when talking
                humanoid:MoveTo(hrp.Position) -- Stop any movement
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(playerHRP.Position.X, hrp.Position.Y, playerHRP.Position.Z))
                print("SERVER: Made NPC face player")
            end
        end
        
        print("SERVER: Sending response to", player.Name, ":", response)
        ChatEvent:FireClient(player, loaderNPC, response)
    end)


end)

print("SERVER: NPCChatServer fully initialized")

-- Let other scripts know this loaded successfully
return true
