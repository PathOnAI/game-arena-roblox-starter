local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

print("SERVER: NPCChatServer script starting")

-- Command prefixes to ignore (all game commands)
local GAME_COMMANDS = {
	"/taboo",
	"/akinator",
	"/bluffing",
	"/exit"
}

-- Variables
local ChatEvent
local loaderNPC

-- Function to check if a message is a game command
local function isGameCommand(message)
	for _, prefix in ipairs(GAME_COMMANDS) do
		if message:lower():sub(1, #prefix) == prefix:lower() then
			print("SERVER: Game command detected:", message)
			return true
		end
	end
	return false
end

-- Process game commands directly
local function processGameCommand(player, message)
    local command = message:lower()
    
    -- Check which game to start
    if command:sub(1, 7) == "/taboo " then
        print("SERVER: Processing Taboo command")
        -- We don't need to do anything here as client will handle it
        return true
    elseif command:sub(1, 10) == "/akinator " then
        print("SERVER: Processing Akinator command")
        -- We don't need to do anything here as client will handle it
        return true
    elseif command:sub(1, 10) == "/bluffing " then
        print("SERVER: Processing Bluffing command")
        -- We don't need to do anything here as client will handle it
        return true
    elseif command == "/taboo" then
        print("SERVER: Starting Taboo game")
        -- We don't need to do anything here as client will handle it
        return true
    elseif command == "/akinator" then
        print("SERVER: Starting Akinator game")
        -- We don't need to do anything here as client will handle it
        return true
    elseif command == "/bluffing" then
        print("SERVER: Starting Bluffing game")
        -- We don't need to do anything here as client will handle it
        return true
    elseif command == "/exit" then
        print("SERVER: Exiting active game")
        -- We don't need to do anything here as client will handle it
        return true
    end
    
    return false
end

-- Create or get the ChatEvent RemoteEvent
local function getChatEvent()
	local chatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")

	if not chatEvent then
		chatEvent = Instance.new("RemoteEvent")
		chatEvent.Name = "ChatEvent"
		chatEvent.Parent = ReplicatedStorage
		print("SERVER: Created new ChatEvent RemoteEvent in ReplicatedStorage")
	elseif not chatEvent:IsA("RemoteEvent") then
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
		ChatEvent:FireClient(player, npc, "Welcome to the game! I'm " .. npc.Name .. ". You can play games with me using these commands:\n/taboo - Play a word guessing game\n/akinator - I'll try to guess what you're thinking\n/bluffing - Play a bluffing game\n/exit - Exit any active game")
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
		
		-- Let game commands pass through without NPC response
		if isGameCommand(message) then
            processGameCommand(player, message)
			return
		end
		
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

-- Function to verify that all game remotes exist
local function verifyGameRemotes()
    -- Check Taboo remotes
    local tabooRemotes = ReplicatedStorage:FindFirstChild("TabooRemotes")
    if not tabooRemotes or
       not tabooRemotes:FindFirstChild("TabooStartGame") or
       not tabooRemotes:FindFirstChild("TabooAskQuestion") then
        warn("SERVER: TabooRemotes are missing or incomplete!")
    else
        print("SERVER: TabooRemotes verified")
    end
    
    -- Check Akinator remotes
    local akinatorRemotes = ReplicatedStorage:FindFirstChild("AkinatorRemotes")
    if not akinatorRemotes or
       not akinatorRemotes:FindFirstChild("AkinatorStartGame") or
       not akinatorRemotes:FindFirstChild("AkinatorAskQuestion") then
        warn("SERVER: AkinatorRemotes are missing or incomplete!")
    else
        print("SERVER: AkinatorRemotes verified")
    end
    
    -- Check Bluffing remotes
    local bluffingRemotes = ReplicatedStorage:FindFirstChild("BluffingRemotes")
    if not bluffingRemotes or
       not bluffingRemotes:FindFirstChild("BluffingStartGame") or
       not bluffingRemotes:FindFirstChild("BluffingMakeMove") then
        warn("SERVER: BluffingRemotes are missing or incomplete!")
    else
        print("SERVER: BluffingRemotes verified")
    end
end

-- INITIALIZATION
ChatEvent = getChatEvent()

-- Verify all game remotes exist
verifyGameRemotes()

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
		ChatEvent:FireClient(player, loaderNPC, "Welcome to the game! I'm " .. loaderNPC.Name .. ". Try these commands:\n/taboo - Play a word guessing game\n/akinator - I'll try to guess what you're thinking\n/bluffing - Play a bluffing game\n/exit - Exit any active game")
	end
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	connectPlayerChatted(player)
end

print("SERVER: NPCChatServer fully initialized")

-- Optional: Uncomment to test the message system on start
-- testMessageSystem()

ChatEvent.OnServerEvent:Connect(function(player, input)
	print("SERVER: Received chat event from player:", player.Name)
	print("SERVER: Input received:", input)
	
	if input == "GAME_WIN" then
		-- Make NPC jump
		if loaderNPC then
			local humanoid = loaderNPC:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Jump = true
				ChatEvent:FireClient(player, {name = loaderNPC.Name}, "Congratulations! You won!")
			end
		end
		return
	elseif input == "GAME_LOSE" then
		-- Make NPC walk backwards
		if loaderNPC then
			local humanoid = loaderNPC:FindFirstChild("Humanoid")
			local hrp = loaderNPC:FindFirstChild("HumanoidRootPart")
			if humanoid and hrp then
				local playerChar = player.Character
				if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
					local direction = (hrp.Position - playerChar.HumanoidRootPart.Position).Unit
					local targetPos = hrp.Position + direction * 15
					humanoid:MoveTo(targetPos)
					ChatEvent:FireClient(player, {name = loaderNPC.Name}, "Oh, you lost! Better luck next time!")
				end
			end
		end
		return
	end
	
	-- Handle regular NPC chat
	if not input then
		print("SERVER: No NPC provided")
		return
	end
	
	if not input:IsA("Model") then
		print("SERVER: NPC is not a Model, it's a", input.ClassName)
		return
	end
	
	print("SERVER: Sending response back to player")
	-- Send a response back to the player
	ChatEvent:FireClient(player, {
		name = input.Name,
	}, "Hello! How can I help you today?")
	print("SERVER: Response sent to player")
end)

return true