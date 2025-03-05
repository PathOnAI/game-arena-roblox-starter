local module = {}

-- REFERENCES
local signals = require(game.ReplicatedStorage:WaitForChild("Shared").signals)

local creditsScreen = game.Players.LocalPlayer.PlayerGui:WaitForChild("BlackFade").creditsScreen

local sounds = game.Players.LocalPlayer.PlayerGui:WaitForChild("sounds")

local StarterGui = game:GetService("StarterGui")

local function endGame(success, optionalArgs)
    warn("Ending game...")

    creditsScreen.Visible = true
    creditsScreen.score.Visible = true
    creditsScreen.score.Position = UDim2.new(0.5, 0, 0.5, 0)
    creditsScreen.credits.Visible = true
    creditsScreen.credits.Position = UDim2.new(0.5, 0, 1.5, 0)

    -- Make any UI changes
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    signals.be:fire("set_force_shift_lock", false)

    -- Set up all the text
    if success then
        creditsScreen.score[1].Text = "You Escaped!"
        creditsScreen.score[2].Text = "You reached the escape pod in time, allowing you to return to Earth safely."
        signals.be:fire("change_playlist", "win")
    else
        creditsScreen.score[1].Text = "Game Over"
        if optionalArgs and optionalArgs.reason then
            creditsScreen.score[2].Text = optionalArgs.reason
        else
            creditsScreen.score[2].Text = "You were unable to reach the escape pod in time..."
        end
        signals.be:fire("change_playlist", "lose")
    end

    -- Get run info
    local runInfo = signals.rf:fire("get_run_info", true)
    creditsScreen.score[3].Text = "You've reached Room " .. runInfo.highestRoom .."."
    creditsScreen.score[4].Text = "Rooms completed (actual): " .. runInfo.roomsCompleted
    creditsScreen.score[5].Text = "Time taken: " .. math.floor(runInfo.timeTaken/60) .. "min " .. runInfo.timeTaken%60 .. "sec"
    creditsScreen.score[6].Text = "Lives left: " .. runInfo.livesLeft
    

    wait(4)

    -- Tween position of score amd credits screen
    creditsScreen.score:TweenPosition(UDim2.new(0.5, 0, -0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 15, true)
    creditsScreen.credits:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 15, true)

    wait(15)

    -- Continue tween
    creditsScreen.score.Position = UDim2.new(0.5, 0, 1.5, 0)
    creditsScreen.score:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 15, true)
    creditsScreen.credits:TweenPosition(UDim2.new(0.5, 0, -0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 15, true)

    wait(15)

    -- Now everything is at the original position
    creditsScreen.credits.Position = UDim2.new(0.5, 0, 1.5, 0)
end

function module.init()
    signals.re:connect("end_game", endGame)
    game.ReplicatedStorage:WaitForChild("Events").showCreditsScreen.OnClientEvent:Connect(function(success)
        endGame(success)
    end)
    creditsScreen.restart.Activated:Connect(function()
        creditsScreen.Visible = false

        -- Reset any UI changes
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        signals.be:fire("set_force_shift_lock", true)

        signals.re:fire("restart_game")
    end)
end

return module