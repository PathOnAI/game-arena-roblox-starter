local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

print("SERVER: NPCChatServer script starting")

-- Variables
local ChatEvent
local loaderNPC

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

-- Add proximity prompt to an NPC
local function addProximityPrompt(npc)
	if not npc then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Talk to " .. npc.Name
	prompt.ObjectText = npc.Name
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 7
	prompt.Parent = npc

	prompt.Triggered:Connect(function(player)
		print("SERVER: Proximity prompt triggered by:", player.Name)
		ChatEvent:FireClient(player, npc, "Welcome to the game! I'm " .. npc.Name .. ".")
		prompt.Enabled = false	

	end)
end

-- Function to find the loader NPC in the workspace
local function findLoaderNPC()
	-- Look for specific named NPCs first
	if Workspace:FindFirstChild("Roblox") then
		return Workspace.Roblox
	end

	if Workspace:FindFirstChild("Loader") then
		return Workspace.Loader
	end

	-- Look for any model with a Humanoid that isn't a player
	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
			-- Check if this isn't a player character
			local isPlayerCharacter = false
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character == obj then
					isPlayerCharacter = true
					break
				end
			end

			if not isPlayerCharacter then
				return obj
			end
		end
	end

	return nil
end

-- Handle player chatted event
local function connectPlayerChatted(player)
	player.Chatted:Connect(function(message)
		print("SERVER: Received message from", player.Name, ":", message)
		local npcName = loaderNPC.Name
		local response = "Hello, " .. player.Name .. "! I'm " .. npcName .. ". You said: " .. message

		-- If we found the NPC, make it look at the player
		local humanoid = loaderNPC:FindFirstChild("Humanoid")
		local hrp = loaderNPC:FindFirstChild("HumanoidRootPart")
		local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

		if humanoid and hrp and playerHRP then
			-- Check distance between NPC and player
			local distance = (hrp.Position - playerHRP.Position).Magnitude
			local maxChatDistance = 15 -- Maximum distance in studs for chat to work
			
			if distance <= maxChatDistance then
				-- Make the NPC face the player when talking
				humanoid:MoveTo(hrp.Position) -- Stop any movement
				hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(playerHRP.Position.X, hrp.Position.Y, playerHRP.Position.Z))
				print("SERVER: Sending response to", player.Name, ":", response)
				ChatEvent:FireClient(player, loaderNPC, response)
				print("SERVER: Made NPC face player")
			else
				print("SERVER: Player", player.Name, "is too far from NPC (", distance, "studs). Max distance:", maxChatDistance)
			end
		end
	end)
end

-- Function to send a test message to all players
local function testMessageSystem()
	for _, player in ipairs(Players:GetPlayers()) do
		print("SERVER: Sending test message to", player.Name)
		ChatEvent:FireClient(player, loaderNPC, "System test message - NPC chat system is working")
	end
end

-- INITIALIZATION
ChatEvent = getChatEvent()

-- Find the loader NPC
local maxAttempts = 10
local attempts = 0

repeat
	loaderNPC = findLoaderNPC()
	attempts = attempts + 1
	if not loaderNPC and attempts < maxAttempts then
		task.wait(1) -- Wait a second before trying again
	end
until loaderNPC or attempts >= maxAttempts

if loaderNPC then
	print("SERVER: Found loader NPC:", loaderNPC:GetFullName())
	addProximityPrompt(loaderNPC)
else
	warn("SERVER: Could not find loader NPC in workspace after", maxAttempts, "attempts!")
end

-- Connect player events
Players.PlayerAdded:Connect(function(player)
	print("SERVER: New player joined:", player.Name)
	connectPlayerChatted(player)

	-- If the player joins after the script has already run
	if loaderNPC then
		ChatEvent:FireClient(player, loaderNPC, "Welcome to the game! I'm " .. loaderNPC.Name .. ".")
	end
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	connectPlayerChatted(player)
end

print("SERVER: NPCChatServer fully initialized")

-- Optional: Uncomment to test the message system on start
-- testMessageSystem()

return true