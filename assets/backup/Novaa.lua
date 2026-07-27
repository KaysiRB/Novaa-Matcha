-- Novaa: Matcha module hub for the scripts in C:\matcha\scripts\Novaa

local ROOT = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/Novaa/"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function loadLocal(path)
    local source = game:HttpGet(path)
    local compiler = loadstring or load
    local chunk = compiler(source, "@" .. path)
    return chunk()
end

local function log(text)
    print("[Novaa] " .. tostring(text))
end

local Modules = {
    Gakuran = loadLocal(ROOT .. "Modules/Gakuran.lua"),
    MM2ESP = loadLocal(ROOT .. "Modules/MM2ESP.lua"),
    CaseUnboxing = loadLocal(ROOT .. "Modules/CaseUnboxing.lua"),
}

local function getValue(property)
    local ok, value = pcall(function() return game[property] end)
    return ok and value or nil
end

local function detect()
    local map = workspace:FindFirstChild("Map")
    local hasDrawing = Drawing ~= nil
    local isMM2 = map ~= nil and hasDrawing
    local isCase = workspace:FindFirstChild("Cases") ~= nil
        or workspace:FindFirstChild("Case") ~= nil
        or workspace:FindFirstChild("Unboxing") ~= nil
    return isMM2, isCase
end

local function loadUi()
    if UI then return true end
    local url = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"
    local ok = pcall(function()
        local source = game:HttpGet(url)
        local compiler = loadstring or load
        local chunk = compiler(source, "@NovaaUILib")
        chunk()
    end)
    return ok and UI ~= nil
end

local isMM2, isCase = detect()
log("PlaceId=" .. tostring(getValue("PlaceId")) .. " MM2=" .. tostring(isMM2) .. " Case=" .. tostring(isCase))

if not loadUi() then
    log("UI library unavailable; modules can still be started by changing the flags below")
end

local started = {}
local function setModule(name, enabled)
    local module = Modules[name]
    if not module then return end
    if enabled and not started[name] then
        started[name] = module.Start()
        log(name .. (started[name] and " started" or " failed"))
    elseif not enabled and started[name] then
        module.Stop()
        started[name] = false
        log(name .. " stopped")
    end
end

if UI and UI.AddTab then
    UI.AddTab("Novaa", function(tab)
        local main = tab:Section("Modules", "Left")
        main:Text("PlaceId: " .. tostring(getValue("PlaceId")))
        local g = main:Toggle("novaa_gakuran", "Gakuran", true, function(v) setModule("Gakuran", v) end)
        local m = main:Toggle("novaa_mm2", "MM2 ESP", isMM2, function(v) setModule("MM2ESP", v) end)
        local c = main:Toggle("novaa_case", "Case Unboxing", isCase, function(v) setModule("CaseUnboxing", v) end)
        main:Keybind("novaa_gakuran_key", 0, "toggle")
        main:Text("Case Unboxing also keeps its original F1 control.")

        local actions = tab:Section("Actions", "Right")
        actions:Button("Start Detected Modules", function()
            setModule("Gakuran", true)
            if isMM2 then setModule("MM2ESP", true) end
            if isCase then setModule("CaseUnboxing", true) end
        end)
        actions:Button("Stop MM2 ESP", function() setModule("MM2ESP", false) end)
        actions:Button("Refresh Detection", function()
            isMM2, isCase = detect()
            log("Detection refreshed: MM2=" .. tostring(isMM2) .. " Case=" .. tostring(isCase))
        end)
    end)
end

-- Start Gakuran automatically; game-specific modules are detection driven.
setModule("Gakuran", true)
if isMM2 then setModule("MM2ESP", true) end
if isCase then setModule("CaseUnboxing", true) end

log("ready")
