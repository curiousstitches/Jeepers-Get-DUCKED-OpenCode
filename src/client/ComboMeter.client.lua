--!strict
-- combo streak gauge: builds as you smash breakables, decays when idle
local Players    = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local ComboMeter = {}

local barFrame: Frame?
local barFill: Frame?
local countLabel: TextLabel?
local glowFrame: Frame?
local comboCount = 0
local decayThread: thread?

local function makeMeter()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ComboMeter"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(0, 260, 0, 36)
	holder.Position = UDim2.new(0.5, -130, 1, -100)
	holder.BackgroundTransparency = 1
	holder.Parent = gui

	countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0, 50, 1, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = Enum.Font.GothamBlack
	countLabel.TextSize = 20
	countLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	countLabel.TextStrokeTransparency = 0.1
	countLabel.TextXAlignment = Enum.TextXAlignment.Right
	countLabel.Text = "0"
	countLabel.Parent = holder

	barFrame = Instance.new("Frame")
	barFrame.Size = UDim2.new(0, 180, 0, 16)
	barFrame.Position = UDim2.new(0, 60, 0, 10)
	barFrame.BackgroundColor3 = Color3.fromRGB(30, 33, 44)
	barFrame.BackgroundTransparency = 0.5
	barFrame.Parent = holder
	Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 8)

	glowFrame = Instance.new("Frame")
	glowFrame.Size = UDim2.fromScale(1, 1)
	glowFrame.BackgroundColor3 = Color3.fromRGB(255, 220, 80)
	glowFrame.BackgroundTransparency = 1
	glowFrame.BorderSizePixel = 0
	glowFrame.Parent = barFrame
	Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 8)

	barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	barFill.BorderSizePixel = 0
	barFill.Parent = barFrame
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 8)
end

function ComboMeter.init()
	makeMeter()
end

function ComboMeter.hit(count: number)
	comboCount = count
	if countLabel then countLabel.Text = tostring(count) end
	if barFill then
		local pct = math.min(count / 20, 1)
		TweenService:Create(barFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(pct, 0, 1, 0) }):Play()
	end
	-- color shifts: white -> gold -> pink -> cyan at high combo
	local hue = math.clamp(0.1 - count * 0.008, 0.0, 0.1)
	local color = Color3.fromHSV(hue, 0.8 + math.min(count * 0.02, 0.2), 1)
	if countLabel then
		TweenService:Create(countLabel, TweenInfo.new(0.1), { TextColor3 = color }):Play()
		countLabel.TextSize = 24 + math.min(count, 12)
	end
	-- glow pulse
	if glowFrame then
		local glowIntensity = math.min(count / 15, 0.8)
		TweenService:Create(glowFrame, TweenInfo.new(0.15), { BackgroundTransparency = 1 - glowIntensity }):Play()
	end
	-- schedule decay
	if decayThread then task.cancel(decayThread) end
	decayThread = task.delay(3, function()
		comboCount = 0
		if countLabel then countLabel.Text = "0"; countLabel.TextSize = 20; countLabel.TextColor3 = Color3.fromRGB(255, 220, 80) end
		if barFill then TweenService:Create(barFill, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 1, 0) }):Play() end
		if glowFrame then TweenService:Create(glowFrame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play() end
	end)
end

return ComboMeter
