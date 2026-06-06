local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData       = require(script.Parent.PlayerData)
local CurrencyService  = require(script.Parent.CurrencyService)
local InventoryService = require(script.Parent.InventoryService)
local DuckGenerator    = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DuckGenerator"))
local Remotes          = require(script.Parent.Remotes)
local RemoteGuard      = require(script.Parent.RemoteGuard)

local DebugCommands = {}

local COMMANDS: { [string]: (Player, { string }) -> () } = {
	["!give"] = function(player, args)
		local amount = tonumber(args[2]) or 1000
		local currency = args[3] or "DuckDroppings"
		CurrencyService.Add(player, currency, amount)
	end,
	["!givemega"] = function(player, _)
		CurrencyService.Add(player, "DuckDroppings", 100000)
		CurrencyService.Add(player, "ShimmerSplats", 500)
	end,
	["!duck"] = function(player, args)
		local rarity = args[2]
		local opts = {}
		if rarity then opts.forceRarity = rarity end
		InventoryService.AddDuck(player, DuckGenerator.roll(opts))
	end,
	["!level"] = function(player, args)
		local lvl = tonumber(args[2]) or 10
		local profile = PlayerData.Get(player)
		if profile then profile.highestLevel = lvl end
	end,
	["!reset"] = function(player, _)
		local profile = PlayerData.Get(player)
		if not profile then return end
		for k, v in pairs(profile.wallet) do profile.wallet[k] = 0 end
		profile.ducks = {}
		profile.equipped = {}
		profile.highestLevel = 1
		profile.rebirthLadder = 0
		profile.attackBoost = 1.0
		CurrencyService.PushBalance(player)
		InventoryService.Push(player)
	end,
	["!help"] = function(player, _)
		local lines = {
			"!give <amount> <currency>",
			"!givemega - 100k drops + 500 splats",
			"!duck <rarity>",
			"!level <num>",
			"!reset - wipe progress",
		}
		local Notify = Remotes.event("Notify")
		for _, line in ipairs(lines) do
			task.wait(0.1)
			Notify:FireClient(player, { text = line, color = Color3.fromRGB(255, 200, 90) })
		end
	end,
}

function DebugCommands.Start()
	local chatEvent = Remotes.event("ChatCommand")
	chatEvent.OnServerEvent:Connect(function(player: Player, msg: string)
		if type(msg) ~= "string" or #msg < 1 or msg:sub(1, 1) ~= "!" then return end
		local parts = {}
		for part in msg:gmatch("%S+") do table.insert(parts, part) end
		local cmd = parts[1]
		local handler = COMMANDS[cmd]
		if handler then
			pcall(function() handler(player, parts) end)
		end
	end)
end

return DebugCommands
