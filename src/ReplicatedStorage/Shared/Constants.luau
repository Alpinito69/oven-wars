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

Constants.GATHER_RANGE_STUDS = 12
Constants.PLOT_INTERACT_RANGE_STUDS = 28 -- spawn pad ~25 studs from oven; leave HRP slack
Constants.GATHER_COOLDOWN_SEC = 2

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
		baseCost = 50,
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
		description = "Better hub gather Uncommon weight",
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

-- Hub gather luck weights (LiveOps): Uncommon starts 0.20, +0.05/Luck, cap 0.45
Constants.HUB_GATHER_BASE_UNCOMMON_WEIGHT = 0.20
Constants.HUB_GATHER_UNCOMMON_PER_LUCK_LEVEL = 0.05
Constants.HUB_GATHER_UNCOMMON_WEIGHT_CAP = 0.45
Constants.HUB_GATHER_UNCOMMON_POOL = { "SugarDust" }

-- Marketplace gamepass IDs — placeholders (0); replace before publish
Constants.GAMEPASS = {
	FasterOvens = 0, -- placeholder Marketplace ID
	ExtraShelves = 0,
	LuckyWhisk = 0,
	IronLock = 0,
}

-- Each owned pass = +1 effective level on matching axis (stacks with cash upgrade)
Constants.GAMEPASS_BONUS = {
	FasterOvensOvenLevels = 1,
	ExtraShelvesStorageLevels = 1,
	LuckyWhiskLuckLevels = 1,
	IronLockSecurityLevels = 1,
}

-- Studio QA: when true AND RunService:IsStudio(), GamePassService.Has returns true for all keys
Constants.GAMEPASS_STUDIO_FORCE_ALL = false

Constants.DATASTORE_SCHEMA_VERSION = 1
Constants.DATASTORE_AUTOSAVE_SEC = 60
Constants.DATASTORE_MAX_RETRIES = 3

return Constants
