if Holo.Options:GetValue("Menu") then	 
	core:module("CoreMenuItemSlider")
	core:import("CoreMenuItem")
	ItemSlider = ItemSlider or class(CoreMenuItem.Item)
	local Holo = _G.Holo
	Holo:Post(ItemSlider, "setup_gui", function(self, node, row_item)
		self:set_slider_color(_G.tweak_data.screen_colors.button_stage_2:with_alpha(0.5))
		row_item.gui_slider_gfx:set_gradient_points({0, self._slider_color, 1, self._slider_color})
	end)	
	Holo:Post(ItemSlider, "fade_row_item", function(self, node, row_item)
		local col = _G.tweak_data.screen_colors.button_stage_2:with_alpha(0.25)
		row_item.gui_slider_gfx:set_gradient_points({0, self._slider_color, 1, self._slider_color})
	end)
	Holo:Post(ItemSlider, "highlight_row_item", function(self, node, row_item)
		row_item.gui_text:set_color(node.row_item_color)
		row_item.gui_slider_text:set_color(node.row_item_color)
	end)
end
