if Holo:ShouldModify("Menu", "BlackScreen") then
	Hooks:PreHook(IngameWaitingForPlayersState, "at_enter", "HoloAtEnter", function(self)
		if not managers.hud:exists(self.LEVEL_INTRO_GUI) then
			managers.hud:load_hud(self.LEVEL_INTRO_GUI, false, false, false, {})
		end
	end)
	Hooks:PreHook(IngameWaitingForPlayersState, "update", "HoloUpdate", function(self)
		if self._skip_data then
	        self._skip_data = {current = 1, total = 1}
	    end
	end)
end