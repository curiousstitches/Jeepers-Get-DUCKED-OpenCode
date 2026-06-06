-- GrassGenerator: creates tall grass, ferns, flower meadows, and vines
-- All generated parts are tagged for client-side wind animation
local CollectionService = game:GetService("CollectionService")

local GrassGenerator = {}

local function part(props)
	local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	return p
end

-- === TALL GRASS PATCH ===
-- Generates a cluster of grass blades at the given position
function GrassGenerator.tallGrassPatch(pos: Vector3, parent: Instance, count: number?, heightMin: number?, heightMax: number?)
	count = count or 6 + math.random(0, 4)
	heightMin = heightMin or 1.4
	heightMax = heightMax or 2.8
	local model = Instance.new("Model"); model.Name = "TallGrass"; model.Parent = parent

	for i = 1, count do
		local h = heightMin + math.random() * (heightMax - heightMin)
		local w = 0.06 + math.random() * 0.06
		local offset = Vector3.new(math.random(-1.2, 1.2), 0, math.random(-1.2, 1.2))
		local g = 100 + math.random(0, 60)
		local blade = part({
			Size = Vector3.new(w, h, 0.3 + math.random() * 0.15),
			CFrame = CFrame.new(pos + offset + Vector3.new(0, h / 2, 0)) * CFrame.Angles(math.rad(math.random(-5, 5)), math.random() * 6.28, math.rad(math.random(-5, 5))),
			Color = Color3.fromRGB(g, g + 20 + math.random(0, 20), g - 10 + math.random(0, 10)),
			Material = Enum.Material.Grass,
			Parent = model,
		})
		CollectionService:AddTag(blade, "AnimatedGrass")
	end
	return model
end

-- === FERN ===
-- A leafy frond with multiple leaflets
function GrassGenerator.fern(pos: Vector3, parent: Instance, scale: number?)
	scale = scale or 1
	local model = Instance.new("Model"); model.Name = "Fern"; model.Parent = parent
	local green = Color3.fromRGB(50 + math.random(0, 30), 120 + math.random(0, 40), 50 + math.random(0, 20))

	local stem = part({
		Size = Vector3.new(0.08 * scale, 1.8 * scale, 0.08 * scale),
		CFrame = CFrame.new(pos + Vector3.new(0, 0.9 * scale, 0)),
		Color = green, Material = Enum.Material.Grass, Parent = model,
	})
	CollectionService:AddTag(stem, "AnimatedGrass")

	for i = 1, 5 do
		local side = (i % 2 == 0) and 1 or -1
		local leaflet = part({
			Size = Vector3.new(0.04 * scale, 0.5 * scale, 0.8 * scale),
			CFrame = CFrame.new(pos + Vector3.new(side * 0.3 * (i / 5) * scale, 0.3 + i * 0.3 * scale, 0)) * CFrame.Angles(math.rad(side * 20 + math.random(-10, 10)), 0, 0),
			Color = green:Lerp(Color3.fromRGB(80, 180, 60), math.random() * 0.3), Material = Enum.Material.Grass, Parent = model,
		})
		CollectionService:AddTag(leaflet, "AnimatedGrass")
	end
	return model
end

