core:import("CoreMenuNodeGui")
function MenuNodeGui:init(node, layer, parameters)
	local name = node:parameters().name
	local lang_mods = {}
	lang_mods[Idstring("german"):key()] = name == "kit" and 0.95 or name == "challenges_active" and 0.875 or name == "challenges_awarded" and 0.875 or 0.9
	lang_mods[Idstring("french"):key()] = name == "kit" and 0.975 or name == "challenges_active" and 0.874 or name == "challenges_awarded" and 0.874 or name == "upgrades_support" and 0.875 or 0.9
	lang_mods[Idstring("italian"):key()] = name == "kit" and 0.975 or name == "challenges_active" and 0.875 or name == "challenges_awarded" and 0.875 or 0.95
	lang_mods[Idstring("spanish"):key()] = name == "kit" and 1 or name == "challenges_active" and 0.84 or name == "challenges_awarded" and 0.84 or (name == "upgrades_assault" or name == "upgrades_sharpshooter" or name == "upgrades_support") and 0.975 or 0.925
	lang_mods[Idstring("english"):key()] = name == "challenges_active" and 0.925 or name == "challenges_awarded" and 0.925 or 1
	local mod = lang_mods[SystemInfo:language():key()] or 1
	self._align_line_proportions = node:parameters().align_line_proportions or 0.65
	self._align_line_padding = 10 * tweak_data.scale.align_line_padding_multiplier
	self._use_info_rect = node:parameters().use_info_rect or node:parameters().use_info_rect == nil and true
	self._stencil_align = node:parameters().stencil_align or "right"
	self._stencil_align_percent = node:parameters().stencil_align_percent or 0
	self._stencil_image = node:parameters().stencil_image
	self._scene_state = node:parameters().scene_state
	self._no_menu_wrapper = true
	self._is_loadout = node:parameters().is_loadout
	self._align = node:parameters().align or "mid"
	self._bg_visible = node:parameters().hide_bg
	self._bg_visible = self._bg_visible == nil
	self._bg_area = node:parameters().area_bg
	self._bg_area = not self._bg_area and "full" or self._bg_area
	self.row_item_color = Holomenu_color_normal
	self.row_item_hightlight_color = Holomenu_color_highlight
	self.row_item_disabled_text_color = tweak_data.menu.default_disabled_text_color
	self.item_panel_h = node:parameters().item_panel_h
	MenuNodeGui.super.init(self, node, layer, parameters)
	if node:parameters().no_item_parent then
		self._item_panel_parent:set_visible(false)
	end
end
function MenuNodeGui:_left_align(align_line_proportions)
	local safe_rect = managers.viewport:get_safe_rect_pixels()
	return safe_rect.width * (align_line_proportions or self._align_line_proportions) - self._align_line_padding
end
function MenuNodeGui:_world_left_align()
	local safe_rect = managers.viewport:get_safe_rect_pixels()
	return safe_rect.x + safe_rect.width * self._align_line_proportions - self._align_line_padding
end

function MenuNodeGui:_text_item_part(row_item, panel, align_x, text_align)
	local new_text = panel:text({
		font_size = self.font_size,
		x = align_x,
		y = 0,
		align = text_align or row_item.align or "left",
		halign = "left",
		vertical = "center",
		font = row_item.font,
		color = Holomenu_color_normal,
		layer = self.layers.items,
		blend_mode = "normal",
		text = row_item.to_upper and utf8.to_upper(row_item.text) or row_item.text,
		render_template = Idstring("VertexColorTextured")
	})
	if row_item.color_ranges then
		for _, color_range in ipairs(row_item.color_ranges) do
			new_text:set_range_color(color_range.start, color_range.stop, color_range.color)
		end
	end
	return new_text
end

function MenuNodeGui:_create_marker(node)
	self._marker_data = {}
	self._marker_data.marker = self.item_panel:panel({
		x = 0,
		y = 0,
		w = 1280,
		h = 10,
		layer = self.layers.marker
	})
	self._marker_data.gradient = self._marker_data.marker:bitmap({
		texture = "guis/textures/menu_selected",
		x = 0,
		y = 0,
		layer = 0,
		alpha = Holomenu_markeralpha,
		color = Holomenu_color_highlight
	})
	if self.marker_color ~= tweak_data.screen_colors.button_stage_3 or self.marker_color ~= tweak_data.screen_colors.button_stage_2 then
		self._marker_data.gradient:set_color(self.marker_color)
	end
end

