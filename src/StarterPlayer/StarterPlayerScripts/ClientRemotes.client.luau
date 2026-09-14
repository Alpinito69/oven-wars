--!strict
--[[
	Oven Wars — client remote listeners + shared client state binder.
	Other client scripts read _G.OvenWarsClient or wait on attributes.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

export type ClientState = {
	cash: number,
	inventory: { { itemId: string, qty: number } },
	displayItemId: string?,
	bakeQueue: { any },
	upgrades: { [string]: number },
	plotIndex: number?,
}

local state: ClientState = {
	cash = 0,
	inventory = {},
	displayItemId = nil,
	bakeQueue = {},
	upgrades = {},
	plotIndex = nil,
}

local binders: { (ClientState) -> () } = {}

local function notifyState()
	for _, fn in binders do
		fn(state)
	end
end

local OvenWarsClient = {}

function OvenWarsClient.GetState(): ClientState
	return state
end

function OvenWarsClient.OnStateChanged(fn: (ClientState) -> ())
	table.insert(binders, fn)
	fn(state)
end

function OvenWarsClient.RequestBake(recipeId: string)
	Remotes.Get("RequestBake"):FireServer(recipeId)
end

function OvenWarsClient.RequestClaimBake(jobId: string)
	Remotes.Get("RequestClaimBake"):FireServer(jobId)
end

function OvenWarsClient.RequestSell(itemId: string, qty: number?)
	Remotes.Get("RequestSell"):FireServer(itemId, qty or 1)
end

function OvenWarsClient.RequestSteal(targetUserId: number)
	Remotes.Get("RequestSteal"):FireServer(targetUserId)
end

function OvenWarsClient.RequestUpgrade(upgradeId: string)
	Remotes.Get("RequestUpgrade"):FireServer(upgradeId)
end

function OvenWarsClient.RequestDisplay(itemId: string?)
	Remotes.Get("RequestDisplay"):FireServer(itemId or "")
end

-- Primary gather path is ProximityPrompt on hub stalls; remote expects node id (e.g. "FlourStall").
function OvenWarsClient.RequestGather(nodeId: string)
	Remotes.Get("RequestGather"):FireServer(nodeId)
end

-- Expose for sibling LocalScripts via shared ModuleScript pattern:
-- sibling scripts require this by waiting; we also stash on a Folder attribute bridge.
-- Publish API via _G for sibling LocalScripts (MVP).
(_G :: any).OvenWarsClient = OvenWarsClient

Remotes.Get("CashUpdated").OnClientEvent:Connect(function(cash: number)
	state.cash = cash
	notifyState()
end)

Remotes.Get("InventoryUpdated").OnClientEvent:Connect(function(inv, displayItemId)
	state.inventory = inv or {}
	state.displayItemId = displayItemId
	notifyState()
end)

Remotes.Get("BakeQueueUpdated").OnClientEvent:Connect(function(queue)
	state.bakeQueue = queue or {}
	notifyState()
end)

Remotes.Get("UpgradeUpdated").OnClientEvent:Connect(function(upgrades)
	state.upgrades = upgrades or {}
	notifyState()
end)

Remotes.Get("PlotAssigned").OnClientEvent:Connect(function(plotIndex: number, _cframe: CFrame)
	state.plotIndex = plotIndex
	notifyState()
end)

Remotes.Get("StealResult").OnClientEvent:Connect(function(success: boolean, message: string)
	-- HUD toast also listens to Notify; duplicate soft feedback
	print("[Steal]", success, message)
end)

Remotes.Get("Notify").OnClientEvent:Connect(function(message: string)
	if message == "OPEN_UPGRADE_SHOP" then
		local ev = playerGui:FindFirstChild("OvenWarsOpenUpgradeShop")
		if ev and ev:IsA("BindableEvent") then
			ev:Fire()
		end
		return
	end
	local toast = playerGui:FindFirstChild("OvenWarsToast")
	if toast and toast:IsA("BindableEvent") then
		toast:Fire(message)
	else
		print("[OvenWars]", message)
	end
end)

print("[OvenWars] ClientRemotes ready")
