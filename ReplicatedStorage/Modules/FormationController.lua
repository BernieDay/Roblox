-- FormationController.lua
local FormationController = {}

-- Computes formation positions (horizontal line) for a list of units.
-- Each unit receives an offset along the X axis so the formation is centered.
function FormationController.computeFormationPositions(units, destination)
	local formationPositions = {}
	local spacing = 5  -- Adjust spacing (in studs) as needed
	local count = #units
	local startOffset = -((count - 1) * spacing / 2)
	for i = 1, count do
		local offset = startOffset + (i - 1) * spacing
		formationPositions[i] = destination + Vector3.new(offset, 0, 0)
	end
	return formationPositions
end

return FormationController
