if Holo.options.HudBox_enable == true and Holo.options.Timerbg_enable == true then 
CloneClass(HUDHeistTimer)
Hooks:PostHook(HUDHeistTimer, "init", "NewInit", function(self, hud, full_hud)

	Timer_bg = self._heist_timer_panel:bitmap({ 
	align = "center", 
	vertical = "top", 
	color = Timerbg_color,
	name = "Timer_bg",
	blend_mode = "normal", 
	visible = true, 
	layer = 0, 
	alpha = HoloAlpha,
	w = 60,
	h = 25,
	x = 570 
	})
	self._timer_text:set_color(Timer_text_color)
	self._timer_text:set_font_size(26)
end)

end