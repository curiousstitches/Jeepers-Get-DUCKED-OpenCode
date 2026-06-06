-- ButterflySwarm: gentle butterfly and firefly particles that wander near the player
-- Pooled — max 8 butterflies at once for performance
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local ButterflySwarm = {}

local swarm: { Model } = {}
local BUTTERFLY_MAX = 6
local SPAWN_RADIUS = 14
local DESPAWN_RADIUS = 30

local function makeButterfly(): Model
	local m = Instance.new("Model"); m.Name = "Butterfly"; m.Parent = Workspace.Terrain

	-- body
	local body = Instance.new("Part")
	body.Shape = Enum.PartType.Ball; body.Size = Vector3.new(0.2, 0.2, 0.2)
	body.Anchored = true; body.CanCollide = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = Color3.fromHSV(math.random(), 0.7, 0.9)
	body.Parent = m

	-- left wing
	local lw = Instance.new("Part")
	lw.Size = Vector3.new(0.6, 0.05, 0.4)
	lw.Anchored = true; lw.CanCollide = false
	lw.Material = Enum.Material.Glass; lw.Transparency = 0.3
	lw.Color = body.Color:Lerp(Color3.new(1, 1, 1), 0.3)
	lw.Parent = m
	lw.Name = "LeftWing"

	-- right wing
	local rw = Instance.new("Part")
	rw.Size = Vector3.new(0.6, 0.05, 0.4)
	rw.Anchored = true; rw.CanCollide = false
	rw.Material = Enum.Material.Glass; rw.Transparency = 0.3
	rw.Color = lw.Color
	rw.Parent = m
	rw.Name = "RightWing"

	m.PrimaryPart = body
	return m
end

-- Natural butterfly flight: target seeking with sine-wave oscillation
local butterflyStates = {} -- [model] = { target, speed, phase, wingPhase }

local function spawnButterfly()
	if #swarm >= BUTTERFLY_MAX then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local butterfly = makeButterfly()
	local origin = root.Position
	local startPos = origin + Vector3.new(math.random(-SPAWN_RADIUS, SPAWN_RADIUS), math.random(1, 5), math.random(-SPAWN_RADIUS, SPAWN_RADIUS))
	butterfly:PivotTo(CFrame.new(startPos))

	butterflyStates[butterfly] = {
		target = origin + Vector3.new(math.random(-6, 6), math.random(0.5, 3), math.random(-6, 6)),
		speed = 2 + math.random() * 3,
		phase = math.random() * 6.28,
		wingPhase = math.random() * 6.28,
		lifetime = 8 + math.random() * 10,
	}
	table.insert(swarm, butterfly)
end

local function despawnButterfly(butterfly: Model)
	butterflyStates[butterfly] = nil
	butterfly:Destroy()
	for i, b in ipairs(swarm) do
		if b == butterfly then table.remove(swarm, i); break end
	end
end

-- Flight path update
local updateTimer = 0
local spawnTimer = 0
RunService.RenderStepped:Connect(function(dt)
	spawnTimer += dt
	if spawnTimer > 3 then
		spawnTimer = 0
		spawnButterfly()
	end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		for _, b in ipairs(swarm) do despawnButterfly(b) end
		return
	end
	local playerPos = root.Position

	updateTimer += dt
	local updateBatch = updateTimer > 0.05
	if updateBatch then updateTimer = 0 end

	for i = #swarm, 1, -1 do
		local butterfly = swarm[i]
		local state = butterflyStates[butterfly]
		if not state then swarm[i] = nil; continue end

		state.lifetime -= dt
		if state.lifetime <= 0 or (butterfly.PrimaryPart and (butterfly.PrimaryPart.Position - playerPos).Magnitude > DESPAWN_RADIUS) then
			despawnButterfly(butterfly)
			continue
		end

		if updateBatch then
			local current = butterfly:GetPivot().Position
			local dist = (current - state.target).Magnitude

			-- pick a new target when close
			if dist < 2 then
				state.target = playerPos + Vector3.new(math.random(-5, 5), math.random(0.5, 3), math.random(-5, 5))
			end

			-- move toward target with sine oscillation
			local t = os.clock() * state.speed + state.phase
			local dir = (state.target - current).Unit
			local move = dir * state.speed * dt * 3
			local osc = Vector3.new(math.sin(t * 2) * 0.6, math.sin(t * 3) * 0.4, math.cos(t * 2.5) * 0.6)
			local newPos = current + move + osc * dt * 2

			-- face the movement direction
			local lookDir = (newPos - current).Magnitude > 0.01 and (newPos - current).Unit or dir
			butterfly:PivotTo(CFrame.lookAt(newPos, newPos + lookDir) * CFrame.Angles(0, math.pi, 0))

			-- wing flap animation
			local lw = butterfly:FindFirstChild("LeftWing")
			local rw = butterfly:FindFirstChild("RightWing")
			if lw and rw then
				local flap = math.sin(os.clock() * 8 + state.wingPhase) * 0.5
				lw.CFrame = CFrame.new(newPos) * CFrame.Angles(0, 0, -0.3 - flap * 0.5)
				rw.CFrame = CFrame.new(newPos) * CFrame.Angles(0, 0, 0.3 + flap * 0.5)
			end
		end
	end
end)

-- Clean up on character reset
player.CharacterAdded:Connect(function()
	for _, b in ipairs(swarm) do
		butterflyStates[b] = nil
		b:Destroy()
	end
	swarm = {}
end)

return ButterflySwarm
