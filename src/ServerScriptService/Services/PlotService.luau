--!strict
--[[
	Oven Wars — plot assignment + display visuals.
	World geometry lives in WorldBuilder (Hub / Plots / LightingHelpers).
]]

local Players = game:GetService("Players")

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local Theme = require(game.ReplicatedStorage.Shared.Theme)
local WorldBuilder = require(script.Parent.WorldBuilder)

local PlotService = {}

local plotsFolder: Folder
local plotModels: { Model } = {}
local ownerToPlot: { [number]: number } = {} -- userId → plotIndex
local plotOwner: { [number]: number? } = {} -- plotIndex → userId

local function refreshPlotLabel(index: number)
	local model = plotModels[index]
	if not model then
		return
	end
	local bakeryName = Theme.PlotName(index)
	local floor = model:FindFirstChild("Floor")
	local bb = floor and floor:FindFirstChild("PlotLabel")
	local label = bb and bb:FindFirstChild("Label")
	if label and label:IsA("TextLabel") then
		local uid = plotOwner[index]
		if uid then
			local player = Players:GetPlayerByUserId(uid)
			local name = if player then player.DisplayName else ("User " .. tostring(uid))
			local displayId = model:GetAttribute("DisplayItemId")
			local flex = ""
			if typeof(displayId) == "string" and displayId ~= "" then
				local item = Catalog.Get(displayId)
				flex = " · " .. (if item then item.name else displayId)
			end
			label.Text = name .. "'s " .. bakeryName .. flex
		else
			label.Text = bakeryName .. "  ·  Empty"
		end
	end

	-- Display case item label
	local display = model:FindFirstChild("DisplayCase")
	local dbb = display and display:FindFirstChild("DisplayItemBillboard")
	local dlabel = dbb and dbb:FindFirstChild("ItemLabel")
	if dlabel and dlabel:IsA("TextLabel") then
		local displayId = model:GetAttribute("DisplayItemId")
		if typeof(displayId) == "string" and displayId ~= "" then
			local item = Catalog.Get(displayId)
			dlabel.Text = "🧁 " .. (if item then item.name else displayId)
			if item then
				dlabel.TextColor3 = Catalog.GetRarityColor(item.rarity)
			end
		else
			dlabel.Text = "Empty case"
			dlabel.TextColor3 = Theme.Cream
		end
	end
end

function PlotService.Init()
	WorldBuilder.ClearPrevious()

	WorldBuilder.BuildHub()
	plotsFolder = WorldBuilder.BuildPlots()

	for i = 1, Constants.PLOT_COUNT do
		plotModels[i] = WorldBuilder.BuildPlot(i, plotsFolder)
		plotOwner[i] = nil
	end

	local helpers = WorldBuilder.BuildLightingHelpers()
	WorldBuilder.BuildPathwaysAndLamps(helpers, plotModels)

	print("[OvenWars] PlotService: hub + " .. tostring(Constants.PLOT_COUNT) .. " bakery plots built")
end

function PlotService.GetPlotsFolder(): Folder
	return plotsFolder
end

function PlotService.GetPlotModel(index: number): Model?
	return plotModels[index]
end

function PlotService.Assign(player: Player): number?
	if ownerToPlot[player.UserId] then
		return ownerToPlot[player.UserId]
	end
	for i = 1, Constants.PLOT_COUNT do
		if plotOwner[i] == nil then
			plotOwner[i] = player.UserId
			ownerToPlot[player.UserId] = i
			local model = plotModels[i]
			model:SetAttribute("OwnerUserId", player.UserId)
			refreshPlotLabel(i)

			local spawn = model:FindFirstChild("Spawn")
			if spawn and spawn:IsA("BasePart") and player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and hrp:IsA("BasePart") then
					hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
				end
			end

			Remotes.Get("PlotAssigned"):FireClient(player, i, model:GetPivot())
			return i
		end
	end
	Remotes.Get("Notify"):FireClient(player, "All bakeries full — spectating hub")
	return nil
end

function PlotService.Release(player: Player)
	local index = ownerToPlot[player.UserId]
	if not index then
		return
	end
	ownerToPlot[player.UserId] = nil
	plotOwner[index] = nil
	local model = plotModels[index]
	if model then
		model:SetAttribute("OwnerUserId", 0)
		model:SetAttribute("DisplayItemId", "")
		refreshPlotLabel(index)
	end
end

function PlotService.GetPlotIndex(userId: number): number?
	return ownerToPlot[userId]
end

function PlotService.UpdateDisplayVisual(userId: number, itemId: string?)
	local index = ownerToPlot[userId]
	if not index then
		return
	end
	local model = plotModels[index]
	model:SetAttribute("DisplayItemId", itemId or "")
	refreshPlotLabel(index)
end

function PlotService.TeleportToPlot(player: Player)
	local index = ownerToPlot[player.UserId]
	if not index then
		return
	end
	local spawn = plotModels[index]:FindFirstChild("Spawn")
	local char = player.Character
	if spawn and spawn:IsA("BasePart") and char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	PlotService.Release(player)
end)

return PlotService
