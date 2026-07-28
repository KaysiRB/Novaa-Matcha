local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// AUTOPLAY SETTINGS
local AUTOPLAY_ENABLED = false
local SHOW_ESP = false
local SHOW_HIT_LINE = true
local SHOW_CIRCLES = true
local SHOW_HOLD_TAILS = true
local AUTO_DETECT_LANES = true
local REQUIRE_GAME_FOCUS = true
local DEBUG_LOGGING = false
local ACTIVE_LANE_COUNT = 4
local CURRENT_KEYS = {
    88,
    67,
    78,
    77,
}
local LANE_ENABLED = {
    true,
    true,
    true,
    true
}
local LANE_REFRESH_INTERVAL = 0.5
local SCALE_UPDATE_INTERVAL = 0.25
local CONFIG = {
    HOLD_MIN_H = 20,
    TAP_HOLD_SEC = 0.05,
    TOUCH_DIST = 30,
    PAST_CATCH = 30,
    APPROACH_DIST = 300,
    MIN_DIST_X = 100,
    LINE_THICK = 4,
    CIRCLE_RADIUS = 20,
    CIRCLE_SIDES = 48,
    CIRCLE_THICK = 2,
    TAIL_THICK = 5,
    MAX_CIRCLES = 8,
    LANE_COLORS = {
        Color3.fromRGB(180, 255, 180),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(100, 220, 100),
        Color3.fromRGB(60, 180, 60),
    },
    COLOR_ON_LINE = Color3.fromRGB(255, 255, 255),
    COLOR_HOLD = Color3.fromRGB(150, 255, 150),
    COLOR_APPROACH = Color3.fromRGB(100, 130, 100),
    LINE_COLOR = Color3.fromRGB(255, 255, 255),
}

--// AUTO-GREEN SETTINGS
local AUTO_GREEN_ENABLED = false
local SHOOT_KEY = 70
local RELEASE_TARGET = 0.274
local DETECT_THRESHOLD = 0.95
local SHOT_TIMEOUT = 3
local shotCount = 0
local shotState = "idle"
local shotStartTime = 0

--// AUTOPLAY STATE
local tapHeld = {}
local tapReleaseAt = {}
local holdActive = {}
local holdStartAt = {}
local seenNotes = {}
local lanesValid = false
local laneData = nil
local notesContainer = nil
local espScale = 1
local lastLaneRefresh = 0
local lastScaleUpdate = 0
local lastCleanupTime = 0
local CLEANUP_INTERVAL = 0.02

--// DRAWINGS
local hitLine = Drawing.new("Line")
hitLine.Color = CONFIG.LINE_COLOR
hitLine.Thickness = CONFIG.LINE_THICK
hitLine.Visible = false
hitLine.ZIndex = 5
local circles = {}
local tails = {}
for lane = 1, 4 do
    circles[lane] = {}
    tails[lane] = {}
    seenNotes[lane] = {}
    for i = 1, CONFIG.MAX_CIRCLES do
        local circle = Drawing.new("Circle")
        circle.NumSides = CONFIG.CIRCLE_SIDES
        circle.Radius = CONFIG.CIRCLE_RADIUS
        circle.Thickness = CONFIG.CIRCLE_THICK
        circle.Filled = false
        circle.Visible = false
        circle.ZIndex = 10
        circles[lane][i] = circle
        local tail = Drawing.new("Line")
        tail.Thickness = CONFIG.TAIL_THICK
        tail.Visible = false
        tail.ZIndex = 9
        tails[lane][i] = tail
    end
end

--// HELPERS
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end
local function debugLog(message, ...)
    if DEBUG_LOGGING then
        print(string.format(message, ...))
    end
end
local function isLaneEnabled(lane)
    return LANE_ENABLED[lane] ~= false
end

--// DRAWING CLEANUP
local function removeDrawing(object)
    if not object then
        return
    end
    pcall(function()
        object:Remove()
    end)
