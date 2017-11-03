if Holo:ShouldModify("Hud", "Interaction") then
	Holo:Post(CircleBitmapGuiObject, "init", function(self)
		self._circle:set_blend_mode("normal")
	end)
end