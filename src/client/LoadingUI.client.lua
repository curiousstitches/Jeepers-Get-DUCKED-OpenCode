local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "LoadingUI"
gui.ResetOnSpawn = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
bg.BorderSizePixel = 0
bg.Parent = gui

local logo = Instance.new("TextLabel")
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.Position = UDim2.fromScale(0.5, 0.4)
logo.Size = UDim2.new(0, 300, 0, 80)
logo.BackgroundTransparency = 1
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 36
logo.TextColor3 = Color3.fromRGB(255, 221, 51)
logo.Text = "JEEPERS\nGET DUCKED"
logo.TextScaled = true
logo.Parent = bg

local subtitle = Instance.new("TextLabel")
subtitle.AnchorPoint = Vector2.new(0.5, 0)
subtitle.Position = UDim2.fromScale(0.5, 0.55)
subtitle.Size = UDim2.new(0, 250, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 18
subtitle.TextColor3 = Color3.fromRGB(150, 160, 180)
subtitle.Text = "Loading..."
subtitle.TextScaled = true
subtitle.Parent = bg

local barBg = Instance.new("Frame")
barBg.AnchorPoint = Vector2.new(0.5, 0.5)
barBg.Position = UDim2.fromScale(0.5, 0.65)
barBg.Size = UDim2.new(0, 200, 0, 6)
barBg.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
barBg.Parent = bg
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(255, 221, 51)
bar.Parent = barBg
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

TweenService:Create(bar, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0.7, 0, 1, 0) }):Play()

local GameReady = Remotes:WaitForChild("GameReady")
GameReady.OnClientEvent:Connect(function()
	TweenService:Create(bar, TweenInfo.new(0.4), { Size = UDim2.new(1, 0, 1, 0) }):Play()
	task.wait(0.5)
	TweenService:Create(bg, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(logo, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
	TweenService:Create(subtitle, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
	TweenService:Create(barBg, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	task.wait(0.6)
	gui:Destroy()
end)

task.wait(8)
if gui and gui.Parent then
	subtitle.Text = "Still loading..."
	TweenService:Create(bar, TweenInfo.new(1), { Size = UDim2.new(0.85, 0, 1, 0) }):Play()
end
