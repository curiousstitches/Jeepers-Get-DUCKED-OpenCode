local ShopConfig = {}

export type Product = {
	id: number,
	key: string,
	name: string,
	robux: number,
	blurb: string,
	grant: { type: string, currency: string?, amount: number?, mult: number?, seconds: number?, slots: number? },
}

export type GamePass = {
	id: number,
	key: string,
	name: string,
	robux: number,
	blurb: string,
	perk: string,
}

export type ExtraProduct = {
	id: number,
	key: string,
	name: string,
	robux: number,
	blurb: string,
}

export type Subscription = {
	id: string,
	name: string,
	blurb: string,
	perk: string,
}

export type DispenserDef = {
	id: string,
	name: string,
	cost: number,
	currency: string,
	luck: number,
	golden: number,
	reveal: string,
}

ShopConfig.DeveloperProducts = {
	{ id = 0, key = "droppings_small", name = "Pocket o' Droppings", robux = 25,  blurb = "+1,000 Duck Droppings",       grant = { type = "currency", currency = "DuckDroppings", amount = 1000 } },
	{ id = 0, key = "droppings_big",   name = "Dump Truck o' Droppings", robux = 100, blurb = "+6,000 Duck Droppings",  grant = { type = "currency", currency = "DuckDroppings", amount = 6000 } },
	{ id = 0, key = "splats_pack",     name = "Splat Pack",      robux = 80,  blurb = "+80 Shimmer Splats",              grant = { type = "currency", currency = "ShimmerSplats", amount = 80 } },
	{ id = 0, key = "luck_potion",     name = "Lucky Quack Potion", robux = 49, blurb = "2x luck for 15 minutes",        grant = { type = "luck", mult = 2, seconds = 900 } },
	{ id = 0, key = "slot_plus3",      name = "+3 Squad Slots",  robux = 99,  blurb = "Equip 3 more ducks, forever",     grant = { type = "slots", slots = 3 } },
}

ShopConfig.GamePasses = {
	{ id = 0, key = "vip",        name = "Golden Duck VIP",     robux = 499, blurb = "2x Droppings + VIP Lounge", perk = "vip" },
	{ id = 0, key = "slots10",    name = "+10 Squad Slots",     robux = 399, blurb = "Equip 10 more ducks",        perk = "slots10" },
	{ id = 0, key = "season",     name = "Season Premium",      robux = 349, blurb = "Unlock premium pass rewards", perk = "season" },
	{ id = 0, key = "x2forever",  name = "2x Collect Forever",  robux = 499, blurb = "Double currency for life",    perk = "x2forever" },
	{ id = 0, key = "luckx2",     name = "2x Luck Forever",     robux = 449, blurb = "Double luck for life",        perk = "luckx2" },
	{ id = 0, key = "open5",      name = "Open 5 Eggs at Once", robux = 299, blurb = "Hatch 5 per pull",            perk = "open5" },
	{ id = 0, key = "open10",     name = "Open 10 Eggs at Once",robux = 599, blurb = "Hatch 10 per pull",           perk = "open10" },
	{ id = 0, key = "autocollect",name = "Auto-Collect",        robux = 399, blurb = "Ducks auto-farm nearby",      perk = "autocollect" },
	{ id = 0, key = "fasttravel", name = "Fast Travel",         robux = 249, blurb = "Skip back to cleared gates",  perk = "fasttravel" },
}

ShopConfig.ExtraProducts = {
	{ id = 0, key = "egg_gladiator",  name = "Gladiator Jeep",  robux = 199, blurb = "Unlock the Gladiator Jeep" },
	{ id = 0, key = "egg_trackhawk",  name = "Trackhawk Jeep",  robux = 399, blurb = "Unlock the Trackhawk Jeep" },
	{ id = 0, key = "egg_vipgold",    name = "VIP Golden Jeep", robux = 799, blurb = "VIP-only golden Jeep" },
	{ id = 0, key = "ability_dig",    name = "Dig Ability",     robux = 149, blurb = "Unlock Dig" },
	{ id = 0, key = "ability_teleport",name= "Teleport Ability",robux = 249, blurb = "Unlock Teleport" },
	{ id = 0, key = "potion_mega",    name = "MEGA Potion",     robux = 99,  blurb = "x5 earnings, 30 min, stacks" },
}

ShopConfig.Subscription = { id = "EXP-REPLACE", name = "Duck Club", blurb = "+25% Droppings + daily Splats", perk = "duckclub" }

ShopConfig.Dispensers = {
	{ id = "crate",   name = "Duck Crate",       cost = 100, currency = "DuckDroppings", luck = 1.0, golden = 0.01, reveal = "burst"  },
	{ id = "claw",    name = "Claw Machine",     cost = 250, currency = "DuckDroppings", luck = 1.3, golden = 0.02, reveal = "claw"   },
	{ id = "pond",    name = "Lucky Pond",       cost = 500, currency = "DuckDroppings", luck = 1.6, golden = 0.03, reveal = "splash" },
	{ id = "gumball", name = "Gumball Quacker",  cost = 20,  currency = "ShimmerSplats", luck = 2.2, golden = 0.06, reveal = "roll"   },
}

function ShopConfig.getDispenser(id: string): DispenserDef?
	for _, d in ipairs(ShopConfig.Dispensers) do if d.id == id then return d end end
end

return ShopConfig
