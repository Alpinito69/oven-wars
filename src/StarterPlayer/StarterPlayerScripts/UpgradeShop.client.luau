--!strict
--[[
	Oven Wars — upgrade shop UI stub (opens from own Upgrade Board prompt).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)

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
screen.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(340, 380)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(40, 28, 18)
panel.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Kitchen Upgrades"
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -28, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = panel
local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
	screen.Enabled = false
end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -40)
list.Position = UDim2.fromOffset(0, 36)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.fromOffset(0, 0)
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = list

local function costFor(def, level: number): number
	return math.floor(def.baseCost * (def.costMult ^ level))
end

local function rebuild()
	for _, c in list:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local state = OvenWarsClient.GetState()
	for id, def in Constants.UPGRADE_DEFS do
		local level = (state.upgrades and state.upgrades[id]) or 0
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -6, 0, 72)
		row.BackgroundColor3 = Color3.fromRGB(60, 42, 28)
		row.Parent = list
		local rc = Instance.new("UICorner")
		rc.CornerRadius = UDim.new(0, 8)
		rc.Parent = row

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -12, 0, 22)
		name.Position = UDim2.fromOffset(8, 6)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 15
		name.TextColor3 = Color3.new(1, 1, 1)
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Text = def.displayName .. "  Lv " .. tostring(level) .. "/" .. tostring(Constants.UPGRADE_MAX_LEVEL)
		name.Parent = row

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -100, 0, 18)
		desc.Position = UDim2.fromOffset(8, 28)
		desc.BackgroundTransparency = 1
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 12
		desc.TextColor3 = Color3.fromRGB(200, 190, 170)
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Text = def.description
		desc.Parent = row

		local buy = Instance.new("TextButton")
		buy.Size = UDim2.fromOffset(88, 28)
		buy.Position = UDim2.new(1, -96, 1, -34)
		buy.Font = Enum.Font.GothamBold
		buy.TextSize = 12
		buy.TextColor3 = Color3.new(1, 1, 1)
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 6)
		bc.Parent = buy
		buy.Parent = row

		if level >= Constants.UPGRADE_MAX_LEVEL then
			buy.Text = "MAX"
			buy.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			buy.Active = false
		else
			local price = costFor(def, level)
			buy.Text = "$" .. tostring(price)
			buy.BackgroundColor3 = Color3.fromRGB(200, 140, 50)
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

-- Also allow keyboard U for quick open during playtest
local UserInputService = game:GetService("UserInputService")
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
