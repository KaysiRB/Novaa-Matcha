local HttpService = game:GetService("HttpService")
local offsets

for _, url in ipairs({"https://offsets.imtheo.lol/Offsets.json", "https://artxficial.dev/misc/theo"}) do
    local success, result = pcall(function() 
        local data = HttpService:JSONDecode(game:HttpGet(url)) 
        return data.Offsets or data 
    end)
    
    if success and type(result) == "table" and next(result) then
        print("[DEBUG] Successfully using offsets from: " .. url)
        offsets = result
        break
    end
end

offsets = offsets or (print("[DEBUG] Both endpoints failed. Defaulting to empty table.") or {})

local KnownOffsets = {
    ["AnimationId"] = offsets.Misc.AnimationId,
    ["ClassDescriptor"] = offsets.Instance.ClassDescriptor, -- const
    ["ClassDescriptorToClassName"] = offsets.Instance.ClassName, -- const
    ["Name"] = offsets.Instance.Name, -- const
    ["TimePosition"] = offsets.AnimationTrack.TimePosition,
    ["ActiveAnimations"] = offsets.Animator.ActiveAnimations, -- const
    ["Animation"] = offsets.AnimationTrack.Animation,
    ["Speed"] = offsets.AnimationTrack.Speed,
    ["IsPlaying"] = offsets.AnimationTrack.IsPlaying,
    -- Node Structure
    ["NodeNext"] = 0x10,
}

local function GetAnimatorAddress(Character)
    if not Character or Character.Address == 0 then return nil end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return nil end

    local Animator = Humanoid:FindFirstChildWhichIsA("Animator")
    return Animator and Animator.Address or nil
end

local function GetPlayingAnimationTracks(Character)
    local AnimatorAddress = GetAnimatorAddress(Character)
    if not AnimatorAddress then 
        print("Failed to resolve Animator.")
        return 
    end

    -- This is the address of the head of the linked list of active animations
    local ListHead_Ptr = memory_read("uintptr_t", AnimatorAddress + KnownOffsets.ActiveAnimations)
    if not ListHead_Ptr or ListHead_Ptr == 0 then
        return 
    end

    -- When you read the pointer at the head, you get the first node in the list (or the head itself if the list is empty)
    local firstNode = memory_read("uintptr_t", ListHead_Ptr)
    if not firstNode or firstNode == 0 or firstNode == ListHead_Ptr then 
--        print(string.format("[Head: 0x%X] ---> EMPTY LIST", ListHead_Ptr))
        return {}
    end

    local AnimationTracks = {}
    local currentNode = firstNode
    local foundCount = 0

    local visualPath = string.format("[Head: 0x%X] -> [Node 1: 0x%X]", ListHead_Ptr, firstNode)
  --  print(visualPath)

    while currentNode and currentNode ~= 0 and currentNode ~= ListHead_Ptr do
        -- 1. Read the track data from the current node first
        local track = memory_read("uintptr_t", currentNode + KnownOffsets.NodeNext)
        
        if track then
            foundCount = foundCount + 1
            AnimationTracks[foundCount] = track
         --   print(string.format("   |__ [Node 0x%X] holds AnimationTrack: 0x%X", currentNode, track))
        end

        if foundCount >= 50 then 
        --    print("   |__ [MAX CAP REACHED]")
            break 
        end

        -- 2. Look ahead to see where we go next
        local nextNode = memory_read("uintptr_t", currentNode)
        
        if nextNode == ListHead_Ptr then
         --   print(string.format("   |__ [Node 0x%X] next node is Head. Traversal complete.", currentNode))
         --   print(string.format("   ---> [Head: 0x%X] (Loop Completed)", ListHead_Ptr))
            break -- Safe to exit now; we fully processed currentNode
        elseif nextNode == 0 or not nextNode then
         --   print("   ---> [NULL] (End of List)")
            break
        else
         --   print(string.format("   ---> [Next Node: 0x%X]", nextNode))
        end

        currentNode = nextNode
    end

    return AnimationTracks
end

local function GetTimePosition(AnimationTrackAddress)
    if not AnimationTrackAddress or AnimationTrackAddress == 0 then return nil end
    
    local TimePosition = memory_read("float", AnimationTrackAddress + KnownOffsets.TimePosition)
    
    return TimePosition
