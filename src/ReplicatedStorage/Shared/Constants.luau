--!strict
--[[
	Oven Wars — shared constants (server + client safe).
	No secrets; tune economy here for playtests.
]]

local Constants = {}

Constants.STARTER_CASH = 100
Constants.MAX_INVENTORY_SLOTS_BASE = 8
Constants.STEAL_COOLDOWN_SEC = 8
Constants.STEAL_RANGE_STUDS = 12
Constants.STEAL_RATE_LIMIT_WINDOW_SEC = 2
Constants.STEAL_RATE_LIMIT_MAX = 3

Constants.PLOT_COUNT = 8
Constants.HUB_CENTER = Vector3.new(0, 0, 0)
Constants.PLOT_RADIUS = 60
Constants.PLOT_SIZE = Vector3.new(40, 1, 40)

-- Bake tier base times (seconds); UpgradeService multiplies by oven speed
Constants.BAKE_TIME = {
	Common = 5,
	Uncommon = 8,
	Rare = 12,
	Epic = 25,
	Legendary = 45,
}

Constants.UPGRADE_MAX_LEVEL = 5

Constants.UPGRADE_DEFS = {
	OvenSpeed = {
		id = "OvenSpeed",
		displayName = "Oven Speed",
		description = "Bake faster",
		baseCost = 75,
		costMult = 1.6,
	},
	Storage = {
		id = "Storage",
		displayName = "Shelf Storage",
		description = "More inventory slots",
		baseCost = 50,
		costMult = 1.5,
	},
	Luck = {
		id = "Luck",
		displayName = "Lucky Whisk",
		description = "Better recipe rolls / loot",
		baseCost = 100,
		costMult = 1.7,
	},
	Security = {
		id = "Security",
		displayName = "Iron Lock",
		description = "Chance to block steals",
		baseCost = 120,
		costMult = 1.65,
	},
}

-- Security block chance per level (0 = 0%, 5 ≈ 40%)
Constants.SECURITY_BLOCK_CHANCE_PER_LEVEL = 0.08

-- Oven speed: level 0 = 1.0x time, level 5 ≈ 0.5x time
Constants.OVEN_SPEED_REDUCTION_PER_LEVEL = 0.1

Constants.STORAGE_SLOTS_PER_LEVEL = 2

return Constants
