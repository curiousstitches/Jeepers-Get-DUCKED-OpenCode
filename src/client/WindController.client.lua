-- WindController: central wind animation for all tagged flora
-- Animates AnimatedGrass, AnimatedFlower, SwayTree, WaterRipple tagged parts
-- Gentle perpetual wind with gusts, applying smooth sine sway
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local WindController = {
	windAngle = 0,
	windStrength = 0.6,
	gustTimer = 0,
}

-- Cached part lists for performance
local grassCache: { BasePart } = {}
local flowerHeadCache: { BasePart } = {}
local treeCache: { Model } = {}
local rippleCache: { BasePart } = {}

-- Rebuild caches from scratch
local function rebuildCache()
	grassCache = {}
	for _, p in ipairs(CollectionService:GetTagged("AnimatedGrass")) do
		if p:IsA("BasePart") and p.Parent then table.insert(grassCache, p) end
	end
	flowerHeadCache = {}
	for _, p in ipairs(CollectionService:GetTagged("AnimatedFlower")) do
		if p:IsA("BasePart") and p.Parent then table.insert(flowerHeadCache, p) end
	end
	treeCache = {}
	for _, m in ipairs(CollectionService:GetTagged("SwayTree")) do
		if m:IsA("Model") and m.Parent then table.insert(treeCache, m) end
	end
	rippleCache = {}
	for _, p in ipairs(CollectionService:GetTagged("WaterRipple")) do
		if p:IsA("BasePart") and p.Parent then table.insert(rippleCache, p) end
	end
end

-- Listen for new tagged instances to add to cache
local function onTagged(tagName: string, cache: { BasePart | Model })
	return function(inst: Instance)
		if tagName == "SwayTree" and inst:IsA("Model") and inst.Parent then
			table.insert(cache, inst)
		elseif inst:IsA("BasePart") and inst.Parent then
			table.insert(cache, inst)
		end
	end
end

CollectionService:GetInstanceAddedSignal("AnimatedGrass"):Connect(onTagged("AnimatedGrass", grassCache))
CollectionService:GetInstanceAddedSignal("AnimatedFlower"):Connect(onTagged("AnimatedFlower", flowerHeadCache))
CollectionService:GetInstanceAddedSignal("SwayTree"):Connect(onTagged("SwayTree", treeCache))
CollectionService:GetInstanceAddedSignal("WaterRipple"):Connect(onTagged("WaterRipple", rippleCache))

-- Clean removed instances from caches
local function filterCache(cache: { any }, inst: Instance)
	for i, v in ipairs(cache) do
		if v == inst then table.remove(cache, i); break end
	end
end
CollectionService:GetInstanceRemovedSignal("AnimatedGrass"):Connect(function(inst) filterCache(grassCache, inst) end)
CollectionService:GetInstanceRemovedSignal("AnimatedFlower"):Connect(function(inst) filterCache(flowerHeadCache, inst) end)
CollectionService:GetInstanceRemovedSignal("SwayTree"):Connect(function(inst) filterCache(treeCache, inst) end)
CollectionService:GetInstanceRemovedSignal("WaterRipple"):Connect(function(inst) filterCache(rippleCache, inst) end)

local grassSampleRate = 4 -- update 1/N of grass per frame
local grassFrameIdx = 0
local treeSampleRate = 8

RunService.RenderStepped:Connect(function(dt)
	WindController.gustTimer += dt
	-- Wind calculation: smooth sine with occasional gusts
	local baseAngle = math.sin(WindController.gustTimer * 0.15) * 0.3
	local gust = math.max(0, math.sin(WindController.gustTimer * 0.6) ^ 4) * 0.5
	WindController.windAngle = baseAngle + gust
	WindController.windStrength = 0.4 + math.sin(WindController.gustTimer * 0.4) * 0.2 + gust * 0.5

	local wa = WindController.windAngle
	local ws = WindController.windStrength

	-- Animate grass (blades sway at base)
	grassFrameIdx = (grassFrameIdx % grassSampleRate) + 1
	local grassCount = #grassCache
	local startIdx = grassFrameIdx
	while startIdx <= grassCount do
		local blade = grassCache[startIdx]
		if blade and blade.Parent then
			local phase = (startIdx * 1.3) % 6.28
			local height = blade:GetAttribute("GrassHeight") or 1.5
			local sway = math.sin(os.clock() * 2.2 + phase) * ws * 0.12 * math.min(height, 2.5) * 0.5
			local basePos = blade:GetAttribute("BasePosition")
			if not basePos then
				basePos = blade.Position
				blade:SetAttribute("BasePosition", basePos)
			end
			local pos = basePos :: Vector3
			local tilt = CFrame.Angles(sway, 0, sway * wa * 0.5)
			blade.CFrame = CFrame.new(pos) * tilt * CFrame.Angles(0, (startIdx * 0.7) % 6.28, 0)
		end
		startIdx += grassSampleRate
	end

	-- Animate flower heads (gentle bob)
	for i, head in ipairs(flowerHeadCache) do
		if head and head.Parent then
			local phase = (i * 2.1) % 6.28
			local bob = math.sin(os.clock() * 1.8 + phase) * ws * 0.06
			local sway2 = math.sin(os.clock() * 2.5 + phase + 1) * ws * 0.04
			local basePos = head:GetAttribute("BasePosition")
			if not basePos then
				basePos = head.Position
				head:SetAttribute("BasePosition", basePos)
			end
			local pos = basePos :: Vector3
			head.CFrame = CFrame.new(pos) * CFrame.Angles(sway2, 0, bob)
		end
	end

	-- Animate trees (slow sway)
	local treeFrameIdx = (os.clock() * 10) % treeSampleRate
	treeFrameIdx = math.floor(treeFrameIdx) + 1
	for i = treeFrameIdx, #treeCache, treeSampleRate do
		local tree = treeCache[i]
		if tree and tree.Parent and tree.PrimaryPart then
			local primary = tree.PrimaryPart
			local phase = (i * 0.7) % 6.28
			local sway = math.sin(os.clock() * 1.2 + phase) * ws * 0.02
			-- rotate entire tree around base
			local basePos = primary.Position
			local treeCF = tree:GetPivot()
			local tilted = treeCF * CFrame.Angles(sway * wa, 0, sway * 0.3)
			tree:PivotTo(tilted)
		end
	end

	-- Animate water ripples (pulse scale)
	for i, ring in ipairs(rippleCache) do
		if ring and ring.Parent then
			local phase = (i * 0.9 + os.clock() * 1.5) % 6.28
			local pulse = 1 + math.sin(phase) * 0.15
			local baseSize = ring:GetAttribute("BaseSize")
			if not baseSize then
				baseSize = ring.Size
				ring:SetAttribute("BaseSize", baseSize)
			end
			local bs = baseSize :: Vector3
			ring.Size = Vector3.new(bs.X, bs.Y * pulse, bs.Z * pulse)
			ring.Transparency = 0.2 + math.sin(phase) * 0.15
		end
	end
end)

-- Periodic cache rebuild (catches any instances created after init)
task.spawn(function()
	while true do
		task.wait(15)
		rebuildCache()
	end
end)

-- Initial cache build
task.spawn(function()
	task.wait(3) -- wait for world to build and replicate
	rebuildCache()
end)

return WindController
