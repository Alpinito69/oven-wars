--!strict
--[[
	Oven Wars — MVP HUD: cash, inventory, bake queue, sell/bake/display actions.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalog = require(ReplicatedStorage.Shared.Catalog)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for client API
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
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
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
cashFrame.Size = UDim2.fromOffset(200, 40)
cashFrame.Position = UDim2.new(0, 16, 0, 16)
cashFrame.BackgroundColor3 = Color3.fromRGB(40, 28, 18)
cashFrame.Parent = screen
corner(cashFrame)
pad(cashFrame, 6)

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "Cash"
cashLabel.Size = UDim2.fromScale(1, 1)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextSize = 20
cashLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Text = "$0"
cashLabel.Parent = cashFrame

-- Toast
local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.Size = UDim2.new(0.5, 0, 0, 36)
toastLabel.Position = UDim2.new(0.25, 0, 0, 64)
toastLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toastLabel.BackgroundTransparency = 0.2
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.Font = Enum.Font.Gotham
toastLabel.TextSize = 16
toastLabel.Text = ""
toastLabel.Visible = false
toastLabel.Parent = screen
corner(toastLabel)

toastEvent.Event:Connect(function(msg: string)
	toastLabel.Text = msg
	toastLabel.Visible = true
	task.delay(2.5, function()
		if toastLabel.Text == msg then
			toastLabel.Visible = false
		end
	end)
end)

-- Inventory panel
local invFrame = Instance.new("Frame")
invFrame.Name = "Inventory"
invFrame.Size = UDim2.fromOffset(280, 320)
invFrame.Position = UDim2.new(0, 16, 0, 70)
invFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 18)
invFrame.Parent = screen
corner(invFrame)
pad(invFrame, 8)

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 24)
invTitle.BackgroundTransparency = 1
invTitle.Font = Enum.Font.GothamBold
invTitle.TextSize = 16
invTitle.TextColor3 = Color3.new(1, 1, 1)
invTitle.TextXAlignment = Enum.TextXAlignment.Left
invTitle.Text = "Inventory"
invTitle.Parent = invFrame

local invList = Instance.new("ScrollingFrame")
invList.Name = "List"
invList.Size = UDim2.new(1, 0, 1, -30)
invList.Position = UDim2.fromOffset(0, 28)
invList.BackgroundTransparency = 1
invList.ScrollBarThickness = 4
invList.CanvasSize = UDim2.fromOffset(0, 0)
invList.Parent = invFrame

local invLayout = Instance.new("UIListLayout")
invLayout.Padding = UDim.new(0, 4)
invLayout.Parent = invList

-- Bake queue panel
local bakeFrame = Instance.new("Frame")
bakeFrame.Name = "BakeQueue"
bakeFrame.Size = UDim2.fromOffset(260, 120)
bakeFrame.Position = UDim2.new(1, -276, 0, 16)
bakeFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 18)
bakeFrame.Parent = screen
corner(bakeFrame)
pad(bakeFrame, 8)

local bakeTitle = Instance.new("TextLabel")
bakeTitle.Size = UDim2.new(1, 0, 0, 22)
bakeTitle.BackgroundTransparency = 1
bakeTitle.Font = Enum.Font.GothamBold
bakeTitle.TextSize = 16
bakeTitle.TextColor3 = Color3.new(1, 1, 1)
bakeTitle.TextXAlignment = Enum.TextXAlignment.Left
bakeTitle.Text = "Oven"
bakeTitle.Parent = bakeFrame

local bakeBody = Instance.new("TextLabel")
bakeBody.Name = "Body"
bakeBody.Size = UDim2.new(1, 0, 1, -50)
bakeBody.Position = UDim2.fromOffset(0, 26)
bakeBody.BackgroundTransparency = 1
bakeBody.Font = Enum.Font.Gotham
bakeBody.TextSize = 14
bakeBody.TextColor3 = Color3.fromRGB(230, 220, 200)
bakeBody.TextWrapped = true
bakeBody.TextXAlignment = Enum.TextXAlignment.Left
bakeBody.TextYAlignment = Enum.TextYAlignment.Top
bakeBody.Text = "Oven idle — bake a recipe from inventory"
bakeBody.Parent = bakeFrame

