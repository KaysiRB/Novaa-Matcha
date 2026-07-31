local BASE_URL = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"
local Players = game:GetService("Players")
local SCRIPT_GEN = tostring(os.clock()) .. ":" .. tostring(math.random())
_G.DELIVERY_FARM_GEN = SCRIPT_GEN
local CONFIG = {
    W_KEY = 0x57,
    PICKUP_WAIT = 10,
    DROPOFF_WAIT = 1,
    HEIGHT = 3,
    PRIVACY_HEIGHT = - 10,
    APPROACH = 35,
    OUTSIDE_HOLD = 0.75,
    MIN_GAIN = 1,
    ANTI_AFK_EVERY = 3,
    TOGGLE_KEY = "F1",
}
local state = {
    enabled = false,
    privacy = true,
    busy = false,
    lastToggle = 0,
}
local stats = {
    startedAt = os.clock(),
    activeStart = nil,
    activeSecs = 0,
    startBal = nil,
    currBal = nil,
    lastBal = nil,
    lastTick = 0,
    totalGain = 0,
    posGain = 0,
    lastGain = 0,
    largestGain = 0,
    payouts = 0,
    targetVisits = 0,
    pickups = 0,
    dropoffs = 0,
    fails = 0,
    lastPayout = nil,
    samples = {},
}
local function comma(v)
    v = tonumber(v) or 0
    local s = tostring(math.floor(math.abs(v) + 0.5))
    while true do
        local n, c = s:gsub("^(%d+)(%d%d%d)", "%1,%2")
        s = n
        if c == 0 then
            break
        end
    end
    return (v < 0 and "-" or "") .. s
end
local function fmtMoney(v)
    return "$" .. comma(v)
end
local function fmtDur(s)
    s = math.max(0, math.floor(tonumber(s) or 0))
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, sec)
    end
    return string.format("%02d:%02d", m, sec)
end
local function perHr(g, s)
    s = tonumber(s) or 0
    if s <= 0 then
        return 0
    end
    return (tonumber(g) or 0) / s * 3600
end
local function getPlayer()
    return Players.LocalPlayer
end
local function isDeliveryDriver(p)
    local t = p and p.Team
    return t and t.Name == "Delivery Driver"
end
local function getRoot(p)
    local c = p and p.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid(p)
    local c = p and p.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getTarget()
    return workspace:FindFirstChild("DeliveryTargetAnchor")
end
local function heightOffset()
    return state.privacy and CONFIG.PRIVACY_HEIGHT or CONFIG.HEIGHT
end
local function getCashObj(p)
    p = p or getPlayer()
    if not p then
        return nil
    end
    local gui = p:FindFirstChild("PlayerGui")
    if not gui then
        return nil
    end
    local exact = gui:FindFirstChild(p.Name .. "'s Stats")
    if exact then
        local c = exact:FindFirstChild("Cash")
        if c and (c:IsA("IntValue") or c:IsA("NumberValue")) then
            return c
        end
    end
    for _, child in ipairs(gui:GetChildren()) do
        if child.Name:find("Stats", 1, true) then
            local c = child:FindFirstChild("Cash")
            if c and (c:IsA("IntValue") or c:IsA("NumberValue")) then
                return c
            end
        end
    end
    return nil
end
local function readCash()
    local c = getCashObj()
    if not c then
        return nil
    end
    local ok, v = pcall(function()
        return tonumber(c.Value)
    end)
    return ok and v or nil
end
local function pruneSamples(t, now, window)
    local cutoff = now - window
    while # t > 2 and t[1].t < cutoff do
        table.remove(t, 1)
    end
end
local function addSample(now, bal)
    stats.samples[# stats.samples + 1] = {
        t = now,
        cash = bal
    }
    pruneSamples(stats.samples, now, 600)
end
local function estPH(window)
    local now = os.clock()
    local first, last = nil, nil
    for _, s in ipairs(stats.samples) do
        if s.t >= now - window then
            first = first or s
            last = s
        end
    end
    if not first or not last or last.t <= first.t then
        return 0
    end
    return perHr(last.cash - first.cash, last.t - first.t)
end
local function avgPayout()
    if stats.payouts <= 0 then
        return 0
    end
    return stats.posGain / stats.payouts
end
local function computeGain()
    local gain = stats.totalGain
    if stats.currBal and stats.startBal then
        gain = stats.currBal - stats.startBal
    end
    return gain
