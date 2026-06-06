local Decor = {}

local function p(props)
	local part = Instance.new("Part"); part.Anchored = true; part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do part[k] = v end
	return part
end

local function light(parent, color, range, brightness)
	local lt = Instance.new("PointLight"); lt.Color = color or Color3.new(1,1,1)
	lt.Range = range or 16; lt.Brightness = brightness or 1.5; lt.Parent = parent
end

local function sparkle(parent, color)
	local em = Instance.new("ParticleEmitter"); em.Texture = "rbxassetid://243660364"
	em.Rate = 4; em.Lifetime = NumberRange.new(1.5, 3); em.Speed = NumberRange.new(0.5, 1.5)
	em.Size = NumberSequence.new(0.3); em.Color = ColorSequence.new(color or Color3.fromRGB(255, 200, 100))
	em.SpreadAngle = Vector2.new(30, 30); em.Parent = parent
end

function Decor.tree(pos, parent, scale, leafColor)
	scale = scale or 1
	leafColor = leafColor or Color3.fromRGB(60, 150, 70)
	local model = Instance.new("Model"); model.Name = "Tree"; model.Parent = parent
	local trunk = p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(7 * scale, 2.2 * scale, 2.2 * scale),
		Color = Color3.fromRGB(105, 70, 40), Material = Enum.Material.Wood,
		CFrame = CFrame.new(pos + Vector3.new(0, 3.5 * scale, 0)) * CFrame.Angles(0, 0, math.pi / 2), Parent = model })
	for i = 0, 2 do
		p({ Shape = Enum.PartType.Ball, Size = Vector3.new((8 - i * 1.6) * scale, (8 - i * 1.6) * scale, (8 - i * 1.6) * scale),
			Color = leafColor:Lerp(Color3.new(1, 1, 1), i * 0.08), Material = Enum.Material.Grass,
			Position = pos + Vector3.new(0, (7 + i * 2.6) * scale, 0), Parent = model })
	end
	return model
end

function Decor.pineTree(pos, parent, scale)
	scale = scale or 1
	local m = Instance.new("Model"); m.Name = "PineTree"; m.Parent = parent
	local trunk = p({ Size = Vector3.new(1.2*scale, 5*scale, 1.2*scale), Color = Color3.fromRGB(90,60,35),
		Material = Enum.Material.Wood, Position = pos + Vector3.new(0, 2.5*scale, 0), Parent = m })
	for i = 0, 2 do
		local r = (5 - i*1.5) * scale
		p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.5*scale, r*2, r*2), Color = Color3.fromRGB(40 + i*20, 120 + i*20, 50 + i*10),
			Material = Enum.Material.Grass, CFrame = CFrame.new(pos + Vector3.new(0, (3 + i*3)*scale, 0)) * CFrame.Angles(0,0,math.pi/2), Parent = m })
	end
	return m
end

function Decor.palmTree(pos, parent, scale)
	scale = scale or 1
	local m = Instance.new("Model"); m.Name = "PalmTree"; m.Parent = parent
	local trunk = p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(10*scale, 1.2*scale, 1.2*scale),
		CFrame = CFrame.new(pos + Vector3.new(0, 5*scale, 0)) * CFrame.Angles(0.2, 0, 0), Color = Color3.fromRGB(140,110,70),
		Material = Enum.Material.Wood, Parent = m })
	for i = 0, 4 do
		local ang = (i / 5) * math.pi * 2
		local leaf = p({ Size = Vector3.new(4*scale, 0.8*scale, 0.5*scale),
			CFrame = CFrame.new(pos + Vector3.new(0, 10*scale, 0)) * CFrame.Angles(0.6, ang, 0) * CFrame.new(0, 0, -3*scale),
			Color = Color3.fromRGB(60, 170, 70), Material = Enum.Material.Grass, Parent = m })
	end
	return m
end

function Decor.bush(pos, parent, color)
	return p({ Shape = Enum.PartType.Ball, Size = Vector3.new(4, 3, 4),
		Color = color or Color3.fromRGB(70, 140, 75), Material = Enum.Material.Grass,
		Position = pos + Vector3.new(0, 1.2, 0), Parent = parent })
end

function Decor.flower(pos, parent, headColor)
	local model = Instance.new("Model"); model.Name = "Flower"; model.Parent = parent
	p({ Size = Vector3.new(0.3, 2, 0.3), Color = Color3.fromRGB(70, 160, 80), Material = Enum.Material.Grass,
		Position = pos + Vector3.new(0, 1, 0), Parent = model })
	p({ Shape = Enum.PartType.Ball, Size = Vector3.new(1.2, 1.2, 1.2),
		Color = headColor or Color3.fromRGB(255, 120, 180), Material = Enum.Material.Neon,
		Position = pos + Vector3.new(0, 2.2, 0), Parent = model })
	return model
