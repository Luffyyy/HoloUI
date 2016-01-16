if Holo.options.Menu_enable then
core:import("CoreMenuItem")
core:import("CoreMenuItemOption")
MenuItemMultiChoice.TYPE = "multi_choice"
MenuItemMultiChoice = MenuItemMultiChoice or class(CoreMenuItem.Item)

function MenuItemMultiChoice:setup_gui(node, row_item)
	local right_align = node._right_align(node)
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.gui_text = node._text_item_part(node, row_item, row_item.gui_panel, right_align, row_item.align)
	row_item.gui_text:set_wrap(true)
	row_item.gui_text:set_word_wrap(true)
	local choice_text_align = row_item.align == "left" and "right" or row_item.align == "right" and "left" or row_item.align
	row_item.choice_panel = row_item.gui_panel:panel({
		w = node.item_panel:w()
	})
	row_item.choice_text = row_item.choice_panel:text({
		font_size = row_item.font_size,
		x = 0,
		y = 0,
		align = "center",
		vertical = "center",
		font = row_item.font,
		color = node.row_item_hightlight_color,
		layer = node.layers.items,
		blend_mode = node.row_item_blend_mode,
		text = utf8.to_upper(""),
		render_template = Idstring("VertexColorTextured")
	})
	local w = 20
	local h = 20
	local base = 20
	local height = 15
	row_item.arrow_left = row_item.gui_panel:bitmap({
		texture = "guis/textures/menu_arrows",
		texture_rect = {
			0,
			0,
			24,
			24
		},
		color = Color(0.5, 0.5, 0.5),
		visible = self:arrow_visible(),
		x = 0,
		y = 0,
		layer = node.layers.items,
		blend_mode = node.row_item_blend_mode
	})
	row_item.color_preview = row_item.gui_panel:bitmap({
		color = Color.white,
		alpha = HoloAlpha,
		visible = false,
		w = row_item.font_size - 4,
		h = row_item.font_size - 4,
		x = 0,
		y = 2,
		layer = node.layers.items,
	})
	row_item.arrow_right = row_item.gui_panel:bitmap({
		texture = "guis/textures/menu_arrows",
		texture_rect = {
			24,
			0,
			-24,
			24
		},
		color = Color(0.5, 0.5, 0.5),
		visible = self:arrow_visible(),
		x = 0,
		y = 0,
		layer = node.layers.items,
		blend_mode = node.row_item_blend_mode
	})
	if self:info_panel() == "lobby_campaign" then
		node._create_lobby_campaign(node, row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node._create_lobby_difficulty(node, row_item)
	elseif row_item.help_text then
	end
	self:_layout(node, row_item)
	return true
end

function MenuItemMultiChoice:reload(row_item, node)
	if not row_item then
		return
	end
	if node.localize_strings and self:selected_option():parameters().localize ~= false then
		row_item.option_text = managers.localization:text(self:selected_option():parameters().text_id)
	else
		row_item.option_text = self:selected_option():parameters().text_id
	end
	row_item.choice_text:set_text(utf8.to_upper(row_item.option_text))
	if self:selected_option():parameters().stencil_image then
		managers.menu:active_menu().renderer:set_stencil_image(self:selected_option():parameters().stencil_image)
	end
	if self:selected_option():parameters().stencil_align then
		managers.menu:active_menu().renderer:set_stencil_align(self:selected_option():parameters().stencil_align, self:selected_option():parameters().stencil_align_percent)
	end
	local arrow_alpha = row_item.highlighted and 1 or 0.5
	row_item.arrow_left:set_visible(self:arrow_visible())
	row_item.arrow_right:set_visible(self:arrow_visible())
	row_item.arrow_left:set_color(row_item.highlighted and Holomenu_color_highlight or Holomenu_color_normal)
	row_item.arrow_right:set_color(row_item.highlighted and Holomenu_color_highlight or Holomenu_color_normal)
	row_item.arrow_left:set_alpha(self:left_arrow_visible() and 1 or 0.5)
	row_item.arrow_right:set_alpha(self:right_arrow_visible() and 1 or 0.5)
	row_item.gui_text:set_color(row_item.color)
	row_item.choice_text:set_color(row_item.color)
	row_item.choice_text:set_alpha(self._enabled and 1 or 0.75)
	if self:info_panel() == "lobby_campaign" then
		node._reload_lobby_campaign(node, row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node._reload_lobby_difficulty(node, row_item)
	end
	local color = self:selected_option():parameters().color1
	if color then
		local count = 1
		while color do
			row_item.choice_text:set_range_color(self:selected_option():parameters()["color_start" .. count], self:selected_option():parameters()["color_stop" .. count], color)
			count = count + 1
			color = self:selected_option():parameters()["color" .. count]
		end
	end
	return true
end
local xl_pad = 64
function MenuItemMultiChoice:_layout(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()
	local right_align = node._right_align(node)
	local left_align = node._left_align(node)
	if self:parameters().filter then
	end
	row_item.gui_panel:set_width(safe_rect.width - node._mid_align(node))
	row_item.gui_panel:set_x(node._mid_align(node))
	local arrow_size = 24 * tweak_data.scale.multichoice_arrow_multiplier
	row_item.arrow_right:set_size(arrow_size, arrow_size)
	row_item.arrow_left:set_size(arrow_size, arrow_size)
	if row_item.align == "right" then
		row_item.arrow_left:set_left(right_align - row_item.gui_panel:x() + (self:parameters().expand_value or 0))
		row_item.arrow_right:set_left(row_item.arrow_left:right() + 2 * (1 - tweak_data.scale.multichoice_arrow_multiplier))
	else
		row_item.arrow_right:set_right(row_item.gui_panel:w())
		row_item.arrow_left:set_right(row_item.arrow_right:left() + 2 * (1 - tweak_data.scale.multichoice_arrow_multiplier))
	end
	row_item.color_preview:set_right(row_item.arrow_left:right() + 30)
	local x, y, w, h = row_item.gui_text:text_rect()
	row_item.gui_text:set_h(h)
	row_item.gui_text:set_width(w + 5)
	if h == 0 then
		h = row_item.font_size
		row_item.choice_panel:set_w(row_item.gui_panel:width() - (arrow_size + node._align_line_padding) * 2)
	else
		row_item.choice_panel:set_w(row_item.gui_panel:width() * 0.4 + (self:parameters().text_offset or 0))
	end
	row_item.choice_panel:set_h(h)
	if row_item.align == "right" then
		row_item.choice_panel:set_left(row_item.arrow_left:right() + node._align_line_padding)
		row_item.arrow_right:set_left(row_item.choice_panel:right())
	else
		row_item.choice_panel:set_right(row_item.arrow_right:left() - node._align_line_padding)
		row_item.arrow_left:set_right(row_item.choice_panel:left())
	end
	row_item.choice_text:set_w(row_item.choice_panel:w())
	row_item.choice_text:set_h(h)
	row_item.choice_text:set_left(0)
	row_item.arrow_right:set_center_y(row_item.choice_panel:center_y())
	row_item.arrow_left:set_center_y(row_item.choice_panel:center_y())
	if row_item.align == "right" then
		row_item.gui_text:set_right(row_item.gui_panel:w())
	else
		row_item.gui_text:set_left(node._right_align(node) - row_item.gui_panel:x() + (self:parameters().expand_value or 0))
	end
	row_item.gui_text:set_height(h)
	row_item.gui_panel:set_height(h)
	if row_item.gui_info_panel then
		node._align_item_gui_info_panel(node, row_item.gui_info_panel)
		if self:info_panel() == "lobby_campaign" then
			node._align_lobby_campaign(node, row_item)
		elseif self:info_panel() == "lobby_difficulty" then
			node._align_lobby_difficulty(node, row_item)
		else
			node._align_info_panel(node, row_item)
		end
	end
	return true
end
function MenuItemMultiChoice:highlight_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_color(row_item.color)
	row_item.choice_text:set_color(row_item.color)
	row_item.choice_text:set_alpha(self._enabled and 1 or 0.75)
	row_item.arrow_left:set_image("guis/textures/menu_arrows", 24, 0, 24, 24)
	row_item.arrow_right:set_image("guis/textures/menu_arrows", 48, 0, -24, 24)
	row_item.arrow_left:set_color(Holomenu_color_highlight)
	row_item.arrow_right:set_color(Holomenu_color_highlight)
	row_item.arrow_left:set_alpha(self:left_arrow_visible() and 1 or 0.5)
	row_item.arrow_right:set_alpha(self:right_arrow_visible() and 1 or 0.5)
	if self:info_panel() == "lobby_campaign" then
		node._highlight_lobby_campaign(node, row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node._highlight_lobby_difficulty(node, row_item)
	elseif row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(true)
	end
	return true
end
function MenuItemMultiChoice:fade_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_color(row_item.color)
	row_item.choice_text:set_color(row_item.color)
	row_item.choice_text:set_alpha(self._enabled and 1 or 0.75)
	row_item.arrow_left:set_image("guis/textures/menu_arrows", 0, 0, 24, 24)
	row_item.arrow_right:set_image("guis/textures/menu_arrows", 24, 0, -24, 24)
	row_item.arrow_left:set_color(Holomenu_color_normal)
	row_item.arrow_right:set_color(Holomenu_color_normal)
	row_item.arrow_left:set_alpha(self:left_arrow_visible() and 1 or 0.5)
	row_item.arrow_right:set_alpha(self:right_arrow_visible() and 1 or 0.5)
	if self:info_panel() == "lobby_campaign" then
		node._fade_lobby_campaign(node, row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node._fade_lobby_difficulty(node, row_item)
	elseif row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(false)
	end
	return true
end
end