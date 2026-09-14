--!strict
--[[
	Oven Wars — MarketplaceService gamepass ownership cache.
	Placeholder IDs (0) are treated as not owned. Studio force-all for QA.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Types = require(game.ReplicatedStorage.Shared.Types)

local GamePassService = {}

local PASS_KEYS: { Types.GamePassKey } = { "FasterOvens", "ExtraShelves", "LuckyWhisk", "IronLock" }

local ownership: { [number]: { [Types.GamePassKey]: boolean } } = {}

local function emptyOwned(): { [Types.GamePassKey]: boolean }
	return {
		FasterOvens = false,
		ExtraShelves = false,
		LuckyWhisk = false,
		IronLock = false,
	}
end

local function studioForceAll(): boolean
	return Constants.GAMEPASS_STUDIO_FORCE_ALL == true and RunService:IsStudio()
end

local function checkOwns(userId: number, passId: number): boolean
	if passId <= 0 then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
	end)
	if ok and owns == true then
		return true
	end
	return false
end

function GamePassService.RefreshOnJoin(player: Player)
	local userId = player.UserId
	local owned = emptyOwned()
	if studioForceAll() then
		for _, key in PASS_KEYS do
			owned[key] = true
		end
	else
		for _, key in PASS_KEYS do
			local passId = Constants.GAMEPASS[key]
			if typeof(passId) == "number" and passId > 0 then
				owned[key] = checkOwns(userId, passId)
			else
				owned[key] = false
			end
		end
	end
	ownership[userId] = owned
end

function GamePassService.RefreshPass(userId: number, passKey: Types.GamePassKey)
	local owned = ownership[userId]
	if not owned then
		owned = emptyOwned()
		ownership[userId] = owned
	end
	if studioForceAll() then
		owned[passKey] = true
		return
	end
	local passId = Constants.GAMEPASS[passKey]
	if typeof(passId) ~= "number" or passId <= 0 then
		owned[passKey] = false
		return
	end
	owned[passKey] = checkOwns(userId, passId)
end

function GamePassService.Has(userId: number, passKey: Types.GamePassKey): boolean
	if studioForceAll() then
		return true
	end
	local owned = ownership[userId]
	if not owned then
		return false
	end
	return owned[passKey] == true
end

local function keyForPassId(passId: number): Types.GamePassKey?
	for _, key in PASS_KEYS do
		if Constants.GAMEPASS[key] == passId and passId > 0 then
			return key
		end
	end
	return nil
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, passId: number, wasPurchased: boolean)
	if not wasPurchased then
		return
	end
	local key = keyForPassId(passId)
	if key then
		GamePassService.RefreshPass(player.UserId, key)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ownership[player.UserId] = nil
end)

return GamePassService
