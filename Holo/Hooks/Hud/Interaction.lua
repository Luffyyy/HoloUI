if Holo:ShouldModify("Hud", "Interaction") then
	Holo:Post(HUDInteraction, "show_interact", function(self) 
		local text = self._hud_panel:child(self._child_name_text)
		text:set_color(Color.white)
		text:set_w(text:parent():w())
	end)
	Holo:Pre(HUDInteraction, "_animate_interaction_complete", function(self, bitmap, circle)
		bitmap:set_blend_mode("normal")
		circle._circle:set_blend_mode("normal")
	end)
end