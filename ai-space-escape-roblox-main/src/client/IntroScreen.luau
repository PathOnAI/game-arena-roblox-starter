-- File: client.IntroScreen.init
local module = {}

function module:init()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Require any shared modules you need (signals, difficulty settings, etc.)
    local signals = require(ReplicatedStorage:WaitForChild("Shared").signals)
    local DifficultySettings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DifficultySettings"))

    -- Get the local player
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

    -- Wait for the IntroScreenGui to be copied from StarterGui to the player's PlayerGui
    local introScreenGui = player:WaitForChild("PlayerGui"):WaitForChild("IntroScreenGui")
    local frame = introScreenGui:WaitForChild("IntroScreen")
    local disclaimerFrame = introScreenGui:WaitForChild("Disclaimer")

    -- Reference your buttons
    local easyButton = frame:WaitForChild("EasyButton")
    local hardButton = frame:WaitForChild("HardButton")
    local VeryHardButton = frame:WaitForChild("VeryHardButton")

    -- Show disclaimer
    print("showing disclaimer...")
    local backButton = disclaimerFrame:WaitForChild("Back")
    local nextButton = disclaimerFrame:WaitForChild("Next")
    
    disclaimerFrame.Visible = true
    backButton.Visible = true
    nextButton.Visible = true

    frame.Visible = true
    frame.BackgroundImage.Visible = true
    easyButton.Visible = true
    hardButton.Visible = true
    VeryHardButton.Visible = true

    local setDiffEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetDifficultyEvent")

    -- Set difficulty and hide UI
    local function setDifficulty(difficulty)
        DifficultySettings.setDifficulty(player, difficulty)

        -- Sync with server
        setDiffEvent:FireServer(difficulty)

        -- Hide the UI after selection
        frame.Visible = false

        -- Tutorials
        if difficulty ~= "Easy" then
            print("hiding tutorial GUI...")
            -- Hide the tutorial GUI
            player.PlayerGui:WaitForChild("TutorialGui").AskFor.Visible = false
        end
        
        if difficulty == "Hard" then
            title = "Regular Mode"
            message ="You have 20 minutes to escape. AI response time does not count towards the timer."
            local tutorial_room = game.Players.LocalPlayer.PlayerGui:WaitForChild("TutorialGui"):WaitForChild("Tutorial_Mode")
            tutorial_room.Info.Text = message
            tutorial_room.Title.Text = title
            tutorial_room.Visible = true
        elseif difficulty == "Very_Hard" then
            title = "Hard Mode"
            message = "You have 15 minutes to escape. All models use experimental advanced AI systems, which may be slower. AI response time does not count towards the timer."  
            local tutorial_room = game.Players.LocalPlayer.PlayerGui:WaitForChild("TutorialGui"):WaitForChild("Tutorial_Mode")
            tutorial_room.Info.Text = message
            tutorial_room.Title.Text = title
            tutorial_room.Visible = true    
        end

        signals.re:fire("reset_currency", player)

        local metadata = signals.rf:fire("fetch_metadata", player)
        local stars = metadata.stars
        if metadata and stars then
            print("initializing metadata stars: " .. stars)
            signals.be:fire("update_stars_counter_ui", stars)
        end
    end

    -- Connect buttons to set difficulty
    easyButton.MouseButton1Click:Connect(function()
        setDifficulty("Easy")
    end)

    hardButton.MouseButton1Click:Connect(function()
        setDifficulty("Hard")
    end)

    VeryHardButton.MouseButton1Click:Connect(function()
        setDifficulty("Very_Hard")
    end)
end

return module
