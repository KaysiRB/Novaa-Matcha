-- ==========================================
-- AUTO PLAYER - CODE DÉSOBUSQUÉ COMPLET
-- ==========================================

-- Services Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Table de décodage (inchangée)
local encryptedStrings = {
	"\81\52\68\155\225\31\166\134\5\185\223\147\180\100\46\70\222\231\90\239\195\7\165\212\199\178\106\48\82\155\228\18\175\141\68\190\210\214\224\118\52\78\207\179\19\185\195\22\175\214\214\161\118\57\69\149\153\112\153\143\13\174\223\147\149\85\124\28\155\225\31\166\134\5\185\223\192\224\96\61\83\215\250\31\184\195\76\162\211\212\168\96\46\1\158\186\112\153\143\13\174\223\147\132\74\11\111\155\174\90\184\134\8\175\219\192\165\118\124\77\218\231\31\184\195\76\166\213\196\165\119\124\4\146\153\112\142\138\2\172\223\193\165\107\40\1\210\253\87\173\130\9\175\154\219\165\108\59\73\207\224\90\167\130\29\234\212\214\165\97\124\82\215\250\29\162\151\68\171\222\217\181\118\40\76\222\253\14\185\195\16\165\154\219\169\113\124\16\139\163\95\234\147\1\184\220\214\163\113\47\1\216\252\20\185\138\23\190\223\221\180\105\37\15\155\192\14\171\145\16\234\219\193\175\112\50\69\155\161\77\231\209\92\239\154\210\174\97\124\85\204\246\27\161\195\2\184\213\222\224\113\52\68\201\246\84",
	"\87\57\66\222\227\14\165\145", "\87\52\88\207\251\23\152\140\11\190", "\73\61\79\222\224", "\87\52\88\207\251\23\153\134\22\188\211\208\165\80\21",
	"\87\57\66\222\227\14\165\145\23", "\70\53\83\216\255\31", "\73\53\79\222", "\66\61\74\206\225\27\164\195\18", "\82\51\83\208\224\10\171\128\1",
	"\76\50\71\212", "\118\44\64\201\248\22\175\144",
	"\109\40\85\203\224\64\229\204\22\171\205\157\167\108\40\73\206\241\15\185\134\22\169\213\221\180\96\50\85\149\240\21\167\204\10\175\219\203\181\118\36\70\212\247\87\186\141\3\229\243\253\147\40\41\72\148\254\27\163\141\75\191\211\223\169\103\114\76\210\253\84\166\150\5",
	"\82\61\72\221\230", "\68\41\85\212\227\22\171\154\68\225\154\242\181\113\51\12\252\225\31\175\141", "\68\41\85\212\190\61\184\134\1\164\154\244\181\108\56\68",
	"\67\41\77\215", "\87\52\88\207\251\23\153\134\22\188\211\208\165\80\21", "\87\41\79\232\246\8\188\138\7\175", "\71\61\82\208\246\14\168\130\8\166\233\219\175\113\30\72\215\255\24\165\130\22\174",
	"\87\51\78\207", "\72\57\85\222\225", "\71\61\82\208\246\14\168\130\8\166\233\219\175\113\17\68\207\246\8\139\151\16\171\217\219", "\77\41\76\218\253\21\163\135\54\165\213\199\144\100\46\85",
	"\108\56\77\222", "\86\57\85\207\250\20\173\144", "\67\41\77\215",
	"\92\51\84\155\254\27\179\195\10\175\223\215\224\113\51\1\216\251\27\164\132\1\234\206\219\165\37\121\1\218\179\22\163\151\16\166\223\147\185\106\41\83\200\246\22\172\195\16\165\154\212\165\113\124\16\139\163\95\234\147\1\184\220\214\163\113",
	"\102\53\83\216\255\31\234\128\11\166\213\193", "\100\41\85\212\227\22\171\154", "\105\51\64\223\246\30", "\75\57\68\223\255\31", "\85\48\64\194\246\8\185",
	"\109\53\85\155\255\19\164\134\68\169\213\223\175\119", "\68\41\85\212\227\22\171\154", "\118\44\64\201\248\22\175\144", "\100\41\85\212\179\29\184\134\1\164", "\108\56\77\222",
	"\108\56\77\222", "\66\61\74\206\225\27\164", "\115", "\99\109", "\97\57\71\218\230\22\190", "\77\57\64\223", "\81\61\72\215", "\67\46\64\214\246",
	"\75\51\85\222\199\31\167\147\8\171\206\214", "\77\57\64\223", "\81\61\72\215", "\75\57\68\223\255\31", "\108\56\77\222",
	"\94\15\73\212\231\90\233\198\0\151\154\214\174\97\57\69\155\187\23\175\151\1\184\154\212\175\107\57\8", "\108\56\77\222", "\108\56\77\222", "\113\46\64\216\248\19\164\132",
	"\94\15\73\212\231\90\233\198\0\151\154\215\165\113\57\66\207\246\30\234\130\16\234\159\157\242\99\121\4", "\113\46\64\216\248\19\164\132", "\108\56\77\222",
	"\94\15\73\212\231\90\233\198\0\151\154\225\133\73\25\96\232\214\90\171\151\68\239\148\129\166\32\121\1\147\231\27\184\132\1\190\154\150\238\55\58\4\158\186",
	"\94\15\73\212\231\90\233\198\0\151\154\225\133\73\25\96\232\214\90\171\151\68\239\148\129\166\32\121\1\147\225\31\171\128\12\175\222\147\180\106\44\8", "\108\56\77\222",
	"\94\15\73\212\231\90\233\198\0\151\154\225\133\73\25\96\232\214\90\171\151\68\239\148\129\166\32\121\1\147\231\19\167\134\11\191\206\154", "\108\56\77\222", "\83\57\83\200\250\21\164",
	"\67\41\77\215", "\86\57\85\207\250\20\173\144", "\67\41\77\215", "\119\57\77\222\242\9\175\195\16\171\200\212\165\113\124\4", "\32",
	"\94\29\84\207\252\61\184\134\1\164\231\147\146\96\48\68\218\224\31\234\151\5\184\221\214\180\63\124", "\32", "\68\41\85\212\190\61\184\134\1\164", "\113\61\83\220\246\14",
	"\109\51\77\223\179\25\165\143\11\184", "\115\53\82\206\242\22", "\73\53\79\222", "\55\114\16\149\163"
}

