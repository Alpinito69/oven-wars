--!strict
--[[
	Oven Wars — authoritative hub gather (node id + proximity + cooldown).
	ProximityPrompt and RequestGather both call TryGather.
]]

local Players = game:GetService("Players")

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local InventoryService = require(script.Parent.InventoryService)

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

	local itemId = node:GetAttribute("GatherItemId")
	if typeof(itemId) ~= "string" then
		return false, "Invalid gather node"
	end

	local item = Catalog.Get(itemId)
	if not item or item.kind ~= "Ingredient" then
		return false, "Invalid ingredient"
	end
	-- Only allow Common/Uncommon hub gathers for MVP
	if item.rarity ~= "Common" and item.rarity ~= "Uncommon" then
		return false, "Too rare to gather here"
	end

	local now = os.clock()
	local last = gatherCooldown[player.UserId] or 0
	if now - last < Constants.GATHER_COOLDOWN_SEC then
		return false, "Gather cooldown"
	end

	if not InventoryService.AddItem(player.UserId, itemId, 1) then
		return false, "Inventory full"
	end

	gatherCooldown[player.UserId] = now
	return true, "Gathered " .. item.name
end

Players.PlayerRemoving:Connect(function(player)
	gatherCooldown[player.UserId] = nil
end)

return GatherService
