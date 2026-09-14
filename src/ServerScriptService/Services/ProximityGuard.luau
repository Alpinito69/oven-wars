--!strict
--[[
	Oven Wars — proximity helpers for plot interaction remotes.
]]

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local PlotService = require(script.Parent.PlotService)

local ProximityGuard = {}

function ProximityGuard.getRoot(player: Player): BasePart?
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

function ProximityGuard.isNearPart(player: Player, part: BasePart, range: number): boolean
	local root = ProximityGuard.getRoot(player)
	if not root then
		return false
	end
	return (root.Position - part.Position).Magnitude <= range
end

local PART_ERR: { [string]: string } = {
	Oven = "Too far from oven",
	Counter = "Too far from counter",
	UpgradeBoard = "Too far from upgrade board",
	DisplayCase = "Too far from display case",
}

function ProximityGuard.requireNearOwnedPlotPart(
	player: Player,
	partName: string,
	range: number?
): (boolean, string?)
	local maxRange = range or Constants.PLOT_INTERACT_RANGE_STUDS
	local plotIndex = PlotService.GetPlotIndex(player.UserId)
	if not plotIndex then
		return false, "No plot assigned"
	end
	local model = PlotService.GetPlotModel(plotIndex)
	if not model then
		return false, "Plot missing"
	end
	local child = model:FindFirstChild(partName)
	if not child or not child:IsA("BasePart") then
		return false, "Missing " .. partName
	end
	if not ProximityGuard.isNearPart(player, child, maxRange) then
		return false, PART_ERR[partName] or ("Too far from " .. partName)
	end
	return true, nil
end

return ProximityGuard
