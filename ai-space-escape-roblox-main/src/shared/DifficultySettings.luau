local DifficultySettings = {}

function DifficultySettings.setDifficulty(player, difficulty)
    if player and player:IsA("Player") then
        player:SetAttribute("Difficulty", difficulty)
    end
    print("Difficulty set to:", player:GetAttribute("Difficulty"))
end

function DifficultySettings.getDifficulty(player)
    if player and player:IsA("Player") then
        return player:GetAttribute("Difficulty")
    end
    return nil
end

return DifficultySettings