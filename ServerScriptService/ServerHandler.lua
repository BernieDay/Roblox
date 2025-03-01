-- ServerHandler.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UnitController"))
local CommandUnit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CommandUnit")
local AttackUnit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackUnit")

CommandUnit.OnServerEvent:Connect(function(player, unit, destination)
	if unit and destination then
		UnitController.moveUnit(unit, destination)
	else
		warn("Invalid move command received!")
	end
end)

AttackUnit.OnServerEvent:Connect(function(player, unit, target)
	if unit and target then
		UnitController.attackUnit(unit, target)
	else
		warn("Invalid attack command received!")
	end
end)