function MenuNodeGui:_create_menu_item(row_item)
	local safe_rect = self:_scaled_size()
	local align_x = safe_rect.width * self._align_line_proportions
	if row_item.gui_panel then
		self.item_panel:remove(row_item.gui_panel)
	end
	if alive(row_item.gui_pd2_panel) then
		row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
	end
	if row_item.item:parameters().back then
		row_item.item:parameters().back = false
		row_item.item:parameters().pd2_corner = true
	end
	if row_item.item:parameters().gui_node_custom then
		self:gui_node_custom(row_item)
	elseif row_item.item:parameters().back then
		row_item.gui_panel = self._item_panel_parent:panel({
			layer = self.layers.items,
			w = 30,
			h = 30
		})
		row_item.unselected = row_item.gui_panel:bitmap({
			visible = false,
			texture = "guis/textures/menu_unselected",
			x = 0,
			y = 0,
			valign = nil,
			halign = nil,
			h = row_item.gui_panel:h(),
			w = row_item.gui_panel:w(),
			layer = -1
		})
		row_item.selected = row_item.gui_panel:bitmap({
			visible = false,
			texture = "guis/textures/menu_selected",
			x = 0,
			y = 0,
			valign = nil,
			halign = nil,
			h = row_item.gui_panel:h(),
			w = row_item.gui_panel:w(),
			layer = 0
		})
		row_item.shadow = row_item.gui_panel:bitmap({
			visible = false,
			texture = "guis/textures/headershadowdown",
			layer = self.layers.items
		})
		row_item.shadow_bottom = row_item.gui_panel:bitmap({
			visible = false,
			texture = "guis/textures/headershadowdown",
			rotation = 180,
			layer = self.layers.items
		})
		row_item.arrow_selected = row_item.gui_panel:bitmap({
			blend_mode = "normal",
			visible = false,
			texture = "guis/textures/menu_arrows",
			texture_rect = {
				0,
				0,
				24,
				24
			},
			x = 0,
			y = 0,
			valign = nil,
			halign = nil,
			h = row_item.gui_panel:w(),
			w = row_item.gui_panel:w(),
			layer = self.layers.items
		})
		row_item.arrow_unselected = row_item.gui_panel:bitmap({
			blend_mode = "normal",
			visible = true,
			texture = "guis/textures/menu_arrows",
			texture_rect = {
				24,
				0,
				24,
				24
			},
			x = 0,
			y = 0,
			valign = nil,
			halign = nil,
			h = row_item.gui_panel:w(),
			w = row_item.gui_panel:w(),
			layer = self.layers.items
		})
	elseif row_item.item:parameters().pd2_corner then
		row_item.gui_panel = self._item_panel_parent:panel({
			layer = self.layers.items,
			w = 3,
			h = 3
		})
		row_item.gui_pd2_panel = self.ws:panel():panel({
			layer = self.layers.items
		})
		local row_item_panel = managers.menu:is_pc_controller() and row_item.gui_pd2_panel or row_item.gui_panel
		row_item.gui_text = row_item_panel:text({
			font_size = self.font_size,
			align = "right",
			halign = "right",
			vertical = "bottom",
			hvertical = "bottom",
			font = row_item.font,
			color = row_item.color,
			layer = self.layers.items,
			text = row_item.text
		})
		local _, _, w, h = row_item.gui_text:text_rect()
		row_item.gui_text:set_size(math.round(w), math.round(h))
		if managers.menu:is_pc_controller() then
			row_item.gui_text:set_rightbottom(row_item.gui_pd2_panel:w(), row_item.gui_pd2_panel:h())
		else
			row_item.gui_text:set_rotation(360)
			row_item.gui_text:set_right(row_item.gui_pd2_panel:w())
		end
		if MenuBackdropGUI and managers.menu:is_pc_controller() then
			local bg_text = row_item.gui_pd2_panel:text({
				text = utf8.to_upper(row_item.text),
				h = 90,
				align = "right",
				vertical = "bottom",
				font_size = tweak_data.menu.pd2_massive_font_size,
				font = tweak_data.menu.pd2_massive_font,
				color = tweak_data.screen_colors.button_stage_3,
				alpha = 0,
				layer = -1,
				rotation = 360
			})
			bg_text:set_right(row_item.gui_text:right())
			bg_text:set_center_y(row_item.gui_text:center_y())
			bg_text:move(13, -9)
			MenuBackdropGUI.animate_bg_text(self, bg_text)
		end
	elseif row_item.type == "level" then
		row_item.gui_panel = self:_text_item_part(row_item, self.item_panel, self:_right_align())
		row_item.gui_panel:set_text(utf8.to_upper(row_item.gui_panel:text()))
		row_item.gui_level_panel = self._item_panel_parent:panel({
			visible = false,
			layer = self.layers.items,
			x = 0,
			y = 0,
			w = self:_left_align(),
			h = self._item_panel_parent:h()
		})
		local level_data = row_item.item:parameters().level_id
		level_data = tweak_data.levels[level_data]
		local description = level_data and level_data.briefing_id and managers.localization:text(level_data.briefing_id) or "Missing description text"
		local image = level_data and level_data.loading_image or "guis/textures/menu/missing_level"
		row_item.level_title = row_item.gui_level_panel:text({
			layer = 1,
			text = utf8.to_upper(row_item.gui_panel:text()),
			font = self.font,
			font_size = self.font_size,
			color = row_item.color,
			align = "left",
			vertical = "top",
			wrap = false,
			word_wrap = false,
			w = 50,
			h = 128
		})
		row_item.level_text = row_item.gui_level_panel:text({
			layer = 1,
			text = utf8.to_upper(description),
			font = tweak_data.menu.small_font,
			font_size = tweak_data.menu.small_font_size,
			color = row_item.color,
			align = "left",
			vertical = "top",
			wrap = true,
			word_wrap = true,
			w = 50,
			h = 128
		})
		self:_align_normal(row_item)
	elseif row_item.type == "chat" then
		row_item.gui_panel = self.item_panel:panel({
			w = self.item_panel:w(),
			h = 100
		})
		row_item.chat_output = row_item.gui_panel:gui(Idstring("guis/chat/textscroll"), {
			layer = self.layers.items,
			h = 120,
			w = 500,
			valign = "grow",
			halign = "grow"
		})
		row_item.chat_input = row_item.gui_panel:gui(Idstring("guis/chat/chat_input"), {
			h = 25,
			w = 500,
			layer = self.layers.items,
			valign = "bottom",
			halign = "grow",
			y = 125
		})
		row_item.chat_input:script().enter_callback = callback(self, self, "_cb_chat", row_item)
		row_item.chat_input:script().esc_callback = callback(self, self, "_cb_unlock", row_item)
		row_item.chat_input:script().typing_callback = callback(self, self, "_cb_lock", row_item)
		row_item.border = row_item.gui_panel:rect({
			visible = false,
			layer = self.layers.items,
			color = tweak_data.hud.prime_color,
			w = 800,
			h = 2
		})
		self:_align_chat(row_item)
	elseif row_item.type == "friend" then
		local cot_align = row_item.align == "right" and "left" or row_item.align == "left" and "right" or row_item.align
		row_item.gui_panel = self.item_panel:panel({
			w = self.item_panel:w()
		})
		row_item.color_mod = (row_item.item:parameters().signin_status == "uninvitable" or row_item.item:parameters().signin_status == "not_signed_in") and 0.75 or 1
		row_item.friend_name = self:_text_item_part(row_item, row_item.gui_panel, self:_right_align())
		row_item.friend_name:set_color(row_item.friend_name:color() * row_item.color_mod)
		row_item.signin_status = self:_text_item_part(row_item, row_item.gui_panel, self:_left_align())
		row_item.signin_status:set_align(cot_align)
		row_item.signin_status:set_color(row_item.signin_status:color() * row_item.color_mod)
		local status_text = managers.localization:text("menu_friends_" .. row_item.item:parameters().signin_status)
		row_item.signin_status:set_text(utf8.to_upper(status_text))
		self:_align_friend(row_item)
	elseif row_item.type == "weapon_expand" or row_item.type == "weapon_upgrade_expand" then
		row_item.item:setup_gui(self, row_item)
	elseif not row_item.item:setup_gui(self, row_item) then
		local cot_align = row_item.align == "right" and "left" or row_item.align == "left" and "right" or row_item.align
		row_item.gui_panel = self:_text_item_part(row_item, self.item_panel, self:_right_align() + (row_item.is_expanded and 20 or 0))
		row_item.current_of_total = self:_text_item_part(row_item, self.item_panel, self:_right_align(), cot_align)
		row_item.current_of_total:set_font_size(20)
		row_item.current_of_total:set_visible(false)
		if row_item.item:parameters().current then
			row_item.current_of_total:set_visible(true)
			row_item.current_of_total:set_color(row_item.color)
			row_item.current_of_total:set_text("(" .. row_item.item:parameters().current .. "/" .. row_item.item:parameters().total .. ")")
		end
		if row_item.help_text then
		end
		if row_item.item:parameters().trial_buy then
			self:_setup_trial_buy(row_item)
		end
		if row_item.item:parameters().fake_disabled then
			self:_setup_fake_disabled(row_item)
		end
		self:_align_normal(row_item)
	end
	local visible = row_item.item:menu_unselected_visible(self, row_item) and not row_item.item:parameters().back
	row_item.menu_unselected = self.item_panel:bitmap({
		visible = false,
		texture = "guis/textures/menu_unselected",
		x = 0,
		y = 0,
		layer = self.layers.items - 2
	})
	row_item.menu_unselected:set_color(row_item.item:parameters().is_expanded and Color(0.5, 0.5, 0.5) or Color.white)
