if Holo.options.Menu_enable then

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 7 or 6.9) / 8
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size

BlackMarketGuiTabItem = BlackMarketGuiTabItem or class(BlackMarketGuiItem)
local oinit = BlackMarketGuiTabItem.init
function BlackMarketGuiTabItem:init(...)
	oinit(self, ...)
	self._tab_panel:child("tab_select_rect"):move(0, -1.5)
	self._tab_panel:child("tab_text"):show()	
end
function BlackMarketGuiTabItem:refresh()
	self._alpha = 1
	self._tab_panel:child("tab_text"):set_color(Holomenu_color_tabtext)
	self._tab_panel:child("tab_text"):set_blend_mode("normal")
	self._tab_panel:child("tab_select_rect"):set_color((self._selected or self._highlighted) and Holomenu_color_tab_highlight or Holomenu_color_tab)
	self._tab_panel:child("tab_select_rect"):show()
	if self._child_panel and alive(self._child_panel) then
		self._child_panel:set_visible(self._selected)
	end
	if alive(self._tab_pages_panel) then
		self._tab_pages_panel:set_visible(self._selected)
	end
end

BlackMarketGuiButtonItem = BlackMarketGuiButtonItem or class(BlackMarketGuiItem)
function BlackMarketGuiButtonItem:init(main_panel, data, x)
	BlackMarketGuiButtonItem.super.init(self, main_panel, data, 0, 0, 10, 10)
	local up_font_size = NOT_WIN_32 and RenderSettings.resolution.y < 720 and self._data.btn == "BTN_STICK_R" and 2 or 0
	self._btn_text = self._panel:text({
		name = "text",
		text = "",
		align = "left",
		x = 10,
		font_size = small_font_size + up_font_size,
		font = small_font,
		color = Holomenu_color_normal,
		blend_mode = "normal",
		layer = 1
	})
	self._btn_text_id = data.name
	self._btn_text_legends = data.legends
	BlackMarketGui.make_fine_text(self, self._btn_text)
	self._panel:set_size(main_panel:w() - x * 2, medium_font_size)
	self._panel:rect({
		name = "select_rect",
		blend_mode = "normal",
		color = Holomenu_color_marker,
		alpha = Holomenu_markeralpha,
		valign = "scale",
		halign = "scale"
	})
	if not managers.menu:is_pc_controller() then
		self._btn_text:set_color(tweak_data.screen_colors.text)
	end
	self._panel:set_left(x)
	self._panel:hide()
	self:set_order(data.prio)
	self._btn_text:set_right(self._panel:w())
	self:deselect(true)
	self:set_highlight(false)
end

function BlackMarketGuiButtonItem:refresh()
	if managers.menu:is_pc_controller() then
		self._btn_text:set_color(self._highlighted and Holomenu_color_highlight or Holomenu_color_normal)
	end
	self._panel:child("select_rect"):set_visible(self._highlighted)
end
BlackMarketGui = BlackMarketGui or class(BlackMarketGui)

Hooks:PostHook(BlackMarketGui, "_setup", "setup", function(self, is_start_page, component_data)
	local back_button = self._panel:child("back_button")
	back_button:set_color(Holomenu_color_normal)
	back_button:set_font_size(tweak_data.menu.pd2_medium_font_size)
	self._fullscreen_panel:child("back_button"):hide()

	self._back_marker = self._panel:bitmap({
		color = Holomenu_color_marker,
		alpha = Holomenu_markeralpha,
		visible = false,
		layer = self._panel:child("back_button"):layer() - 1
	})
	x,y,w,h = back_button:text_rect()
	self._back_marker:set_shape(x,y,313,h)
	self._back_marker:set_right(x + w)

	self._selectbg = self._select_rect:rect({
		name = "selectbg",
		layer = -10,
		alpha = 0.2,
		color = Color.white
	})
end)
 
