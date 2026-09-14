--!strict
--[[
	Oven Wars — warm bakery atmosphere via Lighting service properties.
	Skybox: set a custom Sky in Studio if desired; code configures lighting only.
]]

local Lighting = game:GetService("Lighting")

local LightingService = {}

function LightingService.Init()
	-- Cozy late-afternoon / golden hour bakery vibe
	Lighting.ClockTime = 16.5
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(140, 115, 95)
	Lighting.OutdoorAmbient = Color3.fromRGB(155, 130, 105)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 180)
	Lighting.ColorShift_Bottom = Color3.fromRGB(180, 140, 110)
	Lighting.EnvironmentDiffuseScale = 0.65
	Lighting.EnvironmentSpecularScale = 0.4
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.35
	Lighting.GeographicLatitude = 35

	-- Atmosphere haze
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.28
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(220, 185, 150)
	atmosphere.Decay = Color3.fromRGB(180, 130, 100)
	atmosphere.Glare = 0.15
	atmosphere.Haze = 1.4

	-- Bloom
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.45
	bloom.Size = 24
	bloom.Threshold = 0.9

	-- Warm color correction
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Parent = Lighting
	end
	cc.Brightness = 0.03
	cc.Contrast = 0.08
	cc.Saturation = 0.15
	cc.TintColor = Color3.fromRGB(255, 235, 210)

	-- Subtle depth of field (if available)
	local dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
	if not dof then
		dof = Instance.new("DepthOfFieldEffect")
		dof.Parent = Lighting
	end
	dof.Enabled = true
	dof.FarIntensity = 0.12
	dof.NearIntensity = 0.05
	dof.FocusDistance = 40
	dof.InFocusRadius = 35

	-- Soft sun rays
	local rays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	if not rays then
		rays = Instance.new("SunRaysEffect")
		rays.Parent = Lighting
	end
	rays.Intensity = 0.08
	rays.Spread = 0.6

	--[[
		Sky: Rojo cannot ship arbitrary skybox asset IDs safely.
		In Studio: Lighting → insert Sky, or use Toolbox "Sky" assets.
		Leave default Sky; Atmosphere + ClockTime carry most of the mood.
	]]

	print("[OvenWars] LightingService: cozy golden-hour atmosphere applied")
end

return LightingService
