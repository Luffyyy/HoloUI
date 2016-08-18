
function HUDStatsScreen:show()
	local safe = managers.hud.STATS_SCREEN_SAFERECT
	local full = managers.hud.STATS_SCREEN_FULLSCREEN
	managers.hud:show(full)
	local left_panel = self._full_hud_panel:child("left_panel")
	local right_panel = self._full_hud_panel:child("right_panel")
	local bottom_panel = self._full_hud_panel:child("bottom_panel")
	left_panel:stop()
	self:_create_stats_screen_profile(bottom_panel:child("profile_wrapper_panel"))
	self:_create_stats_screen_objectives(left_panel:child("objectives_panel"))
	self:_create_stats_ext_inventory(right_panel:child("ext_inventory_panel"))
	self:_update_stats_screen_loot(left_panel:child("loot_wrapper_panel"))
	self:_update_stats_screen_day(right_panel)
	local teammates_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("teammates_panel")
	local objectives_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("objectives_panel")
	local chat_panel = managers.hud._hud_chat_ingame._panel 
	left_panel:animate(callback(self, self, "_animate_show_stats_left_panel"), right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
	self._showing_stats_screen = true
	if managers.groupai:state() and not self._whisper_listener then
		self._whisper_listener = "HUDStatsScreen_whisper_mode"
		managers.groupai:state():add_listener(self._whisper_listener, {
			"whisper_mode"
		}, callback(self, self, "on_whisper_mode_changed"))
	end
end
function HUDStatsScreen:hide()
	self._showing_stats_screen = false
	local safe = managers.hud.STATS_SCREEN_SAFERECT
	local full = managers.hud.STATS_SCREEN_FULLSCREEN
	if not managers.hud:exists(safe) then
		return
	end
	managers.hud:hide(safe)
	local left_panel = self._full_hud_panel:child("left_panel")
	local right_panel = self._full_hud_panel:child("right_panel")
	local bottom_panel = self._full_hud_panel:child("bottom_panel")
	left_panel:stop()
	local teammates_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("teammates_panel")
	local objectives_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("objectives_panel")
	local chat_panel = managers.hud._hud_chat_ingame._panel 
	left_panel:animate(callback(self, self, "_animate_hide_stats_left_panel"), right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
	if managers.groupai:state() and self._whisper_listener then
		managers.groupai:state():remove_listener(self._whisper_listener)
		self._whisper_listener = nil
	end
end

function HUDStatsScreen:_animate_show_stats_left_panel(left_panel, right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
	local start_x = left_panel:x()
	local start_a = 1 - start_x / -left_panel:w()
	local TOTAL_T = 0.33 * (start_x / -left_panel:w())
	local t = 0
	while TOTAL_T > t do
		local dt = coroutine.yield() * (1 / TimerManager:game():multiplier())
		t = t + dt
		local a = math.lerp(start_a, 1, t / TOTAL_T)
		left_panel:set_alpha(a)
		left_panel:set_x(math.lerp(start_x, 0, t / TOTAL_T))
		right_panel:set_alpha(a)
		right_panel:set_x(right_panel:parent():w() - (left_panel:x() + right_panel:w()))
		bottom_panel:set_alpha(a)
		bottom_panel:set_y(bottom_panel:parent():h() - (left_panel:x() + bottom_panel:h()))
		local a_half = 0.5 + (1 - a) * 0.5
		teammates_panel:set_alpha(a_half)
		objectives_panel:set_alpha(1 - a)
		chat_panel:set_alpha(a_half)
	end
	left_panel:set_x(0)
	left_panel:set_alpha(1)
	teammates_panel:set_alpha(0.5)
	objectives_panel:set_alpha(0)
	chat_panel:set_alpha(0.5)
	right_panel:set_alpha(1)
	right_panel:set_x(right_panel:parent():w() - right_panel:w())
	bottom_panel:set_alpha(1)
	bottom_panel:set_y(bottom_panel:parent():h() - bottom_panel:h())
	self:_rec_round_object(left_panel)
	self:_rec_round_object(right_panel)
	self:_rec_round_object(bottom_panel)
end
function HUDStatsScreen:_animate_hide_stats_left_panel(left_panel, right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
	local start_x = left_panel:x()
	local start_a = 1 - start_x / -left_panel:w()
	local TOTAL_T = 0.33 * (1 - start_x / -left_panel:w())
	local t = 0
	while TOTAL_T > t do
		local dt = coroutine.yield() * (1 / TimerManager:game():multiplier())
		t = t + dt
		local a = math.lerp(start_a, 0, t / TOTAL_T)
		left_panel:set_alpha(a)
		left_panel:set_x(math.lerp(start_x, -left_panel:w(), t / TOTAL_T))
		right_panel:set_alpha(a)
		right_panel:set_x(right_panel:parent():w() - (left_panel:x() + right_panel:w()))
		bottom_panel:set_alpha(a)
		bottom_panel:set_y(bottom_panel:parent():h() - (left_panel:x() + bottom_panel:h()))
		local a_half = 0.5 + (1 - a) * 0.5
		teammates_panel:set_alpha(a_half)
		objectives_panel:set_alpha(1 - a)
		chat_panel:set_alpha(a_half)
	end
	left_panel:set_x(-left_panel:w())
	left_panel:set_alpha(0)
	teammates_panel:set_alpha(1)
	objectives_panel:set_alpha(1)
	chat_panel:set_alpha(1)
	right_panel:set_alpha(0)
	right_panel:set_x(right_panel:parent():w())
	bottom_panel:set_alpha(0)
	bottom_panel:set_y(bottom_panel:parent():h())
end
