--!strict
--[[
	Oven Wars — server bootstrap.
	Wires remotes → services; assigns plots; handles gather nodes.
]]

local Players = game:GetService("Players")

local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local Catalog = require(game.ReplicatedStorage.Shared.Catalog)

local DataStoreStub = require(script.Parent.Services.DataStoreStub)
local EconomyService = require(script.Parent.Services.EconomyService)
local InventoryService = require(script.Parent.Services.InventoryService)
local BakeService = require(script.Parent.Services.BakeService)
local StealService = require(script.Parent.Services.StealService)
local UpgradeService = require(script.Parent.Services.UpgradeService)
local PlotService = require(script.Parent.Services.PlotService)
local LightingService = require(script.Parent.Services.LightingService)
local VFXService = require(script.Parent.Services.VFXService)
local GatherService = require(script.Parent.Services.GatherService)
local ProximityGuard = require(script.Parent.Services.ProximityGuard)

Remotes.Init()
LightingService.Init()
PlotService.Init()

local function notify(player: Player, msg: string)
	Remotes.Get("Notify"):FireClient(player, msg)
end

local function onPlayerReady(player: Player)
	DataStoreStub.Load(player.UserId)
	PlotService.Assign(player)

	EconomyService.Sync(player)
	InventoryService.Sync(player)
	BakeService.Sync(player)
	UpgradeService.Sync(player)

	-- Sync display visual
	local displayId = InventoryService.GetDisplay(player.UserId)
	PlotService.UpdateDisplayVisual(player.UserId, displayId)

	notify(player, "Welcome to Oven Wars! Gather at the market stalls, bake, sell, steal, upgrade.")
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.defer(function()
			PlotService.TeleportToPlot(player)
		end)
	end)
	onPlayerReady(player)
end)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerReady, player)
end

-- Remotes
Remotes.Get("RequestBake").OnServerEvent:Connect(function(player: Player, recipeId: unknown)
	if typeof(recipeId) ~= "string" then
		return
	end
	local nearOk, nearErr = ProximityGuard.requireNearOwnedPlotPart(player, "Oven")
	if not nearOk then
		notify(player, nearErr or "Too far from oven")
		return
	end
	local ok, err = BakeService.StartBake(player, recipeId)
	if not ok then
		notify(player, err or "Bake failed")
	end
end)

Remotes.Get("RequestClaimBake").OnServerEvent:Connect(function(player: Player, jobId: unknown)
	if typeof(jobId) ~= "string" then
		return
	end
	local nearOk, nearErr = ProximityGuard.requireNearOwnedPlotPart(player, "Oven")
	if not nearOk then
		notify(player, nearErr or "Too far from oven")
		return
	end
	local ok, err = BakeService.ClaimBake(player, jobId)
	if not ok then
		notify(player, err or "Claim failed")
	end
end)

Remotes.Get("RequestSell").OnServerEvent:Connect(function(player: Player, itemId: unknown, qtyUnknown: unknown)
	if typeof(itemId) ~= "string" then
		return
	end
	local nearOk, nearErr = ProximityGuard.requireNearOwnedPlotPart(player, "Counter")
	if not nearOk then
		notify(player, nearErr or "Too far from counter")
		return
	end
	local qty = if typeof(qtyUnknown) == "number" then math.floor(qtyUnknown) else 1
	if qty < 1 then
		return
	end
	local item = Catalog.Get(itemId)
	if not item or not item.sellPrice then
		notify(player, "Can't sell that")
		return
	end
	if not InventoryService.RemoveItem(player.UserId, itemId, qty) then
		notify(player, "Not enough items")
		return
	end
	local earned = item.sellPrice * qty
	EconomyService.AddCash(player.UserId, earned)
	VFXService.SellBurst(player.UserId)
	notify(player, "Sold for $" .. tostring(earned))
end)

Remotes.Get("RequestSteal").OnServerEvent:Connect(function(player: Player, targetUserId: unknown)
	if typeof(targetUserId) ~= "number" then
		return
	end
	local ok, err = StealService.TrySteal(player, targetUserId)
	if not ok and err then
		-- StealService already fires StealResult for some paths; still notify
		notify(player, err)
	end
end)

