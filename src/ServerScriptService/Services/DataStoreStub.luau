--!strict
--[[
	Oven Wars — PlayerData persistence stub.
	Uses DataStore when available; falls back to in-memory for Studio offline.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local Types = require(game.ReplicatedStorage.Shared.Types)

local STORE_NAME = "OvenWars_PlayerData_v1"
local store: DataStore? = nil
local okStore, result = pcall(function()
	return DataStoreService:GetDataStore(STORE_NAME)
end)
if okStore then
	store = result
end

local memoryCache: { [number]: Types.PlayerData } = {}

local DataStoreStub = {}

local function defaultData(): Types.PlayerData
	return {
		cash = Constants.STARTER_CASH,
		inventory = Catalog.GetStarterLoadout(),
		upgrades = {
			OvenSpeed = 0,
			Storage = 0,
			Luck = 0,
			Security = 0,
		},
		displayItemId = nil,
		ownedRecipes = { "RecipeCrustyRoll", "RecipeButterCookie" },
	}
end

function DataStoreStub.Load(userId: number): Types.PlayerData
	if memoryCache[userId] then
		return memoryCache[userId]
	end

	if store then
		local key = "u_" .. tostring(userId)
		local ok, data = pcall(function()
			return store:GetAsync(key)
		end)
		if ok and typeof(data) == "table" and data.cash ~= nil then
			memoryCache[userId] = data :: Types.PlayerData
			return memoryCache[userId]
		end
	end

	local fresh = defaultData()
	memoryCache[userId] = fresh
	return fresh
end

function DataStoreStub.Get(userId: number): Types.PlayerData?
	return memoryCache[userId]
end

function DataStoreStub.Save(userId: number)
	local data = memoryCache[userId]
	if not data then
		return
	end
	if not store then
		return
	end
	local key = "u_" .. tostring(userId)
	pcall(function()
		store:SetAsync(key, data)
	end)
end

function DataStoreStub.Unload(userId: number)
	DataStoreStub.Save(userId)
	memoryCache[userId] = nil
end

Players.PlayerRemoving:Connect(function(player)
	DataStoreStub.Unload(player.UserId)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		DataStoreStub.Save(player.UserId)
	end
end)

return DataStoreStub
