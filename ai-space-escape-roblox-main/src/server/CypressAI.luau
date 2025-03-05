-- add some test loggig here
local module = {}

-- REFERENCES
local signals = require(game.ReplicatedStorage.Shared.signals)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
-- local gameState = require(game.ServerScriptService:WaitForChild("Server").gameState)

-- SETTINGS
local delayAfterAIResponseBeforeInputIsAllowed = 0
local delayBeforeShowingGameStatus = 4
local AppUrl = "http://18.207.190.246:8500/"  -- Your actual server URL
local BotName = "Cypress AI"
local LogSize = 20
local AnswerEverynMessages = 1
local NonAnsweredMessages = AnswerEverynMessages - 1
local Log = {}

-- DIFFICULTY SETTINGS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DifficultySettings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DifficultySettings"))
local chosenDifficulty

local gameUrls = {
	taboo = {
		start = "taboo/start",
		ask_question = "taboo/ask_question",
		regenerate = "taboo/regenerate",
		assistant = "taboo/assistant",
		hint = "taboo/hint"
	},
	akinator = {
		start = "akinator/start",
		ask_question = "akinator/ask_question",
		regenerate = "akinator/regenerate",
		hint = "akinator/hint"
	},
	bluffing = {
		start = "bluffing/start",
		ask_question = "bluffing/ask_question",
		regenerate = "bluffing/regenerate",
		assistant = "bluffing/assistant",
		hint = "bluffing/hint"
	},
	npc = {
		start = "npc/start",
		chat = "npc/chat"
	},
	scenario = {
		start = "scenario/start",
		conclude = "scenario/conclude"
	}
}

-- VAR
local playerSessions = {}

