-- ComboParty: milestone celebrations for combo streaks
-- Confetti bursts, screen shake, milestone popup text
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ComboParty = {}

local vfxHolder: Folder
local function ensureFolder()
	if not vfxHolder or not vfxHolder.Parent then
		vfxHolder = Instance.new("Folder"); vfxHolder.Name = "ComboParty_" .. player.UserId; vfxHolder.Parent = Workspace.Terrain
	end
	return vfxHolder
end

-- confetti burst: colorful small parts sprayed upward
local function confettiBurst(origin: Vector3, count: number)
	local colors = {
		Color3.fromRGB(255, 80, 80), Color3.fromRGB(80, 200, 255),
		Color3.fromRGB(255, 220, 60), Color3.fromRGB(140, 80, 255),
		Color3.fromRGB(80, 255, 120), Color3.fromRGB(255, 140, 200),
	}
	for i = 1, count do
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.2, 0.2, 0.05)
		p.Anchored = true; p.CanCollide = false
		p.Material = Enum.Material.SmoothPlastic
		p.Color = colors[i % #colors + 1]
		p.Transparency = 0
		p.Parent = ensureFolder()
		p.CFrame = CFrame.new(origin + Vector3.new(math.random(-2, 2), 0.5, math.random(-2, 2)))

		local vel = Vector3.new(math.random(-8, 8), math.random(8, 18), math.random(-8, 8))
		local endPos = p.Position + vel * 0.8
		local endRot = CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)))

		TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = CFrame.new(endPos) * endRot, Transparency = 1 }):Play()
		task.delay(0.85, p.Destroy, p)
	end
end

-- camera shake
local function cameraShake(intensity: number, duration: number)
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local orig = cam.CFrame
	local elapsed = 0
	local con: RBXScriptConnection?
	con = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed >= duration then
			cam.CFrame = orig
			if con then con:Disconnect() end
			return
	end
		local shake = CFrame.Angles(
			math.rad(math.random(-intensity, intensity)),
			math.rad(math.random(-intensity, intensity)),
			math.rad(math.random(-intensity, intensity))
		)
		cam.CFrame = orig * shake
	end)
end

-- milestone popup (billboard text that floats up)
local popupPool: { BillboardGui } = {}
local popupIdx = 1
local function milestonePopup(text: string, color: Color3, size: number, position: Vector3)
	local bg = popupPool[popupIdx]
	if not bg then
		bg = Instance.new("BillboardGui")
		bg.Size = UDim2.new(0, 240, 0, 48)
		bg.AlwaysOnTop = true
		bg.Parent = ensureFolder()
		local label = Instance.new("TextLabel")
		label.Name = "M"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.TextStrokeTransparency = 0.1
		label.TextScaled = true
		label.Parent = bg
		table.insert(popupPool, bg)
	end
	popupIdx = popupIdx % 10 + 1

	bg.Adornee = nil
	bg.StudsOffset = Vector3.new(0, 0, 0)
	local label = bg:FindFirstChild("M") :: TextLabel
	if not label then return end
	label.Text = text
	label.TextColor3 = color

	local start = os.clock()
	local dur = 1.5
	local con: RBXScriptConnection?
	con = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / dur
		if t >= 1 then
			bg.StudsOffset = Vector3.new(0, 10, 0)
			label.TextTransparency = 1
			if con then con:Disconnect() end
			return
		end
		local scale = 1 + t * 0.3
		bg.Size = UDim2.new(0, 240 * scale, 0, 48 * scale)
		bg.StudsOffset = Vector3.new(0, t * 6, 0)
		label.TextTransparency = t * 0.5
	end)

	-- pulse outline effect
	task.spawn(function()
		local pulse = Instance.new("Part")
		pulse.Shape = Enum.PartType.Ball; pulse.Size = Vector3.new(1, 1, 1)
		pulse.Anchored = true; pulse.CanCollide = false
		pulse.Color = color; pulse.Material = Enum.Material.Neon
		pulse.Transparency = 0.6; pulse.CFrame = CFrame.new(position)
		pulse.Parent = ensureFolder()
		TweenService:Create(pulse, TweenInfo.new(0.6), { Size = Vector3.new(6, 6, 6), Transparency = 1 }):Play()
		task.delay(0.65, pulse.Destroy, pulse)
	end)
end

local MILESTONES = {
	[10] = { text = "x10 COMBO!", color = Color3.fromRGB(140, 200, 255), confetti = 12, shake = 1 },
	[25] = { text = "x25 COMBO!", color = Color3.fromRGB(200, 140, 255), confetti = 24, shake = 2 },
	[50] = { text = "🌈 x50 COMBO MASTER!", color = Color3.fromRGB(255, 220, 60), confetti = 40, shake = 3 },
	[100] = { text = "⭐ LEGENDARY x100! ⭐", color = Color3.fromRGB(255, 80, 80), confetti = 60, shake = 4 },
}

function ComboParty.celebrate(combo: number, position: Vector3)
	local ms = MILESTONES[combo]
	if not ms then return end

	confettiBurst(position, ms.confetti)
	cameraShake(ms.shake, 0.3)
	milestonePopup(ms.text, ms.color, 240, position)
end

return ComboParty
