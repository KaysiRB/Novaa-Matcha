local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local targetPos = Vector3.new(79.69, -409.72, -1412.36)

local enabled = false
local F1 = 0x70
local W = 0x57

spawn(function()
    while true do
        if enabled and hrp then
            hrp.Position = targetPos
            keypress(W)
            wait(0.1)
            keyrelease(W)
        end
        wait(0.1)
    end
end)

spawn(function()
    while true do
        if iskeypressed(F1) then
            enabled = not enabled
            wait(0.1)
        end
        wait(0.05)
    end
end)