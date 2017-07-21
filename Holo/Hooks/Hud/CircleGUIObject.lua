if Holo:ShouldModify("Hud", "Interaction") then
	Hooks:PostHook(CircleBitmapGuiObject, "init", "HoloInit", function(self)
		self._circle:set_image("guis/textures/custom/Circle" .. (Holo.RadialNames[Holo.Options:GetValue("Colors/Progress")]))
		self._circle:set_blend_mode("normal")
		if self._bg_circle then
			self._bg_circle:set_image("guis/textures/custom/CircleTransparent")
		end
	end)
end