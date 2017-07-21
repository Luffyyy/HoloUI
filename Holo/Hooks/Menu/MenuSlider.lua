if Holo.Options:GetValue("Menu") then	 
	core:module("CoreMenuItemSlider")
	core:import("CoreMenuItem")
	ItemSlider = ItemSlider or class(CoreMenuItem.Item)
	_G.Hooks:PostHook(ItemSlider, "setup_gui", "HoloSetupGUI", function(self, node, row_item)
		local col = _G.tweak_data.screen_colors.button_stage_2
		row_item.gui_slider_gfx:set_gradient_points({0, col, 1, col})
	end)	
	_G.Hooks:PostHook(ItemSlider, "fade_row_item", "HoloFadeRowItem", function(self, node, row_item)
		local col = _G.tweak_data.screen_colors.button_stage_2
		row_item.gui_slider_gfx:set_gradient_points({0, col, 1, col})
	end)
	_G.Hooks:PostHook(ItemSlider, "highlight_row_item", "HoloHighlightRowItem", function(self, node, row_item)
		row_item.gui_text:set_color(node.row_item_color)
		row_item.gui_slider_text:set_color(node.row_item_color)
	end)
end
