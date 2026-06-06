--!strict
-- ambient zone effects: range circle, zone sparkles, pollen drift, collection pulse ring
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local AreaFX = {}

local rangeIndicator: BasePart?
local sparkParticles: ParticleEmitter?
local pollenEmitter: ParticleEmitter?
local pulseRing: BasePart?

local RANGE = 28 -- match FarmService range

local function ensureRangeIndicator()
	if not rangeIndicator or not rangeIndicator.Parent then
		rangeIndicator = Instance.new("Part")
		rangeIndicator.Name = "RangeIndicator"
		rangeIndicator.Shape = Enum.PartType.Cylinder
		rangeIndicator.Anchored = true
		rangeIndicator.CanCollide = false
		rangeIndicator.CanQuery = false
		rangeIndicator.CanTouch = false
		rangeIndicator.Material = Enum.Material.Neon
		rangeIndicator.Color = Color3.fromRGB(120, 200, 255)
		rangeIndicator.Transparency = 0.85
		rangeIndicator.Size = Vector3.new(0.6, RANGE * 2, RANGE * 2)
		rangeIndicator.Parent = Workspace.Terrain

		-- ring particle sparkles
		local sparkPart = Instance.new("Part")
		sparkPart.Size = Vector3.new(1, 1, 1)
		sparkPart.Transparency = 1
		sparkPart.Anchored = true
		sparkPart.CanCollide = false
		sparkPart.Parent = rangeIndicator

		sparkParticles = Instance.new("ParticleEmitter")
		sparkParticles.Texture = "rbxassetid://243660364"
		sparkParticles.Rate = 4
		sparkParticles.Lifetime = NumberRange.new(1, 2.5)
		sparkParticles.Speed = NumberRange.new(0.5, 1.5)
		sparkParticles.Size = NumberSequence.new(0.15)
		sparkParticles.Transparency = NumberSequence.new(0.6)
		sparkParticles.Color = ColorSequence.new(Color3.fromRGB(120, 200, 255))
		sparkParticles.SpreadAngle = Vector2.new(180, 180)
		sparkParticles.VelocityInheritance = 0
		sparkParticles.Parent = sparkPart
	end
end

-- ===== POLLEN / DUST MOTES =====
local function ensurePollen()
	if not pollenEmitter or not pollenEmitter.Parent then
		local pollenPart = Instance.new("Part")
		pollenPart.Size = Vector3.new(1, 1, 1)
		pollenPart.Transparency = 1
		pollenPart.Anchored = true
		pollenPart.CanCollide = false
		pollenPart.Parent = Workspace.Terrain

		pollenEmitter = Instance.new("ParticleEmitter")
		pollenEmitter.Texture = "rbxassetid://243660364"
		pollenEmitter.Rate = 6
		pollenEmitter.Lifetime = NumberRange.new(5, 12)
		pollenEmitter.Speed = NumberRange.new(0.2, 0.8)
		pollenEmitter.Size = NumberSequence.new(0.08)
		pollenEmitter.Transparency = NumberSequence.new(0.6, 0.9)
		pollenEmitter.Color = ColorSequence.new(Color3.fromRGB(220, 230, 180), Color3.fromRGB(255, 240, 200))
		pollenEmitter.SpreadAngle = Vector2.new(180, 180)
		pollenEmitter.VelocityInheritance = 0.3
		pollenEmitter.Acceleration = Vector3.new(0.2, 0.05, 0.1) -- gentle wind drift
		pollenEmitter.Parent = pollenPart
	end
end

-- ===== PULSE RING: expands outward from player =====
local function spawnPulseRing()
	if not pulseRing or not pulseRing.Parent then
		pulseRing = Instance.new("Part")
		pulseRing.Name = "PulseRing"
		pulseRing.Shape = Enum.PartType.Cylinder
		pulseRing.Anchored = true
		pulseRing.CanCollide = false
		pulseRing.CanQuery = false
		pulseRing.Material = Enum.Material.Neon
		pulseRing.Color = Color3.fromRGB(120, 200, 255)
		pulseRing.Transparency = 0.7
		pulseRing.Size = Vector3.new(0.3, 2, 2)
		pulseRing.Parent = Workspace.Terrain
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	pulseRing.CFrame = CFrame.new(root.Position - Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	pulseRing.Size = Vector3.new(0.3, 2, 2)
	pulseRing.Transparency = 0.6
	local ts = game:GetService("TweenService")
	ts:Create(pulseRing, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.3, RANGE * 2, RANGE * 2), Transparency = 0.9 }):Play()
end

-- ===== ZONE SPARKLE PARTICLES =====
local zoneSparkles: ParticleEmitter?
local function spawnZoneSparkles()
	if not zoneSparkles then
		local p = Instance.new("Part")
		p.Size = Vector3.new(1, 1, 1)
		p.Transparency = 1
		p.Anchored = true
		p.CanCollide = false
		p.Name = "ZoneSparkles"
		p.Parent = Workspace.Terrain
		zoneSparkles = Instance.new("ParticleEmitter")
		zoneSparkles.Texture = "rbxassetid://243660364"
		zoneSparkles.Rate = 8
		zoneSparkles.Lifetime = NumberRange.new(2, 5)
		zoneSparkles.Speed = NumberRange.new(0.5, 2)
		zoneSparkles.Size = NumberSequence.new(0.2)
		zoneSparkles.Transparency = NumberSequence.new(0.5)
		zoneSparkles.Color = ColorSequence.new(Color3.fromRGB(200, 230, 255))
		zoneSparkles.SpreadAngle = Vector2.new(180, 180)
		zoneSparkles.VelocityInheritance = 0
		zoneSparkles.Parent = p
	end
	-- position near player
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then zoneSparkles.Parent.Position = root.Position end
end

function AreaFX.init()
	ensureRangeIndicator()
	spawnZoneSparkles()
	ensurePollen()
end

-- update range indicator position each frame
RunService.RenderStepped:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if rangeIndicator then
		rangeIndicator.CFrame = CFrame.new(root.Position - Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	end
	if zoneSparkles then
		zoneSparkles.Parent.Position = root.Position
	end
	if sparkParticles then
		sparkParticles.Parent.Position = root.Position + Vector3.new(0, 1, 0)
	end
	if pollenEmitter then
		pollenEmitter.Parent.Position = root.Position + Vector3.new(0, 3, 0)
	end
end)

-- periodic pulse ring
task.spawn(function()
	while true do
		task.wait(2.5 + math.random() * 1.5)
		spawnPulseRing()
	end
end)

return AreaFX
