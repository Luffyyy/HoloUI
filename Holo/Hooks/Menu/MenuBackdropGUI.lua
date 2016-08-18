if Holo.Options:GetValue("Base/Menu") and Holo.Options:GetValue("Menu/Lobby") and Holo.Options:GetValue("Menu/ColoredBackground") then
	function MenuBackdropGUI:_create_base_layer()
		local base_layer = self._panel:child("base_layer")
		base_layer:clear()
		self:_set_layers_of_layer(1, 1)
		local bd_base_layer = base_layer:rect({
			name = "bd_base_layer",
			color = Holo:GetColor("Colors/MenuBackground")
		})
		self._panel:child("pattern_layer"):set_visible(false)
		self._panel:child("light_layer"):set_visible(false)
		self._panel:child("particles_layer"):set_visible(false)
	end
	function MenuBackdropGUI:animate_bg_text(text)
		text:hide()
	end
end