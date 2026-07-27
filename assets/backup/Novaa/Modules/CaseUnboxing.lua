local BASE = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"
local loaderChunk = loadstring(game:HttpGet(BASE .. "Novaa/Modules/Loader.lua"))
local Loader = loaderChunk()
local Module = { Name = "Case Unboxing", running = false }

function Module.Start()
    return Loader.Start(Module, BASE .. "Novaa/Case-Unboxing.lua")
end

function Module.Stop()
    -- The original script has local loop state and no cleanup hook.
    -- Its F1 toggle remains the safe stop control.
    Module.running = false
end

return Module
