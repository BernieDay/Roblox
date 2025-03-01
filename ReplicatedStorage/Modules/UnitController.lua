-- UnitController.lua
local PathfindingService = game:GetService("PathfindingService")
local UnitController = {}

-- Table to track active movement tasks per unit
local npcMovementThreads = {}

-- (Example) Local steering adjustment—returns a vector to adjust movement.
local function getSteeringAdjustment(unit)
	-- (Simplified for brevity; you can insert your raycast logic here)
	return Vector3.new(0, 0, 0)
end

-- Moves a unit (model) to the destination using PathfindingService.
function UnitController.moveUnit(unit, destination)
	if not unit or not destination then
		warn("Invalid unit or destination")
		return
	end

	local humanoid = unit:FindFirstChild("Humanoid")
	if not humanoid or not unit.PrimaryPart then
		warn("Unit missing Humanoid or PrimaryPart")
		return
	end

	if npcMovementThreads[unit] then
		task.cancel(npcMovementThreads[unit])
		npcMovementThreads[unit] = nil
	end

	-- Play walk animation (assuming you have a function for this)
	local function playAnimation(animationName)
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		local animationsFolder = unit:FindFirstChild("Animations")
		if animationsFolder then
			local animObject = animationsFolder:FindFirstChild(animationName)
			if animObject then
				local track = animator:LoadAnimation(animObject)
				track:Play(0.2)
				return track
			end
		end
	end
	local walkTrack = playAnimation("Walk")

	local pathParams = {
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
	}
	local path = PathfindingService:CreatePath(pathParams)
	path:ComputeAsync(unit.PrimaryPart.Position, destination)
	if path.Status ~= Enum.PathStatus.Success then
		warn("Pathfinding failed:", path.Status)
		if walkTrack then walkTrack:Stop(0.2) end
		return
	end

	local waypoints = path:GetWaypoints()
	print("Path found with", #waypoints, "waypoints.")

	npcMovementThreads[unit] = task.spawn(function()
		for i, waypoint in ipairs(waypoints) do
			local targetPosition = waypoint.Position + getSteeringAdjustment(unit)
			humanoid:MoveTo(targetPosition)
			local reached = humanoid.MoveToFinished:Wait()
			if not reached then
				warn("Failed to reach waypoint:", targetPosition)
				break
			end
		end
		npcMovementThreads[unit] = nil
		print("Unit reached destination!")
		if walkTrack then walkTrack:Stop(0.2) end
		playAnimation("Idle")
	end)
end

-- Continuously attacks the target once in range.
function UnitController.attackUnit(unit, target)
	if not unit or not target then
		warn("Invalid unit or target for attack")
		return
	end

	local attackerHumanoid = unit:FindFirstChild("Humanoid")
	local targetHumanoid = target:FindFirstChild("Humanoid")
	if not attackerHumanoid or not targetHumanoid or not unit.PrimaryPart or not target.PrimaryPart then
		warn("Missing Humanoid or PrimaryPart on attacker or target")
		return
	end

	-- Cancel any current movement.
	if npcMovementThreads[unit] then
		task.cancel(npcMovementThreads[unit])
		npcMovementThreads[unit] = nil
	end

	local attackRange = 10
	local attackDamage = 10
	local attackCooldown = 1.0

	while targetHumanoid.Health > 0 and target.Parent do
		local distance = (unit.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude
		if distance > attackRange then
			print("Target out of range. Moving closer...")
			attackerHumanoid:MoveTo(target.PrimaryPart.Position)
			local reached = attackerHumanoid.MoveToFinished:Wait()
			if not reached then
				warn("Failed to move closer to target.")
				return
			end
			task.wait(0.1)
		else
			local function playAnimation(animationName)
				local animator = attackerHumanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", attackerHumanoid)
				local animationsFolder = unit:FindFirstChild("Animations")
				if animationsFolder then
					local animObject = animationsFolder:FindFirstChild(animationName)
					if animObject then
						local track = animator:LoadAnimation(animObject)
						track:Play(0.2)
						return track
					end
				end
			end
			local attackTrack = playAnimation("Attack")
			-- Play attack sound (if available).
			local soundsFolder = unit:FindFirstChild("Sounds")
			if soundsFolder then
				local attackSound = soundsFolder:FindFirstChild("AttackSound")
				if attackSound then
					attackSound:Play()
				end
			end
			print(unit.Name .. " is attacking " .. target.Name)
			task.wait(0.5)
			targetHumanoid.Health = targetHumanoid.Health - attackDamage
			print(target.Name .. " now has " .. targetHumanoid.Health .. " health.")
			if attackTrack then
				attackTrack:Stop(0.2)
			end
			playAnimation("Idle")
			task.wait(attackCooldown)
		end
	end
	print("Attack loop ended for", unit.Name)
end

return UnitController