end

function MenuNodeGui:_align_marker(row_item)
	if self.marker_color or row_item.marker_color then
		self._marker_data.gradient:set_color(row_item.item:enabled() and Holomenu_color_marker or row_item.disabled_color)
		self._marker_data.gradient:set_alpha(Holomenu_markeralpha)
	end
	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_visible(true)
		self._marker_data.gradient:set_visible(true)
		self._marker_data.gradient:set_rotation(360)
		self._marker_data.marker:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.gradient:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.marker:set_w(self:_scaled_size().width - row_item.menu_unselected:x())
		self._marker_data.gradient:set_w(self._marker_data.marker:w())
		self._marker_data.marker:set_world_right(row_item.gui_text:world_right())
		self._marker_data.marker:set_world_center_y(row_item.gui_text:world_center_y() - 2)
		return
	end
	self._marker_data.marker:show()
	self._marker_data.gradient:set_rotation(0)
	self._marker_data.marker:set_height(64 * row_item.gui_panel:height() / 32)
	self._marker_data.gradient:set_height(64 * row_item.gui_panel:height() / 32)
	self._marker_data.marker:set_left(row_item.menu_unselected:x())
	self._marker_data.marker:set_center_y(row_item.gui_panel:center_y())
	local item_enabled = row_item.item:enabled()
	if item_enabled then
	else
	end
	if row_item.item:parameters().back then
		self._marker_data.marker:set_visible(false)
	else
		self._marker_data.marker:set_visible(true)
		if self._marker_data.back_marker then
			self._marker_data.back_marker:set_visible(false)
		end
	end
	if row_item.type == "upgrade" then
		self._marker_data.marker:set_left(self:_mid_align())
	elseif row_item.type == "friend" then
		if row_item.align == "right" then
			self._marker_data.marker:move(-100, 0)
		else
			local _, _, w, _ = row_item.signin_status:text_rect()
			self._marker_data.marker:set_left(self:_left_align() - w - self._align_line_padding)
		end
	elseif row_item.type == "server_column" then
		self._marker_data.marker:set_left(row_item.gui_panel:x())
	elseif row_item.type == "customize_controller" then
	else
		if row_item.type == "nothing" then
			if row_item.type == "slider" then
				self._marker_data.marker:set_left(self:_left_align() - row_item.gui_slider:width())
			elseif row_item.type == "kitslot" or row_item.type == "multi_choice" then
				if row_item.choice_panel then
					self._marker_data.marker:set_left(row_item.arrow_left:left() - self._align_line_padding + row_item.gui_panel:x())
				end
			elseif row_item.type == "toggle" then
				if row_item.gui_option then
					local x, y, w, h = row_item.gui_option:text_rect()
					self._marker_data.marker:set_left(self:_left_align() - w - self._align_line_padding + row_item.gui_panel:x())
				else
					self._marker_data.marker:set_left(row_item.gui_icon:x() - self._align_line_padding + row_item.gui_panel:x())
				end
			end
		else
		end
	end
	if row_item.type == "slider" then
		self._marker_data.marker:set_visible(false)
	end
	self._marker_data.marker:set_w(self:_scaled_size().width - self._marker_data.marker:left())
	self._marker_data.gradient:set_w(self._marker_data.marker:w())
	self._marker_data.gradient:set_visible(true)
	if row_item.type == "chat" then
		self._marker_data.gradient:set_visible(false)
	end
