--!strict
--[[
	Oven Wars — card-style upgrade shop (Upgrade Board or U).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Theme = require(ReplicatedStorage.Shared.Theme)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local OvenWarsClient
repeat
	task.wait()
	OvenWarsClient = (_G :: any).OvenWarsClient
until OvenWarsClient ~= nil

local openEvent = Instance.new("BindableEvent")
openEvent.Name = "OvenWarsOpenUpgradeShop"
openEvent.Parent = playerGui

local screen = Instance.new("ScreenGui")
screen.Name = "OvenWarsUpgradeShop"
screen.ResetOnSpawn = false
screen.Enabled = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = playerGui

-- Dim backdrop
local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.fromRGB(20, 12, 8)
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.Parent = screen

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(380, 420)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Theme.UI.Panel
panel.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Theme.UI.Stroke
stroke.Thickness = 2
stroke.Transparency = 0.25
stroke.Parent = panel

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 14)
pad.PaddingBottom = UDim.new(0, 14)
pad.PaddingLeft = UDim.new(0, 14)
pad.PaddingRight = UDim.new(0, 14)
pad.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -44, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Theme.UI.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🛠️  Kitchen Upgrades"
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -44, 0, 18)
subtitle.Position = UDim2.fromOffset(0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.TextColor3 = Theme.UI.TextMuted
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Spend bakery cash · levels shown on each card"
subtitle.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.BackgroundColor3 = Theme.UI.Danger
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = panel
local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 8)
cc.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
	screen.Enabled = false
end)
dim.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		screen.Enabled = false
	end
end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -56)
list.Position = UDim2.fromOffset(0, 54)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 5
list.ScrollBarImageColor3 = Theme.UI.Accent
list.CanvasSize = UDim2.fromOffset(0, 0)
list.BorderSizePixel = 0
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = list

local UPGRADE_ICONS: { [string]: string } = {
	OvenSpeed = "🔥",
	Storage = "📦",
	Luck = "🍀",
	Security = "🔒",
}

local function costFor(def, level: number): number
	return math.floor(def.baseCost * (def.costMult ^ level))
end

local function levelPips(parent: Frame, level: number, maxLevel: number)
	local row = Instance.new("Frame")
	row.Name = "Pips"
	row.Size = UDim2.new(1, -110, 0, 10)
	row.Position = UDim2.fromOffset(12, 52)
	row.BackgroundTransparency = 1
	row.Parent = parent
	local lay = Instance.new("UIListLayout")
	lay.FillDirection = Enum.FillDirection.Horizontal
	lay.Padding = UDim.new(0, 4)
	lay.Parent = row
	for i = 1, maxLevel do
		local pip = Instance.new("Frame")
		pip.Size = UDim2.fromOffset(16, 8)
		pip.BackgroundColor3 = if i <= level then Theme.UI.Accent else Theme.UI.PanelLight
		pip.Parent = row
		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(1, 0)
		pc.Parent = pip
	end
end

local function rebuild()
	for _, c in list:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local state = OvenWarsClient.GetState()
	-- Stable order
	local order = { "OvenSpeed", "Storage", "Luck", "Security" }
	for _, id in order do
		local def = Constants.UPGRADE_DEFS[id]
		if not def then
			continue
		end
		local level = (state.upgrades and state.upgrades[id]) or 0
		local effective = (state.effectiveUpgrades and state.effectiveUpgrades[id]) or level
		local icon = UPGRADE_ICONS[id] or "⭐"

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -4, 0, 88)
		row.BackgroundColor3 = Theme.UI.PanelAlt
		row.Parent = list
		local rc = Instance.new("UICorner")
		rc.CornerRadius = UDim.new(0, 12)
		rc.Parent = row
		local rs = Instance.new("UIStroke")
		rs.Color = Theme.UI.Stroke
		rs.Thickness = 1
		rs.Transparency = 0.5
		rs.Parent = row

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -110, 0, 24)
		name.Position = UDim2.fromOffset(12, 8)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 16
		name.TextColor3 = Theme.UI.Text
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Text = icon .. "  " .. def.displayName
		name.Parent = row

		local owned = Instance.new("TextLabel")
		owned.Size = UDim2.new(1, -110, 0, 16)
		owned.Position = UDim2.fromOffset(12, 32)
		owned.BackgroundTransparency = 1
		owned.Font = Enum.Font.Gotham
		owned.TextSize = 12
		owned.TextColor3 = Theme.UI.Cash
		owned.TextXAlignment = Enum.TextXAlignment.Left
		local ownedLine = "Owned Lv " .. tostring(level) .. " / " .. tostring(Constants.UPGRADE_MAX_LEVEL)
		if effective > level then
			ownedLine ..= " · eff " .. tostring(effective) .. " (+pass)"
		end
		owned.Text = ownedLine
		owned.Parent = row

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -110, 0, 16)
		desc.Position = UDim2.fromOffset(12, 66)
		desc.BackgroundTransparency = 1
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 12
		desc.TextColor3 = Theme.UI.TextMuted
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Text = def.description
		desc.Parent = row

		levelPips(row, level, Constants.UPGRADE_MAX_LEVEL)

		local buy = Instance.new("TextButton")
		buy.Size = UDim2.fromOffset(96, 36)
		buy.Position = UDim2.new(1, -108, 0.5, -18)
		buy.Font = Enum.Font.GothamBold
		buy.TextSize = 14
		buy.TextColor3 = Color3.new(1, 1, 1)
		buy.AutoButtonColor = true
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 8)
		bc.Parent = buy
		buy.Parent = row

		if level >= Constants.UPGRADE_MAX_LEVEL then
			buy.Text = "MAX ★"
			buy.BackgroundColor3 = Color3.fromRGB(95, 90, 85)
			buy.Active = false
		else
			local price = costFor(def, level)
			buy.Text = "Buy $" .. tostring(price)
			buy.BackgroundColor3 = Theme.UI.Accent
			buy.MouseButton1Click:Connect(function()
				OvenWarsClient.RequestUpgrade(id)
				task.defer(rebuild)
			end)
		end
	end
	list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
end

local function openShop()
	rebuild()
	screen.Enabled = true
end

openEvent.Event:Connect(openShop)

OvenWarsClient.OnStateChanged(function()
	if screen.Enabled then
		rebuild()
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.U then
		if screen.Enabled then
			screen.Enabled = false
		else
			openShop()
		end
	end
end)

print("[OvenWars] UpgradeShop ready (U or Upgrade Board)")
