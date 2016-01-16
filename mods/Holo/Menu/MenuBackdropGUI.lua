if Holo.options.Holomenu_lobby and Holo.options.colorbg_enable then
function MenuBackdropGUI:_create_base_layer()
	local base_layer = self._panel:child("base_layer")
	base_layer:clear()
	self:_set_layers_of_layer(1, 1)
	local bd_base_layer = base_layer:bitmap({
		name = "bd_base_layer",
		color = Holomenu_color_background
	})
	self._panel:child("pattern_layer"):set_visible(false)
	self._panel:child("light_layer"):set_visible(false)
	self._panel:child("particles_layer"):set_visible(false)
end

end