end
local function activeTime()
    local a = stats.activeSecs
    if state.enabled and stats.activeStart then
        a = a + (os.clock() - stats.activeStart)
    end
    return a
end
local function updateCash(force)
    local now = os.clock()
    if not force and now - stats.lastTick < 1 then
        return
    end
    stats.lastTick = now
    local bal = readCash()
    if not bal then
        return
    end
    stats.currBal = bal
    if not stats.startBal then
        stats.startBal = bal
        stats.lastBal = bal
        addSample(now, bal)
        return
    end
    if stats.lastBal == nil then
        stats.lastBal = bal
    end
    local delta = bal - stats.lastBal
    stats.totalGain = bal - stats.startBal
    if delta >= CONFIG.MIN_GAIN then
        stats.lastGain = delta
        stats.posGain = stats.posGain + delta
        stats.payouts = stats.payouts + 1
        stats.lastPayout = now
        if delta > stats.largestGain then
            stats.largestGain = delta
        end
    end
    stats.lastBal = bal
    addSample(now, bal)
end
local function resetStats()
    local now = os.clock()
    local bal = readCash()
    stats.startedAt = now
    stats.activeStart = state.enabled and now or nil
    stats.activeSecs = 0
    stats.startBal = bal
    stats.currBal = bal
    stats.lastBal = bal
    stats.lastTick = 0
    stats.totalGain = 0
    stats.posGain = 0
    stats.lastGain = 0
    stats.largestGain = 0
    stats.payouts = 0
    stats.targetVisits = 0
    stats.pickups = 0
    stats.dropoffs = 0
    stats.fails = 0
    stats.lastPayout = nil
    stats.samples = {}
    if bal then
        addSample(now, bal)
    end
end
local afkCount = 0
local function antiAfk(p)
    local h = getHumanoid(p)
    pcall(function()
        if h then
            h.Jump = true
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    pcall(function()
        if type(keypress) == "function" and type(keyrelease) == "function" then
            keypress(CONFIG.W_KEY)
            task.wait(0.08)
            keyrelease(CONFIG.W_KEY)
        end
    end)
end
local function horizontalApproach(pos, target)
    local dx = pos.X - target.X
    local dz = pos.Z - target.Z
    local len = math.sqrt(dx * dx + dz * dz)
    if len < 0.01 then
        dx, dz, len = 0, 1, 1
    end
    return Vector3.new(
		target.X + (dx / len) * CONFIG.APPROACH, target.Y + heightOffset(), target.Z + (dz / len) * CONFIG.APPROACH)
end
local function holdPos(root, pos, dur)
    local z = Vector3.new(0, 0, 0)
    local deadline = os.clock() + dur
    while os.clock() < deadline do
        if _G.DELIVERY_FARM_GEN ~= SCRIPT_GEN then
            return
        end
        root.Position = pos
        root.Velocity = z
        task.wait()
    end
end
local function holdHeight(root, targetPos, dur)
    local z = Vector3.new(0, 0, 0)
    local h = Vector3.new(0, heightOffset(), 0)
    local deadline = os.clock() + dur
    while os.clock() < deadline do
        if _G.DELIVERY_FARM_GEN ~= SCRIPT_GEN then
            return
        end
        root.Position = targetPos + h
        root.Velocity = z
        task.wait()
    end
end
local function moveAcross(root, targetPos)
    local outside = horizontalApproach(root.Position, targetPos)
    local inside = targetPos + Vector3.new(0, heightOffset(), 0)
    local z = Vector3.new(0, 0, 0)
    for _ = 1, 10 do
        if _G.DELIVERY_FARM_GEN ~= SCRIPT_GEN then
            return
        end
        root.Position = outside
        root.Velocity = z
        task.wait()
    end
    holdPos(root, outside, CONFIG.OUTSIDE_HOLD)
    for step = 1, 30 do
        if _G.DELIVERY_FARM_GEN ~= SCRIPT_GEN then
            return
        end
        local a = step / 30
        root.Position = outside + (inside - outside) * a
        root.Velocity = z
        task.wait(0.05)
    end
    holdHeight(root, targetPos, 0.2)
end
local function teleport()
    local player = getPlayer()
    if not isDeliveryDriver(player) then
        state.enabled = false
        if stats.activeStart then
            stats.activeSecs = stats.activeSecs + (os.clock() - stats.activeStart)
            stats.activeStart = nil
        end
        win:Notify("Delivery Farm", "Not on Delivery Driver team", 4, "warning")
        return
    end
    local root = getRoot(player)
    local target = getTarget()
    if not root or not target then
        return
    end
    stats.targetVisits = stats.targetVisits + 1
    local balBefore = stats.currBal or readCash() or stats.lastBal
    local tPos = target.Position
    moveAcross(root, tPos)
    holdHeight(root, tPos, 0.35)
    updateCash(true)
    local balAfter = stats.currBal or readCash() or balBefore
    local delta = (balAfter and balBefore) and (balAfter - balBefore) or 0
    local isDropoff = delta >= CONFIG.MIN_GAIN
    if isDropoff then
        stats.dropoffs = stats.dropoffs + 1
        afkCount = afkCount + 1
    else
        stats.pickups = stats.pickups + 1
    end
    holdHeight(root, tPos, isDropoff and CONFIG.DROPOFF_WAIT or CONFIG.PICKUP_WAIT)
    if isDropoff and afkCount >= CONFIG.ANTI_AFK_EVERY then
        afkCount = 0
        antiAfk(player)
    end
end

local Lib = loadstring(game:HttpGet(BASE_URL.."Utils/Scripts/INS-UI.lua"))() or INSui
local win = Lib:CreateWindow({
    title = "Novaa - v1.0.0",
    subtitle = "auto",
    logo = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/Utils/Logos/Stellar.png",
    menuKey = "LeftControl",
    configName = "DrivingEmpire",
    configFolder = "Novaa",
    autoSave = true,
    font = "Minecraft",
    size = Vector2.new(700, 540),
    opacity = 98,
    keybindOverlay = false,
    smartFps = false,
    checkboxStyle = true,
})
win:ApplyThemePreset("Waifu")
win:AddSettingsTab("gear")
win:Notify("Novaa", "Press LeftControl to toggle the menu", 4, "info")
win:Category("Games")

local function cleanup()
    _G.DELIVERY_FARM_GEN = ""
    win:Destroy()
end

local function loadUniversalModule()
    local ok, module = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. "Utils/Scripts/Universal.lua"))()
    end)
    if not ok or type(module) ~= "function" then
        return
    end

    pcall(module, {
        Lib = Lib,
        win = win,
        cleanup = cleanup,
    })