end

function Decor.rock(pos, parent, scale)
	scale = scale or 1
	return p({ Shape = Enum.PartType.Block, Size = Vector3.new(4 * scale, 3 * scale, 4.5 * scale),
		Color = Color3.fromRGB(120, 120, 130), Material = Enum.Material.Slate,
		CFrame = CFrame.new(pos + Vector3.new(0, 1.4 * scale, 0)) * CFrame.Angles(math.rad(math.random(-12, 12)), math.rad(math.random(0, 360)), math.rad(math.random(-12, 12))), Parent = parent })
end

function Decor.lamp(pos, parent, glowColor)
	local model = Instance.new("Model"); model.Name = "Lamp"; model.Parent = parent
	p({ Size = Vector3.new(0.6, 10, 0.6), Color = Color3.fromRGB(40, 40, 48), Material = Enum.Material.Metal,
		Position = pos + Vector3.new(0, 5, 0), Parent = model })
	local bulb = p({ Shape = Enum.PartType.Ball, Size = Vector3.new(2, 2, 2),
		Color = glowColor or Color3.fromRGB(255, 240, 180), Material = Enum.Material.Neon,
		Position = pos + Vector3.new(0, 10, 0), Parent = model })
	light(bulb, glowColor, 20, 2.5)
	sparkle(bulb, glowColor)
	return model
end

function Decor.torch(pos, parent, color)
	local m = Instance.new("Model"); m.Name = "Torch"; m.Parent = parent
	local base = p({ Size = Vector3.new(1.2, 8, 1.2), Color = Color3.fromRGB(60, 50, 40), Material = Enum.Material.Wood,
		Position = pos + Vector3.new(0, 4, 0), Parent = m })
	local fire = p({ Shape = Enum.PartType.Ball, Size = Vector3.new(2, 2.5, 2), Color = color or Color3.fromRGB(255, 150, 50),
		Material = Enum.Material.Neon, Position = pos + Vector3.new(0, 8.5, 0), Parent = m })
	light(fire, color or Color3.fromRGB(255, 160, 60), 18, 3)
	local em = Instance.new("ParticleEmitter"); em.Texture = "rbxassetid://243660364"
	em.Rate = 15; em.Lifetime = NumberRange.new(0.4, 0.8); em.Speed = NumberRange.new(1, 3)
	em.Size = NumberSequence.new(0.6); em.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 80, 30))
	em.SpreadAngle = Vector2.new(30, 30); em.Acceleration = Vector3.new(0, 2, 0); em.Parent = fire
	return m
end

function Decor.fence(pos, parent, length, rot)
	local model = Instance.new("Model"); model.Name = "Fence"; model.Parent = parent
	length = length or 12
	local rail = CFrame.new(pos) * CFrame.Angles(0, math.rad(rot or 0), 0)
	for _, h in ipairs({ 1.6, 3.2 }) do
		p({ Size = Vector3.new(length, 0.4, 0.4), Color = Color3.fromRGB(150, 110, 70), Material = Enum.Material.Wood,
			CFrame = rail * CFrame.new(0, h, 0), Parent = model })
	end
	for off = -length / 2, length / 2, length / 3 do
		p({ Size = Vector3.new(0.5, 4, 0.5), Color = Color3.fromRGB(120, 85, 55), Material = Enum.Material.Wood,
			CFrame = rail * CFrame.new(off, 2, 0), Parent = model })
	end
	return model
end

