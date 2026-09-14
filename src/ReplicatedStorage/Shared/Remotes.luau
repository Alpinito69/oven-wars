--!strict
--[[
	Oven Wars — remote event / function registry.
	Server calls Init() once at bootstrap; clients Get() after wait.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "OvenWarsRemotes"

local RemoteNames = {
	-- Client → Server
	"RequestBake",
	"RequestClaimBake",
	"RequestSell",
	"RequestSteal",
	"RequestUpgrade",
	"RequestDisplay", -- put item on display case
	"RequestGather", -- pick up world ingredient node (hub)
	-- Server → Client
	"CashUpdated",
	"InventoryUpdated",
	"BakeQueueUpdated",
	"UpgradeUpdated",
	"PlotAssigned",
	"StealResult",
	"Notify",
}

local Remotes = {}

local function getFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end
	if RunService:IsServer() then
		local created = Instance.new("Folder")
		created.Name = FOLDER_NAME
		created.Parent = ReplicatedStorage
		return created
	end
	folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 10)
	assert(folder and folder:IsA("Folder"), "OvenWarsRemotes folder missing")
	return folder
end

function Remotes.Init()
	assert(RunService:IsServer(), "Remotes.Init is server-only")
	local folder = getFolder()
	for _, name in RemoteNames do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
	end
end

function Remotes.Get(name: string): RemoteEvent
	local folder = getFolder()
	local remote = folder:WaitForChild(name, 10)
	assert(remote and remote:IsA("RemoteEvent"), "Missing remote: " .. name)
	return remote
end

function Remotes.GetFolder(): Folder
	return getFolder()
end

return Remotes
