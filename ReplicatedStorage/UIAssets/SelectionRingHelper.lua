-- SelectionRingHelper.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = require(ReplicatedStorage:WaitForChild("UIAssets"):WaitForChild("AssetReferences"))

local SelectionRingHelper = {}

-- Adds a selection ring to the model using a BillboardGui.
function SelectionRingHelper.addSelectionRing(model)
	if not model or not model.PrimaryPart then return end
	if model:FindFirstChild("SelectionRing") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SelectionRing"
	billboard.Parent = model.PrimaryPart
	billboard.Adornee = model.PrimaryPart
	billboard.Size = UDim2.new(3, 0, 3, 0)  -- Adjust size as needed
	billboard.AlwaysOnTop = true

	-- Optionally, you can add a Frame with a UIStroke for a ring look
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = billboard

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.new(0, 1, 0)  -- Green
	stroke.Parent = frame

	return billboard
end

-- Removes the selection ring from the model.
function SelectionRingHelper.removeSelectionRing(model)
	if not model then return end
	local ring = model:FindFirstChild("SelectionRing")
	if ring then
		ring:Destroy()
	end
end

return SelectionRingHelper