end
local function hideESP()
    hitLine.Visible = false
    for lane = 1, 4 do
        for i = 1, CONFIG.MAX_CIRCLES do
            circles[lane][i].Visible = false
            tails[lane][i].Visible = false
        end
    end
end
local function clearDrawings()
    removeDrawing(hitLine)
    for lane = 1, 4 do
        for i = 1, CONFIG.MAX_CIRCLES do
            removeDrawing(circles[lane][i])
            removeDrawing(tails[lane][i])
        end
    end
end
local function releaseAllKeys()
    for lane = 1, 4 do
        if CURRENT_KEYS[lane] then
            keyrelease(CURRENT_KEYS[lane])
        end
        tapHeld[lane] = false
        holdActive[lane] = nil
        holdStartAt[lane] = 0
        seenNotes[lane] = {}
    end
    if shotState ~= "idle" then
        keyrelease(SHOOT_KEY)
        shotState = "idle"
    end
end

--// RHYTHM UI
local function isRhythmUIGone()
    local playerGui = safeCall(function()
        return LocalPlayer.PlayerGui
    end)
    if not playerGui then
        return true
    end
    local rhythmUI = safeCall(function()
        return playerGui:FindFirstChild("RhythmServiceUI")
    end)
    return not rhythmUI
end
local function refreshLanes()
    local playerGui = safeCall(function()
        return LocalPlayer.PlayerGui
    end)
    if not playerGui then
        return false
    end
    local rhythmUI = safeCall(function()
        return playerGui:FindFirstChild("RhythmServiceUI")
    end)
    if not rhythmUI then
        return false
    end
    local rhythmRoot = safeCall(function()
        return rhythmUI:FindFirstChild("RhythmRoot")
    end)
    if not rhythmRoot then
        return false
    end
    local lanesFrame = safeCall(function()
        return rhythmRoot:FindFirstChild("Lanes")
    end)
    local receptors = safeCall(function()
        return rhythmRoot:FindFirstChild("Receptors")
    end)
    if not receptors or not lanesFrame then
        return false
    end
    notesContainer = lanesFrame
    local receptorsFound = {}
    local count = 0
    for i = 1, 4 do
        local receptor = safeCall(function()
            return receptors:FindFirstChild("Receptor" .. i)
        end)
        if receptor then
            local pos = safeCall(function()
                return receptor.AbsolutePosition
            end)
            local size = safeCall(function()
                return receptor.AbsoluteSize
            end)
            if pos and size then
                receptorsFound[i] = {
                    inst = receptor,
                    cx = pos.X + size.X / 2,
                    cy = pos.Y + size.Y / 2,
                    hitY = pos.Y + size.Y / 2,
                }
                count += 1
            end
        end
    end
    if count == 0 then
        return false
    end
    ACTIVE_LANE_COUNT = count
    if AUTO_DETECT_LANES and ACTIVE_LANE_COUNT == 2 then
        CURRENT_KEYS = {
            70,
            74
        }
    else
        CURRENT_KEYS = {
            88,
            67,
            78,
            77
        }
        ACTIVE_LANE_COUNT = 4
    end
    laneData = receptorsFound
    local camera = Workspace.CurrentCamera
    local scale = 1
    if camera then
        scale = camera.ViewportSize.Y / 1080
    end
    local leftCx = (receptorsFound[1] and receptorsFound[1].cx or 0) - 50 * scale
    local rightCx = (receptorsFound[ACTIVE_LANE_COUNT] and receptorsFound[ACTIVE_LANE_COUNT].cx or 0) + 50 * scale
    local hitY = receptorsFound[1].hitY
    hitLine.From = Vector2.new(leftCx, hitY)
    hitLine.To = Vector2.new(rightCx, hitY)
    if AUTOPLAY_ENABLED and SHOW_ESP then
        hitLine.Visible = true
    end
    lanesValid = true
    return true
