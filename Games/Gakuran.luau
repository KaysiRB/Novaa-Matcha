-- Deobfuscated & Renamed: Gakuran.lua[cite: 1]

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
local xorKey = { 5, 92, 33, 187, 147, 122, 202, 227, 100, 202, 186, 179, 192 }

local function DecryptString(index)
	local str = encryptedStrings[index]
	local result = {}
	for i = 1, #str do
		local byte = string.byte(str, i)
		local keyByte = xorKey[(i - 1) % #xorKey + 1]
		local decryptedByte = 0
		local multiplier = 1
		for bit = 0, 7 do
			local b1, b2 = byte % 2, keyByte % 2
			if b1 ~= b2 then
				decryptedByte = decryptedByte + multiplier
			end
			byte = (byte - b1) / 2
			keyByte = (keyByte - b2) / 2
			multiplier = multiplier * 2
		end
		result[i] = string.char(decryptedByte)
	end
	return table.concat(result)
end

local function SafeCall(func)
	local success, result = pcall(func)
	if success then
		return result
	end
	return nil
end

-- ==========================================
-- Core Services
-- ==========================================
local RunService = game:GetService(DecryptString(19)) -- "RunService"
local Players = game:GetService(DecryptString(33))    -- "Players"
local Workspace = game:GetService(DecryptString(10))  -- "Workspace"

-- ==========================================
-- Configurations
-- ==========================================
local AutoPlayConfig = {
	enabled = false,
	showESP = false,
	currentKeys = { 88, 67, 78, 77 },
	activeLaneCount = 4
}

local Constants = {
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
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(100, 220, 100),
		Color3.fromRGB(60, 180, 60)
	},
	COLOR_ON_LINE = Color3.fromRGB(255, 255, 255),
	COLOR_HOLD = Color3.fromRGB(150, 255, 150),
	COLOR_APPROACH = Color3.fromRGB(100, 130, 100),
	LINE_COLOR = Color3.fromRGB(255, 255, 255)
}

local AutoShootConfig = {
	enabled = false,
	SHOOT_KEY = 70,
	RELEASE_TARGET = 0.274,
	shotCount = 0,
	shotState = DecryptString(25),
	shotStartTime = 0
}

-- ==========================================
-- ESP Drawing Elements
-- ==========================================
local espLine = Drawing.new("Line")
espLine.Color = Constants.LINE_COLOR
espLine.Thickness = Constants.LINE_THICK
espLine.Visible = false
espLine.ZIndex = 5

local espCircles = {}
local espTails = {}

for lane = 1, 4 do
	espCircles[lane] = {}
	espTails[lane] = {}
	for i = 1, Constants.MAX_CIRCLES do
		local circle = Drawing.new("Circle")
		circle.NumSides = Constants.CIRCLE_SIDES
		circle.Radius = Constants.CIRCLE_RADIUS
		circle.Thickness = Constants.CIRCLE_THICK
		circle.Filled = false
		circle.Visible = false
		circle.ZIndex = 10
		espCircles[lane][i] = circle

		local tail = Drawing.new("Line")
		tail.Thickness = Constants.TAIL_THICK
		tail.Visible = false
		tail.ZIndex = 9
		espTails[lane][i] = tail
	end
end

local function HideESP()
	espLine.Visible = false
	for lane = 1, 4 do
		for i = 1, Constants.MAX_CIRCLES do
			espCircles[lane][i].Visible = false
			espTails[lane][i].Visible = false
		end
	end
end

local function DestroyESP()
	for lane = 1, 4 do
		for i = 1, Constants.MAX_CIRCLES do
			pcall(function() espCircles[lane][i]:Remove() end)
			pcall(function() espTails[lane][i]:Remove() end)
		end
	end
	pcall(function() espLine:Remove() end)
end

-- ==========================================
-- Auto-Play State Trackers
-- ==========================================
local isKeyHeld = {false, false, false, false}
local keyReleaseTimes = {0, 0, 0, 0}
local activeHoldNotes = {nil, nil, nil, nil}
local holdStartTimes = {0, 0, 0, 0}
local processedNotes = {{}, {}, {}, {}}

local function ResetPlayState()
	for lane = 1, 4 do
		if AutoPlayConfig.currentKeys[lane] then
			keyrelease(AutoPlayConfig.currentKeys[lane])
		end
		isKeyHeld[lane] = false
		activeHoldNotes[lane] = nil
		holdStartTimes[lane] = 0
		processedNotes[lane] = {}
	end
