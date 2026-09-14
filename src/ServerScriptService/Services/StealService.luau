--!strict
--[[
	Oven Wars — proximity steal with cooldown + rate limit.
	Server validates range; security upgrade can block.
	Rate-limit timestamps are recorded only on successful steals.
]]

local Players = game:GetService("Players")

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local InventoryService = require(script.Parent.InventoryService)
local UpgradeService = require(script.Parent.UpgradeService)
local DataStoreStub = require(script.Parent.DataStoreStub)
local VFXService = require(script.Parent.VFXService)
local PlotService = require(script.Parent.PlotService)

local StealService = {}

local lastStealAt: { [number]: number } = {}
local rateWindow: { [number]: { number } } = {}

local function pruneRateWindow(userId: number): { number }
	local now = os.clock()
	local window = rateWindow[userId] or {}
	local kept = {}
	for _, t in window do
		if now - t <= Constants.STEAL_RATE_LIMIT_WINDOW_SEC then
			table.insert(kept, t)
		end
	end
	rateWindow[userId] = kept
	return kept
end

local function isRateLimited(userId: number): boolean
	local kept = pruneRateWindow(userId)
	return #kept >= Constants.STEAL_RATE_LIMIT_MAX
end

local function recordRateLimit(userId: number)
	local kept = pruneRateWindow(userId)
	table.insert(kept, os.clock())
	rateWindow[userId] = kept
end

local function getCharacterRoot(player: Player): BasePart?
	local char = player.Character
	if not char then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

function StealService.TrySteal(thief: Player, targetUserId: number): (boolean, string?)
	if thief.UserId == targetUserId then
		return false, "Can't steal from yourself"
	end

	if isRateLimited(thief.UserId) then
		return false, "Slow down"
	end

	local now = os.clock()
	local last = lastStealAt[thief.UserId] or 0
	if now - last < Constants.STEAL_COOLDOWN_SEC then
		local left = math.ceil(Constants.STEAL_COOLDOWN_SEC - (now - last))
		return false, "Cooldown " .. tostring(left) .. "s"
	end

	local target = Players:GetPlayerByUserId(targetUserId)
	if not target then
		return false, "Target offline"
	end

	local thiefRoot = getCharacterRoot(thief)
	local targetRoot = getCharacterRoot(target)
	-- Prefer plot display part if available
	local displayPart: BasePart? = nil
	local plotsFolder = workspace:FindFirstChild("Plots")
	if plotsFolder then
		for _, plot in plotsFolder:GetChildren() do
			if plot:GetAttribute("OwnerUserId") == targetUserId then
				local d = plot:FindFirstChild("DisplayCase")
				if d and d:IsA("BasePart") then
					displayPart = d
				end
				break
			end
		end
	end

	local checkPos = if displayPart then displayPart.Position elseif targetRoot then targetRoot.Position else nil
	if not thiefRoot or not checkPos then
		return false, "Out of range"
	end

	local dist = (thiefRoot.Position - checkPos).Magnitude
	if dist > Constants.STEAL_RANGE_STUDS then
		return false, "Too far from display case"
	end

	local displayId = InventoryService.GetDisplay(targetUserId)
	if not displayId then
		return false, "Display case empty"
	end

	-- Security block
	local blockChance = UpgradeService.GetSecurityBlockChance(targetUserId)
	if math.random() < blockChance then
		lastStealAt[thief.UserId] = now
		Remotes.Get("StealResult"):FireClient(thief, false, "Blocked by Iron Lock!")
		Remotes.Get("Notify"):FireClient(target, thief.DisplayName .. " tried to steal — blocked!")
		return false, "Blocked by security"
	end

	if not InventoryService.CanAdd(thief.UserId, 1) then
		return false, "Inventory full"
	end

	if not InventoryService.RemoveItem(targetUserId, displayId, 1) then
		return false, "Nothing to steal"
	end

	-- Clear display if gone
	local data = DataStoreStub.Get(targetUserId)
	if data then
		data.displayItemId = nil
	end
	InventoryService.Sync(target)

	InventoryService.AddItem(thief.UserId, displayId, 1)
	lastStealAt[thief.UserId] = now
	recordRateLimit(thief.UserId)

	local itemName = Catalog.Get(displayId) and Catalog.Get(displayId).name or displayId
	Remotes.Get("StealResult"):FireClient(thief, true, "Stole " .. itemName .. "!")
	Remotes.Get("Notify"):FireClient(target, thief.DisplayName .. " stole your " .. itemName .. "!")

	PlotService.UpdateDisplayVisual(targetUserId, nil)
	VFXService.StealPoof(targetUserId)

	return true, nil
end

Players.PlayerRemoving:Connect(function(player)
	lastStealAt[player.UserId] = nil
	rateWindow[player.UserId] = nil
end)

return StealService
