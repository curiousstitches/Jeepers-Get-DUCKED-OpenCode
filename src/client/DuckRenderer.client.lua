-- src/client/DuckRenderer.client.lua  | renders your equipped squad as follow-ducks (pooled, capped)
-- Enhanced: personality billboards + rainbow trails + dance party wobble
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")

local player  = Players.LocalPlayer
local Shared  = ReplicatedStorage:WaitForChild("Shared")
local DuckModelBuilder = require(Shared:WaitForChild("DuckModelBuilder"))
local DuckPersonality  = require(script.Parent.DuckPersonality)
local RainbowTrail     = require(script.Parent.RainbowTrail)
local DanceParty       = require(script.Parent.DanceParty)
local NightCycle       = require(script.Parent.NightCycle) -- starts ambient cycle
local WindController   = require(script.Parent.WindController) -- starts grass wind sway
local ButterflySwarm   = require(script.Parent.ButterflySwarm) -- starts butterfly particles
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryChanged = Remotes:WaitForChild("InventoryChanged")

local RENDER_CAP = 30
local folder = Instance.new("Folder"); folder.Name = "MyDucks_" .. player.UserId; folder.Parent = Workspace

local active = {}   -- [duckId] = model
local wantIds = {}  -- ordered list of duck ids to render
local duckData = {} -- [duckId] = data (for rarity color)

local function rebuild(data)
	local byId = {}; for _, d in ipairs(data.ducks or {}) do byId[d.id] = d end
	wantIds = {}
	for _, id in ipairs(data.equipped or {}) do
		if byId[id] then table.insert(wantIds, id) end
		if #wantIds >= RENDER_CAP then break end
	end
	for id, d in pairs(byId) do duckData[id] = d end
	local wantSet = {}; for _, id in ipairs(wantIds) do wantSet[id] = true end

	for id, model in pairs(active) do
		if not wantSet[id] then
			RainbowTrail.detach(model)
			DanceParty.unregisterDuck(model)
			model:Destroy(); active[id] = nil
		end
	end
	for _, id in ipairs(wantIds) do
		if not active[id] then
			local d = byId[id]
			local ok, model = pcall(function() return DuckModelBuilder.build(d) end)
			if ok and model then
				model.Parent = folder; active[id] = model
				local rarityColor = Color3.fromRGB(255, 221, 51) -- default gold
				local DuckSchema = Shared:FindFirstChild("DuckSchema")
				if DuckSchema then
					local r = require(DuckSchema).getRarity(d.rarity)
					if r then rarityColor = r.color end
				end
				DuckPersonality.attach(model, id, rarityColor)
				RainbowTrail.attach(model, rarityColor)
				DanceParty.registerDuck(model)
			end
		end
	end
end

InventoryChanged.OnClientEvent:Connect(rebuild)

-- formation with dance wobble support
local CollectionService = game:GetService("CollectionService")
local t = 0
local function nearestBreakable(pos)
	local best, bd
	for _, b in ipairs(CollectionService:GetTagged("Breakable")) do
		if b:IsA("BasePart") and b.Transparency < 1 then
			local d = (b.Position - pos).Magnitude
			if d <= 26 and (not bd or d < bd) then best, bd = b, d end
		end
	end
	return best
end
RunService.RenderStepped:Connect(function(dt)
	t += dt
	RainbowTrail.update(dt)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local n = #wantIds
	if n == 0 then return end
	local targetBreak = nearestBreakable(root.Position)
	for i, id in ipairs(wantIds) do
		local model = active[id]
		if model and model.PrimaryPart then
			local bob = math.sin(t * 3 + i) * 0.4
			local finalCF: CFrame
			if targetBreak then
				local peck = math.abs(math.sin(t * 10 + i)) * 3
				local side = ((i % 2 == 0) and 1 or -1) * (1 + (i % 3))
				local atkPos = targetBreak.Position + Vector3.new(side, 2 + bob, 0) - (targetBreak.Position - root.Position).Unit * peck
				finalCF = CFrame.new(atkPos, targetBreak.Position) * CFrame.Angles(math.rad(-peck * 6), 0, 0)
			else
				local angle = (i / n) * math.pi - math.pi / 2
				local back = root.CFrame * CFrame.new(math.sin(angle) * (2 + n * 0.3), 0, 4 + (i % 2) * 2)
				local pos = back.Position + Vector3.new(0, 2 + bob, 0)
				finalCF = CFrame.new(pos, pos + root.CFrame.LookVector) * CFrame.Angles(0, math.pi, 0)
			end
			finalCF = DanceParty.applyWobble(model, finalCF)
			model:PivotTo(finalCF)
		end
	end
end)
