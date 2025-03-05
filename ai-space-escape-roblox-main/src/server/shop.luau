local module = {
    currentlyAvailableInShop = {},
    purchases = {},
}

-- REF
local signals = require(game.ReplicatedStorage:WaitForChild("Shared").signals)

local function getPurchasedItem(itemId)
    local count = module.purchases[itemId]

    if not count then
        print("Item not found: " .. itemId)
        return 0
    end

    return module.purchases[itemId]
end

-- SETTINGS
local shipStatsPerShopItem = 40 -- How much each shop item increases the ship stats

local itemList = {
    {
        id = "roomRunner",
        name = "Room Runner",
        desc = "Skip +1 room every time you reach an exit door",
        cost = 500,
        icon = "rbxassetid://14930267287",
        -- implemented
    },
    {
        id = "lifeBoost",
        name = "Sole Survivor",
        desc = "+1 life",
        cost = 500,
        icon = "rbxassetid://13868090608",
        func = function(player) signals.bf:fire("change_currency", player, "lives", 1) end
    },
    {
        id = "lifeChance",
        name = "Second Wind",
        desc = "+10% chance that dying doesn't take a life",
        cost = 500,
        icon = "rbxassetid://14934967002",
        -- implemented
    },
    {
        id = "timerBoost",
        name = "Expert Engineer",
        desc = "+20% duration to self-destruct timers",
        cost = 250,
        icon = "rbxassetid://14936630790",
        -- implemented
    },
    {
        id = "incomeBoost",
        name = "Scavenger",
        desc = "+20% more when collecting chips",
        cost = 250,
        icon = "rbxassetid://13847413936",
        -- implemented
    },
    -- {
    --     id = "speedBoost",
    --     name = "Sprinter",
    --     desc = "+20% run speed",
    --     cost = 100,
    --     icon = "rbxassetid://14939403421",
    --     func = function(player) player.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed * (1 + 0.2 * getPurchasedItem("speedBoost")) end
    -- },
    -- {
    --     id = "jumpBoost",
    --     name = "Jump Boost",
    --     desc = "+20% jump height",
    --     cost = 100,
    --     icon = "rbxassetid://14936798122",
    --     func = function(player) player.Character.Humanoid.JumpHeight = game.StarterPlayer.CharacterJumpHeight * (1 + 0.2 * getPurchasedItem("jumpBoost")) end
    -- },
    {
        id = "healthBoost",
        name = "Resilient",
        desc = "+20% max health",
        cost = 100,
        icon = "rbxassetid://14941349760",
        func = function(player) player.Character.Humanoid.MaxHealth = 100 * (1 + 0.2 * getPurchasedItem("healthBoost")) end
    },
    --{
    --    id = "damageBoost",
    --    name = "Sharpshooter",
    --    desc = "+20% damage",
    --    cost = 100,
    --    icon = "rbxassetid://13850781784",
    --},
    --{
    --    id = "fireRateBoost",
    --    name = "Rapid Fire",
    --    desc = "-20% reload time",
    --    cost = 100,
    --    icon = "rbxassetid://14943101608",
    --},
    --{
    --    id = "knockbackBoost",
    --    name = "Heavy Hitter",
    --    desc = "+20% knockback",
    --    cost = 100,
    --    icon = "rbxassetid://13859356329",
    --},
    {
        id = "hullRepair",
        name = "Hull Repair",
        desc = "+"..shipStatsPerShopItem.." hull points",
        cost = 100,
        icon = "rbxassetid://13850129719",
        func = function(player) signals.bf:fire("change_currency", player, "hull", shipStatsPerShopItem) end
    }
    -- {
    --     id = "coolantRefill",
    --     name = "Coolant Canister",
    --     desc = "+"..shipStatsPerShopItem.." ship reactor coolant",
    --     cost = 100,
    --     icon = "rbxassetid://13867981216",
    --     func = function(player) signals.bf:fire("change_currency", player, "coolant", shipStatsPerShopItem) end
    -- },
    -- {
    --     id = "oxygenRefill",
    --     name = "Oxygen Tank",
    --     desc = "+"..shipStatsPerShopItem.." ship oxygen",
    --     cost = 100,
    --     icon = "rbxassetid://14966360015",
    --     func = function(player) signals.bf:fire("change_currency", player, "oxygen", shipStatsPerShopItem) end
    -- }
}

-- FUNCTION

local function getItemData(itemId)
    for _, item in ipairs(itemList) do
        if item.id == itemId then
            return item
        end
    end
    print("Item not found: " .. itemId)
    return nil
end


local function tryToBuy(player, itemId)
    -- Check if valid item
    local item = getItemData(itemId)
    if not item then warn("doesn't exist") return false end

    -- Check if item is currently available
    if not table.find(module.currentlyAvailableInShop, item.id) then warn("item not available") return false end

    -- Check if player can afford the item
    if not signals.bf:fire("can_afford", player, "chips", item.cost) then warn("can't afford") return false end

    -- Okay, buy the item
    signals.bf:fire("change_currency", player, "chips", -item.cost)

    -- Count the purchases
    if module.purchases[item.id] then
        module.purchases[item.id] = module.purchases[item.id] + 1
    else
        module.purchases[item.id] = 1
    end
    print(player.Name .. " bought " .. item.name .. " (current count: " .. module.purchases[item.id] .. ")")

    -- Execute the purchase effect (if applicable)
    if item.func then item.func(player) end

    return true
end

local function refreshShopItems()
    -- Pick some random items
    local itemIds = {}
    local items = {}
    for i = 1, 5 do
        local item = itemList[math.random(1, #itemList)]

        -- Check if it's already in the shop list
        while table.find(itemIds, item.id) do
            item = itemList[math.random(1, #itemList)]
        end

        table.insert(items, item)
        table.insert(itemIds, item.id)
    end

    -- Add them to the currently available list
    module.currentlyAvailableInShop = itemIds

    return items
end

function module.init()
    signals.rf:connect("shop_try_to_buy", tryToBuy)
    signals.rf:connect("shop_refresh_items", function(player)
        if signals.bf:fire("can_afford", player, "chips", 250) then
            signals.bf:fire("change_currency", player, "chips", -250)
            return refreshShopItems()
        else
            return nil
        end
    end)

    signals.bf:connect("shop_refresh_items", refreshShopItems)
    signals.bf:connect("shop_get_purchased_item", getPurchasedItem)

    signals.be:connect("reset_shop", function(player)
        module.currentlyAvailableInShop = {}
        module.purchases = {}

        -- Also reset humanoid stats
        player.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
        player.Character.Humanoid.JumpHeight = game.StarterPlayer.CharacterJumpHeight
        player.Character.Humanoid.MaxHealth = 100
    end)
end

return module