local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)
local Currencies = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Currencies"))
local BigNum     = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BigNum"))
local Remotes    = require(script.Parent.Remotes)

local CurrencyService = {}
local BalanceChanged: RemoteEvent?

function CurrencyService.Start()
	BalanceChanged = Remotes.event("BalanceChanged")
	local req = Remotes.event("RequestBalance")
	req.OnServerEvent:Connect(function(player) CurrencyService.PushBalance(player) end)
end

function CurrencyService.PushBalance(player: Player)
	local profile = PlayerData.Get(player)
	if profile and BalanceChanged then BalanceChanged:FireClient(player, profile.wallet) end
end

function CurrencyService.Get(player: Player, currency: string): number
	local profile = PlayerData.Get(player)
	return profile and (profile.wallet[currency] or 0) or 0
end

function CurrencyService.Add(player: Player, currency: string, amount: number): boolean
	if currency == "Robux" then return false end
	if not Currencies.isValid(currency) then
		warn("[Currency] rejected unknown id: " .. tostring(currency)); return false
	end
	if type(amount) ~= "number" or amount == 0 then return false end
	local profile = PlayerData.Get(player)
	if not profile then return false end
	profile.wallet[currency] = BigNum.safe((profile.wallet[currency] or 0) + amount)
	if amount > 0 then
		profile.lifetimeEarned = (profile.lifetimeEarned or 0) + amount
		if profile.clanId then profile._clanPending = (profile._clanPending or 0) + amount end
	end
	CurrencyService.PushBalance(player)
	return true
end

function CurrencyService.CanAfford(player: Player, currency: string, cost: number): boolean
	return CurrencyService.Get(player, currency) >= cost
end

function CurrencyService.Spend(player: Player, currency: string, cost: number): boolean
	if cost <= 0 then return true end
	if not CurrencyService.CanAfford(player, currency, cost) then return false end
	return CurrencyService.Add(player, currency, -cost)
end

return CurrencyService
