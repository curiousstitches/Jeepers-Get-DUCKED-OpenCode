-- RainbowTrail: particle emitter on each follow duck that cycles through rainbow hues
-- Intensity/color based on duck rarity
local RunService = game:GetService("RunService")

local RainbowTrail = {
	emitters = {}, -- [model] = ParticleEmitter
	hue = 0,
}

-- attach a rainbow trail to a duck model
function RainbowTrail.attach(model: Model, rarityColor: Color3)
	if not model.PrimaryPart then return end

	-- destroy old emitter if re-attaching
	if RainbowTrail.emitters[model] then
		RainbowTrail.emitters[model]:Destroy()
	end

	local emit = Instance.new("ParticleEmitter")
	emit.Texture = "rbxassetid://243660364"
	emit.Lifetime = NumberRange.new(0.4, 0.8)
	emit.Speed = NumberRange.new(0.2, 0.6)
	emit.Rate = 15
	emit.Rotation = NumberRange.new(0, 360)
	emit.Size = NumberSequence.new(0.3)
	emit.Transparency = NumberSequence.new(0.5, 1)
	emit.VelocityInheritance = 0.2
	emit.Acceleration = Vector3.new(0, -1, 0)
	emit.SpreadAngle = NumberRange.new(0, 30)
	emit.Parent = model.PrimaryPart

	-- start with rarity color, will cycle via update
	local h, s, v = rarityColor:ToHSV()
	emit.Color = ColorSequence.new(Color3.fromHSV(h, s, v))

	RainbowTrail.emitters[model] = emit
end

-- detach and destroy
function RainbowTrail.detach(model: Model)
	local emit = RainbowTrail.emitters[model]
	if emit then
		emit:Destroy()
		RainbowTrail.emitters[model] = nil
	end
end

-- update colors every frame (subtle rainbow cycling)
function RainbowTrail.update(dt: number)
	RainbowTrail.hue = (RainbowTrail.hue + dt * 0.08) % 1
	for model, emit in pairs(RainbowTrail.emitters) do
		if not model.PrimaryPart or not emit.Parent then
			RainbowTrail.detach(model)
		else
			emit.Color = ColorSequence.new(Color3.fromHSV(RainbowTrail.hue, 0.9, 1))
		end
	end
end

-- clean up all
function RainbowTrail.clear()
	for model, emit in pairs(RainbowTrail.emitters) do
		emit:Destroy()
	end
	RainbowTrail.emitters = {}
end

return RainbowTrail
