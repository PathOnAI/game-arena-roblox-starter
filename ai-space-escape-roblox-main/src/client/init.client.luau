print("Client Init")
-- REFERENCES
local client = game.StarterPlayer.StarterPlayerScripts:WaitForChild("Client")

local screenshake = require(client.UIModules.screenshake)
screenshake.init()

require(client.UIModules.blackFade):init()

require(client.ChatWindow.loadingAnimation):init()

require(client.hud):init()

require(client.UIModules.sparkle):init()

require(client.ChatWindow.typingAnimation):init()

require(client.ChatWindow.chatAssistManager):init()

require(client.ChatWindow.shopManager).init()

require(client.creditsScreen).init()

require(client.UIModules.music).init()

require(client.UIModules.forceShiftLock).init()

require(client.UIModules.tutorial_room):init()

-- Init intro screen to choose difficulty level
require(client.IntroScreen):init()

-- Disable leaderboard and chat
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

print("Client Init OK!")