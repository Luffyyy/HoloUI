if Holo.options.Holomenu_lobby then
function MissionBriefingTabItem:init(panel, text, i)
	self._main_panel = panel
	self._panel = self._main_panel:panel()
	self._index = i
	local prev_item_title_text = self._main_panel:child("tab_text_" .. tostring(i - 1))
	local offset = prev_item_title_text and prev_item_title_text:right() 
	self._tab_string = text
	self._tab_string_prefix = ""
	self._tab_string_suffix = ""
	local tab_string = self._tab_string_prefix .. self._tab_string .. self._tab_string_suffix
	self._tab_text = self._main_panel:text({
		name = "tab_text_" .. tostring(self._index),
		text = tab_string,
		h = 32,
		x = offset,
		align = "center",
		vertical = "center",
		font_size = tweak_data.menu.pd2_medium_font_size - 3,
		font = tweak_data.menu.pd2_large_font,
		color = Holomenu_color_tabtext,
		layer = 1,
		blend_mode = "normal"
	})
	local _, _, tw, th = self._tab_text:text_rect()
	self._tab_text:set_size(tw + 30, th + 10)
	self._tab_select_rect = self._main_panel:bitmap({
		name = "tab_select_rect_" .. tostring(self._index),
		texture = "guis/textures/pd2/shared_tab_box",
		layer = 0,
		color = Holomenu_color_tab,
	})
	self._tab_select_rect:set_shape(self._tab_text:shape())
	self._panel:set_top(self._tab_text:bottom())
	self._main_panel:set_top(95.5)
	self._panel:grow(0, -(self._panel:top() + 70 + tweak_data.menu.pd2_small_font_size * 4 + 25))
	self._selected = true
	self:deselect()
 end
function MissionBriefingTabItem:reduce_to_small_font()
 
end
function MissionBriefingTabItem:update_tab_position()
	local prev_item_title_text = self._main_panel:child("tab_text_" .. tostring(self._index - 1))	
	local offset = prev_item_title_text and prev_item_title_text:right() or 0	
	self._tab_select_rect:set_w(self._tab_text:w())
	self._tab_text:set_x(offset)
	self._tab_select_rect:set_x(offset)
end
 
function MissionBriefingTabItem:select(no_sound)
	if self._selected then
		return
	end
	self:show()
	if self._tab_text and alive(self._tab_text) then
		self._tab_text:set_color(Holomenu_color_tabtext)
		self._tab_text:set_blend_mode("normal")
		self._tab_select_rect:set_color(Holomenu_color_tab_highlight)
	end
	self._selected = true
	if no_sound then
		return
	end
	managers.menu_component:post_event("menu_enter")
end
function MissionBriefingTabItem:deselect()
	if not self._selected then
		return
	end
	self:hide()
	if self._tab_text and alive(self._tab_text) then
		self._tab_text:set_color(Holomenu_color_tabtext)
		self._tab_text:set_blend_mode("normal")
		self._tab_select_rect:set_color(Holomenu_color_tab)
	end
	self._selected = false
end

function MissionBriefingTabItem:mouse_moved(x, y)
	if not self._selected then
		if self._tab_text:inside(x, y) then
			if not self._highlighted then
				self._highlighted = true
				self._tab_select_rect:set_color(Holomenu_color_tab_highlight)
				managers.menu_component:post_event("highlight")
			end
		elseif self._highlighted then
			self._tab_select_rect:set_color(Holomenu_color_tab)
			self._highlighted = false
		end
	end
	return self._selected, self._highlighted
end
function MissionBriefingGui:ready_text()
	local legend = not managers.menu:is_pc_controller() and managers.localization:get_default_macro("BTN_Y") or ""
	local ready = self._ready and "READY" or "NOT READY"
	return legend .. ready
