local character = script.Parent.Parent

local player = game.Players:GetPlayerFromCharacter(character)
local humanoid = character:WaitForChild("Humanoid")

local signals = require(game.ReplicatedStorage:WaitForChild("Shared").signals)

local debounce = false

humanoid.HealthChanged:Connect(function(health)
    if health > 0 then return end

    humanoid.Health = humanoid.MaxHealth
    character:MakeJoints()

    if debounce then return end
    debounce = true

    print("Player has died!")

    local livesLeft = signals.bf:fire("change_currency", player, "lives", -1)
    if livesLeft > 0 then
        -- Still alive!

        -- Stop player from moving
        humanoid.WalkSpeed = 0

        -- Get current spawn location
        local currentSpawn = require(game.ServerScriptService:WaitForChild("Server").gameState).currentSpawn
        if not currentSpawn then warn("No current spawn") humanoid.WalkSpeed = 16 return end
        player.Character:SetPrimaryPartCFrame(currentSpawn.CFrame + Vector3.new(0, 6, 0))
        
        -- Wait a bit before allowing the player to move again
        wait(1)
        humanoid.WalkSpeed = 16
    else
        -- Game over

        -- Award lose badge
        signals.be:fire("award_badge", player, 1605897250653134)

        signals.re:fire("set_black_fade", player, true)
        wait(1)

        -- Move player to a safe location before restarting
        local safeSpawn = game.Workspace.Rooms.room_start.AA_Spawn.SpawnLocation
        player.Character:SetPrimaryPartCFrame(safeSpawn.CFrame + Vector3.new(0, 6, 0))

        wait(1)

        -- Restart the game
        signals.re:fire("end_game", player, false, {reason = "You lost all your lives..."})
    end

    debounce = false
end)