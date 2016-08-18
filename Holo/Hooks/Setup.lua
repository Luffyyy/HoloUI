local oinit = Setup._start_loading_screen
function Setup:_start_loading_screen()
	if Global.level_data then
		local level_tweak_data = tweak_data.levels[Global.level_data.level_id]
		if level_tweak_data then
			Global.level_data.briefing_string = managers.localization:text(level_tweak_data.briefing_id)
		end
	end
	oinit(self)
end
 
