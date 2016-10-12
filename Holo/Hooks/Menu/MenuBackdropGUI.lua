if Holo.Options:GetValue("Base/Menu") then
	Hooks:PostHook(MenuBackdropGUI, "_create_base_layer", "HoloCreateBaseLayer", function(self)
		if Holo.Options:GetValue("Menu/ColoredBackground") then
			for _, child in pairs(self._panel:children()) do
				child:hide()
				child:set_alpha(0)
			end
			self._panel:child("item_foreground_layer"):show()
			self._panel:child("item_foreground_layer"):set_alpha(1)
			self._panel:rect({
				name = "background_simple",
				color = Holo:GetColor("Colors/MenuBackground"),
			})	 
		end
	end)
	function MenuBackdropGUI:animate_bg_text(text)
		text:hide()
	end
end