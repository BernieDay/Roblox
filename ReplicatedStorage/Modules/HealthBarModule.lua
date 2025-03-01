-- HealthBarModule.lua
local HealthBarModule = {}

-- Creates and attaches a health bar to the given NPC.
function HealthBarModule.createHealthBar(npc)
	-- Try to get the Head or use the PrimaryPart as a fallback.
	local head = npc:FindFirstChild("Head") or npc.PrimaryPart
	if not head then
		warn("No head or PrimaryPart found for", npc.Name)
		return
	end

	-- Create BillboardGui
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "HealthBarGui"
	billboardGui.Parent = head
	billboardGui.Size = UDim2.new(2, 0, 0.5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)

	-- Background frame (for a border effect)
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.BackgroundColor3 = Color3.new(0, 0, 0)
	background.BorderSizePixel = 0
	background.Size = UDim2.new(1, 0, 0.3, 0)
	background.Parent = billboardGui

	-- The actual health bar
	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.BackgroundColor3 = Color3.new(0, 1, 0)  -- Green for full health
	healthBar.BorderSizePixel = 0
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.Parent = background

	-- Update the health bar when health changes
	local humanoid = npc:FindFirstChild("Humanoid")
	if humanoid then
		-- Initialize the bar based on current health.
		local function updateHealthBar(health)
			local ratio = health / humanoid.MaxHealth
			healthBar.Size = UDim2.new(ratio, 0, 1, 0)
			if ratio < 0.3 then
				healthBar.BackgroundColor3 = Color3.new(1, 0, 0) -- Red for low health
			elseif ratio < 0.6 then
				healthBar.BackgroundColor3 = Color3.new(1, 1, 0) -- Yellow for medium health
			else
				healthBar.BackgroundColor3 = Color3.new(0, 1, 0) -- Green for high health
			end
		end

		updateHealthBar(humanoid.Health)
		humanoid.HealthChanged:Connect(updateHealthBar)
	else
		warn("No Humanoid found for", npc.Name)
	end
end

return HealthBarModule
