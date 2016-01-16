if Holo.options.Menu_enable then
 
MenuNodeUpdatesGui.PADDING = 10

function MenuNodeUpdatesGui:setup()
	self:unretrieve_textures()
	self._next_page_highlighted = nil
	self._prev_page_highlighted = nil
	self._back_button_highlighted = nil
	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui") or ws:panel():panel({
		name = "MenuNodeUpdatesGui"
	})
	self._panel = panel
	panel:clear()
	local title_text = managers.localization:to_upper_text(self._tweak_data.title_id or "menu_content_updates")
	panel:text({
		text = title_text,
		align = "left",
		vertical = "top",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local back_button = panel:text({
		name = "back_button",
		text = managers.localization:to_upper_text("menu_back"),
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = Holomenu_color_normal
	})
	self:make_fine_text(back_button)
	back_button:set_right(panel:w())
	back_button:set_bottom(panel:h())
	back_button:set_visible(managers.menu:is_pc_controller())
	self._back_marker = self._panel:bitmap({
		color = Holomenu_color_marker,
		alpha = Holomenu_markeralpha,
		visible = false,
		layer = back_button:layer() - 1
	})
	x,y,w,h = back_button:text_rect()
	self._back_marker:set_shape(x,y,313,h)
	self._back_marker:set_right(x + w)
	if MenuBackdropGUI then
		local bg_text = panel:text({
			text = title_text,
			align = "left",
			vertical = "top",
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color =  Holomenu_color_normal,
			alpha = 0.4,
			layer = -1,
			rotation = 360
		})
		self:make_fine_text(bg_text)
		bg_text:move(-13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_text)
	end
	self._requested_textures = {}
	local num_previous_updates = self._tweak_data.num_items or 5
	local current_page = self._node:parameters().current_page or 1
	local start_number = (current_page - 1) * num_previous_updates
	local content_updates = self._tweak_data.item_list or {}
	local previous_updates = {}
	local latest_update = content_updates[#content_updates - start_number]
	for i = #content_updates - start_number, math.max(#content_updates - num_previous_updates - start_number + 1, 1), -1 do
		table.insert(previous_updates, content_updates[i])
	end
	self._lastest_content_update = latest_update
	self._previous_content_updates = previous_updates
	self._num_previous_updates = num_previous_updates
	local latest_update_panel = panel:panel({
		name = "lastest_content_update",
		w = panel:w() / 2,
		h = panel:w() / 4,
		x = 0,
		y = 70
	})
	if SystemInfo:platform() ~= Idstring("WIN32") then
		latest_update_panel:set_w(latest_update_panel:w() * 0.8)
		latest_update_panel:set_h(latest_update_panel:w() * 0.5)
	end
	local selected = BoxGuiObject:new(latest_update_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
	BoxGuiObject:new(latest_update_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._selects = {}
	self._selects[latest_update.id] = selected
	self._select_x = 1
	local w = panel:w()
	local padding = SystemInfo:platform() == Idstring("WIN32") and 30 or 5
	local dech_panel_h = SystemInfo:platform() == Idstring("WIN32") and latest_update_panel:h() or panel:h() / 2
	local latest_desc_panel = panel:panel({
		name = "latest_description",
		w = panel:w() - latest_update_panel:w() - padding,
		h = dech_panel_h,
		x = latest_update_panel:right() + padding,
		y = latest_update_panel:top()
	})
	BoxGuiObject:new(latest_desc_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local title_string = latest_update.name_id and managers.localization:to_upper_text(latest_update.name_id) or self:_get_db_text(latest_update.id, "title") or ""
	local date_string = latest_update.date_id and managers.localization:to_upper_text(latest_update.date_id) or self:_get_db_text(latest_update.id, "date") or ""
	local desc_string = latest_update.desc_id and managers.localization:text(latest_update.desc_id) or self:_get_db_text(latest_update.id, "desc") or ""
	local title_text = latest_desc_panel:text({
		name = "title_text",
		text = title_string,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.text,
		x = self.PADDING,
		y = self.PADDING
	})
	local date_text = latest_desc_panel:text({
		name = "date_text",
		text = date_string,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text,
		x = self.PADDING
	})
	local desc_text = latest_desc_panel:text({
		name = "desc_text",
		text = desc_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		x = self.PADDING,
		wrap = true,
		word_wrap = true
	})
	do
		local x, y, w, h = title_text:text_rect()
		title_text:set_size(w, h)
	end
	do
		local x, y, w, h = date_text:text_rect()
		date_text:set_size(w, h)
		date_text:set_top(title_text:bottom())
	end
	desc_text:set_top(date_text:bottom())
	desc_text:set_size(latest_desc_panel:w() - self.PADDING * 2, latest_desc_panel:h() - desc_text:top() - self.PADDING)
	if self._tweak_data.button then
		local top_button = panel:panel({
			name = "top_button",
			w = 32,
			h = 32
		})
		local w, h = 0, 0
		if self._tweak_data.button.text_id then
			local text = top_button:text({
				text = managers.localization:to_upper_text(self._tweak_data.button.text_id),
				align = "right",
				vertical = "top",
				font_size = tweak_data.menu.pd2_medium_font_size,
				font = tweak_data.menu.pd2_medium_font,
				color = tweak_data.screen_colors.button_stage_3,
				halign = "right",
				valign = "top"
			})
			local _, _, tw, th = self:make_fine_text(text)
			text:set_top(0)
			text:set_right(top_button:w())
			w = math.max(w, tw)
			h = math.max(h, th)
		end
		if self._tweak_data.button.image then
			local bitmap = top_button:bitmap({
				texture = self._tweak_data.button.image,
				color = tweak_data.screen_colors.button_stage_3,
				halign = "right",
				valign = "top"
			})
			bitmap:set_top(0)
			bitmap:set_right(top_button:w())
			w = math.max(w, bitmap:w())
			h = math.max(h, bitmap:h())
		end
		top_button:set_size(w, h)
		top_button:set_bottom(latest_desc_panel:top())
		top_button:set_right(panel:w())
	end
	local small_width = w / num_previous_updates - self.PADDING * 2
	local previous_updates_panel = panel:panel({
		name = "previous_content_updates",
		w = w,
		h = small_width / 2 + self.PADDING * 2,
		x = 0,
		y = math.max(latest_update_panel:bottom(), latest_desc_panel:bottom()) + 30
	})
	local previous_update_text = panel:text({
		name = "previous_update_text",
		text = self._tweak_data.choice_id and managers.localization:to_upper_text(self._tweak_data.choice_id) or "",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})
	self:make_fine_text(previous_update_text)
	previous_update_text:set_leftbottom(previous_updates_panel:left(), previous_updates_panel:top())
	local data
	self._previous_update_texts = {}
	for index, data in ipairs(previous_updates) do
		local w = small_width
		local h = small_width / 2
		local x = self.PADDING + (index - 1) * (w + self.PADDING * 2)
		local y = self.PADDING
		local content_panel = previous_updates_panel:panel({
			name = data.id,
			w = w,
			h = h,
			x = x,
			y = y
		})
		local texture_count = managers.menu_component:request_texture(data.image, callback(self, self, "texture_done_clbk", content_panel))
		table.insert(self._requested_textures, {
			texture_count = texture_count,
			texture = data.image
		})
		local text_string = data.name_id and managers.localization:to_upper_text(data.name_id) or self:_get_db_text(data.id, "desc") or " "
		local text = panel:text({
			name = data.name_id,
			text = text_string,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
		self:make_fine_text(text)
		if index == 1 then
			previous_updates_panel:grow(0, text:h() + self.PADDING * 0.5)
		end
		text:set_world_x(content_panel:world_x())
		text:set_bottom(previous_updates_panel:bottom() - self.PADDING + 1)
		self._previous_update_texts[data.id] = text
		local selected = BoxGuiObject:new(content_panel, {
			sides = {
				2,
				2,
				2,
				2
			}
		})
		self._selects[data.id] = selected
	end
	BoxGuiObject:new(previous_updates_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	for i, box in pairs(self._selects) do
		box:hide()
	end
	self:set_latest_content(latest_update, true)
	self._current_page = current_page
	self._num_pages = math.ceil(#content_updates / num_previous_updates)
	if num_previous_updates < #content_updates then
		local num_pages = self._num_pages
		self._prev_page = panel:panel({
			name = "previous_page",
			w = tweak_data.menu.pd2_medium_font_size,
			h = tweak_data.menu.pd2_medium_font_size
		})
		self._next_page = panel:panel({
			name = "next_page",
			w = tweak_data.menu.pd2_medium_font_size,
			h = tweak_data.menu.pd2_medium_font_size
		})
		local prev_text = self._prev_page:text({
			name = "text_obj",
			text = managers.menu:is_pc_controller() and "<" or managers.localization:get_default_macro("BTN_BOTTOM_L"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			align = "center",
			vertical = "center"
		})
		local next_text = self._next_page:text({
			name = "text_obj",
			text = managers.menu:is_pc_controller() and ">" or managers.localization:get_default_macro("BTN_BOTTOM_R"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			align = "center",
			vertical = "center"
		})
		local page_text = panel:text({
			text = tostring(current_page) .. "/" .. tostring(num_pages),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			align = "center",
			vertical = "center"
		})
		self:make_fine_text(page_text)
		self._next_page:set_right(previous_updates_panel:right() - 10)
		self._next_page:set_bottom(previous_updates_panel:top() - 10)
		self._prev_page:set_right(self._next_page:left() - page_text:w() - 8)
		self._prev_page:set_bottom(self._next_page:bottom())
		page_text:set_center((self._prev_page:right() + self._next_page:left()) / 2, self._next_page:center_y() + 3)
		prev_text:set_color(not managers.menu:is_pc_controller() and Color.white or current_page > 1 and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color)
		next_text:set_color(not managers.menu:is_pc_controller() and Color.white or current_page < num_pages and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color)
	end
end
function MenuNodeUpdatesGui:mouse_moved(o, x, y)
	local moved = self._mouse_x ~= x or self._mouse_y ~= y
	self._mouse_x = x
	self._mouse_y = y
	if alive(self._prev_page) then
		local text = self._prev_page:child("text_obj")
		if self._current_page > 1 then
			if self._prev_page:inside(x, y) then
				if not self._prev_page_highlighted then
					self._prev_page_highlighted = true
					managers.menu_component:post_event("highlight")
					text:set_color(tweak_data.screen_colors.button_stage_2)
				end
				return true, "link"
			elseif self._prev_page_highlighted then
				self._prev_page_highlighted = false
				text:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end
	if alive(self._next_page) then
		local text = self._next_page:child("text_obj")
		local num_pages = self._num_pages
		if num_pages > self._current_page then
			if self._next_page:inside(x, y) then
				if not self._next_page_highlighted then
					self._next_page_highlighted = true
					managers.menu_component:post_event("highlight")
					text:set_color(tweak_data.screen_colors.button_stage_2)
				end
				return true, "link"
			elseif self._next_page_highlighted then
				self._next_page_highlighted = false
				text:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end
	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui")
	local back_button = panel:child("back_button")
	local back_highlighted = back_button:inside(x, y)
	if back_highlighted then
		if not self._back_button_highlighted then
			self._back_button_highlighted = true
			back_button:set_color(Holomenu_color_highlight)
			self._back_marker:show()
			managers.menu_component:post_event("highlight")
		end
		return true, self._pressed and "arrow" or "link"
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false
		self._back_marker:hide()
		back_button:set_color(Holomenu_color_normal)
	end
	local top_button = panel:child("top_button")
	if alive(top_button) then
		local top_highlighted = top_button:inside(x, y)
		if top_highlighted then
			if not self._top_button_highlighted then
				self._top_button_highlighted = true
				for _, child in ipairs(top_button:children()) do
					child:set_color(tweak_data.screen_colors.button_stage_2)
				end
				managers.menu_component:post_event("highlight")
			end
			return true, self._pressed and "arrow" or "link"
		elseif self._top_button_highlighted then
			self._top_button_highlighted = false
			for _, child in ipairs(top_button:children()) do
				child:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end
	local content_highlighted = self:check_inside(x, y)
	if self:set_latest_content(content_highlighted, moved) then
		return true, self._pressed and (self._pressed == content_highlighted and "link" or "arrow") or "link"
	end
	return false, "arrow"
end
end