if Holo.options.HudBox_enable == true and Holo.options.Timerbg_enable == true then 
CloneClass(HUDHeistTimer)
Hooks:PostHook(HUDHeistTimer, "init", "NewInit", function(self, hud, full_hud)

  self._bg_box = HUDBGBox_create( self._heist_timer_panel, { w = 60, h = 25, x = 0, y = 0, align = "center", vertical = "top"}, { color = Timerbg_color, blend_mode = "normal", alpha = HoloAlpha } )
  self._bg_box:child("bg"):set_color(Timerbg_color)
  self._bg_box:child("bg"):set_alpha(HoloAlpha)
    self._bg_box:set_center(self._timer_text:center())
    self._bg_box:set_y(self._timer_text:y())

  self._timer_text:set_color(Timer_text_color)
  self._timer_text:set_font_size(26)
end)

Hooks:PostHook(HUDHeistTimer, "set_time", "bg_visible", function(self)
    if Holo.options.HoxHud_support == true then
    self._bg_box:set_visible(managers.hud._hud_assault_corner._assault ~= true and true or false)
    if managers.hud._hud_assault_corner._assault == true then
    self._timer_text:set_color(Assault_text_color)
  end
  end
  end)


end