end

local function ExtractAnimationTrackInfo(AnimationTrackAddress)
    if not AnimationTrackAddress or AnimationTrackAddress == 0 then return nil end

    local Animation = memory_read("uintptr_t", AnimationTrackAddress + KnownOffsets.Animation)
    local AnimationIdPointer = memory_read("uintptr_t", Animation + KnownOffsets.AnimationId)
    local AnimationId = memory_read("string", AnimationIdPointer)

    local NamePtr = memory_read("uintptr_t", AnimationTrackAddress + KnownOffsets.Name)
    local Name = memory_read("string", NamePtr)
    local TimePosition = memory_read("float", AnimationTrackAddress + KnownOffsets.TimePosition)
    local Speed = memory_read("float", AnimationTrackAddress + KnownOffsets.Speed)
    local IsPlaying = memory_read("byte", AnimationTrackAddress + KnownOffsets.IsPlaying)

    return {
        Address = AnimationTrackAddress,
        Name = Name,
        AnimationId = AnimationId,
        TimePosition = TimePosition,
        Speed = Speed,
        IsPlaying = IsPlaying
    }
end


local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {} }, Signal)
end

function Signal:Connect(callback)
    table.insert(self._listeners, callback)
    return {
        Disconnect = function()
            for i = 1, #self._listeners do
                if self._listeners[i] == callback then
                    table.remove(self._listeners, i)
                    break
                end
            end
        end
    }
end

function Signal:Fire(...)
    for i = 1, #self._listeners do
        self._listeners[i](...)
    end
end

local AnimationTracker = {}
AnimationTracker.__index = AnimationTracker

function AnimationTracker.new(IgnoreIds)
    local self = setmetatable({}, AnimationTracker)
    
    self.AnimationAdded = Signal.new()
    self.AnimationUpdated = Signal.new()
    self.AnimationRemoved = Signal.new()
    self.IgnoreIds = IgnoreIds or {}
    
    self._cachedTracks = {} -- No thread handles or tokens stored here anymore!
    
    return self
end

-- BATCH UPDATE: Reads, updates, cleans up, and returns all active animations at once
function AnimationTracker:Update(character)
    local tracksPlaying = GetPlayingAnimationTracks(character)
    if not tracksPlaying then return {} end

    local currentAddresses = {}
    local activeSnapshot = {}

    -- 1. Batch process all currently playing tracks
    for i = 1, #tracksPlaying do
        local address = tracksPlaying[i]
        
        -- Mark as active so your garbage collector doesn't constantly delete and re-extract ignored tracks
        currentAddresses[address] = true 
    
        local info = self._cachedTracks[address]
        local newlyExtracted = false
    
        -- Extract and cache if it doesn't exist
        if not info then
            info = ExtractAnimationTrackInfo(address)
            if info then
                self._cachedTracks[address] = info
                newlyExtracted = true
            end
        end
    
        if info then
            -- 2. Check the Ignore List
            -- Assuming 'info' contains the AnimationId. If it's on the track itself, change this to address.Animation.AnimationId
            local assetId = info.AnimationId 
            local numericId = assetId and tonumber(string.match(tostring(assetId), "%d+"))
    
            -- If the ID is found in the ignore list, skip the rest of the loop
            if numericId and table.find(self.IgnoreIds, numericId) then 
                continue 
            end 
    
            -- 3. Process Valid Tracks
            -- Only fire Added event if it's brand new AND passed the ignore check
            if newlyExtracted then
                self.AnimationAdded:Fire(info)
            end
    
            local liveTime = GetTimePosition(address) or info.TimePosition
            info.TimePosition = liveTime
            
            self.AnimationUpdated:Fire(info, liveTime)
            table.insert(activeSnapshot, info)
        end
    end

    for address, cachedInfo in pairs(self._cachedTracks) do
        if not currentAddresses[address] then
            self.AnimationRemoved:Fire(cachedInfo)
            self._cachedTracks[address] = nil
        end
    end

    return activeSnapshot
end

print("[AnimationTracker] Functions were imported, use Tracker:Update() in a loop v1.1")

_G.AnimationTracker = AnimationTracker
return AnimationTracker