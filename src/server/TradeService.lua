local Players          = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local PlayerData       = require(script.Parent.PlayerData)
local InventoryService = require(script.Parent.InventoryService)
local Remotes          = require(script.Parent.Remotes)
local RemoteGuard      = require(script.Parent.RemoteGuard)

local TradeService = {}
local MAX_OFFER = 12

local sessions = {}
local playerSid = {}
local TradeEvent: RemoteEvent?

local function sidFor(u1: number, u2: number): string
	local a, b = math.min(u1, u2), math.max(u1, u2)
	return a .. "-" .. b
end

local function busy(userId: number): boolean return playerSid[userId] ~= nil end

local sessionLock: DataStore?
pcall(function()
	sessionLock = DataStoreService:GetDataStore("LuckyDuck_TradeLocks")
end)

local function acquireLock(sid: string): boolean
	if not sessionLock then return true end
	for i = 1, 5 do
		local ok = pcall(function()
			sessionLock:UpdateAsync(sid, function(old)
				if old == "locked" then return old end
				return "locked"
			end)
		end)
		if ok then return true end
		task.wait(0.2 * i)
	end
	return false
end

local function releaseLock(sid: string)
	if not sessionLock then return end
	pcall(function() sessionLock:SetAsync(sid, "free") end)
end

local function push(session)
	for _, uid in ipairs({ session.a, session.b }) do
		local p = Players:GetPlayerByUserId(uid)
		if p and TradeEvent then
			local other = (uid == session.a) and session.b or session.a
			TradeEvent:FireClient(p, "update", {
				yourOffer = session.offer[uid], theirOffer = session.offer[other],
				youLocked = session.locked[uid] or false, theyLocked = session.locked[other] or false,
				otherName = (Players:GetPlayerByUserId(other) and Players:GetPlayerByUserId(other).Name) or "?",
			})
		end
	end
end

local function endTrade(sid: string, reason: string)
	local s = sessions[sid]; if not s then return end
	for _, uid in ipairs({ s.a, s.b }) do
		playerSid[uid] = nil
		local p = Players:GetPlayerByUserId(uid)
		if p and TradeEvent then TradeEvent:FireClient(p, "closed", { reason = reason or "Trade closed" }) end
	end
	sessions[sid] = nil
	releaseLock(sid)
end

local function owns(profile: PlayerData.Profile, id: string)
	for _, d in ipairs(profile.ducks) do if d.id == id then return d end end
end

local function execute(s)
	local pa = Players:GetPlayerByUserId(s.a)
	local pb = Players:GetPlayerByUserId(s.b)
	if not (pa and pb) then return endTrade(sidFor(s.a, s.b), "A player left") end
	local profA, profB = PlayerData.Get(pa), PlayerData.Get(pb)
	if not (profA and profB) then return endTrade(sidFor(s.a, s.b), "Data not ready") end

	local moveA, moveB = {}, {}
	for _, id in ipairs(s.offer[s.a] or {}) do
		local d = owns(profA, id); if not d then return endTrade(sidFor(s.a, s.b), "Ownership changed") end
		table.insert(moveA, d)
	end
	for _, id in ipairs(s.offer[s.b] or {}) do
		local d = owns(profB, id); if not d then return endTrade(sidFor(s.a, s.b), "Ownership changed") end
		table.insert(moveB, d)
	end

	local setA = {}; for _, d in ipairs(moveA) do setA[d.id] = true end
	local setB = {}; for _, d in ipairs(moveB) do setB[d.id] = true end
	InventoryService.RemoveDucks(pa, setA)
	InventoryService.RemoveDucks(pb, setB)
	for _, d in ipairs(moveA) do InventoryService.AddDuck(pb, d) end
	for _, d in ipairs(moveB) do InventoryService.AddDuck(pa, d) end

	PlayerData.ForceSave(pa); PlayerData.ForceSave(pb)
	endTrade(sidFor(s.a, s.b), "Trade complete!")
end

local function handle(player: Player, action: string, arg)
	local uid = player.UserId
	if action == "invite" then
		local target = Players:GetPlayerByUserId(tonumber(arg) or 0)
		if not target or target == player then return end
		if busy(uid) or busy(target.UserId) then
			TradeEvent:FireClient(player, "closed", { reason = "Someone's already trading" }); return
		end
		local sid = sidFor(uid, target.UserId)
		if not acquireLock(sid) then
			TradeEvent:FireClient(player, "closed", { reason = "Trade system busy, try again" }); return
		end
		sessions[sid] = { a = uid, b = target.UserId, offer = { [uid] = {}, [target.UserId] = {} }, locked = {} }
		playerSid[uid] = sid; playerSid[target.UserId] = sid
		push(sessions[sid])
		return
	end

	local sid = playerSid[uid]; local s = sid and sessions[sid]; if not s then return end

	if action == "offer" then
		if type(arg) ~= "table" then return end
		local profile = PlayerData.Get(player); if not profile then return end
		local clean, seen = {}, {}
		for _, id in ipairs(arg) do
			if type(id) == "string" and not seen[id] and owns(profile, id) then
				seen[id] = true; table.insert(clean, id)
				if #clean >= MAX_OFFER then break end
			end
		end
		s.offer[uid] = clean
		s.locked = {}
		push(s)
	elseif action == "lock" then
		s.locked[uid] = true; push(s)
		if s.locked[s.a] and s.locked[s.b] then execute(s) end
	elseif action == "unlock" then
		s.locked[uid] = nil; push(s)
	elseif action == "cancel" then
		endTrade(sid, "Trade cancelled")
	end
end

function TradeService.Start()
	TradeEvent = Remotes.event("Trade")
	RemoteGuard.event(TradeEvent, "trade", 8, 12, handle)
	Players.PlayerRemoving:Connect(function(player)
		local sid = playerSid[player.UserId]
		if sid then endTrade(sid, "Other player left") end
	end)
end

return TradeService
