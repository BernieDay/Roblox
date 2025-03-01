-- NPCSpawner.lua
-- This Script should be a Server Script placed inside your building model in Workspace.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local npcTemplates = ReplicatedStorage:WaitForChild("NPCTemplates")  -- Folder with NPC templates

local spawnInterval = 100  -- Time (in seconds) between spawn attempts
local maxNPCCount = 5     -- Maximum NPCs allowed in the Workspace at once

-- The building model should contain a Part named "SpawnPoint"
local building = script.Parent
local spawnPoint = building:FindFirstChild("SpawnPoint")
if not spawnPoint then
	warn("No SpawnPoint found in the building model!")
	return
end

-- Function to count current NPCs in the Workspace.
local function getCurrentNPCCount()
	local count = 0
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
			count = count + 1
		end
	end
	return count
end

-- Main spawning loop.
while true do
	wait(spawnInterval)

	if getCurrentNPCCount() < maxNPCCount then
		-- Pick an NPC template. For simplicity, we use one named "BasicNPC"
		local npcTemplate = npcTemplates:FindFirstChild("Siggi")
		if npcTemplate then
			local npcClone = npcTemplate:Clone()
			npcClone.Parent = workspace
			-- Position the NPC at the SpawnPoint.
			if npcClone.PrimaryPart then
				npcClone:SetPrimaryPartCFrame(spawnPoint.CFrame)
			else
				warn("NPC " .. npcClone.Name .. " does not have a PrimaryPart!")
			end
			print("Spawned NPC:", npcClone.Name)
		else
			warn("No NPC template named 'BasicNPC' found in NPCTemplates!")
		end
	else
		print("Max NPC count reached. Waiting to spawn more NPCs.")
	end
end
