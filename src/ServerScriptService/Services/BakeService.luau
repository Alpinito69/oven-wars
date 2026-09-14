--!strict
--[[
	Oven Wars — server-authoritative bake timers.
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local Types = require(game.ReplicatedStorage.Shared.Types)
local DataStoreStub = require(script.Parent.DataStoreStub)
local InventoryService = require(script.Parent.InventoryService)
local VFXService = require(script.Parent.VFXService)

local BakeService = {}

local jobsByPlayer: { [number]: { Types.BakeJob } } = {}

local function ovenMultiplier(userId: number): number
	local data = DataStoreStub.Get(userId)
	local lvl = if data then data.upgrades.OvenSpeed else 0
	local mult = 1 - (lvl * Constants.OVEN_SPEED_REDUCTION_PER_LEVEL)
	return math.max(0.5, mult)
end

local function syncQueue(player: Player)
	local jobs = jobsByPlayer[player.UserId] or {}
	local payload = {}
	for _, job in jobs do
		if not job.claimed then
			table.insert(payload, {
				jobId = job.jobId,
				recipeId = job.recipeId,
				finishesAt = job.finishesAt,
				startedAt = job.startedAt,
			})
		end
	end
	Remotes.Get("BakeQueueUpdated"):FireClient(player, payload)
end

function BakeService.GetJobs(userId: number): { Types.BakeJob }
	return jobsByPlayer[userId] or {}
end

function BakeService.StartBake(player: Player, recipeId: string): (boolean, string?)
	local item = Catalog.Get(recipeId)
	if not item or item.kind ~= "Recipe" or not item.outputId or not item.ingredientIds then
		return false, "Invalid recipe"
	end

	local userId = player.UserId
	local data = DataStoreStub.Get(userId)
	if not data then
		return false, "No data"
	end

	-- Must own recipe (in inventory or ownedRecipes)
	local owns = false
	for _, rid in data.ownedRecipes do
		if rid == recipeId then
			owns = true
			break
		end
	end
	if not owns and InventoryService.GetCount(userId, recipeId) < 1 then
		return false, "You don't know that recipe"
	end

	if not InventoryService.HasIngredients(userId, item.ingredientIds) then
		return false, "Missing ingredients"
	end

	-- One active unclaimed bake for MVP (simple queue of 1)
	local jobs = jobsByPlayer[userId] or {}
	for _, job in jobs do
		if not job.claimed then
			return false, "Oven busy — claim or wait"
		end
	end

	if not InventoryService.ConsumeIngredients(userId, item.ingredientIds) then
		return false, "Could not consume ingredients"
	end

	local baseTime = item.bakeTimeSec or Constants.BAKE_TIME[item.rarity] or 10
	local duration = baseTime * ovenMultiplier(userId)
	local now = workspace:GetServerTimeNow()
	local job: Types.BakeJob = {
		jobId = HttpService:GenerateGUID(false),
		playerId = userId,
		recipeId = recipeId,
		startedAt = now,
		finishesAt = now + duration,
		claimed = false,
	}

	jobsByPlayer[userId] = jobs
	table.insert(jobs, job)
	syncQueue(player)
	VFXService.StartBake(userId)
	Remotes.Get("Notify"):FireClient(player, "Baking " .. (Catalog.Get(item.outputId) and Catalog.Get(item.outputId).name or item.outputId) .. "...")
	return true, nil
end

function BakeService.ClaimBake(player: Player, jobId: string): (boolean, string?)
	local userId = player.UserId
	local jobs = jobsByPlayer[userId]
	if not jobs then
		return false, "No bake jobs"
	end

	local found: Types.BakeJob? = nil
	for _, job in jobs do
		if job.jobId == jobId then
			found = job
			break
		end
	end
	if not found or found.claimed then
		return false, "Job not found"
	end
	if workspace:GetServerTimeNow() < found.finishesAt then
		return false, "Still baking"
	end

	local recipe = Catalog.Get(found.recipeId)
	if not recipe or not recipe.outputId then
		return false, "Bad recipe"
	end

	if not InventoryService.CanAdd(userId, 1) then
		return false, "Inventory full"
	end

	found.claimed = true
	InventoryService.AddItem(userId, recipe.outputId, 1)
	syncQueue(player)
	VFXService.ClaimSparkle(userId, recipe.outputId)
	Remotes.Get("Notify"):FireClient(player, "Claimed " .. (Catalog.Get(recipe.outputId).name or recipe.outputId) .. "!")
	return true, nil
end

Players.PlayerRemoving:Connect(function(player)
	jobsByPlayer[player.UserId] = nil
end)

function BakeService.Sync(player: Player)
	syncQueue(player)
end

return BakeService