end

local function toggleFarm()
    if os.clock() - state.lastToggle < 0.3 then
        return
    end
    state.lastToggle = os.clock()
    state.enabled = not state.enabled
    local now = os.clock()
    if state.enabled then
        stats.activeStart = now
        win:Notify("Delivery Farm", "Autofarm enabled", 3, "success")
    elseif stats.activeStart then
        stats.activeSecs = stats.activeSecs + (now - stats.activeStart)
        stats.activeStart = nil
        win:Notify("Delivery Farm", "Autofarm disabled", 3, "success")
    end
end

--// GAME INFO
local giTab = win:Tab("Game", "gamepad")
local giSec = giTab:Section("Game Info", "Full", "Session information")
giSec:Label("Game: " .. getgamename())
giSec:Label("Place: " .. game.Name)
giSec:Label("PlaceID: " .. game.PlaceId)
giSec:Label("JobID: " .. game.JobId)

--// AUTOFARM
local afTab = win:Tab("Autofarm", "gamepad")
local afSec = afTab:Section("Autofarm", "Full", "Delivery Driver auto-farm")
local farmToggle = afSec:Toggle("Farm Deliveries", state.enabled, function(v)
    if v and not state.enabled then
        toggleFarm()
    elseif not v and state.enabled then
        toggleFarm()
    end
end)
farmToggle:AddKeybind(CONFIG.TOGGLE_KEY, "Toggle"):Tooltip("Press " .. CONFIG.TOGGLE_KEY .. " to toggle farming")
afSec:Toggle("Privacy Mode", state.privacy, function(v)
    state.privacy = v == true
end):Tooltip("Enable noclip")
afSec:Divider("Farm Stats")
local statLabels = {}
local function createStatsUI()
    statLabels.status = afSec:Label(function()
        return "Status: " .. (state.enabled and "Running" or "Paused")
    end)
    statLabels.runtime = afSec:Label(function()
        return "Runtime: " .. fmtDur(os.clock() - stats.startedAt)
    end)
    statLabels.active = afSec:Label(function()
        return "Active: " .. fmtDur(activeTime())
    end)
    afSec:Divider()
    statLabels.cashMade = afSec:Label(function()
        return "Cash Made: " .. fmtMoney(computeGain())
    end)
    statLabels.balance = afSec:Label(function()
        return "Balance: " .. fmtMoney(stats.currBal or stats.startBal or 0)
    end)
    statLabels.lastGain = afSec:Label(function()
        return "Last Gain: " .. fmtMoney(stats.lastGain)
    end)
    statLabels.payouts = afSec:Label(function()
        return "Payouts: " .. comma(stats.payouts)
    end)
    statLabels.avgPayout = afSec:Label(function()
        return "Avg/Payout: " .. fmtMoney(avgPayout())
    end)
    afSec:Divider()
    statLabels.estHr = afSec:Label(function()
        return "EST/hr: " .. fmtMoney(estPH(60))
    end)
    statLabels.pickups = afSec:Label(function()
        return "Pickups: " .. comma(stats.pickups)
    end)
    statLabels.dropoffs = afSec:Label(function()
        return "Dropoffs: " .. comma(stats.dropoffs)
    end)
    statLabels.fails = afSec:Label(function()
        return "Fails: " .. comma(stats.fails)
    end)
    statLabels.largestGain = afSec:Label(function()
        return "Largest Gain: " .. fmtMoney(stats.largestGain)
    end)
    statLabels.targetVisits = afSec:Label(function()
        return "Target Visits: " .. comma(stats.targetVisits)
    end)
    afSec:Divider()
    afSec:Button("Reset Stats", function()
        resetStats()
        win:Notify("Farm Stats", "Stats reset", 2, "info")
    end)
