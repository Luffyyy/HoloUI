Hooks:PostHook(HUDInteraction, "init", "HoloInit", function(self) 
	self:UpdateHoloHUD()
end)
function HUDInteraction:UpdateHoloHUD()
	self._circle_radius = 64 * Holo.Options:GetValue("HudScale")
end
Hooks:PostHook(HUDInteraction, "show_interact", "HoloShowInteract", function(self) 
	self._hud_panel:child(self._child_name_text):set_color(Color.white)
end)

function HUDInteraction:show_interaction_bar()
	if self._interact_circle then
		self._interact_circle:remove()
		self._interact_circle = nil
	end
	self._interact_circle = CircleBitmapGuiObject:new(self._hud_panel, {
		use_bg = true,
		radius = self._circle_radius,
		sides = self._sides,
		current = self._sides,
		total = self._sides,
		color = Color.white,
		layer = 2
	})
	self._interact_circle:set_position(self._hud_panel:w() / 2 - self._circle_radius, self._hud_panel:h() / 2 - self._circle_radius)
end
function HUDInteraction:hide_interaction_bar(complete)
	if complete then
		local bitmap = self._hud_panel:bitmap({
			texture = "guis/Holo/Circle" .. (Holo.RadialNames[Holo.Options:GetValue("Colors/Progress")]),
			align = "center",
			valign = "center",
			layer = 2
		})
		bitmap:set_position(bitmap:parent():w() / 2 - bitmap:w() / 2, bitmap:parent():h() / 2 - bitmap:h() / 2)
		local radius = 64 * Holo.Options:GetValue("HudScale")
		local circle = CircleBitmapGuiObject:new(self._hud_panel, {
			radius = self._circle_radius,
			sides = 64,
			current = 64,
			total = 64,
			color = Color.white:with_alpha(1),
			blend_mode = "normal",
			layer = 3
		})
		circle:set_position(self._hud_panel:w() / 2 - radius, self._hud_panel:h() / 2 - radius)
		bitmap:animate(callback(self, self, "_animate_interaction_complete"), circle)
	end
	if self._interact_circle then
		self._interact_circle:remove()
		self._interact_circle = nil
	end
end
Hooks:PostHook(HUDInteraction, "set_bar_valid", "HoloSetBarValid", function(self, valid)
 	self._interact_circle:set_image("guis/Holo/Circle" .. (Holo.RadialNames[Holo.Options:GetValue("Colors/Progress" .. (valid and "" or "Red"))]))
end)
