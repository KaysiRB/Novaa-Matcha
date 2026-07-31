local RunService = game:GetService("RunService")
local ESP_Utility = {}
local UpdateThread = nil
ESP_Utility.__index = ESP_Utility
ESP_Utility.TrackersToUpdate = {}
local function magnitude(p1, p2)
    local dx = p2.X - p1.X
    local dy = p2.Y - p1.Y
    local dz = p2.Z - p1.Z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end
local BasePartTypes = {
    ["Part"] = "BasePart",
    ["MeshPart"] = "BasePart",
    ["UnionOperation"] = "BasePart",
    ["Model"] = "Model",
}
local function IsValidObject(Object)
    if type(Object) == "userdata" and Object and Object.ClassName then
        local Type = BasePartTypes[Object.ClassName]
        return Type
    end
    return nil
end
local function GetObjectFromModel(Model)
    local CommonNames = {
        "HumanoidRootPart",
        "Root",
        "RootPart",
        "Core"
    }


	-- 1. Try to find a standard Root Part first
    local Children = Model:GetChildren()
    for _, Name in CommonNames do
        for _, Child in Children do
			-- Convert the current child's name to lowercase for comparison
            if string.lower(Child.Name) == string.lower(Name) and BasePartTypes[Child.ClassName] == "BasePart" then
                return Child
            end
        end
    end

	-- 2. If its a model try its PrimaryPart
    if Model.ClassName == "Model" then
        local PrimaryPart = Model.PrimaryPart
        return PrimaryPart
    end

	-- 3. Fallback: Find the largest part by volume
    local LargestPart = nil
    local MaxVolume = 0
    for _, Child in Model:GetChildren() do
        if BasePartTypes[Child.ClassName] then
			-- Volume = Size.X * Size.Y * Size.Z
            local Volume = Child.Size.X * Child.Size.Y * Child.Size.Z
            if Volume > MaxVolume then
                MaxVolume = Volume
                LargestPart = Child
            end
        end
    end
    return LargestPart
end
function ESP_Utility.NewTracker(Object, CustomName, Color)
    local ObjectType = IsValidObject(Object)
    if not ObjectType then
        warn("[ERROR] The tracker only accepts models, baseparts, meshparts, or unions. || Received: ", Object)
        return
    end
    if ObjectType == "Model" then 
		--	print("[MODEL] Model received")
        local Model = Object
        CustomName = CustomName or Object.Name
        Object = GetObjectFromModel(Model)
        if Object == nil then
            warn(string.format("[ERROR] Could not add Model: %s because it had no valid parts inside of it", Model.Name))
            return
        end
    end
    if ESP_Utility.TrackersToUpdate[Object.Address] then
		--	print("Already exists")
        return ESP_Utility.TrackersToUpdate[Object.Address]
    end
    local self = setmetatable({}, ESP_Utility)
    self.Name = CustomName or Object.Name
    self.Object = Object
    self.Color = Color or Color3.fromRGB(255, 255, 255)
    self.Drawings = {}
    self.ObjectType = ObjectType
    self.DrawingOrder = {}
    self.Visible = true
    self.TrackerOffScreen = false
    self:BuildVisualTracker()
    ESP_Utility.TrackersToUpdate[Object.Address] = self
    return self
end
function ESP_Utility:_IsAlive()
    if not self.Object then
        return false
    end
    local InWorkspace = self.Object:IsDescendantOf(game.Workspace)
    if not InWorkspace then
        return false
    end
    return true
