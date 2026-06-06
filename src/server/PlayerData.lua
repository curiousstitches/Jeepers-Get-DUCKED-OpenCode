local Players          = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService       = game:GetService("RunService")

export type Profile = {
	wallet: { [string]: number },
	ducks: { any },
	equipped: { string },
	rank: number,
	stats: { breakablesSmashed: number, ducksHatched: number, jeepsDucked: number },
	bonusSquadSlots: number,
	purchaseHistory: { [string]: boolean },
	luckBoostUntil: number,
	lastSeen: number,
	rebirths: number,
	unlockedBiomes: { [string]: boolean },
	dex: { [string]: number },
	redeemedCodes: { [string]: boolean },
	daily: { lastDay: number, streak: number },
	quests: { day: number, snapshot: {}, claimed: {} },
	lifetimeEarned: number,
	kindnessStreak: number,
	jeepDuckLog: { [number]: number },
	unlockedEggs: { [string]: boolean },
	abilities: { [string]: boolean },
	potions: { [string]: { power: number, ["until"]: number } },
	gifts: { common: number, rare: number, epic: number, event: number },
	highestLevel: number,
	mode: string,
	hardcoreUnlocked: boolean,
	hardcoreHighest: number,
	dexComplete: {},
	clanId: number?,
	lastSpin: number,
	titles: { string },
	activeTitle: string?,
	achievements: { [string]: boolean },
	cosmeticsOwned: { [string]: boolean },
	equippedTrail: string?,
	equippedAura: string?,
	starterSpun: boolean,
	slotUnlocks: { [string]: boolean },
	rebirthLadder: number,
	attackBoost: number,
	bossTier: number,
	settings: { autoCollect: boolean, music: boolean },
	duckLevels: {},

	_premium: boolean?,
	_droppingsMult: number?,
	_passSlots: number?,
	_vip: boolean?,
	_open5: boolean?,
	_open10: boolean?,
	_autocollect: boolean?,
	_x2forever: boolean?,
	_luckx2: boolean?,
	_fasttravel: boolean?,
	_w1Mult: number?,
	_clanPending: number?,
}

local STORE: DataStore? = nil
local DATASTORE_OK = pcall(function()
	STORE = DataStoreService:GetDataStore("LuckyDuck_PlayerData_v1")
	STORE:GetAsync("__boot_probe__")
end)
if not DATASTORE_OK then
	STORE = nil
	warn("[PlayerData] DataStore unavailable (unpublished place or API off) — running in MEMORY mode. Progress won't save until you Publish + enable API.")
end
local AUTOSAVE = 120

local PlayerData = {}
PlayerData._cache  = {} -- [userId] = profile
PlayerData._loaded = {} -- [userId] = bool

local DEFAULT: Profile = {
	wallet   = { DuckDroppings = 0, ShimmerSplats = 0 },
	ducks    = {},
	equipped = {},
	rank     = 1,
	stats    = { breakablesSmashed = 0, ducksHatched = 0, jeepsDucked = 0 },
	bonusSquadSlots = 0,
	purchaseHistory = {},
	luckBoostUntil  = 0,
	lastSeen        = 0,
	rebirths        = 0,
	unlockedBiomes  = { MuddyTrailhead = true },
	dex             = {},
	redeemedCodes   = {},
	daily           = { lastDay = 0, streak = 0 },
	quests          = { day = 0, snapshot = {}, claimed = {} },
	lifetimeEarned  = 0,
	kindnessStreak  = 0,
	jeepDuckLog     = {},
	unlockedEggs    = { wrangler = true },
	abilities       = {},
	potions         = {},
	gifts           = { common = 0, rare = 0, epic = 0, event = 0 },
	highestLevel    = 1,
	mode            = "normal",
	hardcoreUnlocked = false,
	hardcoreHighest = 1,
	dexComplete     = {},
	clanId          = nil,
	lastSpin        = 0,
	titles          = {},
	activeTitle     = nil,
	achievements    = {},
	cosmeticsOwned  = {},
	equippedTrail   = nil,
	equippedAura    = nil,
	starterSpun     = false,
	slotUnlocks     = {},
	rebirthLadder   = 0,
	attackBoost     = 1.0,
	bossTier        = 0,
	settings        = { autoCollect = true, music = true },
	duckLevels      = {},
}

local function deepCopy(t)
	if type(t) ~= "table" then return t end
	local c = {}
	for k, v in pairs(t) do c[k] = deepCopy(v) end
	return c
end

local function retry(fn, tries: number?)
	tries = tries or 4
	local attempt, ok, res = 0, false, nil
	while attempt < tries do
		ok, res = pcall(fn)
		if ok then return true, res end
		attempt += 1
		task.wait(0.5 * (2 ^ (attempt - 1)))
	end
	return false, res
end

local function migrate(profile: Profile)
	for k, v in pairs(DEFAULT) do
		if profile[k] == nil then profile[k] = deepCopy(v) end
	end
	for cur, amt in pairs(DEFAULT.wallet) do
		if profile.wallet[cur] == nil then profile.wallet[cur] = amt end
	end
	for stat, val in pairs(DEFAULT.stats) do
		if profile.stats[stat] == nil then profile.stats[stat] = val end
	end
	return profile
end

function PlayerData.Load(player: Player): (Profile, boolean)
	if not STORE then
		local profile = deepCopy(DEFAULT)
		PlayerData._cache[player.UserId]  = profile
		PlayerData._loaded[player.UserId] = false
		return profile, false
	end
	local key = "u_" .. player.UserId
	local ok, data = retry(function() return STORE:GetAsync(key) end)
	local profile: Profile = (ok and type(data) == "table") and data or deepCopy(DEFAULT)
	migrate(profile)
	PlayerData._cache[player.UserId]  = profile
	PlayerData._loaded[player.UserId] = ok
	return profile, ok
end

function PlayerData.Get(player: Player): Profile?
	return PlayerData._cache[player.UserId]
end

function PlayerData.Save(player: Player): boolean
	local profile = PlayerData._cache[player.UserId]
	if not profile then return false end
	if not STORE then return false end
	if PlayerData._loaded[player.UserId] == false then
		warn("[PlayerData] skip save for " .. player.Name .. " (cloud load had failed; not overwriting)")
		return false
	end
	profile.lastSeen = os.time()
	local ok = retry(function() STORE:SetAsync("u_" .. player.UserId, profile) end)
	if not ok then warn("[PlayerData] save failed for " .. player.Name) end
	return ok
end

function PlayerData.Release(player: Player)
	PlayerData.Save(player)
	PlayerData._cache[player.UserId]  = nil
	PlayerData._loaded[player.UserId] = nil
end

function PlayerData.ForceSave(player: Player): boolean
	return PlayerData.Save(player)
end

function PlayerData.Start()
	Players.PlayerAdded:Connect(function(p) PlayerData.Load(p) end)
	Players.PlayerRemoving:Connect(function(p) PlayerData.Release(p) end)
	for _, p in ipairs(Players:GetPlayers()) do
		if not PlayerData._cache[p.UserId] then task.spawn(PlayerData.Load, p) end
	end

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE)
			for _, p in ipairs(Players:GetPlayers()) do task.spawn(PlayerData.Save, p) end
		end
	end)

	game:BindToClose(function()
		if RunService:IsStudio() then return end
		for _, p in ipairs(Players:GetPlayers()) do PlayerData.Save(p) end
		task.wait(2)
	end)
end

return PlayerData