function Decor.fountain(pos, parent)
	local model = Instance.new("Model"); model.Name = "Fountain"; model.Parent = parent
	local base = p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 16, 16), Color = Color3.fromRGB(180, 180, 190),
		Material = Enum.Material.Marble, CFrame = CFrame.new(pos + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.pi / 2), Parent = model })
	local bowl = p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.5, 12, 12), Color = Color3.fromRGB(160, 160, 175),
		Material = Enum.Material.Marble, CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.pi / 2), Parent = model })
	local water = p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5, 10, 10), Color = Color3.fromRGB(90, 210, 240),
		Material = Enum.Material.Glass, Transparency = 0.2, CFrame = CFrame.new(pos + Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.pi / 2), Parent = model })
	local spout = p({ Size = Vector3.new(1.8, 7, 1.8), Color = Color3.fromRGB(180, 180, 190), Material = Enum.Material.Marble,
		Position = pos + Vector3.new(0, 5, 0), Parent = model })
	local spire = p({ Shape = Enum.PartType.Ball, Size = Vector3.new(2, 2, 2), Color = Color3.fromRGB(200, 210, 255),
		Material = Enum.Material.Neon, Position = pos + Vector3.new(0, 8.5, 0), Parent = model })
	light(spire, Color3.fromRGB(150, 200, 255), 22, 3)
	local em = Instance.new("ParticleEmitter"); em.Texture = "rbxassetid://243660364"
	em.Rate = 25; em.Lifetime = NumberRange.new(1, 2); em.Speed = NumberRange.new(5, 8)
	em.SpreadAngle = Vector2.new(15, 15); em.Color = ColorSequence.new(Color3.fromRGB(150, 220, 255))
	em.Acceleration = Vector3.new(0, -15, 0); em.Parent = spout
	local em2 = Instance.new("ParticleEmitter"); em2.Texture = "rbxassetid://243660364"
	em2.Rate = 5; em2.Lifetime = NumberRange.new(2, 4); em2.Speed = NumberRange.new(0.5, 1)
	em2.Size = NumberSequence.new(0.4); em2.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255)); em2.Parent = spire
	return model
end

function Decor.arch(pos, parent, color, text)
	local model = Instance.new("Model"); model.Name = "Arch"; model.Parent = parent
	color = color or Color3.fromRGB(150, 150, 160)
	for _, dx in ipairs({ -7, 7 }) do
		local pillar = p({ Size = Vector3.new(2.5, 18, 2.5), Color = color, Material = Enum.Material.Marble,
			Position = pos + Vector3.new(dx, 9, 0), Parent = model })
		local cap = p({ Size = Vector3.new(3.5, 1.5, 3.5), Color = color:Lerp(Color3.new(1,1,1), 0.15), Material = Enum.Material.Marble,
			Position = pos + Vector3.new(dx, 18, 0), Parent = model })
	end
	local top = p({ Size = Vector3.new(20, 3, 3), Color = color, Material = Enum.Material.Marble,
		Position = pos + Vector3.new(0, 18.5, 0), Parent = model })
	local keystone = p({ Size = Vector3.new(3, 4, 3), Color = color:Lerp(Color3.fromRGB(255,200,100), 0.3), Material = Enum.Material.Marble,
		Position = pos + Vector3.new(0, 19, 0), Parent = model })
	if text then
		local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 240, 0, 44); bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.AlwaysOnTop = true; bb.Parent = keystone
		local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1, 1); t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamBlack; t.TextScaled = true; t.TextStrokeTransparency = 0.2
		t.TextColor3 = Color3.fromRGB(255, 235, 150); t.Text = text; t.Parent = bb
	end
	return model
end

function Decor.bench(pos, parent, rot)
	local model = Instance.new("Model"); model.Name = "Bench"; model.Parent = parent
	local basecf = CFrame.new(pos) * CFrame.Angles(0, math.rad(rot or 0), 0)
	p({ Size = Vector3.new(8, 0.5, 2.5), Color = Color3.fromRGB(150, 110, 70), Material = Enum.Material.Wood,
		CFrame = basecf * CFrame.new(0, 2, 0), Parent = model })
	p({ Size = Vector3.new(8, 2.5, 0.5), Color = Color3.fromRGB(130, 95, 60), Material = Enum.Material.Wood,
		CFrame = basecf * CFrame.new(0, 3.2, -1), Parent = model })
	p({ Size = Vector3.new(1.2, 3, 1.2), CFrame = basecf * CFrame.new(-3.5, 1.5, 0), Color = Color3.fromRGB(120, 85, 55), Material = Enum.Material.Wood, Parent = model })
	p({ Size = Vector3.new(1.2, 3, 1.2), CFrame = basecf * CFrame.new(3.5, 1.5, 0), Color = Color3.fromRGB(120, 85, 55), Material = Enum.Material.Wood, Parent = model })
	return model
end

function Decor.barrel(pos, parent)
	return p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 3, 3), Color = Color3.fromRGB(120, 80, 45),
		Material = Enum.Material.Wood, CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.pi / 2), Parent = parent })
end

function Decor.lilypad(pos, parent)
	local model = Instance.new("Model"); model.Name = "Lily"; model.Parent = parent
	p({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 4, 4), Color = Color3.fromRGB(70, 160, 90),
		Material = Enum.Material.Grass, CFrame = CFrame.new(pos + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.pi / 2), Parent = model })
	if math.random() < 0.5 then
		local bloom = p({ Shape = Enum.PartType.Ball, Size = Vector3.new(1.4, 1.4, 1.4), Color = Color3.fromRGB(255, 150, 200),
			Material = Enum.Material.Neon, Position = pos + Vector3.new(0, 1, 0), Parent = model })
		sparkle(bloom, Color3.fromRGB(255, 180, 220))
	end
	return model
