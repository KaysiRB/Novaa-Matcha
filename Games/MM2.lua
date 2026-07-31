local BASE_URL = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// ESP SETTINGS
local ESP_ENABLED = false
local SHOW_BOXES = false
local SHOW_NAMES = true
local SHOW_ROLES = true
local SHOW_TRACERS = false
local SHOW_DISTANCE = true
local SHOW_GUN_ESP = true
local SHOW_GUN_DISTANCE = true
local MAX_DISTANCE = 1000
local COLORS = {
	Murderer = Color3.fromRGB(255, 40, 40),
	Sheriff = Color3.fromRGB(60, 140, 255),
	Innocent = Color3.fromRGB(60, 220, 100),
	Gun = Color3.fromRGB(255, 235, 59)
}
local roleCache = {}
local espObjects = {}
local gunEspObjects = {}

--// DRAWING CLEANUP
local function removeDrawing(object)
	if not object then
		return
	end
	pcall(function()
		object:Remove()
	end)
end
local function destroyDrawingSet(set)
	if not set then
		return
	end
	removeDrawing(set.box)
	removeDrawing(set.nameText)
	removeDrawing(set.distText)
	removeDrawing(set.tracer)
end
local function clearPlayerESP()
	for player, set in pairs(espObjects) do
		destroyDrawingSet(set)
		espObjects[player] = nil
	end
end
local function clearGunESP()
	for _, object in ipairs(gunEspObjects) do
		removeDrawing(object)
	end
	gunEspObjects = {}
end

--// MM2 ROLE DETECTION
local function getRole(player, character)
	if roleCache[player] and roleCache[player] ~= "Innocent" then
		return roleCache[player]
	end

    -- Equipped tool
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

    -- Backpack tool
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

--// PLAYER ESP
local function updateESP()
	clearPlayerESP()
	if not ESP_ENABLED then
		return
	end
	local currentPlayers = Players:GetPlayers()
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local cursorPosition = Vector2.new(Mouse.X, Mouse.Y)

    -- Remove players that left from the role cache
	for cachedPlayer in pairs(roleCache) do
		local exists = false
		for _, player in ipairs(currentPlayers) do
			if player == cachedPlayer then
				exists = true
				break
			end
		end
		if not exists then
			roleCache[cachedPlayer] = nil
		end
	end
	for _, player in ipairs(currentPlayers) do
		if player ~= LocalPlayer then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character and root and humanoid and humanoid.Health > 0 then
				local distance = 0
				if localRoot then
					distance = (localRoot.Position - root.Position).Magnitude
				end
				if not localRoot or distance <= MAX_DISTANCE then
					local headPosition, headVisible = WorldToScreen(root.Position + Vector3.new(0, 2.5, 0))
					local feetPosition, feetVisible = WorldToScreen(root.Position - Vector3.new(0, 3, 0))
					if headVisible and feetVisible then
						local height = feetPosition.Y - headPosition.Y
						local width = height * 0.5
						local topLeft = Vector2.new(headPosition.X - width / 2, headPosition.Y)
						local role = getRole(player, character)
						local color = COLORS[role] or Color3.new(1, 1, 1)

                        -- Box
						local box = Drawing.new("Square")
						box.Thickness = 2
						box.Filled = false
						box.Position = topLeft
						box.Size = Vector2.new(width, height)
						box.Color = color
						box.Visible = SHOW_BOXES

                        -- Name and role
						local nameText = Drawing.new("Text")
						nameText.Center = true
						nameText.Outline = true
						nameText.Font = Drawing.Fonts.System
						pcall(function()
							nameText.FontSize = 14
						end)
						local text = ""
						if SHOW_NAMES then
							text = player.Name
						end
						if SHOW_ROLES then
							if text ~= "" then
								text = text .. " "
							end
							text = text .. "[" .. role .. "]"
						end
						nameText.Text = text
						nameText.Position = Vector2.new(headPosition.X, headPosition.Y - 16)
						nameText.Color = color
						nameText.Visible = text ~= ""

                        -- Distance
						local distanceText = Drawing.new("Text")
						distanceText.Center = true
						distanceText.Outline = true
						distanceText.Font = Drawing.Fonts.System
						pcall(function()
							distanceText.FontSize = 12
						end)
						distanceText.Text = string.format("%d studs", distance)
						distanceText.Position = Vector2.new(headPosition.X, feetPosition.Y + 4)
						distanceText.Color = Color3.fromRGB(255, 255, 255)
						distanceText.Visible = SHOW_DISTANCE

                        -- Tracer
						local tracer = Drawing.new("Line")
						tracer.Thickness = 1
						tracer.From = cursorPosition
						tracer.To = feetPosition
						tracer.Color = color
						tracer.Visible = SHOW_TRACERS
						espObjects[player] = {
							box = box,
							nameText = nameText,
							distText = distanceText,
							tracer = tracer
						}
					end
				end
			end
		end
	end
