
core:module("CoreMenuItemSlider")
core:import("CoreMenuItem")
ItemSlider = ItemSlider or class(CoreMenuItem.Item)
ItemSlider.TYPE = "slider"
function ItemSlider:highlight_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_font(row_item.font and Idstring(row_item.font) or _G.tweak_data.menu.default_font_no_outline_id)
	row_item.gui_slider_text:set_font(row_item.font and Idstring(row_item.font) or _G.tweak_data.menu.default_font_no_outline_id)
	if _G.Holo.options.Menu_enable then
		row_item.gui_slider_gfx:set_gradient_points({
			0,
			_G.Holo.colors[_G.Holo.options.Menu_markercolor].color,
			1,
			_G.Holo.colors[_G.Holo.options.Menu_markercolor].color
		})
    else
    	row_item.gui_slider_gfx:set_gradient_points({
			0,
			_G.tweak_data.screen_colors.button_stage_2,
			1,
			_G.tweak_data.screen_colors.button_stage_2
		})
		row_item.gui_slider_text:set_color(row_item.color)
		row_item.gui_text:set_color(row_item.color)
    end
	if row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(true)
	end
	return true
end

function ItemSlider:fade_row_item(node, row_item)
	row_item.gui_text:set_font(row_item.font and Idstring(row_item.font) or _G.tweak_data.menu.default_font_id)
	row_item.gui_slider_text:set_font(row_item.font and Idstring(row_item.font) or _G.tweak_data.menu.default_font_id)
	if _G.Holo.options.Menu_enable then
	row_item.gui_slider_gfx:set_gradient_points({
		0,
		_G.Holo.colors[_G.Holo.options.Menu_markercolor].color,
		1,
		_G.Holo.colors[_G.Holo.options.Menu_markercolor].color
	})
    else
	row_item.gui_slider_gfx:set_gradient_points({
		0,
		_G.tweak_data.screen_colors.button_stage_3,
		1,
		_G.tweak_data.screen_colors.button_stage_3

	})		
	    row_item.gui_slider_text:set_color(row_item.color)
		row_item.gui_text:set_color(row_item.color)
    end
	if row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(false)
	end
	return true
end

function ItemSlider:_layout(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()
	row_item.gui_text:set_font_size(node.font_size)
	local x, y, w, h = row_item.gui_text:text_rect()
	local bg_pad = 8
	local xl_pad = 64
	row_item.gui_panel:set_height(h)
	row_item.gui_panel:set_width(safe_rect.width - node._mid_align(node))
	row_item.gui_panel:set_x(node._mid_align(node))
	local sh = h - 2
	row_item.gui_slider_bg:set_h(sh)
	row_item.gui_slider_bg:set_w(row_item.gui_panel:w())
	row_item.gui_slider_bg:set_x(0)
	row_item.gui_slider_bg:set_center_y(h / 2)
		
	row_item.gui_slider_text:set_font_size(node.font_size)
	row_item.gui_slider_text:set_size(row_item.gui_slider_bg:size())
	row_item.gui_slider_text:set_position(row_item.gui_slider_bg:position())
	row_item.gui_slider_text:set_y(row_item.gui_slider_text:y())
	if row_item.align == "right" then
		row_item.gui_slider_text:set_left(node._right_align(node) - row_item.gui_panel:x())
	else
		row_item.gui_slider_text:set_x(row_item.gui_slider_text:x() - node.align_line_padding(node))
	end
	row_item.gui_slider_gfx:set_h(sh)
	row_item.gui_slider_gfx:set_x(row_item.gui_slider_bg:x())
	row_item.gui_slider_gfx:set_y(row_item.gui_slider_bg:y())
	row_item.gui_slider:set_x(row_item.gui_slider_bg:x())
	row_item.gui_slider:set_y(row_item.gui_slider_bg:y())
	row_item.gui_slider:set_w(row_item.gui_slider_bg:w())
	row_item.gui_slider_marker:set_center_y(h / 2)
	row_item.gui_text:set_width(safe_rect.width / 2)
	if row_item.align == "right" then
		row_item.gui_text:set_right(row_item.gui_panel:w())
	else
		row_item.gui_text:set_left(node._right_align(node) - row_item.gui_panel:x())
	end
	row_item.gui_text:set_height(h)
	if _G.Holo.options.Menu_enable then
		row_item.gui_slider_bg:set_visible(true)
		row_item.gui_slider_bg:set_color(_G.Holo.colors[_G.Holo.options.Menu_markercolor].color:with_alpha(0.2))
		row_item.gui_slider_gfx:set_gradient_points({
			0,
			_G.Holo.colors[_G.Holo.options.Menu_markercolor].color,
			1,
			_G.Holo.colors[_G.Holo.options.Menu_markercolor].color
		})
    end
end

