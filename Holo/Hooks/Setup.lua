Hooks:PreHook(Setup, "_start_loading_screen", "HoloStartLoadingScreen", function()
	if Global.level_data then
		local level_tweak_data = tweak_data.levels[Global.level_data.level_id]
		if level_tweak_data then  
			Global.level_data.Holo = Holo:ShouldModify("Menu", "Menu/Loading") 
			Global.level_data.main_color = Holo:GetColor("Colors/Main")
			Global.level_data.text_color = Holo:GetColor("TextColors/Menu")
			Global.level_data.colored_background = Holo.Options:GetValue("Menu/ColoredBackground")
			Global.level_data.background_color = Holo:GetColor("Colors/MenuBackground")
			Global.level_data.briefing_string = managers.localization:text(level_tweak_data.briefing_id)
			local difficulty = Global.game_settings.difficulty
			difficulty = difficulty == "overkill_145" and "overkill" or difficulty == "overkill_290" and "apocalypse" or difficulty	
			Global.level_data.difficulty_string = managers.localization:to_upper_text("debug_loading_level") .. " - " .. managers.localization:to_upper_text("menu_difficulty_" .. difficulty)
		end
	end
end)