local Proximity = {}

function Proximity.isNear(player: Player, part: BasePart, range: number?): boolean
	range = range or 20
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local dist = (root.Position - part.Position).Magnitude
	return dist <= range
end

function Proximity.requireNear(player: Player, part: BasePart, range: number?): boolean
	if not Proximity.isNear(player, part, range) then
		warn(("[Proximity] %s attempted interaction outside range"):format(player.Name))
		return false
	end
	return true
end

return Proximity