end
local function cleanupStaleNotes()
    local now = os.clock()
    if now - lastCleanupTime < CLEANUP_INTERVAL then
        return
    end
    lastCleanupTime = now
    for lane = 1, 4 do
        local laneNotes = seenNotes[lane]
        for note in pairs(laneNotes) do
            if not safeCall(function()
                return note.Parent
            end) then
                laneNotes[note] = nil
            end
        end
    end
end

--// AUTO-GREEN
local function getBasketballMeter()
    local playerName = safeCall(function()
        return LocalPlayer.Name
    end)
    if not playerName then
        return nil
    end
    local player = safeCall(function()
        return Workspace.Players:FindFirstChild(playerName)
    end)
    local character = player and safeCall(function()
        return player:FindFirstChild("HumanoidRootPart")
    end)
    local attach = character and safeCall(function()
        return character:FindFirstChild("BasketballShotMeterAttach")
    end)
    local billboard = attach and safeCall(function()
        return attach:FindFirstChild("BasketballShotBillboard")
    end)
    local root = billboard and safeCall(function()
        return billboard:FindFirstChild("Root")
    end)
    local meter = root and safeCall(function()
        return root:FindFirstChild("Meter")
    end)
    return meter
end
local function getNeedleProgress(meter)
    local needle = safeCall(function()
        return meter:FindFirstChild("Needle")
    end)
    if not needle then
        return nil
    end
    local needlePos = safeCall(function()
        return needle.AbsolutePosition
    end)
    local needleSize = safeCall(function()
        return needle.AbsoluteSize
    end)
    local meterPos = safeCall(function()
        return meter.AbsolutePosition
    end)
    local meterSize = safeCall(function()
        return meter.AbsoluteSize
    end)
    if not needlePos or not needleSize or not meterPos or not meterSize or meterSize.Y <= 0 then
        return nil
    end
    local needleCenterY = needlePos.Y + needleSize.Y / 2
    local progress = (needleCenterY - meterPos.Y) / meterSize.Y
    return math.clamp(progress, 0, 1)
end
local function updateAutoGreen(now)
    if not AUTO_GREEN_ENABLED then
        return
    end
    local meter = getBasketballMeter()
    local needle = meter and safeCall(function()
        return meter:FindFirstChild("Needle")
    end)
    if not meter or not needle then
        if shotState ~= "idle" then
            debugLog("[Shot #%d] ended (meter gone)", shotCount)
            shotState = "idle"
        end
        return
    end
    local progress = getNeedleProgress(meter)
    if not progress then
        return
    end
    if shotState == "idle" then
        if progress > DETECT_THRESHOLD then
            shotState = "tracking"
            shotStartTime = now
            shotCount += 1
            debugLog("[Shot #%d] detected at %.2f%%", shotCount, progress * 100)
        end
    elseif shotState == "tracking" then
        if progress <= RELEASE_TARGET then
            shotState = "idle"
            debugLog("[Shot #%d] RELEASE at %.2f%% (target %.2f%%)", shotCount, progress * 100, RELEASE_TARGET * 100)
            keyrelease(SHOOT_KEY)
        elseif progress <= 0.01 then
            debugLog("[Shot #%d] RELEASE at %.2f%% (reached top)", shotCount, progress * 100)
            keyrelease(SHOOT_KEY)
            shotState = "idle"
        elseif now - shotStartTime > SHOT_TIMEOUT then
            debugLog("[Shot #%d] RELEASE at %.2f%% (timeout)", shotCount, progress * 100)
            keyrelease(SHOOT_KEY)
            shotState = "idle"
        end
    end
end