end
local CORNER_OFFSETS = {
    Vector3.new(- 1, - 1, - 1),
    Vector3.new(1, - 1, - 1),
    Vector3.new(1, - 1, 1),
    Vector3.new(- 1, - 1, 1),
    Vector3.new(- 1, 1, - 1),
    Vector3.new(1, 1, - 1),
    Vector3.new(1, 1, 1),
    Vector3.new(- 1, 1, 1),
}
function ESP_Utility:_Get2D_Bounds()
    local position = self.Object.Position
    local size = self.Object.Size
    local half = size * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = - math.huge, - math.huge
    if self.ObjectType ~= "Model" then
        for i = 1, 8 do
            local offset = CORNER_OFFSETS[i]
            local worldPos = Vector3.new(
				position.X + offset.X * half.X, position.Y + offset.Y * half.Y, position.Z + offset.Z * half.Z)
            local screenPos, onScreen = WorldToScreen(worldPos)
            if not onScreen then
                return nil
            end
            if onScreen then
                if screenPos.X < minX then
                    minX = screenPos.X
                end
                if screenPos.Y < minY then
                    minY = screenPos.Y
                end
                if screenPos.X > maxX then
                    maxX = screenPos.X
                end
                if screenPos.Y > maxY then
                    maxY = screenPos.Y
                end
            end
        end
        return minX, minY, maxX, maxY
    end
    local Position = self.Object.Position
    local Size = self.Object.Size
    local ScreenCenter, CenterVisible = WorldToScreen(Position)
    local ScreenTop, TopVisible = WorldToScreen(Position + Vector3.new(0, Size.Y * 0.5, 0))
    if not CenterVisible or not TopVisible then
        return nil
    end
    local Height = math.abs(ScreenCenter.Y - ScreenTop.Y) * 5
    local Width = Height * 1.2
    local halfW = Width * 0.5
    local halfH = Height * 0.5
    return ScreenCenter.X - halfW, ScreenCenter.Y - halfH, ScreenCenter.X + halfW, ScreenCenter.Y + halfH
end
function ESP_Utility:_GetDistance()
    local Character = game.Players.LocalPlayer.Character
    if not Character then
        return 0
    end
    local HRP = Character.HumanoidRootPart
    if not HRP or not HRP.Parent then
        return 0
    end
    return magnitude(HRP.Position, self.Object.Position)
end
function ESP_Utility:_Position(DrawingObject, Y_Offset)
    local Session = self.Session
    local FontSize = DrawingObject.Size or 20
    local Padding = 5
    local textLength = 0
    for line in string.gmatch(DrawingObject.Text, "[^\n]+") do
        local length = # line
        if length > textLength then
            textLength = length
        end
    end


	-- 1. Manual X Centering 
	-- We approximate width: Average char is about half the height wide
    local estimatedWidth = textLength * (FontSize * 0.45)
    local manualCenterX = Session.CenterX - (estimatedWidth / 2)

	-- 2. Upward Y Calculation
	-- As Y_Offset increases (0, 1, 5, 6), this value gets smaller (higher on screen)
    local FinalY = Session.TopY - Padding - ((Y_Offset + 1) * FontSize)

	-- 3. Apply Position
    DrawingObject.Center = false
    DrawingObject.Position = Vector2.new(manualCenterX, FinalY)
end
function ESP_Utility:_DetermineVisibility()
    local isOffScreen = self.TrackerOffScreen
    local isVisible = self.Visible
    local shouldRender = isVisible and not isOffScreen
    for drawingName, data in self.Drawings do
        local DrawingObject = (type(data) == "table" and data.Drawing) or data
        if not shouldRender then
            DrawingObject.Visible = false
            continue
        end
        local setting = data.Visible
        DrawingObject.Visible = setting
    end
    return shouldRender
end
function ESP_Utility:_Update()
    -- Absolute guard clause: ensure the object and its required methods still exist
    if not self or not self.Name or not self._IsAlive or not self._Get2D_Bounds then
        return
    end
    if not self:_IsAlive() or not self.ObjectType then
        if self.Destroy then
            self:Destroy()
        end
        return
    end
    local min_x, min_y, max_x, max_y = self:_Get2D_Bounds()
    local Hidden = false
    self.TrackerOffScreen = (min_x == nil)

    -- Double check _DetermineVisibility exists
    if not self._DetermineVisibility then
        return
    end
    local ShouldRender = self:_DetermineVisibility()
    if not ShouldRender then
        return
    end
    local boxWidth = max_x - min_x
    self.Session = {
        CenterX = min_x + (boxWidth / 2),
        TopY = min_y
    }

    -- Verify Drawings table still exists before updating
    if not self.Drawings or not self.Drawings["Square"] then
        return
    end
    local Square = self.Drawings["Square"].Drawing
    Square.Position = Vector2.new(min_x, min_y)
    Square.Size = Vector2.new(boxWidth, max_y - min_y)
    if not self.DrawingOrder then
        return
    end
    -- Update texts
    for _, TextReference in ipairs(self.DrawingOrder) do
        local Data = self.Drawings[TextReference]
        if not Data then
            continue
        end
        local DrawingObject = Data.Drawing
        local Callback = Data.Function
        if Callback then
            DrawingObject.Text = Callback()
        end
        if not self._Position then
            return
        end
        self:_Position(DrawingObject, Data.Y_Offset)
    end
