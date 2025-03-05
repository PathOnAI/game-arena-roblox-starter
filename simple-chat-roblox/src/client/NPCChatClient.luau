local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

ChatEvent.OnClientEvent:Connect(function(response)
    print("NPC: " .. response)
end)

ChatEvent:FireServer("Hi NPC!")
