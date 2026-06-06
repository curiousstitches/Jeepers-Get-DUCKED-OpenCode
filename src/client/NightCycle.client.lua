-- NightCycle: gradual day/night ambient cycle with fireflies and glow effects
-- 3 min day, 2 min night — creates a cozy atmosphere
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local NightCycle = {
	isNight = false,
	cycleTime = 0, -- seconds since last cycle
	DAY_DURATION = 180,
	NIGHT_DURATION = 120,
}

-- ScreenGui overlay for dimming
local overlayGui: ScreenGui?
local overlayFrame: Frame?
local function ensureOverlay()
	if overlayGui and overlayGui.Parent then return end
	overlayGui = Instance.new("ScreenGui")
	overlayGui.Name = "NightOverlay"
	overlayGui.IgnoreGuiInset = true; overlayGui.ResetOnSpawn = false
	overlayGui.Parent = player:WaitForChild("PlayerGui")

	overlayFrame = Instance.new("Frame")
	overlayFrame.Size = UDim2.fromScale(1, 1)
	overlayFrame.BackgroundColor3 = Color3.fromRGB(5, 8, 30)
	overlayFrame.BackgroundTransparency = 1
	overlayFrame.BorderSizePixel = 0
	overlayFrame.Parent = overlayGui
end

-- firefly particles (ambient sparkles at night)
local fireflyFolder: Folder?
local fireflyParts: { BasePart } = {}
local ffIdx = 1

local function spawnFireflies()
	if not fireflyFolder or not fireflyFolder.Parent then
		fireflyFolder = Instance.new("Folder"); fireflyFolder.Name = "Fireflies_" .. player.UserId
		fireflyFolder.Parent = Workspace.Terrain
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _ = 1, 3 do
		local p = fireflyParts[ffIdx]
		if not p then
			p = Instance.new("Part")
			p.Shape = Enum.PartType.Ball; p.Size = Vector3.new(0.15, 0.15, 0.15)
			p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon
			table.insert(fireflyParts, p)
		end
		ffIdx = ffIdx % 30 + 1
		local hue = (0.5 + math.random() * 0.2) % 1 -- green/teal range
		p.Color = Color3.fromHSV(hue, 0.6, 0.8 + math.random() * 0.2)
		p.Transparency = 0.3
		p.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-12, 12), math.random(1, 5), math.random(-12, 12)))
		p.Parent = fireflyFolder
		TweenService:Create(p, TweenInfo.new(1.5 + math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ Transparency = 1, CFrame = p.CFrame * CFrame.new(math.random(-3, 3), math.random(-1, 2), math.random(-3, 3)) }):Play()
		task.delay(2, function() p.Parent = nil end)
	end
end

-- add glow to nearby breakables at night
local glowLights: { [BasePart]: PointLight } = {}
local function updateBreakableGlow()
	for _, b in ipairs(CollectionService:GetTagged("Breakable")) do
		if b:IsA("BasePart") and b.Transparency < 1 then
			if NightCycle.isNight then
				if not glowLights[b] then
					local gl = Instance.new("PointLight")
					gl.Color = Color3.fromRGB(100, 200, 255)
					gl.Range = 8; gl.Brightness = 0.6
					gl.Parent = b
					glowLights[b] = gl
				end
			else
				local gl = glowLights[b]
				if gl then gl:Destroy(); glowLights[b] = nil end
			end
		else
			local gl = glowLights[b]
			if gl then gl:Destroy(); glowLights[b] = nil end
		end
	end
end

-- main update loop
local lastTick = os.clock()
RunService.RenderStepped:Connect(function()
	local dt = os.clock() - lastTick; lastTick = os.clock()
	NightCycle.cycleTime += dt
	ensureOverlay()
	if not overlayFrame then return end

	local totalCycle = NightCycle.DAY_DURATION + NightCycle.NIGHT_DURATION
	local t = NightCycle.cycleTime % totalCycle
	local shouldBeNight = t >= NightCycle.DAY_DURATION

	if shouldBeNight ~= NightCycle.isNight then
		NightCycle.isNight = shouldBeNight
	end

	if NightCycle.isNight then
		-- fade in night overlay
		local progress = math.min((t - NightCycle.DAY_DURATION) / 30, 1)
		local targetTransparency = 1 - (0.55 * progress)
		-- smooth lerp
		local current = overlayFrame.BackgroundTransparency
		overlayFrame.BackgroundTransparency = current + (targetTransparency - current) * 0.05

		-- spawn fireflies periodically
		if math.random() < 0.08 then spawnFireflies() end

		-- glow breakables
		updateBreakableGlow()
	else
		-- fade out
		local current = overlayFrame.BackgroundTransparency
		overlayFrame.BackgroundTransparency = current + (1 - current) * 0.05

		-- remove breakable glows
		for b, gl in pairs(glowLights) do
			gl:Destroy()
			glowLights[b] = nil
		end
	end
end)

-- cleanup on character reset
player.CharacterAdded:Connect(function()
	for _, gl in pairs(glowLights) do gl:Destroy() end
	glowLights = {}
end)

return NightCycle
