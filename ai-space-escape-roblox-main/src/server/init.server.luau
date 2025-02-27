print("Server Init")
local signals = require(game.ReplicatedStorage.Shared.signals)

local gameState = require(game.ServerScriptService.Server.gameState)
local explodeShip = require(game.ServerScriptService.Server.explodeShip)

gameState.init()

local cypressAI = require(game.ServerScriptService.Server.CypressAI)
cypressAI.init()

require(game.ServerScriptService.Server.brickTypes).init()

require(game.ServerScriptService.Server.Modules.filterText):init()
require(game.ServerScriptService.Server.Modules.currencyManager):init()

require(game.ServerScriptService.Server.shop).init()

require(game.ServerScriptService.Server.explodeShip).init()

require(game.ServerScriptService.Server.Modules.BadgeManager).init()

print("Server Init OK!")

local replicatedStorage = game:GetService("ReplicatedStorage")
local toolsFolder = replicatedStorage:WaitForChild("Tools")
local addToolEvent = replicatedStorage:WaitForChild("Events"):WaitForChild("AddToolToBackpack")

-- Listen for client requests to add a tool
addToolEvent.OnServerEvent:Connect(function(player)
    local laserGun = toolsFolder:FindFirstChild("LaserGun")

    if laserGun then
        -- Clone the tool and add it to the player's Backpack
        local backpack = player:WaitForChild("Backpack")
        local toolClone = laserGun:Clone()
        toolClone.Parent = backpack
        print(player.Name .. " received the LaserGun!")
    else
        warn("LaserGun not found in ReplicatedStorage.Tools!")
    end
end)

-- Wait for the RemoteEvent
local setDiffEvent = replicatedStorage:WaitForChild("Events"):WaitForChild("SetDifficultyEvent")

setDiffEvent.OnServerEvent:Connect(function(player, difficulty)
    -- Set the attribute on the player object
    player:SetAttribute("Difficulty", difficulty)

    print(player.Name .. " set difficulty to " .. difficulty)
end)