-- Clear the Log
local function ClearTable(tbl, AmmountToKeep)
	local keepCount = math.min(AmmountToKeep, #tbl)

	for i = 1, #tbl - keepCount do
		table.remove(tbl, 1)
	end
end

-- Fetch Roblox user metadata from the server (Yuxuan)
local function fetchUserMetadata(player)
    local url = AppUrl .. "/user?roblox_id=" .. player.UserId

    print("Fetching user metadata for Roblox ID:", player.UserId)

	-- For GET requests
	local success, response = pcall(function()
		return HttpService:GetAsync(
			url,
			false -- Do not compress
		)
	end)

    if success then
        print("GET request successful.")
        local data = HttpService:JSONDecode(response)

        if data then
            print("Fetched metadata:", data)
            return data -- Return the fetched metadata
        else
            warn("No metadata found, returning nil.")
            return nil
        end
    else
        warn("GET request failed.")
        warn(response)
        return nil
    end
end

local function updateStarsUI(player)
	local metadata = fetchUserMetadata(player)
	if metadata and metadata.stars then
		local stars = metadata.stars
		signals.re:fire("update_stars_counter_ui", player, stars)
	end
end

local function requestFilterText(player, message)
	signals.re:fire("set_typing_indicator", player, true, "Filtering...")

	-- Filter the message
	message = signals.bf:fire("filter_text", message, player.UserId, player.UserId)

	signals.re:fire("set_typing_indicator", player, false)

	return message
end

-- Display a message to the player
local function DisplayMsgToPlr(player, messageType, message, isExternallyGenerated)

	if not message then print("Oops, AI message is empty") return end
	local msgArgs = {}

	if isExternallyGenerated then
		-- Filter the message
		message = requestFilterText(player, message)

		if messageType == "cypress" then
			-- Allow for regeneration
			msgArgs.allowRegen = true
		end
	end

	-- Display message to player
	signals.re:fire("display_msg", player, messageType, message, msgArgs)

	-- Add AI response to the log
	table.insert(Log, {nickname = BotName, content = message})

	return
end


local function finishGameSession(player, didPlayerWin, OptionalEndingScenarioFlag, OptionalCustomizedText)
	-- signals.re:fire("set_input_enabled", player, false)
    -- signals.re:fire("set_assist_visible", player, false)

	wait(delayBeforeShowingGameStatus)
	if playerSessions[player.UserId] then
		signals.be:fire("set_session_id", player, playerSessions[player.UserId].sessionId)
		print(string.format("[INFO] set_session_id fired: Player=%s, UserId=%d, SessionId=%s", player.Name, player.UserId, playerSessions[player.UserId].sessionId))
	else
		signals.be:fire("set_session_id", player, "00000000")
		print(string.format("[INFO] set_session_id fired: Player=%s, UserId=%d, null SessionId (game not started) =%s", player.Name, player.UserId, "00000000"))
	end
	

	signals.be:fire("set_room_id", player, 1)
	print(string.format("[INFO] set_room_id fired: Player=%s, UserId=%d, RoomId=%s", player.Name, player.UserId, 1))
	playerSessions[player.UserId] = nil



	if OptionalEndingScenarioFlag then
		print("SCENARIO_GAME_ENDED")
		signals.be:fire("set_game_state", player, "scenario_end")
	else
		if didPlayerWin then
			print("PLAYER_WIN")
			signals.be:fire("set_game_state", player, "minigame_win", OptionalCustomizedText)
		else
			warn("PLAYER_LOSE")
			signals.be:fire("set_game_state", player, "minigame_lose", OptionalCustomizedText)
		end
	end

	updateStarsUI(player)
end

-- Define a dictionary mapping animation names to their IDs
local animationIdsR6 = {
    Big_wave = "rbxassetid://82249934538920",  
    Clap_Hands = "rbxassetid://100769033095645",
    Scared = "rbxassetid://70686122660029",
    Confused = "rbxassetid://98175769499050",
    Raise_hand = "rbxassetid://74046459045791",
    Give_direction = "rbxassetid://126201495365963",
    Hug = "rbxassetid://138359104743019",
    Thinking = "rbxassetid://82594897082113"
}

local animationIdsR15 = {
    Big_wave = "rbxassetid://77110755339191",
    Clap_Hands = "rbxassetid://109577776088986",
    Scared = "rbxassetid://128300907956513",
    Confused = "rbxassetid://90656530455583",
    Raise_hand = "rbxassetid://97473517948158",
    Give_direction = "rbxassetid://135862066699291",
    Hug = "rbxassetid://130294660649672",
    Thinking = "rbxassetid://121801336674539"
}

-- Function to play animations on the NPC
local function PlayAnimation(animationName)
	print("Playing animation:", animationName)

    -- Access the NPC instance from the gameState module
    local npc = workspace.npc
    if npc and npc:FindFirstChildOfClass("Humanoid") then

		-- Find the right animation
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
		local animId = nil
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			animId = animationIdsR15[animationName]
			print("R15")
		elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
			animId = animationIdsR6[animationName]
			print("R6")
		end

		print("animationID: ",animId)
    --     if animId then
    --         local anim = Instance.new("Animation")
    --         anim.AnimationId = animId
    --         local track = humanoid:LoadAnimation(anim)
	-- 		print("playing animation")
    --         track:Play()
    --     else
    --         print("Animation ID not found for animation:", animationName)
    --     end
    -- else
    --     print("NPC or Humanoid not found.")
    -- end
	
	if animationName == "Big_wave" then
		local anim = humanoid:FindFirstChild("Big_wave")
		if anim then
			local track = humanoid:LoadAnimation(anim)
			track:Play()
		else
			warn("Big_wave animation not found")
		end
	elseif animationName == "Nod" then
		local anim = humanoid:FindFirstChild("Nod")
		if anim then
			local track = humanoid:LoadAnimation(anim)
			track:Play()
		else
			warn("Nod animation not found")
		end
	elseif animationName == "Shake_head" then
		local anim = humanoid:FindFirstChild("Shake_head")
		if anim then
			local track = humanoid:LoadAnimation(anim)
			track:Play()
		else
			warn("Shake_head animation not found")
		end
	else
		print("Animation not found: " .. animationName)
	end

	end
end

local function PlayAnimationSet(animationTable)
	if not animationTable then print("No animations provided in set") return end
	for _, animationName in ipairs(animationTable) do
		PlayAnimation(animationName)
		wait(1)
	end
end

-- Interpret and apply stat changes in the given table.
-- The table should have the following format:
-- {
-- lives = 10,
-- chips = -20,
-- coolant = 5,
-- oxygen = -10,
-- power = 5,
-- }
-- These values are delta/changes (not actual values). You don't need to include all stats (e.g. stats with 0 change.)
local function interpretStatChanges(player, statChangeTable)
	if not statChangeTable then
		print("Stat change table is nil.")
		return
	end

	-- for statChange in ipairs(statChangeTable) do
	local statName = statChangeTable.type
	local statValue = statChangeTable.value

	if statName and statValue and statName then
		wait(4)
		signals.bf:fire("change_currency", player, statName, statValue)
		if statValue > 0 then
			DisplayMsgToPlr(player, "data", "Ship status changed: +" .. statValue .. " " .. statName, false)
		else
			DisplayMsgToPlr(player, "data", "Ship status changed: " .. statValue .. " " .. statName, false)
		end
	elseif statName and statValue then
		DisplayMsgToPlr(player, "data", "Everything appears normal... though it’s hard to tell for how long.", false)
	else
		print("A stat change entry is missing 'type' or 'value'.")
	end
end

-- Send post request
local function sendPostRequest(url, requestBody)
	print("Sending POST request to the server. URL:", url)
	-- For POST requests
	local success, response = pcall(function()
		return HttpService:PostAsync(
			url,
			requestBody,
			Enum.HttpContentType.ApplicationJson,  -- ContentType
			false  -- compress
		)
	end)

	if not success then warn("POST request failed.") warn(response) return nil end

	if not response then warn("Response is nil.") return nil end

	local data = HttpService:JSONDecode(response)

	if not data then warn("Response data is nil or couldn't be decoded.") return nil end

	print(data)

	return data
end

-- Send Elapsed Time
local function sendElapsedTime(player)
    local sessionId = signals.bf:fire("get_session_id", player)
    local roomId = 1
    local elapsedTime = signals.bf:fire("get_elapsed_time", player)

    -- Validate the data
    if not sessionId then
        warn("Session ID is missing for player:", player.UserId)
        return
    end

    if not roomId then
        warn("Room ID is missing for the current game state.")
        return
    end

    if not elapsedTime then
        warn("Elapsed time is missing for player:", player.UserId)
        return
    end
	
    -- Construct the URL with query parameters
	local url = AppUrl .. "/end" .. "?session_id=" .. sessionId .. "&total_game_time=" .. elapsedTime .. "&escape_ai_room_id=" .. roomId

	-- output not currently needed
	local data = sendPostRequest(url, "")

    -- Log the request
    print("[INFO] Sending request via GET to URL:", url)

    -- Send the GET request
    local success, response = pcall(function()
        return HttpService:PostAsync(url, false) -- false for no compression
    end)

    if success then
        print("[INFO] Successfully sent elapsed time.")
    else
        warn("[ERROR] Failed to send elapsed time. Error:", response)
    end

end

-- Determine level based on stars (Yuxuan)
local function getLevelBasedOnStars(player)
    -- Fetch metadata for the player
    local metadata = fetchUserMetadata(player)
    if metadata and metadata.stars then
        local stars = metadata.stars
        local level = 1 -- Default level

        -- Determine level based on star count
        if stars >= 10 then
            level = 3
        elseif stars >= 4 then
            level = 2
        end

        print("User Info:")
        print("User ID:", player.UserId)
        print("Username:", player.Name)
        print("Stars:", stars)
        print("Assigned Level:", level)

        return level
    else
        warn("Failed to fetch metadata or no stars available. Defaulting to level 1.")
        return 1
    end
end

-- Check if game is over, and a status has been reached
-- Return: Whether the game should continue (i.e. player input should be re-enabled after their current response is done processing)
local function handleGameStatus(player, session, responseData)
	local OptionalCustomizedText
	
	if session.endReason then
		print("ending reason: " .. session.endReason)
		if session.currentGame == "taboo" and session.endReason == "LLM_WRONG_PREDICTION" then
			OptionalCustomizedText = "The AI made a confident attempt but failed to detect the intended password! Security systems deactivated. Unlocking the door..."
		elseif session.currentGame == "taboo" and session.endReason == "LLM_CORRECT_PREDICTION" then
			OptionalCustomizedText = "Oh no! The AI guard has seen through your intentions. The door will remain locked."
		elseif session.currentGame == "bluffing" and session.endReason == "LLM_SUCCEEDED" then
			-- handle player lose special case: LLM claims the statement is false early on
			OptionalCustomizedText = "You failed to convince the AI guard. The door will remain locked."
		end
	end
	
	-- Check if game is over, and a status has been reached
	if session.gameStatus == 'PLAYER_WIN' then
		finishGameSession(player, true, false, OptionalCustomizedText)
		return false
	elseif session.gameStatus == 'PLAYER_LOSE' then
		finishGameSession(player, false, false, OptionalCustomizedText)
		return false
	elseif session.gameStatus == 'MAX_ROUNDS_REACHED' then
		finishGameSession(player, false)
		return false
	elseif session.gameStatus == 'TERMINATED' then
		finishGameSession(player, false, true)
		return false
	else
		-- If Akinator AI is making a guess, but it is wrong
		if session.currentGame == "akinator" and ( string.find(responseData.ai_message:lower(), "guess") or not string.find(responseData.ai_message:lower(), "question") ) then
			signals.re:fire("display_msg", player, "player", "No, that's not right")
			signals.bf:fire("send_msg_plr", player, "No")
		end
		return true
	end
end

-- Handle player messages
-- Return: Whether player input should be re-enabled after their current response is done processing
local function handlePlayerInput(player, message, optionalChoiceIndex)
	message = "test"
	chosenDifficulty = DifficultySettings.getDifficulty(player)
	-- Add Player's response to the log
	table.insert(Log, {nickname = player.Name, content = message})

	local session = playerSessions[player.UserId]
	if not session or session.gameOver then
		DisplayMsgToPlr(player, "cypress", "Oops, I lost track of our conversation. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end

	-- Continue the game
	-- Send player's response to the server
	local url = nil
	local requestBody = nil
	if session.currentGame == "npc" then
		url = AppUrl .. "/"..gameUrls[session.currentGame].chat
		requestBody = HttpService:JSONEncode({
			session_id = session.sessionId,
			user_input = message
		})	
	elseif session.currentGame == "scenario" then
		url = AppUrl .. "/"..gameUrls[session.currentGame].conclude
		requestBody = HttpService:JSONEncode({
			session_id = session.sessionId,
			choice_index = optionalChoiceIndex,
			user_input = message
		})
	else 
		-- If there is a password
		if message and session.password then
			-- Check if password is in player's input
			if string.find(message:lower(), session.password:lower()) then
				signals.re:fire("display_msg", player, "alarm", "You are not allowed to type the password. Please continue without typing the password.")
				wait(2)
				return true
			end
		end
		
		url = AppUrl .. "/"..gameUrls[session.currentGame].ask_question.."?session_id=" .. session.sessionId
		requestBody = HttpService:JSONEncode({
			user_response = message
		})
	end

	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)

	if chosenDifficulty == "Very_Hard" then
		signals.re:fire("set_typing_indicator", player, true, "Deep thinking...")
	else
		signals.re:fire("set_typing_indicator", player, true, "Thinking...")
	end
	local data = sendPostRequest(url, requestBody)
	signals.re:fire("set_typing_indicator", player, false)
	
	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end

	session.gameOver = data.game_over
	session.gameStatus = data.game_status
	session.endReason = data.end_reason

	-- Display AI message to the player
	if session.currentGame == "npc" then
		DisplayMsgToPlr(player, "cypress", data.npc_response, true)
	else
		DisplayMsgToPlr(player, "cypress", data.ai_message, true)
	end
	PlayAnimationSet(data["animations"])
	interpretStatChanges(player, data.stat_changes)
	wait(delayAfterAIResponseBeforeInputIsAllowed)

	-- Check if to send data stream for ship status change notification
	if session.currentGame == "scenario" then
		local statName = data.stat_changes.type
		local statValue = data.stat_changes.value
	
	end

	-- Check if game is over, and a status has been reached
	local gameShouldContinue = handleGameStatus(player, session, data)

	if gameShouldContinue then
		-- Display remaining attempts, if applicable
		-- Currently checking game progress (number of rounds).
		-- Consider switching this logic to check "data.last_round" instead of "data.round"
		local round = data.round
		local level = getLevelBasedOnStars(player)
		if session.currentGame == "akinator" and ((level == 1 and round == 16) or (level == 2 and round == 14) or (level == 3 and round == 12)) then
			DisplayMsgToPlr(player, "data", "You have 4 last attempts before the identity check fails.", false)
			wait(4)
		elseif session.currentGame == "taboo" and round == 3 then
			DisplayMsgToPlr(player, "data", "You have 2 last attempts before the identity check fails.", false)
			wait(4)
		elseif session.currentGame == "bluffing" then
			--if (level == 1 and round == 3) or (level == 2 and round == 5) or (level == 3 and round == 7) then
			--DisplayMsgToPlr(player, "data", "You have 2 last attempts to convince the AI before the system locks.", false)
			--end
			-- wait(4)
		end
	end

	return gameShouldContinue -- Input is, or is not, re-enabled
end

-- Start the conversation with NPC
local function startConvoWithNPC(player)
	print("Starting NPC Conversation")
	local npcName = workspace.npc.Name

	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)

	signals.re:fire("set_typing_indicator", player, true, "Starting conversation...")
	local data = sendPostRequest(AppUrl .. "/"..gameUrls["npc"].start .. "?name=".. npcName, "")
	signals.re:fire("set_typing_indicator", player, false)

	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. You can continue to the next room", false)
		wait(delayBeforeShowingGameStatus)
		return
	end

	local sessionId = data.session_id
	local aiResponse = data.npc_response

	-- Set up player session
	playerSessions[player.UserId] = {
		sessionId = sessionId,
		gameOver = false,
		currentGame = "npc"
	}

	-- Display AI message if there is one
	DisplayMsgToPlr(player, "cypress", aiResponse, true)
	PlayAnimationSet(data["animations"])
	
	-- Setup player input
	signals.re:fire("set_input_type", player, "text")
	signals.re:fire("set_input_enabled", player, true)
