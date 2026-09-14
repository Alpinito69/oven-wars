--!strict
--[[
	Oven Wars — themed steal UX (highlight + prompt copy).
	Primary steal path is server ProximityPrompt on DisplayCase.
]]

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Theme = require(ReplicatedStorage.Shared.Theme)

local player = Players.LocalPlayer

local OvenWarsClient
repeat
	task.wait()
	OvenWarsClient = (_G :: any).OvenWarsClient
until OvenWarsClient ~= nil

local highlight: Highlight? = nil

local function clearHighlight()
	if highlight then
		highlight:Destroy()
		highlight = nil
	end
end

local function ensureHighlight(adornee: Instance)
	if highlight and highlight.Adornee == adornee then
		return
	end
	clearHighlight()
	local h = Instance.new("Highlight")
	h.Name = "StealHighlight"
	h.Adornee = adornee
	h.FillColor = Color3.fromRGB(255, 90, 90)
	h.OutlineColor = Theme.Blush
	h.FillTransparency = 0.55
	h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = adornee
	highlight = h
end

ProximityPromptService.PromptShown:Connect(function(prompt: ProximityPrompt, _inputType)
	if prompt.Name ~= "StealPrompt" then
		return
	end
	local display = prompt.Parent
	if not display then
		return
	end
	local plot = display.Parent
	if not plot then
		return
	end
	local ownerId = plot:GetAttribute("OwnerUserId")
	if typeof(ownerId) == "number" and ownerId ~= 0 and ownerId ~= player.UserId then
		ensureHighlight(display)
		local displayId = plot:GetAttribute("DisplayItemId")
		local bakery = plot:GetAttribute("BakeryName")
		local bakeryLabel = if typeof(bakery) == "string" then bakery else "Rival bakery"
		if typeof(displayId) == "string" and displayId ~= "" then
			prompt.ActionText = "Steal 🍪"
			prompt.ObjectText = "🍪 " .. bakeryLabel
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.55
		else
			prompt.ActionText = "Empty case"
			prompt.ObjectText = bakeryLabel
		end
	else
		prompt.Enabled = ownerId ~= player.UserId
		if ownerId == player.UserId then
			clearHighlight()
		end
	end
end)

ProximityPromptService.PromptHidden:Connect(function(prompt: ProximityPrompt)
	if prompt.Name == "StealPrompt" then
		clearHighlight()
	end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, triggeringPlayer: Player)
	if triggeringPlayer ~= player then
		return
	end
	if prompt.Name ~= "StealPrompt" then
		return
	end
	local _ = Constants.STEAL_COOLDOWN_SEC
end)

-- Soft toast on steal result
local Remotes = require(ReplicatedStorage.Shared.Remotes)
Remotes.Get("StealResult").OnClientEvent:Connect(function(success: boolean, message: string)
	local toast = player:WaitForChild("PlayerGui"):FindFirstChild("OvenWarsToast")
	if toast and toast:IsA("BindableEvent") then
		local prefix = if success then "🍪 " else "🔒 "
		toast:Fire(prefix .. message)
	end
end)

print("[OvenWars] StealPrompt client ready")