end
local function updateStats()
    if statLabels.status then
        statLabels.status:Set("Status: " .. (state.enabled and "Running" or "Paused"))
    end
    if statLabels.runtime then
        statLabels.runtime:Set("Runtime: " .. fmtDur(os.clock() - stats.startedAt))
    end
    if statLabels.active then
        statLabels.active:Set("Active: " .. fmtDur(activeTime()))
    end
    if statLabels.cashMade then
        statLabels.cashMade:Set("Cash Made: " .. fmtMoney(computeGain()))
    end
    if statLabels.balance then
        statLabels.balance:Set("Balance: " .. fmtMoney(stats.currBal or stats.startBal or 0))
    end
    if statLabels.lastGain then
        statLabels.lastGain:Set("Last Gain: " .. fmtMoney(stats.lastGain))
    end
    if statLabels.payouts then
        statLabels.payouts:Set("Payouts: " .. comma(stats.payouts))
    end
    if statLabels.avgPayout then
        statLabels.avgPayout:Set("Avg/Payout: " .. fmtMoney(avgPayout()))
    end
    if statLabels.estHr then
        statLabels.estHr:Set("EST/hr: " .. fmtMoney(estPH(60)))
    end
    if statLabels.pickups then
        statLabels.pickups:Set("Pickups: " .. comma(stats.pickups))
    end
    if statLabels.dropoffs then
        statLabels.dropoffs:Set("Dropoffs: " .. comma(stats.dropoffs))
    end
    if statLabels.fails then
        statLabels.fails:Set("Fails: " .. comma(stats.fails))
    end
    if statLabels.largestGain then
        statLabels.largestGain:Set("Largest Gain: " .. fmtMoney(stats.largestGain))
    end
    if statLabels.targetVisits then
        statLabels.targetVisits:Set("Target Visits: " .. comma(stats.targetVisits))
    end
end
createStatsUI()

--// Universal
loadUniversalModule()

win:autoloadConfig("DrivingEmpire")
win:Notify("Novaa", "Script is ready!", 3, "success")
task.spawn(function()
    while _G.DELIVERY_FARM_GEN == SCRIPT_GEN do
        updateCash(false)
        updateStats()
        if state.enabled and not state.busy then
            state.busy = true
            local ok, err = pcall(teleport)
            state.busy = false
            if not ok then
                stats.fails = stats.fails + 1
                state.enabled = false
                if stats.activeStart then
                    stats.activeSecs = stats.activeSecs + (os.clock() - stats.activeStart)
                    stats.activeStart = nil
                end
                win:Notify("Delivery Farm", tostring(err), 5, "warning")
            end
        end
        task.wait(0.03)
    end
end)