--!strict
--[[
	Oven Wars — server-authoritative cash.
]]

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local DataStoreStub = require(script.Parent.DataStoreStub)

local EconomyService = {}

function EconomyService.GetCash(userId: number): number
	local data = DataStoreStub.Get(userId)
	if not data then
		return 0
	end
	return data.cash
end

function EconomyService.AddCash(userId: number, amount: number): number
	local data = DataStoreStub.Get(userId)
	assert(data, "No player data")
	assert(amount >= 0, "AddCash amount must be >= 0")
	data.cash += amount
	DataStoreStub.MarkDirty(userId)
	local player = game.Players:GetPlayerByUserId(userId)
	if player then
		Remotes.Get("CashUpdated"):FireClient(player, data.cash)
	end
	return data.cash
end

function EconomyService.TrySpend(userId: number, amount: number): boolean
	local data = DataStoreStub.Get(userId)
	if not data or amount < 0 or data.cash < amount then
		return false
	end
	data.cash -= amount
	DataStoreStub.MarkDirty(userId)
	local player = game.Players:GetPlayerByUserId(userId)
	if player then
		Remotes.Get("CashUpdated"):FireClient(player, data.cash)
	end
	return true
end

function EconomyService.Sync(player: Player)
	local data = DataStoreStub.Get(player.UserId)
	if data then
		Remotes.Get("CashUpdated"):FireClient(player, data.cash)
	end
end

return EconomyService
