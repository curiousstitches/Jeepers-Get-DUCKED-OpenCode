local Workspace         = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZoneConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ZoneConfig"))
local Terrain    = require(script.Parent.Terrain)
local Decor      = require(script.Parent.Decor)
local GrassGenerator = require(script.Parent.GrassGenerator)

local ZoneBuilder = {}
ZoneBuilder.OriginX = 0
ZoneBuilder.BaseY = 250
ZoneBuilder.StartZOffset = 80

local function part(props)
	local p=Instance.new("Part"); p.Anchored=true; p.Material=Enum.Material.SmoothPlastic
	for k,v in pairs(props) do p[k]=v end
	return p
end
local function label(pp,text,color,size)
	local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,size or 200,0,44); bb.StudsOffset=Vector3.new(0,4,0)
	bb.AlwaysOnTop=true; bb.Adornee=pp; bb.Parent=pp
	local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Font=Enum.Font.GothamBlack
	t.TextColor3=color or Color3.new(1,1,1); t.TextStrokeTransparency=0.3; t.TextScaled=true; t.Text=text; t.Parent=bb
end

local function breakable(pos,parent,reward,hp,color,mat,currency)
	local b=part({ Name="Breakable", Size=Vector3.new(4,4,4), Position=pos+Vector3.new(0,2,0), Color=color, Material=mat, CanCollide=false, Parent=parent })
	b:SetAttribute("MaxHP",hp); b:SetAttribute("Reward",reward); b:SetAttribute("Currency",currency)
	CollectionService:AddTag(b,"Breakable")
end

local moodDeco = {
	bright = {"tree", "flower", "rock"},
	murky = {"mushroom", "rock", "bone"},
	dim = {"crystal", "gear", "rock"},
	dark = {"crystal", "bone", "star"},
}

function ZoneBuilder.zoneCFrame(zone)
	return Vector3.new(ZoneBuilder.OriginX, ZoneBuilder.BaseY, ZoneConfig.zoneOriginZ(zone) + ZoneConfig.ZoneLength/2 + ZoneBuilder.StartZOffset)
end

