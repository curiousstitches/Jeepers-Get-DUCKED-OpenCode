-- DanceService: handles dance party toggle and double-loot buff
local Remotes = require(script.Parent.Remotes)
local DanceService = {
	active = false,
	endTime = 0,
}

local DancePartySync: RemoteEvent?

function DanceService.Start()
	DancePartySync = Remotes.event("DancePartySync")

	local StartDanceParty = Remotes.event("StartDanceParty")
	StartDanceParty.OnServerEvent:Connect(function(plr)
		if DanceService.active then return end
		DanceService.active = true
		DanceService.endTime = os.clock() + 30
		DancePartySync:FireAllClients(true)
		task.delay(30, function()
			if DanceService.active then
				DanceService.active = false
				DancePartySync:FireAllClients(false)
			end
		end)
	end)
end

function DanceService.GetMultiplier(): number
	if DanceService.active and os.clock() < DanceService.endTime then
		return 2
	end
	if DanceService.active then
		DanceService.active = false
	end
	return 1
end

return DanceService
