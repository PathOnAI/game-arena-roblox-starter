local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

ChatEvent.OnServerEvent:Connect(function(player, userMessage)
    local response = "Hello, " .. player.Name .. "! You said: " .. userMessage
    ChatEvent:FireClient(player, response)
end)

return true  -- Ensure the script can be required