local claimBtn = Instance.new("TextButton")
claimBtn.Name = "Claim"
claimBtn.Size = UDim2.new(1, 0, 0, 28)
claimBtn.Position = UDim2.new(0, 0, 1, -28)
claimBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 90)
claimBtn.Font = Enum.Font.GothamBold
claimBtn.TextSize = 14
claimBtn.TextColor3 = Color3.new(1, 1, 1)
claimBtn.Text = "Claim Bake"
claimBtn.Visible = false
claimBtn.Parent = bakeFrame
corner(claimBtn, 6)

local currentClaimJobId: string? = nil
claimBtn.MouseButton1Click:Connect(function()
	if currentClaimJobId then
		OvenWarsClient.RequestClaimBake(currentClaimJobId)
	end
end)

local function clearChildren(frame: Frame | ScrollingFrame)
	for _, c in frame:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
end

local function rebuildInventory(state)
	for _, c in invList:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end

	for _, entry in state.inventory do
		local item = Catalog.Get(entry.itemId)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -8, 0, 56)
		row.BackgroundColor3 = Color3.fromRGB(55, 40, 28)
		row.Parent = invList
		corner(row, 6)

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -8, 0, 20)
		name.Position = UDim2.fromOffset(6, 4)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 13
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextColor3 = if item then Catalog.GetRarityColor(item.rarity) else Color3.new(1, 1, 1)
		name.Text = (if item then item.name else entry.itemId) .. " x" .. tostring(entry.qty)
		name.Parent = row

		local actions = Instance.new("Frame")
		actions.Size = UDim2.new(1, -8, 0, 26)
		actions.Position = UDim2.fromOffset(4, 26)
		actions.BackgroundTransparency = 1
		actions.Parent = row

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 4)
		layout.Parent = actions

		local function makeBtn(text: string, color: Color3, fn: () -> ())
			local b = Instance.new("TextButton")
			b.Size = UDim2.fromOffset(72, 24)
			b.BackgroundColor3 = color
			b.Font = Enum.Font.Gotham
			b.TextSize = 12
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Text = text
			b.Parent = actions
			corner(b, 4)
			b.MouseButton1Click:Connect(fn)
		end

		if item then
			if item.kind == "Recipe" then
				makeBtn("Bake", Color3.fromRGB(200, 120, 60), function()
					OvenWarsClient.RequestBake(entry.itemId)
				end)
			end
			if item.sellPrice then
				makeBtn("Sell", Color3.fromRGB(90, 140, 200), function()
					OvenWarsClient.RequestSell(entry.itemId, 1)
				end)
			end
			if item.kind == "Baked" then
				makeBtn("Display", Color3.fromRGB(140, 90, 200), function()
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
	-- finishesAt is server os.clock — may desync; show relative using startedAt if needed
	-- For MVP display job id + recipe name; claim enabled when client thinks ready OR always show Claim (server validates)
	local left = math.max(0, job.finishesAt - workspace:GetServerTimeNow())
	bakeBody.Text = "Baking: " .. (if recipe then recipe.name else job.recipeId)
		.. (if left > 0 then string.format("\nReady in %.1fs", left) else "\nReady!")
	currentClaimJobId = job.jobId
	claimBtn.Visible = true
	claimBtn.Text = if left > 0 then string.format("Wait %.0fs", left) else "Claim Bake"
	claimBtn.BackgroundColor3 = if left > 0 then Color3.fromRGB(120, 120, 120) else Color3.fromRGB(80, 160, 90)
end

OvenWarsClient.OnStateChanged(function(state)
	cashLabel.Text = "$" .. tostring(state.cash)
	rebuildInventory(state)
	refreshBake(state)
end)

-- Tick bake display
task.spawn(function()
	while screen.Parent do
		local state = OvenWarsClient.GetState()
		refreshBake(state)
		task.wait(0.5)
	end
end)

print("[OvenWars] HUD ready")