Remotes.Get("RequestUpgrade").OnServerEvent:Connect(function(player: Player, upgradeId: unknown)
	if typeof(upgradeId) ~= "string" then
		return
	end
	local nearOk, nearErr = ProximityGuard.requireNearOwnedPlotPart(player, "UpgradeBoard")
	if not nearOk then
		notify(player, nearErr or "Too far from upgrade board")
		return
	end
	local ok, err = UpgradeService.TryUpgrade(player, upgradeId)
	if not ok then
		notify(player, err or "Upgrade failed")
	end
end)

Remotes.Get("RequestDisplay").OnServerEvent:Connect(function(player: Player, itemId: unknown)
	local nearOk, nearErr = ProximityGuard.requireNearOwnedPlotPart(player, "DisplayCase")
	if not nearOk then
		notify(player, nearErr or "Too far from display case")
		return
	end
	local id: string? = nil
	if typeof(itemId) == "string" and itemId ~= "" then
		id = itemId
	end
	if InventoryService.SetDisplay(player.UserId, id) then
		PlotService.UpdateDisplayVisual(player.UserId, id)
		notify(player, if id then "Displayed item" else "Cleared display")
	else
		notify(player, "Can't display that")
	end
end)

Remotes.Get("RequestGather").OnServerEvent:Connect(function(player: Player, nodeId: unknown)
	if typeof(nodeId) ~= "string" then
		return
	end
	local ok, msg = GatherService.TryGather(player, nodeId)
	if not ok then
		notify(player, msg or "Gather failed")
	elseif msg then
		notify(player, msg)
	end
end)

-- Wire ProximityPrompts on Hub stalls + plot boards / display cases
local function hookPrompt(prompt: ProximityPrompt)
	if prompt:GetAttribute("OvenWarsHooked") then
		return
	end
	prompt:SetAttribute("OvenWarsHooked", true)

	prompt.Triggered:Connect(function(player: Player)
		local parent = prompt.Parent
		if not parent or not parent:IsA("BasePart") then
			return
		end

		if parent:GetAttribute("IsGatherNode") then
			local nodeId = parent:GetAttribute("GatherNodeId")
			if typeof(nodeId) == "string" then
				local ok, msg = GatherService.TryGather(player, nodeId)
				if not ok then
					notify(player, msg or "Gather failed")
				elseif msg then
					notify(player, msg)
				end
			else
				notify(player, "Invalid gather node")
			end
			return
		end

		if parent:GetAttribute("IsDisplayCase") then
			-- Walk up to plot model (DisplayCase is directly under Plot_N)
			local plot = parent.Parent
			if plot then
				local ownerId = plot:GetAttribute("OwnerUserId")
				if typeof(ownerId) == "number" and ownerId ~= 0 and ownerId ~= player.UserId then
					StealService.TrySteal(player, ownerId)
				elseif ownerId == player.UserId then
					notify(player, "Use HUD to set display item")
				end
			end
			return
		end

		if parent:GetAttribute("IsUpgradeBoard") then
			local plot = parent.Parent
			local ownerId = plot and plot:GetAttribute("OwnerUserId")
			if ownerId == player.UserId then
				Remotes.Get("Notify"):FireClient(player, "OPEN_UPGRADE_SHOP")
			else
				notify(player, "Not your upgrade board")
			end
			return
		end
	end)
end

local function scanPrompts(root: Instance)
	for _, d in root:GetDescendants() do
		if d:IsA("ProximityPrompt") then
			hookPrompt(d)
		end
	end
	root.DescendantAdded:Connect(function(d)
		if d:IsA("ProximityPrompt") then
			hookPrompt(d)
		end
	end)
end

local hub = workspace:WaitForChild("Hub")
local plots = workspace:WaitForChild("Plots")
scanPrompts(hub)
scanPrompts(plots)

print("[OvenWars] Server bootstrap complete")
