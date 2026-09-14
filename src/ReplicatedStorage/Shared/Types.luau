--!strict
--[[
	Oven Wars — shared type aliases for Luau strict mode.
]]

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type ItemKind = "Ingredient" | "Recipe" | "Baked"

export type CatalogItem = {
	id: string,
	name: string,
	kind: ItemKind,
	rarity: Rarity,
	sellPrice: number?, -- baked goods / some ingredients
	bakeTimeSec: number?, -- recipes only
	outputId: string?, -- recipe → baked item id
	ingredientIds: { string }?, -- recipes need these
	description: string,
}

export type InventoryEntry = {
	itemId: string,
	qty: number,
}

export type UpgradeId = "OvenSpeed" | "Storage" | "Luck" | "Security"

export type PlayerUpgrades = {
	OvenSpeed: number,
	Storage: number,
	Luck: number,
	Security: number,
}

export type BakeJob = {
	jobId: string,
	playerId: number,
	recipeId: string,
	startedAt: number,
	finishesAt: number,
	claimed: boolean,
}

export type PlayerData = {
	schemaVersion: number?,
	cash: number,
	inventory: { InventoryEntry },
	upgrades: PlayerUpgrades,
	displayItemId: string?, -- what's on the display case
	ownedRecipes: { string }, -- unlocked recipe ids
}

export type PlotInfo = {
	plotIndex: number,
	ownerUserId: number?,
	cframe: CFrame,
}

export type GamePassKey = "FasterOvens" | "ExtraShelves" | "LuckyWhisk" | "IronLock"

return {}
