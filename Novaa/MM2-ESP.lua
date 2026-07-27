local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if _G.MM2ESP_Running then
    _G.MM2ESP_Running = false
    if _G.MM2ESP_Cleanup then
        pcall(_G.MM2ESP_Cleanup)
    end
    wait(0.1)
end
_G.MM2ESP_Running = true

local ESP_ENABLED = true
local SHOW_TRACERS = false
local SHOW_DISTANCE = true
local SHOW_GUN_ESP = true
local MAX_DISTANCE = 1000

local TOGGLE_KEY = 0xA2

local COLORS = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(60, 220, 100),
    Gun      = Color3.fromRGB(255, 235, 59),
}

local roleCache = {}
local espObjects = {}
local gunEspObjects = {}

local function destroyDrawingSet(set)
    if not set then return end
    pcall(function() set.box:Remove() end)
    pcall(function() set.nameText:Remove() end)
    pcall(function() set.distText:Remove() end)
    pcall(function() set.tracer:Remove() end)
end

local function getRole(player, character)
    if roleCache[player] and roleCache[player] ~= "Innocent" then
        return roleCache[player]
    end

    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            if tool.Name == "Knife" or tool:FindFirstChild("Knife") then
                roleCache[player] = "Murderer"
                return "Murderer"
            elseif tool.Name == "Gun" or tool:FindFirstChild("Gun") then
                roleCache[player] = "Sheriff"
                return "Sheriff"
            end
        end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then
            roleCache[player] = "Murderer"
            return "Murderer"
        elseif backpack:FindFirstChild("Gun") then
            roleCache[player] = "Sheriff"
            return "Sheriff"
        end
    end

    return "Innocent"
end

local function updateGunEsp()
    for _, obj in ipairs(gunEspObjects) do
        pcall(function() obj:Remove() end)
    end
    gunEspObjects = {}

    if not ESP_ENABLED or not SHOW_GUN_ESP then
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local cursorPos = Vector2.new(Mouse.X, Mouse.Y)

    for _, item in ipairs(workspace:GetChildren()) do
        if item.Name == "GunDrop" or (item.Name == "Gun" and item:IsA("Tool") and not Players:GetPlayerFromCharacter(item.Parent)) then
            local pos = nil

            if item:IsA("BasePart") then
                pos = item.Position
            elseif item:IsA("Model") then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then pos = part.Position end
            elseif item:IsA("Tool") then
                local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                if handle then pos = handle.Position end
            end

            if pos then
                local screenPos, onScreen = WorldToScreen(pos)
                if onScreen then
                    local dist = myRoot and (myRoot.Position - pos).Magnitude or 0

                    local gunText = Drawing.new("Text")
                    gunText.Center = true
                    gunText.Outline = true
                    gunText.Font = Drawing.Fonts.System
                    pcall(function() gunText.FontSize = 14 end)
                    gunText.Text = string.format("DROPPED GUN [%d studs]", dist)
                    gunText.Position = Vector2.new(screenPos.X, screenPos.Y - 10)
                    gunText.Color = COLORS.Gun
                    gunText.Visible = true

                    local tracer
                    if SHOW_TRACERS then
                        tracer = Drawing.new("Line")
                        tracer.Thickness = 1.5
                        tracer.From = cursorPos
                        tracer.To = screenPos
                        tracer.Color = COLORS.Gun
                        tracer.Visible = true
                    end

                    table.insert(gunEspObjects, gunText)
                    if tracer then table.insert(gunEspObjects, tracer) end
                end
            end
        end
    end
end