end

--// DROPPED GUN ESP
local function updateGunESP()
	clearGunESP()
	if not ESP_ENABLED then
		return
	end
	if not SHOW_GUN_ESP then
		return
	end
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local cursorPosition = Vector2.new(Mouse.X, Mouse.Y)
	for _, item in ipairs(workspace:GetChildren()) do
		local droppedGun = item.Name == "GunDrop"
		local looseGun = item.Name == "Gun" and item:IsA("Tool") and not Players:GetPlayerFromCharacter(item.Parent)
		if droppedGun or looseGun then
			local position
			if item:IsA("BasePart") then
				position = item.Position
			elseif item:IsA("Model") then
				local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
				if part then
					position = part.Position
				end
			elseif item:IsA("Tool") then
				local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
				if handle then
					position = handle.Position
				end
			end
			if position then
				local screenPosition, visible = WorldToScreen(position)
				if visible then
					local distance = 0
					if root then
						distance = (root.Position - position).Magnitude
					end
					if distance <= MAX_DISTANCE then
						local text = Drawing.new("Text")
						text.Center = true
						text.Outline = true
						text.Font = Drawing.Fonts.System
						pcall(function()
							text.FontSize = 14
						end)
						if SHOW_GUN_DISTANCE then
							text.Text = string.format("DROPPED GUN [%d studs]", distance)
						else
							text.Text = "DROPPED GUN"
						end
						text.Position = Vector2.new(screenPosition.X, screenPosition.Y - 10)
						text.Color = COLORS.Gun
						text.Visible = true
						table.insert(gunEspObjects, text)
						if SHOW_TRACERS then
							local tracer = Drawing.new("Line")
							tracer.Thickness = 1.5
							tracer.From = cursorPosition
							tracer.To = screenPosition
							tracer.Color = COLORS.Gun
							tracer.Visible = true
							table.insert(gunEspObjects, tracer)
						end
					end
				end
			end
		end
	end
end

--// ESP STATE
local espToggle
local function setESPEnabled(value)
	ESP_ENABLED = value == true
	if not ESP_ENABLED then
		clearPlayerESP()
		clearGunESP()
	end
end

--// CLEANUP
_G.MM2ESP_Cleanup = function()
	clearPlayerESP()
	clearGunESP()
	roleCache = {}
end
if _G.MM2ESP_Running then
	_G.MM2ESP_Running = false
	if _G.MM2ESP_Cleanup then
		pcall(_G.MM2ESP_Cleanup)
	end
	task.wait(0.1)
end
_G.MM2ESP_Running = true

--// LOAD UI
local Lib = loadstring(game:HttpGet(BASE_URL.."Utils/Scripts/INS-UI.lua"))() or INSui
local win = Lib:CreateWindow({
	title = "Novaa - v1.0.0",
	subtitle = "auto",
	logo = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/Utils/Logos/Stellar.png",
	menuKey = "LeftControl",
	configName = "MM2",
	configFolder = "Novaa",
	autoSave = true,
	font = "Minecraft",
	size = Vector2.new(700, 540),
	opacity = 98,
	keybindOverlay = false,
	smartFps = false,
	checkboxStyle = true
})
Lib:ApplyThemePreset("Waifu")
win:AddSettingsTab("gear")
Lib:Notify("Novaa", "Press LeftControl to toggle the menu", 4, "info")
Lib:Category("Games")

