local BASE_URL = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"

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

-- Register exact game IDs here. No object heuristics are used.
local GAMES = {
    -- [YOUR_GAME_ID] = {
    --     Name = "Case Unboxing",
    --     Module = "Novaa/Games/Case-Unboxing.luau",
    -- },
    [66654135] = {
        Name = "Murder Mystery 2",
        Module = "Games/MM2.luau",s
    },
    [2298998220] = {
        Name = "Nothingness",
        Module = "Games/MM2.luau",
    },
    [9199655655] = {
        Name = "Gakuran",
        Module = "Games/Gakuran.luau",
    },
    [1202096104] = {
        Name = "Driving Empire",
        Module = "Games/DrivingEmpire.luau",
    },
}

local gameId = game.GameId
local gameInfo = GAMES[gameId]
local loadedModule

local function startGameModule()
    if not gameInfo then
        log("No module registered for GameId " .. tostring(gameId))
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

local gameIdText = "GameId: " .. tostring(gameId)
log(gameIdText)
log(gameInfo and ("Detected game: " .. gameInfo.Name) or "Unknown game")

startGameModule()
