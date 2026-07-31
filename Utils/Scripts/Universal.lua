log("1")

local function log(message)
    print("[Universal] " .. tostring(message))
end

local Lib = env and (env.Lib or env.lib) or _G.INSui
local win = env and (env.win or env.window) or nil
local cleanup = env and env.cleanup or nil

if type(Lib) ~= "table" or type(win) ~= "table" then
    log("No UI context available")
    return Universal
end

local ok, err = pcall(function()
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
    utilities:Button("Unload", function()
        Lib:Dialog({
            title = "Unload Novaa?",
            text = "This will remove all drawings and close the UI.",
            confirm = "Unload",
            onConfirm = cleanup,
        })
    end):SetRisk()
end)

if not ok then
    log("Failed to build UI: " .. tostring(err))
end