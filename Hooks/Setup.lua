Holo:Pre(Setup, "_start_loading_screen", function()
	if Holo then
		local loc = managers.localization
		Holo:Pre(getmetatable(LoadingEnvironment), "start", function(self, setup, load, data)
			local difficulty = Global.game_settings and Global.game_settings.difficulty
			local level = Global.level_data and tweak_data.levels[Global.level_data.level_id]
			local diff_text = tweak_data.difficulty_name_ids[difficulty]
			if Holo:ShouldModify("Menu", "Loading") then
				data.Holo = {
					background_color = Holo:GetColor("Colors/Menu"),
					text_color = Holo:GetColor("TextColors/Menu"),
					colored_background = Holo.Options:GetValue("ColoredBackground"),
					briefing_string = loc and level and loc:text(level.briefing_id),
					difficulty_string = loc and diff_text and (loc:to_upper_text("debug_loading_level").." - "..loc:to_upper_text(diff_text)) or nil
				}
			end
		end)
	end
end)