local RemoteRegistry = {
	Events = {
		BalanceChanged    = "BalanceChanged",
		RequestBalance    = "RequestBalance",
		InventoryChanged  = "InventoryChanged",
		EquipDuck         = "EquipDuck",
		Trade             = "Trade",
		Notify            = "Notify",
		RevealDuck        = "RevealDuck",
		GetEggs           = "GetEggs",
		UnlockEgg         = "UnlockEgg",
		OpenEgg           = "OpenEgg",
		GetUnlocks        = "GetUnlocks",
		BuyAbility        = "BuyAbility",
		BuyPotion         = "BuyPotion",
		GetGifts          = "GetGifts",
		OpenGift          = "OpenGift",
		SellGift          = "SellGift",
		GameReady         = "GameReady",
		BreakSmashed      = "BreakSmashed",
		StartDanceParty   = "StartDanceParty",
		DancePartySync    = "DancePartySync",
	},
	Functions = {
		UseFacility          = "UseFacility",
		GetSubscriptionStatus = "GetSubscriptionStatus",
	},
}

return RemoteRegistry
