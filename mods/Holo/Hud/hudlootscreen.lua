if Holo.options.Holomenu_lobby then

require("lib/managers/menu/MenuBackdropGUI")
HUDLootScreen = HUDLootScreen or class()
function HUDLootScreen:init(hud, workspace, saved_lootdrop, saved_selected, saved_chosen, saved_setup)
	self._backdrop = MenuBackdropGUI:new(workspace)
	self._backdrop:create_black_borders()
	self._active = false
	self._hud = hud
	self._workspace = workspace
	local massive_font = tweak_data.menu.pd2_massive_font
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local massive_font_size = tweak_data.menu.pd2_massive_font_size
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	self._background_layer_safe = self._backdrop:get_new_background_layer()
	self._background_layer_full = self._backdrop:get_new_background_layer()
	self._foreground_layer_safe = self._backdrop:get_new_foreground_layer()
	self._foreground_layer_full = self._backdrop:get_new_foreground_layer()
	self._baselayer_two = self._backdrop:get_new_base_layer()
	self._backdrop:set_panel_to_saferect(self._background_layer_safe)
	self._backdrop:set_panel_to_saferect(self._foreground_layer_safe)
	self._callback_handler = {}
	local lootscreen_string = managers.localization:to_upper_text("menu_l_lootscreen")
	local loot_text = self._foreground_layer_safe:text({
		name = "loot_text",
		text = lootscreen_string,
		align = "center",
		vertical = "top",
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})
	self:make_fine_text(loot_text)
	local bg_text = self._background_layer_full:text({
		text = loot_text:text(),
		h = 90,
		align = "left",
		vertical = "top",
		font_size = massive_font_size,
		font = massive_font,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0
	})
	self:make_fine_text(bg_text)
	local x, y = managers.gui_data:safe_to_full_16_9(loot_text:world_x(), loot_text:world_center_y())
	bg_text:set_world_left(loot_text:world_x())
	bg_text:set_world_center_y(loot_text:world_center_y())
	bg_text:move(-13, 9)
	local icon_path, texture_rect = tweak_data.hud_icons:get_icon_data("downcard_overkill_deck")
	self._downcard_icon_path = icon_path
	self._downcard_texture_rect = texture_rect
	self._hud_panel = self._foreground_layer_safe:panel()
	self._hud_panel:set_y(25)
	self._hud_panel:set_h(self._hud_panel:h() - 25 - 150)
	self._peer_data = {}
	self._peers_panel = self._hud_panel:panel({})
	for i = 1, 4 do
		self:create_peer(self._peers_panel, i)
	end
	self._num_visible = 1
	self:set_num_visible(self:get_local_peer_id())
	if saved_setup then
		for _, setup in ipairs(saved_setup) do
			self:make_cards(setup.peer, setup.max_pc, setup.left_card, setup.right_card)
		end
	end
	self._lootdrops = self._lootdrops or {}
	if saved_lootdrop then
		for _, lootdrop in ipairs(saved_lootdrop) do
			self:make_lootdrop(lootdrop)
		end
	end
	if saved_selected then
		for peer_id, selected in pairs(saved_selected) do
			self:set_selected(peer_id, selected)
		end
	end
	if saved_chosen then
		for peer_id, card_id in pairs(saved_chosen) do
			self:begin_choose_card(peer_id, card_id)
		end
	end
	local local_peer_id = self:get_local_peer_id()
	local panel = self._peers_panel:child("peer" .. tostring(local_peer_id))
	local peer_info_panel = panel:child("peer_info")
	local peer_name = peer_info_panel:child("peer_name")
	local experience = (managers.experience:current_rank() > 0 and managers.experience:rank_string(managers.experience:current_rank()) .. "-" or "") .. managers.experience:current_level()
	peer_name:set_text(tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()) .. " (" .. experience .. ")")
	self:make_fine_text(peer_name)
	peer_name:set_right(peer_info_panel:w())
	if managers.experience:current_rank() > 0 then
		peer_info_panel:child("peer_infamy"):set_visible(true)
		peer_info_panel:child("peer_infamy"):set_right(peer_name:x())
		peer_info_panel:child("peer_infamy"):set_top(peer_name:y())
	else
		peer_info_panel:child("peer_infamy"):set_visible(false)
	end
	panel:set_alpha(1)
	peer_info_panel:show()
	panel:child("card_info"):hide()