end
function MissionBriefingGui:init(saferect_ws, fullrect_ws, node)
	self._safe_workspace = saferect_ws
	self._full_workspace = fullrect_ws
	self._node = node
	self._fullscreen_panel = self._full_workspace:panel():panel()
	self._panel = self._safe_workspace:panel():panel({
		w = self._safe_workspace:panel():w() / 2,
		layer = 6
	})
	self._panel:set_right(self._safe_workspace:panel():w())
	self._panel:set_top(165 + tweak_data.menu.pd2_medium_font_size)
	self._panel:grow(0, -self._panel:top())
	self._ready = managers.network:session():local_peer():waiting_for_player_ready()
	local ready_text = self:ready_text()
	self._ready_button = self._panel:text({
		name = "ready_button",
		text = ready_text,
		align = "right",
		vertical = "center",
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = Holomenu_color_normal,
		layer = 2,
		blend_mode = "normal",
		rotation = 360
	})	

	local _, _, w, h = self._ready_button:text_rect()
	self._ready_button:set_size(w, h)
	self._ready_tick_box = self._panel:bitmap({
		name = "ready_tickbox",
		texture = "guis/textures/pd2/mission_briefing/gui_tickbox",
		w = 22,
		h = 22,
		visible = false,
		layer = 2
	})
	self._ready_tick_box:set_rightbottom(self._panel:w(), self._panel:h())
	self._ready_tick_box:set_image(self._ready and "guis/textures/pd2/mission_briefing/gui_tickbox_ready" or "guis/textures/pd2/mission_briefing/gui_tickbox")
	self._ready_button:set_center_y(self._ready_tick_box:center_y())
	self._ready_button:set_rightbottom(self._panel:w() - 10, self._panel:h() + 105)
	local big_text = self._fullscreen_panel:text({
		name = "ready_big_text",
		text = ready_text,
		h = 90,
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0,
		layer = 1,
		rotation = 360
	})
	WalletGuiObject.set_wallet(self._safe_workspace:panel(), 10)
	self._node:parameters().menu_component_data = self._node:parameters().menu_component_data or {}
	self._node:parameters().menu_component_data.asset = self._node:parameters().menu_component_data.asset or {}
	self._node:parameters().menu_component_data.loadout = self._node:parameters().menu_component_data.loadout or {}
	local asset_data = self._node:parameters().menu_component_data.asset
	local loadout_data = self._node:parameters().menu_component_data.loadout
	if not managers.menu:is_pc_controller() then
		local prev_page = self._panel:text({
			name = "tab_text_0",
			y = 0,
			w = 0,
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			layer = 2,
			text = managers.localization:get_default_macro("BTN_BOTTOM_L"),
			vertical = "top"
		})
		local _, _, w, h = prev_page:text_rect()
		prev_page:set_size(w, h + 10)
		prev_page:set_left(0)
		self._prev_page = prev_page
	end
	self._items = {}
	self._description_item = DescriptionItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_description")), 1, self._node:parameters().menu_component_data.saved_descriptions)
	table.insert(self._items, self._description_item)
	self._assets_item = AssetsItem:new(self._panel, managers.preplanning:has_current_level_preplanning() and managers.localization:to_upper_text("menu_preplanning") or utf8.to_upper(managers.localization:text("menu_assets")), 2, {}, nil, asset_data)
	table.insert(self._items, self._assets_item)
	self._new_loadout_item = NewLoadoutTab:new(self._panel, managers.localization:to_upper_text("menu_loadout"), 3, loadout_data)
	table.insert(self._items, self._new_loadout_item)
	if not Global.game_settings.single_player then
		self._team_loadout_item = TeamLoadoutItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_team_loadout")), 4)
		table.insert(self._items, self._team_loadout_item)
	end
	if tweak_data.levels[Global.level_data.level_id].music ~= "no_music" then
		self._jukebox_item = JukeboxItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_jukebox")), Global.game_settings.single_player and 4 or 5)
		table.insert(self._items, self._jukebox_item)
	end
	local max_x = self._panel:w()
	if not managers.menu:is_pc_controller() then
		local next_page = self._panel:text({
			name = "tab_text_" .. tostring(#self._items + 1),
			y = 0,
			w = 0,
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			layer = 2,
			text = managers.localization:get_default_macro("BTN_BOTTOM_R"),
			vertical = "top"
		})
		local _, _, w, h = next_page:text_rect()
		next_page:set_size(w, h + 10)
		next_page:set_right(self._panel:w())
		self._next_page = next_page
		max_x = next_page:left() - 5
	end
	self._reduced_to_small_font = not managers.menu:is_pc_controller()
	self:chk_reduce_to_small_font()
	self._selected_item = 0
	self:set_tab(self._node:parameters().menu_component_data.selected_tab, true)
	local box_panel = self._panel:panel()
	box_panel:set_shape(self._items[self._selected_item]:panel():shape())
	BoxGuiObject:new(box_panel, {
		sides = {
			0,
			0,
			0,
			0
		}
	})
	box_panel:move(0,2.5)
	if managers.assets:is_all_textures_loaded() or #managers.assets:get_all_asset_ids(true) == 0 then
		self:create_asset_tab()
	end
	self._items[self._selected_item]:select(true)
	self._enabled = true
	self:flash_ready()
end
function MissionBriefingGui:mouse_moved(x, y)
	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return false, "arrow"
	end
	if self._displaying_asset then
		return false, "arrow"
	end
	if game_state_machine:current_state().blackscreen_started and game_state_machine:current_state():blackscreen_started() then
		return false, "arrow"
	end
	local mouse_over_tab = false
	for _, tab in ipairs(self._items) do
		local selected, highlighted = tab:mouse_moved(x, y)
		if highlighted and not selected then
			mouse_over_tab = true
		end
	end
	if mouse_over_tab then
		return true, "link"
	end
	if self._ready_button:inside(x, y) or self._ready_tick_box:inside(x, y) then
		if not self._ready_highlighted then
			self._ready_highlighted = true
			self._ready_button:set_color(Holomenu_color_tab_highlight)
			managers.menu_component:post_event("highlight")
		end
		return true, "link"
	elseif self._ready_highlighted then
		self._ready_button:set_color(Holomenu_color_normal)
		self._ready_highlighted = false
	end
	if managers.hud._hud_mission_briefing and managers.hud._hud_mission_briefing._backdrop then
		managers.hud._hud_mission_briefing._backdrop:mouse_moved(x, y)
	end
	return false, "arrow"
end
end