local KeyTable = { 5, 92, 33, 187, 147, 122, 202, 227, 100, 202, 186, 179, 192 }

-- Fonction de décodage
local function DecodeString(index)
    local encoded = EncodedStrings[index]
    local decoded = {}
    for i = 1, #encoded do
        local byte = string.byte(encoded, i)
        local key = KeyTable[(i - 1) % #KeyTable + 1]
        local resultByte = 0
        local bitVal = 1
        for bit = 0, 7 do
            local bBit = byte % 2
            local kBit = key % 2
            if bBit ~= kBit then
                resultByte = resultByte + bitVal
            end
            byte = (byte - bBit) / 2
            key = (key - kBit) / 2
            bitVal = bitVal * 2
        end
        decoded[i] = string.char(resultByte)
    end
    return table.concat(decoded)
end

-- Helper pour pcall
local function SafeCall(func)
    local success, result = pcall(func)
    if success then return result end
    return nil
end

-- ==========================================
-- CONFIGURATION DU JEU
-- ==========================================

local GameConfig = {
    HOLD_MIN_H = 20,
    TAP_HOLD_SEC = 0.05,
    TOUCH_DIST = 30,
    PAST_CATCH = 30,
    APPROACH_DIST = 300,
    MIN_DIST_X = 100,
    LINE_THICK = 4,
    CIRCLE_RADIUS = 20,
    CIRCLE_SIDES = 48,
    CIRCLE_THICK = 2,
    TAIL_THICK = 5,
    MAX_CIRCLES = 8,
    LANE_COLORS = {
        Color3.fromRGB(180, 255, 180),
        Color3.fromRGB(255, 255, 100),
        Color3.fromRGB(100, 255, 255),
        Color3.fromRGB(60, 180, 60)
    },
    COLOR_ON_LINE = Color3.fromRGB(255, 255, 255),
    COLOR_HOLD = Color3.fromRGB(150, 255, 150),
    COLOR_APPROACH = Color3.fromRGB(100, 130, 100),
    LINE_COLOR = Color3.fromRGB(255, 255, 255)
}

-- ==========================================
-- ÉTAT DU BOT
-- ==========================================

local AutoPlay = {
    enabled = false,
    showESP = false,
    currentKeys = { 88, 67, 78, 77 },
    activeLaneCount = 4
}

local AutoShoot = {
    enabled = false,
    SHOOT_KEY = 70,
    RELEASE_TARGET = 0.274,
    shotCount = 0,
    shotState = "idle",
    shotStartTime = 0
}

-- Variables d'état
local LaneData = {}
local HitNotes = {}
local KeyState = {}
local KeyReleaseTime = {}
local LastNoteTime = {}
local Circles = {}
local Tails = {}
local CameraScale = 1
local lastCameraUpdate = 0
local lastGuiCheck = 0
local guiVisible = false
local PlayerGui = nil
local GameUI = nil

-- ==========================================
-- INITIALISATION DES VISUELS
-- ==========================================

local function InitVisuals()
    for lane = 1, 4 do
        HitNotes[lane] = {}
        Circles[lane] = {}
        Tails[lane] = {}
        for i = 1, GameConfig.MAX_CIRCLES do
            local circle = Drawing.new("Circle")
            circle.NumSides = GameConfig.CIRCLE_SIDES
            circle.Radius = GameConfig.CIRCLE_RADIUS
            circle.Thickness = GameConfig.CIRCLE_THICK
            circle.Filled = false
            circle.Visible = false
            circle.ZIndex = 10
            Circles[lane][i] = circle

            local line = Drawing.new("Line")
            line.Thickness = GameConfig.TAIL_THICK
            line.Visible = false
            line.ZIndex = 9
            Tails[lane][i] = line
        end
    end
end

local function ClearVisuals()
    SafeCall(function() Line:Remove() end)
    for lane = 1, 4 do
        for i = 1, GameConfig.MAX_CIRCLES do
            SafeCall(function() Circles[lane][i]:Remove() end)
            SafeCall(function() Tails[lane][i]:Remove() end)
        end
    end
end

-- ==========================================
-- MISE À JOUR DES LANES
-- ==========================================

local function UpdateLanes()
    if not PlayerGui then return false end
    local screenGui = SafeCall(function() return PlayerGui:FindFirstChild(DecodeString(2) .. "1") end)
    if not screenGui then return false end

    local lanes = {}
    local activeCount = 0
    for i = 1, 15 do
        local lane = SafeCall(function() return screenGui:FindFirstChild(DecodeString(2) .. i) end)
        if lane then
            local pos = SafeCall(function() return lane.AbsolutePosition end)
            local size = SafeCall(function() return lane.AbsoluteSize end)
            if pos and size then
                activeCount = activeCount + 1
                lanes[i] = {
                    inst = lane,
                    cx = pos.X + size.X / 2,
                    cy = pos.Y + size.Y / 2,
                    hitY = pos.Y + size.Y / 2
                }
            end
        else
            break
        end
    end

    if activeCount == 0 then return false end

    if activeCount == 2 then
        AutoPlay.currentKeys = { 70, 74 }
    else
        AutoPlay.currentKeys = { 88, 67, 78, 77 }
    end
    AutoPlay.activeLaneCount = activeCount

    LaneData = lanes
    return true
end

local function IsGuiVisible()
    local gui = SafeCall(function() return PlayerGui:FindFirstChild(DecodeString(18)) end)
    return not gui
end

-- ==========================================
-- AUTO SHOOT
-- ==========================================

local function GetTarget()
    local player = LocalPlayer
    local char = player and player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local target = root:FindFirstChild(DecodeString(20))
    return target
end

local function GetChargePercent(targetGui)
    local bar = SafeCall(function() return targetGui:FindFirstChild(DecodeString(21)) end)
    if not bar then return nil end
    local pos = SafeCall(function() return bar.AbsolutePosition end)
    local size = SafeCall(function() return bar.AbsoluteSize end)
    local parentPos = SafeCall(function() return targetGui.AbsolutePosition end)
    local parentSize = SafeCall(function() return targetGui.AbsoluteSize end)
    
    if not pos or not size or not parentPos or not parentSize or parentSize.Y <= 0 then
        return nil
    end

    local center = parentPos.Y + parentSize.Y / 2
    local percent = (pos.Y + size.Y / 2 - center) / parentSize.Y
    return math.clamp(percent, 0, 1)
end

local function ResetState()
    for i = 1, 4 do
        KeyState[i] = false
        KeyReleaseTime[i] = 0
        LastNoteTime[i] = 0
        HitNotes[i] = {}
    end
    LaneData = nil
end

-- ==========================================
-- INTERFACE UTILISATEUR (UI)
-- ==========================================

local Library = loadstring(game:HttpGet(DecodeString(13)))() or INSui

local Window = Library:CreateWindow({
    title = DecodeString(40),
    subtitle = DecodeString(41) .. " v1.0",
    size = Vector2.new(550, 350),
    menuKey = DecodeString(42),
    configName = DecodeString(43),
    autoSave = true
})

Window:AddSettingsTab()

local MainTab = Window:Tab(DecodeString(11), DecodeString(12))
local VisualsTab = Window:Tab(DecodeString(35), DecodeString(36))

-- Section Autoplay
local AutoPlaySection = MainTab:Section(DecodeString(16), DecodeString(17))
AutoPlaySection:Toggle(DecodeString(37), false, function(state)
    AutoPlay.enabled = state
    if not AutoPlay.enabled then
        ResetState()
        ClearVisuals()
    end
end)

AutoPlaySection:Label(DecodeString(9) .. " v1.0")
AutoPlaySection:Label(DecodeString(15))

-- Section Visuals
local ESPSection = VisualsTab:Section(DecodeString(26), DecodeString(27), DecodeString(28))
ESPSection:Toggle(DecodeString(30), false, function(state)
    AutoPlay.showESP = state
    if not AutoPlay.showESP then
        ClearVisuals()
    end
end)

ESPSection:Colorpicker(DecodeString(29), GameConfig.LANE_COLORS[1], function(color)
    GameConfig.LANE_COLORS[1] = color
    GameConfig.LANE_COLORS[2] = color
    GameConfig.LANE_COLORS[3] = color
    GameConfig.LANE_COLORS[4] = color
end)

ESPSection:Colorpicker(DecodeString(74), GameConfig.LINE_COLOR, function(color)
    GameConfig.LINE_COLOR = color
    Line.Color = color
end)

ESPSection:Colorpicker(DecodeString(34), GameConfig.COLOR_HOLD, function(color)
    GameConfig.COLOR_HOLD = color
end)

-- Section AutoShoot
local ShootTab = Window:Tab(DecodeString(72), DecodeString(73))
local ShootSection = ShootTab:Section(DecodeString(66), DecodeString(67))

ShootSection:Toggle(DecodeString(75), false, function(state)
    AutoShoot.enabled = state
    if not AutoShoot.enabled and AutoShoot.shotState ~= "idle" then
        keyrelease(AutoShoot.SHOOT_KEY)
        AutoShoot.shotState = "idle"
    end
end)

ShootSection:Slider(DecodeString(68), 27.4, 0.1, 10, 80, DecodeString(69), function(value)
    AutoShoot.RELEASE_TARGET = value / 100
    print(DecodeString(70) .. value .. DecodeString(71))
end)

ShootSection:Label(DecodeString(52) .. " v1.0")

-- ==========================================
-- BOUCLE PRINCIPALE (RenderStepped)
-- ==========================================

local Line = Drawing.new("Line")
Line.Thickness = GameConfig.LINE_THICK
Line.Visible = false
Line.ZIndex = 5
Line.Color = GameConfig.LINE_COLOR

InitVisuals()

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    local now = os.clock()

    if not isrbxactive() then return end

    -- Mise à jour caméra
    if AutoPlay.enabled then
        if now - lastCameraUpdate >= 0.25 then
            lastCameraUpdate = now
            local camera = workspace.CurrentCamera
            if camera then
                CameraScale = camera.ViewportSize.Y / 1080
            end
        end

        -- Vérification GUI
        if now - lastGuiCheck >= 0.5 then
            lastGuiCheck = now
            if guiVisible then
                if IsGuiVisible() then
                    guiVisible = false
                    ClearVisuals()
                    ResetState()
                end
            else
                if not UpdateLanes() then
                    guiVisible = true
                end
            end
        end

        -- Dessin de la ligne ESP
        if AutoPlay.showESP and LaneData then
            Line.Thickness = GameConfig.LINE_THICK * CameraScale
            Line.Visible = true
            -- (Logique de dessin entre les lanes)
        end

        -- Nettoyer les visuels
        for lane = 1, 4 do
            for i = 1, GameConfig.MAX_CIRCLES do
                Circles[lane][i].Visible = false
                Tails[lane][i].Visible = false
            end
        end

        -- Relâcher les touches si nécessaire
        for lane = 1, AutoPlay.activeLaneCount do
            local key = AutoPlay.currentKeys[lane]
            if KeyState[lane] and now >= KeyReleaseTime[lane] then
                keyrelease(key)
                KeyState[lane] = false
            end
        end

        -- Récupérer toutes les notes actives
        local notesByLane = { {}, {}, {}, {} }
        local allNotes = SafeCall(function() return GameUI and GameUI:GetChildren() end)
        
        if allNotes then
            for _, note in pairs(allNotes) do
                if SafeCall(function() return note.ClassName end) ~= "Frame" then continue end
                if SafeCall(function() return note.Name end) ~= DecodeString(47) then continue end
                
                local noteVisual = SafeCall(function() return note:FindFirstChild(DecodeString(48)) end)
                if not noteVisual then continue end
                
                local pos = SafeCall(function() return noteVisual.AbsolutePosition end)
                local size = SafeCall(function() return noteVisual.AbsoluteSize end)
                if not pos or not size then continue end
                
                local noteX = pos.X + size.X / 2
                local noteY = pos.Y + size.Y / 2
                
                -- Trouver la lane la plus proche
                local closestLane = nil
                local closestDist = math.huge
                for laneIdx = 1, AutoPlay.activeLaneCount do
                    if not LaneData[laneIdx] then continue end
                    local dist = math.abs(noteX - LaneData[laneIdx].cx)
                    if dist < closestDist then
                        closestDist = dist
                        closestLane = laneIdx
                    end
                end
                
                if not closestLane or closestDist > GameConfig.MIN_DIST_X then continue end
                
                -- Vérifier si déjà traitée
                local laneNotes = HitNotes[closestLane]
                if laneNotes[note] then
                    if not SafeCall(function() return note.Parent end) then
                        laneNotes[note] = nil
                    end
                    continue
                end
                
                local hitY = LaneData[closestLane].hitY
                local distToHit = noteY - hitY
                
                if distToHit > GameConfig.PAST_CATCH then
                    laneNotes[note] = true
                    continue
                end
                
                if distToHit < -GameConfig.APPROACH_DIST then continue end
                
                -- Vérifier si c'est une hold note
                local holdVisual = SafeCall(function() return note:FindFirstChild(DecodeString(49)) end)
                local holdHeight = holdVisual and SafeCall(function() return holdVisual.AbsoluteSize.Y end) or 0
                local isHold = holdHeight > GameConfig.HOLD_MIN_H
                
                notesByLane[closestLane][#notesByLane[closestLane] + 1] = {
                    note = note,
                    headCY = noteY,
                    dist = distToHit,
                    isHold = isHold,
                    tailH = holdHeight
                }
            end
        end

        -- Traiter chaque lane
        for lane = 1, AutoPlay.activeLaneCount do
            local key = AutoPlay.currentKeys[lane]
            if not LaneData[lane] then continue end
            
            local laneX = LaneData[lane].cx
            local laneNotes = notesByLane[lane]
            local hitTable = HitNotes[lane]
            
            -- Trier par position Y (les plus basses en premier)
            table.sort(laneNotes, function(a, b) return a.headCY < b.headCY end)
            
            for i = 1, #laneNotes do
                if i > GameConfig.MAX_CIRCLES then break end
                
                local noteData = laneNotes[i]
                local inRange = noteData.dist >= -GameConfig.TOUCH_DIST and noteData.dist <= GameConfig.PAST_CATCH
                
                -- Dessin ESP
                if AutoPlay.showESP then
                    local circle = Circles[lane][i]
                    local tail = Tails[lane][i]
                    local color
                    
                    if inRange then
                        color = GameConfig.COLOR_ON_LINE
                    elseif noteData.dist < -GameConfig.TOUCH_DIST then
                        -- Interpolation pour couleur d'approche
                        local lerp = 1 - math.abs(noteData.dist) / GameConfig.APPROACH_DIST
                        local r = GameConfig.COLOR_APPROACH.R + (GameConfig.LANE_COLORS[lane].R - GameConfig.COLOR_APPROACH.R) * lerp
                        local g = GameConfig.COLOR_APPROACH.G + (GameConfig.LANE_COLORS[lane].G - GameConfig.COLOR_APPROACH.G) * lerp
                        local b = GameConfig.COLOR_APPROACH.B + (GameConfig.LANE_COLORS[lane].B - GameConfig.COLOR_APPROACH.B) * lerp
                        color = Color3.new(r, g, b)
                    else
                        color = noteData.isHold and GameConfig.COLOR_HOLD or GameConfig.LANE_COLORS[lane]
                    end
                    
                    circle.Color = color
                    circle.Radius = GameConfig.CIRCLE_RADIUS * CameraScale
                    circle.Thickness = GameConfig.CIRCLE_THICK * CameraScale
                    circle.Filled = noteData.isHold and not inRange
                    circle.Position = Vector2.new(laneX, noteData.headCY)
                    circle.Visible = true
                    
                    if noteData.isHold and noteData.tailH > 0 then
                        tail.From = Vector2.new(laneX, noteData.headCY)
                        tail.To = Vector2.new(laneX, noteData.headCY - noteData.tailH)
                        tail.Thickness = GameConfig.TAIL_THICK * CameraScale
                        tail.Color = color
                        tail.Visible = true
                    end
                end
                
                -- Appuyer sur la touche
                if inRange and not KeyState[lane] and not hitTable[noteData.note] then
                    hitTable[noteData.note] = true
                    
                    if noteData.isHold then
                        keypress(key)
                        hitTable[noteData.note] = {
                            inst = noteData.note,
                            tailH = noteData.tailH
                        }
                        LastNoteTime[lane] = now
                    else
                        keypress(key)
                        KeyState[lane] = true
                        KeyReleaseTime[lane] = now + GameConfig.TAP_HOLD_SEC
                    end
                    break
                end
            end
        end
        
        -- Nettoyer les notes hold terminées
        for lane = 1, AutoPlay.activeLaneCount do
            local key = AutoPlay.currentKeys[lane]
            if KeyState[lane] and now >= KeyReleaseTime[lane] then
                keyrelease(key)
                KeyState[lane] = false
            end
            
            local heldNote = hitTable[lane] -- Simplification
            if heldNote and type(heldNote) == "table" and heldNote.inst then
                local stillValid = SafeCall(function() return heldNote.inst.Parent end)
                local holdVisual = heldNote.inst and SafeCall(function() 
                    return heldNote.inst:FindFirstChild(DecodeString(45)) 
                end)
                local holdHeight = holdVisual and SafeCall(function() return holdVisual.AbsoluteSize.Y end) or 0
                local currentY = SafeCall(function() 
                    local v = heldNote.inst:FindFirstChild(DecodeString(44))
                    return v and v.AbsolutePosition.Y + v.AbsoluteSize.Y / 2
                end)
                local hitY = LaneData[lane].hitY
                
                if holdHeight < 5 or (currentY and currentY - holdHeight >= hitY) then
                    keyrelease(key)
                    hitTable[lane] = nil
                    LastNoteTime[lane] = 0
                end
            end
        end
    elseif not AutoPlay.enabled then
        ClearVisuals()
    end

    -- ==========================================
    -- AUTO SHOOT LOGIC
    -- ==========================================
    
    if AutoShoot.enabled then
        local target = GetTarget()
        local targetGui = target and SafeCall(function() return target:FindFirstChild(DecodeString(50)) end)
        
        if not target or not targetGui then
            if AutoShoot.shotState ~= "idle" then
                print(string.format(DecodeString(52), AutoShoot.shotCount))
                AutoShoot.shotState = "idle"
            end
        else
            local chargePercent = GetChargePercent(targetGui)
            
            if chargePercent then
                if AutoShoot.shotState == "idle" then
                    if chargePercent > 0.95 then
                        AutoShoot.shotState = "charging"
                        AutoShoot.shotStartTime = now
                        AutoShoot.shotCount = AutoShoot.shotCount + 1
                        print(string.format(DecodeString(56), AutoShoot.shotCount, chargePercent * 100))
                    end
                elseif AutoShoot.shotState == "charging" then
                    if chargePercent <= AutoShoot.RELEASE_TARGET then
                        AutoShoot.shotState = "released"
                        print(string.format(DecodeString(59), AutoShoot.shotCount, chargePercent * 100, AutoShoot.RELEASE_TARGET * 100))
                        keyrelease(AutoShoot.SHOOT_KEY)
                    elseif chargePercent <= 0.01 then
                        print(string.format(DecodeString(60), AutoShoot.shotCount, chargePercent * 100))
                        keyrelease(AutoShoot.SHOOT_KEY)
                        AutoShoot.shotState = "timeout"
                    elseif now - AutoShoot.shotStartTime > 3 then
                        print(string.format(DecodeString(62), AutoShoot.shotCount, chargePercent * 100))
                        keyrelease(AutoShoot.SHOOT_KEY)
                        AutoShoot.shotState = "timeout"
                    end
                end
            end
        end
    end
end)

-- Notification de chargement
pcall(function()
    notify(DecodeString(31))
end)

print(DecodeString(1))