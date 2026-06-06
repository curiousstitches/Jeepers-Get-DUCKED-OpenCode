-- Duck Personality: unique name, title, traits, and bond level for every duck
-- Each duck gets a seeded personality from its id — persists across sessions
-- BillboardGui floats above duck, click to pet for bond + happy buff
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local NAMES = {
	"Quackers", "Waddles", "Daffy Jr", "Puddles", "Feathers",
	"Bubbles", "Nibbles", "Squawks", "Pip", "Zuzu",
	"Mocha", "Pepper", "Sunny", "Biscuit", "Pickle",
	"Bumble", "Tofu", "Mochi", "Cocoa", "Gizmo",
	"Pixel", "Mint", "Jelly", "Nugget", "Oreo",
}
local TITLES = {
	"the Brave", "the Fluffy", "of the Pond", "the Quack",
	"the Explorer", "the Mighty", "the Scribbler", "the Dreamer",
	"the Snuggly", "the Dancer", "the Adventurer", "the Bold",
	"the Curious", "the Waddler", "the Sneaky", "the Star",
}
local TRAIT_POOL = {
	"Brave", "Lazy", "Silly", "Grumpy", "Bouncy",
	"Sleepy", "Hungry", "Clever", "Clumsy", "Cheerful",
	"Sneaky", "Gentle", "Bold", "Shy", "Dramatic",
	"Chill", "Hyper", "Mysterious", "Friendly", "Regal",
}
local CATCHPHRASES = {
	"Quackademia!", "Waddle waddle!", "Let's get quackin'!",
	"I believe I can fly!", "Bread please?", "Puddle time!",
	"No thoughts, just vibes.", "You quack me up!",
	"Living the pond life.", "Ducks out!", "Feathers up!",
	"Just here for the snacks.",
}

local cache = {} -- duckId -> personality

local function seededHash(id: string): Random
	local seed = 0
	for i = 1, #id do
		seed = seed + string.byte(id, i) * (i * 7 + 13)
	end
	return Random.new(seed)
end