end

local activeUIContainer = nil
local isPlaying = false
local laneData = nil

local function ScanRhythmUI()
	local playerGui = SafeCall(function() return Players.LocalPlayer.PlayerGui end)
	if not playerGui then return false end

	local mainUI = SafeCall(function() return playerGui:FindFirstChild(DecryptString(5)) end)
	if not mainUI then return false end

	local laneContainer = SafeCall(function() return mainUI:FindFirstChild(DecryptString(3)) end)
	if not laneContainer then return false end

	local trackUI = SafeCall(function() return laneContainer:FindFirstChild(DecryptString(6)) end)
	local notesContainer = SafeCall(function() return laneContainer:FindFirstChild(DecryptString(4)) end)

	if not trackUI or not notesContainer then return false end

	local scannedLanes = {}
	local count = 0

	for i = 1, 4 do
		local laneInst = SafeCall(function() return trackUI:FindFirstChild(DecryptString(2) .. i) end)
		if laneInst then
			local pos = SafeCall(function() return laneInst.AbsolutePosition end)
			local size = SafeCall(function() return laneInst.AbsoluteSize end)
			if pos and size then
				scannedLanes[i] = {
					inst = laneInst,
					cx = pos.X + size.X / 2,
					cy = pos.Y + size.Y / 2,
					hitY = pos.Y + size.Y / 2
				}
				count = count + 1
			end
		end
	end

	if count == 0 then return false end

	AutoPlayConfig.activeLaneCount = count
	laneData = scannedLanes
	activeUIContainer = notesContainer
	isPlaying = true

	if AutoPlayConfig.activeLaneCount == 2 then
		AutoPlayConfig.currentKeys = {70, 74}
	else
		AutoPlayConfig.currentKeys = {88, 67, 78, 77}
	end

	local camera = Workspace.CurrentCamera
	local viewportScale = camera and (camera.ViewportSize.Y / 1080) or 1

	local leftBound = (scannedLanes[1] and scannedLanes[1].cx or 0) - (50 * viewportScale)
	local rightBound = (scannedLanes[AutoPlayConfig.activeLaneCount] and scannedLanes[AutoPlayConfig.activeLaneCount].cx or 0) + (50 * viewportScale)
	local hitY = scannedLanes[1].hitY

	espLine.From = Vector2.new(leftBound, hitY)
	espLine.To = Vector2.new(rightBound, hitY)

	if AutoPlayConfig.enabled and AutoPlayConfig.showESP then
		espLine.Visible = true
	end

	return true
end

local function CleanUpNotes(currentTime)
	for lane = 1, 4 do
		local noteDict = processedNotes[lane]
		for noteInst, _ in pairs(noteDict) do
			if not SafeCall(function() return noteInst.Parent end) then
				noteDict[noteInst] = nil
			end
		end
	end
end

-- ==========================================
-- Auto-Shoot Helpers
-- ==========================================
local function GetTargetPlayerMeter()
	local localPlr = SafeCall(function() return Players.LocalPlayer end)
	local name = localPlr and SafeCall(function() return localPlr.Name end)
	if not name then return nil end
	
	local workspacePlr = SafeCall(function() return Workspace.Players:FindFirstChild(name) end)
	local charElement = workspacePlr and SafeCall(function() return workspacePlr:FindFirstChild(DecryptString(24)) end)
	local subChar = charElement and SafeCall(function() return charElement:FindFirstChild(DecryptString(23)) end)
	local meterContainer = subChar and SafeCall(function() return subChar:FindFirstChild(DecryptString(20)) end)
	local meterBase = meterContainer and SafeCall(function() return meterContainer:FindFirstChild(DecryptString(21)) end)
	
	return meterBase and SafeCall(function() return meterBase:FindFirstChild(DecryptString(22)) end)
end

local function GetShotMeterValue(meterUI)
	local fillUI = SafeCall(function() return meterUI:FindFirstChild(DecryptString(32)) end)
	if not fillUI then return nil end
	
	local fillPos = SafeCall(function() return fillUI.AbsolutePosition end)
	local fillSize = SafeCall(function() return fillUI.AbsoluteSize end)
	local meterPos = SafeCall(function() return meterUI.AbsolutePosition end)
	local meterSize = SafeCall(function() return meterUI.AbsoluteSize end)
	
	if not fillPos or not fillSize or not meterPos or not meterSize or meterSize.Y <= 0 then 
		return nil 
	end
	
	local fillCenterY = fillPos.Y + fillSize.Y / 2
	local value = (fillCenterY - meterPos.Y) / meterSize.Y
	return math.clamp(value, 0, 1)
