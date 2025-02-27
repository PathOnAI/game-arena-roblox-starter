local module = {}

-- REFERENCES
local ts = game:GetService("TweenService")

local signals = require(game.ReplicatedStorage:WaitForChild("Shared").signals)

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD")
local topBar = playerGui:WaitForChild("TopBar")

local client = game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("Client")
local sparkle = require(client.UIModules.sparkle)
local uiFlash = require(client.UIModules.uiFlash)
local uiValueDisplacement = require(client.UIModules.uiValueDisplacement)

local sounds = game.Players.LocalPlayer.PlayerGui:WaitForChild("sounds")

-- FUNCTIONS

local roomInfo = hud.screenArea.roomInfo
local roomInfoTween = ts:Create(roomInfo, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.024, 0, 0.042, 0), Size = UDim2.new(0, 250, 0, 60), AnchorPoint = Vector2.new(0, 0)})
local coverTween = ts:Create(roomInfo.ignoreLayout.cover.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)})
local function displayRoomInfo(title, desc, roomN)
    -- Reset position
    roomInfo.Position = UDim2.new(0.5, 0, 0.5, 0)
    roomInfo.Size = UDim2.new(0, 600, 0, 120)
    roomInfo.AnchorPoint = Vector2.new(0.5, 0.5)

    roomInfo.ignoreLayout.cover.Visible = true
    roomInfo.ignoreLayout.cover.UIGradient.Offset = Vector2.new(-1, 0)

    -- Set details
    roomInfo.header.title.Text = title
    roomInfo.desc.Text = desc
    if string.sub(title, 1, 5) == "Room " then
        -- Don't show room number if it's a generic room
        roomInfo.header.roomN.Visible = false
    else
        -- Show room number
        roomInfo.header.roomN.Visible = true
        if roomN < 10 then
            roomInfo.header.roomN.Text = "Room 0" .. roomN
        else
            roomInfo.header.roomN.Text = "Room " .. roomN
        end
    end

    -- Reveal tween
    coverTween:Play()

    wait(4)

    -- Play tween
    roomInfoTween:Play()
end
local function updateRoomInfoDesc(desc)
    roomInfo.desc.Text = desc
    sounds.objective:Play()
end

local roomCounter = hud.screenArea.bright.roomCounter
local function updateRoomCounterUI(current, real, total, title, desc)
    roomCounter.container.Top.text.Text = (total-current) .. " AI guards to escape pod"

    roomCounter.container.Bottom.bar.fill.Size = UDim2.new(current/total, 0, 1, 0)

    -- Sparkle the end of the bar
    spawn(function()
        sparkle:sparkle({stagger = true, reverse = true, numParticles = 50}, roomCounter.container.Bottom.bar.fill.endOfBar)
    end)
    
    -- Display room info
    displayRoomInfo(title, desc, real)
end

local starsCounter = hud.screenArea.bleft.security
local function updateStarsCounterUI(current)
    if current >= 10 then
        -- Tier 3 (max)
        starsCounter.container.Bottom.bar.fill.Size = UDim2.new(1, 0, 1, 0)
        starsCounter.container.Bottom.bar.fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        starsCounter.iconFrame.icon.text.Text = "3"
    elseif current >= 4 then
        -- Tier 2 (4-9)
        starsCounter.container.Bottom.bar.fill.Size = UDim2.new((current-4)/6, 0, 1, 0)
        starsCounter.container.Bottom.bar.fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        starsCounter.iconFrame.icon.text.Text = "2"
    else
        -- Tier 1 (0-3)
        starsCounter.container.Bottom.bar.fill.Size = UDim2.new(current/4, 0, 1, 0)
        starsCounter.container.Bottom.bar.fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        starsCounter.iconFrame.icon.text.Text = "1"
    end

    -- Sparkle the end of the bar
    sparkle:sparkle({stagger = true, reverse = true, numParticles = 50}, starsCounter.container.Bottom.bar.fill.endOfBar)
end

