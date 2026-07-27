local BASE = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"
local loaderChunk = loadstring(game:HttpGet(BASE .. "Novaa/Modules/Loader.lua"))
local Loader = loaderChunk()
local Module = { Name = "MM2 ESP", running = false }

function Module.Start()
    return Loader.Start(Module, BASE .. "Novaa/MM2-ESP.lua")
end

function Module.Stop()
    _G.MM2ESP_Running = false
    if _G.MM2ESP_Cleanup then pcall(_G.MM2ESP_Cleanup) end
    Module.running = false
end

return Module