end

ScanRhythmUI()

-- ==========================================
-- Main Loop (RenderStepped)
-- ==========================================
local lastCameraUpdate = 0
local lastUIRefresh = 0
local lastNoteCleanup = 0
local viewportScale = 1
local currentCamera = nil
local scriptVersionName = DecryptString(77)

RunService.RenderStepped:Connect(function(deltaTime)
	if not isrbxactive() then return end
	local currentTime = os.clock()

	-- Auto Play Logic
	if AutoPlayConfig.enabled then
		if currentTime - lastCameraUpdate >= 0.25 then
			lastCameraUpdate = currentTime
			currentCamera = Workspace.CurrentCamera
			if currentCamera then
				viewportScale = currentCamera.ViewportSize.Y / 1080
			end
		end

		if currentTime - lastUIRefresh >= 0.5 then
			lastUIRefresh = currentTime
			if isPlaying then
				local playerGui = SafeCall(function() return Players.LocalPlayer.PlayerGui end)
				local stillActive = SafeCall(function() return playerGui:FindFirstChild(DecryptString(18)) end)
				if not stillActive then
					isPlaying = false
					HideESP()
					ResetPlayState()
				end
			else
				ScanRhythmUI()
			end
		end

		if isPlaying and laneData then
			if AutoPlayConfig.showESP then
				espLine.Thickness = Constants.LINE_THICK * viewportScale
				espLine.Visible = true
			end

			for lane = 1, 4 do
				for i = 1, Constants.MAX_CIRCLES do
					espCircles[lane][i].Visible = false
					espTails[lane][i].Visible = false
				end
			end

			-- Process Key Releases
			for lane = 1, AutoPlayConfig.activeLaneCount do
				local key = AutoPlayConfig.currentKeys[lane]

				if isKeyHeld[lane] and currentTime >= keyReleaseTimes[lane] then
					keyrelease(key)
					isKeyHeld[lane] = false
				end

				if activeHoldNotes[lane] then
					local holdData = activeHoldNotes[lane]
					local shouldRelease = false

					local parent = SafeCall(function() return holdData.inst.Parent end)
					if not parent then
						shouldRelease = true
					else
						local tailInst = SafeCall(function() return holdData.inst:FindFirstChild(DecryptString(44)) end)
						if not tailInst then
							shouldRelease = true
						else
							local tPos = SafeCall(function() return tailInst.AbsolutePosition end)
							local tSize = SafeCall(function() return tailInst.AbsoluteSize end)
							if not tPos or not tSize then
								shouldRelease = true
							else
								local tailBottomY = tPos.Y + tSize.Y / 2
								local tailHeight = SafeCall(function() return holdData.inst:FindFirstChild(DecryptString(45)).AbsoluteSize.Y end) or 0
								local targetY = laneData[lane].hitY

								if tailHeight < 4 or tailBottomY - tailHeight >= targetY then
									shouldRelease = true
								end
							end
						end
					end

					if shouldRelease then
						keyrelease(key)
						activeHoldNotes[lane] = nil
						holdStartTimes[lane] = 0
					end
				end
			end

			-- Run cleanup occasionally
			if currentTime - lastNoteCleanup >= 1 then
				lastNoteCleanup = currentTime
				CleanUpNotes(currentTime)
			end

			-- Scan and process incoming notes
			local notes = SafeCall(function() return activeUIContainer:GetChildren() end)
			if notes then
				local upcomingNotes = {{}, {}, {}, {}}

				for _, note in pairs(notes) do
					if SafeCall(function() return note.ClassName end) ~= DecryptString(46) then continue end
					if SafeCall(function() return note.Name end) ~= DecryptString(47) then continue end

					local headInst = SafeCall(function() return note:FindFirstChild(DecryptString(48)) end)
					if not headInst then continue end

					local pos = SafeCall(function() return headInst.AbsolutePosition end)
					local size = SafeCall(function() return headInst.AbsoluteSize end)
					if not pos or not size then continue end

					local noteX = pos.X + size.X / 2
					local noteY = pos.Y + size.Y / 2

					-- Assign to lane
					local targetLane = nil
					local closestDist = math.huge
					for lane = 1, AutoPlayConfig.activeLaneCount do
						if laneData[lane] then
							local distX = math.abs(noteX - laneData[lane].cx)
							if distX < closestDist then
								closestDist = distX
								targetLane = lane
							end
						end
					end

					if not targetLane or closestDist > Constants.MIN_DIST_X then continue end
					if processedNotes[targetLane][note] then continue end

					local hitY = laneData[targetLane].hitY
					local distY = noteY - hitY

					if distY > Constants.PAST_CATCH then
						processedNotes[targetLane][note] = true
						continue
					end
					if distY < -Constants.APPROACH_DIST then continue end

					local tailInst = SafeCall(function() return note:FindFirstChild(DecryptString(49)) end)
					local tailHeight = tailInst and SafeCall(function() return tailInst.AbsoluteSize.Y end) or 0
					local isHold = tailHeight > Constants.HOLD_MIN_H

					table.insert(upcomingNotes[targetLane], {
						note = note,
						headCY = noteY,
						dist = distY,
						isHold = isHold,
						tailH = tailHeight
					})
				end

				-- Evaluate hits and draw ESP
				for lane = 1, AutoPlayConfig.activeLaneCount do
					local key = AutoPlayConfig.currentKeys[lane]
					if not laneData[lane] then continue end

					local laneX = laneData[lane].cx
					local notesInLane = upcomingNotes[lane]

					table.sort(notesInLane, function(a, b) return a.headCY < b.headCY end)

					for i, noteData in ipairs(notesInLane) do
						if i > Constants.MAX_CIRCLES then break end

						local inHitWindow = noteData.dist >= -Constants.TOUCH_DIST and noteData.dist <= Constants.PAST_CATCH

						if AutoPlayConfig.showESP then
							local circle = espCircles[lane][i]
							local tail = espTails[lane][i]
							local color

							if inHitWindow then
								color = Constants.COLOR_ON_LINE
							elseif noteData.dist < -Constants.TOUCH_DIST then
								local percent = 1 - math.abs(noteData.dist) / Constants.APPROACH_DIST
								color = Constants.COLOR_APPROACH:Lerp(Constants.LANE_COLORS[lane], percent)
							else
								color = noteData.isHold and Constants.COLOR_HOLD or Constants.LANE_COLORS[lane]
							end

							circle.Color = color
							circle.Radius = Constants.CIRCLE_RADIUS * viewportScale
							circle.Thickness = Constants.CIRCLE_THICK * viewportScale
							circle.Filled = noteData.isHold and not inHitWindow
							circle.Position = Vector2.new(laneX, noteData.headCY)
							circle.Visible = true

							if noteData.isHold and noteData.tailH > 0 then
								tail.From = Vector2.new(laneX, noteData.headCY)
								tail.To = Vector2.new(laneX, noteData.headCY - noteData.tailH)
								tail.Thickness = Constants.TAIL_THICK * viewportScale
								tail.Color = color
								tail.Visible = true
							end
						end

						-- Execute Hit
						if inHitWindow and not isKeyHeld[lane] and not activeHoldNotes[lane] then
							processedNotes[lane][noteData.note] = true
							keypress(key)
							if noteData.isHold then
								activeHoldNotes[lane] = { inst = noteData.note, tailH = noteData.tailH }
								holdStartTimes[lane] = currentTime
							else
								isKeyHeld[lane] = true
								keyReleaseTimes[lane] = currentTime + Constants.TAP_HOLD_SEC
							end
							break
						end
					end
				end
			end
		elseif not AutoPlayConfig.enabled then
			HideESP()
		end
	end
	
	-- Auto Shoot Logic
	if AutoShootConfig.enabled then
		local meterUI = GetTargetPlayerMeter()
		local validMeter = meterUI and SafeCall(function() return meterUI:FindFirstChild(DecryptString(50)) end)
		
		if not meterUI or not validMeter then
			if AutoShootConfig.shotState ~= DecryptString(51) then
				print(string.format(DecryptString(52), AutoShootConfig.shotCount))
				AutoShootConfig.shotState = DecryptString(53)
			end
		else
			local meterValue = GetShotMeterValue(meterUI)
			if meterValue then
				if AutoShootConfig.shotState == DecryptString(54) then
					if meterValue > 0.95 then
						AutoShootConfig.shotState = DecryptString(55)
						AutoShootConfig.shotStartTime = currentTime
						AutoShootConfig.shotCount = AutoShootConfig.shotCount + 1
						print(string.format(DecryptString(56), AutoShootConfig.shotCount, meterValue * 100))
					end
				elseif AutoShootConfig.shotState == DecryptString(57) then
					if meterValue <= AutoShootConfig.RELEASE_TARGET then
						AutoShootConfig.shotState = DecryptString(58)
						print(string.format(DecryptString(59), AutoShootConfig.shotCount, meterValue * 100, AutoShootConfig.RELEASE_TARGET * 100))
						keyrelease(AutoShootConfig.SHOOT_KEY)
					elseif meterValue <= 0.01 then
						print(string.format(DecryptString(60), AutoShootConfig.shotCount, meterValue * 100))
						keyrelease(AutoShootConfig.SHOOT_KEY)
						AutoShootConfig.shotState = DecryptString(61)
					elseif currentTime - AutoShootConfig.shotStartTime > 3 then
						print(string.format(DecryptString(62), AutoShootConfig.shotCount, meterValue * 100))
						keyrelease(AutoShootConfig.SHOOT_KEY)
						AutoShootConfig.shotState = DecryptString(63)
					end
				end
			end
		end
	end
end]

