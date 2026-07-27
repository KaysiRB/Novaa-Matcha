local BASE = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"
local loaderChunk = loadstring(game:HttpGet(BASE .. "Novaa/Modules/Loader.lua"))
local Loader = loaderChunk()
local Module = { Name = "Gakuran", running = false }

function Module.Start()
    return Loader.Start(Module, BASE .. "Novaa/Gakuran.lua")
end

function Module.Stop()
    -- Gakuran owns its UI lifecycle; reloading the hub does not destroy it.
    Module.running = false
end

return Module