end
function MenuNodeGui:_align_normal(row_item)
	local safe_rect = self:_scaled_size()
	row_item.gui_panel:set_font_size(row_item.font_size or self.font_size)
	local x, y, w, h = row_item.gui_panel:text_rect()
	row_item.gui_panel:set_height(h)
	row_item.gui_panel:set_left(self:_right_align() + (row_item.item:parameters().expand_value or 0))
	row_item.gui_panel:set_w(safe_rect.width - row_item.gui_panel:left())
	if row_item.gui_info_panel then
		self:_align_info_panel(row_item)
	end
end
function MenuNodeGui:_highlight_row_item(row_item, mouse_over)
	if row_item then
		row_item.highlighted = true
		local active_menu = managers.menu:active_menu()
		if active_menu then
			active_menu.renderer:set_bottom_text(row_item.item:parameters().help_id, row_item.item:parameters().localize_help ~= false)
		end
		self:_align_marker(row_item)
		row_item.color = self.row_item_hightlight_color
		if row_item.type == "NOTHING" then
		elseif row_item.type == "column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
		elseif row_item.type == "server_column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
			row_item.gui_info_panel:set_visible(true)
		elseif row_item.type == "level" then
			row_item.gui_level_panel:set_visible(true)
			MenuNodeGui.super._highlight_row_item(self, row_item)
		elseif row_item.type == "friend" then
			row_item.friend_name:set_color(row_item.color)
			row_item.friend_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
			row_item.signin_status:set_color(row_item.color)
			row_item.signin_status:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
		elseif row_item.type == "chat" then
			self.ws:connect_keyboard(Input:keyboard())
			row_item.border:set_visible(true)
			if not mouse_over then
				row_item.chat_input:script().set_focus(true)
			end
		elseif row_item.type == "weapon_expand" or row_item.type == "weapon_upgrade_expand" then
			row_item.item:highlight_row_item(self, row_item, mouse_over)
		elseif row_item.item:parameters().back then
			row_item.arrow_selected:set_visible(true)
			row_item.arrow_unselected:set_visible(false)
		elseif row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(self.row_item_hightlight_color)
		elseif not row_item.item:highlight_row_item(self, row_item, mouse_over) then
			if row_item.gui_panel.set_text then
				row_item.gui_panel:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
			end
			if row_item.gui_info_panel then
				row_item.gui_info_panel:set_visible(true)
			end	
			if row_item.color_ranges then
				row_item.gui_panel:clear_range_color(0, 99)
			end
			row_item.gui_panel:set_color(row_item.color)
		end
		local active_menu = managers.menu:active_menu()
		if active_menu then
			if row_item.item:parameters().stencil_image then
				active_menu.renderer:set_stencil_image(row_item.item:parameters().stencil_image)
			else
				active_menu.renderer:set_stencil_image(self._stencil_image)
			end
		end
	end
