local Universal = {}

return function(env)
    local Lib = env and env.Lib or _G.INSui
    local win = env and env.win or nil
    local cleanup = env and env.cleanup or nil

    if not Lib or not win then
        log("No lib")
        return Universal
    end

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

    return Universal
end