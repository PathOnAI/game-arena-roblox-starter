local character = script.Parent
print(character.Name .. " has spawned!")

-- Example: Play Animation when NPC talks
local humanoid = character:FindFirstChild("Humanoid")
if humanoid then
    print(character.Name .. " is ready!")
end