end
function MenuNodeGui:_fade_row_item(row_item)
	if row_item then
		row_item.highlighted = false
		row_item.color =  row_item.item:enabled() and (row_item.row_item_color or self.row_item_color) or self.row_item_disabled_text_color
		if row_item.type == "NOTHING" then
		elseif row_item.type == "column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
		elseif row_item.type == "server_column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
			row_item.gui_info_panel:set_visible(false)
		elseif row_item.type == "level" then
			row_item.gui_level_panel:set_visible(false)
			MenuNodeGui.super._fade_row_item(self, row_item)
		elseif row_item.type == "friend" then
			row_item.friend_name:set_color(row_item.color * row_item.color_mod)
			row_item.friend_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
			row_item.signin_status:set_color(row_item.color * row_item.color_mod)
			row_item.signin_status:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
		elseif row_item.type == "chat" then
			row_item.border:set_visible(false)
			row_item.chat_input:script().set_focus(false)
			self.ws:disconnect_keyboard()
		elseif row_item.type == "weapon_expand" or row_item.type == "weapon_upgrade_expand" then
			row_item.item:fade_row_item(self, row_item)
		elseif row_item.item:parameters().back then
			row_item.arrow_selected:set_visible(false)
			row_item.arrow_unselected:set_visible(true)
		elseif row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(self.row_item_color)
		elseif not row_item.item:fade_row_item(self, row_item) then
			if row_item.gui_panel.set_text then
				row_item.gui_panel:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
			end
			if row_item.gui_info_panel then
				row_item.gui_info_panel:set_visible(false)
			end
			if row_item.color_ranges then
				for _, color_range in ipairs(row_item.color_ranges) do
					row_item.gui_panel:set_range_color(color_range.start, color_range.stop, color_range.color)
				end
			end
			row_item.gui_panel:set_color(row_item.color)
		end
	end
end
function MenuNodeGui:reload_item(item)
	local type = item:type()
	local row_item = self:row_item(item)
	if row_item then
		row_item.color =  row_item.highlighted and (row_item.hightlight_color or self.row_item_hightlight_color) or item:enabled() and (row_item.row_item_color or self.row_item_color) or self.row_item_disabled_text_color
	end
	if not item:reload(row_item, self) then
		if type == "weapon_expand" or type == "weapon_upgrade_expand" then
			self:_reload_expand(item)
		elseif type == "expand" then
			self:_reload_expand(item)
		elseif type == "friend" then
			self:_reload_friend(item)
		else
			MenuNodeGui.super.reload_item(self, item)
		end
	end
	if self._highlighted_item and self._highlighted_item == item and row_item then
		self:_align_marker(row_item)
	end
end

