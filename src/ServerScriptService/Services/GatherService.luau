--!strict
--[[
	Oven Wars — authoritative hub gather (node id + proximity + cooldown).
	Luck + Lucky Whisk raise Uncommon weight on Common stalls (LiveOps formula).
	ProximityPrompt and RequestGather both call TryGather.
]]

local Players = game:GetService("Players")

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local InventoryService = require(script.Parent.InventoryService)
local UpgradeService = require(script.Parent.UpgradeService)

local GatherService = {}

local gatherCooldown: { [number]: number } = {}

local function getRoot(player: Player): BasePart?
	local char = player.Character
	if not char then
		return nil
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function findGatherNode(nodeId: string): BasePart?
	local hub = workspace:FindFirstChild("Hub")
	if not hub then
		return nil
	end
	for _, d in hub:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("IsGatherNode") == true then
			if d:GetAttribute("GatherNodeId") == nodeId then
				return d
			end
		end
	end
	return nil
end

local function uncommonWeight(userId: number): number
	local effectiveLuck = UpgradeService.GetEffectiveLuckLevel(userId)
	local weight = Constants.HUB_GATHER_BASE_UNCOMMON_WEIGHT
		+ effectiveLuck * Constants.HUB_GATHER_UNCOMMON_PER_LUCK_LEVEL
	return math.clamp(weight, 0, Constants.HUB_GATHER_UNCOMMON_WEIGHT_CAP)
end

local function pickFromPool(pool: { string }): string?
	if #pool == 0 then
		return nil
	end
	return pool[math.random(1, #pool)]
end

function GatherService.TryGather(player: Player, nodeId: string): (boolean, string?)
	if typeof(nodeId) ~= "string" or nodeId == "" then
		return false, "Invalid gather node"
	end

	local node = findGatherNode(nodeId)
	if not node then
		return false, "Unknown gather node"
	end

	local root = getRoot(player)
	if not root then
		return false, "No character"
	end

	local dist = (root.Position - node.Position).Magnitude
	if dist > Constants.GATHER_RANGE_STUDS then
		return false, "Too far from stall"
	end

	local nodeItemId = node:GetAttribute("GatherItemId")
	if typeof(nodeItemId) ~= "string" then
		return false, "Invalid gather node"
	end

	local nodeItem = Catalog.Get(nodeItemId)
	if not nodeItem or nodeItem.kind ~= "Ingredient" then
		return false, "Invalid ingredient"
	end
	-- Only allow Common/Uncommon hub gathers for MVP
	if nodeItem.rarity ~= "Common" and nodeItem.rarity ~= "Uncommon" then
		return false, "Too rare to gather here"
	end

	local now = os.clock()
	local last = gatherCooldown[player.UserId] or 0
	if now - last < Constants.GATHER_COOLDOWN_SEC then
		return false, "Gather cooldown"
	end

	local grantId = nodeItemId
	-- Common nodes: roll Uncommon weight from luck; Uncommon/Rare+ nodes grant themselves
	if nodeItem.rarity == "Common" then
		local chance = uncommonWeight(player.UserId)
		-- chance is Uncommon weight; Common is implicitly 1 - chance (re-normalized)
		if math.random() < chance then
			local pooled = pickFromPool(Constants.HUB_GATHER_UNCOMMON_POOL)
			if pooled then
				grantId = pooled
			end
		end
	end

	local grantItem = Catalog.Get(grantId)
	if not grantItem or grantItem.kind ~= "Ingredient" then
		return false, "Invalid ingredient"
	end
	if grantItem.rarity ~= "Common" and grantItem.rarity ~= "Uncommon" then
		return false, "Too rare to gather here"
	end

	if not InventoryService.AddItem(player.UserId, grantId, 1) then
		return false, "Inventory full"
	end

	gatherCooldown[player.UserId] = now
	return true, "Gathered " .. grantItem.name
end

Players.PlayerRemoving:Connect(function(player)
	gatherCooldown[player.UserId] = nil
end)

return GatherService
