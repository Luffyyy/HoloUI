Hooks:PostHook(CircleBitmapGuiObject, "init", "HoloInit", function(self)
	self._circle:set_image("guis/textures/hud/Circle" .. (Holo.RadialNames[Holo.Options:GetValue("Colors/Progress")]))
	self._circle:set_blend_mode("normal")
	if self._bg_circle then
		self._bg_circle:set_image("guis/textures/hud/CircleTransparent")
	end
end)
 
