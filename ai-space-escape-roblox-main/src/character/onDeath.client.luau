local character = script.Parent.Parent

local player = game.Players:GetPlayerFromCharacter(character)
local humanoid = character:WaitForChild("Humanoid")

humanoid.HealthChanged:Connect(function(health)
    if health > 0 then return end

    humanoid.Health = humanoid.MaxHealth
	character:MakeJoints()

    print("Player has died due to resetting (client reasons)")

    -- Stop player from moving
    humanoid.WalkSpeed = 0

    -- Get current spawn location
    local currentSpawn = require(game.ServerScriptService:WaitForChild("Server").gameState).currentSpawn
    if not currentSpawn then warn("No current spawn") humanoid.WalkSpeed = 16 return end
    player.Character:SetPrimaryPartCFrame(currentSpawn.CFrame + Vector3.new(0, 6, 0))
    
    -- Wait a bit before allowing the player to move again
    wait(1)
    humanoid.WalkSpeed = 16
end)