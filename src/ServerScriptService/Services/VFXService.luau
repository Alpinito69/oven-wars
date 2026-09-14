--!strict
--[[
	Oven Wars — server-spawned bake / sell / steal / legendary VFX.
	Uses ParticleEmitters + Highlight; no external asset IDs.
]]

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local Theme = require(game.ReplicatedStorage.Shared.Theme)

local VFXService = {}

local activeBakeSteam: { [number]: { ParticleEmitter } } = {}

local function findPlotForUser(userId: number): Model?
	local plots = workspace:FindFirstChild("Plots")
	if not plots then
		return nil
	end
	for _, child in plots:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("OwnerUserId") == userId then
			return child
		end
	end
	return nil
end

local function ensureEmitter(parent: Instance, name: string): ParticleEmitter
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("ParticleEmitter") then
		return existing
	end
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	e.Parent = parent
	return e
end

local function burst(attachment: Attachment, config: {
	color: ColorSequence,
	lifetime: NumberRange,
	speed: NumberRange,
	size: NumberSequence,
	rate: number,
	duration: number,
	spread: Vector2?,
	lightEmission: number?,
	texture: string?,
})
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Burst"
	emitter.Color = config.color
	emitter.Lifetime = config.lifetime
	emitter.Speed = config.speed
	emitter.Size = config.size
	emitter.SpreadAngle = config.spread or Vector2.new(40, 40)
	emitter.LightEmission = config.lightEmission or 0.4
	emitter.Rate = 0
	emitter.Enabled = true
	if config.texture then
		emitter.Texture = config.texture
	end
	emitter.Parent = attachment
	emitter:Emit(math.clamp(math.floor(config.rate), 1, 80))
	Debris:AddItem(emitter, config.duration + 1)
end

function VFXService.StartBake(userId: number)
	local plot = findPlotForUser(userId)
	if not plot then
		return
	end
	local oven = plot:FindFirstChild("Oven")
	if not oven or not oven:IsA("BasePart") then
		return
	end

	local light = oven:FindFirstChild("BakeLight")
	if light and light:IsA("PointLight") then
		light.Enabled = true
		light.Brightness = 2.2
	end

	local attach = oven:FindFirstChild("SteamAttachment")
	if not attach or not attach:IsA("Attachment") then
		attach = Instance.new("Attachment")
		attach.Name = "SteamAttachment"
		attach.Position = Vector3.new(0, 2.2, 0)
		attach.Parent = oven
	end

	VFXService.StopBake(userId)

	local steam = ensureEmitter(attach, "Steam")
	steam.Texture = "rbxasset://textures/particles/smoke_main.dds"
	steam.Color = ColorSequence.new(Color3.fromRGB(230, 230, 230), Color3.fromRGB(200, 200, 210))
	steam.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 2.2),
	})
	steam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	steam.Lifetime = NumberRange.new(1.2, 2.2)
	steam.Speed = NumberRange.new(1.5, 3)
	steam.SpreadAngle = Vector2.new(25, 25)
	steam.Rate = 12
	steam.LightEmission = 0.1
	steam.Enabled = true

	local sparks = ensureEmitter(attach, "HeatSparks")
	sparks.Color = ColorSequence.new(Theme.OvenGlow, Color3.fromRGB(255, 220, 120))
	sparks.Size = NumberSequence.new(0.15, 0.05)
	sparks.Lifetime = NumberRange.new(0.4, 0.8)
	sparks.Speed = NumberRange.new(2, 5)
	sparks.SpreadAngle = Vector2.new(60, 60)
	sparks.Rate = 8
	sparks.LightEmission = 0.7
	sparks.Enabled = true

	activeBakeSteam[userId] = { steam, sparks }
end

function VFXService.StopBake(userId: number)
	local list = activeBakeSteam[userId]
	if list then
		for _, e in list do
			if e.Parent then
				e.Enabled = false
				Debris:AddItem(e, 1.5)
			end
		end
		activeBakeSteam[userId] = nil
	end

	local plot = findPlotForUser(userId)
	if not plot then
		return
	end
	local oven = plot:FindFirstChild("Oven")
	if oven and oven:IsA("BasePart") then
		local light = oven:FindFirstChild("BakeLight")
		if light and light:IsA("PointLight") then
			light.Brightness = 0
			light.Enabled = false
		end
	end
end

