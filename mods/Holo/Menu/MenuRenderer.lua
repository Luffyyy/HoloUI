if Holo.options.Menu_enable then 
function MenuRenderer:show_node( node )
	local gui_class = MenuNodeGui
	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable( node:parameters().gui_class )
	end
	local parameters = { 	
		font = tweak_data.menu.pd2_medium_font,
		row_item_color = Holomenu_color_normal,
		row_item_hightlight_color = Holomenu_color_highlight, 
		row_item_blend_mode = "normal",
		font_size = Holomenu_textsize,
		node_gui_class = gui_class, 
		spacing = node:parameters().spacing,
		marker_alpha = 0.2, 
		marker_color = Holomenu_color_normal,
		align = "right",
		to_upper = true,
	} 
	MenuRenderer.super.show_node( self, node, parameters )
end


function MenuRenderer:_create_bottom_text()
	local scaled_size = managers.gui_data:scaled_size()
	self._bottom_text = self._main_panel:text({ 
		text = "",
		wrap = true, word_wrap = true,
		font_size = tweak_data.menu.pd2_small_font_size,  
		align="right",
		halign="right",
	 	vertical="top",
	 	hvertical="top",
		font = tweak_data.menu.pd2_small_font,
		w = scaled_size.width*0.66,
		layer = 2,
	})
	self._bottom_text:set_right( self._bottom_text:parent():w() )
end
end