end
function HUDLootScreen:create_peer(peers_panel, peer_id)
	local massive_font = tweak_data.menu.pd2_massive_font
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local massive_font_size = tweak_data.menu.pd2_massive_font_size
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local color = tweak_data.chat_colors[peer_id]
	local is_local_peer = peer_id == self:get_local_peer_id()
	self._peer_data[peer_id] = {}
	self._peer_data[peer_id].selected = 2
	self._peer_data[peer_id].wait_t = false
	self._peer_data[peer_id].ready = false
	self._peer_data[peer_id].active = false
	self._peer_data[peer_id].wait_for_lootdrop = true
	self._peer_data[peer_id].wait_for_choice = true
	local panel = peers_panel:panel({
		name = "peer" .. tostring(peer_id),
		x = 0,
		y = (peer_id - 1) * 110,
		w = peers_panel:w(),
		h = 110
	})
	local peer_info_panel = panel:panel({
		name = "peer_info",
		w = 255,
		h = panel:h() + 20,
		y = -10
	})
	local peer_name = peer_info_panel:text({
		name = "peer_name",
		font = medium_font,
		font_size = medium_font_size - 1,
		text = " ",
		h = medium_font_size,
		w = 1,
		color = color,
		blend_mode = "normal"
	})
	local infamy_icon = tweak_data.hud_icons:get_icon_data("infamy_icon")
	local peer_infamy = peer_info_panel:bitmap({
		name = "peer_infamy",
		w = 16,
		h = 32,
		texture = infamy_icon,
		visible = false,
		color = color
	})
	self:make_fine_text(peer_name)
	peer_name:set_right(peer_info_panel:w())
	peer_name:set_center_y(peer_info_panel:h() * 0.5)
	local max_quality = peer_info_panel:text({
		name = "max_quality",
		font = small_font,
		font_size = small_font_size - 1,
		text = " ",
		h = medium_font_size,
		w = 1,
		color = tweak_data.screen_colors.text,
		blend_mode = "normal",
		visible = false
	})
	self:make_fine_text(max_quality)
	max_quality:set_right(peer_info_panel:w())
	max_quality:set_top(peer_name:bottom())
	local card_info_panel = panel:panel({name = "card_info", w = 300})
	card_info_panel:set_right(panel:w())
	local main_text = card_info_panel:text({
		name = "main_text",
		font = medium_font,
		font_size = medium_font_size,
		text = managers.localization:to_upper_text(is_local_peer and "menu_l_choose_card_local" or "menu_l_choose_card_peer"),
		blend_mode = "normal",
		wrap = true,
		word_wrap = true,
		rotation = 360
	})
	local quality_text = card_info_panel:text({
		name = "quality_text",
		font = small_font,
		font_size = small_font_size,
		text = " ",
		blend_mode = "normal",
		visible = false
	})
	local global_value_text = card_info_panel:text({
		name = "global_value_text",
		font = small_font,
		font_size = small_font_size,
		text = managers.localization:to_upper_text("menu_l_global_value_infamous"),
		color = tweak_data.lootdrop.global_values.infamous.color,
		blend_mode = "normal",
		rotation = 360
	})
	global_value_text:hide()
	local _, _, _, hh = main_text:text_rect()
	main_text:set_h(hh + 2)
	self:make_fine_text(quality_text)
	self:make_fine_text(global_value_text)
	main_text:set_y(0)
	quality_text:set_y(main_text:bottom())
	global_value_text:set_y(main_text:bottom())
	card_info_panel:set_h(main_text:bottom())
	card_info_panel:set_center_y(panel:h() * 0.5)
	local total_cards_w = panel:w() - peer_info_panel:w() - card_info_panel:w() - 10
	local card_w = math.round((total_cards_w - 10) / 3)
	for i = 1, 3 do
		local card_panel = panel:panel({
			name = "card" .. i,
			x = peer_info_panel:right() + (i - 1) * card_w + 10,
			y = 10,
			w = card_w - 2.5,
			h = panel:h() - 10,
			halign = "scale",
			valign = "scale"
		})
		local downcard = card_panel:bitmap({
			name = "downcard",
			texture = self._downcard_icon_path,
			texture_rect = self._downcard_texture_rect,
			w = math.round(0.7111111 * card_panel:h()),
			h = card_panel:h(),
			blend_mode = "normal",
			rotation = math.random(4) - 2,
			layer = 1,
			halign = "scale",
			valign = "scale"
		})
		if downcard:rotation() == 0 then
			downcard:set_rotation(1)
		end
		if not is_local_peer then
			downcard:set_size(math.round(0.7111111 * card_panel:h() * 0.85), math.round(card_panel:h() * 0.85))
		end
		downcard:set_center(card_panel:w() * 0.5, card_panel:h() * 0.5)
		local bg = card_panel:bitmap({
			name = "bg",
			texture = self._downcard_icon_path,
			texture_rect = self._downcard_texture_rect,
			color = tweak_data.screen_colors.button_stage_3,
			halign = "scale",
			valign = "scale"
		})
		bg:set_rotation(downcard:rotation())
		bg:set_shape(downcard:shape())
		local inside_card_check = panel:panel({
			name = "inside_check_card" .. tostring(i),
			w = 100,
			h = 100
		})
		inside_card_check:set_center(card_panel:center())
		card_panel:hide()
	end
	local box = BoxGuiObject:new(panel:panel({
		x = peer_info_panel:right() + 5,
		y = 5,
		w = total_cards_w,
		h = panel:h() - 10
	}), {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	if not is_local_peer then
		box:set_color(tweak_data.screen_colors.item_stage_2)
	end
	card_info_panel:hide()
	peer_info_panel:hide()
	panel:set_alpha(0)
end
function HUDLootScreen:set_num_visible(peers_num)
	self._num_visible = math.max(self._num_visible, peers_num)
	for i = 1, 4 do
		self._peers_panel:child("peer" .. i):set_visible(i <= self._num_visible)
	end
	self._peers_panel:set_h(self._num_visible * 110)
	self._peers_panel:set_center_y(self._hud_panel:h() * 0.5)
	if managers.menu:is_console() and self._num_visible >= 4 then
		self._peers_panel:move(0, 30)
	end
end
function HUDLootScreen:make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end
function HUDLootScreen:create_selected_panel(peer_id)
	local panel = self._peers_panel:child("peer" .. peer_id)
	local selected_panel = panel:panel({
		name = "selected_panel",
		w = 100,
		h = 100,
		layer = -1
	})
	local glow_circle = selected_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 200,
		h = 200,
		blend_mode = "normal",
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0.4,
		rotation = 360
	})
	local glow_stretch = selected_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 500,
		h = 200,
		blend_mode = "normal",
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0.4,
		rotation = 360
	})
	glow_circle:set_center(selected_panel:w() * 0.5, selected_panel:h() * 0.5)
	glow_stretch:set_center(selected_panel:w() * 0.5, selected_panel:h() * 0.5)
	local anim_func = function(o)
		while true do
			over(1, function(p)
				o:set_alpha(math.sin(p * 180 % 180) * 0.2 + 0.6)
			end)
		end
	end
	selected_panel:animate(anim_func)
	return selected_panel
