-- Novaa main loader: exact PlaceId -> game module selection.

local BASE_URL = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"
local UI_URL = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"

local function log(message)
    print("[Novaa] " .. tostring(message))
end

local function httpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" and body ~= "" then return body end
    return nil, body
end

local function runSource(source, name)
    local compiler = loadstring or load
    if type(compiler) ~= "function" then return nil, "loadstring unavailable" end
    local okCompile, chunk = pcall(compiler, source, name)
    if not okCompile or type(chunk) ~= "function" then return nil, chunk end
    local okRun, result = pcall(chunk)
    if not okRun then return nil, result end
    return result
end

local function loadRemote(url, name)
    local source, requestError = httpGet(url)
    if not source then return nil, "HTTP failed: " .. tostring(requestError) end
    return runSource(source, name)
end

local function getPlaceId()
    local ok, value = pcall(function() return game.PlaceId end)
    return ok and tonumber(value) or 0
end

-- Register exact game IDs here. No object heuristics are used.
local GAMES = {
    [142823291] = {
        Name = "Murder Mystery 2",
        Module = "Novaa/Games/MM2.lua",
    },
    -- [YOUR_CASE_PLACE_ID] = {
    --     Name = "Case Unboxing",
    --     Module = "Novaa/Games/Case-Unboxing.lua",
    -- },
}

local placeId = getPlaceId()
local gameInfo = GAMES[placeId]
local loadedModule

local function startGameModule()
    if not gameInfo then
        log("No module registered for PlaceId " .. tostring(placeId))
        return false
    end
    if loadedModule then return true end

    local result, err = loadRemote(BASE_URL .. gameInfo.Module, "@" .. gameInfo.Module)
    if result == nil and err then
        log("Module failed: " .. tostring(err))
        return false
    end

    loadedModule = result or true
    if type(result) == "table" and type(result.Start) == "function" then
        local ok, startError = pcall(result.Start, result)
        if not ok then
            log("Module start failed: " .. tostring(startError))
            loadedModule = nil
            return false
        end
    end
    log("Loaded " .. gameInfo.Name)
    return true
end

local placeText = "PlaceId: " .. tostring(placeId)
log(placeText)
log(gameInfo and ("Detected game: " .. gameInfo.Name) or "Unknown game")

if not UI then
    local _, uiError = loadRemote(UI_URL, "@NovaaUILib")
    if uiError and not UI then log("UI library failed: " .. tostring(uiError)) end
end

if UI and UI.AddTab then
    UI.AddTab("Novaa", function(tab)
        local info = tab:Section("Game Detection", "Left")
        info:Text(placeText)
        info:Text("Game: " .. (gameInfo and gameInfo.Name or "Unsupported"))
        info:Toggle("novaa_game_enabled", "Load game module", false, function(value)
            if value and not startGameModule() then
                UI.SetValue("novaa_game_enabled", false)
            end
        end)

        local actions = tab:Section("Actions", "Right")
        actions:Button("Load Detected Game", function()
            if startGameModule() then UI.SetValue("novaa_game_enabled", true) end
        end)
        actions:Text("Modules are selected by exact PlaceId.")
    end)
else
    log("Novaa menu unavailable")
end

log("ready")