--// AUTOPLAY
local function updateAutoplay(now)
    if not AUTOPLAY_ENABLED then
        hideESP()
        return
    end
    if now - lastScaleUpdate >= SCALE_UPDATE_INTERVAL then
        lastScaleUpdate = now
        local camera = Workspace.CurrentCamera
        if camera then
            espScale = camera.ViewportSize.Y / 1080
        end
    end
    if now - lastLaneRefresh >= LANE_REFRESH_INTERVAL then
        lastLaneRefresh = now
        if lanesValid then
            if isRhythmUIGone() then
                lanesValid = false
                hideESP()
                releaseAllKeys()
            end
        else
            refreshLanes()
        end
    end
    if not lanesValid or not laneData then
        return
    end
    if SHOW_ESP and SHOW_HIT_LINE then
        hitLine.Thickness = CONFIG.LINE_THICK * espScale
        hitLine.Visible = true
    else
        hitLine.Visible = false
    end
    for lane = 1, 4 do
        for i = 1, CONFIG.MAX_CIRCLES do
            circles[lane][i].Visible = false
            tails[lane][i].Visible = false
        end
    end
    for lane = 1, ACTIVE_LANE_COUNT do
        if not isLaneEnabled(lane) then
            continue
        end
        local key = CURRENT_KEYS[lane]
        if tapHeld[lane] and now >= tapReleaseAt[lane] then
            keyrelease(key)
            tapHeld[lane] = false
        end
        if holdActive[lane] then
            local hold = holdActive[lane]
            local invalid = false
            local parent = safeCall(function()
                return hold.inst.Parent
            end)
            if not parent then
                invalid = true
            else
                local head = safeCall(function()
                    return hold.inst:FindFirstChild("Head")
                end)
                if not head then
                    invalid = true
                else
                    local headPos = safeCall(function()
                        return head.AbsolutePosition
                    end)
                    local headSize = safeCall(function()
                        return head.AbsoluteSize
                    end)
                    if not headPos or not headSize then
                        invalid = true
                    else
                        local headY = headPos.Y + headSize.Y / 2
                        local tail = safeCall(function()
                            return hold.inst:FindFirstChild("Tail")
                        end)
                        local tailH = tail and safeCall(function()
                            return tail.AbsoluteSize.Y
                        end) or 0
                        local catchY = laneData[lane].hitY
                        if tailH < 2 or headY - tailH >= catchY then
                            invalid = true
                        end
                    end
                end
            end
            if invalid then
                keyrelease(key)
                holdActive[lane] = nil
                holdStartAt[lane] = 0
            end
        end
    end
    cleanupStaleNotes()
    local children = safeCall(function()
        return notesContainer:GetChildren()
    end)
    if not children then
        return
    end
    local notesByLane = {
        {},
        {},
        {},
        {},
    }
    for _, note in ipairs(children) do
        if safeCall(function()
            return note.ClassName
        end) ~= "Frame" then
            continue
        end
        if safeCall(function()
            return note.Name
        end) ~= "NoteTemplate" then
            continue
        end
        local head = safeCall(function()
            return note:FindFirstChild("Head")
        end)
        if not head then
            continue
        end
        local headPos = safeCall(function()
            return head.AbsolutePosition
        end)
        local headSize = safeCall(function()
            return head.AbsoluteSize
        end)
        if not headPos or not headSize then
            continue
        end
        local headCX = headPos.X + headSize.X / 2
        local headCY = headPos.Y + headSize.Y / 2
        local nearestLane = nil
        local nearestDist = math.huge
        for lane = 1, ACTIVE_LANE_COUNT do
            if not laneData[lane] or not isLaneEnabled(lane) then
                continue
            end
            local dist = math.abs(headCX - laneData[lane].cx)
            if dist < nearestDist then
                nearestDist = dist
                nearestLane = lane
            end
        end
        if not nearestLane or nearestDist > CONFIG.MIN_DIST_X then
            continue
        end
        local laneNotes = seenNotes[nearestLane]
        if laneNotes[note] then
            if not safeCall(function()
                return note.Parent
            end) then
                laneNotes[note] = nil
            end
            continue
        end
        local catchY = laneData[nearestLane].hitY
        local distToLine = headCY - catchY
        if distToLine > CONFIG.PAST_CATCH then
            laneNotes[note] = true
            continue
        end
        if distToLine < - CONFIG.APPROACH_DIST then
            continue
        end
        local tail = safeCall(function()
            return note:FindFirstChild("Tail")
        end)
        local tailH = tail and safeCall(function()
            return tail.AbsoluteSize.Y
        end) or 0
        local isHold = tailH > CONFIG.HOLD_MIN_H
        table.insert(notesByLane[nearestLane], {
            note = note,
            headCY = headCY,
            dist = distToLine,
            isHold = isHold,
            tailH = tailH,
        })
    end
    for lane = 1, ACTIVE_LANE_COUNT do
        if not isLaneEnabled(lane) then
            continue
        end
        local key = CURRENT_KEYS[lane]
        if not laneData[lane] then
            continue
        end
        local laneCX = laneData[lane].cx
        local laneNotes = notesByLane[lane]
        local seen = seenNotes[lane]
        table.sort(laneNotes, function(a, b)
            return a.headCY < b.headCY
        end)
        for i, noteInfo in ipairs(laneNotes) do
            if i > CONFIG.MAX_CIRCLES then
                break
            end
            local onLine = noteInfo.dist >= - CONFIG.TOUCH_DIST and noteInfo.dist <= CONFIG.PAST_CATCH
            if SHOW_ESP then
                local circle = circles[lane][i]
                local tail = tails[lane][i]
                local color
                if onLine then
                    color = CONFIG.COLOR_ON_LINE
                elseif noteInfo.dist < - CONFIG.TOUCH_DIST then
                    local t = 1 - math.abs(noteInfo.dist) / CONFIG.APPROACH_DIST
                    local laneColor = CONFIG.LANE_COLORS[lane]
                    color = Color3.new(
						CONFIG.COLOR_APPROACH.R + (laneColor.R - CONFIG.COLOR_APPROACH.R) * t, CONFIG.COLOR_APPROACH.G + (laneColor.G - CONFIG.COLOR_APPROACH.G) * t, CONFIG.COLOR_APPROACH.B + (laneColor.B - CONFIG.COLOR_APPROACH.B) * t)
                else
                    color = noteInfo.isHold and CONFIG.COLOR_HOLD or CONFIG.LANE_COLORS[lane]
                end
                if SHOW_CIRCLES then
                    circle.Color = color
                    circle.Radius = CONFIG.CIRCLE_RADIUS * espScale
                    circle.Thickness = CONFIG.CIRCLE_THICK * espScale
                    circle.Filled = noteInfo.isHold and not onLine
                    circle.Position = Vector2.new(laneCX, noteInfo.headCY)
                    circle.Visible = true
                end
                if SHOW_HOLD_TAILS and noteInfo.isHold and noteInfo.tailH > 0 then
                    tail.From = Vector2.new(laneCX, noteInfo.headCY)
                    tail.To = Vector2.new(laneCX, noteInfo.headCY - noteInfo.tailH)
                    tail.Thickness = CONFIG.TAIL_THICK * espScale
                    tail.Color = color
                    tail.Visible = true
                end
            end
            if onLine and not tapHeld[lane] and not holdActive[lane] then
                seen[noteInfo.note] = true
                if noteInfo.isHold then
                    keypress(key)
                    holdActive[lane] = {
                        inst = noteInfo.note,
                        tailH = noteInfo.tailH,
                    }
                    holdStartAt[lane] = now
                else
                    keypress(key)
                    tapHeld[lane] = true
                    tapReleaseAt[lane] = now + CONFIG.TAP_HOLD_SEC
                end
                break
            end
        end
    end