function VFXService.ClaimSparkle(userId: number, itemId: string?)
	VFXService.StopBake(userId)
	local plot = findPlotForUser(userId)
	if not plot then
		return
	end
	local oven = plot:FindFirstChild("Oven")
	if not oven or not oven:IsA("BasePart") then
		return
	end
	local attach = oven:FindFirstChild("SteamAttachment") :: Attachment?
	if not attach then
		return
	end

	local legendary = false
	if itemId then
		local item = Catalog.Get(itemId)
		if item and item.rarity == "Legendary" then
			legendary = true
		end
	end

	burst(attach, {
		color = ColorSequence.new(Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 200, 80)),
		lifetime = NumberRange.new(0.5, 1.1),
		speed = NumberRange.new(4, 10),
		size = NumberSequence.new(0.35, 0.05),
		rate = if legendary then 50 else 28,
		duration = 1.2,
		spread = Vector2.new(80, 80),
		lightEmission = 0.8,
	})

	if legendary then
		VFXService.LegendaryCelebration(userId)
	end
end

function VFXService.LegendaryCelebration(userId: number)
	local plot = findPlotForUser(userId)
	if not plot then
		return
	end
	local floor = plot:FindFirstChild("Floor")
	if not floor or not floor:IsA("BasePart") then
		return
	end
	local attach = floor:FindFirstChild("LegendAttach")
	if not attach then
		attach = Instance.new("Attachment")
		attach.Name = "LegendAttach"
		attach.Position = Vector3.new(0, 3, 0)
		attach.Parent = floor
	end

	burst(attach :: Attachment, {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 200, 255)),
		}),
		lifetime = NumberRange.new(0.8, 1.6),
		speed = NumberRange.new(8, 18),
		size = NumberSequence.new(0.6, 0.1),
		rate = 70,
		duration = 2,
		spread = Vector2.new(180, 180),
		lightEmission = 0.9,
	})

	local flash = Instance.new("PointLight")
	flash.Brightness = 4
	flash.Range = 28
	flash.Color = Color3.fromRGB(255, 230, 140)
	flash.Parent = floor
	Debris:AddItem(flash, 1.2)
end

function VFXService.SellBurst(userId: number)
	local plot = findPlotForUser(userId)
	if not plot then
		return
	end
	local counter = plot:FindFirstChild("Counter")
	if not counter or not counter:IsA("BasePart") then
		return
	end
	local attach = counter:FindFirstChild("SellAttachment") :: Attachment?
	if not attach then
		attach = Instance.new("Attachment")
		attach.Name = "SellAttachment"
		attach.Position = Vector3.new(0, 1.5, 0)
		attach.Parent = counter
	end

	burst(attach, {
		color = ColorSequence.new(Color3.fromRGB(255, 230, 80), Color3.fromRGB(255, 200, 40)),
		lifetime = NumberRange.new(0.4, 0.9),
		speed = NumberRange.new(5, 12),
		size = NumberSequence.new(0.4, 0.08),
		rate = 32,
		duration = 1,
		spread = Vector2.new(50, 50),
		lightEmission = 0.75,
	})
end

function VFXService.StealPoof(targetUserId: number)
	local plot = findPlotForUser(targetUserId)
	if not plot then
		return
	end
	local display = plot:FindFirstChild("DisplayCase")
	if not display or not display:IsA("BasePart") then
		return
	end

	local attach = display:FindFirstChild("StealAttachment") :: Attachment?
	if not attach then
		attach = Instance.new("Attachment")
		attach.Name = "StealAttachment"
		attach.Parent = display
	end

	burst(attach, {
		color = ColorSequence.new(Color3.fromRGB(220, 220, 230), Color3.fromRGB(180, 180, 200)),
		lifetime = NumberRange.new(0.25, 0.6),
		speed = NumberRange.new(6, 14),
		size = NumberSequence.new(0.8, 0.1),
		rate = 36,
		duration = 0.8,
		spread = Vector2.new(90, 90),
		lightEmission = 0.2,
		texture = "rbxasset://textures/particles/smoke_main.dds",
	})

	-- Brief steal highlight
	local h = Instance.new("Highlight")
	h.Name = "StealFlash"
	h.Adornee = display
	h.FillColor = Color3.fromRGB(255, 90, 90)
	h.OutlineColor = Color3.fromRGB(255, 200, 200)
	h.FillTransparency = 0.45
	h.OutlineTransparency = 0
	h.Parent = display
	Debris:AddItem(h, 0.7)
end

Players.PlayerRemoving:Connect(function(player)
	VFXService.StopBake(player.UserId)
end)

return VFXService
