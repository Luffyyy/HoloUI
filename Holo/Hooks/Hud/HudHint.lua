if Holo.Options:GetValue("Base/Hud") and Holo.Options:GetValue("Hint")  then
	Hooks:PostHook(HUDHint, "init", "HoloInit", function(self)
		self:UpdateHoloHUD()
	end)
	function HUDHint:UpdateHoloHUD()
		local scale = Holo.Options:GetValue("HudScale")
		local clip_panel = self._hint_panel:child("clip_panel")
		self._hint_panel:configure({
			h = 30 * scale,
			y = 50 * scale
		})
		clip_panel:set_h(self._hint_panel:h())
		clip_panel:child("bg"):configure({
			w = self._hint_panel:w(),
			h = self._hint_panel:h(),
			color = Holo:GetColor("Colors/Hint"),
			alpha = Holo.Options:GetValue("HudAlpha"),
		})
		clip_panel:child("hint_text"):configure({
			font_size = 24 * scale,
			y = 0,
			h = self._hint_panel:h(),
			font = "fonts/font_large_mf",
			color = Holo:GetColor("TextColors/Hint"),
		})
		self._hint_panel:child("marker"):set_h(0)
	end
end