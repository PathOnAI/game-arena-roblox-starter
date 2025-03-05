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

local function displayStandardMsg(npcChar, msg)
	local player = Players.LocalPlayer
	if not player then return end


	local formattedChatMsg = "[" .. npcChar.name .. "]" .. msg

	-- System message in chat
	local textChannel = TextChatService.TextChannels.RBXGeneral
	textChannel:DisplaySystemMessage(formattedChatMsg)

	-- Display bubble chat with filtered message
	--TextChatService:DisplayBubble(npcChar.Head, msg)
end

ChatEvent.OnClientEvent:Connect(displayStandardMsg)



return true