end

-- Start a story scenario
local function startScenario(player)
	print("Starting story scenario")

	-- Get the current room
	local currentRoom = signals.bf:fire("get_room", player)
	local currentRoomName
	if currentRoom:FindFirstChild("AA_RoomTitle") then 
		currentRoomName = currentRoom:FindFirstChild("AA_RoomTitle").Value
	else
		currentRoomName = currentRoom.Name
	end

	local url = AppUrl .. "/"..gameUrls["scenario"].start ..
		"?current_room=" .. currentRoomName ..
		"&user_id=" .. player.UserId ..
		"&username=" .. HttpService:UrlEncode(player.Name)
	
	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)
	
	signals.re:fire("set_typing_indicator", player, true, "Encountered a scenario...")
	local data = sendPostRequest(url, "")
	signals.re:fire("set_typing_indicator", player, false)

	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return
	end

	local sessionId = data.session_id
	local aiResponse = data.ai_message

	-- Set up player session
	playerSessions[player.UserId] = {
		sessionId = sessionId,
		gameOver = false,
		currentGame = "scenario"
	}

	-- Display AI message if there is one
	DisplayMsgToPlr(player, "scenario", aiResponse, true)
	
	-- Interpret options
	local options = data.options
	-- options.firstOption = "text..."
	-- options.secondOption = "text..."
	
	-- Setup player input
	signals.re:fire("set_input_type", player, "2options", options)
	signals.re:fire("set_input_enabled", player, true)
