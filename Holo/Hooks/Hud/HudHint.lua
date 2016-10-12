if Holo:ShouldModify("Hud", "Hint") then
	Hooks:PostHook(HUDHint, "init", "HoloInit", function(self)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDHint:UpdateHolo()
		self._hint_panel:configure({
			h = 30,
			y = 50
		})
		self._hint_panel:set_world_center_x(self._hint_panel:parent():world_center_x())
		local clip_panel = self._hint_panel:child("clip_panel")
		clip_panel:set_size(self._hint_panel:size())
		clip_panel:child("bg"):configure({
			color = Holo:GetColor("Colors/Hint"),
			alpha = Holo.Options:GetValue("HudAlpha"),
		})
		clip_panel:child("hint_text"):configure({
			y = 0,
			font = "fonts/font_large_mf",
			font_size = clip_panel:h() - 2,
			color = Holo:GetColor("TextColors/Hint"),
		})
		self._hint_panel:child("marker"):set_h(0)
	end
end