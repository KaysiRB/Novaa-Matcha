-- Universal script chargé après le script spécifique au jeu.
-- Interface INS-ui universelle, avec un onglet Misc et un bouton unload.

local Universal = {}

function Universal:init(env)
    self.env = env
    self.env.registerModule("universal", self)
    self.gui = env.createGui and env.createGui("Novaa Universal")
    self.running = true
    self:startLoops()
end

function Universal:startLoops()
    spawn(function()
        while self.running and not self.env.unloadRequested() do
            wait(2)
            -- logique universelle si nécessaire
        end
    end)
end

function Universal:createTabs()
    local tabs = {
        {
            name = "Misc",
            buttons = {
                {label = "Unload All", callback = function()
                    self.env.unloadAll()
                end}
            }
        }
    }
    return tabs
end

function Universal:unload()
    self.running = false
    self.env.unregisterModule("universal")
end

return function(env)
    local script = setmetatable({}, {__index = Universal})
    script:init(env)
    return script
end
