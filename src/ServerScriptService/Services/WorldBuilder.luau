--!strict
--[[
	Oven Wars — cozy bakery plaza world (Parts composition).
	Builds Hub, Plots, LightingHelpers under Workspace.
	Mesh/Toolbox assets can replace these in Studio later (see ASSETS.md).
]]

local Constants = require(game.ReplicatedStorage.Shared.Constants)
local Theme = require(game.ReplicatedStorage.Shared.Theme)

local WorldBuilder = {}

local function part(
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	parent: Instance,
	props: { [string]: any }?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if props then
		for k, v in props do
			(p :: any)[k] = v
		end
	end
	p.Parent = parent
	return p
end

local function surfaceLabel(adornee: BasePart, face: Enum.NormalId, text: string, textColor: Color3?): SurfaceGui
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Label"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor or Theme.Cream
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = Color3.fromRGB(40, 25, 15)
	label.Parent = gui
	return gui
end

local function billboard(adornee: BasePart, text: string, offsetY: number?): BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Name = "Billboard"
	bb.Size = UDim2.fromOffset(220, 44)
	bb.StudsOffset = Vector3.new(0, offsetY or 4, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 80
	bb.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Theme.WoodDark
	label.BackgroundTransparency = 0.25
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Theme.Cream
	label.Parent = bb

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	return bb
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

local function buildStall(
	parent: Model,
	name: string,
	origin: CFrame,
	accent: Color3,
	signText: string,
	gatherItemId: string?,
	crateColor: Color3
)
	local stall = Instance.new("Model")
	stall.Name = name
	stall.Parent = parent

	-- Table
	part("TableTop", Vector3.new(6, 0.4, 3.5), origin * CFrame.new(0, 2.2, 0), Theme.WoodLight, stall, {
		Material = Enum.Material.Wood,
	})
	part("LegFL", Vector3.new(0.35, 2.2, 0.35), origin * CFrame.new(-2.4, 1.1, -1.3), Theme.WoodDark, stall, {
		Material = Enum.Material.Wood,
	})
	part("LegFR", Vector3.new(0.35, 2.2, 0.35), origin * CFrame.new(2.4, 1.1, -1.3), Theme.WoodDark, stall, {
		Material = Enum.Material.Wood,
	})
	part("LegBL", Vector3.new(0.35, 2.2, 0.35), origin * CFrame.new(-2.4, 1.1, 1.3), Theme.WoodDark, stall, {
		Material = Enum.Material.Wood,
	})
	part("LegBR", Vector3.new(0.35, 2.2, 0.35), origin * CFrame.new(2.4, 1.1, 1.3), Theme.WoodDark, stall, {
		Material = Enum.Material.Wood,
	})

	-- Awning posts + canopy
	part("PostL", Vector3.new(0.3, 4, 0.3), origin * CFrame.new(-2.8, 2.5, -1.6), Theme.Wood, stall, {
		Material = Enum.Material.Wood,
	})
	part("PostR", Vector3.new(0.3, 4, 0.3), origin * CFrame.new(2.8, 2.5, -1.6), Theme.Wood, stall, {
		Material = Enum.Material.Wood,
	})
	part("Awning", Vector3.new(6.4, 0.25, 3.8), origin * CFrame.new(0, 4.6, -0.2) * CFrame.Angles(math.rad(-12), 0, 0), accent, stall, {
		Material = Enum.Material.Fabric,
	})
	part("AwningTrim", Vector3.new(6.5, 0.15, 0.3), origin * CFrame.new(0, 4.2, -2), Theme.AwningStripeB, stall, {
		Material = Enum.Material.Fabric,
	})

	-- Crates / goods
	local crate = part("Crate", Vector3.new(2.2, 1.6, 1.8), origin * CFrame.new(0, 3.2, 0.2), crateColor, stall, {
		Material = Enum.Material.Wood,
	})
	if gatherItemId then
		crate:SetAttribute("GatherItemId", gatherItemId)
		crate:SetAttribute("IsGatherNode", true)
		crate:SetAttribute("GatherNodeId", name) -- stall model name e.g. FlourStall
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = signText
		prompt.ActionText = "Gather"
		prompt.HoldDuration = 0.4
		prompt.MaxActivationDistance = 10
		prompt.Parent = crate
	end

	-- Sign
	local sign = part("Sign", Vector3.new(3.5, 1.2, 0.2), origin * CFrame.new(0, 3.6, -1.8), Theme.SignBoard, stall, {
		Material = Enum.Material.Wood,
	})
	surfaceLabel(sign, Enum.NormalId.Front, signText, Theme.Cream)
end

local function buildFountain(hub: Model)
	local base = part("FountainBase", Vector3.new(8, 1.2, 8), CFrame.new(0, 1.1, 0), Theme.Stone, hub, {
		Material = Enum.Material.Slate,
	})
	part("FountainRing", Vector3.new(10, 0.6, 10), CFrame.new(0, 0.8, 0), Theme.CreamDark, hub, {
		Material = Enum.Material.Concrete,
	})
	part("Pedestal", Vector3.new(2.4, 3.5, 2.4), CFrame.new(0, 3.1, 0), Theme.Terracotta, hub, {
		Material = Enum.Material.Ceramic,
	})
	local cake = part("DisplayCake", Vector3.new(3.2, 1.4, 3.2), CFrame.new(0, 5.4, 0), Theme.SoftPink, hub, {
		Material = Enum.Material.SmoothPlastic,
	})
	part("CakeTop", Vector3.new(2.4, 0.5, 2.4), CFrame.new(0, 6.3, 0), Theme.Blush, hub)
	part("CakeCherry", Vector3.new(0.6, 0.6, 0.6), CFrame.new(0, 6.8, 0), Color3.fromRGB(200, 50, 60), hub, {
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.SmoothPlastic,
	})
	billboard(cake, "★ Oven Wars Plaza ★", 3)

	local light = Instance.new("PointLight")
	light.Brightness = 1.2
	light.Range = 18
	light.Color = Theme.Butter
	light.Parent = base
end

function WorldBuilder.ClearPrevious()
	for _, name in { "Hub", "Plots", "LightingHelpers", "OvenWarsPlots" } do
		local existing = workspace:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end
end

function WorldBuilder.BuildHub(): Folder
	local hubFolder = Instance.new("Folder")
	hubFolder.Name = "Hub"
	hubFolder.Parent = workspace

	local hub = Instance.new("Model")
	hub.Name = "Plaza"
	hub.Parent = hubFolder

	-- Plaza floor (layered for coziness)
	part("PlazaFloor", Vector3.new(36, 1, 36), CFrame.new(Constants.HUB_CENTER), Theme.CreamDark, hub, {
		Material = Enum.Material.Concrete,
	})
	part("PlazaInlay", Vector3.new(22, 0.2, 22), CFrame.new(0, 0.6, 0), Theme.Cream, hub, {
		Material = Enum.Material.SmoothPlastic,
	})
	part("PlazaRing", Vector3.new(28, 0.15, 28), CFrame.new(0, 0.55, 0), Theme.Terracotta, hub, {
		Material = Enum.Material.Brick,
	})

	buildFountain(hub)

	-- Welcome arch / sign
	part("ArchL", Vector3.new(1, 8, 1), CFrame.new(-7, 4.5, -16), Theme.Wood, hub, {
		Material = Enum.Material.Wood,
	})
	part("ArchR", Vector3.new(1, 8, 1), CFrame.new(7, 4.5, -16), Theme.Wood, hub, {
		Material = Enum.Material.Wood,
	})
	local archTop = part("ArchTop", Vector3.new(15, 1.5, 1.2), CFrame.new(0, 8.5, -16), Theme.TerracottaDeep, hub, {
		Material = Enum.Material.Wood,
	})
	surfaceLabel(archTop, Enum.NormalId.Front, "OVEN WARS  •  MARKET HUB", Theme.Cream)
	surfaceLabel(archTop, Enum.NormalId.Back, "OVEN WARS  •  MARKET HUB", Theme.Cream)

	-- Market stalls (gather nodes)
	buildStall(
		hub,
		"FlourStall",
		CFrame.new(10, 0, 6) * CFrame.Angles(0, math.rad(-35), 0),
		Theme.SoftPink,
		"Flour Market",
		"Flour",
		Theme.Flour
	)
	buildStall(
		hub,
		"ButterStall",
		CFrame.new(-10, 0, 6) * CFrame.Angles(0, math.rad(35), 0),
		Theme.Butter,
		"Butter Stall",
		"Butter",
		Theme.Butter
	)
	buildStall(
		hub,
		"SugarStall",
		CFrame.new(0, 0, 12) * CFrame.Angles(0, math.rad(180), 0),
		Theme.Mint,
		"Sugar Stand",
		"SugarDust",
		Theme.Sugar
	)

	-- Benches
	for _, ox in { -12, 12 } do
		part("BenchSeat", Vector3.new(5, 0.4, 1.4), CFrame.new(ox, 1.2, -8), Theme.WoodLight, hub, {
			Material = Enum.Material.Wood,
		})
		part("BenchBack", Vector3.new(5, 1.4, 0.3), CFrame.new(ox, 2, -8.6), Theme.Wood, hub, {
			Material = Enum.Material.Wood,
		})
	end

	-- Planters
	for _, offset in {
		Vector3.new(14, 0.8, -10),
		Vector3.new(-14, 0.8, -10),
		Vector3.new(14, 0.8, 14),
		Vector3.new(-14, 0.8, 14),
	} do
		part("Planter", Vector3.new(2.2, 1.2, 2.2), CFrame.new(offset), Theme.Terracotta, hub, {
			Material = Enum.Material.Ceramic,
		})
		part("Bush", Vector3.new(2, 1.6, 2), CFrame.new(offset + Vector3.new(0, 1.4, 0)), Theme.Hedge, hub, {
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end

	return hubFolder
end

local function buildOven(model: Model, cf: CFrame, accent: Color3)
	local ovenGroup = Instance.new("Model")
	ovenGroup.Name = "OvenGroup"
	ovenGroup.Parent = model

	-- Main interactive oven part (API-compatible name at plot root)
	local oven = part("Oven", Vector3.new(5.5, 4.5, 4), cf * CFrame.new(0, 2.75, -13), Theme.OvenBody, model, {
		Material = Enum.Material.Metal,
	})
	oven:SetAttribute("IsOven", true)

	part("OvenTop", Vector3.new(5.8, 0.4, 4.3), cf * CFrame.new(0, 5.2, -13), Theme.WoodDark, ovenGroup, {
		Material = Enum.Material.Wood,
	})
	part("OvenDoor", Vector3.new(3.2, 2.4, 0.25), cf * CFrame.new(0, 2.4, -10.9), Theme.OvenDoor, ovenGroup, {
		Material = Enum.Material.Metal,
	})
	local window = part("OvenWindow", Vector3.new(2.2, 1.4, 0.2), cf * CFrame.new(0, 2.5, -10.85), Theme.OvenGlow, ovenGroup, {
		Material = Enum.Material.Neon,
		Transparency = 0.35,
		CanCollide = false,
	})
	part("Chimney", Vector3.new(1.2, 2.5, 1.2), cf * CFrame.new(1.8, 6.5, -13.5), Theme.Stone, ovenGroup, {
		Material = Enum.Material.Brick,
	})
	part("ChimneyCap", Vector3.new(1.6, 0.3, 1.6), cf * CFrame.new(1.8, 7.8, -13.5), Theme.WoodDark, ovenGroup)

	local light = Instance.new("PointLight")
	light.Name = "BakeLight"
	light.Brightness = 0
	light.Range = 14
	light.Color = Theme.OvenGlow
	light.Enabled = false
	light.Parent = oven

	-- Steam attach point (VFXService fills emitters)
	local steamAttach = Instance.new("Attachment")
	steamAttach.Name = "SteamAttachment"
	steamAttach.Position = Vector3.new(0, 2.5, 0)
	steamAttach.Parent = oven

	local _ = accent
	local _ = window
end

local function buildDisplayCase(model: Model, cf: CFrame, accent: Color3)
	local counter = part("Counter", Vector3.new(9, 2.2, 3), cf * CFrame.new(11, 1.6, 0), Theme.WoodLight, model, {
		Material = Enum.Material.Wood,
	})
	part("CounterTrim", Vector3.new(9.2, 0.25, 3.2), cf * CFrame.new(11, 2.75, 0), accent, model, {
		Material = Enum.Material.SmoothPlastic,
	})

	-- Glass display case (main steal target — must stay named DisplayCase at plot root)
	local glass = part("DisplayCase", Vector3.new(7.5, 3.2, 2.2), cf * CFrame.new(11, 4.5, 0), Theme.Glass, model, {
		Material = Enum.Material.Glass,
		Transparency = 0.45,
		Reflectance = 0.15,
	})
	glass:SetAttribute("IsDisplayCase", true)

	part("CaseFrameTop", Vector3.new(7.8, 0.25, 2.4), cf * CFrame.new(11, 6.2, 0), Theme.Wood, model, {
		Material = Enum.Material.Wood,
	})
	part("CaseFrameL", Vector3.new(0.25, 3.2, 2.4), cf * CFrame.new(7.35, 4.5, 0), Theme.Wood, model, {
		Material = Enum.Material.Wood,
	})
	part("CaseFrameR", Vector3.new(0.25, 3.2, 2.4), cf * CFrame.new(14.65, 4.5, 0), Theme.Wood, model, {
		Material = Enum.Material.Wood,
	})
	part("CaseShelf", Vector3.new(7, 0.15, 1.8), cf * CFrame.new(11, 4.2, 0), Theme.Cream, model, {
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local stealPrompt = Instance.new("ProximityPrompt")
	stealPrompt.Name = "StealPrompt"
	stealPrompt.ObjectText = "Display Case"
	stealPrompt.ActionText = "Steal 🍪"
	stealPrompt.HoldDuration = 0.6
	stealPrompt.MaxActivationDistance = Constants.STEAL_RANGE_STUDS
	stealPrompt.RequiresLineOfSight = false
	stealPrompt.Parent = glass

	local displayGui = Instance.new("BillboardGui")
	displayGui.Name = "DisplayItemBillboard"
	displayGui.Size = UDim2.fromOffset(160, 36)
	displayGui.StudsOffset = Vector3.new(0, 2.8, 0)
	displayGui.AlwaysOnTop = false
	displayGui.MaxDistance = 50
	displayGui.Parent = glass

	local displayText = Instance.new("TextLabel")
	displayText.Name = "ItemLabel"
	displayText.Size = UDim2.fromScale(1, 1)
	displayText.BackgroundColor3 = Theme.WoodDark
	displayText.BackgroundTransparency = 0.3
	displayText.Text = "Empty case"
	displayText.TextScaled = true
	displayText.Font = Enum.Font.Gotham
	displayText.TextColor3 = Theme.Cream
	displayText.Parent = displayGui
	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(0, 6)
	dc.Parent = displayText

	local poofAttach = Instance.new("Attachment")
	poofAttach.Name = "StealAttachment"
	poofAttach.Parent = glass

	local sellAttach = Instance.new("Attachment")
	sellAttach.Name = "SellAttachment"
	sellAttach.Position = Vector3.new(0, 1, 0)
	sellAttach.Parent = counter

	return glass, counter
end

local function buildUpgradeBoard(model: Model, cf: CFrame, accent: Color3)
	local post = part("BoardPost", Vector3.new(0.5, 5, 0.5), cf * CFrame.new(-13, 3, 2), Theme.WoodDark, model, {
		Material = Enum.Material.Wood,
	})
	local board = part("UpgradeBoard", Vector3.new(5.5, 4, 0.4), cf * CFrame.new(-13, 4.5, 2), Theme.SignBoard, model, {
		Material = Enum.Material.Wood,
	})
	board:SetAttribute("IsUpgradeBoard", true)
	part("BoardFrame", Vector3.new(5.9, 4.4, 0.25), cf * CFrame.new(-13, 4.5, 1.85), accent, model, {
		Material = Enum.Material.SmoothPlastic,
	})

	surfaceLabel(board, Enum.NormalId.Front, "⬆ UPGRADES\nKitchen Shop", Theme.Cream)
	surfaceLabel(board, Enum.NormalId.Back, "⬆ UPGRADES", Theme.Cream)

	local upgradePrompt = Instance.new("ProximityPrompt")
	upgradePrompt.Name = "UpgradePrompt"
	upgradePrompt.ObjectText = "Upgrade Board"
	upgradePrompt.ActionText = "Open Shop"
	upgradePrompt.HoldDuration = 0.2
	upgradePrompt.MaxActivationDistance = 12
	upgradePrompt.Parent = board

	local _ = post
end

local function buildRoof(model: Model, cf: CFrame, accent: Color3)
	-- Half-walls
	part("WallBack", Vector3.new(28, 5, 0.6), cf * CFrame.new(0, 3, -16), Theme.Cream, model, {
		Material = Enum.Material.SmoothPlastic,
	})
	part("WallL", Vector3.new(0.6, 4, 18), cf * CFrame.new(-15, 2.5, -6), Theme.CreamDark, model, {
		Material = Enum.Material.SmoothPlastic,
	})
	part("WallR", Vector3.new(0.6, 4, 18), cf * CFrame.new(15, 2.5, -6), Theme.CreamDark, model, {
		Material = Enum.Material.SmoothPlastic,
	})
	-- Accent stripe on back wall
	part("AccentStripe", Vector3.new(26, 0.6, 0.65), cf * CFrame.new(0, 5.2, -16), accent, model)

	-- Awning / roof over bakery
	part("Roof", Vector3.new(30, 0.4, 20), cf * CFrame.new(0, 7.2, -6) * CFrame.Angles(math.rad(-6), 0, 0), accent, model, {
		Material = Enum.Material.Fabric,
	})
	part("RoofBeam", Vector3.new(30, 0.5, 0.5), cf * CFrame.new(0, 6.6, 3.5), Theme.Wood, model, {
		Material = Enum.Material.Wood,
	})
end

function WorldBuilder.BuildPlot(index: number, plotsFolder: Folder): Model
	local accent = Theme.PlotAccent(index)
	local bakeryName = Theme.PlotName(index)

	local model = Instance.new("Model")
	model.Name = "Plot_" .. tostring(index)
	model:SetAttribute("PlotIndex", index)
	model:SetAttribute("OwnerUserId", 0)
	model:SetAttribute("DisplayItemId", "")
	model:SetAttribute("BakeryName", bakeryName)
	model.Parent = plotsFolder

	local cf = plotCFrame(index)

	-- Floor pad
	local floor = part("Floor", Constants.PLOT_SIZE, cf * CFrame.new(0, 0, 0), Theme.Path, model, {
		Material = Enum.Material.Concrete,
	})
	part("FloorRug", Vector3.new(18, 0.15, 14), cf * CFrame.new(0, 0.55, -2), Theme.Cream, model, {
		Material = Enum.Material.Fabric,
		CanCollide = false,
	})
	part("AccentTile", Vector3.new(8, 0.12, 8), cf * CFrame.new(0, 0.58, 6), accent, model, {
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	buildRoof(model, cf, accent)
	buildOven(model, cf, accent)
	buildDisplayCase(model, cf, accent)
	buildUpgradeBoard(model, cf, accent)

	-- Spawn doormat
	local spawn = part("Spawn", Vector3.new(5, 0.2, 4), cf * CFrame.new(0, 0.65, 12), Theme.Mint, model, {
		Material = Enum.Material.Fabric,
		CanCollide = false,
		Transparency = 0.15,
	})
	surfaceLabel(spawn, Enum.NormalId.Top, "HOME", Theme.WoodDark)

	-- Plot number / name sign (front)
	local nameSign = part("NameSign", Vector3.new(10, 2.2, 0.35), cf * CFrame.new(0, 3.5, 16), Theme.SignBoard, model, {
		Material = Enum.Material.Wood,
	})
	part("NameSignPostL", Vector3.new(0.4, 3.5, 0.4), cf * CFrame.new(-4.5, 2, 16), Theme.WoodDark, model, {
		Material = Enum.Material.Wood,
	})
	part("NameSignPostR", Vector3.new(0.4, 3.5, 0.4), cf * CFrame.new(4.5, 2, 16), Theme.WoodDark, model, {
		Material = Enum.Material.Wood,
	})
	surfaceLabel(nameSign, Enum.NormalId.Front, "#" .. tostring(index) .. "  " .. bakeryName, Theme.Cream)
	surfaceLabel(nameSign, Enum.NormalId.Back, "#" .. tostring(index) .. "  " .. bakeryName, Theme.Cream)

	-- Billboard owner label (updated by PlotService)
	local bb = Instance.new("BillboardGui")
	bb.Name = "PlotLabel"
	bb.Size = UDim2.fromOffset(200, 42)
	bb.StudsOffset = Vector3.new(0, 9, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 90
	bb.Parent = floor
	local text = Instance.new("TextLabel")
	text.Name = "Label"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 0.2
	text.BackgroundColor3 = Theme.WoodDark
	text.Text = bakeryName .. "  ·  Empty"
	text.TextColor3 = Theme.Cream
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.Parent = bb
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 8)
	tc.Parent = text

	-- Low hedges along sides toward hub
	for _, side in { -1, 1 } do
		for i = 0, 3 do
			part(
				"Hedge",
				Vector3.new(1.2, 1.4, 3),
				cf * CFrame.new(side * 18, 1.2, 8 - i * 4),
				Theme.Hedge,
				model,
				{ Material = Enum.Material.Grass, CanCollide = true }
			)
		end
	end

	-- Small fence posts at plot entrance
	for _, sx in { -6, 6 } do
		part("FencePost", Vector3.new(0.35, 2.2, 0.35), cf * CFrame.new(sx, 1.4, 18), Theme.Wood, model, {
			Material = Enum.Material.Wood,
		})
	end
	part("FenceRail", Vector3.new(12, 0.25, 0.25), cf * CFrame.new(0, 1.8, 18), Theme.WoodLight, model, {
		Material = Enum.Material.Wood,
	})

	return model
end

function WorldBuilder.BuildPlots(): Folder
	local plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = workspace
	return plotsFolder
end

function WorldBuilder.BuildPathwaysAndLamps(helpers: Folder, plotModels: { Model })
	-- Ground ring / grass apron
	part("GrassRing", Vector3.new(160, 0.8, 160), CFrame.new(0, -0.9, 0), Theme.Grass, helpers, {
		Material = Enum.Material.Grass,
	})

	-- Pathways from hub to each plot
	for i = 1, Constants.PLOT_COUNT do
		local cf = plotCFrame(i)
		local plotPos = cf.Position
		local hubPos = Constants.HUB_CENTER
		local mid = (plotPos + hubPos) / 2
		local dir = plotPos - hubPos
		local dist = dir.Magnitude
		local angle = math.atan2(-dir.X, -dir.Z)

		part(
			"Path_" .. tostring(i),
			Vector3.new(5, 0.25, dist - 18),
			CFrame.new(mid.X, 0.2, mid.Z) * CFrame.Angles(0, angle, 0),
			Theme.Path,
			helpers,
			{ Material = Enum.Material.Cobblestone }
		)

		-- Street lamps along path
		local lampPos = hubPos:Lerp(plotPos, 0.45)
		local pole = part(
			"LampPole_" .. tostring(i),
			Vector3.new(0.35, 7, 0.35),
			CFrame.new(lampPos.X, 3.5, lampPos.Z),
			Theme.WoodDark,
			helpers,
			{ Material = Enum.Material.Metal }
		)
		local lampHead = part(
			"LampHead_" .. tostring(i),
			Vector3.new(1.4, 0.8, 1.4),
			CFrame.new(lampPos.X, 7.2, lampPos.Z),
			Theme.Butter,
			helpers,
			{ Material = Enum.Material.Neon }
		)
		local light = Instance.new("PointLight")
		light.Brightness = 1.4
		light.Range = 22
		light.Color = Color3.fromRGB(255, 210, 140)
		light.Parent = lampHead

		-- Hedge clumps flanking path
		local hedgePos = hubPos:Lerp(plotPos, 0.3)
		local side = Vector3.new(-dir.Z, 0, dir.X).Unit
		for _, s in { -1, 1 } do
			part(
				"PathHedge",
				Vector3.new(1.5, 1.6, 2.5),
				CFrame.new(hedgePos + side * (s * 4) + Vector3.new(0, 1.1, 0)),
				Theme.Hedge,
				helpers,
				{ Material = Enum.Material.Grass }
			)
		end

		local _ = pole
		local _ = plotModels
	end

	-- Hub corner lamps
	for _, pos in {
		Vector3.new(16, 0, 16),
		Vector3.new(-16, 0, 16),
		Vector3.new(16, 0, -16),
		Vector3.new(-16, 0, -16),
	} do
		part("HubLampPole", Vector3.new(0.4, 6, 0.4), CFrame.new(pos + Vector3.new(0, 3, 0)), Theme.WoodDark, helpers, {
			Material = Enum.Material.Metal,
		})
		local head = part("HubLampHead", Vector3.new(1.2, 0.7, 1.2), CFrame.new(pos + Vector3.new(0, 6.4, 0)), Theme.Gold, helpers, {
			Material = Enum.Material.Neon,
		})
		local light = Instance.new("PointLight")
		light.Brightness = 1.6
		light.Range = 24
		light.Color = Color3.fromRGB(255, 200, 120)
		light.Parent = head
	end
end

function WorldBuilder.BuildLightingHelpers(): Folder
	local helpers = Instance.new("Folder")
	helpers.Name = "LightingHelpers"
	helpers.Parent = workspace
	return helpers
end

WorldBuilder.PlotCFrame = plotCFrame

return WorldBuilder