local function updateEsp()
    for player, set in pairs(espObjects) do
        destroyDrawingSet(set)
        espObjects[player] = nil
    end

    if not ESP_ENABLED then
        return
    end

    local currentPlayers = Players:GetPlayers()
    local cursorPos = Vector2.new(Mouse.X, Mouse.Y)

    for cachedPlayer in pairs(roleCache) do
        local stillInGame = false
        for _, p in ipairs(currentPlayers) do
            if p == cachedPlayer then
                stillInGame = true
                break
            end
        end
        if not stillInGame then
            roleCache[cachedPlayer] = nil
        end
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(currentPlayers) do
        if player ~= LocalPlayer then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if not humanoid or humanoid.Health <= 0 then
                roleCache[player] = nil
            end

            if character and root and humanoid and humanoid.Health > 0 then
                local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0

                if not myRoot or dist <= MAX_DISTANCE then
                    local headPos, headOnScreen = WorldToScreen(root.Position + Vector3.new(0, 2.5, 0))
                    local feetPos, feetOnScreen = WorldToScreen(root.Position - Vector3.new(0, 3, 0))

                    if headOnScreen and feetOnScreen then
                        local height = feetPos.Y - headPos.Y
                        local width = height * 0.5
                        local topLeft = Vector2.new(headPos.X - width / 2, headPos.Y)

                        local role = getRole(player, character)
                        local color = COLORS[role]

                        local box = Drawing.new("Square")
                        box.Thickness = 2
                        box.Filled = false
                        box.Position = topLeft
                        box.Size = Vector2.new(width, height)
                        box.Color = color
                        box.Visible = true

                        local nameText = Drawing.new("Text")
                        nameText.Center = true
                        nameText.Outline = true
                        nameText.Font = Drawing.Fonts.System
                        pcall(function() nameText.FontSize = 14 end)
                        nameText.Text = player.Name .. " [" .. role .. "]"
                        nameText.Position = Vector2.new(headPos.X, headPos.Y - 16)
                        nameText.Color = color
                        nameText.Visible = true

                        local distText
                        if SHOW_DISTANCE then
                            distText = Drawing.new("Text")
                            distText.Center = true
                            distText.Outline = true
                            distText.Font = Drawing.Fonts.System
                            pcall(function() distText.FontSize = 12 end)
                            distText.Text = string.format("%d studs", dist)
                            distText.Position = Vector2.new(headPos.X, feetPos.Y + 4)
                            distText.Color = Color3.fromRGB(255, 255, 255)
                            distText.Visible = true
                        end

                        local tracer
                        if SHOW_TRACERS then
                            tracer = Drawing.new("Line")
                            tracer.Thickness = 1
                            tracer.From = cursorPos
                            tracer.To = feetPos
                            tracer.Color = color
                            tracer.Visible = true
                        end

                        espObjects[player] = {
                            box = box,
                            nameText = nameText,
                            distText = distText or { Remove = function() end },
                            tracer = tracer or { Remove = function() end },
                        }
                    end
                end
            end
        end
    end
end

local lastToggleState = false
local function handleToggle()
    local pressed = iskeypressed(TOGGLE_KEY)
    if pressed and not lastToggleState then
        ESP_ENABLED = not ESP_ENABLED
        notify(ESP_ENABLED and "ESP Enabled" or "ESP Disabled", "esp", 2)
    end
    lastToggleState = pressed
end

_G.MM2ESP_Cleanup = function()
    for player, set in pairs(espObjects) do
        destroyDrawingSet(set)
        espObjects[player] = nil
    end
    for _, obj in ipairs(gunEspObjects) do
        pcall(function() obj:Remove() end)
    end
    gunEspObjects = {}
    roleCache = {}
end

local RunService = game:GetService("RunService")
local toggleAccumulator = 0

local renderConn
renderConn = RunService.RenderStepped:Connect(function(dt)
    if not _G.MM2ESP_Running then
        renderConn:Disconnect()
        _G.MM2ESP_Cleanup()
        return
    end

    toggleAccumulator = toggleAccumulator + dt
    if toggleAccumulator >= 0.1 then
        toggleAccumulator = 0
        handleToggle()
    end

    updateEsp()
    updateGunEsp()
end)

notify("LeftControl to toggle", "esp made by saph thx np", 3)