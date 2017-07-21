Holo.CustomTextures = {}
Holo.Updaters = {}
Holo.Voices = { -- Add/Remove Voices!
	["f40_any"] = "Move",
	["l03x_sin"] = "And cuffs!",
	["a01x_any"] = "Lets start",
	["f38_any"] = "Follow me!",
	["f02x_sin"] = "Down On" ..  "\n" .. "The Ground!",
	["r01x_sin"] = "Ok",
	["p45"] = "Help",
	["p17"] = "Any Seconds",
	["whistling_attention"] = "Whistle",
	["f33y_any"] = "Cloaker!",
	["v55"] = "Sniper!",
	["f30x_any"] = "Dozer!",
	["f31x_any"] = "Shield!",
	["f32x_any"] = "Taser!",
	["s05x_sin"] = "Thanks",
	["g92"] = "Hooray!",
	["g06"] = "Go Down",
	["g05"] = "Go Up",
	["g63"] = "One Minute",
	["g65"] = "Two Minutes",
	["g67"] = "Any Seconds",
	["g24"] = "Fuck Yeah!",
	["g28"] = "Just A Bit",
	["g81x_plu"] = "Need Ammo!",
	["g80x_plu"] = "Need Healing!",
	["p19"] = "Coming!",
	["g43"] = "Grenade!",
	["g09"] = "Hurry!",
	["g10"] = "Careful",
	["p46"] = "Jump",
}
Holo.VoiceMaxPerRow = 5
Holo.Loot = {}
Holo.RadialNames = {
	"Blue",
	"Orange",
	"Green", 
	"Pink", 
	"Yellow",
	"White",
	"Red",
	"Cyan",
	"SpringGreen",
	"DarkBlue",
	"Purple",
	"Lime",
	"Black",
}
Holo.RadialColors = clone(Holo.RadialNames)
for i, name in pairs(Holo.RadialColors) do Holo.RadialColors[i] = "Holo/"..name end

Holo.TextSizesStrings = {
	"Holo/Small",
	"Holo/Normal",
	"Holo/Big"
}
Holo.FrameStyles = {
	"Holo/Normal",
	"Holo/BottomLine",
	"Holo/LeftLine",
	"Holo/RightLine",
	"Holo/TopLine",
	"Holo/FullFrame",
	"Holo/None",
}
Holo.Positions = {
	"Holo/TopLeft",
	"Holo/TopCenter",
	"Holo/TopRight",
	"Holo/CenterLeft",
	"Holo/Center",
	"Holo/CenterRight",
	"Holo/BottomLeft",
	"Holo/BottomCenter",
	"Holo/BottomRight",
}