end

--// STATE
local autoplayToggle
local autoGreenToggle
local function setAutoplayEnabled(value)
    AUTOPLAY_ENABLED = value == true
    if not AUTOPLAY_ENABLED then
        releaseAllKeys()
        hideESP()
        lanesValid = false
    end
end
local function setShowESP(value)
    SHOW_ESP = value == true
    if not SHOW_ESP then
        hideESP()
    end
end
local function setAutoGreenEnabled(value)
    AUTO_GREEN_ENABLED = value == true
    if not AUTO_GREEN_ENABLED and shotState ~= "idle" then
        keyrelease(SHOOT_KEY)
        shotState = "idle"
    end
end

--// CLEANUP
_G.Gakuran_Cleanup = function()
    releaseAllKeys()
    hideESP()
    clearDrawings()
    lanesValid = false
    laneData = nil
    notesContainer = nil
    shotState = "idle"
end
if _G.Gakuran_Running then
    _G.Gakuran_Running = false
    if _G.Gakuran_Cleanup then
        pcall(_G.Gakuran_Cleanup)
    end
    task.wait(0.1)
end
_G.Gakuran_Running = true

--// LOAD UI
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui
local win = Lib:CreateWindow({
    title = "Novaa - v1.0.0",
    subtitle = "auto",
    logo = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/Utils/Logos/Stellar.png",
    menuKey = "LeftControl",
    configName = "Gakuran",
    configFolder = "Novaa",
    autoSave = true,
    font = "Minecraft",
    size = Vector2.new(700, 540),
    opacity = 98,
    keybindOverlay = false,
    smartFps = false,
    checkboxStyle = true,
})
Lib:ApplyThemePreset("Waifu")
win:AddSettingsTab("gear")
Lib:Notify("Novaa", "Press LeftControl to toggle the menu", 4, "info")
Lib:Category("Games")