-- ==========================================
-- UI Initialization
-- ==========================================
local LinoriaUI = loadstring(game:HttpGet(DecryptString(13)))() or INSui

local Window = LinoriaUI:CreateWindow({
	title = DecryptString(40),
	subtitle = DecryptString(41) .. scriptVersionName,
	size = Vector2.new(550, 350),
	menuKey = DecryptString(42),
	configName = DecryptString(43),
	autoSave = true
})

local TabPlay = Window:Tab(DecryptString(11), DecryptString(12))
local TabShoot = Window:Tab(DecryptString(35), DecryptString(36))
local TabSettings = Window:Tab(DecryptString(72), DecryptString(73))
Window:AddSettingsTab()

-- AutoPlay UI Elements
local PlayInfoSection = TabPlay:Section(DecryptString(64), DecryptString(65))
PlayInfoSection:Label(DecryptString(9) .. scriptVersionName)
PlayInfoSection:Label(DecryptString(15))

local PlayConfigSection = TabPlay:Section(DecryptString(16), DecryptString(17))
PlayConfigSection:Toggle(DecryptString(30), false, function(state)
	AutoPlayConfig.enabled = state
	if not state then
		ResetPlayState()
		HideESP()
	end
end)

PlayConfigSection:Toggle(DecryptString(75), false, function(state)
	AutoPlayConfig.showESP = state
	if not state then HideESP() end
end)

