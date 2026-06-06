local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ChatCommand = Remotes:WaitForChild("ChatCommand")

local gui = Instance.new("ScreenGui")
gui.Name = "ChatUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local box = Instance.new("TextBox")
box.AnchorPoint = Vector2.new(0.5, 1)
box.Position = UDim2.fromScale(0.5, 0.98)
box.Size = UDim2.new(0, 400, 0, 36)
box.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
box.BackgroundTransparency = 0.15
box.Font = Enum.Font.Gotham
box.TextSize = 16
box.TextColor3 = Color3.fromRGB(220, 220, 220)
box.PlaceholderText = "Type !help for commands"
box.Visible = false
box.Parent = gui
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", box).Color = Color3.fromRGB(255, 200, 60)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Semicolon then
		box.Visible = not box.Visible
		if box.Visible then
			box:CaptureFocus()
			box.Text = ""
		end
	end
end)

box.FocusLost:Connect(function(enter)
	if enter and #box.Text > 0 then
		ChatCommand:FireServer(box.Text)
	end
	box.Visible = false
end)
