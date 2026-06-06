-- DanceParty: toggle a wobble dance on all follow ducks + confetti + double loot buff
-- To activate, call DanceParty.toggle()
-- Server applies a global double-loot buff while party is active (30s, 120s cooldown)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StartDanceParty = Remotes:WaitForChild("StartDanceParty")
local DancePartySync = Remotes:WaitForChild("DancePartySync")

local DanceParty = {
	active = false,
	endTime = 0,
	cooldownUntil = 0,
	dancingDucks = {},
}

-- wobble state per duck model
local wobble = {} -- [model] = { phase, speed }

local vfxFolder: Folder
local function ensureFolder()
	if not vfxFolder or not vfxFolder.Parent then
		vfxFolder = Instance.new("Folder"); vfxFolder.Name = "DanceVFX_" .. player.UserId; vfxFolder.Parent = Workspace.Terrain
	end
	return vfxFolder
end

-- party confetti rain (gentle falling)
local rainParts: { BasePart } = {}
local rainIdx = 1
local rainCon: RBXScriptConnection?
local function startConfettiRain()
	if rainCon then return end
	rainCon = RunService.RenderStepped:Connect(function()
		if not DanceParty.active then
			if rainCon then rainCon:Disconnect(); rainCon = nil end
			return
		end
		for _ = 1, 2 do
			local p = rainParts[rainIdx]
			if not p then
				p = Instance.new("Part")
				p.Size = Vector3.new(0.15, 0.15, 0.04)
				p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.SmoothPlastic
				table.insert(rainParts, p)
			end
			rainIdx = rainIdx % 40 + 1
			p.Color = Color3.fromHSV(math.random(), 0.8, 1)
			p.Transparency = 0
			local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local origin = playerPos and playerPos.Position or Vector3.new(0, 0, 0)
			p.CFrame = CFrame.new(origin + Vector3.new(math.random(-15, 15), 12 + math.random(0, 6), math.random(-15, 15)))
			p.Parent = ensureFolder()
			TweenService:Create(p, TweenInfo.new(3 + math.random() * 2, Enum.EasingStyle.Linear),
				{ CFrame = p.CFrame * CFrame.new(math.sin(math.random() * 6) * 3, -14, math.sin(math.random() * 6) * 3), Transparency = 1 }):Play()
			task.delay(4, function() p.Parent = nil end)
		end
	end)
end

local function stopConfettiRain()
	if rainCon then rainCon:Disconnect(); rainCon = nil end
end

-- register a duck model to dance when party is active
function DanceParty.registerDuck(model: Model)
	if not model or not model.PrimaryPart then return end
	wobble[model] = { phase = math.random() * 6.28, speed = 2 + math.random() * 3 }
end

-- unregister a duck
function DanceParty.unregisterDuck(model: Model)
	wobble[model] = nil
end

-- called every RenderStepped by DuckRenderer
function DanceParty.applyWobble(model: Model, originalCF: CFrame): CFrame
	if not DanceParty.active then return originalCF end
	local w = wobble[model]
	if not w then return originalCF end
	local t = tick()
	local angle = math.sin(t * w.speed + w.phase) * 0.15
	local bounce = math.abs(math.sin(t * w.speed * 1.5 + w.phase)) * 1.2
	return originalCF * CFrame.Angles(angle, 0, angle * 0.5) * CFrame.new(0, bounce, 0)
end

-- toggle party
function DanceParty.toggle()
	local now = os.clock()
	if DanceParty.active then
		return
	end
	if now < DanceParty.cooldownUntil then return end

	DanceParty.active = true
	DanceParty.endTime = now + 30
	DanceParty.cooldownUntil = now + 120

	startConfettiRain()
	StartDanceParty:FireServer()

	task.delay(30, function()
		if DanceParty.active then
			DanceParty.active = false
			stopConfettiRain()
		end
	end)
end

DancePartySync.OnClientEvent:Connect(function(active: boolean)
	DanceParty.active = active
	if not active then stopConfettiRain() end
end)

-- remaining cooldown in seconds
function DanceParty.cooldownRemaining(): number
	return math.max(0, DanceParty.cooldownUntil - os.clock())
end

-- remaining duration
function DanceParty.timeRemaining(): number
	if not DanceParty.active then return 0 end
	return math.max(0, DanceParty.endTime - os.clock())
end

return DanceParty
