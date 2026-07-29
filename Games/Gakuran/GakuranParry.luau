local UserInputService = game:GetService("UserInputService")

return function(ctx)
	local RunService = ctx.RunService
	local Workspace = ctx.Workspace
	local LocalPlayer = ctx.LocalPlayer
	local Lib = ctx.Lib
	local win = ctx.win
	local safeCall = ctx.safeCall

	local ESP_Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/matchastuff/main/esp_utility.lua"))()
	local AnimationTrackerModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/matchastuff/main/animationtracker.lua"))()

	local parryConfigSource
	if readfile then
		parryConfigSource = readfile("Games/Gakuran/GakuranParryConfig.luau")
	end
	if not parryConfigSource then
		parryConfigSource = game:HttpGet("https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/Games/Gakuran/GakuranParryConfig.luau")
	end
	local ParryData = loadstring(parryConfigSource, "GakuranParryConfig")()

	--// AUTO PARRY SETTINGS
	local AUTO_PARRY_ENABLED = false
	local AUTO_DODGE_ENABLED = true
	local AUTO_TARGET_NEAREST = false
	local MULTI_TARGET = true
	local PARRY_DEBUG = false
	local TARGET_FACING_YOU = false
	local YOU_FACING_TARGET = true
	local INCLUDE_LOCAL_CHARACTER = false
	local DAMAGE_LOGS = false
	local SelectedFolder = nil
	local AutoParryRange = 10
	local MaxCycleRange = 20
	local ParryWindow = 0.06
	local ProbabilityToParry = 100
	local DefaultReactionTime = 0.1
	local ParryOffset = 0
	local BlockHoldTime = 0.4
	local PARRY_DISTANCE = 15
	local ParryKey = string.byte("F")
	local DodgeKey = string.byte("Q")

	local IgnoreIds = table.clone(ParryData.IgnoreIds)
	local ParriedAnimation = ParryData.ParriedAnimation
	local StunnedAnimation = ParryData.StunnedAnimation
	local ParryingAnimation = ParryData.ParryingAnimation

	local AnimationsLoggedCache = {}
	local AnimationsLoggedOrder = {}
	local AnimationIdSliders = {}
	local scheduler = { pendingTasks = {} }
	local TargetCharacters = {}
	local EspTrackers = {}
	local AnimationRegistry = {}
	local CurrentIndex = 1
	local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
	local COLOR_RED = Color3.fromRGB(255, 50, 50)
	local COLOR_GREEN = Color3.fromRGB(50, 255, 50)

	local KeyHeld = false
	local ReleaseDeadline = 0
	local Stunned = false
	local shotCount = 0
	local lastParryAt = 0
	local lastAnimationCheck = 0
	local LastCycleCheck = 0
	local UTILITY_TICK = 0.5
	local InputRegisteredTime = nil
	local ParryRegisteredTime = nil
	local InputLatency = 0
	local LastPendingRegData = nil
	local ParryState = {
		IDLE = "idle",
		INPUT_PENDING = "input_pending",
		PARRYING = "parrying",
		PARRYINGFAILED = "parryingfailed",
		STUNNED = "stunned",
		WINDOW_EXCEEDED = "window_exceeded",
		SUCCESS = "parrysuccess",
	}
	local CurrentParryState = ParryState.IDLE
	local StunToken = 0

	local damageConnection = nil
	local animationAddedConnection = nil
	local inputConnection = nil
	local orbConnection = nil
	local previousHealth = 100
	local lastCharacter = nil

	local function flattenGameConfig(rawConfig, defaultReactionTime)
		local flattened = {}
		for styleName, assets in pairs(rawConfig) do
			for assetId, data in pairs(assets) do
				if assetId == "M1Time" then
					continue
				end
				local flatData = table.clone(data)
				flatData.Style = styleName
				if data.DisplayName ~= "M2" and assets.M1Time then
					flatData.ReactionTime = assets.M1Time
				elseif not data.ReactionTime then
					flatData.DefaultReactionTime = defaultReactionTime
				end
				if flatData.ParryFunction then
					local original = flatData.ParryFunction
					flatData.ParryFunction = function(payload, helpers)
						original(payload, helpers)
					end
				end
				flattened[assetId] = flatData
			end
		end
		return flattened
	end

	local GameConfig = flattenGameConfig(ParryData.GameConfig, DefaultReactionTime)
	local ParryHelpers = {}

	local function schedulerDelay(delayTime, callback)
		table.insert(scheduler.pendingTasks, {
			executeAt = os.clock() + delayTime,
			callback = callback,
		})
	end

	local function schedulerUpdate()
		local now = os.clock()
		for i = #scheduler.pendingTasks, 1, -1 do
			local taskInfo = scheduler.pendingTasks[i]
			if now >= taskInfo.executeAt then
				table.remove(scheduler.pendingTasks, i)
				coroutine.wrap(taskInfo.callback)()
			end
		end
	end

	local AnimationTracker = AnimationTrackerModule.new(IgnoreIds)
	local LocalTracker = AnimationTrackerModule.new(IgnoreIds)

	local function GetAllFoldersInWorkspace()
		local folders = {}
		for _, folder in Workspace:GetChildren() do
			if folder:IsA("Folder") then
				table.insert(folders, folder.Name)
			end
		end
		return folders
	end

	local function GetAllCharactersInFolder()
		if not SelectedFolder or not Workspace:FindFirstChild(SelectedFolder) then
			Lib:Notify("ERROR", "Select a folder first", 2, "warning")
			return
		end
		local characters = {}
		local folder = Workspace[SelectedFolder]
		for _, character in folder:GetChildren() do
			if character:IsA("Model") and character:FindFirstChildWhichIsA("Humanoid") then
				if not INCLUDE_LOCAL_CHARACTER and character == LocalPlayer.Character then
					continue
				end
				table.insert(characters, character)
			end
		end
		return characters
	end

	local function UpdateClipboardSection(loggedText, ignoredText)
		local loggedCount = 0
		for _ in AnimationsLoggedCache do
			loggedCount += 1
		end
		loggedText:SetText("Logged Ids: " .. loggedCount)
		ignoredText:SetText("Ignored Ids: " .. #IgnoreIds)
	end

	local function SetClipboardLoggedCache()
		if #AnimationsLoggedOrder == 0 then
			Lib:Notify("Clipboard", "Nothing logged to copy", 2, "warning")
			return
		end
		local ids = {}
		for i = 1, #AnimationsLoggedOrder do
			local numericId = tostring(AnimationsLoggedOrder[i]):match("%d+")
			if numericId then
				table.insert(ids, numericId)
			end
		end
		setclipboard(table.concat(ids, ","))
		Lib:Notify("Clipboard", string.format("Copied %d logged animation IDs", #ids), 2, "success")
	end

	local function SetClipboardIgnoreList()
		if next(AnimationsLoggedCache) == nil then
			Lib:Notify("Clipboard", "Nothing logged to copy", 2, "warning")
			return
		end
		local newlyAddedIds = {}
		for animationId in AnimationsLoggedCache do
			local numericId = tonumber(string.match(tostring(animationId), "%d+"))
			if numericId then
				table.insert(IgnoreIds, numericId)
				table.insert(newlyAddedIds, tostring(numericId))
			end
		end
		setclipboard(table.concat(newlyAddedIds, ", "))
		AnimationsLoggedCache = {}
		AnimationsLoggedOrder = {}
		Lib:Notify("Clipboard", string.format("Copied %d new IDs to ignore list", #newlyAddedIds), 2, "success")
	end

	local function UpdateSliders()
		for animationId, info in GameConfig do
			if AnimationIdSliders[animationId] then
				info.DefaultReactionTime = DefaultReactionTime
				local reactionTime = info.M1Time or info.ReactionTime or info.DefaultReactionTime or DefaultReactionTime
				AnimationIdSliders[animationId]:Set(reactionTime)
			end
		end
	end

	local function TransitionToState(newState)
		if PARRY_DEBUG then
			print(string.format("[Parry] %s -> %s", CurrentParryState, newState))
		end
		CurrentParryState = newState
	end

	local function BlockEnd()
		KeyHeld = false
		if AUTO_PARRY_ENABLED then
			keyrelease(ParryKey)
		end
	end

	local function ResetParryState()
		KeyHeld = false
		ReleaseDeadline = 0
		BlockEnd()
	end

	function ParryHelpers.Dodge()
		BlockEnd()
		for _ = 1, 12 do
			keypress(DodgeKey)
			keyrelease(DodgeKey)
		end
	end

	function ParryHelpers.BlockStart(startTime, holdFor)
		if not startTime then
			return
		end
		if ParryRegisteredTime and os.clock() - ParryRegisteredTime < 0.8 then
			return
		end
		if CurrentParryState ~= ParryState.IDLE then
			return
		end
		local holdDuration = holdFor or BlockHoldTime
		ReleaseDeadline = startTime + holdDuration
		KeyHeld = true
		if AUTO_PARRY_ENABLED then
			if ismouse1pressed() then
				mouse2click()
			end
			keypress(ParryKey)
		end
	end

	local BlockStart = ParryHelpers.BlockStart
	local Dodge = ParryHelpers.Dodge

	local function GetActiveAnimationsForCharacterAsDictionary(character)
		local returnTable = {}
		local activeAnimations = AnimationTracker:Update(character)
		if not activeAnimations or #activeAnimations == 0 then
			return returnTable
		end
		for _, anim in activeAnimations do
			if anim.AnimationId then
				returnTable[anim.AnimationId] = anim
			end
		end
		return returnTable
	end

	local function DebugParry()
		local weActuallyBlockedAt = ParryRegisteredTime
		local weWantedToBlockAt = InputRegisteredTime
		local timeTheServerReceived = InputLatency / 2
		if LastPendingRegData then
			local animationStartTime = LastPendingRegData.StartTime
			local blockStart = LastPendingRegData.BlockStart
			local blockExpire = LastPendingRegData.BlockExpire
			local relativeBlockStart = blockStart - animationStartTime
			local relativeBlockExpire = blockExpire - animationStartTime
			local clientReactionTime = weWantedToBlockAt - animationStartTime
			local serverRelativeTime = (weActuallyBlockedAt - timeTheServerReceived) - animationStartTime
			local isSuccess = clientReactionTime >= relativeBlockStart and clientReactionTime <= relativeBlockExpire
			print(string.format(
				"\n================ PARRY DIAGNOSTICS ================\nTotal Input Latency: %.3fs\nTarget Parry Window: %.3fs to %.3fs\nPressed F At: %.3fs\nStatus: %s\n===================================================",
				InputLatency,
				relativeBlockStart,
				relativeBlockExpire,
				clientReactionTime,
				isSuccess and "[SUCCESS]" or "[MISSED WINDOW]"
			))
		else
			print(string.format("\n============ LATENCY ONLY DIAGNOSTICS ============\nTotal Input Latency: %.3fs\n===================================================", InputLatency))
		end
	end

	local function OnInputF()
		if CurrentParryState == ParryState.IDLE then
			InputRegisteredTime = os.clock()
			TransitionToState(ParryState.INPUT_PENDING)
		end
	end

	local function OnParryingAnimationSuccess()
		if CurrentParryState == ParryState.INPUT_PENDING then
			ParryRegisteredTime = os.clock()
			InputLatency = os.clock() - InputRegisteredTime
			if PARRY_DEBUG then
				DebugParry()
			end
			TransitionToState(ParryState.PARRYING)
		end
	end

	local function OnParryingAnimationFailed()
		if CurrentParryState == ParryState.INPUT_PENDING then
			TransitionToState(ParryState.PARRYINGFAILED)
			ResetParryState()
			TransitionToState(ParryState.IDLE)
		end
	end

	local function OnStunned()
		if CurrentParryState ~= ParryState.STUNNED then
			TransitionToState(ParryState.STUNNED)
		end
		StunToken += 1
		local myToken = StunToken
		schedulerDelay(0.3, function()
			if myToken == StunToken then
				BlockEnd()
				TransitionToState(ParryState.IDLE)
			end
		end)
	end

	local function OnSuccessfulParry()
		if CurrentParryState ~= ParryState.PARRYING or not LastPendingRegData then
			return
		end
		local animId = LastPendingRegData.AnimationId
		local attackConfig = GameConfig[animId]
		local parryPressTime = InputRegisteredTime - LastPendingRegData.StartTime
		if parryPressTime > 1 or parryPressTime < 0 then
			return
		end
		Lib:Notify(
			"Parry Success",
			string.format("%.3fs - %s %s", parryPressTime, attackConfig.Style, attackConfig.DisplayName),
			3,
			"success"
		)
		LastPendingRegData.LearnedParryTime = parryPressTime
		LastPendingRegData.Success = true
		ParryRegisteredTime = 0
		ResetParryState()
	end

	local function OnWindowExceeded()
		if CurrentParryState == ParryState.PARRYING and LastPendingRegData and LastPendingRegData.Success then
			LastPendingRegData.Success = false
			TransitionToState(ParryState.IDLE)
		end
	end

	local function ParryTask()
		local now = os.clock()
		if KeyHeld and now > ReleaseDeadline then
			BlockEnd()
		end
		if CurrentParryState == ParryState.INPUT_PENDING then
			local maxLatency = 0.5
			local timePassed = now - InputRegisteredTime
			local activeAnims = GetActiveAnimationsForCharacterAsDictionary(LocalPlayer.Character)
			if activeAnims[ParryingAnimation[1]] then
				OnParryingAnimationSuccess()
			end
			if timePassed > maxLatency then
				OnParryingAnimationFailed()
				TransitionToState(ParryState.IDLE)
			end
		elseif CurrentParryState == ParryState.PARRYING then
			if not LastPendingRegData then
				TransitionToState(ParryState.IDLE)
				return
			end
			if now > LastPendingRegData.BlockExpire then
				OnWindowExceeded()
			end
		end
	end

	local function LogAnimation(assetId, trackInfo)
		if AnimationsLoggedCache[assetId] then
			return
		end
		AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
		table.insert(AnimationsLoggedOrder, assetId)
	end

	local function ValidateLocalCharacter()
		local localCharacter = LocalPlayer and LocalPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
		if not localRoot or Stunned then
			return nil
		end
		return localCharacter, localRoot
	end

	local function UpdateCharacterESP(character, distance)
		local tracker = EspTrackers[character]
		if not tracker or not tracker.ChangeText then
			return distance <= AutoParryRange
		end
		if not AUTO_PARRY_ENABLED then
			tracker:ChangeText("Name", "AUTO PARRY IS DISARMED", COLOR_RED)
			return true
		end
		if distance > AutoParryRange then
			tracker:ChangeText("Name", character.Name .. " | OUT OF RANGE", COLOR_RED)
			return false
		end
		tracker:ChangeText("Name", character.Name .. " IN RANGE", COLOR_GREEN)
		return true
	end

	local function CalculateParryTiming(attackConfig, startTime)
		local optimalReactionTime = attackConfig.ReactionTime or DefaultReactionTime
		local adjustedReactionTime = optimalReactionTime + ParryOffset
		local parryWindowStart = adjustedReactionTime
		local parryWindowEnd = adjustedReactionTime + ParryWindow
		return startTime + parryWindowStart, startTime + parryWindowEnd
	end

	local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig)
		if not AnimationRegistry[animKey] then
			local adjustedNow = now - currentTrackTime
			local blockStart, blockExpire = CalculateParryTiming(attackConfig, adjustedNow)
			AnimationRegistry[animKey] = {
				StartTime = adjustedNow,
				Processed = false,
				CurrentClockTime = os.clock(),
				CurrentTrackTime = currentTrackTime,
				ReactionTime = attackConfig,
				Ignore = false,
				AnimationId = anim.AnimationId,
				DidALoop = false,
				BlockStart = blockStart,
				BlockExpire = blockExpire,
				RandomNum = math.random(1, 100),
			}
		end
		local regData = AnimationRegistry[animKey]
		if regData.CurrentTrackTime and currentTrackTime < regData.CurrentTrackTime then
			local blockStart, blockExpire = CalculateParryTiming(attackConfig, now - currentTrackTime)
			regData.Processed = false
			regData.DidALoop = true
			regData.BlockStart = blockStart
			regData.BlockExpire = blockExpire
			regData.StartTime = now - currentTrackTime
		end
		regData.CurrentClockTime = os.clock()
		regData.CurrentTrackTime = currentTrackTime
		if LastPendingRegData == regData then
			LastPendingRegData = regData
		end
		return regData
	end

	local function CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig)
		if character == localCharacter then
			return true
		end
		local direction = (targetRoot.Position - localRoot.Position).Unit
		local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
		if not isHeavy then
			if TARGET_FACING_YOU and targetRoot.CFrame.LookVector:Dot(-direction) < 0.25 then
				return false
			end
			if YOU_FACING_TARGET and localRoot.CFrame.LookVector:Dot(direction) < 0.25 then
				return false
			end
		end
		return true
	end

	local function ExecuteParry(regData, attackConfig)
		local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
		if attackConfig.Jump then
			task.spawn(function()
				keypress(32)
				task.wait(0.06)
				keyrelease(32)
			end)
		elseif isHeavy and AUTO_DODGE_ENABLED then
			Dodge()
		elseif LastPendingRegData ~= regData then
			LastPendingRegData = regData
			BlockStart(LastPendingRegData.BlockStart)
		elseif LastPendingRegData == regData and regData.DidALoop then
			regData.DidALoop = false
			BlockStart(regData.BlockStart)
		end
	end

	local function EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
		if not anim.AnimationId then
			return
		end
		local attackConfig = GameConfig[tostring(anim.AnimationId)]
		if not attackConfig then
			return
		end
		local animKey = anim.Address or anim
		currentActiveIds[animKey] = true
		local now = os.clock()
		local regData = UpdateAnimationRegistry(animKey, anim, now, anim.TimePosition or 0, attackConfig)
		if regData.Processed then
			return
		end
		if attackConfig.ParryFunction and (now - regData.StartTime) <= (attackConfig.ReactionTime or DefaultReactionTime) + ParryWindow / 2 then
			attackConfig.ParryFunction({
				RegistryData = regData,
				Mob = character,
				AnimationData = anim,
				AnimationTracker = AnimationTracker,
			}, ParryHelpers)
			return
		end
		if not CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig) then
			return
		end
		if regData.RandomNum > ProbabilityToParry then
			regData.Processed = true
			return
		end
		if now >= regData.BlockStart and now <= regData.BlockExpire then
			ExecuteParry(regData, attackConfig)
		end
	end

	local function EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
		local targetRoot = character:FindFirstChild("HumanoidRootPart")
		if not targetRoot then
			return
		end
		local distance = (targetRoot.Position - localRoot.Position).Magnitude
		if not UpdateCharacterESP(character, distance) then
			return
		end
		local activeAnimations = AnimationTracker:Update(character)
		if not activeAnimations or #activeAnimations == 0 then
			return
		end
		for _, anim in ipairs(activeAnimations) do
			EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
		end
	end

	local function EvaluateParryTriggers()
		local localCharacter, localRoot = ValidateLocalCharacter()
		if not localCharacter or not localRoot then
			return
		end
		local currentActiveIds = {}
		for _, character in ipairs(TargetCharacters) do
			EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
		end
		for key, val in pairs(AnimationRegistry) do
			if not currentActiveIds[key] then
				AnimationRegistry[key] = nil
				if LastPendingRegData == val then
					LastPendingRegData = nil
				end
			end
		end
	end

	local TargetPoolText
	local LoggedText
	local IgnoredText

	local function ProcessEspAndLogging()
		for i = #TargetCharacters, 1, -1 do
			local character = TargetCharacters[i]
			local tracker = EspTrackers[character]
			if tracker and not tracker.ChangeText then
				EspTrackers[character] = nil
				table.remove(TargetCharacters, i)
				continue
			end
			local activeAnimations = AnimationTracker:Update(character) or {}
			local lines = {}
			if #activeAnimations == 0 then
				if tracker then
					tracker:ChangeText("CurrentlyPlaying", "None", COLOR_WHITE)
				end
				continue
			end
			for _, anim in activeAnimations do
				if not anim.AnimationId then
					continue
				end
				local assetId = anim.AnimationId
				local numericId = tonumber(string.match(tostring(assetId), "%d+"))
				if numericId and table.find(IgnoreIds, numericId) then
					continue
				end
				local poolData = GameConfig[tostring(assetId)]
				local resolvedName = poolData and poolData.DisplayName or anim.Name
				if not poolData then
					LogAnimation(assetId, { Name = resolvedName, AnimationId = assetId })
				end
				table.insert(lines, string.format(
					"%s (%s) | ID: %s | Time: %.2f | Timing: %.2f %s | Speed: %.2f",
					tostring(resolvedName),
					poolData and poolData.Style or "???",
					tostring(assetId),
					anim.TimePosition or 0,
					poolData and poolData.ReactionTime or DefaultReactionTime,
					poolData and "[Logged]" or "[Unknown]",
					anim.Speed or 1
				))
			end
			if tracker and tracker.Name then
				tracker:ChangeText("CurrentlyPlaying", table.concat(lines, "\n"), COLOR_WHITE)
			end
		end
		if LoggedText and IgnoredText then
			UpdateClipboardSection(LoggedText, IgnoredText)
		end
	end

	local function ClearAllEspTrackers()
		for _, tracker in pairs(EspTrackers) do
			if tracker and tracker.Destroy then
				if ESP_Utility.TrackersToUpdate and ESP_Utility.TrackersToUpdate[tracker] then
					ESP_Utility.TrackersToUpdate[tracker] = nil
				end
				tracker:Destroy()
			end
		end
		table.clear(EspTrackers)
	end

	local function UpdateTargetCharacters(charactersList)
		ClearAllEspTrackers()
		table.clear(TargetCharacters)
		for _, character in charactersList do
			table.insert(TargetCharacters, character)
			if character and character:FindFirstChild("HumanoidRootPart") then
				local tracker = ESP_Utility.NewTracker(character.HumanoidRootPart, character.Name, COLOR_RED)
				if tracker and tracker.Name then
					tracker:AddText("CurrentlyPlaying", nil, "???")
				end
				EspTrackers[character] = tracker
			end
		end
	end

	local function UpdateTargetPoolSection()
		local characters = GetAllCharactersInFolder() or {}
		local names = {}
		for i, character in ipairs(characters) do
			table.insert(names, character.Name)
			if i == 10 then
				table.insert(names, "... (too long)")
				break
			end
		end
		if TargetPoolText then
			TargetPoolText:SetText("Target Pool: " .. table.concat(names, ", "))
		end
	end

	local function CycleEvent()
		local allCharacters = GetAllCharactersInFolder()
		if not SelectedFolder or not allCharacters then
			UpdateTargetCharacters({})
			return
		end
		local localCharacter = LocalPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
		if not localRoot then
			return
		end
		local validCharacters = {}
		for _, char in ipairs(allCharacters) do
			if char == localCharacter then
				continue
			end
			local targetRoot = char:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local distance = (localRoot.Position - targetRoot.Position).Magnitude
				if distance <= MaxCycleRange then
					table.insert(validCharacters, { Character = char, Distance = distance })
				end
			end
		end
		if #validCharacters == 0 then
			CurrentIndex = 1
			UpdateTargetCharacters({})
			if not AUTO_TARGET_NEAREST then
				Lib:Notify("Cycle", "No targets found in range [" .. MaxCycleRange .. " studs]", 2, "warning")
			end
			return
		end
		table.sort(validCharacters, function(a, b)
			return a.Distance < b.Distance
		end)
		if MULTI_TARGET then
			local finalTargets = {}
			for i = 1, math.min(3, #validCharacters) do
				table.insert(finalTargets, validCharacters[i].Character)
			end
			UpdateTargetCharacters(finalTargets)
		else
			CurrentIndex = (CurrentIndex % #validCharacters) + 1
			local targetIndex = AUTO_TARGET_NEAREST and 1 or CurrentIndex
			UpdateTargetCharacters({ validCharacters[targetIndex].Character })
		end
		UpdateTargetPoolSection()
	end

	local function ToggleDamageLogger(state)
		if not state then
			if damageConnection then
				damageConnection:Disconnect()
				damageConnection = nil
			end
			return
		end
		if damageConnection then
			return
		end
		damageConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then
				return
			end
			if lastCharacter and char ~= lastCharacter then
				lastCharacter = char
				previousHealth = hum.Health
			end
			local currentHealth = hum.Health
			if currentHealth < previousHealth then
				local damageTaken = previousHealth - currentHealth
				for _, targetCharacter in ipairs(TargetCharacters) do
					local activeAnimations = AnimationTracker:Update(targetCharacter) or {}
					for _, anim in activeAnimations do
						if not anim.AnimationId or anim.TimePosition < 0.1 or anim.TimePosition > 0.7 then
							continue
						end
						local assetId = tostring(anim.AnimationId)
						local poolData = GameConfig[assetId]
						warn(string.format(
							"[HIT] %d DMG | Anim: %s (%s) %s | Frame Time: %.3f",
							damageTaken,
							poolData and poolData.DisplayName or anim.Name or "Unknown",
							assetId,
							poolData and poolData.Style or "",
							anim.TimePosition or 0
						))
					end
				end
			end
			previousHealth = currentHealth
		end)
	end

	local function onLocalAnimationAdded(anim)
		local animId = anim.AnimationId
		if table.find(ParriedAnimation, animId) then
			OnSuccessfulParry()
		end
		if table.find(ParryingAnimation, animId) then
			if InputRegisteredTime then
				OnParryingAnimationSuccess()
			end
		end
		if table.find(StunnedAnimation, animId) then
			OnStunned()
		end
	end

	animationAddedConnection = LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded)

	inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.X then
			CycleEvent()
		elseif input.KeyCode == Enum.KeyCode.F then
			LocalTracker:Update(LocalPlayer.Character)
			OnInputF()
		end
	end)

	local function ListenForOrbs()
		return RunService.Heartbeat:Connect(function()
			local character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end
			local thrownFolder = Workspace:FindFirstChild("Thrown")
			if not thrownFolder then
				return
			end
			for _, orb in thrownFolder:GetChildren() do
				if (orb.Name == "ArdourBall2" or orb.Name == "ArdourBall") and orb:IsA("BasePart") then
					if (hrp.Position - orb.Position).Magnitude <= PARRY_DISTANCE and tick() - lastParryAt >= 0.08 then
						lastParryAt = tick()
						ParryHelpers.BlockStart(os.clock())
						BlockEnd()
						break
					end
				end
			end
		end)
	end

	if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then
		orbConnection = ListenForOrbs()
	end

	--// UI
	local autoParryTab = win:Tab("Auto Parry", "swords")
	local styleConfigTab = win:Tab("Style Config", "swords")

	local filesSection = autoParryTab:Section("Files", "Full", "Save and load parry configuration")
	local configSection = autoParryTab:Section("Global Configuration", "Full", "Timing, range, and probability settings")
	local apSection = autoParryTab:Section("Auto Parry Settings", "Full", "Core auto parry toggles and targeting")
	local foldersSection = autoParryTab:Section("Folders", "Full", "Workspace folder and target cycling")
	local clipboardSection = autoParryTab:Section("Logging", "Full", "Animation logging and clipboard tools")

	filesSection:Info("Game: " .. ParryData.GameName)
	filesSection:Button("Load parry configuration", function()
		Lib:LoadConfig(ParryData.GameName)
		Lib:Notify("Success", "Loaded parry configuration", 2, "success")
	end)
	filesSection:Button("Save parry configuration", function()
		Lib:SaveConfig(ParryData.GameName)
		Lib:Notify("Success", "Saved parry configuration", 2, "success")
	end)

	local autoParryToggle = apSection:Toggle("Auto Parry", AUTO_PARRY_ENABLED, function(value)
		AUTO_PARRY_ENABLED = value
		Lib:Notify("Auto Parry", AUTO_PARRY_ENABLED and "Enabled" or "Disabled", 2, AUTO_PARRY_ENABLED and "success" or "warning")
	end)
	autoParryToggle:AddKeybind("H", "Toggle")

	apSection:Toggle("Auto Dodge", AUTO_DODGE_ENABLED, function(value)
		AUTO_DODGE_ENABLED = value
	end)
	apSection:Toggle("Auto target nearest", AUTO_TARGET_NEAREST, function(value)
		AUTO_TARGET_NEAREST = value
	end)
	apSection:Toggle("Multiple targets", MULTI_TARGET, function(value)
		MULTI_TARGET = value
	end)
	apSection:Label("Press X to cycle targets when auto target nearest is off")

	apSection:Divider("Conditions")
	apSection:Toggle("Target facing you", TARGET_FACING_YOU, function(value)
		TARGET_FACING_YOU = value
	end)
	apSection:Toggle("You facing target", YOU_FACING_TARGET, function(value)
		YOU_FACING_TARGET = value
	end)

	configSection:Toggle("Debug parry", PARRY_DEBUG, function(value)
		PARRY_DEBUG = value
	end)
	configSection:Slider("Parry offset", ParryOffset, 0.01, -0.1, 0.1, " s", function(value)
		ParryOffset = value
	end)
	configSection:Label("Positive moves the window later, negative moves it earlier")
	configSection:Slider("Auto parry range", AutoParryRange, 1, 7, 80, " studs", function(value)
		AutoParryRange = value
	end)
	configSection:Slider("Probability to parry", ProbabilityToParry, 1, 1, 100, "%", function(value)
		ProbabilityToParry = value
	end)

	local defaultSection = styleConfigTab:Section("Default Configuration", "Full", "Default reaction time and parry window")
	defaultSection:Slider("Default reaction time", DefaultReactionTime, 0.01, 0, 1, " s", function(value)
		DefaultReactionTime = value
		UpdateSliders()
	end)
	defaultSection:Label("Reaction time is when F is pressed relative to animation start")
	defaultSection:Divider("Window")
	defaultSection:Slider("Default parry window", ParryWindow, 0.01, 0, 1, " s", function(value)
		ParryWindow = value
	end)
	defaultSection:Label("Usually constant, avoid changing unless needed")

	foldersSection:Slider("Max cycle range", MaxCycleRange, 1, 7, 50, " studs", function(value)
		MaxCycleRange = value
	end)
	foldersSection:Toggle("Include local character", INCLUDE_LOCAL_CHARACTER, function(value)
		INCLUDE_LOCAL_CHARACTER = value
		UpdateTargetPoolSection()
	end)
	TargetPoolText = foldersSection:Label("NO TARGETS FOUND")
	local folderDropdown = foldersSection:Dropdown("Live folder", nil, GetAllFoldersInWorkspace(), false, function(list)
		SelectedFolder = list[1]
		UpdateTargetPoolSection()
	end)
	if Workspace:FindFirstChild("Players") then
		folderDropdown:Set({ "Players" })
		SelectedFolder = "Players"
	elseif Workspace:FindFirstChild("Live") then
		folderDropdown:Set({ "Live" })
		SelectedFolder = "Live"
	end

	LoggedText = clipboardSection:Label("Logged Ids: 0")
	IgnoredText = clipboardSection:Label("Ignored Ids: 0")
	clipboardSection:Toggle("Damage logs", DAMAGE_LOGS, function(value)
		DAMAGE_LOGS = value
		ToggleDamageLogger(value)
	end)
	clipboardSection:Button("Copy logged IDs", function()
		SetClipboardLoggedCache()
		UpdateClipboardSection(LoggedText, IgnoredText)
	end)
	clipboardSection:Button("Add unknowns to ignore and copy", function()
		SetClipboardIgnoreList()
		UpdateClipboardSection(LoggedText, IgnoredText)
	end)
	clipboardSection:Button("Clear animation cache", function()
		AnimationsLoggedCache = {}
		AnimationsLoggedOrder = {}
		UpdateClipboardSection(LoggedText, IgnoredText)
		Lib:Notify("Logging", "Animation cache cleared", 2, "success")
	end)

	local groupedStyles = {}
	for animationId, info in pairs(GameConfig) do
		local styleName = info.Style
		if not groupedStyles[styleName] then
			groupedStyles[styleName] = {}
		end
		groupedStyles[styleName][animationId] = info
	end
	local styleNumber = 1
	for styleName, animations in pairs(groupedStyles) do
		local styleSection = styleConfigTab:Section(styleName, "Full", "Per-animation reaction times")
		for animationId, info in pairs(animations) do
			local nameLabel = info.DisplayName or tostring(animationId)
			if info.ParryFunction then
				styleSection:Label("Slider unavailable for " .. nameLabel .. " (uses custom function)")
				continue
			end
			AnimationIdSliders[animationId] = styleSection:Slider(
				"Reaction time: " .. nameLabel,
				info.M1Time or info.ReactionTime or DefaultReactionTime,
				0.01,
				0,
				1,
				" s",
				function(value)
					if value ~= DefaultReactionTime then
						info.ReactionTime = value
					end
				end
			)
		end
		styleNumber += 1
	end

	UpdateClipboardSection(LoggedText, IgnoredText)
	UpdateTargetPoolSection()

	local function updateAutoParry()
		local localChar = LocalPlayer.Character
		if not localChar or not localChar:FindFirstChildOfClass("Humanoid") then
			return
		end
		LocalTracker:Update(localChar)
		EvaluateParryTriggers()
		ParryTask()
		schedulerUpdate()

		local now = os.clock()
		if now - LastCycleCheck >= UTILITY_TICK then
			LastCycleCheck = now
			if AUTO_TARGET_NEAREST then
				CycleEvent()
			end
			ProcessEspAndLogging()
		end
	end

	local function cleanup()
		if damageConnection then
			damageConnection:Disconnect()
			damageConnection = nil
		end
		if animationAddedConnection then
			animationAddedConnection:Disconnect()
			animationAddedConnection = nil
		end
		if inputConnection then
			inputConnection:Disconnect()
			inputConnection = nil
		end
		if orbConnection then
			orbConnection:Disconnect()
			orbConnection = nil
		end
		ClearAllEspTrackers()
		ResetParryState()
		table.clear(TargetCharacters)
		table.clear(AnimationRegistry)
		table.clear(scheduler.pendingTasks)
	end

	return {
		Update = updateAutoParry,
		Cleanup = cleanup,
		CycleTargets = CycleEvent,
	}
end