end
function ESP_Utility:_CreateSquare()
    local NewSquare = Drawing.new("Square")
    NewSquare.Size = Vector2.new(10, 10)
    NewSquare.Color = self.Color
    NewSquare.Filled = false
    if self.ObjectType == "Model" then
        NewSquare.Visible = false
    end
    self.Drawings["Square"] = {
        Drawing = NewSquare,
        Visible = true,
    }
end
local function GetLineCount(text)
    local _, count = string.gsub(tostring(text or ""), "\n", "")
    return count + 1
end
function ESP_Utility:RecalculateOffsets()
    local totalLines = 0
    for _, reference in ipairs(self.DrawingOrder) do
        local data = self.Drawings[reference]
        if data and data.LineCount then
            data.Y_Offset = totalLines + data.LineCount - 1
            totalLines = totalLines + data.LineCount
        end
    end
end
function ESP_Utility:AddText(Reference, NewColor, Value, Callback)
    if self.Drawings[Reference] then
        return
    end
    if not self.DrawingOrder then
        self.DrawingOrder = {}
    end
    local NewText = Drawing.new("Text")
    NewText.Text = Value or "Callback passed, uninitialized"
    NewText.Center = false
    NewText.Outline = true
    NewText.Color = NewColor or Color3.fromRGB(200, 200, 200)
    local currentText = tostring((Callback and Callback()) or Value or "")
    local currentLineCount = GetLineCount(currentText)
    self.Drawings[Reference] = {
        Drawing = NewText,
        Function = Callback,
        Y_Offset = 0,
        LineCount = currentLineCount,
        Visible = true,
    }
    table.insert(self.DrawingOrder, Reference)
    self:RecalculateOffsets()
end
function ESP_Utility:ChangeText(Reference, Value, NewColor)
    local TextData = self.Drawings[Reference]
    if not TextData or not TextData.LineCount then
        warn("Attempting to change text of a non-text object")
        return
    end
    if TextData.Function ~= nil then
        warn(string.format("TEXT: %s already has a callback assigned, remove it to use :ChangeText", Reference))
        return
    end
    local TextDrawing = TextData.Drawing
    if Value then
        TextDrawing.Text = Value
        TextData.LineCount = GetLineCount(Value)

        -- Update all Y offsets since this text may have grown/shrunk
        self:RecalculateOffsets()
    end
    if NewColor then
        TextDrawing.Color = NewColor
    end
end
function ESP_Utility:BuildVisualTracker()
    self:_CreateSquare()
    self:AddText("Distance", nil, "ok", function()
        return "[" .. math.floor(self:_GetDistance()) .. "m]"
    end)
    local NameString = self.Name .. (self.ObjectType == "Model" and " [M]" or "")
    self:AddText("Name", self.Color, NameString)
end
function ESP_Utility:Destroy()
    ESP_Utility.TrackersToUpdate[self.Object.Address] = nil
    for Name, Drawing in pairs(self.Drawings) do
        if type(Drawing) == "table" then
            Drawing.Drawing:Remove()
        else
            Drawing:Remove()
        end
    end
    for key, value in self do
        self[key] = nil
    end
    setmetatable(self, nil)
end
UpdateThread = RunService.RenderStepped:Connect(function(dt)
    -- 1. Take a snapshot of the current keys
    local keys = {}
    for i in pairs(ESP_Utility.TrackersToUpdate) do
        table.insert(keys, i)
    end

    -- 2. Iterate over the snapshot
    for idx = 1, # keys do
        local i = keys[idx]
        local v = ESP_Utility.TrackersToUpdate[i]
        
        -- Check if it still exists (in case it was deleted earlier in the same frame)
        if v then
            if not v.Name then
                ESP_Utility.TrackersToUpdate[i] = nil
                continue
            end
            v:_Update()
        end
    end
end)
notify("ESP thread started", "ESP_Utility", 3)
print("[ESP_Utility] Functions were imported v1.3")
_G.ESP_Utility = ESP_Utility
return ESP_Utility