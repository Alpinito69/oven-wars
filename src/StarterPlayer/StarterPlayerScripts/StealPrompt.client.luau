--!strict
--[[
	Oven Wars — client helpers for steal UX (highlights + optional remote steal).
	Primary steal path is server ProximityPrompt on DisplayCase.
]]

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)

local player = Players.LocalPlayer

local OvenWarsClient
repeat
	task.wait()
	OvenWarsClient = (_G :: any).OvenWarsClient
until OvenWarsClient ~= nil

-- Soft highlight when near rival display cases
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
	h.FillColor = Color3.fromRGB(255, 80, 80)
	h.OutlineColor = Color3.fromRGB(255, 200, 200)
	h.FillTransparency = 0.7
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
		if typeof(displayId) == "string" and displayId ~= "" then
			prompt.ActionText = "Steal"
			prompt.ObjectText = "Rival display"
		else
			prompt.ActionText = "Empty"
			prompt.ObjectText = "Rival display"
		end
	else
		prompt.Enabled = ownerId ~= player.UserId -- hide on own case; own case uses HUD Display
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

-- Fallback: if prompt trigger somehow needs client FireServer (backup path)
ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, triggeringPlayer: Player)
	if triggeringPlayer ~= player then
		return
	end
	if prompt.Name ~= "StealPrompt" then
		return
	end
	-- Server already handles StealPrompt.Triggered; this is a redundant safety net
	-- only if Attribute says client-driven (not used in MVP). Kept for docs/playtest.
	local _ = Constants.STEAL_COOLDOWN_SEC
end)

print("[OvenWars] StealPrompt client ready")