local function cleanup()
	_G.MM2ESP_Running = false
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	if _G.MM2ESP_Cleanup then
		_G.MM2ESP_Cleanup()
	end
	Lib:Destroy()
end

local function loadUniversalModule()
	local ok, module = pcall(function()
		return loadstring(game:HttpGet(BASE_URL .. "Utils/Scripts/Universal.lua"))()
	end)
	if not ok or type(module) ~= "function" then
		return
	end

	pcall(module, {
		Lib = Lib,
		win = win,
		cleanup = cleanup,
	})
end

--// GAME INFO
local gameInfoTab = win:Tab("Game", "gamepad")
local gameInfo = gameInfoTab:Section("Game Info", "Full", "Information about the current game")
gameInfo:Label("Game: " .. getgamename())
gameInfo:Label("Place: " .. game.Name)
gameInfo:Label("GameID: " .. game.GameId)
gameInfo:Label("PlaceID: " .. game.PlaceId)
gameInfo:Label("JobID: " .. game.JobId)

--// MM2 ESP
local espTab = win:Tab("ESP", "users")
local mm2ESP = espTab:Section("MM2 ESP", "Full", "Murderer, Sheriff, Innocent and dropped gun")
espToggle = mm2ESP:Toggle("Enabled", ESP_ENABLED, function(value)
	setESPEnabled(value)
	Lib:Notify("MM2 ESP", ESP_ENABLED and "Enabled" or "Disabled", 2, ESP_ENABLED and "success" or "warning")
end)
espToggle:AddKeybind("O", "Toggle")
mm2ESP:Divider("Players")
mm2ESP:Toggle("Boxes", SHOW_BOXES, function(value)
	SHOW_BOXES = value
end)
mm2ESP:Toggle("Names", SHOW_NAMES, function(value)
	SHOW_NAMES = value
end)
mm2ESP:Toggle("Roles", SHOW_ROLES, function(value)
	SHOW_ROLES = value
end)
mm2ESP:Toggle("Distance", SHOW_DISTANCE, function(value)
	SHOW_DISTANCE = value
end)
mm2ESP:Toggle("Tracers", SHOW_TRACERS, function(value)
	SHOW_TRACERS = value
end)
mm2ESP:Slider("Maximum distance", MAX_DISTANCE, 25, 50, 5000, " studs", function(value)
	MAX_DISTANCE = value
end)
mm2ESP:Divider("Dropped gun")
mm2ESP:Toggle("Gun ESP", SHOW_GUN_ESP, function(value)
	SHOW_GUN_ESP = value
	if not value then
		clearGunESP()
	end
end)
mm2ESP:Toggle("Gun distance", SHOW_GUN_DISTANCE, function(value)
	SHOW_GUN_DISTANCE = value
end)

--// MM2 COLORS
local gameSettingsTab = win:Tab("Game Settings", "cog")
local roleColors = gameSettingsTab:Section("MM2 Colors", "Full", "Role and dropped-gun colors")
roleColors:Colorpicker("Murderer", COLORS.Murderer, function(color)
	COLORS.Murderer = color
end)
roleColors:Colorpicker("Sheriff", COLORS.Sheriff, function(color)
	COLORS.Sheriff = color
end)
roleColors:Colorpicker("Innocent", COLORS.Innocent, function(color)
	COLORS.Innocent = color
end)
roleColors:Colorpicker("Dropped gun", COLORS.Gun, function(color)
	COLORS.Gun = color
end)

--// Universal
loadUniversalModule()

--// ESP LOOP
local renderConnection
local espTick = 0
renderConnection = RunService.RenderStepped:Connect(function(dt)
	if not _G.MM2ESP_Running then
		if renderConnection then
			renderConnection:Disconnect()
			renderConnection = nil
		end
		if _G.MM2ESP_Cleanup then
			_G.MM2ESP_Cleanup()
		end
		return
	end
	espTick += dt
	if espTick >= 0.15 then
		espTick = 0
		updateESP()
		updateGunESP()
	end
end)

--// LOAD CONFIG LAST
win:autoloadConfig("MM2")
Lib:Notify("Loaded", "Novaa script is ready!", 3, "success")