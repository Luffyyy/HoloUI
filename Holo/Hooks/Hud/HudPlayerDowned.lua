if Holo.Options:GetValue("Hud") and (not restoration or not (restoration.Options and restoration.Options:GetValue("HUD/MainHud"))) then
	Hooks:PostHook(HUDPlayerDowned, "init", "HoloInit", function(self, hud, ...)	
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)	
	function HUDPlayerDowned:UpdateHolo()
		local scale = Holo.Options:GetValue("HudScale")
		local downed_panel = self._hud_panel:child("downed_panel")
		local timer_msg = downed_panel:child("timer_msg")
		timer_msg:configure({
			w = 400 * scale,
			font_size = 24 * scale,
		})	
		local _, _, w, h = timer_msg:text_rect()
		timer_msg:set_h(h)
		timer_msg:set_x(math.round(self._hud_panel:center_x() - timer_msg:w() / 2))
		timer_msg:set_y(24 * scale)

		self._hud.arrest_finished_text:set_font_size(24 * scale)
		local _, _, w, h = self._hud.arrest_finished_text:text_rect()
		self._hud.arrest_finished_text:set_h(h)
		self._hud.arrest_finished_text:set_y(24 * scale)
		self._hud.arrest_finished_text:set_center_x(self._hud_panel:center_x())	

		self._hud.timer:set_font_size(24 * scale)
		local _, _, w, h = self._hud.timer:text_rect()		
		self._hud.timer:set_h(h)
		self._hud.timer:set_top(self._hud.arrest_finished_text:bottom())
		self._hud.timer:set_center_x(self._hud_panel:center_x())
	end
	function HUDPlayerDowned:show_timer()
		local downed_panel = self._hud_panel:child("downed_panel")
		local timer_msg = downed_panel:child("timer_msg")
		timer_msg:set_visible(true)
		self._hud.timer:set_visible(true)
		QuickAnim:Work(timer_msg, "alpha", 1)
		QuickAnim:Work(self._hud.timer, "alpha", 1)
	end
	function HUDPlayerDowned:hide_timer()
		local downed_panel = self._hud_panel:child("downed_panel")
		local timer_msg = downed_panel:child("timer_msg")
		QuickAnim:Work(timer_msg, "alpha", .65)
		QuickAnim:Work(self._hud.timer, "alpha", .65)	
	end
	Hooks:PostHook(HUDPlayerDowned, "on_downed", "HoloOnDowned", function(self)
		if Holo.Options:GetValue("HealthText") and managers.hud._teammate_panels[managers.hud.PLAYER_PANEL].UpdateHolo then
		 	managers.hud._teammate_panels[managers.hud.PLAYER_PANEL]:set_downed()
		end
	end)
end