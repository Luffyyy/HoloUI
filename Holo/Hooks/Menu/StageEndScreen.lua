if Holo:ShouldModify("Menu", "Lobby") then
	Hooks:PostHook(HUDPackageUnlockedItem, "init", "HoloInit", function(self)
		Holo.Utils:SetBlendMode(self._panel)
	end)
	Hooks:PostHook(HUDStageEndScreen, "init", "HoloInit", function(self)
		self._background_layer_full:child("stage_text"):hide()
		Holo.Utils:SetBlendMode(self._foreground_layer_safe)
		self._box._panel:hide()
		self._package_box._panel:hide()
		self._paygrade_panel:hide()
		local pg_text = self._foreground_layer_safe:child("pg_text") 
		local difficulty = Global.game_settings.difficulty
		difficulty = difficulty == "overkill_145" and "overkill" or difficulty == "overkill_290" and "apocalypse" or difficulty		
		pg_text:set_text(string.upper(managers.localization:text("menu_difficulty_" .. difficulty)))		
		managers.hud:make_fine_text(pg_text)		
		pg_text:set_right(self._paygrade_panel:right())
	end)
	Hooks:PostHook(HUDStageEndScreen, "stage_spin_up", "HoloStageSpinUp", function(self)
		self._lp_text:set_font_size(48)
	end)
end