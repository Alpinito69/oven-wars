--!strict
--[[
	Oven Wars — hub + bakery plot placeholders; assign on join.
]]

local Players = game:GetService("Players")

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local InventoryService = require(script.Parent.InventoryService)

local PlotService = {}

local plotsFolder: Folder
local plotModels: { Model } = {}
local ownerToPlot: { [number]: number } = {} -- userId → plotIndex
local plotOwner: { [number]: number? } = {} -- plotIndex → userId

local function makePart(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function plotCFrame(index: number): CFrame
	local angle = ((index - 1) / Constants.PLOT_COUNT) * math.pi * 2
	local pos = Vector3.new(
		math.cos(angle) * Constants.PLOT_RADIUS,
		0,
		math.sin(angle) * Constants.PLOT_RADIUS
	)
	return CFrame.new(pos) * CFrame.Angles(0, -angle + math.pi / 2, 0)
end

local function buildHub()
	local hub = Instance.new("Model")
	hub.Name = "Hub"
	hub.Parent = plotsFolder

	makePart("HubFloor", Vector3.new(30, 1, 30), CFrame.new(Constants.HUB_CENTER), Color3.fromRGB(240, 220, 180), hub)

	local sign = makePart("HubSign", Vector3.new(12, 4, 1), CFrame.new(0, 3, -12), Color3.fromRGB(180, 90, 50), hub)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "OVEN WARS HUB"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = billboard

	-- World gather nodes (free common ingredients)
	local nodes = {
		{ name = "FlourSack", itemId = "Flour", offset = Vector3.new(8, 1.5, 4), color = Color3.fromRGB(230, 220, 190) },
		{ name = "ButterCrate", itemId = "Butter", offset = Vector3.new(-8, 1.5, 4), color = Color3.fromRGB(255, 230, 120) },
		{ name = "SugarBarrel", itemId = "SugarDust", offset = Vector3.new(0, 1.5, 10), color = Color3.fromRGB(255, 255, 255) },
	}
	for _, n in nodes do
		local part = makePart(n.name, Vector3.new(3, 3, 3), CFrame.new(Constants.HUB_CENTER + n.offset), n.color, hub)
		part:SetAttribute("GatherItemId", n.itemId)
		part:SetAttribute("IsGatherNode", true)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = n.name
		prompt.ActionText = "Gather"
		prompt.HoldDuration = 0.4
		prompt.MaxActivationDistance = 10
		prompt.Parent = part
	end
end

local function buildPlot(index: number): Model
	local model = Instance.new("Model")
	model.Name = "Plot_" .. tostring(index)
	model:SetAttribute("PlotIndex", index)
	model:SetAttribute("OwnerUserId", 0)
	model:SetAttribute("DisplayItemId", "")
	model.Parent = plotsFolder

	local cf = plotCFrame(index)
	local floor = makePart("Floor", Constants.PLOT_SIZE, cf, Color3.fromRGB(200, 170, 140), model)

	local oven = makePart("Oven", Vector3.new(6, 5, 4), cf * CFrame.new(0, 3, -12), Color3.fromRGB(80, 80, 90), model)
	oven:SetAttribute("IsOven", true)

	local display = makePart("DisplayCase", Vector3.new(8, 4, 2), cf * CFrame.new(10, 2.5, 0), Color3.fromRGB(120, 200, 220), model)
	display:SetAttribute("IsDisplayCase", true)
	local stealPrompt = Instance.new("ProximityPrompt")
	stealPrompt.Name = "StealPrompt"
	stealPrompt.ObjectText = "Display Case"
	stealPrompt.ActionText = "Steal"
	stealPrompt.HoldDuration = 0.6
	stealPrompt.MaxActivationDistance = Constants.STEAL_RANGE_STUDS
	stealPrompt.RequiresLineOfSight = false
	stealPrompt.Parent = display

	local board = makePart("UpgradeBoard", Vector3.new(6, 5, 0.5), cf * CFrame.new(-12, 3, 0), Color3.fromRGB(90, 60, 40), model)
	board:SetAttribute("IsUpgradeBoard", true)
	local upgradePrompt = Instance.new("ProximityPrompt")
	upgradePrompt.Name = "UpgradePrompt"
	upgradePrompt.ObjectText = "Upgrade Board"
	upgradePrompt.ActionText = "Open Shop"
	upgradePrompt.HoldDuration = 0.2
	upgradePrompt.MaxActivationDistance = 12
	upgradePrompt.Parent = board

	local spawn = makePart("Spawn", Vector3.new(4, 1, 4), cf * CFrame.new(0, 1, 8), Color3.fromRGB(100, 180, 100), model)
	spawn.Transparency = 0.4
	spawn.CanCollide = false

	-- Plot label
	local bb = Instance.new("BillboardGui")
	bb.Name = "PlotLabel"
	bb.Size = UDim2.fromOffset(180, 40)
	bb.StudsOffset = Vector3.new(0, 6, 0)
	bb.AlwaysOnTop = true
	bb.Parent = floor
	local text = Instance.new("TextLabel")
	text.Name = "Label"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 0.3
	text.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
	text.Text = "Bakery #" .. tostring(index) .. " (Empty)"
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextScaled = true
	text.Font = Enum.Font.Gotham
	text.Parent = bb

	return model
end

local function refreshPlotLabel(index: number)
	local model = plotModels[index]
	if not model then
		return
	end
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
				flex = " | " .. (if item then item.name else displayId)
			end
			label.Text = name .. "'s Bakery" .. flex
		else
			label.Text = "Bakery #" .. tostring(index) .. " (Empty)"
		end
	end
end

function PlotService.Init()
	local existing = workspace:FindFirstChild("OvenWarsPlots")
	if existing then
		existing:Destroy()
	end
	plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "OvenWarsPlots"
	plotsFolder.Parent = workspace

	buildHub()
	for i = 1, Constants.PLOT_COUNT do
		plotModels[i] = buildPlot(i)
		plotOwner[i] = nil
	end
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