local currency = hud.screenArea.bleft.currency
local function updateCurrency(currencyType, newAmount)
    if currencyType == "lives" then
        uiValueDisplacement.tweenNumber(currency.lives.text, newAmount)

        sparkle:sparkle({numParticles = 100, distance = 500, explosionTime = 2}, currency.lives.icon)
        uiFlash:flash(currency.lives.icon)
        sounds.heartbeat:Play()

    elseif currencyType == "chips" then
        local oldValue = tonumber(currency.chips.text.Text)
        if oldValue then
            if newAmount > oldValue then
                -- Increase
                local screenCenter = game.Players.LocalPlayer.PlayerGui:WaitForChild("particleContainer"):WaitForChild("screenCenter")

                sounds.money_collect:Play()
                sparkle:sparkle({stagger = true, image = "rbxassetid://13847413936", numParticles = 10, destSound = sounds.money_count}, screenCenter, currency.chips.icon)
                
                wait(1.5)
            else
                -- Decrease
                sounds.money_buy:Play()
                sparkle:sparkle({stagger = true, reverse = false, numParticles = 50}, currency.chips.icon)
            end
        end

        uiValueDisplacement.tweenNumber(currency.chips.text, newAmount)
    -- elseif currencyType == "hull" or currencyType == "oxygen" or currencyType == "coolant" then
    elseif currencyType == "hull" then
        local targetShipStat = topBar.screenArea[currencyType]

        -- Basic value display
        uiValueDisplacement.tweenNumber(targetShipStat.body.top.amount, newAmount)
        local barFill = targetShipStat.body.bottom.bar.fill
        barFill:TweenSize(UDim2.new(newAmount/100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, true)

        -- Range-specific effects
        if newAmount <= 0 then
            targetShipStat.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        else
            targetShipStat.BackgroundColor3 = Color3.fromRGB(0,0,0)
        end
        
        if newAmount <= 25 then
            barFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

            uiFlash:flash(targetShipStat.icon.image, true)
        elseif newAmount <= 50 then
            barFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)

            uiFlash:stopFlash(targetShipStat.icon.image)
            uiFlash:flash(targetShipStat.icon.image, false)
        else
            barFill.BackgroundColor3 = Color3.fromRGB(66, 255, 0)

            uiFlash:stopFlash(targetShipStat.icon.image)
        end

        -- Increase/decrease effects
        local oldValue = tonumber(targetShipStat.body.top.amount.Text)
        if oldValue and math.abs(oldValue-newAmount) >= 5 then
            if newAmount > oldValue then
                -- Increase
                sparkle:sparkle({stagger = true, reverse = true, numParticles = 50}, targetShipStat.icon.image)
            else
                -- Decrease
                sparkle:sparkle({stagger = true, numParticles = 50}, targetShipStat.icon.image)
            end
        end
    end
end

-- A variable to keep the timer running or stop it
local globalTimerEnabled = false

local TweenService = game:GetService("TweenService")

-- Helper function to uniformly tween a UIGradient’s transparency
-- from startVal to endVal (both 0-1) over `duration` seconds.
local function fadeGradient(uiGradient, startVal, endVal, duration)
    local numberVal = Instance.new("NumberValue")
    numberVal.Value = startVal

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(numberVal, tweenInfo, { Value = endVal })

    numberVal.Changed:Connect(function(newVal)
        -- Assign a uniform NumberSequence
        uiGradient.Transparency = NumberSequence.new(newVal)
    end)

    tween.Completed:Connect(function()
        numberVal:Destroy()
    end)

    tween:Play()
end

--------------------------------------------------------------------------------
-- GLOBAL TIMER DISPLAY: BEGIN
--------------------------------------------------------------------------------

local globalTimerEnabled = false
local timeLeft = 0

-- Pause-related variables
local displayGlobalTimerPaused = false  -- Whether the global timer is currently paused
local prevTime = 0                      -- Tracks the last frame's os.time() to compute delta

