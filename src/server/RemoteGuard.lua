local Players = game:GetService("Players")
local RemoteGuard = {}

type Bucket = { tokens: number, last: number }
local buckets: { [number]: { [string]: Bucket } } = {}

Players.PlayerRemoving:Connect(function(p: Player) buckets[p.UserId] = nil end)

function RemoteGuard.check(player: Player, key: string, rate: number?, burst: number?): boolean
	rate = rate or 5; burst = burst or 5
	local now = os.clock()
	local b = buckets[player.UserId]; if not b then b = {}; buckets[player.UserId] = b end
	local s = b[key]
	if not s then s = { tokens = burst, last = now }; b[key] = s end
	s.tokens = math.min(burst, s.tokens + (now - s.last) * rate)
	s.last = now
	if s.tokens >= 1 then s.tokens -= 1; return true end
	return false
end

function RemoteGuard.event(remote: RemoteEvent, key: string, rate: number?, burst: number?, handler: (player: Player, ...any) -> ())
	remote.OnServerEvent:Connect(function(player: Player, ...)
		if RemoteGuard.check(player, key, rate, burst) then handler(player, ...) end
	end)
end

function RemoteGuard.func<T>(remote: RemoteFunction, key: string, rate: number?, burst: number?, handler: (player: Player, ...any) -> T, onReject: T)
	remote.OnServerInvoke = function(player: Player, ...): T
		if RemoteGuard.check(player, key, rate, burst) then return handler(player, ...) end
		return onReject
	end
end

return RemoteGuard
