-- When this module is required, all we really want is for it to make sure
-- the RemoteEvent exists, but the module itself can't return the RemoteEvent directly
-- since Rojo will sync this as a ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This will run when this module is required
local function setupChatEvent()
    local chatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
    
    -- If the event doesn't exist, create it
    if not chatEvent then
        chatEvent = Instance.new("RemoteEvent")
        chatEvent.Name = "ChatEvent"
        chatEvent.Parent = ReplicatedStorage
        print("ChatEvent.luau: Created RemoteEvent 'ChatEvent' in ReplicatedStorage")
    -- If it exists but isn't a RemoteEvent, replace it
    elseif not chatEvent:IsA("RemoteEvent") then
        warn("ChatEvent.luau: Found 'ChatEvent' in ReplicatedStorage but it's a " .. chatEvent.ClassName .. ", not a RemoteEvent")
        chatEvent:Destroy()
        
        chatEvent = Instance.new("RemoteEvent")
        chatEvent.Name = "ChatEvent"
        chatEvent.Parent = ReplicatedStorage
        print("ChatEvent.luau: Replaced with a proper RemoteEvent")
    end
    
    return true
end

-- Run the setup right away
setupChatEvent()

-- Return true to indicate setup was successful
return true