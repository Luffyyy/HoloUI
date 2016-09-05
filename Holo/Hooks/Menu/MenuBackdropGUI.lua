if Holo.Options:GetValue("Base/Menu") then
	if Holo.Options:GetValue("Menu/Lobby") then
		Hooks:PostHook(MenuBackdropGUI, "_create_base_layer", "HoloCreateBaseLayer", function(self)
			if Holo.Options:GetValue("Menu/ColoredBackground") then
				self._panel:child("base_layer"):child("bd_base_layer"):set_image("units/white_df")
				self._panel:child("base_layer"):child("bd_base_layer"):set_color(Holo:GetColor("Colors/MenuBackground"))
			end
			self._panel:child("pattern_layer"):set_visible(false)
			self._panel:child("light_layer"):set_visible(false)
			self._panel:child("particles_layer"):set_visible(false)	
		end)
	end
	function MenuBackdropGUI:animate_bg_text(text)
		text:hide()
	end
end