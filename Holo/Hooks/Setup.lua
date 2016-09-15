Hooks:RegisterHook("SetupPreInitManagers")
Hooks:PreHook(Setup, "_start_loading_screen", "HoloStartLoadingScreen", function()
	if Global.level_data then
		local level_tweak_data = tweak_data.levels[Global.level_data.level_id]
		if level_tweak_data then  
			Global.level_data.Holo = Holo.Options:GetValue("Menu/Loading")
			Global.level_data.main_color = Holo:GetColor("Colors/Main")
			Global.level_data.colored_background = Holo.Options:GetValue("Menu/ColoredBackground")
			Global.level_data.background_color = Holo:GetColor("Colors/MenuBackground")
			Global.level_data.briefing_string = managers.localization:text(level_tweak_data.briefing_id)
		end
	end
end)
Hooks:PreHook(Setup, "init_managers", "HoloInitManagers", function(self)
	Hooks:Call("SetupPreInitManagers", self)
end)