--// GAME INFO
local gameInfoTab = win:Tab("Game", "gamepad")
local gameInfo = gameInfoTab:Section("Game Info", "Full", "Information about the current game")
gameInfo:Label("Game: " .. getgamename())
gameInfo:Label("Place: " .. game.Name)
gameInfo:Label("GameID: " .. game.GameId)
gameInfo:Label("PlaceID: " .. game.PlaceId)
gameInfo:Label("JobID: " .. game.JobId)

--// AUTOPLAY
local autoplayTab = win:Tab("Autoplay", "sparkles")
local autoplaySection = autoplayTab:Section("Gakuran Autoplay", "Full", "Automatic rhythm note inputs and visual overlay")
autoplayToggle = autoplaySection:Toggle("Enabled", AUTOPLAY_ENABLED, function(value)
    setAutoplayEnabled(value)
    Lib:Notify("Gakuran Autoplay", AUTOPLAY_ENABLED and "Enabled" or "Disabled", 2, AUTOPLAY_ENABLED and "success" or "warning")
end)
autoplayToggle:AddKeybind("P", "Toggle")
autoplaySection:Divider("Visuals")
autoplaySection:Toggle("Show ESP", SHOW_ESP, function(value)
    setShowESP(value)
end)
autoplaySection:Toggle("Hit line", SHOW_HIT_LINE, function(value)
    SHOW_HIT_LINE = value
    if not SHOW_HIT_LINE then
        hitLine.Visible = false
    end
end)
autoplaySection:Toggle("Note circles", SHOW_CIRCLES, function(value)
    SHOW_CIRCLES = value
end)
autoplaySection:Toggle("Hold tails", SHOW_HOLD_TAILS, function(value)
    SHOW_HOLD_TAILS = value
end)
autoplaySection:Slider("Circle radius", CONFIG.CIRCLE_RADIUS, 1, 5, 50, " px", function(value)
    CONFIG.CIRCLE_RADIUS = value
end)
autoplaySection:Slider("Line thickness", CONFIG.LINE_THICK, 1, 1, 10, " px", function(value)
    CONFIG.LINE_THICK = value
end)
autoplaySection:Slider("Max notes shown", CONFIG.MAX_CIRCLES, 1, 1, 16, "", function(value)
    CONFIG.MAX_CIRCLES = math.floor(value)
end)
autoplaySection:Divider("Timing")
autoplaySection:Slider("Tap hold duration", CONFIG.TAP_HOLD_SEC * 1000, 1, 10, 200, " ms", function(value)
    CONFIG.TAP_HOLD_SEC = value / 1000
end)
autoplaySection:Slider("Touch distance", CONFIG.TOUCH_DIST, 1, 5, 80, " px", function(value)
    CONFIG.TOUCH_DIST = value
end)
autoplaySection:Slider("Past catch window", CONFIG.PAST_CATCH, 1, 5, 80, " px", function(value)
    CONFIG.PAST_CATCH = value
end)
autoplaySection:Slider("Approach distance", CONFIG.APPROACH_DIST, 10, 50, 600, " px", function(value)
    CONFIG.APPROACH_DIST = value
end)
autoplaySection:Slider("Lane match tolerance", CONFIG.MIN_DIST_X, 5, 25, 250, " px", function(value)
    CONFIG.MIN_DIST_X = value
end)
autoplaySection:Slider("Hold min height", CONFIG.HOLD_MIN_H, 1, 5, 80, " px", function(value)
    CONFIG.HOLD_MIN_H = value
end)
autoplaySection:Slider("Lane refresh rate", LANE_REFRESH_INTERVAL * 1000, 50, 100, 2000, " ms", function(value)
    LANE_REFRESH_INTERVAL = value / 1000
end)
autoplaySection:Divider("Lanes")
autoplaySection:Toggle("Auto-detect lane count", AUTO_DETECT_LANES, function(value)
    AUTO_DETECT_LANES = value
    lanesValid = false
end)
for lane = 1, 4 do
    autoplaySection:Toggle("Lane " .. lane, LANE_ENABLED[lane], function(value)
        LANE_ENABLED[lane] = value
        if not value and tapHeld[lane] then
            keyrelease(CURRENT_KEYS[lane])
            tapHeld[lane] = false
        end
        if not value and holdActive[lane] then
            keyrelease(CURRENT_KEYS[lane])
            holdActive[lane] = nil
        end
    end)