end

-- Start the game for a player
local function startGameForPlayer(player, whichGame, optionalGameSecret)
	print("Starting "..whichGame.." for player:", player.Name)

	-- First, calculate the user's level
	local level = getLevelBasedOnStars(player)

	-- ============== initialize games that require API connections ==============
	-- start the game and set url
	local url = nil
	local data = nil
	local isUserProvidedWord = false

	local roomId = 1

	if whichGame == "akinator" then
		isUserProvidedWord = true
		url = AppUrl .. "/" .. gameUrls[whichGame].start ..
			"?use_secret_word=" .. "true" ..
			"&ingame_id=" .. roomId ..
			"&secret_word=" .. optionalGameSecret ..
			"&level=" .. (level or 1) ..
			"&user_id=" .. player.UserId ..
			"&username=" .. HttpService:UrlEncode(player.Name)
		data = sendPostRequest(url, "")
	else
		url = AppUrl .. "/" .. gameUrls[whichGame].start ..
			"?ingame_id=" .. roomId ..
			"&level=" .. (level or 1) ..
			"&user_id=" .. player.UserId ..
			"&username=" .. HttpService:UrlEncode(player.Name)
	end
	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)

	signals.re:fire("set_typing_indicator", player, true, "Getting data...")
	data = sendPostRequest(url, "")
	signals.re:fire("set_typing_indicator", player, false)

	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return
	end

	local sessionId = data.session_id
	local aiResponse = data.ai_message

	-- Set up player session
	playerSessions[player.UserId] = {
		sessionId = sessionId,
		gameOver = false,
		currentGame = whichGame,
		userProvidedWordFlag = isUserProvidedWord
	}

	-- Interpret and display the password
	-- NOTE: We don't filter the password because we have full control over the password word bank
	if whichGame == "bluffing" then
		local password = data.game_secret.bluffing_statement
		local topic = data.game_secret.topic

		playerSessions[player.UserId].password = password
		DisplayMsgToPlr(player, "data", "Pretend that this statement is true for you: " .. password, false)
	elseif whichGame == "akinator" then
		local password = data.game_secret
		
		playerSessions[player.UserId].password = password
		DisplayMsgToPlr(player, "data", "System overridden with password (visible only to you): " .. password, false)
		wait(2)
		DisplayMsgToPlr(player, "data", "Help AI guard figure out the password to unlock the door.", false)
	elseif whichGame == "taboo" then
		local password = data.game_secret
		
		playerSessions[player.UserId].password = password
		DisplayMsgToPlr(player, "data", "Password successfully hacked (visible only to you): " .. password, false)
	end
	-- ============== finish game initialization ==============

	wait(4)

	-- Display # of attempts
	if whichGame == "taboo" then
		local attempts = 5
		DisplayMsgToPlr(player, "data", "You have "..attempts.." attempts before the system locks.", false)
	elseif whichGame == "bluffing" then
		local attempts = 5
		if level == 2 then
			attempts = 7
		elseif level == 3 then
			attempts = 9
		end
		DisplayMsgToPlr(player, "cypress", "I'll ask you up to "..attempts.." questions to confirm your authenticity.", false)
	elseif whichGame == "akinator" then
		local attempts = 20
		if level == 2 then
			attempts = 18
		elseif level == 3 then
			attempts = 16
		end
		DisplayMsgToPlr(player, "data", "You have "..attempts.." questions before the system locks.", false)
	end
	wait(4)

	-- Display AI message if there is one
	DisplayMsgToPlr(player, "cypress", aiResponse, true)

	-- Setup player input
	if whichGame == "taboo" or whichGame == "bluffing" then
		signals.re:fire("set_input_type", player, "text")
	elseif whichGame == "akinator" then
		if level >= 3 then
			signals.re:fire("set_input_type", player, "yesno")
		else
			signals.re:fire("set_input_type", player, "probablyyesno")
		end
	end

	signals.re:fire("set_input_enabled", player, true)
	signals.re:fire("set_assist_visible", player, true)
