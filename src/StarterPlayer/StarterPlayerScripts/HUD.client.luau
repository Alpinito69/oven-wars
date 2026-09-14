--!strict
--[[
	Oven Wars — cozy bakery HUD: cash, inventory, bake queue, actions.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalog = require(ReplicatedStorage.Shared.Catalog)
local Theme = require(ReplicatedStorage.Shared.Theme)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local OvenWarsClient
repeat
	task.wait()
	OvenWarsClient = (_G :: any).OvenWarsClient
until OvenWarsClient ~= nil

local toastEvent = Instance.new("BindableEvent")
toastEvent.Name = "OvenWarsToast"
toastEvent.Parent = playerGui

local screen = Instance.new("ScreenGui")
screen.Name = "OvenWarsHUD"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = playerGui

local function corner(parent: Instance, r: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
end

local function stroke(parent: Instance, color: Color3?, thickness: number?)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.UI.Stroke
	s.Thickness = thickness or 1.5
	s.Transparency = 0.35
	s.Parent = parent
end

local function pad(parent: Instance, px: number)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.PaddingLeft = UDim.new(0, px)
	p.PaddingRight = UDim.new(0, px)
	p.Parent = parent
end

-- Cash bar
local cashFrame = Instance.new("Frame")
cashFrame.Name = "CashBar"
cashFrame.Size = UDim2.fromOffset(220, 44)
cashFrame.Position = UDim2.new(0, 16, 0, 16)
cashFrame.BackgroundColor3 = Theme.UI.Panel
cashFrame.Parent = screen
corner(cashFrame, 12)
stroke(cashFrame)
pad(cashFrame, 8)

local cashIcon = Instance.new("TextLabel")
cashIcon.Size = UDim2.fromOffset(28, 28)
cashIcon.Position = UDim2.fromOffset(2, 0)
cashIcon.BackgroundTransparency = 1
cashIcon.Font = Enum.Font.GothamBold
cashIcon.TextSize = 22
cashIcon.Text = "💰"
cashIcon.Parent = cashFrame

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "Cash"
cashLabel.Size = UDim2.new(1, -36, 1, 0)
cashLabel.Position = UDim2.fromOffset(34, 0)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextSize = 22
cashLabel.TextColor3 = Theme.UI.Cash
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Text = "$0"
cashLabel.Parent = cashFrame

-- Toast
local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.Size = UDim2.new(0.48, 0, 0, 40)
toastLabel.Position = UDim2.new(0.26, 0, 0, 68)
toastLabel.BackgroundColor3 = Theme.UI.Toast
toastLabel.BackgroundTransparency = 0.1
toastLabel.TextColor3 = Theme.UI.Text
toastLabel.Font = Enum.Font.Gotham
toastLabel.TextSize = 16
toastLabel.Text = ""
toastLabel.Visible = false
toastLabel.Parent = screen
corner(toastLabel, 10)
stroke(toastLabel, Theme.UI.Accent, 1)

toastEvent.Event:Connect(function(msg: string)
	toastLabel.Text = "  " .. msg
	toastLabel.Visible = true
	task.delay(2.5, function()
		if toastLabel.Text == "  " .. msg then
			toastLabel.Visible = false
		end
	end)
end)

-- Inventory panel
local invFrame = Instance.new("Frame")
invFrame.Name = "Inventory"
invFrame.Size = UDim2.fromOffset(300, 340)
invFrame.Position = UDim2.new(0, 16, 0, 74)
invFrame.BackgroundColor3 = Theme.UI.Panel
invFrame.Parent = screen
corner(invFrame, 14)
stroke(invFrame)
pad(invFrame, 10)

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 26)
invTitle.BackgroundTransparency = 1
invTitle.Font = Enum.Font.GothamBold
invTitle.TextSize = 18
invTitle.TextColor3 = Theme.UI.Text
invTitle.TextXAlignment = Enum.TextXAlignment.Left
invTitle.Text = "🧺  Pantry"
invTitle.Parent = invFrame

local invHint = Instance.new("TextLabel")
invHint.Size = UDim2.new(1, 0, 0, 16)
invHint.Position = UDim2.fromOffset(0, 24)
invHint.BackgroundTransparency = 1
invHint.Font = Enum.Font.Gotham
invHint.TextSize = 11
invHint.TextColor3 = Theme.UI.TextMuted
invHint.TextXAlignment = Enum.TextXAlignment.Left
invHint.Text = "Bake · Sell · Display from your bags"
invHint.Parent = invFrame

local invList = Instance.new("ScrollingFrame")
invList.Name = "List"
invList.Size = UDim2.new(1, 0, 1, -46)
invList.Position = UDim2.fromOffset(0, 46)
invList.BackgroundTransparency = 1
invList.ScrollBarThickness = 5
invList.ScrollBarImageColor3 = Theme.UI.Accent
invList.CanvasSize = UDim2.fromOffset(0, 0)
invList.BorderSizePixel = 0
invList.Parent = invFrame

local invLayout = Instance.new("UIListLayout")
invLayout.Padding = UDim.new(0, 6)
invLayout.Parent = invList

-- Bake queue panel
local bakeFrame = Instance.new("Frame")
bakeFrame.Name = "BakeQueue"
bakeFrame.Size = UDim2.fromOffset(280, 132)
bakeFrame.Position = UDim2.new(1, -296, 0, 16)
bakeFrame.BackgroundColor3 = Theme.UI.Panel
bakeFrame.Parent = screen
corner(bakeFrame, 14)
stroke(bakeFrame)
pad(bakeFrame, 10)

local bakeTitle = Instance.new("TextLabel")
bakeTitle.Size = UDim2.new(1, 0, 0, 24)
bakeTitle.BackgroundTransparency = 1
bakeTitle.Font = Enum.Font.GothamBold
bakeTitle.TextSize = 18
bakeTitle.TextColor3 = Theme.UI.Text
bakeTitle.TextXAlignment = Enum.TextXAlignment.Left
bakeTitle.Text = "🔥  Oven"
bakeTitle.Parent = bakeFrame

local bakeBody = Instance.new("TextLabel")
bakeBody.Name = "Body"
bakeBody.Size = UDim2.new(1, 0, 1, -58)
bakeBody.Position = UDim2.fromOffset(0, 28)
bakeBody.BackgroundTransparency = 1
bakeBody.Font = Enum.Font.Gotham
bakeBody.TextSize = 14
bakeBody.TextColor3 = Theme.UI.TextMuted
bakeBody.TextWrapped = true
bakeBody.TextXAlignment = Enum.TextXAlignment.Left
bakeBody.TextYAlignment = Enum.TextYAlignment.Top
bakeBody.Text = "Oven idle — bake a recipe from your pantry"
bakeBody.Parent = bakeFrame

local claimBtn = Instance.new("TextButton")
claimBtn.Name = "Claim"
claimBtn.Size = UDim2.new(1, 0, 0, 32)
claimBtn.Position = UDim2.new(0, 0, 1, -32)
claimBtn.BackgroundColor3 = Theme.UI.Success
claimBtn.Font = Enum.Font.GothamBold
claimBtn.TextSize = 15
claimBtn.TextColor3 = Color3.new(1, 1, 1)
claimBtn.Text = "✨ Claim Bake"
claimBtn.Visible = false
claimBtn.AutoButtonColor = true
claimBtn.Parent = bakeFrame
corner(claimBtn, 8)
stroke(claimBtn, Color3.fromRGB(120, 200, 130), 1)

local currentClaimJobId: string? = nil
claimBtn.MouseButton1Click:Connect(function()
	if currentClaimJobId then
		OvenWarsClient.RequestClaimBake(currentClaimJobId)
	end
end)

local function rebuildInventory(state)
	for _, c in invList:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end

	for _, entry in state.inventory do
		local item = Catalog.Get(entry.itemId)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -6, 0, 60)
		row.BackgroundColor3 = Theme.UI.PanelAlt
		row.Parent = invList
		corner(row, 8)
		stroke(row, Theme.UI.PanelLight, 1)

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -10, 0, 22)
		name.Position = UDim2.fromOffset(8, 4)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 13
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextColor3 = if item then Catalog.GetRarityColor(item.rarity) else Theme.UI.Text
		local kindGlyph = "•"
		if item then
			if item.kind == "Ingredient" then
				kindGlyph = "🌾"
			elseif item.kind == "Recipe" then
				kindGlyph = "📜"
			elseif item.kind == "Baked" then
				kindGlyph = "🧁"
			end
		end
		name.Text = kindGlyph
			.. " "
			.. (if item then item.name else entry.itemId)
			.. "  ×"
			.. tostring(entry.qty)
		name.Parent = row

		local actions = Instance.new("Frame")
		actions.Size = UDim2.new(1, -10, 0, 28)
		actions.Position = UDim2.fromOffset(6, 28)
		actions.BackgroundTransparency = 1
		actions.Parent = row

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 5)
		layout.Parent = actions

		local function makeBtn(text: string, color: Color3, fn: () -> ())
			local b = Instance.new("TextButton")
			b.Size = UDim2.fromOffset(78, 26)
			b.BackgroundColor3 = color
			b.Font = Enum.Font.GothamBold
			b.TextSize = 12
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Text = text
			b.AutoButtonColor = true
			b.Parent = actions
			corner(b, 6)
			b.MouseButton1Click:Connect(fn)
		end

		if item then
			if item.kind == "Recipe" then
				makeBtn("🔥 Bake", Theme.UI.Accent, function()
					OvenWarsClient.RequestBake(entry.itemId)
				end)
			end
			if item.sellPrice then
				makeBtn("💵 Sell", Theme.UI.Info, function()
					OvenWarsClient.RequestSell(entry.itemId, 1)
				end)
			end
			if item.kind == "Baked" then
				makeBtn("🪟 Show", Theme.UI.Purple, function()
					OvenWarsClient.RequestDisplay(entry.itemId)
				end)
			end
		end

	end

	invList.CanvasSize = UDim2.fromOffset(0, invLayout.AbsoluteContentSize.Y + 8)