end
function HUDLootScreen:set_selected(peer_id, selected)
	local panel = self._peers_panel:child("peer" .. peer_id)
	local selected_panel = panel:child("selected_panel") or self:create_selected_panel(peer_id)
	local card_panel = panel:child("card" .. selected)
	selected_panel:set_center(card_panel:center())
	self._peer_data[peer_id].selected = selected
	local is_local_peer = peer_id == self:get_local_peer_id()
	local aspect = 0.7111111
	for i = 1, 3 do
		local card_panel = panel:child("card" .. i)
		local downcard = card_panel:child("downcard")
		local bg = card_panel:child("bg")
		local cx, cy = downcard:center()
		local size = card_panel:h() * (i == selected and 1.15 or 0.9) * (is_local_peer and 1 or 0.85)
		bg:set_color(tweak_data.screen_colors[i == selected and "button_stage_2" or "button_stage_3"])
		downcard:set_size(math.round(aspect * size), math.round(size))
		downcard:set_center(cx, cy)
		downcard:set_alpha(is_local_peer and 1 or 0.58)
		bg:set_alpha(1)
		bg:set_shape(downcard:shape())
	end
end
function HUDLootScreen:add_callback(key, clbk)
	self._callback_handler[key] = clbk
end
function HUDLootScreen:clear_other_peers(peer_id)
	peer_id = peer_id or self:get_local_peer_id()
	for i = 1, 4 do
		if i ~= peer_id then
			self:remove_peer(i)
		end
	end