end

-- Regenerate last AI message
local function ReGenerateLastMsg(player)
	local session = playerSessions[player.UserId]
	if not session or session.gameOver then
		DisplayMsgToPlr(player, "cypress", "Oops, I lost track of our conversation. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end
	
	print("Regenerating last AI message from "..session.currentGame.." for player:", player.Name)

	-- Send regeneration request to the server
	local url = AppUrl .. "/"..gameUrls[session.currentGame].regenerate.."?session_id=" .. session.sessionId

	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)
	
	signals.re:fire("set_typing_indicator", player, true, "Rethinking...")
	local data = sendPostRequest(url, "")
	signals.re:fire("set_typing_indicator", player, false)

	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end

	session.gameOver = data.game_over
	session.gameStatus = data.game_status

	-- Display AI message to the player
	DisplayMsgToPlr(player, "cypress", data.ai_message, true)

	wait(delayAfterAIResponseBeforeInputIsAllowed)

	-- Check if game is over, and a status has been reached
	local gameShouldContinue = handleGameStatus(player, session, data)
	return gameShouldContinue -- Input is, or is not, re-enabled
end

-- Generate and show alternative answers/questions from AI (for Taboo & Bluffing)
local function GenerateAssistantChoices(player)
	local session = playerSessions[player.UserId]
	if not session or session.gameOver then
		DisplayMsgToPlr(player, "cypress", "Oops, I lost track of our conversation. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end
	
	print("Generating alternative responses in "..session.currentGame.." for player:", player.Name)

	-- Send alternative responses request to the server
	local url = AppUrl .. "/"..gameUrls[session.currentGame].assistant.."?session_id=" .. session.sessionId

	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)
	
	signals.re:fire("set_typing_indicator", player, true, "Getting sample answers...")
	local data = sendPostRequest(url, "")
	signals.re:fire("set_typing_indicator", player, false)

	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end

	local first_response = requestFilterText(player, data.first_response)
	local second_response = requestFilterText(player, data.second_response)

	signals.re:fire("display_clickable_alternatives", player, first_response, second_response)

	return true -- Input is re-enabled
