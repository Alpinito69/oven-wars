--!strict
--[[
	Oven Wars — kitchen upgrades (speed / storage / luck / security).
	Effective levels include gamepass bonuses (+1 per matching pass).
]]

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Types = require(game.ReplicatedStorage.Shared.Types)
local DataStoreStub = require(script.Parent.DataStoreStub)
local EconomyService = require(script.Parent.EconomyService)
local GamePassService = require(script.Parent.GamePassService)

local UpgradeService = {}

local function costFor(def, level: number): number
	return math.floor(def.baseCost * (def.costMult ^ level))
end

function UpgradeService.GetLevel(userId: number, upgradeId: Types.UpgradeId): number
	local data = DataStoreStub.Get(userId)
	if not data then
		return 0
	end
	return data.upgrades[upgradeId] or 0
end

function UpgradeService.GetEffectiveOvenLevel(userId: number): number
	local lvl = UpgradeService.GetLevel(userId, "OvenSpeed")
	if GamePassService.Has(userId, "FasterOvens") then
		lvl += Constants.GAMEPASS_BONUS.FasterOvensOvenLevels
	end
	return lvl
end

function UpgradeService.GetEffectiveStorageLevel(userId: number): number
	local lvl = UpgradeService.GetLevel(userId, "Storage")
	if GamePassService.Has(userId, "ExtraShelves") then
		lvl += Constants.GAMEPASS_BONUS.ExtraShelvesStorageLevels
	end
	return lvl
end

function UpgradeService.GetLuckLevel(userId: number): number
	-- Cash Luck upgrade only (Lucky Whisk applied separately as +1 effective for gather)
	return UpgradeService.GetLevel(userId, "Luck")
end

function UpgradeService.GetEffectiveLuckLevel(userId: number): number
	local lvl = UpgradeService.GetLuckLevel(userId)
	if GamePassService.Has(userId, "LuckyWhisk") then
		lvl += Constants.GAMEPASS_BONUS.LuckyWhiskLuckLevels
	end
	return lvl
end

function UpgradeService.GetEffectiveSecurityLevel(userId: number): number
	local lvl = UpgradeService.GetLevel(userId, "Security")
	if GamePassService.Has(userId, "IronLock") then
		lvl += Constants.GAMEPASS_BONUS.IronLockSecurityLevels
	end
	return lvl
end

function UpgradeService.Sync(player: Player)
	local data = DataStoreStub.Get(player.UserId)
	if data then
		Remotes.Get("UpgradeUpdated"):FireClient(player, data.upgrades)
	end
end

function UpgradeService.TryUpgrade(player: Player, upgradeId: string): (boolean, string?)
	local def = Constants.UPGRADE_DEFS[upgradeId]
	if not def then
		return false, "Unknown upgrade"
	end

	local data = DataStoreStub.Get(player.UserId)
	if not data then
		return false, "No data"
	end

	local typedId = upgradeId :: Types.UpgradeId
	local level = data.upgrades[typedId] or 0
	if level >= Constants.UPGRADE_MAX_LEVEL then
		return false, "Max level"
	end

	local price = costFor(def, level)
	if not EconomyService.TrySpend(player.UserId, price) then
		return false, "Not enough cash"
	end

	data.upgrades[typedId] = level + 1
	DataStoreStub.MarkDirty(player.UserId)
	UpgradeService.Sync(player)
	Remotes.Get("Notify"):FireClient(player, def.displayName .. " → Lv " .. tostring(level + 1))
	return true, nil
end

function UpgradeService.GetSecurityBlockChance(userId: number): number
	local lvl = UpgradeService.GetEffectiveSecurityLevel(userId)
	return math.clamp(lvl * Constants.SECURITY_BLOCK_CHANCE_PER_LEVEL, 0, 0.5)
end

function UpgradeService.GetShopPayload(userId: number)
	local payload = {}
	for id, def in Constants.UPGRADE_DEFS do
		local level = UpgradeService.GetLevel(userId, id :: Types.UpgradeId)
		table.insert(payload, {
			id = id,
			displayName = def.displayName,
			description = def.description,
			level = level,
			maxLevel = Constants.UPGRADE_MAX_LEVEL,
			nextCost = if level < Constants.UPGRADE_MAX_LEVEL then costFor(def, level) else nil,
		})
	end
	return payload
end

return UpgradeService