-- === FLOWER CLUSTER ===
-- Multiple flowers of random colors arranged in a small patch
function GrassGenerator.flowerCluster(pos: Vector3, parent: Instance, count: number?)
	count = count or 3 + math.random(0, 4)
	local model = Instance.new("Model"); model.Name = "Flowers"; model.Parent = parent
	local flowerColors = {
		Color3.fromRGB(255, 120, 180), Color3.fromRGB(255, 200, 80),
		Color3.fromRGB(180, 100, 255), Color3.fromRGB(255, 80, 80),
		Color3.fromRGB(255, 150, 220), Color3.fromRGB(120, 200, 255),
		Color3.fromRGB(255, 220, 100), Color3.fromRGB(80, 255, 180),
	}

	for i = 1, count do
		local h = 0.8 + math.random() * 1.6
		local offset = Vector3.new(math.random(-1.5, 1.5), 0, math.random(-1.5, 1.5))
		local fc = flowerColors[math.random(1, #flowerColors)]

		local stem = part({
			Size = Vector3.new(0.05, h, 0.05),
			CFrame = CFrame.new(pos + offset + Vector3.new(0, h / 2, 0)) * CFrame.Angles(math.rad(math.random(-4, 4)), 0, math.rad(math.random(-4, 4))),
			Color = Color3.fromRGB(50, 140, 60), Material = Enum.Material.Grass, Parent = model,
		})
		CollectionService:AddTag(stem, "AnimatedGrass")

		local headSize = 0.3 + math.random() * 0.3
		local head = part({
			Shape = Enum.PartType.Ball, Size = Vector3.new(headSize, headSize, headSize),
			CFrame = CFrame.new(pos + offset + Vector3.new(0, h + headSize * 0.4, 0)),
			Color = fc, Material = Enum.Material.Neon, Parent = model,
		})
		CollectionService:AddTag(head, "AnimatedFlower")
	end
	return model
end

-- === VINE (hanging from an edge) ===
function GrassGenerator.vine(startPos: Vector3, parent: Instance, length: number, direction: Vector3?)
	direction = direction or Vector3.new(0, -1, 0)
	length = length or 3 + math.random() * 4
	local model = Instance.new("Model"); model.Name = "Vine"; model.Parent = parent
	local green = Color3.fromRGB(40 + math.random(0, 30), 100 + math.random(0, 40), 40 + math.random(0, 20))
	local segs = math.ceil(length / 0.8)

	for i = 0, segs - 1 do
		local segPos = startPos + direction * (i * 0.8) + Vector3.new(math.sin(i * 1.3) * 0.2, 0, math.cos(i * 1.7) * 0.2)
		local seg = part({
			Size = Vector3.new(0.08, 0.8, 0.08),
			CFrame = CFrame.new(segPos) * CFrame.Angles(math.rad(math.random(-6, 6)), 0, math.rad(math.random(-6, 6))),
			Color = green:Lerp(Color3.fromRGB(80, 160, 50), math.random() * 0.2),
			Material = Enum.Material.Grass, Parent = model,
		})
		CollectionService:AddTag(seg, "AnimatedGrass")
	end

	if math.random() < 0.5 then
		local leafPos = startPos + direction * (length * 0.7) + Vector3.new(math.random(-0.3, 0.3), 0, math.random(-0.3, 0.3))
		local leaf = part({
			Size = Vector3.new(0.04, 0.3, 0.5),
			CFrame = CFrame.new(leafPos) * CFrame.Angles(math.rad(math.random(-30, 30)), math.random() * 6.28, math.rad(math.random(-20, 20))),
			Color = Color3.fromRGB(60, 150, 50), Material = Enum.Material.Grass, Parent = model,
		})
		CollectionService:AddTag(leaf, "AnimatedGrass")
	end

	return model
end

-- === WATER RIPPLE DECORATION ===
-- Places small animated ripples on a water surface
function GrassGenerator.waterRipple(center: Vector3, parent: Instance, radius: number)
	local model = Instance.new("Model"); model.Name = "WaterRipple"; model.Parent = parent
	for i = 1, 3 do
		local a = math.random() * 6.28
		local r = math.random() * radius
		local pos = center + Vector3.new(math.cos(a) * r, 0.2, math.sin(a) * r)
		local ring = part({
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.05, 0.8 + math.random() * 0.6, 0.8 + math.random() * 0.6),
			CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2),
			Color = Color3.fromRGB(180, 230, 255), Material = Enum.Material.Glass,
			Transparency = 0.3, Parent = model,
		})
		CollectionService:AddTag(ring, "WaterRipple")
	end
	return model
end

-- === SCATTER HELPER ===
-- Calls a generator function multiple times in a random ring around center
function GrassGenerator.scatter(center: Vector3, parent: Instance, count: number, innerR: number, outerR: number, fn: (Vector3, Instance) -> ())
	for _ = 1, count do
		local a = math.random() * 6.28
		local r = innerR + math.random() * (outerR - innerR)
		fn(center + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r), parent)
	end
end

-- === SCATTER ALONG ROAD ===
-- Calls a generator function along a line with random offset
function GrassGenerator.scatterAlongLine(fromPos: Vector3, toPos: Vector3, parent: Instance, count: number, lateralSpread: number, fn: (Vector3, Instance) -> ())
	local dir = toPos - fromPos
	local len = dir.Magnitude
	if len < 1 then return end
	local step = len / count
	local baseCF = CFrame.lookAt(fromPos, toPos)

	for i = 0, count - 1 do
		local t = (i + 0.5) / count
		local along = fromPos:Lerp(toPos, t)
		local lat = Vector3.new(math.random(-lateralSpread, lateralSpread), 0, math.random(-lateralSpread, lateralSpread))
		fn(along + lat, parent)
	end
end

return GrassGenerator
