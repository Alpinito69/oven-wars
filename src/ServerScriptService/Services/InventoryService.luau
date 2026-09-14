--!strict
--[[
	Oven Wars — server-authoritative inventory + display case.
]]

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local DataStoreStub = require(script.Parent.DataStoreStub)
local UpgradeService = require(script.Parent.UpgradeService)

local InventoryService = {}

local function maxSlots(userId: number): number
	local storageLvl = UpgradeService.GetEffectiveStorageLevel(userId)
	return Constants.MAX_INVENTORY_SLOTS_BASE + storageLvl * Constants.STORAGE_SLOTS_PER_LEVEL
end

local function totalQty(data): number
	local n = 0
	for _, entry in data.inventory do
		n += entry.qty
	end
	return n
end

local function findEntry(data, itemId: string)
	for i, entry in data.inventory do
		if entry.itemId == itemId then
			return entry, i
		end
	end
	return nil, nil
end

function InventoryService.Sync(player: Player)
	local data = DataStoreStub.Get(player.UserId)
	if data then
		Remotes.Get("InventoryUpdated"):FireClient(player, data.inventory, data.displayItemId)
	end
end

function InventoryService.GetCount(userId: number, itemId: string): number
	local data = DataStoreStub.Get(userId)
	if not data then
		return 0
	end
	local entry = findEntry(data, itemId)
	return if entry then entry.qty else 0
end

function InventoryService.CanAdd(userId: number, qty: number): boolean
	local data = DataStoreStub.Get(userId)
	if not data then
		return false
	end
	return totalQty(data) + qty <= maxSlots(userId)
end

function InventoryService.AddItem(userId: number, itemId: string, qty: number): boolean
	if qty <= 0 or not Catalog.Get(itemId) then
		return false
	end
	local data = DataStoreStub.Get(userId)
	if not data or not InventoryService.CanAdd(userId, qty) then
		return false
	end
	local entry = findEntry(data, itemId)
	if entry then
		entry.qty += qty
	else
		table.insert(data.inventory, { itemId = itemId, qty = qty })
	end
	DataStoreStub.MarkDirty(userId)
	local player = game.Players:GetPlayerByUserId(userId)
	if player then
		InventoryService.Sync(player)
	end
	return true
end

function InventoryService.RemoveItem(userId: number, itemId: string, qty: number): boolean
	if qty <= 0 then
		return false
	end
	local data = DataStoreStub.Get(userId)
	if not data then
		return false
	end
	local entry, index = findEntry(data, itemId)
	if not entry or entry.qty < qty then
		return false
	end
	entry.qty -= qty
	if entry.qty <= 0 then
		table.remove(data.inventory, index)
	end
	if data.displayItemId == itemId and InventoryService.GetCount(userId, itemId) <= 0 then
		data.displayItemId = nil
	end
	DataStoreStub.MarkDirty(userId)
	local player = game.Players:GetPlayerByUserId(userId)
	if player then
		InventoryService.Sync(player)
	end
	return true
end

function InventoryService.SetDisplay(userId: number, itemId: string?): boolean
	local data = DataStoreStub.Get(userId)
	if not data then
		return false
	end
	if itemId ~= nil then
		local item = Catalog.Get(itemId)
		if not item or item.kind ~= "Baked" then
			return false
		end
		if InventoryService.GetCount(userId, itemId) < 1 then
			return false
		end
	end
	data.displayItemId = itemId
	DataStoreStub.MarkDirty(userId)
	local player = game.Players:GetPlayerByUserId(userId)
	if player then
		InventoryService.Sync(player)
	end
	-- Visual update handled by PlotService listeners / attribute
	return true
end

function InventoryService.GetDisplay(userId: number): string?
	local data = DataStoreStub.Get(userId)
	return if data then data.displayItemId else nil
end

function InventoryService.HasIngredients(userId: number, ingredientIds: { string }): boolean
	local needed: { [string]: number } = {}
	for _, id in ingredientIds do
		needed[id] = (needed[id] or 0) + 1
	end
	for id, count in needed do
		if InventoryService.GetCount(userId, id) < count then
			return false
		end
	end
	return true
end

function InventoryService.ConsumeIngredients(userId: number, ingredientIds: { string }): boolean
	if not InventoryService.HasIngredients(userId, ingredientIds) then
		return false
	end
	for _, id in ingredientIds do
		if not InventoryService.RemoveItem(userId, id, 1) then
			return false
		end
	end
	return true
end

return InventoryService
