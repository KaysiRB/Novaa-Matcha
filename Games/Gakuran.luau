local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

--// AUTO PARRY IMPORTS
local ImportESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/matchastuff/main/esp_utility.lua"))()
local ImportAnimationTracker = loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/matchastuff/main/animationtracker.lua"))()

--// AUTO PARRY SETTINGS
local AUTO_PARRY_ENABLED = true
local AUTO_DODGE_ENABLED = true
local AUTO_TARGET_NEAREST = false
local MULTI_TARGET = true
local TARGET_FACING_YOU = false
local YOU_FACING_TARGET = true
local DEBUG_PARRY = false
local INCLUDE_LOCAL_CHARACTER = false
local AUTO_PARRY_RANGE = 10
local MAX_CYCLE_RANGE = 20
local PARRY_WINDOW = 0.06
local PROBABILITY_TO_PARRY = 100
local DEFAULT_REACTION_TIME = 0.1
local PARRY_OFFSET = 0
local BLOCK_HOLD_TIME = 0.4
local PARRY_DISTANCE = 15
local SelectedFolder = nil

--// AUTO PARRY GAME CONFIG
local GameConfig = {
    ["KarateAnims"] = {
        ["rbxassetid://137837926745158"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://100981571094705"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://130865087635587"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://86495068205420"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://120393553812903"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
    },
    ["BasicAnims"] = {
        ["rbxassetid://83491849294956"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://89420531853362"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://83730275893449"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://106980660082799"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://78888626472394"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["M1Time"] = 0.14,
    },
    ["WrestlingAnims"] = {
        ["rbxassetid://91485623489753"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://73748315742870"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://82903450925391"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://119685134442395"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://107464726433388"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["M1Time"] = 0.11,
    },
    ["MuayThaiAnims"] = {
        ["rbxassetid://137034747040618"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://74960202100098"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://104515319350296"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://139911027872047"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://96726284968458"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["M1Time"] = 0.1,
    },
    ["BoxingAnims"] = {
        ["rbxassetid://137980914350618"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.12,
        },
        ["rbxassetid://100408082509740"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.12,
        },
        ["rbxassetid://94803478352691"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://78695517680318"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://132022052139564"] = {
            DisplayName = "M2",
            ParryFunction = function(data)
                if data.RegistryData.Processed == true then warn("no") return end
                data.RegistryData.Processed = true
                task.spawn(function()
                    print("Boxing parry")
                    task.wait(.3)
                    Dodge()
                    task.wait(.35)
                    BlockStart(os.clock(), 0.6)
                end)
            end,
        },
    },
    ["HakariAnims"] = {
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://76236532060812"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://74206130671324"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://71919935695307"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://122861547142657"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://92851992709496"] = {
            DisplayName = "M2",
            ReactionTime = 0.35,
        },
    },
    ["CapoeiraAnims"] = {
        ["rbxassetid://125976167173936"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://134945199381140"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://117877243065533"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://106965238908791"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://131071815103338"] = {
            DisplayName = "Whirlwind",
            ReactionTime = 0.32,
        }
    },
    ["SluggerAnims"] = {
        ["rbxassetid://134829666925953"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.24,
        },
        ["rbxassetid://104867156139010"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://112759168172605"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22
        },
        ["rbxassetid://114647502301740"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.19,
        },
        ["rbxassetid://118943955490014"] = {
            DisplayName = "M2",
            ReactionTime = 0.65,
        }
    },
    ["StrikerAnims"] = {
        ["rbxassetid://127909081017342"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://79563637573277"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://118070233153900"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://77710266587706"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://114364673509520"] = {
            DisplayName = "M2"
        },
        ["rbxassetid://132840225082238"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://88761422474765"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://98462236639320"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://122451562066756"] = {
            DisplayName = "4thM1"
        }
    },
    ["KureAnims"] = {
        ["rbxassetid://71676634048602"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://102407060635393"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.01,
        },
        ["rbxassetid://82904229252991"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://103732110215321"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://103964436023727"] = {
            DisplayName = "3rdM1"
        },
    },
    ["HakariOtherAnims"] = {
        ["rbxassetid://126612786608030"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://113719263885794"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://136305578634960"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://89039586375625"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://101619248052969"] = {
            DisplayName = "M2"
        },
    },
}

local IgnoreIds = {
73766443218740,111699625251889,85823794654077,83600639547203,99661732639863,106268941365574,109816855387997,122561749929324,129805948180599,
90752347516770,135133599113049,132695091086148,137015026151472,114511731321756,122541287927198,80309578200579,100794890036133,109303037515668,117293898907979,74690341409113,73090768467054,72284079162560,92787945841620,89016181362524,
76945839486275,101161965631044,80135556847061,128307941333158,85931837451298,91352556581859, 104407197874289,77911299793653,129335968179665, 122384188141033,
132695766056641,113331696487725,124220338099067,99799500309776,108636808436488,90015977935891,87932588807124,132477488202815,102982320608759,109278619250401,79971841883936,97783129267001,72822821848529,79974955602012,77798715679680,85845666927963,108862846290180,108045962864902,93184693099565,120399899079666,99958962160522,
}

local ParriedAnimation = {"rbxassetid://100773926241456", "rbxassetid://102823909334302", "rbxassetid://96304721384743", "rbxassetid://82979105739696", "rbxassetid://96600699015093", "rbxassetid://138519505081692"}
local StunnedAnimation = {"rbxassetid://9598562590", "rbxassetid://9598537410", "rbxassetid://9598551746"}
local ParryingAnimation = {"rbxassetid://118147060185189"}

--// AUTO PARRY CONFIG FLATTENING
local FlattenedConfig = {}
for styleName, assets in pairs(GameConfig) do
    for assetId, data in pairs(assets) do
        if assetId == "M1Time" then continue end
        if assets["M1Time"] then end
        local flatData = table.clone(data) or {}
        flatData.Style = styleName
        if data.DisplayName ~= "M2" and assets["M1Time"] then
            flatData.ReactionTime = assets["M1Time"]
        elseif not data.ReactionTime then
            flatData.DefaultReactionTime = DEFAULT_REACTION_TIME
        else
            flatData.ReactionTime = data.ReactionTime
        end
        FlattenedConfig[assetId] = flatData
    end
end
GameConfig = FlattenedConfig

--// AUTO PARRY FORWARD DECLARATIONS
local Lib
local LoggedText, IgnoredText, TargetPool_Text

--// AUTO PARRY STATE
local AnimationsLoggedCache = {}
local AnimationsLoggedOrder = {}
local AnimationIdSliders = {}
local scheduler = {}
local pendingTasks = {}
local ParryKey = string.byte("F")
local DodgeKey = string.byte("A")
local KeyHeld = false
local ReleaseDeadline = 0
local Stunned = false
local AnimationTracker = AnimationTracker.new(IgnoreIds)
local LocalTracker = AnimationTracker.new(IgnoreIds)
local damageLoggerConnection = nil
local previousHealth = 100
local lastCharacter = nil
local TargetCharacters = {}
local EspTrackers = {}
local CurrentIndex = 1
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)
local AnimationRegistry = {}
local LastPendingRegData = nil
local InputRegisteredTime = nil
local ParryRegisteredTime = nil
local InputLatency = 0
local DodgeLockoutEnd = 0
local StunToken = 0
local lastParryAt = 0
local animationAddedConnection = nil
local inputBeganConnection = nil
local orbListenerConnection = nil

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

--// AUTO PARRY SCHEDULER
function scheduler.delay(delayTime, callback)
    table.insert(pendingTasks, {
        executeAt = os.clock() + delayTime,
        callback = callback,
    })
end

function scheduler.update()
    local now = os.clock()
    for i = #pendingTasks, 1, -1 do
        local task = pendingTasks[i]
        if now >= task.executeAt then
            table.remove(pendingTasks, i)
            coroutine.wrap(task.callback)()
        end
    end
end

--// AUTO PARRY HELPERS
local function GetAllFoldersInWorkspace()
    local Folders = {}
    for _, Folder in game.Workspace:GetChildren() do
        if Folder.ClassName == "Folder" then
            table.insert(Folders, Folder.Name)
        end
    end
    return Folders
end

local function GetAllCharactersInFolder()
    if not SelectedFolder or not game.Workspace:FindFirstChild(SelectedFolder) then return end
    local Characters = {}
    local folder = game.Workspace[SelectedFolder]
    for _, Character in folder:GetChildren() do
        if Character.ClassName == "Model" and Character:FindFirstChildWhichIsA("Humanoid") then
            if not INCLUDE_LOCAL_CHARACTER then
                if Character.Address == game.Players.LocalPlayer.Character.Address then continue end
            end
            table.insert(Characters, Character)
        end
    end
    return Characters
end

local function UpdateClipboardSection()
    local AnimationsLoggedCount = 0
    for _, _ in AnimationsLoggedCache do
        AnimationsLoggedCount += 1
    end
    if LoggedText then LoggedText:SetText("Logged Ids: " .. AnimationsLoggedCount) end
    if IgnoredText then IgnoredText:SetText("Ignored Ids: " .. #IgnoreIds) end
end

local function UpdateTargetPoolSection()
    local characters = GetAllCharactersInFolder() or {}
    local names = {}
    for i, character in ipairs(characters) do
        table.insert(names, character.Name)
        if i == 10 then table.insert(names, "... (too long)") break end
    end
    local poolString = table.concat(names, ", ")
    if TargetPool_Text then TargetPool_Text:SetText("Target Pool: " .. poolString) end
end

local function SetClipboardLoggedCache()
    local totalItems = #AnimationsLoggedOrder
    if totalItems == 0 then
        print("[Clipboard] Nothing logged to copy.")
        return
    end
    local ids = {}
    for i = 1, totalItems do
        local numericId = tostring(AnimationsLoggedOrder[i]):match("%d+")
        if numericId then
            table.insert(ids, numericId)
        end
    end
    local clipboardString = table.concat(ids, ",")
    setclipboard(clipboardString)
    print(string.format("[Clipboard] Successfully copied %d logged animation IDs!", #ids))
    if Lib then Lib:Notify("Clipboard", string.format("Successfully copied %d logged animation IDs!", #ids), 2, "success") end
end

local function SetClipboardIgnoreList()
    local totalItems = #AnimationsLoggedOrder
    if totalItems == 0 then
        print("[Clipboard] Nothing logged to copy.")
        return
    end
    local newlyAddedIds = {}
    for AnimationId, _ in pairs(AnimationsLoggedCache) do
        local numericId = tonumber(string.match(tostring(AnimationId), "%d+"))
        if numericId then
            table.insert(IgnoreIds, numericId)
            table.insert(newlyAddedIds, tostring(numericId))
        end
    end
    local outputstring = table.concat(newlyAddedIds, ", ")
    setclipboard(outputstring)
    print(string.format("[Clipboard] Copied %d NEW IDs! (Total ignored: %d)", #newlyAddedIds, #IgnoreIds))
end

local function LogAnimation(assetId, trackInfo)
    if not AnimationsLoggedCache[assetId] then
        AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
        table.insert(AnimationsLoggedOrder, assetId)
        UpdateClipboardSection()
    end
end

local function UpdateSliders()
    for animationId, Info in pairs(GameConfig) do
        if AnimationIdSliders[animationId] then
            Info.DefaultReactionTime = DEFAULT_REACTION_TIME
            local ReactionTime = Info.M1Time or Info.ReactionTime or Info.DefaultReactionTime
            AnimationIdSliders[animationId]:Set(ReactionTime)
        end
    end
end

--// AUTO PARRY ORB LISTENER
local function ListenForOrbs()
    print("Listening for orbs")
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local myPosition = hrp.Position
        local ActiveOrbs = {}
        local thrownFolder = game.Workspace:FindFirstChild("Thrown")
        if thrownFolder then
            for _, v in ipairs(thrownFolder:GetChildren()) do
                if (v.Name == "ArdourBall2" or v.Name == "ArdourBall")
                    and v:IsA("BasePart")
                    and v:IsDescendantOf(game.Workspace.Thrown)
                then
                    table.insert(ActiveOrbs, v)
                end
            end
        end
        for i = #ActiveOrbs, 1, -1 do
            local orb = ActiveOrbs[i]
            if orb and orb.Parent then
                local distance = (myPosition - orb.Position).Magnitude
                if distance <= PARRY_DISTANCE and (tick() - lastParryAt >= 0.08) then
                    lastParryAt = tick()
                    print("Ok")
                    BlockStart()
                    BlockEnd()
                    break
                end
            end
        end
    end)
    return connection
end

--// AUTO PARRY CORE FUNCTIONS
local function GetLocalHRP()
    local localChar = LocalPlayer.Character
    local HRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
    return HRP
end

local function checkRange(Studs, Origin)
    local HRP = GetLocalHRP()
    if not HRP then return false end
    return (HRP.Position - Origin.Position).Magnitude < Studs
end

local function ToggleDamageLogger(state)
    if not state then
        if damageLoggerConnection then
            damageLoggerConnection:Disconnect()
            damageLoggerConnection = nil
        end
        print("[Logger] Heartbeat damage logger DISABLED.")
        return
    end
    if damageLoggerConnection then return end
    print("[Logger] Heartbeat damage logger ACTIVE.")
    damageLoggerConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end
        if lastCharacter and (char.Address ~= lastCharacter.Address) then
            lastCharacter = char
            previousHealth = hum.Health
        end
        local currentHealth = hum.Health
        if currentHealth < previousHealth then
            local damageTaken = previousHealth - currentHealth
            if #TargetCharacters then
                local activeAnimations = AnimationTracker:Update(TargetCharacters[1]) or {}
                for _, anim in activeAnimations do
                    if not anim.AnimationId or anim.TimePosition < 0.1 or anim.TimePosition > 0.7 then continue end
                    local assetId = tostring(anim.AnimationId)
                    local poolData = GameConfig[assetId]
                    warn(string.format("[HIT] %d DMG | Anim: %s (%s) %s | Frame Time: %.3f",
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

local function GetHeightMultiplierForCharacter(TargetCharacter)
    local succ, data = pcall(function()
        local stateFolder = TargetCharacter and TargetCharacter:FindFirstChild("PlayerData")
        return stateFolder and stateFolder:GetAttribute("CurrentHeight")
    end)
    if succ then return data else return 1 end
end

local function ResetParryState()
    KeyHeld = false
    ReleaseDeadline = 0
    BlockEnd()
end

function Dodge()
    BlockEnd()
    for i = 1, 12, 1 do
        keypress(DodgeKey)
        keyrelease(DodgeKey)
    end
end

function BlockStart(StartTime, HoldFor)
    if not StartTime then
        warn("Lacking a start time")
        return
    end
    if ParryRegisteredTime then
        local TimeBetweenLastParry = os.clock() - ParryRegisteredTime
        if TimeBetweenLastParry < 0.8 then
            print("parry is gonna be on cooldown")
            return
        end
    end
    if CurrentParryState ~= ParryState.IDLE then
        warn("tried to press in a non idle state")
        return
    end
    local holdFor = HoldFor or BLOCK_HOLD_TIME
    ReleaseDeadline = StartTime + holdFor
    KeyHeld = true
    if AUTO_PARRY_ENABLED then
        if ismouse1pressed() then mouse2click() end
        keypress(ParryKey)
    end
end

function BlockEnd()
    KeyHeld = false
    if AUTO_PARRY_ENABLED then
        keyrelease(ParryKey)
    end
end

--// AUTO PARRY STATE MACHINE
local function TransitionToState(newState)
    print(string.format("[Parry] %s -> %s", CurrentParryState, newState))
    CurrentParryState = newState
end

local function OnInputF()
    if CurrentParryState == ParryState.IDLE then
        InputRegisteredTime = os.clock()
        TransitionToState(ParryState.INPUT_PENDING)
    end
end

local function DebugParry()
    local WeActuallyBlockedAt = ParryRegisteredTime
    local WeWantedToBlockAt = InputRegisteredTime
    local TimeTheServerReceived = InputLatency / 2
    if LastPendingRegData then
        local AnimationStartTime = LastPendingRegData.StartTime
        local BlockStartTime = LastPendingRegData.BlockStart
        local BlockExpire = LastPendingRegData.BlockExpire
        local RelativeBlockStart = BlockStartTime - AnimationStartTime
        local RelativeBlockExpire = BlockExpire - AnimationStartTime
        local ClientReactionTime = WeWantedToBlockAt - AnimationStartTime
        local ServerRelativeTime = (WeActuallyBlockedAt - TimeTheServerReceived) - AnimationStartTime
        local IsSuccess = (ClientReactionTime >= RelativeBlockStart and ClientReactionTime <= RelativeBlockExpire)
        print(string.format(
            "\n================ PARRY DIAGNOSTICS ================\n" ..
            "[NETWORK STATE]\n" ..
            "Total Input Latency:  %.3fs\n" ..
            "One-Way Server Delay: %.3fs\n" ..
            "---------------------------------------------------\n" ..
            "[ANIMATION TIMELINE]\n" ..
            "Target Parry Window:  %.3fs to %.3fs\n" ..
            "Pressed F At:    %.3fs\n" ..
            "Parry Registered At:  %.3fs (ONE-WAY)\n" ..
            "---------------------------------------------------\n" ..
            "[VERDICT]\n" ..
            "Status:               %s\n" ..
            "===================================================",
            InputLatency, TimeTheServerReceived,
            RelativeBlockStart, RelativeBlockExpire,
            ClientReactionTime, ServerRelativeTime,
            IsSuccess and "[SUCCESS]" or "[MISSED WINDOW]"
        ))
    else
        print(string.format(
            "\n============ LATENCY ONLY DIAGNOSTICS ============\n" ..
            "[NETWORK STATE]\n" ..
            "Total Input Latency:  %.3fs\n" ..
            "One-Way Server Delay: %.3fs\n" ..
            "===================================================",
            InputLatency, TimeTheServerReceived
        ))
    end
end

local function OnParryingAnimationSuccess()
    if CurrentParryState == ParryState.INPUT_PENDING then
        ParryRegisteredTime = os.clock()
        InputLatency = os.clock() - InputRegisteredTime
        if DEBUG_PARRY then
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
    local MyToken = StunToken
    scheduler.delay(0.3, function()
        if MyToken == StunToken then
            BlockEnd()
            TransitionToState(ParryState.IDLE)
        end
    end)
end

local function OnSuccessfulParry()
    if CurrentParryState == ParryState.PARRYING then
        local AnimId = LastPendingRegData.AnimationId
        local AttackConfig = GameConfig[AnimId]
        local ParryPressTime = tonumber(InputRegisteredTime - LastPendingRegData.StartTime)
        if ParryPressTime > 1 or ParryPressTime < 0 then return end
        if Lib then
            Lib:Notify("Parry Success",
                string.format("%.3fs  - %s %s", ParryPressTime, AttackConfig.Style, AttackConfig.DisplayName),
                2, "success")
        end
        LastPendingRegData.LearnedParryTime = ParryPressTime
        LastPendingRegData.Success = true
        ParryRegisteredTime = 0
        ResetParryState()
    end
end

local function OnWindowExceeded()
    if CurrentParryState == ParryState.PARRYING then
        if LastPendingRegData and LastPendingRegData.Success then
            LastPendingRegData.Success = false
            TransitionToState(ParryState.IDLE)
        end
    end
end

function GetActiveAnimationsForCharacterAsDictionary(character)
    local ReturnTable = {}
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return {} end
    for _, Anim in activeAnimations do
        if Anim.AnimationId then
            ReturnTable[Anim.AnimationId] = Anim
        end
    end
    return ReturnTable
end

local function ParryTask()
    local now = os.clock()
    if KeyHeld and os.clock() > ReleaseDeadline then
        BlockEnd()
    end
    if CurrentParryState == ParryState.INPUT_PENDING then
        local MaxLatency = 0.5
        local TimePassedSinceFWasPressed = now - InputRegisteredTime
        local ActiveAnims = GetActiveAnimationsForCharacterAsDictionary(LocalPlayer.Character)
        if ActiveAnims and ActiveAnims[ParryingAnimation[1]] then
            OnParryingAnimationSuccess()
        end
        if TimePassedSinceFWasPressed > MaxLatency then
            warn(string.format("Parrying animation didn't appear, probably on CD MAX: %.2f | TIME: %.2f", MaxLatency, TimePassedSinceFWasPressed))
            OnParryingAnimationFailed()
            TransitionToState(ParryState.IDLE)
        end
    elseif CurrentParryState == ParryState.PARRYING then
        if not LastPendingRegData then
            TransitionToState(ParryState.IDLE)
            return
        end
        local BlockExpire = LastPendingRegData.BlockExpire
        local CurrentTime = os.clock()
        if CurrentTime > BlockExpire then
            OnWindowExceeded()
        end
    end
end

--// AUTO PARRY LOCAL ANIMATION HANDLER
local function onLocalAnimationAdded(anim)
    local animId = anim.AnimationId
    if table.find(ParriedAnimation, animId) then
        OnSuccessfulParry()
    end
    if table.find(ParryingAnimation, animId) then
        if not InputRegisteredTime then return end
        OnParryingAnimationSuccess()
    end
    if table.find(StunnedAnimation, animId) then
        OnStunned()
    end
end

animationAddedConnection = LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded)

--// AUTO PARRY EVALUATION
local function ValidateLocalCharacter()
    local localCharacter = LocalPlayer and LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot or Stunned then return nil end
    return localCharacter, localRoot
end

local function ValidateTargetCharacter(character)
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end
    return targetRoot
end

local function CheckCharacterDistance(localRoot, targetRoot)
    return (targetRoot.Position - localRoot.Position).Magnitude
end

local function UpdateCharacterESP(character, Distance)
    if not AUTO_PARRY_ENABLED then
        if EspTrackers[character] and EspTrackers[character].ChangeText then
            EspTrackers[character]:ChangeText("Name", "AUTO PARRY IS DISARMED", COLOR_RED)
        end
        return true
    elseif Distance > AUTO_PARRY_RANGE then
        if EspTrackers[character] and EspTrackers[character].ChangeText then
            EspTrackers[character]:ChangeText("Name", character.Name.. " | OUT OF RANGE", COLOR_RED)
        end
        return false
    else
        if EspTrackers[character] and EspTrackers[character].ChangeText then
            EspTrackers[character]:ChangeText("Name", character.Name.. " IN RANGE", COLOR_GREEN)
        end
        return true
    end
end

local function CalculateParryTiming(attackConfig, StartTime)
    local optimalReactionTime = (attackConfig.ReactionTime or DEFAULT_REACTION_TIME)
    local adjustedReactionTime = optimalReactionTime + PARRY_OFFSET
    local parryWindowStart = adjustedReactionTime
    local parryWindowEnd = adjustedReactionTime + PARRY_WINDOW
    local ClockStart = StartTime + parryWindowStart
    local ClockEnd = StartTime + parryWindowEnd
    return ClockStart, ClockEnd
end

local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig)
    if not AnimationRegistry[animKey] then
        local adjustedNow = now - currentTrackTime
        local BlockStartTime, BlockExpire = CalculateParryTiming(attackConfig, adjustedNow)
        AnimationRegistry[animKey] = {
            StartTime = adjustedNow,
            Processed = false,
            CurrentClockTime = os.clock(),
            CurrentTrackTime = currentTrackTime,
            ReactionTime = attackConfig,
            Ignore = false,
            AnimationId = anim.AnimationId,
            DidALoop = false,
            BlockStart = BlockStartTime,
            BlockExpire = BlockExpire,
            RandomNum = math.random(1, 100),
        }
    end
    local regData = AnimationRegistry[animKey]
    if regData.CurrentTrackTime and (currentTrackTime < regData.CurrentTrackTime) then
        local BlockStartTime, BlockExpire = CalculateParryTiming(attackConfig, now - currentTrackTime)
        regData.Processed = false
        regData.DidALoop = true
        warn("Loop detected")
        regData.BlockStart = BlockStartTime
        regData.BlockExpire = BlockExpire
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
    if character.Address == localCharacter.Address then return true end
    local direction = (targetRoot.Position - localRoot.Position).Unit
    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
    if not isHeavy then
        if TARGET_FACING_YOU and targetRoot.CFrame.LookVector:Dot(-direction) < 0.25 then return false end
        if YOU_FACING_TARGET and localRoot.CFrame.LookVector:Dot(direction) < 0.25 then return false end
    end
    return true
end

local function ExecuteParry(regData, attackConfig)
    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
    if attackConfig.Jump then
        task.spawn(function()
            keypress(32)
            task.wait(.06)
            keyrelease(32)
        end)
        DodgeLockoutEnd = os.clock() + 0.2
    elseif isHeavy and AUTO_DODGE_ENABLED then
        Dodge()
        DodgeLockoutEnd = os.clock() + 0.2
    else
        if LastPendingRegData ~= regData then
            LastPendingRegData = regData
            BlockStart(LastPendingRegData.BlockStart)
        elseif LastPendingRegData == regData then
            if regData.DidALoop then
                print(string.format("Block retriggered for [%s | %s] because its the same key but it looped",
                    attackConfig.Style, attackConfig.DisplayName))
                regData.DidALoop = false
                BlockStart(regData.BlockStart)
            end
        end
    end
end

local function EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    if not anim.AnimationId then return end
    local attackConfig = GameConfig[tostring(anim.AnimationId)]
    if not attackConfig then return end
    local animKey = anim.Address or anim
    currentActiveIds[animKey] = true
    local now = os.clock()
    local regData = UpdateAnimationRegistry(animKey, anim, now, anim.TimePosition or 0, attackConfig)
    if regData.Processed then return end
    if attackConfig.ParryFunction and (now - regData.StartTime) <= (attackConfig.ReactionTime or DEFAULT_REACTION_TIME) + PARRY_WINDOW/2 then
        attackConfig.ParryFunction({
            RegistryData = regData,
            Mob = character,
            AnimationData = anim,
            AnimationTracker = AnimationTracker,
        })
        return
    end
    if not CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig) then return end
    if regData.RandomNum > PROBABILITY_TO_PARRY then
        regData.Processed = true
        return
    end
    if now >= regData.BlockStart and now <= regData.BlockExpire then
        ExecuteParry(regData, attackConfig)
    end
end

local function EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    local targetRoot = ValidateTargetCharacter(character)
    if not targetRoot then return end
    local Distance = CheckCharacterDistance(localRoot, targetRoot)
    if not UpdateCharacterESP(character, Distance) then return end
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return end
    for _, anim in ipairs(activeAnimations) do
        EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    end
end

local function EvaluateParryTriggers()
    local localCharacter, localRoot = ValidateLocalCharacter()
    if not localCharacter or not localRoot then return end
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

--// AUTO PARRY ESP & LOGGING
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
            tracker:ChangeText("CurrentlyPlaying", "None", COLOR_WHITE)
            continue
        end
        for i = 1, #activeAnimations do
            local anim = activeAnimations[i]
            if not anim.AnimationId then continue end
            local assetId = anim.AnimationId
            local numericId = tonumber(string.match(tostring(assetId), "%d+"))
            if numericId and table.find(IgnoreIds, numericId) then continue end
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
                anim.TimePosition or 0.00,
                poolData and poolData.ReactionTime or DEFAULT_REACTION_TIME,
                poolData and "[Logged]" or "[Unknown]",
                anim.Speed
            ))
        end
        if tracker and tracker.Name then
            tracker:ChangeText("CurrentlyPlaying", table.concat(lines, "\n"), COLOR_WHITE)
        end
    end
end

local function ClearAllEspTrackers()
    for char, tracker in pairs(EspTrackers) do
        if tracker and tracker.Destroy then
            if ESP_Utility.TrackersToUpdate[tracker] then
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

function CycleEvent()
    local allCharacters = GetAllCharactersInFolder()
    if not SelectedFolder or not allCharacters then
        UpdateTargetCharacters({})
        return
    end
    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local validCharacters = {}
    for _, char in ipairs(allCharacters) do
        if char == localCharacter then continue end
        local targetRoot = char:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            if distance <= MAX_CYCLE_RANGE then
                table.insert(validCharacters, { Character = char, Distance = distance })
            end
        end
    end
    if #validCharacters == 0 then
        CurrentIndex = 1
        UpdateTargetCharacters({})
        if not AUTO_TARGET_NEAREST and Lib then
            Lib:Notify("Cycle", "No targets found in range [".. MAX_CYCLE_RANGE.." studs]", 2, "warning")
        end
        return
    end
    table.sort(validCharacters, function(a, b)
        return a.Distance < b.Distance
    end)
    if MULTI_TARGET then
        local Max = 3
        local finalTargets = {}
        for i = 1, math.min(Max, #validCharacters) do
            table.insert(finalTargets, validCharacters[i].Character)
        end
        UpdateTargetCharacters(finalTargets)
    else
        CurrentIndex = (CurrentIndex % #validCharacters) + 1
        local targetIndex = AUTO_TARGET_NEAREST and 1 or CurrentIndex
        local selectedCharacter = validCharacters[targetIndex].Character
        UpdateTargetCharacters({selectedCharacter})
    end
end

--// AUTO PARRY INPUT HANDLER
inputBeganConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == string.byte("x") then
        CycleEvent()
    elseif input.KeyCode == string.byte("f") then
        local localChar = LocalPlayer.Character
        LocalTracker:Update(localChar)
        OnInputF()
    end
end)

--// AUTO PARRY ORB LISTENER START
if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then
    orbListenerConnection = ListenForOrbs()
end

--// AUTOPLAY SETTINGS
local AUTOPLAY_ENABLED = false
local SHOW_ESP = false
local SHOW_HIT_LINE = true
local SHOW_CIRCLES = true
local SHOW_HOLD_TAILS = true
local AUTO_DETECT_LANES = true
local REQUIRE_GAME_FOCUS = true
local DEBUG_LOGGING = false
local ACTIVE_LANE_COUNT = 4
local CURRENT_KEYS = {88, 67, 78, 77,}
local LANE_ENABLED = {true, true, true, true}
local LANE_REFRESH_INTERVAL = 0.5
local SCALE_UPDATE_INTERVAL = 0.25
local CONFIG = {
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
        Color3.fromRGB(60, 180, 60),
    },
    COLOR_ON_LINE = Color3.fromRGB(255, 255, 255),
    COLOR_HOLD = Color3.fromRGB(150, 255, 150),
    COLOR_APPROACH = Color3.fromRGB(100, 130, 100),
    LINE_COLOR = Color3.fromRGB(255, 255, 255),
}

--// AUTO-GREEN SETTINGS
local AUTO_GREEN_ENABLED = false
local SHOOT_KEY = 70
local RELEASE_TARGET = 0.274
local DETECT_THRESHOLD = 0.95
local SHOT_TIMEOUT = 3
local shotCount = 0
local shotState = "idle"
local shotStartTime = 0

--// AUTOPLAY STATE
local tapHeld = {}
local tapReleaseAt = {}
local holdActive = {}
local holdStartAt = {}
local seenNotes = {}
local lanesValid = false
local laneData = nil
local notesContainer = nil
local espScale = 1
local lastLaneRefresh = 0
local lastScaleUpdate = 0
local lastCleanupTime = 0
local CLEANUP_INTERVAL = 0.02

--// DRAWINGS
local hitLine = Drawing.new("Line")
hitLine.Color = CONFIG.LINE_COLOR
hitLine.Thickness = CONFIG.LINE_THICK
hitLine.Visible = false
hitLine.ZIndex = 5
local circles = {}
local tails = {}
for lane = 1, 4 do
    circles[lane] = {}
    tails[lane] = {}
    seenNotes[lane] = {}
    for i = 1, CONFIG.MAX_CIRCLES do
        local circle = Drawing.new("Circle")
        circle.NumSides = CONFIG.CIRCLE_SIDES
        circle.Radius = CONFIG.CIRCLE_RADIUS
        circle.Thickness = CONFIG.CIRCLE_THICK
        circle.Filled = false
        circle.Visible = false
        circle.ZIndex = 10
        circles[lane][i] = circle
        local tail = Drawing.new("Line")
        tail.Thickness = CONFIG.TAIL_THICK
        tail.Visible = false
        tail.ZIndex = 9
        tails[lane][i] = tail
    end
end

--// HELPERS
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end
local function debugLog(message, ...)
    if DEBUG_LOGGING then
        print(string.format(message, ...))
    end
end
local function isLaneEnabled(lane)
    return LANE_ENABLED[lane] ~= false
end

--// DRAWING CLEANUP
local function removeDrawing(object)
    if not object then
        return
    end
    pcall(function()
        object:Remove()
    end)
end
local function hideESP()
    hitLine.Visible = false
    for lane = 1, 4 do
        for i = 1, CONFIG.MAX_CIRCLES do
            circles[lane][i].Visible = false
            tails[lane][i].Visible = false
        end
    end
end
local function clearDrawings()
    removeDrawing(hitLine)
    for lane = 1, 4 do
        for i = 1, CONFIG.MAX_CIRCLES do
            removeDrawing(circles[lane][i])
            removeDrawing(tails[lane][i])
        end
    end
end
local function releaseAllKeys()
    for lane = 1, 4 do
        if CURRENT_KEYS[lane] then
            keyrelease(CURRENT_KEYS[lane])
        end
        tapHeld[lane] = false
        holdActive[lane] = nil
        holdStartAt[lane] = 0
        seenNotes[lane] = {}
    end
    if shotState ~= "idle" then
        keyrelease(SHOOT_KEY)
        shotState = "idle"
    end
end

--// RHYTHM UI
local function isRhythmUIGone()
    local playerGui = safeCall(function()
        return LocalPlayer.PlayerGui
    end)
    if not playerGui then
        return true
    end
    local rhythmUI = safeCall(function()
        return playerGui:FindFirstChild("RhythmServiceUI")
    end)
    return not rhythmUI
end
local function refreshLanes()
    local playerGui = safeCall(function()
        return LocalPlayer.PlayerGui
    end)
    if not playerGui then
        return false
    end
    local rhythmUI = safeCall(function()
        return playerGui:FindFirstChild("RhythmServiceUI")
    end)
    if not rhythmUI then
        return false
    end
    local rhythmRoot = safeCall(function()
        return rhythmUI:FindFirstChild("RhythmRoot")
    end)
    if not rhythmRoot then
        return false
    end
    local lanesFrame = safeCall(function()
        return rhythmRoot:FindFirstChild("Lanes")
    end)
    local receptors = safeCall(function()
        return rhythmRoot:FindFirstChild("Receptors")
    end)
    if not receptors or not lanesFrame then
        return false
    end
    notesContainer = lanesFrame
    local receptorsFound = {}
    local count = 0
    for i = 1, 4 do
        local receptor = safeCall(function()
            return receptors:FindFirstChild("Receptor" .. i)
        end)
        if receptor then
            local pos = safeCall(function()
                return receptor.AbsolutePosition
            end)
            local size = safeCall(function()
                return receptor.AbsoluteSize
            end)
            if pos and size then
                receptorsFound[i] = {
                    inst = receptor,
                    cx = pos.X + size.X / 2,
                    cy = pos.Y + size.Y / 2,
                    hitY = pos.Y + size.Y / 2,
                }
                count += 1
            end
        end
    end
    if count == 0 then
        return false
    end
    ACTIVE_LANE_COUNT = count
    if AUTO_DETECT_LANES and ACTIVE_LANE_COUNT == 2 then
        CURRENT_KEYS = {
            70,
            74
        }
    else
        CURRENT_KEYS = {
            88,
            67,
            78,
            77
        }
        ACTIVE_LANE_COUNT = 4
    end
    laneData = receptorsFound
    local camera = Workspace.CurrentCamera
    local scale = 1
    if camera then
        scale = camera.ViewportSize.Y / 1080
    end
    local leftCx = (receptorsFound[1] and receptorsFound[1].cx or 0) - 50 * scale
    local rightCx = (receptorsFound[ACTIVE_LANE_COUNT] and receptorsFound[ACTIVE_LANE_COUNT].cx or 0) + 50 * scale
    local hitY = receptorsFound[1].hitY
    hitLine.From = Vector2.new(leftCx, hitY)
    hitLine.To = Vector2.new(rightCx, hitY)
    if AUTOPLAY_ENABLED and SHOW_ESP then
        hitLine.Visible = true
    end
    lanesValid = true
    return true
end
local function cleanupStaleNotes()
    local now = os.clock()
    if now - lastCleanupTime < CLEANUP_INTERVAL then
        return
    end
    lastCleanupTime = now
    for lane = 1, 4 do
        local laneNotes = seenNotes[lane]
        for note in pairs(laneNotes) do
            if not safeCall(function()
                return note.Parent
            end) then
                laneNotes[note] = nil
            end
        end
    end
end

--// AUTO-GREEN
local function getBasketballMeter()
    local playerName = safeCall(function()
        return LocalPlayer.Name
    end)
    if not playerName then
        return nil
    end
    local player = safeCall(function()
        return Workspace.Players:FindFirstChild(playerName)
    end)
    local character = player and safeCall(function()
        return player:FindFirstChild("HumanoidRootPart")
    end)
    local attach = character and safeCall(function()
        return character:FindFirstChild("BasketballShotMeterAttach")
    end)
    local billboard = attach and safeCall(function()
        return attach:FindFirstChild("BasketballShotBillboard")
    end)
    local root = billboard and safeCall(function()
        return billboard:FindFirstChild("Root")
    end)
    local meter = root and safeCall(function()
        return root:FindFirstChild("Meter")
    end)
    return meter
end
local function getNeedleProgress(meter)
    local needle = safeCall(function()
        return meter:FindFirstChild("Needle")
    end)
    if not needle then
        return nil
    end
    local needlePos = safeCall(function()
        return needle.AbsolutePosition
    end)
    local needleSize = safeCall(function()
        return needle.AbsoluteSize
    end)
    local meterPos = safeCall(function()
        return meter.AbsolutePosition
    end)
    local meterSize = safeCall(function()
        return meter.AbsoluteSize
    end)
    if not needlePos or not needleSize or not meterPos or not meterSize or meterSize.Y <= 0 then
        return nil
    end
    local needleCenterY = needlePos.Y + needleSize.Y / 2
    local progress = (needleCenterY - meterPos.Y) / meterSize.Y
    return math.clamp(progress, 0, 1)
end
local function updateAutoGreen(now)
    if not AUTO_GREEN_ENABLED then
        return
    end
    local meter = getBasketballMeter()
    local needle = meter and safeCall(function()
        return meter:FindFirstChild("Needle")
    end)
    if not meter or not needle then
        if shotState ~= "idle" then
            debugLog("[Shot #%d] ended (meter gone)", shotCount)
            shotState = "idle"
        end
        return
    end
    local progress = getNeedleProgress(meter)
    if not progress then
        return
    end
    if shotState == "idle" then
        if progress > DETECT_THRESHOLD then
            shotState = "tracking"
            shotStartTime = now
            shotCount += 1
            debugLog("[Shot #%d] detected at %.2f%%", shotCount, progress * 100)
        end
    elseif shotState == "tracking" then
        if progress <= RELEASE_TARGET then
            shotState = "idle"
            debugLog("[Shot #%d] RELEASE at %.2f%% (target %.2f%%)", shotCount, progress * 100, RELEASE_TARGET * 100)
            keyrelease(SHOOT_KEY)
        elseif progress <= 0.01 then
            debugLog("[Shot #%d] RELEASE at %.2f%% (reached top)", shotCount, progress * 100)
            keyrelease(SHOOT_KEY)
            shotState = "idle"
        elseif now - shotStartTime > SHOT_TIMEOUT then
            debugLog("[Shot #%d] RELEASE at %.2f%% (timeout)", shotCount, progress * 100)
            keyrelease(SHOOT_KEY)
            shotState = "idle"
        end
    end
end

--// AUTOPLAY
local function updateAutoplay(now)
    if not AUTOPLAY_ENABLED then
        hideESP()
        return
    end
    if now - lastScaleUpdate >= SCALE_UPDATE_INTERVAL then
        lastScaleUpdate = now
        local camera = Workspace.CurrentCamera
        if camera then
            espScale = camera.ViewportSize.Y / 1080
        end
    end
    if now - lastLaneRefresh >= LANE_REFRESH_INTERVAL then
        lastLaneRefresh = now
        if lanesValid then
            if isRhythmUIGone() then
                lanesValid = false
                hideESP()
                releaseAllKeys()
            end
        else
            refreshLanes()
        end
    end
    if not lanesValid or not laneData then
        return
    end
    if SHOW_ESP and SHOW_HIT_LINE then
        hitLine.Thickness = CONFIG.LINE_THICK * espScale
        hitLine.Visible = true
    else
        hitLine.Visible = false
    end
    for lane = 1, 4 do
        for i = 1, CONFIG.MAX_CIRCLES do
            circles[lane][i].Visible = false
            tails[lane][i].Visible = false
        end
    end
    for lane = 1, ACTIVE_LANE_COUNT do
        if not isLaneEnabled(lane) then
            continue
        end
        local key = CURRENT_KEYS[lane]
        if tapHeld[lane] and now >= tapReleaseAt[lane] then
            keyrelease(key)
            tapHeld[lane] = false
        end
        if holdActive[lane] then
            local hold = holdActive[lane]
            local invalid = false
            local parent = safeCall(function()
                return hold.inst.Parent
            end)
            if not parent then
                invalid = true
            else
                local head = safeCall(function()
                    return hold.inst:FindFirstChild("Head")
                end)
                if not head then
                    invalid = true
                else
                    local headPos = safeCall(function()
                        return head.AbsolutePosition
                    end)
                    local headSize = safeCall(function()
                        return head.AbsoluteSize
                    end)
                    if not headPos or not headSize then
                        invalid = true
                    else
                        local headY = headPos.Y + headSize.Y / 2
                        local tail = safeCall(function()
                            return hold.inst:FindFirstChild("Tail")
                        end)
                        local tailH = tail and safeCall(function()
                            return tail.AbsoluteSize.Y
                        end) or 0
                        local catchY = laneData[lane].hitY
                        if tailH < 2 or headY - tailH >= catchY then
                            invalid = true
                        end
                    end
                end
            end
            if invalid then
                keyrelease(key)
                holdActive[lane] = nil
                holdStartAt[lane] = 0
            end
        end
    end
    cleanupStaleNotes()
    local children = safeCall(function()
        return notesContainer:GetChildren()
    end)
    if not children then
        return
    end
    local notesByLane = {
        {},
        {},
        {},
        {},
    }
    for _, note in ipairs(children) do
        if safeCall(function()
            return note.ClassName
        end) ~= "Frame" then
            continue
        end
        if safeCall(function()
            return note.Name
        end) ~= "NoteTemplate" then
            continue
        end
        local head = safeCall(function()
            return note:FindFirstChild("Head")
        end)
        if not head then
            continue
        end
        local headPos = safeCall(function()
            return head.AbsolutePosition
        end)
        local headSize = safeCall(function()
            return head.AbsoluteSize
        end)
        if not headPos or not headSize then
            continue
        end
        local headCX = headPos.X + headSize.X / 2
        local headCY = headPos.Y + headSize.Y / 2
        local nearestLane = nil
        local nearestDist = math.huge
        for lane = 1, ACTIVE_LANE_COUNT do
            if not laneData[lane] or not isLaneEnabled(lane) then
                continue
            end
            local dist = math.abs(headCX - laneData[lane].cx)
            if dist < nearestDist then
                nearestDist = dist
                nearestLane = lane
            end
        end
        if not nearestLane or nearestDist > CONFIG.MIN_DIST_X then
            continue
        end
        local laneNotes = seenNotes[nearestLane]
        if laneNotes[note] then
            if not safeCall(function()
                return note.Parent
            end) then
                laneNotes[note] = nil
            end
            continue
        end
        local catchY = laneData[nearestLane].hitY
        local distToLine = headCY - catchY
        if distToLine > CONFIG.PAST_CATCH then
            laneNotes[note] = true
            continue
        end
        if distToLine < - CONFIG.APPROACH_DIST then
            continue
        end
        local tail = safeCall(function()
            return note:FindFirstChild("Tail")
        end)
        local tailH = tail and safeCall(function()
            return tail.AbsoluteSize.Y
        end) or 0
        local isHold = tailH > CONFIG.HOLD_MIN_H
        table.insert(notesByLane[nearestLane], {
            note = note,
            headCY = headCY,
            dist = distToLine,
            isHold = isHold,
            tailH = tailH,
        })
    end
    for lane = 1, ACTIVE_LANE_COUNT do
        if not isLaneEnabled(lane) then
            continue
        end
        local key = CURRENT_KEYS[lane]
        if not laneData[lane] then
            continue
        end
        local laneCX = laneData[lane].cx
        local laneNotes = notesByLane[lane]
        local seen = seenNotes[lane]
        table.sort(laneNotes, function(a, b)
            return a.headCY < b.headCY
        end)
        for i, noteInfo in ipairs(laneNotes) do
            if i > CONFIG.MAX_CIRCLES then
                break
            end
            local onLine = noteInfo.dist >= - CONFIG.TOUCH_DIST and noteInfo.dist <= CONFIG.PAST_CATCH
            if SHOW_ESP then
                local circle = circles[lane][i]
                local tail = tails[lane][i]
                local color
                if onLine then
                    color = CONFIG.COLOR_ON_LINE
                elseif noteInfo.dist < - CONFIG.TOUCH_DIST then
                    local t = 1 - math.abs(noteInfo.dist) / CONFIG.APPROACH_DIST
                    local laneColor = CONFIG.LANE_COLORS[lane]
                    color = Color3.new(
						CONFIG.COLOR_APPROACH.R + (laneColor.R - CONFIG.COLOR_APPROACH.R) * t, CONFIG.COLOR_APPROACH.G + (laneColor.G - CONFIG.COLOR_APPROACH.G) * t, CONFIG.COLOR_APPROACH.B + (laneColor.B - CONFIG.COLOR_APPROACH.B) * t)
                else
                    color = noteInfo.isHold and CONFIG.COLOR_HOLD or CONFIG.LANE_COLORS[lane]
                end
                if SHOW_CIRCLES then
                    circle.Color = color
                    circle.Radius = CONFIG.CIRCLE_RADIUS * espScale
                    circle.Thickness = CONFIG.CIRCLE_THICK * espScale
                    circle.Filled = noteInfo.isHold and not onLine
                    circle.Position = Vector2.new(laneCX, noteInfo.headCY)
                    circle.Visible = true
                end
                if SHOW_HOLD_TAILS and noteInfo.isHold and noteInfo.tailH > 0 then
                    tail.From = Vector2.new(laneCX, noteInfo.headCY)
                    tail.To = Vector2.new(laneCX, noteInfo.headCY - noteInfo.tailH)
                    tail.Thickness = CONFIG.TAIL_THICK * espScale
                    tail.Color = color
                    tail.Visible = true
                end
            end
            if onLine and not tapHeld[lane] and not holdActive[lane] then
                seen[noteInfo.note] = true
                if noteInfo.isHold then
                    keypress(key)
                    holdActive[lane] = {
                        inst = noteInfo.note,
                        tailH = noteInfo.tailH,
                    }
                    holdStartAt[lane] = now
                else
                    keypress(key)
                    tapHeld[lane] = true
                    tapReleaseAt[lane] = now + CONFIG.TAP_HOLD_SEC
                end
                break
            end
        end
    end
end

--// STATE
local autoplayToggle
local autoGreenToggle
local function setAutoplayEnabled(value)
    AUTOPLAY_ENABLED = value == true
    if not AUTOPLAY_ENABLED then
        releaseAllKeys()
        hideESP()
        lanesValid = false
    end
end
local function setShowESP(value)
    SHOW_ESP = value == true
    if not SHOW_ESP then
        hideESP()
    end
end
local function setAutoGreenEnabled(value)
    AUTO_GREEN_ENABLED = value == true
    if not AUTO_GREEN_ENABLED and shotState ~= "idle" then
        keyrelease(SHOOT_KEY)
        shotState = "idle"
    end
end

--// CLEANUP
_G.Gakuran_Cleanup = function()
    releaseAllKeys()
    hideESP()
    clearDrawings()
    lanesValid = false
    laneData = nil
    notesContainer = nil
    shotState = "idle"
    if animationAddedConnection then
        animationAddedConnection:Disconnect()
        animationAddedConnection = nil
    end
    if inputBeganConnection then
        inputBeganConnection:Disconnect()
        inputBeganConnection = nil
    end
    if orbListenerConnection then
        orbListenerConnection:Disconnect()
        orbListenerConnection = nil
    end
    if damageLoggerConnection then
        damageLoggerConnection:Disconnect()
        damageLoggerConnection = nil
    end
    ClearAllEspTrackers()
    table.clear(AnimationRegistry)
    LastPendingRegData = nil
end
if _G.Gakuran_Running then
    _G.Gakuran_Running = false
    if _G.Gakuran_Cleanup then
        pcall(_G.Gakuran_Cleanup)
    end
    task.wait(0.1)
end
_G.Gakuran_Running = true

--// LOAD UI
Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui
local win = Lib:CreateWindow({
    title = "Novaa - v1.0.0",
    subtitle = "auto",
    logo = "https://raw.githubusercontent.com/KaysiRB/Novaa-Matcha/main/Utils/Logos/Stellar.png",
    menuKey = "LeftControl",
    configName = "Gakuran",
    configFolder = "Novaa",
    autoSave = true,
    font = "Minecraft",
    size = Vector2.new(700, 540),
    opacity = 98,
    keybindOverlay = false,
    smartFps = false,
    checkboxStyle = true,
})
Lib:ApplyThemePreset("Waifu")
win:AddSettingsTab("gear")
Lib:Notify("Novaa", "Press LeftControl to toggle the menu", 4, "info")
Lib:Category("Games")

--// GAME INFO
local gameInfoTab = win:Tab("Game", "gamepad")
local gameInfo = gameInfoTab:Section("Game Info", "Full", "Information about the current game")
gameInfo:Label("Game: " .. getgamename())
gameInfo:Label("Place: " .. game.Name)
gameInfo:Label("GameID: " .. game.GameId)
gameInfo:Label("PlaceID: " .. game.PlaceId)
gameInfo:Label("JobID: " .. game.JobId)

--// AUTO PARRY
local autoParryTab = win:Tab("Auto Parry", "swords")
local apFilesSection = autoParryTab:Section("Files", "Full", "Load and save auto parry configuration")
local apConfigSection = autoParryTab:Section("Global Configuration", "Full", "Parry timing and probability settings")
local apSettingsSection = autoParryTab:Section("Settings", "Full", "Auto parry behavior and targeting")
local apFoldersSection = autoParryTab:Section("Folders", "Full", "Target folder and cycle range")
local apLoggingSection = autoParryTab:Section("Logging", "Full", "Animation logging and clipboard utilities")

apFilesSection:Info("Game: Gakuran")
apFilesSection:Button("Load Configuration", function()
    Lib:LoadConfig("Gakuran")
    Lib:Notify("Success", "Loaded configuration", 2, "success")
end)
apFilesSection:Button("Save Configuration", function()
    Lib:SaveConfig("Gakuran")
    Lib:Notify("Success", "Saved configuration", 2, "success")
end)

apConfigSection:Toggle("Debug Parry", DEBUG_PARRY, function(value)
    DEBUG_PARRY = value
end)
local offsetSlider = apConfigSection:Slider("Parry offset", PARRY_OFFSET, 0.01, -0.1, 0.1, "s", function(value)
    PARRY_OFFSET = value
end)
offsetSlider:Set(PARRY_OFFSET)
apConfigSection:Info("Positive moves window forward making you parry later, Negative moves it backwards making you parry earlier")
local rangeSlider = apConfigSection:Slider("Auto Parry Range", AUTO_PARRY_RANGE, 1, 7, 80, " studs", function(value)
    AUTO_PARRY_RANGE = value
end)
rangeSlider:Set(AUTO_PARRY_RANGE)
local probabilitySlider = apConfigSection:Slider("Probability To Parry", PROBABILITY_TO_PARRY, 1, 1, 100, "%", function(value)
    PROBABILITY_TO_PARRY = value
end)
probabilitySlider:Set(PROBABILITY_TO_PARRY)

apSettingsSection:Info("Press X to target someone or enable Auto Target Nearest")
local autoParryToggle = apSettingsSection:Toggle("Auto Parry", AUTO_PARRY_ENABLED, function(value)
    AUTO_PARRY_ENABLED = value
    Lib:Notify("Auto Parry", AUTO_PARRY_ENABLED and "Enabled" or "Disabled", 2, AUTO_PARRY_ENABLED and "success" or "warning")
end)
autoParryToggle:AddKeybind("G", "Toggle")
apSettingsSection:Toggle("Auto Dodge", AUTO_DODGE_ENABLED, function(value)
    AUTO_DODGE_ENABLED = value
end)
apSettingsSection:Toggle("Auto Target Nearest", AUTO_TARGET_NEAREST, function(value)
    AUTO_TARGET_NEAREST = value
end)
apSettingsSection:Toggle("Multiple Targets", MULTI_TARGET, function(value)
    MULTI_TARGET = value
end)
apSettingsSection:Divider("Conditions")
apSettingsSection:Toggle("Target facing you", TARGET_FACING_YOU, function(value)
    TARGET_FACING_YOU = value
end)
apSettingsSection:Toggle("You facing target", YOU_FACING_TARGET, function(value)
    YOU_FACING_TARGET = value
end)

local maxCycleSlider = apFoldersSection:Slider("Max Cycle Range", MAX_CYCLE_RANGE, 1, 7, 50, " studs", function(value)
    MAX_CYCLE_RANGE = value
end)
maxCycleSlider:Set(MAX_CYCLE_RANGE)
apFoldersSection:Toggle("Include Local Character", INCLUDE_LOCAL_CHARACTER, function(value)
    INCLUDE_LOCAL_CHARACTER = value
    UpdateTargetPoolSection()
end)
TargetPool_Text = apFoldersSection:Label("NO TARGETS FOUND")
local folderDropdown = apFoldersSection:Dropdown("Live Folder", nil, GetAllFoldersInWorkspace(), false, function(list)
    local Selected = list[1]
    SelectedFolder = Selected
    UpdateTargetPoolSection()
end)
if game.Workspace:FindFirstChild("Players") then
    folderDropdown:Set({"Players"})
elseif game.Workspace:FindFirstChild("Live") then
    folderDropdown:Set({"Live"})
end

LoggedText = apLoggingSection:Label("Logged Ids: ?")
IgnoredText = apLoggingSection:Label("Ignored Ids: ?")
UpdateClipboardSection()
apLoggingSection:Toggle("Damage Logs", false, function(value)
    ToggleDamageLogger(value)
end)
apLoggingSection:Button("Add unknowns to ignore and copy ignore list", function()
    SetClipboardIgnoreList()
    AnimationsLoggedCache = {}
    AnimationsLoggedOrder = {}
    UpdateClipboardSection()
end)
apLoggingSection:Button("Copy to clipboard", function()
    SetClipboardLoggedCache()
end)
apLoggingSection:Button("Clear animation cache", function()
    AnimationsLoggedCache = {}
    AnimationsLoggedOrder = {}
    UpdateClipboardSection()
end)

--// AUTO PARRY STYLE CONFIGURATIONS
local styleConfigTab = win:Tab("Style Configurations", "swords")
local GroupedStyles = {}
for animationId, Info in pairs(GameConfig) do
    local StyleName = Info.Style
    if not GroupedStyles[StyleName] then
        GroupedStyles[StyleName] = {}
    end
    GroupedStyles[StyleName][animationId] = Info
end
local styleNumber = 1
for StyleName, Animations in pairs(GroupedStyles) do
    local StyleSection = styleConfigTab:Section(StyleName, "Full")
    for animationId, Info in pairs(Animations) do
        local nameLabel = Info.DisplayName or tostring(animationId)
        if Info["ParryFunction"] then
            StyleSection:Info("Slider not possible for " .. nameLabel .. " since it uses a function")
            continue
        end
        AnimationIdSliders[animationId] = StyleSection:Slider("Reaction Time: " .. nameLabel, 0, 0.01, 0, 1, "s", function(value)
            if value ~= DEFAULT_REACTION_TIME then
                Info.ReactionTime = value
            end
        end)
        AnimationIdSliders[animationId]:Set(Info.M1Time or Info.ReactionTime or DEFAULT_REACTION_TIME)
    end
    styleNumber += 1
end
local defaultSection = styleConfigTab:Section("Default Configuration", "Full")
local defaultTimeSlider = defaultSection:Slider("Default Reaction Time", DEFAULT_REACTION_TIME, 0.01, 0, 1, "s", function(value)
    DEFAULT_REACTION_TIME = value
    UpdateSliders()
end)
defaultTimeSlider:Set(DEFAULT_REACTION_TIME)
defaultSection:Info("Reaction time is the time you press F from the moment the animation starts playing. It does not account for ping")
defaultSection:Divider("Window")
local windowSlider = defaultSection:Slider("Default Parry Window", PARRY_WINDOW, 0.01, 0, 1, "s", function(value)
    PARRY_WINDOW = value
end)
windowSlider:Set(PARRY_WINDOW)
defaultSection:Info("This is usually constant, don't change this.")

--// AUTOPLAY
local autoplayTab = win:Tab("Autoplay", "sparkles")
local autoplaySection = autoplayTab:Section("Gakuran Autoplay", "Full", "Automatic rhythm note inputs and visual overlay")
autoplayToggle = autoplaySection:Toggle("Enabled", AUTOPLAY_ENABLED, function(value)
    setAutoplayEnabled(value)
    Lib:Notify("Gakuran Autoplay", AUTOPLAY_ENABLED and "Enabled" or "Disabled", 2, AUTOPLAY_ENABLED and "success" or "warning")
end)
autoplayToggle:AddKeybind("P", "Toggle")
autoplaySection:Divider("Visuals")
autoplaySection:Toggle("Show ESP", SHOW_ESP, function(value)
    setShowESP(value)
end)
autoplaySection:Toggle("Hit line", SHOW_HIT_LINE, function(value)
    SHOW_HIT_LINE = value
    if not SHOW_HIT_LINE then
        hitLine.Visible = false
    end
end)
autoplaySection:Toggle("Note circles", SHOW_CIRCLES, function(value)
    SHOW_CIRCLES = value
end)
autoplaySection:Toggle("Hold tails", SHOW_HOLD_TAILS, function(value)
    SHOW_HOLD_TAILS = value
end)
autoplaySection:Slider("Circle radius", CONFIG.CIRCLE_RADIUS, 1, 5, 50, " px", function(value)
    CONFIG.CIRCLE_RADIUS = value
end)
autoplaySection:Slider("Line thickness", CONFIG.LINE_THICK, 1, 1, 10, " px", function(value)
    CONFIG.LINE_THICK = value
end)
autoplaySection:Slider("Max notes shown", CONFIG.MAX_CIRCLES, 1, 1, 16, "", function(value)
    CONFIG.MAX_CIRCLES = math.floor(value)
end)
autoplaySection:Divider("Timing")
autoplaySection:Slider("Tap hold duration", CONFIG.TAP_HOLD_SEC * 1000, 1, 10, 200, " ms", function(value)
    CONFIG.TAP_HOLD_SEC = value / 1000
end)
autoplaySection:Slider("Touch distance", CONFIG.TOUCH_DIST, 1, 5, 80, " px", function(value)
    CONFIG.TOUCH_DIST = value
end)
autoplaySection:Slider("Past catch window", CONFIG.PAST_CATCH, 1, 5, 80, " px", function(value)
    CONFIG.PAST_CATCH = value
end)
autoplaySection:Slider("Approach distance", CONFIG.APPROACH_DIST, 10, 50, 600, " px", function(value)
    CONFIG.APPROACH_DIST = value
end)
autoplaySection:Slider("Lane match tolerance", CONFIG.MIN_DIST_X, 5, 25, 250, " px", function(value)
    CONFIG.MIN_DIST_X = value
end)
autoplaySection:Slider("Hold min height", CONFIG.HOLD_MIN_H, 1, 5, 80, " px", function(value)
    CONFIG.HOLD_MIN_H = value
end)
autoplaySection:Slider("Lane refresh rate", LANE_REFRESH_INTERVAL * 1000, 50, 100, 2000, " ms", function(value)
    LANE_REFRESH_INTERVAL = value / 1000
end)
autoplaySection:Divider("Lanes")
autoplaySection:Toggle("Auto-detect lane count", AUTO_DETECT_LANES, function(value)
    AUTO_DETECT_LANES = value
    lanesValid = false
end)
for lane = 1, 4 do
    autoplaySection:Toggle("Lane " .. lane, LANE_ENABLED[lane], function(value)
        LANE_ENABLED[lane] = value
        if not value and tapHeld[lane] then
            keyrelease(CURRENT_KEYS[lane])
            tapHeld[lane] = false
        end
        if not value and holdActive[lane] then
            keyrelease(CURRENT_KEYS[lane])
            holdActive[lane] = nil
        end
    end)
end

--// AUTO-GREEN
local autoGreenTab = win:Tab("Auto-Green", "target")
local autoGreenSection = autoGreenTab:Section("Gakuran Auto-Green", "Full", "Automatic perfect basketball shot timing")
autoGreenToggle = autoGreenSection:Toggle("Enabled", AUTO_GREEN_ENABLED, function(value)
    setAutoGreenEnabled(value)
    Lib:Notify("Gakuran Auto-Green", AUTO_GREEN_ENABLED and "Enabled" or "Disabled", 2, AUTO_GREEN_ENABLED and "success" or "warning")
end)
autoGreenToggle:AddKeybind("G", "Toggle")
autoGreenSection:Slider("Release target %", RELEASE_TARGET * 100, 0.1, 10, 80, "%", function(value)
    RELEASE_TARGET = value / 100
    Lib:Notify("Auto-Green", "Release target: " .. value .. "%", 2, "info")
end)
autoGreenSection:Slider("Detect threshold %", DETECT_THRESHOLD * 100, 0.5, 80, 99, "%", function(value)
    DETECT_THRESHOLD = value / 100
end)
autoGreenSection:Slider("Shot timeout", SHOT_TIMEOUT, 0.5, 1, 8, " s", function(value)
    SHOT_TIMEOUT = value
end)
autoGreenSection:Slider("Shoot key code", SHOOT_KEY, 1, 65, 90, "", function(value)
    SHOOT_KEY = math.floor(value)
end)
autoGreenSection:Info("The release target % controls when the shot is released.\n\n" .. "Slide UP = releases earlier (higher %)\n" .. "Slide DOWN = releases later (lower %)\n\n" .. "Different in-game heights may need slight adjustments to hit 100% perfects consistently. " .. "Start around 27-28% and tweak from there.")

--// GAME SETTINGS
local gameSettingsTab = win:Tab("Game Settings", "cog")
local rhythmColors = gameSettingsTab:Section("Gakuran Colors", "Full", "Autoplay visual colors")
rhythmColors:Colorpicker("Hit line", CONFIG.LINE_COLOR, function(color)
    CONFIG.LINE_COLOR = color
    hitLine.Color = color
end)
rhythmColors:Colorpicker("Circle", CONFIG.LANE_COLORS[1], function(color)
    CONFIG.LANE_COLORS[1] = color
    CONFIG.LANE_COLORS[2] = color
    CONFIG.LANE_COLORS[3] = color
    CONFIG.LANE_COLORS[4] = color
end)
rhythmColors:Colorpicker("Hold note", CONFIG.COLOR_HOLD, function(color)
    CONFIG.COLOR_HOLD = color
end)
rhythmColors:Colorpicker("On-line note", CONFIG.COLOR_ON_LINE, function(color)
    CONFIG.COLOR_ON_LINE = color
end)
rhythmColors:Colorpicker("Approach note", CONFIG.COLOR_APPROACH, function(color)
    CONFIG.COLOR_APPROACH = color
end)
rhythmColors:Divider("Per-lane colors")
for lane = 1, 4 do
    rhythmColors:Colorpicker("Lane " .. lane, CONFIG.LANE_COLORS[lane], function(color)
        CONFIG.LANE_COLORS[lane] = color
    end)
end
local rhythmAdvanced = gameSettingsTab:Section("Gakuran Advanced", "Full", "Miscellaneous script behavior")
rhythmAdvanced:Toggle("Require game focus", REQUIRE_GAME_FOCUS, function(value)
    REQUIRE_GAME_FOCUS = value
end)
rhythmAdvanced:Toggle("Debug logging", DEBUG_LOGGING, function(value)
    DEBUG_LOGGING = value
end)
rhythmAdvanced:Slider("Circle thickness", CONFIG.CIRCLE_THICK, 1, 1, 8, " px", function(value)
    CONFIG.CIRCLE_THICK = value
end)
rhythmAdvanced:Slider("Tail thickness", CONFIG.TAIL_THICK, 1, 1, 12, " px", function(value)
    CONFIG.TAIL_THICK = value
end)
Lib:Category("Universal")

--// VISUALS
local visuals = win:Tab("Visuals", "eye")
local universalVisuals = visuals:Section("Universal Visuals", "Full", "Features shared between supported games")
universalVisuals:Info("Universal visual features will be added here.")
universalVisuals:Toggle("Watermark", false)
universalVisuals:Toggle("FPS counter", false)

--// PLAYER
local playerTab = win:Tab("Player", "user")
local movement = playerTab:Section("Movement", "Full", "Universal player settings")
movement:Info("Universal movement features will be added here.")

--// MISC
local misc = win:Tab("Misc", "three-dots-horizontal")
local utilities = misc:Section("Utilities", "Full")
utilities:Button("Refresh lanes", function()
    lanesValid = false
    refreshLanes()
    Lib:Notify("Novaa", "Lanes refreshed", 1, "success")
end)
utilities:Button("Release all keys", function()
    releaseAllKeys()
    Lib:Notify("Novaa", "All keys released", 1, "success")
end)
utilities:Button("Reset shot counter", function()
    shotCount = 0
    shotState = "idle"
    Lib:Notify("Novaa", "Shot counter reset", 1, "success")
end)
utilities:Button("Unload", function()
    Lib:Dialog({
        title = "Unload Novaa?",
        text = "This will remove all drawings and close the UI.",
        confirm = "Unload",
        onConfirm = function()
            _G.Gakuran_Running = false
            if renderConnection then
                renderConnection:Disconnect()
                renderConnection = nil
            end
            if _G.Gakuran_Cleanup then
                _G.Gakuran_Cleanup()
            end
            Lib:Destroy()
        end,
    })
end):SetRisk()

--// MAIN LOOP
local UTILITY_TICK = 0.5
local LastCycleCheck = 0
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not _G.Gakuran_Running then
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        if _G.Gakuran_Cleanup then
            _G.Gakuran_Cleanup()
        end
        return
    end
    if REQUIRE_GAME_FOCUS and not isrbxactive() then
        return
    end
    local now = os.clock()
    local localChar = LocalPlayer.Character
    if localChar and localChar:FindFirstChild("Humanoid") then
        LocalTracker:Update(localChar)
        EvaluateParryTriggers()
        ParryTask()
        scheduler.update()
    end
    if (now - LastCycleCheck >= UTILITY_TICK) then
        LastCycleCheck = now
        if AUTO_TARGET_NEAREST then
            CycleEvent()
        end
        ProcessEspAndLogging()
    end
    updateAutoplay(now)
    updateAutoGreen(now)
end)

--// LOAD CONFIG LAST
win:autoloadConfig("Gakuran")
Lib:Notify("Loaded", "Novaa script is ready!", 3, "success")