PlayConfigSection:Colorpicker(DecryptString(34), Constants.LINE_COLOR, function(color)
	Constants.LINE_COLOR = color
	espLine.Color = color
end)

-- AutoShoot UI Elements
local ShootConfigSection = TabShoot:Section(DecryptString(66), DecryptString(67))
ShootConfigSection:Toggle(DecryptString(37), false, function(state)
	AutoShootConfig.enabled = state
	if not state and AutoShootConfig.shotState ~= DecryptString(38) then
		keyrelease(AutoShootConfig.SHOOT_KEY)
		AutoShootConfig.shotState = DecryptString(39)
	end
end)

ShootConfigSection:Slider(DecryptString(68), 27.4, 0.1, 10, 80, DecryptString(69), function(val)
	AutoShootConfig.RELEASE_TARGET = val / 100
	print(DecryptString(70) .. val .. DecryptString(71))
end)

-- Settings UI Elements
local ColorSettingsSection = TabSettings:Section(DecryptString(26), DecryptString(27), DecryptString(28))
ColorSettingsSection:Colorpicker(DecryptString(29), Constants.LANE_COLORS[1], function(color)
	Constants.LANE_COLORS[1] = color
	Constants.LANE_COLORS[2] = color
	Constants.LANE_COLORS[3] = color
	Constants.LANE_COLORS[4] = color
end)

ColorSettingsSection:Colorpicker(DecryptString(74), Constants.COLOR_HOLD, function(color)
	Constants.COLOR_HOLD = color
end)

-- Finalize Theme & Notify
LinoriaUI:ApplyThemePreset(DecryptString(14))
pcall(function() notify(DecryptString(31)) end)