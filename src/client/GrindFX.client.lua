--!strict
-- visual feast: floating text, coin bursts, screen flash for every breakable smash
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BreakSmashed = Remotes:WaitForChild("BreakSmashed")
local ComboMeter = require(script.Parent.ComboMeter)
local ComboParty = require(script.Parent.ComboParty)

local vfxHolder: Folder
local function ensureVFXFolder()
	if not vfxHolder or not vfxHolder.Parent then
		vfxHolder = Instance.new("Folder"); vfxHolder.Name = "GrindVFX_" .. player.UserId; vfxHolder.Parent = Workspace.Terrain
	end
	return vfxHolder
end

local function formatReward(n: number): string
	if n >= 1000000 then return string.format("%.1fM", n / 1000000)
	elseif n >= 1000 then return string.format("%.1fK", n / 1000)
	else return tostring(n) end
end

-- ===== FLOATING TEXT =====
local textPool: { BillboardGui } = {}
local textPoolIdx = 1
local function spawnFloatingText(text: string, color: Color3, position: Vector3, size: number)
	local billboard = textPool[textPoolIdx]
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 120, 0, 36)
		billboard.AlwaysOnTop = true
		billboard.Parent = ensureVFXFolder()
		local label = Instance.new("TextLabel")
		label.Name = "T"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.TextStrokeTransparency = 0.15
		label.TextScaled = true
		label.Parent = billboard
		table.insert(textPool, billboard)
	end
	textPoolIdx = textPoolIdx % 30 + 1

	billboard.Adornee = nil
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	local label = billboard:FindFirstChild("T") :: TextLabel
	if not label then return end
	label.Text = text
	label.TextColor3 = color
	label.TextTransparency = 0
	billboard.Size = UDim2.new(0, size or 120, 0, 36)

	local startTime = os.clock()
	local dur = 1.2
	local con: RBXScriptConnection?
	con = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - startTime) / dur
		if t >= 1 then
			billboard.StudsOffset = Vector3.new(0, 8, 0)
			label.TextTransparency = 1
			if con then con:Disconnect() end
			return
		end
		billboard.StudsOffset = Vector3.new(0, t * 8, 0)
		label.TextTransparency = t
	end)
end

-- ===== COIN BURST =====
local burstPool: { BasePart } = {}
local burstIdx = 1
local function coinBurst(position: Vector3, count: number)
	local n = math.clamp(count, 4, 24)
	for i = 1, n do
		local part = burstPool[burstIdx]
		if not part then
			part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Material = Enum.Material.Neon
			part.Anchored = false
			part.CanCollide = false
			part.Size = Vector3.new(0.3, 0.3, 0.3)
			table.insert(burstPool, part)
		end
		burstIdx = burstIdx % 60 + 1

		part.CFrame = CFrame.new(position + Vector3.new(math.random(-1, 1), math.random(0, 2), math.random(-1, 1)))
		part.Color = Color3.fromRGB(255, 200 + math.random(0, 55), 50 + math.random(0, 50))
		part.Transparency = 0
		part.Size = Vector3.new(0.2 + math.random() * 0.3, 0.2 + math.random() * 0.3, 0.2 + math.random() * 0.3)
		part.Parent = ensureVFXFolder()

		local vel = Vector3.new(math.random(-12, 12), math.random(6, 18), math.random(-12, 12))
		local bodyVel = Instance.new("BodyVelocity")
		bodyVel.Velocity = vel; bodyVel.MaxForce = Vector3.new(1, 1, 1) * 10000
		bodyVel.Parent = part

		task.delay(0.4 + math.random() * 0.3, function()
			bodyVel:Destroy()
			local ts = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Transparency = 1, Size = Vector3.new(0, 0, 0) })
			ts:Play()
			ts.Completed:Connect(function() part.Parent = nil end)
		end)
	end
end

-- ===== SCREEN FLASH =====
local flashGui: ScreenGui?
local flashFrame: Frame?
local function screenFlash(color: Color3, intensity: number)
	if not flashGui or not flashGui.Parent then
		flashGui = Instance.new("ScreenGui")
		flashGui.Name = "GrindFlash"
		flashGui.IgnoreGuiInset = true
		flashGui.Parent = player:WaitForChild("PlayerGui")
		flashFrame = Instance.new("Frame")
		flashFrame.Size = UDim2.fromScale(1, 1)
		flashFrame.BackgroundColor3 = Color3.fromRGB(255, 220, 80)
		flashFrame.BackgroundTransparency = 1
		flashFrame.BorderSizePixel = 0
		flashFrame.Parent = flashGui
	end
	if not flashFrame then return end
	local i = math.clamp(intensity, 0, 0.8)
	flashFrame.BackgroundColor3 = color
	flashFrame.BackgroundTransparency = 1
	TweenService:Create(flashFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 - i }):Play()
	task.delay(0.12, function()
		TweenService:Create(flashFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ BackgroundTransparency = 1 }):Play()
	end)
end

-- ===== COLLECTION BEAM (from breakable to player) =====
local beamPart: BasePart?
local function spawnCollectBeam(fromPos: Vector3, toPos: Vector3)
	if not beamPart then
		beamPart = Instance.new("Part")
		beamPart.Name = "CollectBeam"
		beamPart.Anchored = true
		beamPart.CanCollide = false
		beamPart.Material = Enum.Material.Neon
		beamPart.Color = Color3.fromRGB(255, 220, 80)
		beamPart.Transparency = 0.4
		beamPart.Parent = Workspace.Terrain
	end
	local mid = (fromPos + toPos) / 2
	local dir = toPos - fromPos
	local len = dir.Magnitude
	beamPart.Size = Vector3.new(0.4, 0.4, len)
	beamPart.CFrame = CFrame.lookAt(mid, toPos) * CFrame.Angles(math.pi / 2, 0, 0)
	beamPart.Transparency = 0.2
	task.delay(0.15, function()
		TweenService:Create(beamPart, TweenInfo.new(0.2), { Transparency = 1 }):Play()
	end)
end

-- ===== MAIN HANDLER =====
BreakSmashed.OnClientEvent:Connect(function(data: any)
	if not data or not data.position then return end
	local combo = data.combo or 1
	local reward = data.reward or 0

	-- floating text color: scales with combo
	local textColor: Color3
	local textSize = 120
	if combo >= 20 then textColor = Color3.fromRGB(80, 255, 200); textSize = 200
	elseif combo >= 10 then textColor = Color3.fromRGB(255, 80, 200); textSize = 170
	elseif combo >= 5 then textColor = Color3.fromRGB(255, 180, 60); textSize = 150
	else textColor = Color3.fromRGB(255, 220, 80) end

	local prefix = combo > 1 and string.format("x%d ", combo) or ""
	spawnFloatingText(prefix .. formatReward(reward), textColor, data.position, textSize)

	-- coin burst scales with combo
	coinBurst(data.position, combo)

	-- screen flash at milestones
	if combo >= 5 then screenFlash(Color3.fromRGB(255, 180, 60), math.min(combo / 20, 0.8))
	elseif reward >= 1000 then screenFlash(Color3.fromRGB(255, 220, 80), 0.4) end

	-- update combo meter
	ComboMeter.hit(combo)

	-- milestone celebration
	if combo == 10 or combo == 25 or combo == 50 or combo == 100 then
		ComboParty.celebrate(combo, data.position)
	end

	-- collect beam (fly toward player)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then spawnCollectBeam(data.position, root.Position + Vector3.new(0, 2, 0)) end
end)