function ZoneBuilder.Build()
	local world=Workspace:FindFirstChild("World") or Instance.new("Folder"); world.Name="World"; world.Parent=Workspace
	local zonesRoot=Instance.new("Folder"); zonesRoot.Name="Zones"; zonesRoot.Parent=Workspace
	local W=ZoneConfig.ZoneWidth; local L=ZoneConfig.ZoneLength; local half=W/2

	for zone=1, ZoneConfig.TotalZones do
		local wd=ZoneConfig.worldForZone(zone)
		local stats=ZoneConfig.stats(zone)
		local cz=ZoneConfig.zoneOriginZ(zone)+L/2 + ZoneBuilder.StartZOffset
		local origin=Vector3.new(0,ZoneBuilder.BaseY,cz)
		local folder=Instance.new("Folder"); folder.Name="Zone_"..zone; folder.Parent=zonesRoot

		local art = ZoneConfig.artForZone(zone)
		part({ Name="Floor", Size=Vector3.new(W,4,L), Position=origin+Vector3.new(0,-2,0), Color=wd.floor, Material=art.ground or wd.floorMat, Parent=folder })

		-- road markings: center dashed line
		local dashLen=8; local gap=6; local dashes=math.floor(L/(dashLen+gap))
		for d=0,dashes-1 do
			local dz=-L/2+4 + d*(dashLen+gap)
			part({ Name="RoadDash", Size=Vector3.new(0.6,2.2,dashLen), Position=origin+Vector3.new(0,0.6,dz),
				Color=Color3.fromRGB(220,210,180), Material=Enum.Material.SmoothPlastic, CanCollide=false, Parent=folder })
		end
		-- road edge lines
		for _,s in ipairs({-1,1}) do
			part({ Name="RoadEdge", Size=Vector3.new(1,2.2,L-4), Position=origin+Vector3.new(s*(half-3),0.6,0),
				Color=Color3.fromRGB(200,190,160), Material=Enum.Material.SmoothPlastic, CanCollide=false, Parent=folder })
		end

		for _,s in ipairs({-1,1}) do
			local style = art.walls[((zone + (s==1 and 0 or 1)) % #art.walls)+1]
			Terrain.wallStructures(origin, folder, s, half, L, style, wd.border, wd.accent)
			Terrain.backdrop(origin, folder, s, half, L, wd.border, wd.prop)
		end

		-- ambient particles per mood
		do
			local em=Instance.new("ParticleEmitter"); em.Texture="rbxassetid://243660364"
			em.Rate=6; em.Lifetime=NumberRange.new(3,6); em.Speed=NumberRange.new(1,3)
			local pSize = art.mood=="dark" and 0.5 or 0.8
			em.Size=NumberSequence.new(pSize)
			em.Color=ColorSequence.new(wd.accent); em.SpreadAngle=Vector2.new(180,180)
			if art.lightFx == "godray" then
				em.VelocityInheritance=0; em.Acceleration=Vector3.new(0,-1,0); em.Rate=10
			end
			local emPart=part({ Size=Vector3.new(1,1,1), Position=origin+Vector3.new(0,20,0), Transparency=1, CanCollide=false, Parent=folder })
			emPart.CanQuery=false; em.Parent=emPart
		end

		-- fog effect for dark/murky zones
		if art.mood == "dark" or art.mood == "murky" then
			local fogPart=part({ Size=Vector3.new(1,1,1), Position=origin+Vector3.new(0,2,0), Transparency=1, CanCollide=false, Parent=folder })
			local fe=Instance.new("ParticleEmitter"); fe.Texture="rbxassetid://300883607"
			fe.Rate=4; fe.Lifetime=NumberRange.new(4,8); fe.Speed=NumberRange.new(0.5,2)
			fe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,3),NumberSequenceKeypoint.new(1,8)})
			fe.Transparency=NumberSequence.new(0.4); fe.Color=ColorSequence.new(wd.fog)
			fe.SpreadAngle=Vector2.new(20,20); fe.VelocityInheritance=0; fe.Parent=fogPart
		end

		if (zone-1)%10==0 then
			local sign=part({ Size=Vector3.new(40,10,1), Position=origin+Vector3.new(0,12,-L/2+4), Color=Color3.fromRGB(30,30,38), Parent=folder })
			label(sign, ("WORLD %d\n%s"):format(wd.n, wd.name), wd.accent, 260)
			Decor.arch(origin+Vector3.new(0,0,-L/2+6), folder, wd.accent)
			-- entrance portal glow particles
			local gp=part({ Size=Vector3.new(1,1,1), Position=origin+Vector3.new(0,6,-L/2+10), Transparency=1, CanCollide=false, Parent=folder })
			local ge=Instance.new("ParticleEmitter"); ge.Texture="rbxassetid://243660364"
			ge.Rate=15; ge.Lifetime=NumberRange.new(1,3); ge.Speed=NumberRange.new(2,5)
			ge.Size=NumberSequence.new(0.8); ge.Color=ColorSequence.new(wd.accent)
			ge.SpreadAngle=Vector2.new(30,30); ge.Acceleration=Vector3.new(0,5,0); ge.Parent=gp
		end

		local n=8 + math.floor(zone/12)
		for i=1,n do
			local x=math.random(-half+12, half-12); local z=math.random(-L/2+12, L/2-20)
			breakable(origin+Vector3.new(x,0,z), folder, stats.reward, stats.hp, wd.floor:Lerp(Color3.new(0,0,0),0.3), wd.floorMat, wd.currency)
		end

		local decos = moodDeco[art.mood] or {"rock"}
		Decor.scatter(origin, folder, 4, 10, half-6, function(p, pp)
			Decor.themed(decos[math.random(1,#decos)], p, pp, wd.accent)
		end)

		local doorW=22
		local seg=(W-doorW)/2
		for _,s in ipairs({-1,1}) do
			local gw=part({ Size=Vector3.new(seg,30,4), Position=origin+Vector3.new(s*(doorW/2+seg/2),15,L/2), Color=wd.border, Material=Enum.Material.SmoothPlastic, Parent=folder })
			gw.CanQuery=false
		end
		if zone < ZoneConfig.TotalZones then
			local gate=part({ Name="Gate_"..zone, Size=Vector3.new(doorW,24,3), Position=origin+Vector3.new(0,12,L/2), Color=wd.accent, Material=Enum.Material.ForceField, Transparency=0.35, Parent=folder })
			gate:SetAttribute("GateLevel",zone+1); gate:SetAttribute("GateCost",stats.unlockCost); gate:SetAttribute("GateCurrency",wd.currency)
			CollectionService:AddTag(gate,"LevelGate")
			label(gate, ("ZONE %d\n%d %s"):format(zone+1, stats.unlockCost, wd.curName), wd.accent)
			-- gate glow particles
			local gp=part({ Size=Vector3.new(1,1,1), Position=origin+Vector3.new(0,12,L/2-2), Transparency=1, CanCollide=false, Parent=folder })
			local ge=Instance.new("ParticleEmitter"); ge.Texture="rbxassetid://243660364"
			ge.Rate=8; ge.Lifetime=NumberRange.new(1,2); ge.Speed=NumberRange.new(1,3)
			ge.Size=NumberSequence.new(0.5); ge.Color=ColorSequence.new(wd.accent)
			ge.SpreadAngle=Vector2.new(20,20); ge.Parent=gp
		end

		for e=1,3 do
			local podPos = origin+Vector3.new(half-12-(e-1)*8, 4, L/2-12)
			local pod=part({ Name="Hatcher_"..zone.."_"..e, Shape=Enum.PartType.Ball, Size=Vector3.new(7,9,7), Position=podPos, Color=wd.accent, Material=Enum.Material.Neon, Transparency=0.05, Parent=folder })
			pod:SetAttribute("HatchZone",zone); pod:SetAttribute("EggCost",stats.eggCost); pod:SetAttribute("Currency",wd.currency)
			CollectionService:AddTag(pod,"Hatcher")
			part({ Shape=Enum.PartType.Cylinder, Size=Vector3.new(2,6,6), Position=podPos-Vector3.new(0,5,0), Color=Color3.fromRGB(230,230,240), Material=Enum.Material.Marble, CFrame=CFrame.new(podPos-Vector3.new(0,5,0))*CFrame.Angles(0,0,math.pi/2), Parent=folder })
			local lt=Instance.new("PointLight"); lt.Color=wd.accent; lt.Range=14; lt.Brightness=1.4; lt.Parent=pod
			local em=Instance.new("ParticleEmitter"); em.Texture="rbxassetid://243660364"; em.Rate=10; em.Lifetime=NumberRange.new(0.8,1.4); em.Speed=NumberRange.new(1,2); em.Size=NumberSequence.new(0.6); em.Color=ColorSequence.new(wd.accent); em.Parent=pod
			local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Hatch"; prompt.ObjectText="Jeep Egg "..zone
			prompt.HoldDuration=0.15; prompt.MaxActivationDistance=12
			prompt:SetAttribute("HatchZone",zone); prompt:SetAttribute("EggCost",stats.eggCost); prompt:SetAttribute("Currency",wd.currency); prompt.Parent=pod
			if e==2 then label(pod, ("Hatch: %d %s"):format(stats.eggCost, wd.curName), wd.accent) end
		end

		if zone % 10 == 0 and zone < ZoneConfig.TotalZones then
			local ep=part({ Name="EndPortal_"..zone, Size=Vector3.new(16,20,3), Position=origin+Vector3.new(0,12,L/2-6),
				Color=Color3.fromRGB(150,90,255), Material=Enum.Material.Neon, Transparency=0.2, Parent=folder })
			ep:SetAttribute("NextZone",zone+1); CollectionService:AddTag(ep,"EndPortal")
			label(ep, ("WORLD %d -> %d\nstep through!"):format(wd.n, wd.n+1), Color3.fromRGB(190,140,255))
			-- portal swirl particles
			local pp=part({ Size=Vector3.new(1,1,1), Position=origin+Vector3.new(0,12,L/2-4), Transparency=1, CanCollide=false, Parent=folder })
			local pe=Instance.new("ParticleEmitter"); pe.Texture="rbxassetid://243660364"
			pe.Rate=20; pe.Lifetime=NumberRange.new(0.5,1.5); pe.Speed=NumberRange.new(3,7)
			pe.Size=NumberSequence.new(0.6); pe.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,wd.accent),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,90,255))})
			pe.SpreadAngle=Vector2.new(40,40); pe.Rotation=NumberRange.new(0,360); pe.Parent=pp
		end

		if zone%20==0 then
			local sh=part({ Name="RebirthShrine_"..zone, Shape=Enum.PartType.Cylinder, Size=Vector3.new(3,10,10),
				Position=origin+Vector3.new(-half+10,5,0), Color=Color3.fromRGB(255,215,40), Material=Enum.Material.Neon,
				CFrame=CFrame.new(origin+Vector3.new(-half+10,5,0))*CFrame.Angles(0,0,math.pi/2), Parent=folder })
			sh:SetAttribute("RebirthShrine",true); CollectionService:AddTag(sh,"RebirthShrine")
			label(sh,"REBIRTH",Color3.fromRGB(255,230,120))
		end

		-- LUSH LANDSCAPING: animated grass and flowers along road edges
		local mood = art.mood or "bright"
		local grassCount = (mood == "dark" and 4 or (mood == "murky" and 8 or 12))
		for _ = 1, grassCount do
			local side = (math.random() < 0.5 and -1 or 1)
			local zOff = math.random(-L/2 + 4, L/2 - 4)
			local latOff = 4 + math.random() * 6
			local gp = origin + Vector3.new(side * latOff, 0, zOff)
			if mood == "dark" then
				GrassGenerator.fern(gp, folder, 0.6 + math.random() * 0.4)
			elseif mood == "murky" then
				GrassGenerator.tallGrassPatch(gp, folder, 3 + math.random(0, 3), 0.8, 1.8)
			else
				if math.random() < 0.5 then
					GrassGenerator.tallGrassPatch(gp, folder, 4 + math.random(0, 4), 1.0, 2.6)
				else
					GrassGenerator.flowerCluster(gp, folder, 2 + math.random(0, 3))
				end
			end
		end
		-- water ripples if zone has water
		if wd.water and math.random() < 0.3 then
			GrassGenerator.waterRipple(origin + Vector3.new(0, 2, 0), folder, 6)
		end

		-- out-of-map barrier walls (sides + bottom)
		Terrain.invisibleWall(origin+Vector3.new(half+6,0,0), folder, Vector3.new(4,30,L))
		Terrain.invisibleWall(origin-Vector3.new(half+6,0,0), folder, Vector3.new(4,30,L))
		Terrain.invisibleWall(origin-Vector3.new(0,20,0), folder, Vector3.new(W,4,L))
	end
end

return ZoneBuilder