local function pick(rng: Random, list: { string }): string
	return list[rng:NextInteger(1, #list)]
end

local DuckPersonality = {}

function DuckPersonality.get(duckId: string, rarityColor: Color3): { [string]: any }
	if cache[duckId] then return cache[duckId] end
	local rng = seededHash(duckId)
	local p = {
		id = duckId,
		name = pick(rng, NAMES),
		title = pick(rng, TITLES),
		traits = { pick(rng, TRAIT_POOL), pick(rng, TRAIT_POOL) },
		catchphrase = pick(rng, CATCHPHRASES),
		rarityColor = rarityColor,
		bondLevel = 0,
		lastPetted = 0,
		model = nil,
	}
	cache[duckId] = p
	return p
end

-- Attach personality billboard + ClickDetector to a duck model
function DuckPersonality.attach(model: Model, duckId: string, rarityColor: Color3)
	local p = DuckPersonality.get(duckId, rarityColor)
	p.model = model

	local primary = model.PrimaryPart
	if not primary then return end

	-- BillboardGui
	local bg = Instance.new("BillboardGui")
	bg.Name = "PersonalityTag"
	bg.Size = UDim2.new(0, 160, 0, 80)
	bg.StudsOffset = Vector3.new(0, 3.5, 0)
	bg.AlwaysOnTop = true
	bg.Adornee = primary
	bg.Parent = model

	local back = Instance.new("Frame")
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	back.BackgroundTransparency = 0.35
	back.Parent = bg
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", back).Color = rarityColor; Instance.new("UIStroke", back).Transparency = 0.5

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(1, -8, 0, 26); nameL.Position = UDim2.new(0, 4, 0, 2)
	nameL.BackgroundTransparency = 1; nameL.Font = Enum.Font.GothamBlack; nameL.TextSize = 14
	nameL.TextColor3 = rarityColor; nameL.Text = p.name; nameL.Parent = back

	local titleL = Instance.new("TextLabel")
	titleL.Size = UDim2.new(1, -8, 0, 18); titleL.Position = UDim2.new(0, 4, 0, 26)
	titleL.BackgroundTransparency = 1; titleL.Font = Enum.Font.GothamMedium; titleL.TextSize = 10
	titleL.TextColor3 = Color3.fromRGB(200, 200, 210); titleL.TextXAlignment = Enum.TextXAlignment.Left
	titleL.Text = p.title; titleL.Parent = back

	local traitL = Instance.new("TextLabel")
	traitL.Size = UDim2.new(1, -8, 0, 16); traitL.Position = UDim2.new(0, 4, 0, 44)
	traitL.BackgroundTransparency = 1; traitL.Font = Enum.Font.Gotham; traitL.TextSize = 9
	traitL.TextColor3 = Color3.fromRGB(160, 160, 180); traitL.TextXAlignment = Enum.TextXAlignment.Left
	traitL.Text = p.traits[1] .. " + " .. p.traits[2]; traitL.Parent = back

	local bondL = Instance.new("TextLabel")
	bondL.Size = UDim2.new(1, -8, 0, 14); bondL.Position = UDim2.new(0, 4, 0, 62)
	bondL.BackgroundTransparency = 1; bondL.Font = Enum.Font.Gotham; bondL.TextSize = 8
	bondL.TextColor3 = Color3.fromRGB(255, 100, 150); bondL.TextXAlignment = Enum.TextXAlignment.Left
	bondL.Text = string.rep("❤", math.min(p.bondLevel, 5)) .. string.rep("♡", math.max(5 - p.bondLevel, 0))
	bondL.Parent = back

	-- ClickDetector for petting
	local cd = Instance.new("ClickDetector")
	cd.MaxActivationDistance = 16
	cd.Parent = primary
	cd.MouseClick:Connect(function(plr)
		if plr ~= player then return end
		local now = os.clock()
		if now - p.lastPetted < 2 then return end
		p.lastPetted = now
		p.bondLevel += 1
		bondL.Text = string.rep("❤", math.min(p.bondLevel, 5)) .. string.rep("♡", math.max(5 - p.bondLevel, 0))
		-- bounce animation
		local origPos = primary.CFrame
		TweenService:Create(primary, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = origPos * CFrame.new(0, 1.2, 0) }):Play()
		task.wait(0.15)
		TweenService:Create(primary, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), { CFrame = origPos }):Play()
		-- spawn heart particles
		for _ = 1, 3 do
			local heart = Instance.new("Part"); heart.Shape = Enum.PartType.Ball; heart.Size = Vector3.new(0.3, 0.3, 0.3)
			heart.Anchored = true; heart.CanCollide = false; heart.Material = Enum.Material.Neon
			heart.Color = Color3.fromRGB(255, 60, 120); heart.Parent = Workspace.Terrain
			heart.CFrame = CFrame.new(primary.Position + Vector3.new(math.random(-1, 1), 2, math.random(-1, 1)))
			TweenService:Create(heart, TweenInfo.new(0.6), { Transparency = 1, CFrame = heart.CFrame * CFrame.new(math.random(-3, 3), 3, math.random(-3, 3)) }):Play()
			task.delay(0.6, heart.Destroy, heart)
		end
		-- notify
		local notify = Instance.new("BillboardGui"); notify.Size = UDim2.new(0, 100, 0, 24)
		notify.StudsOffset = Vector3.new(0, 1.5, 0); notify.AlwaysOnTop = true; notify.Adornee = primary
		notify.Parent = primary
		local nl = Instance.new("TextLabel"); nl.Size = UDim2.fromScale(1, 1); nl.BackgroundTransparency = 1
		nl.Font = Enum.Font.GothamBlack; nl.TextSize = 12; nl.TextColor3 = Color3.fromRGB(255, 80, 150)
		nl.Text = p.name .. " loves you! ❤"; nl.Parent = notify
		task.delay(1.2, function()
			TweenService:Create(nl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
			task.wait(0.3); notify:Destroy()
		end)
	end)

	-- hover glow: pulse the billboard stroke on mouse hover
	cd.HoverEnter:Connect(function()
		TweenService:Create(back:FindFirstChildOfClass("UIStroke") or back, TweenInfo.new(0.15), { Transparency = 0 }):Play()
	end)
	cd.HoverLeave:Connect(function()
		local s = back:FindFirstChildOfClass("UIStroke")
		if s then TweenService:Create(s, TweenInfo.new(0.3), { Transparency = 0.5 }):Play() end
	end)
end

-- Get happy buff multiplier based on total bond across all ducks
function DuckPersonality.happyBuff(): number
	local total = 0
	for _, p in pairs(cache) do total += p.bondLevel end
	return 1 + math.min(total * 0.02, 0.5) -- max +50% at 25 total bond
end

return DuckPersonality
