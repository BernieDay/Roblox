-- SpawnUnitHandler.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnUnit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SpawnUnit")
local NPCTemplates = ReplicatedStorage:WaitForChild("NPCTemplates")

SpawnUnit.OnServerEvent:Connect(function(player, building, unitType)
	if not building or not unitType then
		warn("Invalid parameters for spawning unit.")
		return
	end

	local template = NPCTemplates:FindFirstChild(unitType)
	if not template then
		warn("No NPC template found for unit type:", unitType)
		return
	end

	local npcClone = template:Clone()
	npcClone.Parent = workspace

	local spawnPoint = building:FindFirstChild("SpawnPoint")
	if spawnPoint and npcClone.PrimaryPart then
		npcClone:SetPrimaryPartCFrame(spawnPoint.CFrame)
	else
		warn("Building missing SpawnPoint or NPC template missing PrimaryPart.")
	end
end)
-- SpawnUnitHandler.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnUnit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SpawnUnit")
local NPCTemplates = ReplicatedStorage:WaitForChild("NPCTemplates")

-- Adjust these values to control spawn offset randomness:
local SPAWN_RADIUS = 5  -- Maximum offset (studs)

SpawnUnit.OnServerEvent:Connect(function(player, building, unitType)
	if not building or not unitType then
		warn("Invalid parameters for spawning unit.")
		return
	end

	local npcTemplate = NPCTemplates:FindFirstChild(unitType)
	if not npcTemplate then
		warn("No NPC template found for unit type:", unitType)
		return
	end

	local npcClone = npcTemplate:Clone()
	npcClone.Parent = workspace

	local spawnPoint = building:FindFirstChild("SpawnPoint")
	if spawnPoint and npcClone.PrimaryPart then
		-- Generate a random offset within a circle of radius SPAWN_RADIUS
		local angle = math.random() * 2 * math.pi
		local radius = math.random() * SPAWN_RADIUS
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)

		npcClone:SetPrimaryPartCFrame(spawnPoint.CFrame * CFrame.new(offset))
	else
		warn("Building missing SpawnPoint or NPC template missing PrimaryPart.")
	end
end)
