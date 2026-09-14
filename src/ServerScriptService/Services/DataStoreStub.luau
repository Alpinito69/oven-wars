--!strict
--[[
	Oven Wars — PlayerData persistence (filename kept as DataStoreStub).
	DataStore when available; in-memory fallback for Studio / no-store.
	Persists: cash, inventory, upgrades, displayItemId, ownedRecipes (+ schemaVersion).
	Save on leave, BindToClose, and ~60s autosave. Retries Get/Set with backoff.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local Types = require(game.ReplicatedStorage.Shared.Types)

local STORE_NAME = "OvenWars_PlayerData_v1"
local MAX_RETRIES = Constants.DATASTORE_MAX_RETRIES
local AUTOSAVE_SEC = Constants.DATASTORE_AUTOSAVE_SEC

local store: DataStore? = nil
local okStore, storeResult = pcall(function()
	return DataStoreService:GetDataStore(STORE_NAME)
end)
if okStore and storeResult ~= nil then
	store = storeResult :: DataStore
else
	warn("[OvenWars] DataStore unavailable — using memory fallback")
end

local memoryCache: { [number]: Types.PlayerData } = {}
local dirty: { [number]: boolean } = {}

local DataStoreStub = {}

local function defaultData(): Types.PlayerData
	return {
		schemaVersion = Constants.DATASTORE_SCHEMA_VERSION,
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

--[[
	Merge missing fields from defaults without wiping good data.
]]
local function migrate(raw: any): Types.PlayerData
	local defaults = defaultData()
	if typeof(raw) ~= "table" then
		return defaults
	end

	local data = raw :: { [string]: any }

	if typeof(data.cash) ~= "number" then
		data.cash = defaults.cash
	end

	if typeof(data.inventory) ~= "table" then
		data.inventory = defaults.inventory
	end

	if typeof(data.upgrades) ~= "table" then
		data.upgrades = defaults.upgrades
	else
		local up = data.upgrades :: { [string]: any }
		for key, defVal in defaults.upgrades :: { [string]: number } do
			if typeof(up[key]) ~= "number" then
				up[key] = defVal
			end
		end
	end

	if data.displayItemId ~= nil and typeof(data.displayItemId) ~= "string" then
		data.displayItemId = nil
	end

	if typeof(data.ownedRecipes) ~= "table" then
		data.ownedRecipes = defaults.ownedRecipes
	end

	data.schemaVersion = Constants.DATASTORE_SCHEMA_VERSION

	return data :: Types.PlayerData
end

local function keyFor(userId: number): string
	return "u_" .. tostring(userId)
end

local function withRetry(label: string, fn: () -> any): (boolean, any)
	local delaySec = 0.5
	local lastErr: any = nil
	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		warn(string.format("[OvenWars] %s failed attempt %d/%d: %s", label, attempt, MAX_RETRIES, tostring(result)))
		if attempt < MAX_RETRIES then
			task.wait(delaySec)
			delaySec *= 2
		end
	end
	return false, lastErr
end

function DataStoreStub.MarkDirty(userId: number)
	if memoryCache[userId] then
		dirty[userId] = true
	end
end

function DataStoreStub.Load(userId: number): Types.PlayerData
	if memoryCache[userId] then
		return memoryCache[userId]
	end

	if store then
		local ok, data = withRetry("GetAsync", function()
			return (store :: DataStore):GetAsync(keyFor(userId))
		end)
		if ok and typeof(data) == "table" then
			local merged = migrate(data)
			memoryCache[userId] = merged
			dirty[userId] = false
			return merged
		end
	end

	local fresh = defaultData()
	memoryCache[userId] = fresh
	dirty[userId] = true -- new player should persist on first save window
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
	data.schemaVersion = Constants.DATASTORE_SCHEMA_VERSION
	if not store then
		dirty[userId] = false
		return
	end
	local ok = withRetry("SetAsync", function()
		(store :: DataStore):SetAsync(keyFor(userId), data)
		return true
	end)
	if ok then
		dirty[userId] = false
	end
end

function DataStoreStub.Unload(userId: number)
	DataStoreStub.Save(userId)
	memoryCache[userId] = nil
	dirty[userId] = nil
end

Players.PlayerRemoving:Connect(function(player)
	DataStoreStub.Unload(player.UserId)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		DataStoreStub.Save(player.UserId)
	end
	-- brief yield so SetAsync can flush in live servers
	if store then
		task.wait(2)
	end
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_SEC)
		for _, player in Players:GetPlayers() do
			local userId = player.UserId
			if memoryCache[userId] then
				DataStoreStub.Save(userId)
			end
		end
	end
end)

return DataStoreStub
