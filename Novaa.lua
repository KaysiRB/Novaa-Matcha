local BASE_URL = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"
local UNIVERSAL_MODULE = "Utils/Scripts/Universal.lua"
local INS_UI_MODULE = "Utils/Scripts/INS-UI.lua"

local GAMES = {
    [66654135] = {Name = "Murder Mystery 2", Module = "Games/MM2.luau"},
    [9199655655] = {Name = "Gakuran", Module = "Games/Gakuran.luau"},
    [1202096104] = {Name = "Driving Empire", Module = "Games/DrivingEmpire.luau"},
}

local LOCAL_FILE_SUPPORT = type(isfile) == "function" and type(readfile) == "function"

local scriptDir
if debug and debug.getinfo then
    local source = debug.getinfo(1, "S").source
    if type(source) == "string" and source:sub(1, 1) == "@" then
        scriptDir = source:sub(2):match("^(.*)[/\\][^/\\]+$")
    end
end

local function normalizeLocalPath(path)
    local localPath = path
    if localPath:sub(-5) == ".luau" then
        localPath = localPath:sub(1, -5) .. ".lua"
    end
    return localPath
end

local function absoluteScriptPath(relative)
    if not scriptDir or not relative then
        return nil
    end
    relative = relative:gsub("/", "\\")
    return scriptDir .. "\\" .. relative
end

local function localPathCandidates(path)
    local normalized = normalizeLocalPath(path)
    local candidates = {normalized}

    if normalized:match("^Games/") then
        table.insert(candidates, "Games/" .. normalized:sub(7))
        table.insert(candidates, "./" .. normalized)
        local abs = absoluteScriptPath(normalized)
        if abs then
            table.insert(candidates, abs)
        end
    elseif normalized:match("^Utils/") then
        table.insert(candidates, "./" .. normalized)
        local abs = absoluteScriptPath(normalized)
        if abs then
            table.insert(candidates, abs)
        end
    end

    return candidates
end

local function readLocalSource(path)
    if not LOCAL_FILE_SUPPORT then
        return nil, "local filesystem unavailable"
    end

    for _, candidate in ipairs(localPathCandidates(path)) do
        if isfile(candidate) then
            local ok, contents = pcall(readfile, candidate)
            if ok and type(contents) == "string" and contents ~= "" then
                return contents
            end
            return nil, contents or "failed to read local file"
        end
    end

    return nil, "local file not found"
end

local Loader = {
    modules = {},
    unloadRequested = false,
}

local function log(message)
    print("[NovaaLoader] " .. tostring(message))
end

local function httpGet(url)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and body ~= "" then
        return body
    end
    if http and http.request then
        local response = http.request({
            Url = url,
            Method = "GET",
        })
        if response and response.StatusCode == 200 and type(response.Body) == "string" then
            return response.Body
        end
        return nil, response and response.StatusMessage or "HTTP request failed"
    end
    return nil, body
end

local sharedEnv = type(shared) == "table" and shared or {}

local function setGlobal(name, value)
    pcall(function()
        getgenv()[name] = value
    end)
    pcall(function()
        _G[name] = value
    end)
    pcall(function()
        sharedEnv[name] = value
    end)
end

local function createEnv(loader)
    local env = {
        game = game,
        Loader = loader,
        BaseUrl = BASE_URL,
        IsUnloadRequested = function()
            return loader.unloadRequested
        end,
        RequestUnload = function()
            loader:Unload()
        end,
        RegisterModule = function(name, module)
            loader.modules[name] = module
        end,
        UnregisterModule = function(name)
            loader.modules[name] = nil
        end,
    }
    return setmetatable(env, {__index = _G})
end

local function compileSource(source, name, env)
    local compiler = loadstring or load
    if type(compiler) ~= "function" then
        return nil, "loadstring unavailable"
    end

    local chunk, err
    if compiler == load and env then
        chunk, err = compiler(source, name, "t", env)
    else
        chunk, err = compiler(source, name)
        if chunk and env and setfenv then
            setfenv(chunk, env)
        end
    end

    if not chunk then
        return nil, err
    end

    return chunk
end

local function loadRemote(path, env)
    local source, err = readLocalSource(path)
    if not source then
        local url = BASE_URL .. path
        source, err = httpGet(url)
        if not source then
            return nil, "HTTP failed: " .. tostring(err)
        end
    end

    local chunk, compileErr = compileSource(source, "@" .. path, env)
    if not chunk then
        return nil, compileErr
    end

    local ok, result = pcall(chunk)
    if not ok then
        return nil, result
    end

    if type(result) == "function" then
        local ok2, module = pcall(result, env)
        if not ok2 then
            return nil, module
        end
        result = module
    end

    if result == nil then
        result = true
    end
    return result
end

function Loader:LoadGameModule(gameId)
    local info = GAMES[gameId]
    if not info then
        return false, "No module registered for GameId " .. tostring(gameId)
    end

    log("Detected game: " .. info.Name .. " (" .. tostring(gameId) .. ")")
    local allowedEnv = createEnv(self)
    local module, err = loadRemote(info.Module, allowedEnv)
    if err then
        return false, err
    end

    self.modules.Game = module
    if type(module) == "table" and type(module.Start) == "function" then
        local ok, startErr = pcall(module.Start, module)
        if not ok then
            return false, startErr
        end
    end

    return true
end

function Loader:LoadInsUIModule()
    log("Loading INS-UI module")
    local allowedEnv = createEnv(self)
    local module, err = loadRemote(INS_UI_MODULE, allowedEnv)
    if not module then
        return false, err
    end

    self.modules.InsUI = module
    setGlobal("INSui", module)
    return true
end

function Loader:LoadUniversalModule()
    log("Loading universal module")
    local allowedEnv = createEnv(self)
    local module, err = loadRemote(UNIVERSAL_MODULE, allowedEnv)
    if not module then
        return false, err
    end

    self.modules.Universal = module
    if type(module.Start) == "function" then
        local ok, startErr = pcall(module.Start, module)
        if not ok then
            return false, startErr
        end
    end

    return true
end

function Loader:Unload()
    if self.unloadRequested then
        return
    end

    log("Unload requested")
    self.unloadRequested = true

    for name, module in pairs(self.modules) do
        if type(module.Unload) == "function" then
            pcall(module.Unload, module)
        elseif type(module.unload) == "function" then
            pcall(module.unload, module)
        end
    end

    self.modules = {}
    self.unloadRequested = false
end

function Loader:Start()
    setGlobal("NovaaLoader", self)

    local gameId = game.GameId or game.PlaceId
    if not gameId then
        log("Impossible de détecter le GameId")
        return
    end

    local ok, err = self:LoadGameModule(gameId)
    if not ok then
        log("Game module failed: " .. tostring(err))
    end

    local insOk, insErr = self:LoadInsUIModule()
    if not insOk then
        log("INS-UI module failed: " .. tostring(insErr))
    end

    local uniOk, uniErr = self:LoadUniversalModule()
    if not uniOk then
        log("Universal module failed: " .. tostring(uniErr))
    end

    log("Loader ready")
end

return Loader