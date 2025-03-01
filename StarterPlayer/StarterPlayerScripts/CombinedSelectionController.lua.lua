-- CombinedSelectionController.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CommandUnit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CommandUnit")
local AttackUnit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackUnit")
local SelectionRingHelper = require(ReplicatedStorage:WaitForChild("UIAssets"):WaitForChild("SelectionRingHelper"))

------------------------------------------------------------
-- Building UI (for buildings)
------------------------------------------------------------
local buildingGui = player:WaitForChild("PlayerGui"):WaitForChild("BuildingGui")
local buildingPanel = buildingGui:WaitForChild("BuildingPanel")
buildingPanel.Visible = false
local selectedBuilding = nil

local function showBuildingUI(building)
	selectedBuilding = building
	buildingPanel.Visible = true
	local titleLabel = buildingPanel:FindFirstChild("BuildingTitle")
	if titleLabel then
		titleLabel.Text = building.Name
	end
	print("Building UI shown for:", building.Name)
end

local function hideBuildingUI()
	buildingPanel.Visible = false
	selectedBuilding = nil
	print("Building UI hidden")
end

local siggiButton = buildingPanel:WaitForChild("SiggiButton")
siggiButton.MouseButton1Click:Connect(function()
	if selectedBuilding then
		print("Spawning Siggi from", selectedBuilding.Name)
		SpawnUnit:FireServer(selectedBuilding, "Siggi")
		-- Optionally, you may choose to hide the building UI here.
		-- hideBuildingUI()
	end
end)

------------------------------------------------------------
-- Unit (NPC) Selection
------------------------------------------------------------
local selectedUnits = {}

local function clearUnitSelection()
	for _, unit in ipairs(selectedUnits) do
		SelectionRingHelper.removeSelectionRing(unit)
	end
	selectedUnits = {}
	print("Unit selection cleared.")
end

local function addUnitToSelection(unit)
	for _, u in ipairs(selectedUnits) do
		if u == unit then return end -- already selected
	end
	table.insert(selectedUnits, unit)
	SelectionRingHelper.addSelectionRing(unit)
	print("Added", unit.Name, "to unit selection. Total selected:", #selectedUnits)
end

------------------------------------------------------------
-- Drag Selection UI Setup
------------------------------------------------------------
local dragSelectionGui = Instance.new("ScreenGui")
dragSelectionGui.Name = "DragSelectionGui"
dragSelectionGui.ResetOnSpawn = false
dragSelectionGui.Parent = player:WaitForChild("PlayerGui")

local selectionBox = Instance.new("Frame")
selectionBox.Name = "SelectionBox"
selectionBox.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
selectionBox.BorderSizePixel = 0
selectionBox.BackgroundTransparency = 0.5
selectionBox.Visible = false
selectionBox.Parent = dragSelectionGui

local dragging = false
local dragStartPos = Vector2.new(0, 0)
local dragCurrentPos = Vector2.new(0, 0)

-- Throttle update if needed (optional)
local lastUpdate = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
		dragCurrentPos = dragStartPos
		selectionBox.Position = UDim2.new(0, dragStartPos.X, 0, dragStartPos.Y)
		selectionBox.Size = UDim2.new(0, 0, 0, 0)
		selectionBox.Visible = true
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local currentTime = tick()
		if currentTime - lastUpdate < 0.05 then
			return
		end
		lastUpdate = currentTime
		dragCurrentPos = Vector2.new(input.Position.X, input.Position.Y)
		local startX = math.min(dragStartPos.X, dragCurrentPos.X)
		local startY = math.min(dragStartPos.Y, dragCurrentPos.Y)
		local sizeX = math.abs(dragCurrentPos.X - dragStartPos.X)
		local sizeY = math.abs(dragCurrentPos.Y - dragStartPos.Y)
		selectionBox.Position = UDim2.new(0, startX, 0, startY)
		selectionBox.Size = UDim2.new(0, sizeX, 0, sizeY)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
		dragging = false
		selectionBox.Visible = false

		local deltaX = math.abs(dragCurrentPos.X - dragStartPos.X)
		local deltaY = math.abs(dragCurrentPos.Y - dragStartPos.Y)
		local threshold = 5  -- pixel threshold
		-- If the drag distance is below threshold, treat it as a simple click and don't clear selection.
		if deltaX < threshold and deltaY < threshold then
			return
		end

		local minX = math.min(dragStartPos.X, dragCurrentPos.X)
		local minY = math.min(dragStartPos.Y, dragCurrentPos.Y)
		local maxX = math.max(dragStartPos.X, dragCurrentPos.X)
		local maxY = math.max(dragStartPos.Y, dragCurrentPos.Y)
		local selectionRect = {Min = Vector2.new(minX, minY), Max = Vector2.new(maxX, maxY)}
		print("Selection rectangle:", selectionRect.Min, selectionRect.Max)

		clearUnitSelection()
		for _, model in ipairs(workspace:GetChildren()) do
			if model:IsA("Model") and model:FindFirstChild("Humanoid") and model.PrimaryPart then
				local camera = workspace.CurrentCamera
				local screenPoint, onScreen = camera:WorldToViewportPoint(model.PrimaryPart.Position)
				if onScreen and screenPoint.X >= selectionRect.Min.X and screenPoint.X <= selectionRect.Max.X and screenPoint.Y >= selectionRect.Min.Y and screenPoint.Y <= selectionRect.Max.Y then
					addUnitToSelection(model)
				end
			end
		end
		print("Total units selected:", #selectedUnits)
	end
end)

------------------------------------------------------------
-- Combined Click Handling for Buildings and Unit Selection
------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	-- Only process a click if it's a MouseButton1 press and not part of a drag.
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
		local target = mouse.Target
		if target then
			local model = target:FindFirstAncestorWhichIsA("Model")
			if model then
				if model:FindFirstChild("IsBuilding") and model.IsBuilding.Value == true then
					showBuildingUI(model)
					return
				elseif model:FindFirstChild("Humanoid") then
					addUnitToSelection(model)
					return
				end
			end
		end
		-- If nothing valid is clicked, hide building UI and clear unit selection.
		hideBuildingUI()
		clearUnitSelection()
	end
end)

------------------------------------------------------------
-- Commanding Move and Attack
------------------------------------------------------------
mouse.Button1Down:Connect(function()
	-- If not dragging and there are selected units, and the click is on empty ground, issue a move command.
	if not dragging and #selectedUnits > 0 then
		local target = mouse.Target
		if not (target and target:FindFirstAncestorWhichIsA("Model") and target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid")) then
			local destination = mouse.Hit.Position
			print("Commanding", #selectedUnits, "units to move to", destination)
			for _, unit in ipairs(selectedUnits) do
				CommandUnit:FireServer(unit, destination)
			end
			-- Optionally, clear selection after move:
			-- clearUnitSelection()
		end
	end
end)

mouse.Button2Down:Connect(function()
	local target = mouse.Target
	if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
		local enemyUnit = target.Parent
		local isFriendly = false
		for _, unit in ipairs(selectedUnits) do
			if unit == enemyUnit then
				isFriendly = true
				break
			end
		end
		if not isFriendly and #selectedUnits > 0 then
			print("Commanding attack on", enemyUnit.Name)
			for _, unit in ipairs(selectedUnits) do
				AttackUnit:FireServer(unit, enemyUnit)
			end
			-- Optionally, keep selection after attack.
			return
		end
	end
	clearUnitSelection()
end)
