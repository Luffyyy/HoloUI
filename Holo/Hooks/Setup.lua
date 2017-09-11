Holo:Pre(Setup, "_start_loading_screen", function()
	if Holo then
		if not LoadingEnvironment._start then
			overwrite_meta_function(LoadingEnvironment, "start", function(self, setup, load, data, ...)
				local difficulty = Global.game_settings and Global.game_settings.difficulty
				difficulty = difficulty == "overkill_145" and "overkill" or difficulty == "overkill_290" and "apocalypse" or difficulty
				local level = Global.level_data and tweak_data.levels[Global.level_data.level_id]
				if Holo:ShouldModify("Menu", "Loading") then
					data.Holo = {
						background_color = Holo:GetColor("Colors/Menu"),
						main_color = Holo:GetColor("Colors/Main"),
						text_color = Holo:GetColor("TextColors/Menu"),
						colored_background = Holo.Options:GetValue("ColoredBackground"),
						briefing_string = managers.localization and level and managers.localization:text(level.briefing_id),
						difficulty_string = difficulty and string.upper(managers.localization:text("debug_loading_level").." - "..managers.localization:text(tweak_data.difficulty_name_ids[difficulty]))
					}
				end
				return self:_start(setup, load, data, ...)
			end)
		end
	end
end)