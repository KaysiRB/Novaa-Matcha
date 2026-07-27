local Loader = {}

local function read(url)
    local ok, source = pcall(function() return game:HttpGet(url) end)
    return ok and type(source) == "string" and source or nil
end

function Loader.Start(module, path)
    if module.running then return true end
    local source = read(path)
    local compile = loadstring or load
    if not source or type(compile) ~= "function" then return false end
    local ok, chunk = pcall(compile, source, "@" .. path)
    if not ok or type(chunk) ~= "function" then return false end
    module.running = true
    task.spawn(function()
        local ran = pcall(chunk)
        if not ran then module.running = false end
    end)
    return true
end

function Loader.Stop(module, cleanup)
    if cleanup then pcall(cleanup) end
    module.running = false
end

return Loader