end

--// AUTO-GREEN
local autoGreenTab = win:Tab("Auto-Green", "target")
local autoGreenSection = autoGreenTab:Section("Gakuran Auto-Green", "Full", "Automatic perfect basketball shot timing")
autoGreenToggle = autoGreenSection:Toggle("Enabled", AUTO_GREEN_ENABLED, function(value)
    setAutoGreenEnabled(value)
    Lib:Notify("Gakuran Auto-Green", AUTO_GREEN_ENABLED and "Enabled" or "Disabled", 2, AUTO_GREEN_ENABLED and "success" or "warning")
end)
autoGreenToggle:AddKeybind("G", "Toggle")
autoGreenSection:Slider("Release target %", RELEASE_TARGET * 100, 0.1, 10, 80, "%", function(value)
    RELEASE_TARGET = value / 100
    Lib:Notify("Auto-Green", "Release target: " .. value .. "%", 2, "info")
end)
autoGreenSection:Slider("Detect threshold %", DETECT_THRESHOLD * 100, 0.5, 80, 99, "%", function(value)
    DETECT_THRESHOLD = value / 100
end)
autoGreenSection:Slider("Shot timeout", SHOT_TIMEOUT, 0.5, 1, 8, " s", function(value)
    SHOT_TIMEOUT = value
end)
autoGreenSection:Slider("Shoot key code", SHOOT_KEY, 1, 65, 90, "", function(value)
    SHOOT_KEY = math.floor(value)
end)
autoGreenSection:Info("The release target % controls when the shot is released.\n\n" .. "Slide UP = releases earlier (higher %)\n" .. "Slide DOWN = releases later (lower %)\n\n" .. "Different in-game heights may need slight adjustments to hit 100% perfects consistently. " .. "Start around 27-28% and tweak from there.")