end
function HUDLootScreen:check_all_ready()
	local ready = true
	for i = 1, 4 do
		if self._peer_data[i].active and ready then
			ready = self._peer_data[i].ready
		end
	end
	return ready
end
function HUDLootScreen:remove_peer(peer_id, reason)
	Application:debug("HUDLootScreen:remove_peer( peer_id, reason )", peer_id, reason)
	local panel = self._peers_panel:child("peer" .. tostring(peer_id))
	panel:stop()
	panel:child("card_info"):hide()
	panel:child("peer_info"):hide()
	panel:child("card1"):stop()
	panel:child("card2"):stop()
	panel:child("card3"):stop()
	panel:child("card1"):hide()
	panel:child("card2"):hide()
	panel:child("card3"):hide()
	if panel:child("item") then
		panel:child("item"):stop()
		panel:child("item"):hide()
	end
	if panel:child("selected_panel") then
		panel:child("selected_panel"):hide()
	end
	self._peer_data[peer_id] = {}
	self._peer_data[peer_id].active = false
end
function HUDLootScreen:hide()
	if self._active then
		return
	end
	self._backdrop:hide()
	if self._video then
		managers.video:remove_video(self._video)
		self._video:parent():remove(self._video)
		self._video = nil
	end
	if self._sound_listener then
		self._sound_listener:delete()
		self._sound_listener = nil
	end
	if self._sound_source then
		self._sound_source:stop()
		self._sound_source:delete()
		self._sound_source = nil
	end
end
function HUDLootScreen:show()
	if not self._video and SystemInfo:platform() ~= Idstring("X360") then
		local variant
		if managers.dlc:is_installing() then
			variant = 1
		else
			variant = math.random(8)
		end
		self._video = self._baselayer_two:video({
			video = "movies/lootdrop" .. tostring(variant),
			loop = false,
			speed = 1,
			blend_mode = "normal",
			alpha = 0.2
		})
		managers.video:add_video(self._video)
	end
	self._backdrop:show()
	self._active = true
	if not self._sound_listener then
		self._sound_listener = SoundDevice:create_listener("lobby_menu")
		self._sound_listener:set_position(Vector3(0, -50000, 0))
		self._sound_listener:activate(true)
	end
	if not self._sound_source then
		self._sound_source = SoundDevice:create_source("HUDLootScreen")
		self._sound_source:post_event(managers.music:jukebox_menu_track("heistfinish"))
	end
	local fade_rect = self._foreground_layer_full:rect({
		layer = 10000,
		color = Color.black
	})
	local function fade_out_anim(o)
		over(0.5, function(p)
			o:set_alpha(1 - p)
		end)
		fade_rect:parent():remove(fade_rect)
	end
	fade_rect:animate(fade_out_anim)
	managers.menu_component:lootdrop_is_now_active()
end
function HUDLootScreen:is_active()
	return self._active
end
function HUDLootScreen:update_layout()
	self._backdrop:_set_black_borders()
end

end