end

function Decor.banner(pos, parent, color, text)
	local model = Instance.new("Model"); model.Name = "Banner"; model.Parent = parent
	p({ Size = Vector3.new(0.5, 14, 0.5), Color = Color3.fromRGB(60, 50, 40), Material = Enum.Material.Wood,
		Position = pos + Vector3.new(0, 7, 0), Parent = model })
	p({ Size = Vector3.new(6, 8, 0.3), Color = color or Color3.fromRGB(255, 200, 50),
		Material = Enum.Material.Fabric, Position = pos + Vector3.new(2.8, 9, 0), Parent = model })
	return model
end

function Decor.waterfall(startPos, parent, color, height)
	local m = Instance.new("Model"); m.Name = "Waterfall"; m.Parent = parent
	height = height or 40
	local col = color or Color3.fromRGB(90, 210, 240)
	for i = 0, height/3, 3 do
		local seg = p({ Size = Vector3.new(3, 3, 3), Color = col, Material = Enum.Material.Glass,
			Transparency = 0.15 + (i/height) * 0.3, Position = startPos - Vector3.new(0, i, 0), Parent = m })
	end
	p({ Size = Vector3.new(3, 3, 3), Color = col:Lerp(Color3.new(1,1,1),0.2), Material = Enum.Material.Neon,
		Transparency = 0.1, Position = startPos - Vector3.new(0, height, 0), Parent = m })
	light(p({ Shape=Enum.PartType.Ball, Size=Vector3.new(1,1,1), Position=startPos, Transparency=1, Parent=m }),
		col, 20, 2)
	local em = Instance.new("ParticleEmitter"); em.Texture = "rbxassetid://243660364"
	em.Rate = 12; em.Lifetime = NumberRange.new(0.8, 1.5); em.Speed = NumberRange.new(4, 7)
	em.Size = NumberSequence.new(0.5); em.Color = ColorSequence.new(col)
	em.Acceleration = Vector3.new(0, -10, 0); em.SpreadAngle = Vector2.new(5, 10); em.Parent = em
	em.Parent = m
	return m
end

function Decor.crystal(pos, parent, color)
	local m = Instance.new("Model"); m.Name="Crystal"; m.Parent=parent
	for i=1,4 do
		local h=4+math.random()*6
		local cr = p({ Size=Vector3.new(1.4,h,1.4), Color=color or Color3.fromRGB(140,200,255), Material=Enum.Material.Glass,
			Transparency=0.1, CFrame=CFrame.new(pos+Vector3.new(math.random(-3,3),h/2,math.random(-3,3)))*CFrame.Angles(math.rad(math.random(-20,20)),0,math.rad(math.random(-20,20))), Parent=m })
	end
	light(p({ Shape=Enum.PartType.Ball, Size=Vector3.new(1,1,1), Position=pos, Transparency=1, Parent=m }), color, 14, 2)
	return m
end

function Decor.mushroom(pos, parent, capColor)
	local m=Instance.new("Model"); m.Name="Mushroom"; m.Parent=parent
	local s=0.7+math.random()*1.2
	p({ Size=Vector3.new(1.4*s,4*s,1.4*s), Color=Color3.fromRGB(235,225,200), Material=Enum.Material.SmoothPlastic, Position=pos+Vector3.new(0,2*s,0), Parent=m })
	local cap = p({ Shape=Enum.PartType.Ball, Size=Vector3.new(5*s,3.5*s,5*s), Color=capColor or Color3.fromRGB(230,70,80), Material=Enum.Material.SmoothPlastic, Position=pos+Vector3.new(0,4.4*s,0), Parent=m })
	if math.random() < 0.4 then
		p({ Shape=Enum.PartType.Ball, Size=Vector3.new(1*s,1*s,1*s), Color=Color3.new(1,1,1), Material=Enum.Material.SmoothPlastic, Position=pos+Vector3.new(1.2*s,5*s,1*s), Parent=m })
	end
	return m
end

