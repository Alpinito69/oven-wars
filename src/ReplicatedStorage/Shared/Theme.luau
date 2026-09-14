--!strict
--[[
	Oven Wars — warm bakery color palette + plot accent colors.
	Shared so client UI and server world builders stay consistent.
]]

local Theme = {}

Theme.Cream = Color3.fromRGB(255, 245, 230)
Theme.CreamDark = Color3.fromRGB(235, 220, 195)
Theme.Terracotta = Color3.fromRGB(196, 110, 70)
Theme.TerracottaDeep = Color3.fromRGB(150, 75, 45)
Theme.Wood = Color3.fromRGB(120, 78, 48)
Theme.WoodLight = Color3.fromRGB(160, 115, 75)
Theme.WoodDark = Color3.fromRGB(78, 48, 28)
Theme.SoftPink = Color3.fromRGB(240, 175, 185)
Theme.Blush = Color3.fromRGB(255, 200, 205)
Theme.Mint = Color3.fromRGB(150, 210, 185)
Theme.MintDeep = Color3.fromRGB(90, 160, 135)
Theme.Gold = Color3.fromRGB(230, 190, 90)
Theme.Butter = Color3.fromRGB(255, 230, 140)
Theme.Flour = Color3.fromRGB(240, 230, 210)
Theme.Sugar = Color3.fromRGB(255, 252, 245)
Theme.Stone = Color3.fromRGB(185, 175, 160)
Theme.Path = Color3.fromRGB(210, 185, 150)
Theme.Grass = Color3.fromRGB(95, 150, 90)
Theme.Hedge = Color3.fromRGB(70, 120, 70)
Theme.Glass = Color3.fromRGB(190, 230, 235)
Theme.OvenBody = Color3.fromRGB(70, 55, 50)
Theme.OvenDoor = Color3.fromRGB(45, 40, 38)
Theme.OvenGlow = Color3.fromRGB(255, 160, 60)
Theme.SignBoard = Color3.fromRGB(90, 55, 35)
Theme.AwningStripeA = Color3.fromRGB(220, 90, 90)
Theme.AwningStripeB = Color3.fromRGB(250, 240, 230)
Theme.UI = {
	Panel = Color3.fromRGB(48, 32, 24),
	PanelAlt = Color3.fromRGB(62, 42, 30),
	PanelLight = Color3.fromRGB(78, 54, 38),
	Stroke = Color3.fromRGB(210, 160, 100),
	Text = Color3.fromRGB(255, 245, 230),
	TextMuted = Color3.fromRGB(220, 200, 175),
	Cash = Color3.fromRGB(255, 220, 100),
	Accent = Color3.fromRGB(220, 130, 70),
	Success = Color3.fromRGB(90, 170, 100),
	Danger = Color3.fromRGB(200, 75, 75),
	Info = Color3.fromRGB(100, 150, 210),
	Purple = Color3.fromRGB(150, 100, 200),
	Toast = Color3.fromRGB(35, 24, 18),
}

-- Per-plot accent so each bakery reads uniquely
Theme.PLOT_ACCENTS = {
	Color3.fromRGB(240, 150, 160), -- soft pink
	Color3.fromRGB(210, 120, 70), -- terracotta
	Color3.fromRGB(130, 195, 165), -- mint
	Color3.fromRGB(230, 185, 90), -- honey gold
	Color3.fromRGB(255, 175, 140), -- peach
	Color3.fromRGB(200, 150, 190), -- lavender rose
	Color3.fromRGB(230, 110, 100), -- coral
	Color3.fromRGB(120, 175, 190), -- soft teal
}

Theme.PLOT_NAMES = {
	"Cream & Crumb",
	"Honey Hearth",
	"Mint Oven",
	"Golden Whisk",
	"Peach Pastry",
	"Rose Bakery",
	"Coral Crust",
	"Teal Tartine",
}

function Theme.PlotAccent(index: number): Color3
	local accents = Theme.PLOT_ACCENTS
	return accents[((index - 1) % #accents) + 1]
end

function Theme.PlotName(index: number): string
	local names = Theme.PLOT_NAMES
	return names[((index - 1) % #names) + 1]
end

return Theme