--// GAME SETTINGS
local gameSettingsTab = win:Tab("Game Settings", "cog")
local rhythmColors = gameSettingsTab:Section("Gakuran Colors", "Full", "Autoplay visual colors")
rhythmColors:Colorpicker("Hit line", CONFIG.LINE_COLOR, function(color)
    CONFIG.LINE_COLOR = color
    hitLine.Color = color
end)
rhythmColors:Colorpicker("Circle", CONFIG.LANE_COLORS[1], function(color)
    CONFIG.LANE_COLORS[1] = color
    CONFIG.LANE_COLORS[2] = color
    CONFIG.LANE_COLORS[3] = color
    CONFIG.LANE_COLORS[4] = color
end)
rhythmColors:Colorpicker("Hold note", CONFIG.COLOR_HOLD, function(color)
    CONFIG.COLOR_HOLD = color
end)
rhythmColors:Colorpicker("On-line note", CONFIG.COLOR_ON_LINE, function(color)
    CONFIG.COLOR_ON_LINE = color
end)
rhythmColors:Colorpicker("Approach note", CONFIG.COLOR_APPROACH, function(color)
    CONFIG.COLOR_APPROACH = color
end)
rhythmColors:Divider("Per-lane colors")
for lane = 1, 4 do
    rhythmColors:Colorpicker("Lane " .. lane, CONFIG.LANE_COLORS[lane], function(color)
        CONFIG.LANE_COLORS[lane] = color
    end)
end
local rhythmAdvanced = gameSettingsTab:Section("Gakuran Advanced", "Full", "Miscellaneous script behavior")
rhythmAdvanced:Toggle("Require game focus", REQUIRE_GAME_FOCUS, function(value)
    REQUIRE_GAME_FOCUS = value
end)
rhythmAdvanced:Toggle("Debug logging", DEBUG_LOGGING, function(value)
    DEBUG_LOGGING = value
end)
rhythmAdvanced:Slider("Circle thickness", CONFIG.CIRCLE_THICK, 1, 1, 8, " px", function(value)
    CONFIG.CIRCLE_THICK = value
end)
rhythmAdvanced:Slider("Tail thickness", CONFIG.TAIL_THICK, 1, 1, 12, " px", function(value)
    CONFIG.TAIL_THICK = value
end)
Lib:Category("Universal")

--// VISUALS
local visuals = win:Tab("Visuals", "eye")
local universalVisuals = visuals:Section("Universal Visuals", "Full", "Features shared between supported games")
universalVisuals:Info("Universal visual features will be added here.")
universalVisuals:Toggle("Watermark", false)
universalVisuals:Toggle("FPS counter", false)

--// PLAYER
local playerTab = win:Tab("Player", "user")
local movement = playerTab:Section("Movement", "Full", "Universal player settings")
movement:Info("Universal movement features will be added here.")

--// MISC
local misc = win:Tab("Misc", "three-dots-horizontal")
local utilities = misc:Section("Utilities", "Full")
utilities:Button("Refresh lanes", function()
    lanesValid = false
    refreshLanes()
    Lib:Notify("Novaa", "Lanes refreshed", 1, "success")
end)
utilities:Button("Release all keys", function()
    releaseAllKeys()
    Lib:Notify("Novaa", "All keys released", 1, "success")
end)
utilities:Button("Reset shot counter", function()
    shotCount = 0
    shotState = "idle"
    Lib:Notify("Novaa", "Shot counter reset", 1, "success")
end)
utilities
	:Button("Unload", function()
    Lib:Dialog({
        title = "Unload Novaa?",
        text = "This will remove all drawings and close the UI.",
        confirm = "Unload",
        onConfirm = function()
            _G.Gakuran_Running = false
            if renderConnection then
                renderConnection:Disconnect()
                renderConnection = nil
            end
            if _G.Gakuran_Cleanup then
                _G.Gakuran_Cleanup()
            end
            Lib:Destroy()
        end,
    })
end)
	:SetRisk()

--// MAIN LOOP
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not _G.Gakuran_Running then
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        if _G.Gakuran_Cleanup then
            _G.Gakuran_Cleanup()
        end
        return
    end
    if REQUIRE_GAME_FOCUS and not isrbxactive() then
        return
    end
    local now = os.clock()
    updateAutoplay(now)
    updateAutoGreen(now)
end)

--// LOAD CONFIG LAST
win:autoloadConfig("Gakuran")
Lib:Notify("Loaded", "Novaa script is ready!", 3, "success")