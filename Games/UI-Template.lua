local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if _G.MM2ESP_Running then
    _G.MM2ESP_Running = false
    if _G.MM2ESP_Cleanup then
        pcall(_G.MM2ESP_Cleanup)
    end
    wait(0.1)
end
_G.MM2ESP_Running = true

local ESP_ENABLED = true
local SHOW_TRACERS = false
local SHOW_DISTANCE = true
local SHOW_GUN_ESP = true
local MAX_DISTANCE = 1000

local COLORS = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 220, 100),
    Gun      = Color3.fromRGB(255, 235, 59),
}

local roleCache = {}
local espObjects = {}
local gunEspObjects = {}

local function destroyDrawingSet(set)
    if not set then return end
    pcall(function() set.box:Remove() end)
    pcall(function() set.nameText:Remove() end)
    pcall(function() set.distText:Remove() end)
    pcall(function() set.tracer:Remove() end)
end

local function getRole(player, character)
    if roleCache[player] and roleCache[player] ~= "Innocent" then
        return roleCache[player]
    end

    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            if tool.Name == "Knife" or tool:FindFirstChild("Knife") then
                roleCache[player] = "Murderer"
                return "Murderer"
            elseif tool.Name == "Gun" or tool:FindFirstChild("Gun") then
                roleCache[player] = "Sheriff"
                return "Sheriff"
            end
        end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then
            roleCache[player] = "Murderer"
            return "Murderer"
        elseif backpack:FindFirstChild("Gun") then
            roleCache[player] = "Sheriff"
            return "Sheriff"
        end
    end

    return "Innocent"
end

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local win = Lib:CreateWindow({
    title = "Novaa - v1.0.0",
    subtitle = "auto",
    logo = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/assets/logo.png",
    menuKey = "LeftControl",
    configName = "MM2",
    configFolder= "Novaa",
    font = "Minecraft",
    size = Vector2.new(700, 540),
    opacity = 98,
    keybindOverlay = false,
    smartFps = false,
    checkboxStyle = true,
})

Lib:ApplyThemePreset("Waifu")
Lib:SetPerformance(true)

win:AddSettingsTab("gear")
Lib:Notify("Novaa", "Press `LeftControl` to toggle the menu", 4, "info")

Lib:Category("Games")
local games = win:Tab("Games", "gamepad")

local gamesSub1 = games:Sub("ESP", "users")
local TeamESP = gamesSub1:Section("ESP", "Full")
local TeamESPtg = TeamESP:Toggle("Team ESP", false, function(value) Lib:Notify("ESP", value, 3, "info") end)

local gamesSub2 = games:Sub("Settings", "cog")

Lib:Notify("Loaded", "Novaa script is ready!", 3, "success")