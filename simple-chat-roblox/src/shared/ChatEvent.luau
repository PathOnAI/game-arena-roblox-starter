local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChatEvent = Instance.new("RemoteEvent")
ChatEvent.Name = "ChatEvent"
ChatEvent.Parent = ReplicatedStorage

return ChatEvent