end

-- Generate hint from AI
local function GenerateHint(player)
	local session = playerSessions[player.UserId]
	if not session or session.gameOver then
		DisplayMsgToPlr(player, "cypress", "Oops, I lost track of our conversation. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end
	
	print("Generating hint response in "..session.currentGame.." for player:", player.Name)

	-- Send alternative responses request to the server
	local url
	if session.currentGame == "akinator" then
		local akinatorWordFlagStr = tostring(session.userProvidedWordFlag)
		url = AppUrl .. "/"..gameUrls[session.currentGame].hint.. "?use_secret_word=" .. akinatorWordFlagStr .. "&session_id=" .. session.sessionId
	else
		url = AppUrl .. "/"..gameUrls[session.currentGame].hint.."?session_id=" .. session.sessionId
	end

	-- Pause timer sequence
	signals.be:fire("pause_explode_timer", player)        -- Pauses local explode timer
	signals.re:fire("pause_display_explode_timer", player)
	signals.be:fire("pause_global_explode_timer", player) -- Pauses global explode timer
	signals.re:fire("pause_display_global_explode_timer", player)
	
	signals.re:fire("set_typing_indicator", player, true, "Getting hint...")
	local data = sendPostRequest(url, "")
	signals.re:fire("set_typing_indicator", player, false)

	-- Resume timer sequence
	signals.be:fire("resume_explode_timer", player)        -- Resumes local explode timer
	signals.re:fire("resume_display_explode_timer", player)
	signals.be:fire("resume_global_explode_timer", player) -- Resumes global explode timer
	signals.re:fire("resume_display_global_explode_timer", player)

	if not data then
		DisplayMsgToPlr(player, "cypress", "Oops, I couldn't connect to the network. I'll just unlock the door for you...", false)
		signals.be:fire("set_internet_state", true)
		finishGameSession(player, true)
		return false
	end

	print("hint message:", data.hint_message)

	local hint_message = requestFilterText(player, data.hint_message)

	signals.re:fire("display_hint", player, hint_message)

	return true -- Input is re-enabled
end

-- Check if player can afford the cost. If so, buy the item
local function tryToBuy(player, cost)
	if signals.bf:fire("can_afford", player, "chips", cost) then
		signals.bf:fire("change_currency", player, "chips", -cost)
		return true
	else
		DisplayMsgToPlr(player, "alarm", "You don't have enough chips to do that.")
		return false
	end
end

function module.init()
	print("CypressAI init")
	signals.rf:connect("send_msg_plr", handlePlayerInput)
	signals.bf:connect("send_msg_plr", handlePlayerInput)

	signals.re:connect("start_game", startGameForPlayer)
	signals.be:connect("start_game", startGameForPlayer)

	signals.be:connect("start_npc", startConvoWithNPC)
	signals.be:connect("start_scenario", startScenario)

	signals.rf:connect("calculate_level", getLevelBasedOnStars)
	signals.rf:connect("fetch_metadata", fetchUserMetadata)

	signals.rf:connect("send_elapsed_time", sendElapsedTime)
	signals.bf:connect("send_elapsed_time", sendElapsedTime)

	signals.re:connect("request_show_hint", function(player)
		local cost = 50
		if tryToBuy(player, cost) then
			GenerateHint(player)
		end
	end)
	signals.re:connect("request_show_answer", function(player)
		local cost = 250
		if tryToBuy(player, cost) then
			GenerateAssistantChoices(player)
		end
	end)
	signals.re:connect("request_skip_minigame", function(player)
		local cost = 500
		if tryToBuy(player, cost) then
			finishGameSession(player, true)
		end
	end)

	signals.re:connect("regenerate_last_ai_message", ReGenerateLastMsg) -- FIXME (Lanxiang): 1. simplify "regenerate" API implementation & db operations; 2. refactor code shared with ``handlePlayerInput''
	
	Players.PlayerRemoving:Connect(function(player)
		-- Clean up any session data
		playerSessions[player.UserId] = nil
	end)

end

return module