function BlackMarketGuiTabItem:mouse_moved(x, y)
	if alive(self._tab_pages_panel) then
		local previous_page = self._tab_pages_panel:child("previous_page")
		local next_page = self._tab_pages_panel:child("next_page")
		local inside_prev = previous_page:inside(x, y)
		local inside_next = next_page:inside(x, y)
		local used = false
		local pointer = "arrow"
		if inside_prev then
			if not self._previous_page_highlighted then
				self._previous_page_highlighted = true
				previous_page:set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			used = true
			pointer = "link"
		elseif self._previous_page_highlighted then
			self._previous_page_highlighted = false
			previous_page:set_color(Holomenu_color_normal)
		end
		if inside_next then
			if not self._next_page_highlighted then
				self._next_page_highlighted = true
				next_page:set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			used = true
			pointer = "link"
		elseif self._next_page_highlighted then
			self._next_page_highlighted = false
			next_page:set_color(Holomenu_color_normal)
		end
		if used then
			return used, pointer
		end
	end
	return self:moved_scroll_bar(x, y)
end
function BlackMarketGui:mouse_moved(o, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end
	if not self._enabled then
		return
	end
	if self._renaming_item then
		return true, "link"
	end
	if alive(self._no_input_panel) then
		self._no_input = self._no_input_panel:inside(x, y)
	end
	if self._extra_options_data then
		local used = false
		local pointer = "arrow"
		self._extra_options_data.selected = self._extra_options_data.selected or 1
		local selected_slot
		for i = 1, self._extra_options_data.num_panels do
			local option = self._extra_options_data[i]
			local panel = option.panel
			local image = option.image
			if alive(panel) and panel:inside(x, y) then
				if not option.highlighted then
					option.highlighted = true
				end
				used = true
				pointer = "link"
			elseif option.highlighted then
				option.highlighted = false
			end
			if alive(image) then
				image:set_alpha((option.selected and 1 or 0.9) * (option.highlighted and 1 or 0.9))
			end
		end
		if used then
			return used, pointer
		end
	elseif self._steam_inventory_extra_data and alive(self._steam_inventory_extra_data.gui_panel) then
		local used = false
		local pointer = "arrow"
		local extra_data = self._steam_inventory_extra_data
		if extra_data.arrow_left:inside(x, y) then
			if not extra_data.arrow_left_highlighted then
				extra_data.arrow_left_highlighted = true
				extra_data.arrow_left:set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			used = true
			pointer = "link"
		elseif extra_data.arrow_left_highlighted then
			extra_data.arrow_left_highlighted = false
			extra_data.arrow_left:set_color(Holomenu_color_normal)
		end
		if extra_data.arrow_right:inside(x, y) then
			if not extra_data.arrow_right_highlighted then
				extra_data.arrow_right_highlighted = true
				extra_data.arrow_right:set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			used = true
			pointer = "link"
		elseif extra_data.arrow_right_highlighted then
			extra_data.arrow_right_highlighted = false
			extra_data.arrow_right:set_color(Holomenu_color_normal)
		end
		if used then
			if alive(extra_data.bg) then
				extra_data.bg:set_color(Holomenu_color_marker:with_alpha(0.2))
				extra_data.bg:set_alpha(1)
			end
			return used, pointer
		elseif alive(extra_data.bg) then
			extra_data.bg:set_color(Color.black:with_alpha(0.5))
		end
	end
	local inside_tab_area = self._tab_area_panel:inside(x, y)
	local used = true
	local pointer = inside_tab_area and self._highlighted == self._selected and "arrow" or "link"
	local inside_tab_scroll = self._tab_scroll_panel:inside(x, y)
	local update_select = false
	if not self._highlighted then
		update_select = true
		used = false
		pointer = "arrow"
	elseif not inside_tab_scroll or self._tabs[self._highlighted] and not self._tabs[self._highlighted]:inside(x, y) then
		self._tabs[self._highlighted]:set_highlight(not self._pages, not self._pages)
		self._highlighted = nil
		update_select = true
		used = false
		pointer = "arrow"
	end
	if update_select then
		for i, tab in ipairs(self._tabs) do
			update_select = inside_tab_scroll and tab:inside(x, y)
			if update_select then
				self._highlighted = i
				self._tabs[self._highlighted]:set_highlight(self._selected ~= self._highlighted)
				used = true
				pointer = self._highlighted == self._selected and "arrow" or "link"
			end
		end
	end
	if self._tabs[self._selected] then
		local tab_used, tab_pointer = self._tabs[self._selected]:mouse_moved(x, y)
		if tab_used then
			local x, y = self._tabs[self._selected]:selected_slot_center()
			self._select_rect:set_world_center(x, y)
			self._select_rect:stop()
			self._select_rect_box:set_color(Color.white)
			self._select_rect:set_visible(y > self._tabs[self._selected]._grid_panel:top() and y < self._tabs[self._selected]._grid_panel:bottom() and self._selected_slot and self._selected_slot._name ~= "empty")
			used = tab_used
			pointer = tab_pointer
		end
	end
	if self._market_bundles then
		local active_bundle = self._market_bundles[self._data.active_market_bundle]
		if active_bundle then
			for key, data in pairs(active_bundle) do
				if key ~= "panel" and (alive(data.text) and data.text:inside(x, y) or alive(data.image) and data.image:inside(x, y)) then
					if not data.highlighted then
						data.highlighted = true
						if alive(data.image) then
							data.image:set_alpha(1)
						end
						if alive(data.text) then
							data.text:set_color(Holomenu_color_marker)
						end
						managers.menu_component:post_event("highlight")
					end
					if not used then
						used = true
						pointer = "link"
					end
				elseif data.highlighted then
					data.highlighted = false
					if alive(data.image) then
						data.image:set_alpha(0.9)
					end
					if alive(data.text) then
						data.text:set_color(Holomenu_color_normal)
					end
				end
			end
		end
		if self._market_bundles.arrow_left then
			if self._market_bundles.arrow_left:inside(x, y) then
				if not self._market_bundles.arrow_left_highlighted then
					self._market_bundles.arrow_left_highlighted = true
					managers.menu_component:post_event("highlight")
					self._market_bundles.arrow_left:set_color(Holomenu_color_marker)
				end
				if not used then
					used = true
					pointer = "link"
				end
			elseif self._market_bundles.arrow_left_highlighted then
				self._market_bundles.arrow_left_highlighted = false
				self._market_bundles.arrow_left:set_color(Holomenu_color_normal)
			end
		end
		if self._market_bundles.arrow_right then
			if self._market_bundles.arrow_right:inside(x, y) then
				if not self._market_bundles.arrow_right_highlighted then
					self._market_bundles.arrow_right_highlighted = true
					managers.menu_component:post_event("highlight")
					self._market_bundles.arrow_right:set_color(Holomenu_color_marker)
				end
				if not used then
					used = true
					pointer = "link"
				end
			elseif self._market_bundles.arrow_right_highlighted then
				self._market_bundles.arrow_right_highlighted = false
				self._market_bundles.arrow_right:set_color(Holomenu_color_normal)
			end
		end
	end
	if self._panel:child("back_button"):inside(x, y) then
		used = true
		pointer = "link"
		if not self._back_button_highlighted then
			self._back_button_highlighted = true
			self._panel:child("back_button"):set_color(Holomenu_color_highlight)
			self._back_marker:show()
			managers.menu_component:post_event("highlight")
			return used, pointer
		end
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false
		self._back_marker:hide()
		self._panel:child("back_button"):set_color(Holomenu_color_normal)
	end
	update_select = false
	if not self._button_highlighted then
		update_select = true
	elseif self._btns[self._button_highlighted] and not self._btns[self._button_highlighted]:inside(x, y) then
		self._btns[self._button_highlighted]:set_highlight(false)
		self._button_highlighted = nil
		update_select = true
	end
	if update_select then
		for i, btn in pairs(self._btns) do
			if not self._button_highlighted and btn:visible() and btn:inside(x, y) then
				self._button_highlighted = i
				btn:set_highlight(true)
			else
				btn:set_highlight(false)
			end
		end
	end
	if self._button_highlighted then
		used = true
		pointer = "link"
	end
	if self._tab_scroll_table.left and self._tab_scroll_table.left_klick then
		local color
		if self._tab_scroll_table.left:inside(x, y) then
			color = Holomenu_color_marker
			used = true
			pointer = "link"
		else
			color = Holomenu_color_normal
		end
		self._tab_scroll_table.left:set_color(color)
	end
	if self._tab_scroll_table.right and self._tab_scroll_table.right_klick then
		local color
		if self._tab_scroll_table.right:inside(x, y) then
			color = Holomenu_color_marker
			used = true
			pointer = "link"
		else
			color = Holomenu_color_normal
		end
		self._tab_scroll_table.right:set_color(color)
	end
	if self._rename_info_text then
		local text_button = self._info_texts and self._info_texts[self._rename_info_text]
		if text_button then
			if self._slot_data and not self._slot_data.customize_locked and text_button:inside(x, y) then
				if not self._rename_highlight then
					self._rename_highlight = true
					text_button:set_blend_mode("normal")
					text_button:set_color(Holomenu_color_marker)
					local bg = self._info_texts_bg[self._rename_info_text]
					if alive(bg) then
						bg:set_visible(true)
						bg:set_color(Holomenu_color_normal)
					end
					managers.menu_component:post_event("highlight")
				end
				used = true
				pointer = "link"
			elseif self._rename_highlight then
				self._rename_highlight = false
				text_button:set_blend_mode("normal")
				text_button:set_color(tweak_data.screen_colors.text)
				local bg = self._info_texts_bg[self._rename_info_text]
				if alive(bg) then
					bg:set_visible(false)
					bg:set_color(Color.black)
				end
			end
		end
	end
	return used, pointer
end
 

 function BlackMarketGuiSlotItem:select(instant, no_sound)
	BlackMarketGuiSlotItem.super.select(self, instant, no_sound)
	if not managers.menu:is_pc_controller() then
		self:set_highlight(true, instant)
	end
	if self._text_in_mid and alive(self._panel:child("text")) then
		self._panel:child("text"):set_color(Holomenu_color_marker)
		self._panel:child("text"):set_blend_mode("normal")
		self._panel:child("text"):set_text(self._data.mid_text.no_upper and self._data.mid_text.selected_text or utf8.to_upper(self._data.mid_text.selected_text or ""))
		if alive(self._lock_bitmap) and self._data.mid_text.is_lock_same_color then
			self._lock_bitmap:set_color(self._panel:child("text"):color())
		end
	end
	if self._data.new_drop_data then
		local newdrop = self._data.new_drop_data
		if newdrop[1] and newdrop[2] and newdrop[3] then
			managers.blackmarket:remove_new_drop(newdrop[1], newdrop[2], newdrop[3])
			if newdrop.icon then
				newdrop.icon:parent():remove(newdrop.icon)
			end
			self._data.new_drop_data = nil
		end
	end
	if self._panel:child("equipped_text") and self._data.selected_text and not self._data.equipped then
		self._panel:child("equipped_text"):set_text(self._data.selected_text)
	end
	if self._mini_panel and self._data.hide_unselected_mini_icons then
		self._mini_panel:show()
	end
	return self
end
function BlackMarketGuiSlotItem:deselect(instant)
	BlackMarketGuiSlotItem.super.deselect(self, instant)
	if not managers.menu:is_pc_controller() then
		self:set_highlight(false, instant)
	end
	if self._text_in_mid and alive(self._panel:child("text")) then
		self._panel:child("text"):set_color(Holomenu_color_normal)
		self._panel:child("text"):set_blend_mode("normal")
		self._panel:child("text"):set_text(self._data.mid_text.no_upper and self._data.mid_text.noselected_text or utf8.to_upper(self._data.mid_text.noselected_text or ""))
		if alive(self._lock_bitmap) and self._data.mid_text.is_lock_same_color then
			self._lock_bitmap:set_color(self._panel:child("text"):color())
		end
	end
	if self._panel:child("equipped_text") and self._data.selected_text and not self._data.equipped then
		self._panel:child("equipped_text"):set_text("")
	end
	if self._mini_panel and self._data.hide_unselected_mini_icons then
		self._mini_panel:hide()
	end
end
end
