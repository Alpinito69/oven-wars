--!strict
--[[
	Oven Wars — item catalog (ingredients, recipes, baked goods).
	12 items spanning Common → Legendary. Original bakery theme.
]]

local Types = require(script.Parent.Types)

export type CatalogItem = Types.CatalogItem

local Catalog: { [string]: CatalogItem } = {
	-- Ingredients
	Flour = {
		id = "Flour",
		name = "Bag of Flour",
		kind = "Ingredient",
		rarity = "Common",
		sellPrice = 5,
		description = "Everyday baking staple.",
	},
	Butter = {
		id = "Butter",
		name = "Farm Butter",
		kind = "Ingredient",
		rarity = "Common",
		sellPrice = 8,
		description = "Creamy and soft.",
	},
	SugarDust = {
		id = "SugarDust",
		name = "Sugar Dust",
		kind = "Ingredient",
		rarity = "Uncommon",
		sellPrice = 15,
		description = "Sparkles in the light.",
	},
	CocoaNibs = {
		id = "CocoaNibs",
		name = "Cocoa Nibs",
		kind = "Ingredient",
		rarity = "Rare",
		sellPrice = 35,
		description = "Bitter-sweet crunch.",
	},
	MoonHoney = {
		id = "MoonHoney",
		name = "Moon Honey",
		kind = "Ingredient",
		rarity = "Epic",
		sellPrice = 90,
		description = "Harvested under a full moon.",
	},
	StarYeast = {
		id = "StarYeast",
		name = "Star Yeast",
		kind = "Ingredient",
		rarity = "Legendary",
		sellPrice = 200,
		description = "Rises with constellation energy.",
	},

	-- Recipes
	RecipeCrustyRoll = {
		id = "RecipeCrustyRoll",
		name = "Recipe: Crusty Roll",
		kind = "Recipe",
		rarity = "Common",
		bakeTimeSec = 5,
		outputId = "CrustyRoll",
		ingredientIds = { "Flour" },
		description = "A simple bakery classic.",
	},
	RecipeButterCookie = {
		id = "RecipeButterCookie",
		name = "Recipe: Butter Cookie",
		kind = "Recipe",
		rarity = "Uncommon",
		bakeTimeSec = 8,
		outputId = "ButterCookie",
		ingredientIds = { "Flour", "Butter" },
		description = "Crisp edges, soft center.",
	},
	RecipeSugarBun = {
		id = "RecipeSugarBun",
		name = "Recipe: Sugar Bun",
		kind = "Recipe",
		rarity = "Rare",
		bakeTimeSec = 12,
		outputId = "SugarBun",
		ingredientIds = { "Flour", "Butter", "SugarDust" },
		description = "Dusty-sweet and fluffy.",
	},
	RecipeCocoaLoaf = {
		id = "RecipeCocoaLoaf",
		name = "Recipe: Cocoa Loaf",
		kind = "Recipe",
		rarity = "Epic",
		bakeTimeSec = 25,
		outputId = "CocoaLoaf",
		ingredientIds = { "Flour", "CocoaNibs", "Butter" },
		description = "Dense chocolate glory.",
	},
	RecipeMoonCake = {
		id = "RecipeMoonCake",
		name = "Recipe: Moon Cake",
		kind = "Recipe",
		rarity = "Legendary",
		bakeTimeSec = 45,
		outputId = "MoonCake",
		ingredientIds = { "MoonHoney", "StarYeast", "Flour" },
		description = "The flex bake. Defend it.",
	},

	-- Baked goods (sellable / displayable)
	CrustyRoll = {
		id = "CrustyRoll",
		name = "Crusty Roll",
		kind = "Baked",
		rarity = "Common",
		sellPrice = 20,
		description = "Warm and crusty.",
	},
	ButterCookie = {
		id = "ButterCookie",
		name = "Butter Cookie",
		kind = "Baked",
		rarity = "Uncommon",
		sellPrice = 45,
		description = "Golden brown perfection.",
	},
	SugarBun = {
		id = "SugarBun",
		name = "Sugar Bun",
		kind = "Baked",
		rarity = "Rare",
		sellPrice = 80,
		description = "Worth stealing.",
	},
	CocoaLoaf = {
		id = "CocoaLoaf",
		name = "Cocoa Loaf",
		kind = "Baked",
		rarity = "Epic",
		sellPrice = 220,
		description = "Showpiece of the case.",
	},
	MoonCake = {
		id = "MoonCake",
		name = "Moon Cake",
		kind = "Baked",
		rarity = "Legendary",
		sellPrice = 550,
		description = "Legendary bakery flex.",
	},
}

local CatalogModule = {}

function CatalogModule.Get(id: string): CatalogItem?
	return Catalog[id]
end

function CatalogModule.GetAll(): { CatalogItem }
	local list = {}
	for _, item in Catalog do
		table.insert(list, item)
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	return list
end

function CatalogModule.GetByKind(kind: Types.ItemKind): { CatalogItem }
	local list = {}
	for _, item in Catalog do
		if item.kind == kind then
			table.insert(list, item)
		end
	end
	return list
end

function CatalogModule.GetStarterLoadout(): { { itemId: string, qty: number } }
	return {
		{ itemId = "Flour", qty = 5 },
		{ itemId = "Butter", qty = 3 },
		{ itemId = "RecipeCrustyRoll", qty = 1 },
		{ itemId = "RecipeButterCookie", qty = 1 },
	}
end

function CatalogModule.GetRarityColor(rarity: Types.Rarity): Color3
	if rarity == "Common" then
		return Color3.fromRGB(180, 180, 180)
	elseif rarity == "Uncommon" then
		return Color3.fromRGB(80, 200, 120)
	elseif rarity == "Rare" then
		return Color3.fromRGB(70, 140, 255)
	elseif rarity == "Epic" then
		return Color3.fromRGB(180, 80, 255)
	else
		return Color3.fromRGB(255, 180, 40)
	end
end

return CatalogModule