end

local function refreshBake(state)
	local queue = state.bakeQueue
	if #queue == 0 then
		bakeBody.Text = "Oven idle — tap Bake on a recipe"
		claimBtn.Visible = false
		currentClaimJobId = nil
		return
	end
	local job = queue[1]
	local recipe = Catalog.Get(job.recipeId)
	local left = math.max(0, job.finishesAt - workspace:GetServerTimeNow())
	bakeBody.Text = "Baking: "
		.. (if recipe then recipe.name else job.recipeId)
		.. (if left > 0 then string.format("\n⏱ Ready in %.1fs", left) else "\n✨ Ready to claim!")
	currentClaimJobId = job.jobId
	claimBtn.Visible = true
	claimBtn.Text = if left > 0 then string.format("⏳ Wait %.0fs", left) else "✨ Claim Bake"
	claimBtn.BackgroundColor3 = if left > 0 then Color3.fromRGB(110, 100, 90) else Theme.UI.Success
end

OvenWarsClient.OnStateChanged(function(state)
	cashLabel.Text = "$" .. tostring(state.cash)
	rebuildInventory(state)
	refreshBake(state)
end)

task.spawn(function()
	while screen.Parent do
		local state = OvenWarsClient.GetState()
		refreshBake(state)
		task.wait(0.5)
	end
end)

print("[OvenWars] HUD ready")