function Decor.coral(pos, parent, color)
	local m=Instance.new("Model"); m.Name="Coral"; m.Parent=parent
	local cols={Color3.fromRGB(255,120,150),Color3.fromRGB(255,170,80),Color3.fromRGB(150,120,255),Color3.fromRGB(80,220,200)}
	color=color or cols[math.random(1,#cols)]
	for i=1,5 do
		local h=3+math.random()*6
		p({ Size=Vector3.new(1.2,h,1.2), Color=color, Material=Enum.Material.Neon,
			CFrame=CFrame.new(pos+Vector3.new(math.random(-4,4),h/2,math.random(-4,4)))*CFrame.Angles(math.rad(math.random(-30,30)),0,math.rad(math.random(-30,30))), Parent=m })
	end
	sparkle(p({ Shape=Enum.PartType.Ball, Size=Vector3.new(1,1,1), Position=pos+Vector3.new(0,6,0), Transparency=1, Parent=m }), color)
	return m
end

function Decor.cactus(pos, parent)
	local m=Instance.new("Model"); m.Name="Cactus"; m.Parent=parent
	local g=Color3.fromRGB(70,150,80)
	p({ Size=Vector3.new(2.5,8,2.5), Color=g, Material=Enum.Material.Grass, Position=pos+Vector3.new(0,4,0), Parent=m })
	p({ Size=Vector3.new(1.4,3,1.4), Color=g, Material=Enum.Material.Grass, Position=pos+Vector3.new(2,5,0), Parent=m })
	p({ Size=Vector3.new(1.4,3,1.4), Color=g, Material=Enum.Material.Grass, Position=pos+Vector3.new(-2,6,0), Parent=m })
	return m
end

function Decor.star(pos, parent, color)
	local b=p({ Shape=Enum.PartType.Ball, Size=Vector3.new(2.5,2.5,2.5), Color=color or Color3.fromRGB(255,240,150),
		Material=Enum.Material.Neon, Position=pos+Vector3.new(0,4+math.random()*6,0), Parent=parent })
	light(b, b.Color, 12, 2.5); sparkle(b, b.Color)
	return b
end

function Decor.candy(pos, parent)
	local m=Instance.new("Model"); m.Name="Candy"; m.Parent=parent
	local cols={Color3.fromRGB(255,90,160),Color3.fromRGB(120,200,255),Color3.fromRGB(255,210,70)}
	p({ Size=Vector3.new(1,9,1), Color=Color3.fromRGB(255,255,255), Material=Enum.Material.SmoothPlastic, Position=pos+Vector3.new(0,4.5,0), Parent=m })
	local ball = p({ Shape=Enum.PartType.Ball, Size=Vector3.new(4,4,4), Color=cols[math.random(1,#cols)], Material=Enum.Material.SmoothPlastic, Position=pos+Vector3.new(0,9,0), Parent=m })
	light(ball, ball.Color, 10, 1.5)
	return m
end

function Decor.gear(pos, parent, color)
	return p({ Shape=Enum.PartType.Cylinder, Size=Vector3.new(0.8,5,5), Color=color or Color3.fromRGB(120,130,140),
		Material=Enum.Material.Metal, CFrame=CFrame.new(pos+Vector3.new(0,3,0))*CFrame.Angles(0,0,math.pi/2), Parent=parent })
end

function Decor.bone(pos, parent)
	local m=Instance.new("Model"); m.Name="Bone"; m.Parent=parent
	p({ Size=Vector3.new(0.8,5,0.8), Color=Color3.fromRGB(235,228,210), Material=Enum.Material.SmoothPlastic,
		CFrame=CFrame.new(pos+Vector3.new(0,1,0))*CFrame.Angles(0,0,math.rad(70)), Parent=m })
	return m
end

function Decor.scatter(center, parent, count, innerR, outerR, fn)
	for _ = 1, count do
		local ang = math.random() * math.pi * 2
		local r = innerR + math.random() * (outerR - innerR)
		fn(center + Vector3.new(math.cos(ang) * r, 0, math.sin(ang) * r), parent)
	end
end

function Decor.themed(name, pos, parent, accent)
	if name=="crystal" then return Decor.crystal(pos,parent,accent)
	elseif name=="mushroom" then return Decor.mushroom(pos,parent)
	elseif name=="coral" then return Decor.coral(pos,parent)
	elseif name=="cactus" then return Decor.cactus(pos,parent)
	elseif name=="star" then return Decor.star(pos,parent,accent)
	elseif name=="candy" then return Decor.candy(pos,parent)
	elseif name=="gear" then return Decor.gear(pos,parent,accent)
	elseif name=="bone" then return Decor.bone(pos,parent)
	elseif name=="rock" then return Decor.rock(pos,parent,0.8+math.random())
	else return Decor.tree(pos,parent,0.8+math.random()*0.7)
	end
end

return Decor
