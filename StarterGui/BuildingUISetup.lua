-- BuildingUISetup.lua (Place in StarterGui or StarterPlayerScripts)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create the ScreenGui
local buildingGui = Instance.new("ScreenGui")
buildingGui.Name = "BuildingGui"
buildingGui.ResetOnSpawn = false
buildingGui.Parent = player:WaitForChild("PlayerGui")

-- Create the Building Panel
local panel = Instance.new("Frame")
panel.Name = "BuildingPanel"
panel.Size = UDim2.new(0, 300, 0, 150)
panel.Position = UDim2.new(0.5, -150, 1, -170)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BackgroundTransparency = 0.2
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.new(1, 1, 1)
panel.Visible = false
panel.Parent = buildingGui

-- Create a Title Label for the Building
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "BuildingTitle"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Barracks"  -- This can be updated dynamically when a building is selected.
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.Parent = panel

-- Create the Footman Spawn Button
local SiggiButton = Instance.new("TextButton")
SiggiButton.Name = "SiggiButton"
SiggiButton.Size = UDim2.new(0, 100, 0, 50)
SiggiButton.Position = UDim2.new(0, 20, 0, 50)
SiggiButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
SiggiButton.Text = "Siggi"
SiggiButton.TextColor3 = Color3.new(1, 1, 1)
SiggiButton.Font = Enum.Font.SourceSansBold
SiggiButton.TextSize = 20
SiggiButton.Parent = panel

-- Create the Archer Spawn Button
local archerButton = Instance.new("TextButton")
archerButton.Name = "ArcherButton"
archerButton.Size = UDim2.new(0, 100, 0, 50)
archerButton.Position = UDim2.new(0, 140, 0, 50)
archerButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
archerButton.Text = "Spawn Archer"
archerButton.TextColor3 = Color3.new(1, 1, 1)
archerButton.Font = Enum.Font.SourceSansBold
archerButton.TextSize = 20
archerButton.Parent = panel

-- The panel starts hidden; you can make it visible when a building is selected.