local function displayGlobalTimer(timeInSeconds)
    -- If timer is already running, just update 'timeLeft'
    if globalTimerEnabled then
        print("Timer is already running; updating timeLeft to:", timeInSeconds)
        timeLeft = timeInSeconds
        return
    end

    -- Otherwise, set up the timer for the first time
    globalTimerEnabled = true
    timeLeft = timeInSeconds
    displayGlobalTimerPaused = false

    -- References to your timer UI
    local timerFrame = hud.screenArea.globalTimer
    local contentFrame = timerFrame.contentFrame
    local timerText = contentFrame.timerText

    prevTime = os.time()

    -- Make sure everything is visible
    timerFrame.Visible = true
    timerFrame.header.Visible = true
    timerText.Visible = true

    -- Fade In: contentFrame background, gradients, text, images
    contentFrame.BackgroundTransparency = 1
    for _, obj in pairs(contentFrame:GetDescendants()) do
        if obj:IsA("UIGradient") then
            obj.Transparency = NumberSequence.new(1) -- fully invisible
        elseif obj:IsA("TextLabel") then
            obj.TextTransparency = 1
        elseif obj:IsA("ImageLabel") then
            obj.ImageTransparency = 1
        end
    end

    local fadeInInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(contentFrame, fadeInInfo, { BackgroundTransparency = 0 }):Play()

    -- Tween UIGradient -> from 1 to 0.5, TextLabel & ImageLabel -> from 1 to 0
    for _, obj in pairs(contentFrame:GetDescendants()) do
        if obj:IsA("UIGradient") then
            fadeGradient(obj, 1, 0.5, 4) 
        elseif obj:IsA("TextLabel") then
            TweenService:Create(obj, fadeInInfo, { TextTransparency = 0 }):Play()
        elseif obj:IsA("ImageLabel") then
            TweenService:Create(obj, fadeInInfo, { ImageTransparency = 0 }):Play()
        end
    end

    -- Helper function for tweening text color
    local function tweenTextColor(newColor, duration)
        local textColorInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        TweenService:Create(timerText, textColorInfo, {TextColor3 = newColor}):Play()
    end

    -- Start the single countdown loop
    spawn(function()
        --local prevTime = os.time()
        while globalTimerEnabled do
            local currentTime = os.time()
            local elapsed = currentTime - prevTime
            prevTime = currentTime

            if not displayGlobalTimerPaused then
                -- Only if not paused, decrement time
                timeLeft -= elapsed

                -- Time up => show "SELF-DESTRUCT"
                if timeLeft <= 0 then
                    timerText.TextSize = 18
                    timerText.Text = "SELF-DESTRUCT\nINITIATED"
                else
                    -- Convert to minutes & seconds
                    local minutes = math.floor(timeLeft / 60)
                    local seconds = math.floor(timeLeft % 60)

                    if seconds < 10 then
                        timerText.Text = string.format("%d:0%d", minutes, seconds)
                    else
                        timerText.Text = string.format("%d:%d", minutes, seconds)
                    end
                end

                -- 3) Blinking logic
                if timeLeft <= 30 then
                    -- Blink red <-> white quickly
                    tweenTextColor(Color3.fromRGB(255, 0, 0), 0.25) 
                    wait(0.25)
                    tweenTextColor(Color3.fromRGB(255, 255, 255), 0.25)
                    wait(0.25)
                elseif timeLeft <= 60 then
                    -- Blink slower
                    tweenTextColor(Color3.fromRGB(255, 0, 0), 0.5)
                    wait(0.5)
                    tweenTextColor(Color3.fromRGB(255, 255, 255), 0.5)
                    wait(0.5)
                else
                    -- Normal state (white text), update each second
                    tweenTextColor(Color3.fromRGB(255, 255, 255), 0.2) 
                    wait(1)
                end

                -- If timeLeft <= 0, we show "SELF-DESTRUCT" but remain in loop until next cycle
                if timeLeft <= -5 then
                    break
                end
            else
                -- If paused, just wait a bit and continue looping
                wait(0.5)
            end
        end
        
        -- "SELF-DESTRUCT" will disappear from the screen
        timerFrame.Visible = false
        globalTimerEnabled = false
        timerText.TextSize = 28
    end)
end

--------------------------------------------------------------------------------
-- GLOBAL TIMER DISPLAY: END
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PAUSE / RESUME GLOBAL DISPLAY TIMER
--------------------------------------------------------------------------------

local function pauseDisplayGlobalTimer(player)
    if globalTimerEnabled and not displayGlobalTimerPaused then
        displayGlobalTimerPaused = true
        print("** Global display timer paused **")
    end
end

local function resumeDisplayGlobalTimer(player)
    if globalTimerEnabled and displayGlobalTimerPaused then
        displayGlobalTimerPaused = false
        -- Reset prevTime so we don't subtract the entire paused duration
        prevTime = os.time()
        print("** Global display timer resumed **")
    end
end


function module:init()
    hud.Enabled = true
    topBar.Enabled = true

    -- Hide oxygen and coolant UI elements
    topBar.screenArea.oxygen.Visible = false
    topBar.screenArea.coolant.Visible = false

    signals.re:connect("update_room_info_desc", updateRoomInfoDesc)

    signals.re:connect("update_room_counter_ui", updateRoomCounterUI)
    signals.re:connect("update_stars_counter_ui", updateStarsCounterUI)
    signals.be:connect("update_stars_counter_ui", updateStarsCounterUI)

    signals.re:connect("update_currency_ui", updateCurrency)

    signals.re:connect("display_global_explode_timer", displayGlobalTimer)
    local timerFrame = hud.screenArea.globalTimer
    -- for global timer testing purposes only
    -- timerFrame.Visible = true
    -- timerFrame.header.Visible = true
    -- timerFrame.contentFrame.timerText.Visible = true

    -- Global timer pause/resume
    signals.re:connect("pause_display_global_explode_timer", pauseDisplayGlobalTimer)
    signals.re:connect("resume_display_global_explode_timer", resumeDisplayGlobalTimer)

    -- (Lanxiang notes) deplay star initialization upon --> choosing a difficulty level
    -- Init stars UI
    -- local metadata = signals.rf:fire("fetch_metadata")
    -- if metadata and metadata.stars then
    --    updateStarsCounterUI(metadata.stars)
    -- end
end

return module